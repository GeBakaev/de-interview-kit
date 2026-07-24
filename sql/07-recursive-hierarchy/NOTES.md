# Org Hierarchy Levels (recursive CTE) — notes

- **Pattern:** `WITH RECURSIVE` walking a parent/child hierarchy.
- **Result:** reasoned out the full logic solo (anchor, join direction, level). One implementation gap: didn't carry `id` through the CTE.

## Anatomy

- **Anchor member** — starting rows, runs once (the CEO: `manager_id IS NULL`, level 1).
- **Recursive member** — references the CTE itself; each pass builds the next level from the previous one. Stops when it returns no rows (no explicit loop).
- Joined by **`UNION ALL`**.

## The trap I hit: carry the join key

The CTE must select `id` in **both** members, because the recursive join needs `o.id` to match `e.manager_id`. Output columns (name, level) ≠ columns the recursion needs (id). Carry the key inside; drop it in the outer SELECT.

## Two correctness points

- **`UNION ALL`, not `UNION`** — UNION dedupes on every pass (wasteful; can hide rows).
- **Join direction:** `e.manager_id = o.id` (child's manager points up to a found row). Reversing it is the #1 recursive-CTE bug.

## Variants to know

- All subordinates under a given manager → anchor = that manager instead of the root.
- Full path string → carry `CONCAT(o.path, ' > ', e.name)` alongside level.
