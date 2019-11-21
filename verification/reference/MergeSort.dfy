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


// Real simple tests
method Main(){
	// Testing with sequences
	var a := [9, 4, 6, 3, 8];
	var r := MergeSort(a);
	assert (r == [3,4,6,8,9]);
	print r, '\n';

	var b := [];
	r := MergeSort(b[..]);
	assert (r == []);
	print r, '\n';

	var c := [1,2,3,4,5];
	r := MergeSort(c);
	assert (r == c);
	print r, '\n';

	// var d := new int[5];
	// d[0], d[1], d[2], d[3], d[4] := 9, 4, 6, 3, 8;
	// assert d[0]==9 && d[1]==4 && d[2]==6 && d[3]==3 && d[4]==8;
	// MergeSortArray(d, 0, 5);
	// printArray(d);
	// // NOTE: below asserts commented out as they change verification time from 5 sec to 30 sec
	// //assert InOrder(d[0..5]);

	// var e := new int[0];
	// MergeSortArray(e, 0, 0);
	// //assert InOrder(e[..]);

	// var f := new int[5];
	// CopyIntoArray(c, f, 0);
	// MergeSortArray(f, 0, f.Length);
	// printArray(f);
	//assert InOrder(f[..]);
}