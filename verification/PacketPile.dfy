// Verification for PacketPile class (abstracted to expiry date)
// Useful predicates, functions below class

class PacketPile
{
    var buf: array<int>; // int represents expiry date of blood packet
    var count: int; 
    var low: int; 
    // bloodStatuses 
   

    predicate Valid()
    reads this, this.buf; 
    {
        buf != null &&
        0 <= count <= buf.Length &&
        0 <= low <= buf.Length &&
        Sorted(buf, 0, count) // Sorted by expiry date
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

    method popAtIndex(index: int) returns (el: int) 
    modifies this.buf, this`count; 
    requires Valid(); ensures Valid(); 
    requires 0 <= index < count; 
    ensures count == old(count) - 1;
    ensures el == old(buf[index]);
    ensures buf[..count] == old(buf[..index]) + old(buf[index+1..old(count)]); // Putting RHS into predicate fails(?)
    {
        el := buf[index]; 
        
        var i: int := index; 
        while (i < count - 1)
        invariant index <= i <= count - 1; 
        invariant count == old(count);
        invariant buf == old(buf);
        invariant DualRange(buf, 0, i, i+1, count) == old(buf[..index]) + old(buf[index+1..old(count)]);
        invariant Sorted(buf, 0, count)
        {
            buf[i] := buf[i + 1];
            i := i + 1; 
        }
        count := count - 1; 
    }

    // I know it's ugly, but it's faster to verify when it's ugly 
    // Too slow to verify with sequences + multisets 
    method push(el: int) 
    modifies this.buf, this`count; 
    requires Valid(); ensures Valid();
    requires buf.Length > 0;
    ensures buf.Length == old(buf.Length);
    // ensures count == if old(count) == buf.Length then old(count) else old(count) + 1; // Too slow
    ensures old(count) < buf.Length ==> count == old(count) + 1; 
    ensures old(count) == buf.Length ==> count == old (count); 
    ensures old(count) < buf.Length ==> exists index :: 0 <= index < count && (
            (forall j :: 0 <= j < index ==> buf[j] == old(buf[j])) &&
            buf[index] == el &&
            (forall j :: index < j < count ==> buf[j] == old(buf[j-1]))
    );
    ensures old(count) == buf.Length ==> exists index :: 0 <= index < count && (
            (forall j :: 0 <= j < index ==> buf[j] == old(buf[j+1])) &&
            buf[index] == el &&
            (forall j :: index < j < count ==> buf[j] == old(buf[j]))
    );
    {
        if (count == buf.Length)
        {
            var p: int := popAtIndex(0); // Remove oldest
            assert count == old(count) - 1;
            assert buf.Length != 0; 
            assert forall j :: 0 <= j < count - 1 ==> buf[j] == old(buf[j+1]);
            
            // Mark blood packet as disposed of 
        }
        assert forall j :: 0 <= j < buf.Length ==> buf[j] == old(buf)[j];
        assert old(count) == buf.Length ==> (forall j :: 0 <= j < count ==> buf[j] == old(buf[j+1]));
        assert old(count) < buf.Length ==> (forall j :: 0 <= j < count ==> buf[j] == old(buf[j]));

        var index: int := 0; 
        while (index < count && buf[index] < el) 
        invariant 0 <= index <= count; 
        invariant Sorted(buf, 0, count);
        invariant LTRange(buf, 0, index, el);
        invariant old(count) == buf.Length ==> (forall j :: 0 <= j < count ==> buf[j] == old(buf[j+1])); 
        invariant old(count) < buf.Length ==> (forall j :: 0 <= j < count ==> buf[j] == old(buf[j]));
        {
            index := index + 1;
        }

        assert 0 <= index <= count < buf.Length; 
        assert LTRange(buf, 0, index, el);
        assert GERange(buf, index, count, el);

        var i: int := count - 1; 
        while (i >= index) 
        invariant index - 1 <= i <= count - 1;
        invariant count <= buf.Length; 
        invariant buf.Length == old(buf.Length);
        invariant LTRange(buf, 0, index, el);
        invariant old(count) <  buf.Length ==> count == old(count);
        invariant old(count) == buf.Length ==> count == old(count) - 1;
        invariant old(count) <  buf.Length ==> (forall j :: 0 <= j < i + 1 ==> buf[j] == old(buf[j]));
        invariant old(count) == buf.Length ==> (forall j :: 0 <= j < i + 1==> buf[j] == old(buf[j+1]));
        invariant old(count) <  buf.Length ==> (forall j :: i + 1 < j <= count ==> buf[j] == old(buf[j-1]));
        invariant old(count) == buf.Length ==> (forall j :: i + 1 < j <= count ==> buf[j] == old(buf[j]));
        {
            buf[i+1] := buf[i];
            i := i - 1; 
        } 
        count := count + 1;
        buf[index] := el;
    }

    // Normally, objects wont have identical copies, unlike int
    // Ignore return since int can't be null, or otherwise is just el
    method removePacket(el: int)
    modifies this.buf, this`count;
    requires Valid(); ensures Valid(); 
    ensures buf == old(buf);
    ensures count == if (forall j :: 0 <= j < old(count) ==> old(buf[j]) != el) then old(count) else old(count) - 1; // Can't use IsClean because old(buf[j]) != old(buf)[j]
    ensures multiset(buf[..count]) == multiset(old(buf[..old(count)])) - multiset([el]);
    {
        var i: int := 0; 
        while (i < count && buf[i] != el)
        invariant 0 <= i <= count; 
        invariant buf == old(buf);
        invariant count == old(count);
        invariant IsClean(buf, 0, i, el); 
        {
            i := i + 1;
        }
        
        if (i == count) 
        {
        } 
        else 
        {
            var temp: int := popAtIndex(i);
            assert old(buf[..i]) + [old(buf[i])] + old(buf[i+1..old(count)]) == old(buf[..old(count)]);
        }
    }

    method resize(newSize: int)
    modifies this`buf, this`count, this`low;
    requires Valid(); ensures Valid();
    requires newSize >= 0;
    ensures fresh(buf);
    ensures buf.Length == newSize;
    ensures count == if (newSize < old(count)) then newSize else old(count);
    ensures low == if (old(low) > newSize) then newSize else old(low);
    ensures buf[..count] == if (newSize < old(count)) then old(buf[old(count)-newSize..old(count)]) else old(buf[..old(count)]);
    {
        var newBuf := new int[newSize];
        var i: int := 0; 
        if newSize < count // Less inventory space
        {
            // Keep newest blood packets
            var shift: int := count - newSize;

            while (i < newSize) 
            invariant 0 <= i <= newSize;
            invariant count == old(count);
            invariant low == old(low);
            invariant buf == old(buf);
            invariant 0 < shift + i <= count <= buf.Length; 
            invariant newBuf[..i] == buf[shift..shift+i]
            invariant buf[count-newSize..count] == old(buf[old(count)-newSize..old(count)]);
            invariant Sorted(buf, 0, count);
            {
                newBuf[i] := buf[shift + i];
                i := i + 1; 
            }
            count := newSize; 
            assert Sorted(newBuf, 0, count); 
        } 
        else 
        {
            // Directly copy 
            while (i < count) 
            invariant 0 <= i <= count;
            invariant count == old(count);
            invariant low == old(low);
            invariant buf == old(buf);
            invariant newBuf[..i] == buf[..i];
            invariant buf[..count] == old(buf[..count]);
            {
                newBuf[i] := buf[i]; 
                i := i + 1;
            }
        }
        if (low > newSize)
        {
            low := newSize; 
        }
        buf := newBuf;
    }

    // Excluding String dest since we aren't dealing with actual bloodpacket objects
    method doRequest(nPackets: int, useBy: int) returns (result: array<int>)
    requires Valid(); ensures Valid();
    fresh
    {
        result := new int[nPackets];
    }

    method isLow() returns (b: bool)
        requires Valid(); ensures Valid()
        ensures b <==> (this.count <= this.low)
    {
        b := this.count <= this.low;
    }

    method setLow(l: int)
        modifies this`low
        requires Valid(); ensures Valid()
        requires 0 <= l <= buf.Length
        ensures this.low == l
    {
        this.low := l;
    }

    method getSize() returns (size: int)
        requires Valid(); ensures Valid()
        ensures size == buf.Length
    {
        size := buf.Length;
    }

    method getCount() returns (c: int)
        requires Valid(); ensures Valid()
        ensures c == this.count
    {
        c := this.count;
    }

    method getBuf() returns(newBuf: array<int>)
        requires Valid(); ensures Valid()
        ensures newBuf != null
        ensures buf[..count] == newBuf[..]
    {
        newBuf := new int[count];
        var i := 0;
        while (i < count) 
        invariant 0 <= i <= count;
        invariant count == old(count);
        invariant low == old(low);
        invariant buf == old(buf);
        invariant newBuf[..i] == buf[..i];
        invariant buf[..count] == old(buf[..count]);
        {
            newBuf[i] := buf[i]; 
            i := i + 1;
        }
    }

}

predicate Sorted(a: array<int>, low: int, high: int)
reads a;
requires a != null;
requires 0 <= low <= high <= a.Length;  
{
    forall i, j :: low <= i < j < high ==> a[i] <= a[j]
}

function DualRange(a: array<int>, low: int, mid1: int, mid2: int, high: int): seq<int>
reads a;
requires a != null;
requires 0 <= low <= mid1 <= mid2 <= high <= a.Length;
{
    a[low..mid1] + a[mid2..high]
}

predicate SortedIgnore(a: array<int>, low: int, high: int, index: int)
reads a;
requires a != null;
requires 0 <= low <= high <= a.Length;  
{
    forall i, j :: low <= i < j < high && i != index && j != index ==> a[i] <= a[j]
}

predicate LTRange(a: array<int>, low: int, high: int, key: int) 
reads a; 
requires a != null;
requires 0 <= low <= high <= a.Length;
{
    forall j :: low <= j < high ==> a[j] < key
}

predicate GERange(a: array<int>, low: int, high: int, key: int)
reads a;
requires a != null;
requires 0 <= low <= high <= a.Length;
{
    forall j :: low <= j < high ==> a[j] >= key
}

predicate GERangeIgnore(a: array<int>, low: int, high: int, key: int, ignore: int)
reads a;
requires a != null;
requires 0 <= low <= high <= a.Length;
{
    forall j :: low <= j < high && j != ignore ==> a[j] >= key
}

predicate IsClean(a: array<int>, low: int, high: int, key: int) 
reads a; 
requires a != null;
requires 0 <= low <= high <= a.Length; 
{
    forall j :: low <= j < high ==> a[j] != key
}

// predicate temp(s1: seq<int>, s2: seq<int>, s3: seq<int>) 
// requires s1 == s2 + s3; 
// {
//     multiset(s1) == multiset(s2) + multiset(s3)
// }

method Main() {
    var p: PacketPile;
    var c: int;
    var popped: int;

    p := new PacketPile;
    p.Init(10, 3);
    c := p.getCount();
    assert !(1 in p.buf[..p.count]);
    assert c == 0;

    p.push(1);
    c := p.getCount();
    assert 1 in p.buf[..p.count];
    assert c == 1;

    popped := p.popAtIndex(0);
    c := p.getCount();
    assert !(1 in p.buf[..p.count]);
    assert c == 0;
    assert popped == 1;

    assert p.buf != null;
    // Following should fail 
    // p.resize(-1);
}
