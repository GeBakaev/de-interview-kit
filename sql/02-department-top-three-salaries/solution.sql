-- Department Top Three Salaries  (LeetCode 185, hard)
-- Pattern: top-N per group with a window ranking function.
--
-- SCHEMA
--   Employee(id INT, name VARCHAR, salary INT, departmentId INT)
--   Department(id INT, name VARCHAR)
--
-- TASK: employees earning among the top THREE DISTINCT salaries within their
-- department. Output: Department | Employee | Salary.
--
-- APPROACH
--   DENSE_RANK() over each department, ordered by salary DESC, then keep rank <= 3.
--   DENSE_RANK (not RANK/ROW_NUMBER) because "top 3 DISTINCT salaries": ties must
--   share a rank AND must not consume extra slots. Join + window in one CTE;
--   filter the rank in the outer query (window fns can't be used in WHERE).

WITH ranked AS (
    SELECT
        d.name   AS Department,
        e.name   AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS rnk
    FROM Employee e
    JOIN Department d ON e.departmentId = d.id
)
SELECT Department, Employee, Salary
FROM ranked
WHERE rnk <= 3;
