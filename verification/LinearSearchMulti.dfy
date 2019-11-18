// Checks if key is in array
predicate InsideArray(a:array<int>, key:int)
requires a != null
reads a 
{	
	exists i:nat :: i<a.Length && a[i] == key
}

predicate InsideUpTo(a:array<int>, key:int, high:nat)
requires a != null
requires high <= a.Length
reads a
{
	exists i:nat :: i<high && a[i] == key
}

// Returns number of matches of key in sequence
// Uses recursion since ghosts can't use loops
function Matches(s:seq<int>, key:int) : nat
decreases s 
{
	if (|s| == 0) then 0
	else if (s[0] == key) then 1 + Matches(s[1..], key)
	else Matches(s[1..], key)
}

// Similar to above but as a method checking an array, low is the index to start checking from
method ArrayMatches(a:array<int>, key:int, low:nat) returns (matches:nat)
decreases a.Length - low
ensures low < a.Length ==> matches == Matches(a[low..], key)
ensures low >= a.Length ==> matches == 0
requires a != null
{
	if (low >= a.Length){
		matches := 0;
	} else if (a[low] == key){
		matches := ArrayMatches(a, key, low+1);
		matches := matches + 1;
	} else {
		matches := ArrayMatches(a, key, low+1);
	}
}

// Uses LinearSearch to return objects which match key
method LinearSearchMultiple(a:array<int>, key:int) returns (r:array<int>)
requires a != null
ensures r != null
ensures forall i:nat :: i<r.Length ==> r[i] == key
// If returned array has no values, there are no matches
ensures r.Length == 0 ==> Matches(a[..],key) == 0
// For all elements in a, if it is a key it is in r and vice versa (if an element is in r it is a key)
ensures r.Length != 0 ==> forall i:nat :: i<a.Length ==> (InsideUpTo(r, a[i], r.Length) <==> a[i] == key)
ensures r.Length != 0 ==> multiset(r[..]) <= multiset(a[..])	// r is a subset of a 
ensures r.Length == Matches(a[..], key)	// Ensures that every match is in r
// Can't distinguish between ints with the same value so this is the best we can do
{

	// Find number of matches to init returned array with appropriate size
	var matches := ArrayMatches(a, key, 0);
	r := new int[matches];
	if (r.Length == 0){ return; } // If no matches leave early	

	var i := 0;	// index for iterating through a
	var j := 0;	// index for holding current index of r 

	while (i < a.Length || j < r.Length)
	decreases a.Length + matches -i -j
	invariant 0<=i<=a.Length
	invariant j <= r.Length && r.Length - j == Matches(a[i..], key)	// remaining matches to find not yet in r
	invariant forall k:nat :: k<j<=r.Length ==> r[k] == key	// All elements in r are keys
	// All elements in a that are keys are in r
	invariant forall k:nat :: k<i<=a.Length ==> (InsideUpTo(r, a[k], j) <==> a[k] == key)
	invariant multiset(r[..j]) <= multiset(a[..i])	// r is a subset of a (when treated as a multiset)
	{
		// If looking at a match, add to r
		if (a[i] == key){
			r[j] := a[i];
			j := j + 1;
		}
		i := i + 1;
	}
	assert a[..i] == a[..];
	assert r[..j] == r[..];
}