# Running Total — notes

- **Pattern:** cumulative sum via windowed aggregate.
- **Result:** approach nailed (partition + in-window order); completed as reference. Retype & submit on LeetCode to lock in.

## The one idea to keep

**`ORDER BY` inside the window makes a sum cumulative.**

- `SUM(x) OVER (PARTITION BY g)` → grand total per group (same value on every row).
- `SUM(x) OVER (PARTITION BY g ORDER BY d)` → running total (default frame = partition start … current row).

## Contrast with #1 (Rank Scores)

`PARTITION BY` is **correct here** because gender is a real group. In #1 there was no group, so adding a partition was the bug. Rule: partition only when a genuine group exists.

## Also

- Window `ORDER BY` assigns the frame; add an outer `ORDER BY gender, day` for the required result ordering.
