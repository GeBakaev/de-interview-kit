-- Consecutive Numbers  (LeetCode 180, medium)
-- Pattern: compare a row to its neighbours (LAG/LEAD, or self-join).
--
-- SCHEMA
--   Logs(id INT primary key, num VARCHAR)   -- id is sequential: 1,2,3,...
--
-- TASK: numbers that appear at least THREE times in a row (by id).
-- Output column: ConsecutiveNums.
--
-- APPROACH
--   LAG to look at the previous two rows; keep rows where the current num equals
--   both. LAG can't go in WHERE (window fns run after WHERE) -> compute in a CTE,
--   filter outside. DISTINCT because a long run yields multiple qualifying rows.

WITH cte AS (
    SELECT num,
           LAG(num, 1) OVER (ORDER BY id) AS prev1,
           LAG(num, 2) OVER (ORDER BY id) AS prev2
    FROM Logs
)
SELECT DISTINCT num AS ConsecutiveNums
FROM cte
WHERE num = prev1 AND num = prev2;

-- Self-join alternative (enforces exact id-adjacency):
-- SELECT DISTINCT l1.num AS ConsecutiveNums
-- FROM Logs l1
-- JOIN Logs l2 ON l2.id = l1.id + 1 AND l2.num = l1.num
-- JOIN Logs l3 ON l3.id = l1.id + 2 AND l3.num = l1.num;
