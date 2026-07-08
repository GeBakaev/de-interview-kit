# de-interview-kit

A working log of data-engineering problems I solve to stay sharp — coding, SQL, system design, and behavioral prep — each with notes on approach, complexity, and tradeoffs. Public on purpose: "here's the pipeline I designed last week" beats "trust me, I know this."

**By [George Bakaev](https://bakaev.dev)** — senior data engineer (GCP & AWS).
[bakaev.dev](https://bakaev.dev) · [GitHub](https://github.com/gebakaev) · [LinkedIn](https://www.linkedin.com/in/gebakaev/)

## Start here

**[Real-time clickstream ingestion + IP scoring @ 100k events/sec »](system-design/market-data-100k-eps/DESIGN.md)** — a full system-design write-up: requirements, back-of-envelope, architecture, deep dives (dedup, idempotent scoring), reliability, cost (~$7–9k/mo), and what changes at 10×.

## Structure

```
coding/          one folder per problem: solution + notes
sql/             advanced SQL — window functions, CTEs, performance tuning
system-design/   design write-ups with architecture diagrams and cost numbers
behavioral/      STAR stories from production work
templates/       notes template for new entries
```

## How I work these

- Interview conditions: timed, plain editor, no autocomplete, no lookups.
- State the approach **before** writing code.
- Every entry gets notes: approach, complexity, what I'd do differently, follow-ups.
- Ship the scrappy version, refine later.

## Index

| Date       | Problem                                                                                    | Type          | Result                 |
| ---------- | ------------------------------------------------------------------------------------------ | ------------- | ---------------------- |
| 2026-07-06 | [Clickstream ingest + IP scoring @ 100k/sec](system-design/market-data-100k-eps/DESIGN.md) | system design | complete               |
| 2026-06-05 | [Top K Frequent Elements](coding/top-k-frequent-elements/)                                 | coding        | accepted, first submit |
