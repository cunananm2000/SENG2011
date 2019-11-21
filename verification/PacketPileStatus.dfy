//  Time to verify:
//  Corresponds to the packet pile in PacketPile.java
//  Abstractions:
//      In practice, packet pile would store a buffer of blood packets
//      This version of the proof will abstract each blood packet to
//      just the status integer, since the functions we prove in this file
//      will only see blood packets as expiry date integers.
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
    ensures (1 in buf[..count]) <==> total > 0
    {
        total := 0;
        var i: int := 0;
        while (i < count) 
        invariant 0 <= i <= count
        invariant total == Count(buf[..i], 1)
        invariant 1 in buf[..i] <==> total > 0
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

    method getAlmostExpired() returns (almostTrashIDs: array<int>)
    requires Valid(); ensures Valid(); 
    ensures fresh(almostTrashIDs);
    ensures almostTrashIDs.Length == Count(buf[..count], 1);
    ensures forall j :: 0 <= j < almostTrashIDs.Length ==> almostTrashIDs[j] == 1;
    ensures multiset(almostTrashIDs[..]) <= multiset(buf[..count]);
    {
        var trashSize: int := getNAlmostExpired();
        almostTrashIDs := new int[trashSize];

        var next: int := 0;
        var i: int := 0; 
        while (i < count) 
        invariant 0 <= i <= count; 
        invariant next <= almostTrashIDs.Length;
        invariant forall j :: 0 <= j < next ==> almostTrashIDs[j] == 1; 
        invariant next == Count(buf[..i], 1);
        invariant next + Count(buf[i..count], 1) == almostTrashIDs.Length;
        invariant multiset(almostTrashIDs[..next]) <= multiset(buf[..i]);
        {
            if (buf[i] == 1)
            {
                almostTrashIDs[next] := buf[i];
                next := next + 1;
            }
            DistributiveLemma(buf[..i], [buf[i]], 1);
            assert buf[..i+1] == buf[..i] + [buf[i]];
            i := i + 1; 
        }
        assert almostTrashIDs[..next] == almostTrashIDs[..];
    }
}

function method Count(a: seq<int>, key: int) : nat
    decreases |a|
    ensures Count(a, key) <= |a|
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
