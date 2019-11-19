// Parallel to PacketPile in PacketPile.dfy
// Since having objects from another class is a framing nightmare,
// this file focuses on the 'status' of a BloodPacket 

class PacketPile 
{
    var buf: array<int>;  // represents status 
    var count: int; 
    var low: int;

    predicate Valid() 
    reads this, this.buf; 
    {
        buf != null && 
        0 <= count <= buf.Length &&
        0 <= low <= buf.Length &&
        forall j :: 0 <= j < count ==> 0 <= buf[j] <= 2 
        // Valid statuses
        // 0: clear
        // 1: almost expired
        // 2: expired
    }

    method Init(size: int, low1: int)
    modifies this; 
    requires 0 <= low1 <= size; 
    ensures Valid();
    ensures fresh(buf);
    ensures buf.Length == size; 
    ensures count == 0; 
    ensures low == low1; 
    {
        buf := new int[size];
        count := 0; // initially 0 packets
        low := low1; 
    }

    method getNAlmostExpired() returns (total: int)
    requires Valid(); ensures Valid()
    ensures total == Count(buf[..count], 1)
    {
        total := 0;
        var i: int := 0;
        while (i < count) 
        invariant 0 <= i <= count;
        invariant total == Count(buf[..i], 1);
        {
            if (buf[i] == 1) 
            {
                total := total + 1; 
            }
            DistributiveLemma(buf[..i], [buf[i]], 1);
            assert buf[..i+1] == buf[..i] + [buf[i]];
            i := i + 1; 
        }
    }

    method getAlmostExpired() returns (trash: array<int>)
        requires Valid(); ensures Valid()
        ensures trash != null
        ensures forall i :: 0 <= i < |trash[..]| ==> trash[i] == 1;
    {
        var size := getNAlmostExpired();
        var trashSeq: seq<int> := [];
        var i := 0;
        while i < count
        decreases count - i
        invariant 0 <= i <= count
        invariant forall j :: 0 <= j < |trashSeq| ==> trashSeq[j] == 1
        {
            if buf[i] == 1 {
                trashSeq := trashSeq + [buf[i]];
            }
            i := i + 1;
        }
        trash := seqToArrInt(trashSeq);
    }
}

function method Count(a: seq<int>, key: int) : nat
decreases |a|
{   
    if |a| == 0 then 0 else
    (if a[0] == key then 1 else 0) + Count(a[1..], key)
}

lemma DistributiveLemma(a: seq<int>, b: seq<int>, key: int)
ensures Count(a + b, key) == Count(a, key) + Count(b, key)
{
    if a == [] {
        assert a + b == b;
    } else {
        DistributiveLemma(a[1..], b, key);
        assert a + b == [a[0]] + (a[1..] + b);
    }
}

method seqToArrInt(s: seq<int>) returns(a: array<int>)
    ensures a != null
    ensures a.Length == |s|
    ensures forall i :: 0 <= i < |s| ==> a[i] == s[i]
    ensures multiset(a[..]) == multiset(s)
{
    a := new int[|s|];
    var i := 0;
    while i < |s|
    decreases |s| - i
    invariant 0 <= i <= |s|
    invariant forall j :: 0 <= j < i ==> a[j] == s[j]
    {
        a[i] := s[i];
        i := i + 1;
    }
    assert a[..] == s;
}
