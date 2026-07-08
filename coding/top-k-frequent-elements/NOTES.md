# Top K Frequent Elements — notes

- **Date:** 2026-06-05
- **Time taken:** 15m 47s (budget 40m)
- **Result:** solved clean — accepted first submit, 23/23

## Approach I stated before coding

Didn't formally state it first — habit to fix next problem. De facto approach:
hash-map count → sort pairs by count desc → slice first k.

## Final complexity

- Time: O(n + m log m), m = unique elements → O(n log n) worst case
- Space: O(m)

## What I missed / got wrong first (review feedback)

- **Bare `except:`** for the counting — catches everything, production red flag.
  Use `dict.get(i, 0) + 1`, `defaultdict(int)`, or `Counter`.
- Left a debug `print()` in the submitted code.
- Naming: `i` for a value, `items` for a single pair.
- Final loop collapses to a comprehension: `[num for num, _ in ranked[:k]]`.

## The alternative(s)

- `Counter(nums).most_common(k)` — one line; worth naming in an interview,
  expect "now without most_common."
- **Min-heap of size k → O(n log k)** — the standard follow-up. NOT DONE YET.
- **Bucket sort by count → O(n)** — counts bounded by len(nums); place, don't compare.

## Follow-ups to be ready for

- [ ] Implement the size-k min-heap version (O(n log k))
- [ ] Bucket-sort version (O(n))
- Stream that doesn't fit in memory → heavy-hitters territory (Count-Min Sketch,
  Misra-Gries); tie answer back to Fintent-scale pipelines.
- Distributed top-K across N workers → local top-K per worker, merge candidate
  sets, beware the cross-partition undercount.
