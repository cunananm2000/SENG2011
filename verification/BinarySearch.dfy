// Proof of binary search
// Proof with comparator without equivalence, less than
// Proof with comparator with equivalence, less than or equals
// Uses same algo for both, but comparators are hard coded in 
//(since I don't know how to do higher level order functions)
// by Mark Estoque (tell me when you find the really obvious thing I overlooked)

// Checks that sequence is ordered
predicate InOrder(a:seq<int>)
{
	forall i, j :: 0 <= i < j < |a| ==> a[i] <= a[j]
}

// XAND over less than comparator
method xandLT(a:int, b:int) returns (r:bool)
ensures a == b ==> r == true
ensures a != b ==> r == false
{
	r := ((a<b) && (b<a)) || (!(a<b) && !(b<a));
}

// Binary Search for less than comparator
method BinarySearchLT(a:array<int>, key:int) returns (r:int)
requires a != null
requires InOrder(a[..])
ensures if exists i:nat :: i<a.Length && a[i] == key
	then 0<=r<a.Length && a[r] == key else r == -1
{
	var low, high := 0, a.Length;	// Setting range
	// Keep on looking while there are items within bounds
	while (low < high)
	decreases high-low
	invariant 0<=low<=high<=a.Length
	invariant key !in a[..low] && key !in a[high..]
	{
		// Finding midpoint 
		var mid := (low+high)/2;
		var x := xandLT(key, a[mid]);	// Using xand to tell if key is found
		if (x){							
			assert key == a[mid];
			r := mid;
			return;
		} 
		else if (key < a[mid]){		// Key must be in lower half
			high := mid;
		} else if (key > a[mid]){	// Key must be in upper half
			low := mid + 1;
		} 
	}
	r := -1;	// Couldn't find key
}

// XAND over less or equal than comparator
method xandLTE(a:int, b:int) returns (r:bool)
ensures a == b ==> r == true
ensures a != b ==> r == false
{
	r := ((a<=b) && (b<=a)) || (!(a<=b) && !(b<=a));
}

// Binary Search for less or equal than comparator
method BinarySearchLTE(a:array<int>, key:int) returns (r:int)
requires a != null
requires InOrder(a[..])
ensures if exists i:nat :: i<a.Length && a[i] == key
	then 0<=r<a.Length && a[r] == key else r == -1
{
	var low, high := 0, a.Length;	// Setting range
	// Keep on looking while there are items within bounds
	while (low < high)
	decreases high-low
	invariant 0<=low<=high<=a.Length
	invariant key !in a[..low] && key !in a[high..]
	{
		// Finding midpoint 
		var mid := (low+high)/2;
		var x := xandLTE(key, a[mid]);	// Using xand to tell if key is found
		if (x){
			assert key == a[mid];
			r := mid;
			return;
		} 
		else if (key <= a[mid]){	// Key must be in lower half
			high := mid;
		} else if (key >= a[mid]){	// Key must be in upper half
			low := mid + 1;
		} 
	}
	r := -1;	// Couldn't find key
}