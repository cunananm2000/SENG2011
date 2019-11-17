from algos import mergeSorted, mergeSort, _mergeSortArray, _mergeSubarrays

cmp = lambda a,b : a <= b

def test_sorted_simple():
	a = [2,3,1,4,5]
	r = mergeSorted(a, cmp)
	assert r == [1,2,3,4,5]

def test_sorted_preordered():
	a = [1,2,3,4,5]
	r = mergeSorted(a, cmp)
	assert r == a

def test_array_simple():
	a = [2,3,1,4,5]
	_mergeSortArray(a, 0, 5, cmp)
	assert a == [1,2,3,4,5]

def test_sort_simple():
	a = [2,3,1,4,5]
	mergeSort(a, cmp)
	assert a == [1,2,3,4,5]

def test_sort_preordered():
	a = [1,2,3,4,5]
	mergeSort(a, cmp)
	assert a == [1,2,3,4,5]

def test_subarrays_simple():
	a = [3,4,1,2]
	_mergeSubarrays(a, 0, 2, 4, cmp)
	assert a == [1,2,3,4]