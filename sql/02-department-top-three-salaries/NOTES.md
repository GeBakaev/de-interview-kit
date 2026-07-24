# Department Top Three Salaries — notes

- **Pattern:** top-N per group (window ranking).
- **Result:** solved with coaching (rusty on CTE/window syntax; concept was solid). Retyped & **accepted on LeetCode, 21/21 (2026-07-23)**.

## Why DENSE_RANK

"Top three **distinct** salaries" is the tell:

- `ROW_NUMBER` — gives ties different numbers → would wrongly drop one of two equal salaries.
- `RANK` — skips numbers after a tie (1,1,3…) → a tie could push the 3rd distinct salary past rank 3.
- `DENSE_RANK` — ties share a rank, no gaps → exactly "top 3 distinct".

## Two things to remember

1. **One CTE, not two** — the join and the window function live in the same SELECT.
2. **Filter the rank in the outer query** — window functions are computed after WHERE, so `WHERE rnk <= 3` can't go in the CTE.

## At scale (the interviewer follow-up)

On a billion-row Employee table, the cost is the **sort inside each partition** (ORDER BY salary per department). Mitigations:

- Composite index / clustering on `(departmentId, salary DESC)` so the engine reads pre-sorted.
- If departments are few and huge, the window still scans everything — consider pre-aggregating the top-3 distinct salaries per department in a summary table refreshed on a schedule (same tiered-precompute idea as the IP-scores table in the system-design write-up).
