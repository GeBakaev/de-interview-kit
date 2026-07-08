"""
Top K Frequent Elements (LeetCode 347, medium)
https://leetcode.com/problems/top-k-frequent-elements/

Result: Accepted first submit, 23/23, 15m47s (2026-06-05).

APPROACH (as solved): hash map to count frequencies in O(n), sort the
(num, count) pairs by count descending, slice the first k, return the nums.
time:  O(n + m log m), m = unique elements -> O(n log n) worst case
space: O(m)

FOLLOW-UP (not yet done): O(n log k) with a size-k min-heap. See NOTES.md.
"""

from collections import Counter
from typing import List


# --- As submitted (accepted) ---
class Solution:
    def topKFrequent(self, nums: List[int], k: int) -> List[int]:
        number_dict = {}
        for i in nums:
            try:
                number_dict[i] += 1
            except:
                number_dict[i] = 1
        number_list_sorted = sorted(number_dict.items(), key=lambda item: item[1], reverse=True)
        only_k_top = []
        for items in number_list_sorted[:k]:
            only_k_top.append(items[0])
        return only_k_top


# --- Cleaned version of the same approach (post-review) ---
def top_k_frequent(nums: List[int], k: int) -> List[int]:
    counts = Counter(nums)
    ranked = sorted(counts.items(), key=lambda p: p[1], reverse=True)
    return [num for num, _ in ranked[:k]]


if __name__ == "__main__":
    for impl in (Solution().topKFrequent, top_k_frequent):
        assert sorted(impl([1, 1, 1, 2, 2, 3], 2)) == [1, 2]
        assert impl([1], 1) == [1]
        assert sorted(impl([1, 2, 1, 2, 1, 2, 3, 1, 3, 2], 2)) == [1, 2]
        assert sorted(impl([4, 1, -1, 2, -1, 2, 3], 2)) == [-1, 2]
    print("ok")
