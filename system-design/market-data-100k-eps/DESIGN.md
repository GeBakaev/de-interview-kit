# Design: real-time clickstream ingestion + IP scoring @ 100k events/sec

- **Date:** 2026-06-08 (core) · 2026-07-06 (closer)
- **Time taken:** ~80 min, timed
- **Status:** complete.
- **Prompt:** Ingest a real-time event feed at 100k events/sec, score activity per IP, serve it to dashboards, and persist raw forever for replay.

> Event reframed to my domain: a clickstream/analytics line — `(ip, page_url, geo, timestamp, user_hash, country)`.

## 1. Requirements & assumptions

**Functional**

- Ingest ~100k events/sec (steady-state target for this pass).
- Dedup events.
- Score per IP (aggregate many events for the same IP into one evolving score).
- Serve scores to dashboards (pull/query).
- Persist raw forever for replay; keep curated fields queryable.

**Non-functional**

- **Latency: relaxed.** "Real-time-ish" is nice-to-have, not a hard SLA → micro-batch is fine, no sub-second path needed. (This decision unlocks most of the simplifications below.)
- Durability: no data loss on ingest; survive consumer restarts.
- Reads: low QPS, heavy aggregate scans.

**Out of scope:** auth, GDPR/PII handling of IPs (would matter in reality), multi-region.

## 2. Back-of-envelope

- Event size: **~500 bytes** (6 short fields + JSON overhead).
- 100k × 500 B = **50 MB/s**
- × 86,400 = **~4.3 TB/day** raw
- Forever retention → ~130 TB/month, **~1.5 PB/year** raw
- Parquet + columnar compression (5–10x) → cold grows **~0.5–0.9 TB/day** compressed
- **Implication:** volume _forces_ tiered storage — "just put it all in BigQuery" is wrong. Raw→cold + curated→BQ is derived from the math, not guessed.

## 3. High-level architecture

```
producers
   │  100k events/sec
   ▼
Pub/Sub topic           ← front door: absorbs the firehose, buffers,
   │                       decouples ingest from processing, retains for replay
   ▼
Dataflow (streaming, windowed)
   ├─► GCS raw zone      ← windowed Parquet files (Dataflow writes them, not clients)
   └─► BigQuery curated  ← dropped unwanted fields, typed
        │
        ├─ daily dedup (batch pass on the date partition)
        ├─ keyed aggregation → ip_scores (MERGE/upsert on identity key)
        │
        ▼
   dashboards (query ip_scores / curated)

GCS lifecycle policy: raw objects → Coldline/Archive at 10 days.
```

## 4. Component choices + the alternative for each

| Component         | Choice                                 | Alternative                        | Why                                                                                                        |
| ----------------- | -------------------------------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Front-door buffer | **Pub/Sub**                            | Kafka                              | Managed, scales past 100k/sec, native to GCP stack; Kafka if multi-cloud / tighter ordering control needed |
| Processing        | **Dataflow** (Apache Beam)             | Spark Structured Streaming / Flink | On-stack, autoscaling, unified batch+stream; Flink if richer keyed-state semantics needed                  |
| Raw store         | **GCS Parquet** + lifecycle            | BQ long-term                       | Cheap, columnar, replay source of truth                                                                    |
| Curated store     | **BigQuery**                           | ClickHouse / Druid                 | Scan-heavy dashboard queries, serverless                                                                   |
| Cold tier         | **GCS Coldline/Archive via lifecycle** | manual export job                  | Zero-code managed transition                                                                               |

## 5. Deep dives

**Delivery & the dedup loop.** Pub/Sub is **at-least-once** → duplicates are _guaranteed_. So dedup isn't optional, it's a direct consequence. Dedup is **daily, keyed on `(ip, page_url, user_hash)`**, run as a **batch pass on the landed daily BQ partition** (`ROW_NUMBER() OVER (PARTITION BY ip,page,hash ...)`). Bounded window = tractable state; we never reconcile across all of time.

**Scoring = stateful aggregation, made idempotent.** Score per IP is an _aggregation_, not a dedup. Compute it **keyed on `(ip, date[, page])`** and **MERGE/upsert** into `ip_scores`. The score is the _value written_, never part of the key. Re-processing a window overwrites the same row with the same correct value → idempotent, no accumulation, no coincidental drops. _(Open decision: daily scores = bounded state, clean; lifetime scores = unbounded → external state store like Bigtable or periodic BQ recompute.)_

**Error handling.** Bad / missing-IP records dropped — but **not silently**: route to a dead-letter table and emit a drop-rate metric ("dropped 0.3% today" is a number interviewers ask for).

## 6. Reliability

