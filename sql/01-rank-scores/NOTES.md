# Rank Scores — notes

- **Pattern:** plain window ranking (no filter, no group).
- **Result:** solved with one bug (added a `PARTITION BY` that shouldn't be there). Retyped & **accepted on LeetCode, 11/11 (2026-07-23)**.

## The bug: PARTITION BY out of habit

Carried `PARTITION BY id` over from #2. `id` is the primary key → every row is its own partition → every score ranks 1. **No group here, so no PARTITION.**

**Rule:** `PARTITION BY` = "rank within each group." Only use it when a group exists (#2 had departments). Global ranking → omit it.

## Also

- Window `ORDER BY` assigns the ranks; it does NOT sort the result set. Need an explicit outer `ORDER BY score DESC` for the required output order.
- `rank` is a reserved word → quote the alias `AS "rank"`.
