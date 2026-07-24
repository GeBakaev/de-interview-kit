# Consecutive Numbers — notes

- **Pattern:** compare a row to its neighbours.
- **Result:** solved with bugs — right idea (LAG vs previous two), three syntax fixes. Retyped & **accepted on LeetCode, 23/23 (2026-07-23)**.

## Bugs I made

1. **Put `LAG()` in `WHERE`.** Window functions run after WHERE → must compute in a CTE, filter outside. (Same trap as #2's rank filter — burn this in.)
2. **`a = b = c` doesn't chain in SQL.** It's `(a = b)` → boolean, then `boolean = c`. Use `num = prev1 AND num = prev2`.
3. **`LAG` needs `OVER (ORDER BY id)`** — incomplete without the window spec.

- Also missing `DISTINCT` and the output alias `ConsecutiveNums`.

## The one rule to remember

**Filtering on a window function → CTE + outer WHERE.** This is the single most common SQL interview trap. Bitten me twice (rank, LAG).

## LAG vs self-join (the senior nuance)

- `LAG` is **positional** — previous _row_. Treats adjacent rows as consecutive even if ids jump (3 → 7).
- Self-join on `id+1`/`id+2` enforces **exact id-adjacency**.
- LeetCode 180 has contiguous ids so both pass; knowing the difference is the interview point.
