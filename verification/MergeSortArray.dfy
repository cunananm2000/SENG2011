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
// All elements in bounds are preserver
ensures multiset(a[low..high]) == multiset(old(a[low..high]))
// All elements in bounds are in order
ensures InOrder(a[low..high])
{
	assert a[..low] == old(a[..low]);
	// Creating temp arrays for left and right
	var i, j := 0,0;
	// ghost seqs for left, right arrays and final merged part
	ghost var l, r, m:seq<int> := a[low..mid], a[mid..high], [];
	// ghost var old_l, old_r := a[low..mid], a[mid..high];
	assert l+r+m == old(a[low..high]);
	var left, right := new int[mid-low], new int[high-mid];

	while (i < mid-low)
	decreases mid-low -i
	invariant a[..] == old(a[..])
	invariant i <= mid-low
	invariant left[..i] == a[low..low+i]
	{
		left[i] := a[low+i];
		i := i + 1;
	}
	assert left[..] == l;

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
	assert right[..] == r;

	assert a[..low] == old(a[..low]);

	// assert InOrder(left[..]) && InOrder(right[..]);
	// Merge temp arrays back into a[low..high]
	// Proof strategy: prove that algo works for ghost seqs 
	// Then prove that seqs == arrays
	
	i,j := 0,0;
	var k := low;
	assert multiset(l+r+m) == multiset(old(a[low..high]));

	ghost var old_a := multiset(l+r+m);

	while (i < left.Length || j < right.Length)
	decreases left.Length + right.Length - i - j
	invariant k <= high && k >= low
	invariant i <= left.Length && j <= right.Length
	invariant k-low == i + j
	// invariant InOrder(a[low..k]) && InOrder(left[i..]) && InOrder(right[j..])
	invariant a[..low] == old(a[..low]) && a[high..] == old(a[high..])
	// invariant multiset(a[low..k]) == multiset(left[..i] + right[..j])
	invariant InOrder(l) && InOrder(r) && InOrder(m)
	invariant lessThanEqualSeq(m,l) && lessThanEqualSeq(m,r)
	invariant multiset(l+r+m) == old_a
	//invariant |m+r+l| == |old_a|
	invariant left[i..] == l && right[j..] == r && a[low..k] == m
	{
		//ghost var n : int; // Holds value to 'append' to m
		// When neither 'queue' is empty, find lowest value and add to array
		if (i < left.Length && j < right.Length){
			if (left[i] <= right[j]){
				ghost var old_l, old_m, n := l, m, l[0];
			
				m := m + [l[0]];
				l := l[1..];
				
				assert old_m+[n] == m;
				assert [n]+l == old_l;
				assert multiset(old_m+old_l) == multiset(m+l);
				assert multiset(l+r+m) == old_a;

				a[k] := left[i];
				i := i + 1;
			} else {
				ghost var old_r, old_m, n := r, m, r[0];
				
				m := m + [r[0]];
				r := r[1..];
				
				assert old_m+[n] == m;
				assert [n]+r == old_r;
				assert multiset(old_m+old_r) == multiset(m+r);
				assert multiset(l+r+m) == old_a;

				a[k] := right[j];
				j := j + 1;
			}
		// If right is empty, add from left
		} else if (i < left.Length){
			ghost var old_l, old_m, n := l, m, l[0];
			m := m + [l[0]];
			l := l[1..];
			assert old_m+[n] == m;
			assert [n]+l == old_l;
			assert multiset(old_m+old_l) == multiset(m+l);
			assert multiset(l+r+m) == old_a;

			a[k] := left[i];
			i := i + 1;
		// Else if left is emtpy, add from right
		} else {
			ghost var old_r, old_m, n := r, m, r[0];
			m := m + [r[0]];
			r := r[1..];
			assert old_m+[n] == m;
			assert [n]+r == old_r;
			assert multiset(old_m+old_r) == multiset(m+r);
			assert multiset(l+r+m) == old_a;
			a[k] := right[j];
			j := j + 1;
		}
		k := k + 1;
	}
}

// Only used for ghost sequences, removes first element is seq
function PopSeq(s:seq<int>) : seq<int>
requires |s| > 0
{
	if (|s| > 1) then s[1..]
	else []
}