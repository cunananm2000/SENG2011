


method popArray(a:array<int>, size:nat) 
returns (e:int, newSize:nat)
modifies a
requires a != null
requires 0<size<=a.Length
ensures newSize<size
ensures a[..newSize] == old(a[..newSize])
{
	e := a[size-1];
	newSize := size-1;
}

// b is first index, c is second
method swapElements(a:array<int>, size:nat, b:nat, c:nat) 
modifies a
requires a != null
requires b < c < size <= a.Length
ensures a[..b] == old(a[..b]) && a[b+1..c] == old(a[b+1..c])
&& a[c+1..] == old(a[c+1..])
ensures a[b] == old(a[c]) && a[c] == old(a[b])
{
	a[b], a[c] := a[c], a[b];
}

method shiftElements(a:array<int>, i:nat)
modifies a
requires a != null
requires i<a.Length
ensures a[..i] == old(a[..i]) && a[i..a.Length-1] == old(a[i+1..])
{
	var s := a[i+1..];
	if (|s| > 0){
		CopyIntoArray(s, a, i);
	}
}


method CopyNArray(s:array<int>, start:nat, a:array<int>, low:nat)
modifies a
requires a != null
requires s.Length > 0
requires s.Length -start <= a.Length - low;
ensures forall i :: 0<=i<s.Length ==> (s[i] == a[i+low])
ensures old(a[..low]) == a[..low] && old(a[s.Length+low..]) == a[s.Length+low..]
{

}

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