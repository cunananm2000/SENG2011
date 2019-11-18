datatype BloodPacket = Empty | Node(expiryDate: int, )

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
        Sorted(buf, 0, count)
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
        invariant index == old(index); 
        invariant DualRange(buf, 0, i, i+1, count) == old(buf[..index]) + old(buf[index+1..old(count)]);
        invariant Sorted(buf, 0, count)
        {
            buf[i] := buf[i + 1];
            i := i + 1; 
        }
        count := count - 1; 
    }

    

    // Times out verifying these 
    // ensures old(count) == buf.Length ==> multiset(buf[..count]) == multiset(old(buf[1..old(count)])) + multiset([el]);
    // ensures old(count) != buf.Length ==> multiset(buf[..count]) == multiset(old(buf[..old(count)])) + multiset([el]);
    // method push(el: int) 
    // modifies this.buf, this`count; 
    // requires Valid(); ensures Valid();
    // requires count > 0;
    // ensures el in buf[..count];
    // {
    //     if (count == buf.Length)
    //     {
    //         assert count > 0;
    //         var p: int := popAtIndex(0); // Remove oldest
    //         assert count == buf.Length - 1;
    //         // Mark blood packet as disposed of 
    //     }

    //     var index: int := 0; 
    //     while (index < count && buf[index] < el) 
    //     invariant 0 <= index <= count; 
    //     invariant Sorted(buf, 0, count);
    //     invariant LTRange(buf, 0, index, el);
    //     {
    //         index := index + 1;
    //     }
    
    //     var i: int := count - 1; 
    //     while (i >= index) 
    //     invariant index - 1 <= i <= count - 1;
    //     invariant buf == old(buf);
    //     invariant if old(count) == buf.Length then count == buf.Length - 1 else count == old(count);
    //     invariant SortedIgnore(buf, 0, count + 1, i + 1);
    //     invariant LTRange(buf, 0, index, el);
    //     invariant GERangeIgnore(buf, index + 1, count + 1, el, i + 1);
    //     invariant old(count) == buf.Length ==> DualRange(buf, 0, i+1, i+2, count+1) == old(buf[1..old(count)]);
    //     invariant old(count) != buf.Length ==> DualRange(buf, 0, i+1, i+2, count+1) == old(buf[..old(count)]);
    //     {
    //         buf[i+1] := buf[i];
    //         i := i - 1; 
    //     } 
    //     count := count + 1;
    //     assert old(count) == buf.Length ==> DualRange(buf, 0, index, index+1, count) == old(buf[1..old(count)]);
    //     assert old(count) != buf.Length ==> DualRange(buf, 0, index, index+1, count) == old(buf[..old(count)]);
    //     buf[index] := el;
    //     assert old(count) == buf.Length ==> DualRange(buf, 0, index, index+1, count) == old(buf[1..old(count)]);
    //     assert old(count) != buf.Length ==> DualRange(buf, 0, index, index+1, count) == old(buf[..old(count)]);
    //     assert buf[index] == el;
    //     assert el in buf[..count];
    // }


    predicate IsClean(a: array<int>, low: int, high: int, key: int) 
    reads a; 
    requires a != null;
    requires 0 <= low <= high <= a.Length; 
    {
        forall j :: low <= j < high ==> a[j] != key
    }

    // Normally, objects wont have identical copies, unlike int
    // Ignore return since int can't be null, or otherwise is just el
    // ensures if IsClean(old(buf), 0, old(count), el) then count == old(count) else count == old(count) - 1;
    method removePacket(el: int)
    modifies this.buf, this`count;
    requires Valid(); ensures Valid(); 
    ensures buf == old(buf); // Note for next predicate, the commented IsClean ensures above doesn't work (?)
    ensures count == if (forall j :: 0 <= j < old(count) ==> old(buf[j]) != el) then old(count) else old(count) - 1;
    ensures multiset(buf[..count]) == multiset(old(buf[..old(count)])) - multiset([el]);
    {
    // ensures multiset(buf[..count]) == multiset(old(buf[..old(count)])) - multiset([el]);
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
    modifies this, this.buf, this`count, this`low;
    requires Valid(); ensures Valid();
    requires newSize >= 0;
    ensures fresh(buf);
    ensures buf.Length == newSize;
    ensures count == if (newSize < old(count)) then newSize else old(count);
    ensures low == if (old(low) > newSize) then newSize else old(low);
    ensures buf[..count] == if (newSize < old(count)) then old(buf[old(count)-newSize..old(count)]) else old(buf[..old(count)]);
    {
        var newBuf := new int[newSize];
        if newSize < count // Less inventory space
        {
            // Keep newest blood packets
            var i: int := 0; 
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
            var i: int := 0; 
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

    method isLow() returns (b: bool)
        requires Valid(); ensures Valid()
        ensures b <==> (this.count <= this.low)
    {
        b := this.count <= this.low;
    }

    method setLow(l: int)
        modifies this, this`low
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