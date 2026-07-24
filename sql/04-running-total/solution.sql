-- Running Total for Different Genders  (LeetCode 1308, medium)
-- Pattern: cumulative sum with a windowed aggregate.
--
-- SCHEMA
--   Scores(player_name VARCHAR, gender VARCHAR, day DATE, score_points INT)
--
-- TASK: per gender, running total of score_points ordered by day.
-- Output: gender | day | total, ordered by gender then day.
--
-- APPROACH
--   Windowed SUM. PARTITION BY gender (real group → running total resets per
--   gender). ORDER BY day INSIDE the window makes the sum cumulative (default
--   frame = start of partition .. current row). Outer ORDER BY for result order.

SELECT gender, day,
       SUM(score_points) OVER (PARTITION BY gender ORDER BY day) AS total
FROM Scores
ORDER BY gender, day;
