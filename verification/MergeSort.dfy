// MergeSort proven in Dafny 1.9.7 by Mark E
// Initially uses sequences since I don't want to deal with arrays being null 
// And how its a pain to set them syntactically

// Checks that sequence is ordered
predicate InOrder(a:seq<int>)
{
	forall i, j :: 0 <= i < j < |a| ==> a[i] <= a[j]
}

// Checks that every element in a are less than or equal to every element in b
predicate lessThanEqualSeq(a:seq<int>, b:seq<int>){
	forall i, j :: 0<=i<|a| && 0<=j<|b| ==> a[i] <= b[j]
}

// Recursive merge sort on a sequence
method MergeSort(s:seq<int>) returns (m:seq<int>)
decreases s
ensures multiset(s) == multiset(m)
ensures InOrder(m)
{
	// When s is more than one value, sort
	if (|s| > 1){
		// Split m into l and r, l can be slightly less than r
		var mid := |s|/2;
		var l, r := s[..mid], s[mid..];
		assert l + r == s;
		// Sort each half then merge them
		l := MergeSort(s[..mid]);
		r := MergeSort(s[mid..]);
		m := Merge(l, r);
		assert multiset(l+r) == multiset(m);
	} else {
		m := s;
	}
}

// Deals with sequences so no need to mess with memory
method Merge(left:seq<int>, right:seq<int>) returns (m:seq<int>)
requires InOrder(left) && InOrder(right)
ensures multiset(left + right) == multiset(m)
ensures InOrder(m)
ensures |left| + |right| == |m|
{
	// l and r act as queue versions of left and right, with PopSeq method used to 'edit' them
	var l, r := left, right;
	m := [];

	// Loop appends to m whichever value is lowest in the 'queues'
	while (|l| > 0 || |r| > 0)
	decreases |l| + |r|
	invariant InOrder(l) && InOrder(r) && InOrder(m)
	invariant lessThanEqualSeq(m,l) && lessThanEqualSeq(m,r)
	invariant multiset(m+r+l) == multiset(left+right)
	invariant |m+r+l| == |left+right|
	{
		var n : int;	// Holds new value to 'append' to m
		// When neither queue is empty, find the lowest value and pop into m
		if (|l| > 0 && |r| > 0){
			if (l[0] <= r[0]){
				l, n := PopSeq(l);
				m := m + [n];
			} else {
				r, n := PopSeq(r);
				m := m + [n];
			}
		// If r is empty, pop from l
		} else if (|l| > 0){
			l, n := PopSeq(l);
			m := m + [n];
		// If l is empty, pop from r
		} else {
			r, n := PopSeq(r);
			m := m + [n];
		}
	}
}

// Pops the first value of seq s, returns new seq as r and item popped as i
method PopSeq(s:seq<int>) returns (r:seq<int>, i:int)
requires |s| > 0
ensures r == s[1..]
ensures s == [i] + r
{
	// Getting first value
	i := s[0];
	// 'Chopping' front of s
	if (|s| > 1){
		r := s[1..];
	} else {
		r := [];
	}
}

method MergeSubarrays(a:array<int>, low:nat, mid:nat, high:nat)
modifies a
requires a != null
requires low<mid<high<a.Length
requires InOrder(a[low..mid]) && InOrder(a[mid..high])
ensures multiset(a[low..high]) == multiset(old(a[low..high]))
ensures InOrder(a[low..high])
ensures old(a[..low]) == a[..low] && old(a[high..]) == a[high..];
ensures multiset(a[..]) == multiset(old(a[..]))
{
	assert multiset(a[..]) == multiset(old(a[..]));
	assert old(a[..low]) == a[..low] && old(a[high..] ==a[high..]);

	var m := Merge(a[low..mid], a[mid..high]);

	assert a[low..mid]+a[mid..high] == a[low..high]; 
	assert multiset(a[low..mid] + a[mid..high]) == multiset(m);
	assert |m| == high-low;
	assert InOrder(m) && |m| < a.Length;

	var high : nat := |m|+low;
	assert multiset(a[..]) == multiset(old(a[..]));
	CopyIntoArray(m, a, low);
	assert multiset(a[..low]) == multiset(old(a[..low]));
	assert multiset(a[high..]) == multiset(old(a[high..]));
	assert multiset(m) == multiset(old(a[low..high]));
	assert m == a[low..high];
	assert multiset(a[low..high]) == multiset(old(a[low..high]));
	// assert multiset(a[..low]) + multiset(a[low..high]) + multiset(a[high..])
		// == multiset(old(a[..low])) + multiset(old(a[low..high])) + multiset(old(a[high..]));
	assert multiset(a[..low] + a[low..high] + a[high..]) 
		== multiset(old(a[..low] + a[low..high] + a[high..]));
	assert a[..] == a[..low]+a[low..high]+a[high..];
	assert multiset(a[..]) == multiset(a[..low] + a[low..high] + a[high..]);
	assert old(a[..] == a[..low]+a[low..high]+a[high..]);
	assert old(multiset(a[..]) == multiset(a[..low] + a[low..high] + a[high..]));
	assert multiset(a[..]) == multiset(old(a[..]));

	assert old(a[..low]) == a[..low] && old(a[high..] ==a[high..]);
	assert m[..] == a[low..high];
	assert multiset(a[low..high]) == multiset(m);
	assert InOrder(a[low..high]);
}

