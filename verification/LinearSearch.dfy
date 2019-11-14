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

method LinearSearchMultiple(a:array<int>, key:int) returns (r:array<int>)
requires a != null
ensures forall i:nat :: i< r.Length ==> r[i] == key
ensures r.Length == 0 ==> Matches(a[..],key) == 0
ensures r.Length != 0 ==> forall i:nat :: i<a.Length ==> (InsideUpTo(r, a[i], r.Length) <==> a[i] == key) 
ensures r.Length != 0 ==> multiset(r[..]) <= multiset(a[..]) 
ensures r.Length != 0 ==> !(multiset(r[..] + [key]) <= multiset(a[..]))
{
  // Find number of matches to init returned array with appropriate size
  var matches := ArrayMatches(a, key, 0);
  assert matches == Matches(a[..], key);
  r := new int[matches];
  // If no matches leave early
  if (r.Length == 0){
    return;
  }

  var i := 0;
  var j := 0;
  assert forall k:nat :: k<i<a.Length ==> (InsideUpTo(r, a[k], r.Length) <==> a[k] == key);
  assert matches == r.Length;
  assert Matches(a[i..], key) == matches;
  assert Matches(a[i..], key) == r.Length;
  assert multiset(r[..j]) <= multiset(a[..]);

  while (i < a.Length || j < r.Length)
  decreases a.Length + matches -i -j
  invariant 0 <= i <= a.Length
  invariant forall k:nat :: k<j<=r.Length ==> r[k] == key
  invariant j <= matches && j <= r.Length
  invariant r.Length - j == Matches(a[i..], key);
  invariant forall k:nat :: k<i<=a.Length ==> (InsideUpTo(r, a[k], j) <==> a[k] == key)
  invariant multiset(r[..j]) <= multiset(a[..])
  {
    if (a[i] == key){
      r[j] := a[i];
      assert a[i] == key;
      assert multiset(r[..j]) <= multiset(a[..]);
      assert InsideArray(a, r[j]);
      //assert multiset([r[j]]) <= multiset(a[..]);
      //assert multiset(r[..j]+[r[j]]) <= multiset(a[..]);
      j := j + 1;
      //assert multiset(r[..j-1]) <= multiset(a[..]);
      var gho := r[..j-1]+[r[j-1]];
      //assert Matches(gho[..], key) <= Matches(a[..], key);
      //assert multiset(gho) <= multiset(a[..]);
      //assert multiset(r[..j]) <= multiset(a[..]);
      
    }
    //assert multiset(r[..j]) <= multiset(a[..]);
    //assert multiset([r[j]]) <= multiset(a[..]);
    i := i + 1;
  }
  assert i == a.Length;
  assert forall k:nat :: k<i<=a.Length ==> (InsideUpTo(r, a[k], j) <==> a[k] == key);
  assert forall k:nat :: k<a.Length ==> (InsideUpTo(r, a[k], j) <==> a[k] == key);
  assert j == r.Length;
  assert InsideUpTo(r, key, r.Length) <==> InsideArray(r, key);
  
}