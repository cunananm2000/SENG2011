method find(a: array<int>, key: int) returns (i: int)
ensures i == -1 || 0 <= i < a.Length
ensures 0 <= i < a.Length ==> a[i] == key && forall j:: 0 <= j < i ==> a[j] != key
ensures i == -1 ==> forall j:: 0 <= j < a.Length ==> a[j] != key
{
  i := 0;
  while(i < a.Length && a[i] != key)
  decreases a.Length - i
  invariant 0 <= i <= a.Length
  invariant forall j:: 0 <= j < i ==> a[j] != key
  {
    i := i + 1;
  }
  if (i == a.Length){
    i := -1;
  }
}

// Checks if key is in array
predicate InsideArray(a:array<int>, key:int)
reads a 
{
  exists i:nat :: i<a.Length && a[i] == key
}

predicate InsideUpTo(a:array<int>, key:int, high:nat)
requires high <= a.Length
reads a
{
  exists i:nat :: i<high && a[i] == key
}

// Returns number of matches of key in sequence
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
