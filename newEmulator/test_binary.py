from algos import binarySearch

cmp = lambda a,b : a <= b

def test_simple():
	a = [1,2,3,4,5]
	r = binarySearch(a, 2, cmp)
	assert r == 1

def test_not_found():
	a = [1,2,3,4,5]
	r = binarySearch(a, 0, cmp)
	assert r == -1

def test_find_middle():
	a = [1,2,2,2,2,3]
	r = binarySearch(a, 2, cmp)
	assert r == 3