# sql

Advanced SQL for data-engineering interviews — window functions, recursive CTEs, gaps-and-islands, and performance. Each problem: solve on a judge (LeetCode DB / StrataScratch) under time, commit the query + a short note (approach, the pattern it drills, what I'd do at scale).

## The 10-problem set

**Window functions**
1. **Rank Scores** — `DENSE_RANK()` basics. (LeetCode 178)
2. **Department Top Three Salaries** — top-N per group: `DENSE_RANK() OVER (PARTITION BY …)`. (LeetCode 185, hard) ← _start here_
3. **Consecutive Numbers** — `LAG`/`LEAD` or 3-way self-join. (LeetCode 180)
4. **Running Total by group** — `SUM() OVER (PARTITION BY … ORDER BY …)`. (LeetCode 1308)

**Gaps-and-islands / sessionization**
5. **Human Traffic of Stadium** — the classic islands problem. (LeetCode 601, hard)
6. **Longest login streak per user** — consecutive-day islands with `ROW_NUMBER` date trick. (StrataScratch)

**Recursive CTEs**
7. **Employee management chain** — `WITH RECURSIVE` to walk a hierarchy + compute depth.
8. **Fill missing dates** — recursive date series (or `generate_series`) to find gaps in a daily table.

**Aggregation / reshaping**
9. **Reformat Department Table** — pivot via conditional aggregation. (LeetCode 1179)

**Performance**
10. **Optimize one of the above** — take #2 or #5 and write "how I'd make this fast on a billion-row table": partition pruning, clustering, avoiding a window over a full scan, pre-aggregation. Ties to real DE work.

## Progress

| # | Problem | Pattern | Result | Notes |
|---|---|---|---|---|
| 1 | [Rank Scores](01-rank-scores/) | window ranking (no filter) | ✅ accepted | no PARTITION when there's no group |
| 2 | [Department Top Three Salaries](02-department-top-three-salaries/) | window / top-N per group | ✅ accepted | DENSE_RANK, one-CTE, filter outside |
| 3 | [Consecutive Numbers](03-consecutive-numbers/) | neighbours (LAG / self-join) | ✅ accepted | LAG in CTE; `a=b=c` doesn't chain |
| 4 | [Running Total](04-running-total/) | cumulative windowed SUM | solved | ORDER BY inside window = running total |
| 7 | [Org Hierarchy Levels](07-recursive-hierarchy/) | recursive CTE | solved | carry the join key; UNION ALL |
