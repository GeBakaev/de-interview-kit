-- Org Hierarchy Levels  (recursive CTE)
-- Pattern: WITH RECURSIVE to walk a parent/child hierarchy.
--
-- SCHEMA
--   Employees(id INT primary key, name VARCHAR, manager_id INT)  -- CEO: manager_id IS NULL
--
-- TASK: every employee's name + LEVEL (CEO = 1, reports = 2, ...). Order by level, name.
--
-- APPROACH
--   Anchor = root (manager_id IS NULL) at level 1. Recursive member joins each
--   employee to the row already found via e.manager_id = o.id, level = parent + 1.
--   Carry `id` through the CTE (it's the join key) even though the final output
--   is just name + level. UNION ALL (not UNION).

WITH RECURSIVE org AS (
    SELECT id, name, 1 AS level
    FROM Employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.id, e.name, o.level + 1
    FROM Employees e
    JOIN org o ON e.manager_id = o.id
)
SELECT name, level
FROM org
ORDER BY level, name;
