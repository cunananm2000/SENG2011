// Recursively count the number of appearances 'k' has in sequence 'a'
function count(a: seq<int>, k: int): nat{
  if |a| == 0 then 0 else (if a[0] == k then 1 else 0) + count(a[1..],k)
}

/*
  Counting the instances of a key in the sum of two sequences,
  is the same as summing the instances of the key in each sequence
*/
lemma distributiveCount(a: seq<int>, b: seq<int>)
ensures forall k:: count(a + b,k) == count(a,k) + count(b,k)
{
  if (|a| == 0){
    assert a + b == b;
  } else {
    distributiveCount(a[1..],b);
    assert a == [a[0]] + a[1..];
    assert a + b == [a[0]] + (a[1..] + b);
  }
}

/*
  If we have two pairs of seq's that are permutations of each other, then
  it must be true that their sums are also permutations.
*/
lemma distributivePerm(a: seq<int>,a': seq<int>,b: seq<int>,b': seq<int>)
requires PermOf(a,a')
requires PermOf(b,b')
ensures PermOf(a+b,a'+b')
{
  assert forall k:: count(a,k) + count(b,k) == count(a',k) + count(b',k);
  distributiveCount(a,b);
  distributiveCount(a',b');
  assert forall k:: count(a + b,k) == count(a,k) + count(b,k) == count(a',k) + count(b',k) == count(a'+b',k);
  assert PermOf(a+b,a'+b');
}

// Check if one sequence is a permutation of another by counting appearances of keys
predicate PermOf(a: seq<int>, b: seq<int>) {
  forall i: int :: count(a,i) == count(b,i)
}

// Check is a[x..] is sorted
predicate Sorted(a: seq<int>, x: int)
{
    forall i, j :: 0 <= x <= i <= j < |a| ==> a[i] <= a[j]
}

/*
    Checks if the right portion of a partition split at index i
    is greater than the left portion
*/
predicate Less(a: seq<int>, i: int)
{
    forall j, k :: 0 <= j <= i < k < |a| ==> a[j] <= a[k]
}

method BubbleSort(a: array<int>)
requires a != null;
modifies a;
ensures Less(a[..],0)
ensures Sorted(a[..],0)
ensures PermOf(old (a[..]), a[..])
{
  if a.Length == 0 { return; }
  var i := a.Length - 1;
  while (i > 0)
  invariant 0 <= i < a.Length
  invariant Less(a[..],i)
  invariant Sorted(a[..], i)
  // a[i..] is sorted and a[..i] <= a[i..]
  invariant PermOf(old (a[..]), a[..])
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
    invariant PermOf(old (a[..]), a[..])              // Current array is a perm. of the original array
    {
      ghost var a' := a[..];                          // Save instance of array before any swapping
      ghost var v1,v2 := a[j],a[j+1];                 // Get the two variables that (may) be swapped
//      assert a[..] == a[0..j] + [v1,v2] + a[j+2..];
      
      if (a[j] > a[j + 1]){                           // Swap if necessary
        a[j],a[j+1] := a[j+1],a[j];
      }
      
      /*
        Intution for the proof:
          We may partition the seq 'a' into 3 subsets: a[..i],a[i,i+1],a[i+2..].
          Clearly, these subsets are disjoint and their sum is 'a'.
          During the swap, these subsets are individually permuted within themselves,
            that is, no member of a subset will end up in a different subset after the swap.
          We formalise this by saying that a[..i],a[i,i+1],a[i+2..] are each unaffected up to a permutation
          We assert these individually, and also use the distributive lemma regarding permutations
            to show that therefore the whole array is a permutation of the original array
      */
      
      ghost var v3,v4 := a[j],a[j+1];                     // Save two variables that (may) have been swapped
      assert PermOf([v1,v2],[v3,v4]);
      assert PermOf(a'[0..j],a[0..j]);
      distributivePerm(a'[0..j],a[0..j],[v1,v2],[v3,v4]);
      
      assert PermOf(a'[0..j] + [v1,v2],a[0..j] + [v3,v4]);
      assert PermOf(a'[j+2..],a[j+2..]);
      distributivePerm(a'[0..j]+[v1,v2],a[0..j]+[v3,v4],a'[j+2..],a[j+2..]);
      
      assert a'[..] == a'[0..j] + [v1,v2] + a'[j+2..];
      assert a[..] == a[0..j] + [v3,v4] + a[j+2..];
      assert PermOf(a',a[..]);
      
      j := j + 1;
    }
    i := i - 1;
  }
}


method Main() {
    var a := new int[5];
    a[0], a[1], a[2], a[3], a[4] := 9, 4, 6, 3, 8;
    BubbleSort(a);
    var b := new int[0];
    BubbleSort(b);
    assert Sorted(b[..], 0);
}
