// Checks that sequence is ordered
predicate InOrder(a:seq<int>)
{
	forall i, j :: 0 <= i < j < |a| ==> a[i] <= a[j]
}

// Checks that every element in a are less than or equal to every element in b
predicate lessThanEqualSeq(a:seq<int>, b:seq<int>){
	forall i, j :: 0<=i<|a| && 0<=j<|b| ==> a[i] <= b[j]
}

// Merges 2 adjacent sub arrays within an array
// low, mid and high are the indcies for these arrays
// Takes years to verify but hey it does
method MergeSubarrays(a:array<int>, low:nat, mid:nat, high:nat)
modifies a
requires a != null
requires low<mid<high<=a.Length
requires InOrder(a[low..mid]) && InOrder(a[mid..high])
// ensures array segments out of bounds aren't changed
ensures old(a[..low]) == a[..low] && old(a[high..]) == a[high..];
// All elements in bounds are preserved
ensures multiset(a[low..high]) == multiset(old(a[low..high]))
// All elements in bounds are in order
ensures InOrder(a[low..high])
{
	// Creating temp arrays for left and right
	var i, j := 0,0;
	// ghost seqs for left, right arrays and final merged part
	ghost var l, r, m:seq<int> := a[low..mid], a[mid..high], [];
	ghost var old_a := a[low..high];
	assert l+r+m == old_a;
	assert multiset(l+r+m) == multiset(old_a);
	
	var left, right := new int[mid-low], new int[high-mid];
	// Copying temp array for left
	while (i < mid-low)
	decreases mid-low -i
	invariant a[..] == old(a[..])
	invariant i <= mid-low
	invariant left[..i] == a[low..low+i]
	{
		left[i] := a[low+i];
		i := i + 1;
	}
	// Copying temp array for right
	while (j < high-mid) 
	decreases high-mid -j
	invariant a[..] == old(a[..])
	invariant j <= high-mid
	invariant left[..] == l;
	invariant right[..j] == a[mid..mid+j]
	{
		right[j] := a[mid+j];
		j := j + 1;
	}

	assert multiset(l+r+m) == multiset(old_a);

	// assert InOrder(left[..]) && InOrder(right[..]);
	// Merge temp arrays back into a[low..high]
	// Proof strategy: prove that algo works for ghost seqs 
	// Then prove that seqs == arrays
	
	i,j := 0,0;
	var k := low;

	while (i < left.Length || j < right.Length)
	decreases left.Length + right.Length - i - j
	invariant low <= k <= high
	invariant i <= left.Length && j <= right.Length
	invariant k-low == i + j
	invariant a[..low] == old(a[..low]) && a[high..] == old(a[high..])
	invariant InOrder(l) && InOrder(r) && InOrder(m)
	invariant lessThanEqualSeq(m,l) && lessThanEqualSeq(m,r)
	invariant multiset(l+r+m) == multiset(old_a)
	invariant left[i..] == l && right[j..] == r && a[low..k] == m
	{
		// When neither 'queue' is empty, find lowest value and add to array
		if (i < left.Length && j < right.Length){
			if (left[i] <= right[j]){
				// Ghost part
				ghost var old_l := l;
				ghost var n := [l[0]];
				m := m + n;
				l := l[1..];
				assert old_l == n + l;
				// Actual implementation part
				a[k] := left[i];
				i := i + 1;
			} else {
				// Ghosts
				ghost var old_r := r;
				ghost var n := [r[0]];
				m := m + n;
				r := r[1..];
				assert old_r == n + r;
				//Implementation
				a[k] := right[j];
				j := j + 1;
			}
		// If right is empty, add from left
		} else if (i < left.Length){
			// Ghost
			ghost var old_l := l;
			ghost var n := [l[0]];
			m := m + n;
			l := l[1..];
			assert old_l == n + l;
			//Implementation
			a[k] := left[i];
			i := i + 1;
		// Else if left is emtpy, add from right
		} else {
			// Ghost
			ghost var old_r := r;
			ghost var n := [r[0]];
			m := m + n;
			r := r[1..];
			assert old_r == n + r;
			// Implementation
			a[k] := right[j];
			j := j + 1;
		}
		k := k + 1;
	}
	assert k == high;
}

//Sorts given array within indices low to high
//Open at low, closed at high
// Takes 12 min rip in dafny 1.9.7
method MergeSortArray(a:array<int>, low:nat, high:nat)
decreases a, high - low
modifies a
requires a != null
requires a.Length >= 0
requires low<=high<=a.Length
ensures multiset(old(a[low..high])) == multiset(a[low..high])
ensures a[..low] == old(a[..low]) && a[high..] == old(a[high..])
ensures multiset(a[..]) == multiset(old(a[..]))
ensures InOrder(a[low..high])
{
	var mid:nat := low + (high-low)/2;	// finding midpoint in subsection of array
	// If array is more than one value, sort
	if (a.Length > 1 && low < mid)
	{
		MergeSortArray(a, low, mid);	// Recursively sort left array
		assert old(a[mid..high]) == a[mid..high];
		assert multiset(a[low..mid]) == multiset(old(a[low..mid]));
		assert multiset(old(a[..])) == multiset(a[..]);

		MergeSortArray(a, mid, high);	// Recursively sort right array
		assert old(a[low..mid]+a[mid..high] == a[low..high]);
		assert a[low..mid]+a[mid..high] == a[low..high];	// Remind dafny something super obvious
		assert multiset(old(a[..])) == multiset(a[..]);

		MergeSubarrays(a, low, mid, high);	// Merging left and right

		assert a[..low]+a[low..high]+a[high..] == a[..];
		assert old(a[..low]+a[low..high]+a[high..]) == old(a[..]);
		// assert multiset(a[..]) == multiset(old(a[..]));
	} // Else no need to sort array
}

// Commented out so that verification will take less than 2 min
method Main(){
	var d := new int[5];
	d[0], d[1], d[2], d[3], d[4] := 9, 4, 6, 3, 8;
	assert d[0]==9 && d[1]==4 && d[2]==6 && d[3]==3 && d[4]==8;
	MergeSortArray(d, 0, 5);
	assert InOrder(d[0..5]);

	var e := new int[0];
	MergeSortArray(e, 0, 0);
	assert InOrder(e[..]);

	var f := new int[5];
	f[0], f[1], f[2], f[3], f[4] := 1, 2, 3, 4, 5;
	MergeSortArray(f, 0, f.Length);
	assert InOrder(f[..]);
}