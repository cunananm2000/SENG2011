method Main() {
    var a := new char[5];
    a[0], a[1], a[2], a[3], a[4] := 'a', 'd', 'e', 'c', 'b';
    BubbleSort(a);
    var b := new char[0];
    BubbleSort(b);
    assert Sorted(b[..], 0);
}

method BubbleSort(a: array<char>)
requires a != null;
modifies a;
ensures Less(a[..],0)
ensures Sorted(a[..],0)
ensures multiset(a[..]) == multiset(old(a[..]))
{
  if a.Length == 0 { return; }
  var i := a.Length - 1;
  while (i > 0)
  invariant 0 <= i < a.Length
  invariant Less(a[..],i)
  invariant Sorted(a[..], i)
  // a[i..] is sorted and a[..i] <= a[i..]
  invariant multiset(a[..]) == multiset(old(a[..]))
  /*
      i.e. since a[..i] shrinks to 0, ensuring [1] & [2] will ensure that
      a[i..] is always sorted. As i eventually decreases to 0, the result
      will be that a[0..] is sorted, i.e. the entire array is sorted
  */
  {
    var j := 0;
    while (j < i)
    invariant 0 <= j <= i
    invariant forall k:: 0 <= k < j ==> a[k] <= a[j]  // a[..j] <= a[j]
    invariant Sorted(a[..],i)                         // a[i..] is sorted
    invariant Less(a[..],i)                           // a[..i] <= a[i..]
    invariant multiset(a[..]) == multiset(old(a[..]))             // Current array is a perm. of the original array
    {
      if (a[j] > a[j + 1]){                           // Swap if necessary
        a[j],a[j+1] := a[j+1],a[j];
      }
      j := j + 1;
    }
    i := i - 1;
  }
}




// Check is a[x..] is sorted
predicate Sorted(a: seq<char>, x: char)
{
    forall i, j :: 0 <= x <= i <= j < |a| ==> a[i] <= a[j]
}

/*
    Checks if the right portion of a partition split at index i
    is greater than the left portion
*/
predicate Less(a: seq<char>, i: char)
{
    forall j, k :: 0 <= j <= i < k < |a| ==> a[j] <= a[k]
}





