-- Rank Scores  (LeetCode 178, medium)
-- Pattern: plain window ranking, no filter.
--
-- SCHEMA
--   Scores(id INT primary key, score DECIMAL(3,2))
--
-- TASK: rank scores highest-first; ties share a rank with NO gap (1,1,2).
-- Order output by score descending. Output: score | rank.
--
-- APPROACH
--   DENSE_RANK over ALL rows ordered by score DESC (no PARTITION — there's no
--   group here). Add an outer ORDER BY for the required result ordering.

SELECT score,
       DENSE_RANK() OVER (ORDER BY score DESC) AS "rank"
FROM Scores
ORDER BY score DESC;