**Dataflow job dies mid-window.** Two mechanisms together → at-least-once, no loss. (1) **Pub/Sub ack-on-commit:** a message stays in the subscription until Dataflow *acks* it, and it only acks once results are durably committed. A worker dying mid-window leaves those messages unacked → Pub/Sub **redelivers** them. (2) **Dataflow checkpointing:** in-flight window/aggregation state is persisted to durable checkpoints; on restart the job resumes from the last one. Committed work isn't redone; unacked work is reprocessed.

**Curated BQ corrupted** (bad deploy, botched schema change). Two recovery tiers: **BQ time travel** (`FOR SYSTEM_TIME AS OF`, up to **7 days**) or a table snapshot for a fast restore; and for a full rebuild, **reprocess the GCS raw Parquet** — the immutable source of truth. Cheap precisely because curated is always reproducible from raw.

**BQ briefly unavailable.** Nothing dropped: Dataflow stops acking, unacked messages accumulate in the Pub/Sub subscription (retained **up to 7 days**), pipeline catches up when BQ returns. Effective ceiling ≈ a 7-day outage with zero loss. (Mnemonic: BQ time travel and Pub/Sub retention are both 7 days.)

## 7. Cost (rough monthly order-of-magnitude)

- **Pub/Sub ≈ $5.2k/mo** — 130 TB × ~$40/TB. **The dominant line item** → first place to optimize (batch/compress at the producer).
- **Cold storage — cumulative, no flat number.** ~0.5–0.9 TB/day into Coldline (~$0.004/GB-mo): ~$80/mo month 1, growing ~$80/mo, ~$1k/mo by end of year 1. Grows because we never delete.
- **BigQuery — bounded by design, not just "it depends."** Curated storage (~$0.02/GB-mo) capped via **partition expiration** (e.g., 90 days hot, older in cold); query cost (~$5/TB scanned) kept low by **partitioning + clustering** and serving the pre-aggregated `ip_scores` table so dashboards scan KBs, not TBs. Low hundreds to ~$1–2k/mo depending on dashboard load.
- **Dataflow ≈ $0.4–1.3k/mo** — 10–30 vCPUs at ~$0.06/vCPU-hr. Stays lean because dedup + scoring run as **BQ queries**, not in the stream job.
- **Total ≈ $7–9k/mo, ~⅔ Pub/Sub.** Know your dominant driver.

## 8. Tradeoffs & what I'd change at 10x (1M/sec, ~500 MB/s)

**Where it breaks first.** Pub/Sub is the most elastic piece (built for millions/sec) — not the first wall beyond raising a regional publish quota. The real first walls: **BQ write throughput** (per-table append/streaming limits → batch via load jobs or fan out write streams) and **Dataflow shuffle + keyed-state hot spots**. Scaling vCPUs ×10 is necessary but not sufficient; skew is the harder limit.

**Hot-key skew.** A *skew* problem, not a correctness one: keying aggregation by IP sends one dominant IP's entire volume to a single worker/partition, which melts while others idle. Fixes: **map-side combiners** (Beam `Combine` pre-aggregates locally, so a hot key ships one partial per worker, not millions of rows, to the final reducer) and **key salting** (aggregate on `ip + shard`, then merge partials — two-phase aggregation). _(Flagging "all traffic from one IP → raise an alert" is bot/anomaly detection — a useful product feature, but a different problem from the systems-level skew fix.)_

**Scoring: BQ recompute vs. streaming state at 10x.** Relaxed latency still avoids a hard real-time path, but full BQ recompute over 500 MB/s scans enormous partitions repeatedly — cost and runtime balloon. So shift from *recompute* to *incremental*: either MERGE only new partitions (stay in BQ, cheaper scans) or move running per-IP scores into **Dataflow keyed state backed by Bigtable** (high-throughput keyed store for large/lifetime state), emitting continuously. Tradeoff: streaming state = lower scan cost + fresher scores, but you own the state lifecycle and more ops; BQ recompute = simplest, but scan cost scales badly. **Bigtable** is the GCP service for the keyed-state/serving layer.

---

## Lessons & review notes

1. **Missing the front-door buffer** — went straight to GCS; 100k writes/sec needs Pub/Sub. Memorize: firehose ⇒ message bus first.
2. **Put the computed score in the dedup key** — category error. Identity keys ≠ computed values. Dedup on identity; make results idempotent with an upsert.
3. **"Hot key" means data skew, not anomaly detection.** The fix is combiners + salting (two-phase aggregation), not flagging suspicious IPs. Don't confuse a systems problem with a product feature.
4. **Name the dominant cost driver.** Pub/Sub was ~⅔ of the bill; and Pub/Sub is the *most* elastic component, so it's not the first thing to break at 10x — BQ writes + Dataflow shuffle are.
