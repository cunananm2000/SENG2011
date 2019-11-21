predicate FullSorted(a: seq<int>){
    forall i,j :: 0 <= i < j < |a| ==> a[i] <= a[j]
}

method SortedInsert(a: seq<int>, el: int) returns (b: seq<int>)
requires FullSorted(a[..])
ensures multiset(b[..]) == multiset(a[..]) + multiset([el])
ensures FullSorted(b[..])
{
    var i := 0;
    while (i < |a| && a[i] < el)
    decreases |a| - i;
    invariant 0 <= i <= |a|
    invariant forall k :: 0 <= k < i ==> a[k] <= el
    {
        i := i + 1;
    }
    if (i == |a|){
        b := a + [el];
    } else if (i == 0) {
        assert el <= a[0];
        b := [el] + a;
    } else {
        assert a[..] == a[..i] + a[i..];
        b := a[..i] + [el] + a[i..];
    }
    
}