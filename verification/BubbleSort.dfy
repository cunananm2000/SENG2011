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
    requires a != null
    modifies a
    ensures Sorted(a[..], 0)
{
    if a.Length == 0 { return; }
    var i := a.Length - 1;
    while i > 0
    invariant 0 <= i < a.Length
    // a[i..] is sorted and a[..i] <= a[i..]
    invariant Sorted(a[..], i) && Less(a[..], i)
    /*
        i.e. since a[..i] shrinks to 0, ensuring [1] & [2] will ensure that
        a[i..] is always sorted. As i eventually decreases to 0, the result
        will be that a[0..] is sorted, i.e. the entire array is sorted
    */
    {
        var j := 0;
        while j < i
        invariant 0 <= j <= i
        // a[i..] is sorted and a[..i] <= a[i..]
        invariant Sorted(a[..], i) && Less(a[..], i)
        // a[..j] <= a[j]
        invariant forall k :: 0 <= k < j ==> a[k] <= a[j]
        {
            if a[j] > a[j + 1] { a[j], a[j + 1] := a[j + 1], a[j]; }
            j := j + 1;
        }
        i := i - 1;
    }
}

method Main() {
    var a := new int[5];
    a[0], a[1], a[2], a[3], a[4] := 9, 4, 6, 3, 8;
    BubbleSort(a);
    assert Sorted(a[..], 0);
    var b := new int[0];
    BubbleSort(b);
    assert Sorted(b[..], 0);
}
