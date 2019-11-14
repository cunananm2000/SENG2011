// Super simple print array
method printArray(a:array)
requires a != null
{
	var i := 0;
	while (i < a.Length)
	decreases a.Length - i
	{
		print a[i], " ";
		i := i + 1;
	}
	print '\n';
}

// Copies a given sequence into an array, at a given starting index low
method CopyIntoArray(s:seq<int>, a:array<int>, low:nat)
modifies a
requires a != null
requires |s| > 0
requires |s| <= a.Length - low;
ensures forall i :: 0<=i<|s| ==> (s[i] == a[i+low])
ensures old(a[..low]) == a[..low] && old(a[|s|+low..]) == a[|s|+low..]
{
	// Simple loop that seq into array
	var i := 0;
	while (i < |s|)
	decreases |s| - i
	invariant i <= |s|
	invariant forall j :: 0<=j<i ==> s[j] == a[low+j]
	invariant old(a[..low]) == a[..low] && old(a[|s|+low..]) == a[|s|+low..]
	{
		a[low+i] := s[i];
		i := i + 1;
	}
}

// Checks that sequence is ordered
predicate InOrder(a:seq<int>)
{
	forall i, j :: 0 <= i < j < |a| ==> a[i] <= a[j]
}

// Checks that every element in a are less than or equal to every element in b
predicate lessThanEqualSeq(a:seq<int>, b:seq<int>){
	forall i, j :: 0<=i<|a| && 0<=j<|b| ==> a[i] <= b[j]
}

// Sorts given array within indices low to high
// Open at low, closed at high
// method MergeSortArray(a:array<int>, low:nat, high:nat)
// decreases a, high - low
// modifies a
// requires a != null
// requires a.Length >= 0
// requires low<=high<=a.Length
// ensures multiset(old(a[low..high])) == multiset(a[low..high])
// ensures a[..low] == old(a[..low]) && a[high..] == old(a[high..])
// ensures multiset(a[..]) == multiset(old(a[..]))
// ensures InOrder(a[low..high])
// {
// 	var mid:nat := low + (high-low)/2;	// finding midpoint in subsection of array
// 	// If array is more than one value, sort
// 	if (a.Length > 1 && low < mid)
// 	{
// 		MergeSortArray(a, low, mid);	// Recursively sort left array
// 		assert old(a[mid..high]) == a[mid..high];

// 		MergeSortArray(a, mid, high);	// Recursively sort right array
// 		assert old(a[low..mid]+a[mid..high] == a[low..high]);
// 		assert a[low..mid]+a[mid..high] == a[low..high];	// Remind dafny something super obvious

// 		MergeSubarrays(a, low, mid, high);	// Merging left and right
// 	} // Else no need to sort array
// }

// Merges 2 adjacent sub arrays within an array
// low, mid and high are the indcies for these arrays
method MergeSubarrays(a:array<int>, low:nat, mid:nat, high:nat)
modifies a
requires a != null
requires low<mid<high<=a.Length
requires InOrder(a[low..mid]) && InOrder(a[mid..high])
ensures multiset(a[low..high]) == multiset(old(a[low..high]))
ensures InOrder(a[low..high])
ensures old(a[..low]) == a[..low] && old(a[high..]) == a[high..];
ensures multiset(a[..]) == multiset(old(a[..]))
{
	assert a[..low] == old(a[..low]);
	// Creating temp arrays for left and right
	var i, j := 0,0;
	var left, right := new int[mid-low], new int[high-mid];
	assert left.Length +  right.Length == high-low;
	while (i < mid-low)
	decreases mid-low -i
	invariant a[..] == old(a[..])
	invariant i <= mid-low
	invariant left[..i] == a[low..low+i]
	{
		left[i] := a[low+i];
		i := i + 1;
	}
	while (j < high-mid) 

	decreases high-mid -j
	invariant a[..] == old(a[..])
	invariant j <= high-mid
	invariant right[..j] == a[mid..mid+j]
	{
		right[j] := a[mid+j];
		j := j + 1;
	}
	assert a[..low] == old(a[..low]);

	assert InOrder(left[..]) && InOrder(right[..]);
	// Merge temp arrays back into a[low..high]
	i,j := 0,0;
	var k := low;
	assert mid-low == left.Length && high-mid == right.Length;
	while (i < left.Length && j < right.Length)
	decreases left.Length + right.Length - i - j
	invariant k <= a.Length && k >= low
	invariant i <= left.Length && j <= right.Length
	invariant InOrder(a[low..k]) && InOrder(left[i..]) && InOrder(right[j..])
	invariant a[..low] == old(a[..low])
	invariant multiset(a[low..k]) == multiset(left[..i] + right[..j])
	{
		if (left[i] <= right[j]){
			assert multiset(a[low..k]) == multiset(left[..i] + right[..j]);
			assert a[k] <= left[i];
			a[k] := left[i];
			k := k + 1;
			i := i + 1;
			assert multiset(a[low..k]) == multiset(left[..i] + right[..j]);
		} else {
			assert multiset(a[low..k]) == multiset(left[..i] + right[..j]);
			assert a[k] <= right[j];
			a[k] := right[j];
			k := k + 1;
			j := j + 1;
			assert multiset(a[low..k]) == multiset(left[..i] + right[..j]);
		}
		assert multiset(a[low..k]) == multiset(left[..i] + right[..j]);
	}


}