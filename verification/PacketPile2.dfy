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

    method getAlmostExpired() returns (trash: array<int>)
        requires Valid(); ensures Valid()
        ensures trash != null
        ensures forall i :: 0 <= i < |trash[..]| ==> trash[i] == 1;
    {
        //var size := getNAlmostExpired();
        var nTrash := 0;
        var tempTrash := new int[count];
        var i := 0;
        while i < count
        decreases count - i
        invariant count == old(count)
        invariant buf == old(buf)
        invariant 0 <= i <= count
        invariant 0 <= nTrash <= i
        invariant forall j :: 0 <= j < nTrash ==> tempTrash[j] == 1
        {
            if buf[i] == 1 {
                tempTrash[nTrash] := buf[i];
                nTrash := nTrash + 1;
            }
            i := i + 1;
        }

        //need to reduce trash array size for postcond
        trash := new int[nTrash];
        i := 0;
        while i < nTrash
        decreases nTrash - i
        invariant count == old(count)
        invariant trash == old(trash)
        invariant 0 <= i <= nTrash
        invariant forall j :: 0 <= j < nTrash ==> tempTrash[j] == 1
        invariant forall j :: 0 <= j < i ==> trash[j] == tempTrash[j]
        {
            trash[i] := tempTrash[i];
            i := i + 1;
        }
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