// Sorts given array within indices low to high
// Open at low, closed at high
method MergeSortArray(a:array<int>, low:nat, high:nat)
decreases a, high - low
modifies a
requires a != null
requires a.Length > 0
requires low<high<a.Length
ensures multiset(old(a[low..high])) == multiset(a[low..high])
ensures a[..low] == old(a[..low]) && a[high..] == old(a[high..])
ensures multiset(a[..]) == multiset(old(a[..]))
ensures InOrder(a[low..high])
{
	assert a[..low] == old(a[..low]) && a[high..] == old(a[high..]);
	var mid:nat := low + (high-low)/2;	// finding midpoint in subsection of array
	// If array is more than one value, sort
	if (a.Length > 1 && low < mid){
		assert multiset(old(a[mid..])) == multiset(a[mid..]);

		MergeSortArray(a, low, mid);
		
		assert old(a[..low]) == a[..low] && old(a[high..] == a[high..]);
		assert multiset(old(a[low..mid])) == multiset(a[low..mid]);
		assert old(a[mid..high]) == a[mid..high];
		assert multiset(old(a[..])) == multiset(a[..]);
		// assert InOrder(a[low..mid]);
		// assert old(a[mid..high]) == a[mid..high];
		// assert multiset(old(a[mid..high])) == multiset(a[mid..high]);
		assert multiset(old(a[mid..high])) == multiset(a[mid..high]);

		MergeSortArray(a, mid, high);

		assert multiset(old(a[mid..high])) == multiset(a[mid..high]);
		assert multiset(old(a[low..mid])) == multiset(a[low..mid]);
		assert a[low..mid]+a[mid..high] == a[low..high];
		assert old(a[low..mid]+a[mid..high] == a[low..high]);
		assert multiset(old(a[low..high])) == multiset(a[low..high]);
		assert old(a[..low]) == a[..low] && old(a[high..]) == a[high..];
		// assert multiset(old(a[..])) == multiset(a[..]);
		// assert old(a[..low]) == a[..low] && old(a[high..] == a[high..]);
		// assert InOrder(a[mid..high]);

		// assert multiset(old(a[low..mid])) == multiset(a[low..mid]);
		// assert multiset(old(a[mid..high])) == multiset(a[mid..high]);
		assert multiset(old(a[..])) == multiset(a[..]);
		// assert multiset(old(a[low..mid])) + multiset(old(a[mid..high])) 
		// 	== multiset(a[low..mid]) + multiset(a[mid..high]);

		// assert forall i:nat :: 0<=i<a.Length ==> a[..i] + a[i..] == a[..];
		// assert forall i:nat :: low<=i<high<a.Length ==> a[low..i] + a[i..high] == a[low..high];
		// assert forall i:nat :: 0<=i<a.Length ==> multiset(a[..i])+multiset(a[i..]) == multiset(a[..]);


		// assert multiset(a[low..mid])+ multiset(a[mid..high]) == multiset(a[low..high]);
		//assert multiset(old(a[low..mid]+a[mid..high])) == multiset(old(a[low..high]));
		// assert multiset(old(a[low..high])) == multiset(a[low..high]);

		//assert multiset(old(a[low..high])) == multiset(old(a[low..mid])+old(a[mid..high]));
		MergeSubarrays(a, low, mid, high);
		assert multiset(old(a[low..high])) == multiset(a[low..high]);
		assert old(a[..low]) == a[..low] && old(a[high..]) == a[high..];
		assert multiset(old(a[..])) == multiset(a[..]); 
		// assert old(a[..low]) == a[..low] && old(a[high..] == a[high..]);
		//assert multiset(old(a[low..mid] + a[mid..high])) == multiset(a[low..mid] + a[mid..high]);
	}
	assert old(a[high..]) == a[high..];
	assert a[..low] == old(a[..low]) && a[high..] == old(a[high..]);
	// Else no need to sort array
}

method CopyIntoArray(s:seq<int>, a:array<int>, low:nat)
modifies a
requires |s| > 0
requires |s| <= a.Length - low;
ensures forall i :: 0<=i<|s| ==> (s[i] == a[i+low])
ensures old(a[..low]) == a[..low] && old(a[|s|+low..]) == a[|s|+low..]
{
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


// Real simple tests
method Main(){
	var a := [9, 4, 6, 3, 8];
    var r := MergeSort(a);
	// assert (r == [3,4,6,8,9]);
	print r, '\n';

    var b := [];
    r := MergeSort(b[..]);
	// assert (r == []);
	print r, '\n';

	var c := [1,2,3,4,5];
	r := MergeSort(c);
	// assert (r == c);
	print r, '\n';
}