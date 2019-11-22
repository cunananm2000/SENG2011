//  Time to verify: 0m37.716s (note that this is almost 5 minutes via SSH)
//  Corresponds to the packet pile in PacketPile.java
//  Abstractions:
//      In practice, packet pile would store a buffer of blood packets
//      This version of the proof will abstract each blood packet to
//      just the expiry date, since the functions we prove in this file
//      will only see blood packets as expiry date integers.

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
        ensures el in old(buf[..old(count)]) ==> 
                exists j :: 0 <= j < old(count) && buf[..count] == old(buf[..j]) + old(buf[j+1..old(count)]) 
                && old(buf[j]) == el; 
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
                assert el in old(buf[..old(count)]);
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
        modifies this.buf, this`count;
        requires Valid();
        requires nPackets > 0;
        ensures Valid();
        ensures result != null;
        ensures forall i :: 0 <= i < result.Length ==> result[i] >= useBy;
        ensures 0 <= result.Length <= old(count);
        ensures countGEend(old(buf)[..old(count)],useBy) < nPackets ==> result.Length == 0; // If not enough, return nothinf
        ensures countGEend(old(buf)[..old(count)],useBy) >= nPackets ==> count == old(count) - nPackets;
        ensures countGEend(old(buf)[..old(count)],useBy) >= nPackets ==> result.Length == nPackets; // If enough, then returns some amount
        // ensures countGEend(buf[..],useBy) >= nPackets ==> result[0]// If enough, return the oldest possible
        // Oldest <==> Just before result it too early // what if result[0]
            // Everything before is too early
            // THere exists an index such hat everything befor eis tpoo early
        // ensures countGEend(old(buf)[..old(count)]),useBy) >= nPackets ==> 
        //     exists lo :: 0 <= lo <= i+nPackets <= old(count) && (
        //         (forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]) < useBy) &&
        //         (forall j :: 0 <= j < nPackets ==> result[j] == old(buf[j+lo]))
        //     );
        {
        result := new int[nPackets];
        var lo := 0;
        while (lo < count && buf[lo] < useBy)
        decreases count - lo;
        invariant old(buf) == buf;
        invariant forall i :: 0 <= i < count ==> buf[i] == old(buf[i]);
        invariant old(count) == count;
        invariant 0 <= lo <= count;
        invariant forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
        invariant forall j :: 0 <= j < lo ==> buf[j] < useBy;
        invariant Valid();
        invariant Sorted(buf,0,count);
        invariant countGEend(buf[..lo],useBy) == 0;
        invariant count <= buf.Length;
        {
            assert countGEend(buf[..lo],useBy) == 0;
            assert buf[lo] < useBy;
            assert count > 0;
            assert countGEend(buf[..lo+1],useBy) == if |buf[..lo+1]| == 0 then 0 else
                                            (if buf[..lo+1][|buf[..lo+1]|-1] >= useBy then 1 else 0) + countGEend(buf[..lo+1][..|buf[..lo+1]|-1], useBy);

            assert |buf[..lo+1]| == lo+1 != 0;
            assert countGEend(buf[..lo+1],useBy) == (if buf[..lo+1][|buf[..lo+1]|-1] >= useBy then 1                               else 0) + countGEend(buf[..lo+1][..|buf[..lo+1]|-1], useBy);
            assert |buf[..lo+1]|-1 == lo;
            assert buf[..lo+1][|buf[..lo+1]|-1] == buf[lo] < useBy;
            assert (if buf[..lo+1][|buf[..lo+1]|-1] >= useBy then 1 else 0) == 0;

            assert countGEend(buf[..lo+1],useBy) == 0 + countGEend(buf[..lo+1][..lo], useBy);
            assert buf[..lo+1][..lo] == buf[..lo];
            assert countGEend(buf[..lo+1],useBy) == 0 + countGEend(buf[..lo], useBy);
            assert countGEend(buf[..lo+1],useBy) == countGEend(buf[..lo],useBy);
            lo := lo + 1;
        }
        assert countGEend(buf[..lo],useBy) == 0;
        assert forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
        assert forall j :: 0 <= j < lo ==> buf[j] < useBy;

        // if (count - i < nPackets)
        if (lo == count) {
            assert countGEend(buf[..count],useBy) == 0 < nPackets;
            result := new int [0];
        } else {
            assert (lo < count);
            assert (buf[lo] >= useBy);
            assert (useBy <= buf[lo]);
            assert Sorted(buf,0,count);
            assert forall j :: lo <= j < count ==> buf[j] >= useBy;
            assert countGEend(buf[..lo],useBy) == 0;
            var found := 0;

            while (lo + found < count && found < nPackets)
            decreases count - (lo + found);
            invariant Valid();
            invariant useBy <= buf[lo];
            invariant old(buf) == buf;
            invariant forall i :: 0 <= i < count ==> buf[i] == old(buf[i]);
            invariant old(count) == count;
            invariant 0 <= lo <= count;
            invariant lo <= lo + found <= count <= buf.Length;
            invariant 0 <= found <= nPackets;

            invariant forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
            invariant forall j :: 0 <= j < lo ==> buf[j] < useBy;
            
            invariant Sorted(buf,0,count);
            invariant allGE(buf,lo,lo+found,useBy);


            // Now you've found how many that are possible
            if (found >= nPackets) {
                
                // Good
                // We formalise this as 'good', that there are enough packets
                assert 0 <= count <= buf.Length;

                assert allGE(buf,lo,lo+found,useBy);

                assert buf[..lo+found] == buf[..lo] + buf[lo..lo+found]; 
                assert countGEend(buf[lo..lo+found],useBy) == nPackets;
                assert countGEend(buf[..lo],useBy) == 0;
                distcountGEend(buf[..lo],buf[lo..lo+found],useBy);
                assert countGEend(buf[..lo+found],useBy) == nPackets;

                assert buf[..count] == buf[..lo+found] + buf[lo+found..count];
                assert countGEend(buf[lo+found..count],useBy) >= 0;
                distcountGEend(buf[..lo+found],buf[lo+found..count],useBy);
                assert countGEend(buf[..count],useBy) >= nPackets;

                result := new int[nPackets];
                assert old(buf) == buf;
                assert allGE(buf,lo,lo+found,useBy);
                assert countGEend(buf[..count],useBy) >= nPackets;

                assert !(countGEend(old(buf)[..old(count)],useBy) < nPackets);

                var i := 0;
                while (i < nPackets)
                decreases nPackets - i;
                invariant Valid();
                invariant buf == old(buf);
                invariant forall i :: 0 <= i < count ==> buf[i] == old(buf[i]);
                invariant useBy <= buf[lo];
                invariant allGE(buf,lo,lo+found,useBy);
                invariant 0 <= count <= buf.Length && countGEend(buf[..count],useBy) >= nPackets;
                invariant 0 <= i <= nPackets;
                invariant lo <= lo + i <= lo + nPackets <= count;
                invariant Sorted(buf,0,count);
                invariant forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
                invariant forall j :: 0 <= j < lo ==> buf[j] < useBy;
                invariant forall j :: 0 <= j < i ==> result[j] >= useBy;
                invariant forall j :: 0 <= j < i ==> result[j] == buf[lo+j];
                invariant count == old(count);
                {
                    assert useBy <= buf[lo] <= buf[lo+i];
                    assert forall j :: 0 <= j < i ==> result[j] == buf[lo+j];
                    result[i] := buf[lo+i];
                    assert forall j :: 0 <= j <= i ==> result[j] == buf[lo+j];
                    i := i + 1;
                }
                assert countGEend(buf[..count],useBy) >= nPackets ==> result.Length == nPackets;
                assert count <= buf.Length;

                assert 0 <= lo <= old(count);
                assert forall j :: 0 <= j < lo ==> buf[j] < useBy;
                assert forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
                assert forall j :: 0 <= j < nPackets ==> result[j] == old(buf[lo+j]);

                assert lo + nPackets <= old(count);

                // Now that you have the correct ones we assert that this came from a continuous subset:
                    

                assert lo + nPackets <= old(count);
                assert 0 <= lo <= old(count);
                assert forall j :: 0 <= j < nPackets ==> result[j] == old(buf[lo+j]);
                assert forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
                assert forall j :: 0 <= j < lo ==> buf[j] < useBy;

                i := 0;
                while (i < nPackets)
                invariant Valid();
                invariant count == old(count) - i;
                invariant 0 <= lo <= old(count) - nPackets <= count;
                invariant buf.Length != 0;
                invariant forall j :: 0 <= j < nPackets ==> result[j] == old(buf[lo+j]);
                invariant forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]);
                invariant forall j :: 0 <= j < lo ==> buf[j] < useBy;
                {
                    var p := popAtIndex(lo);
                    i := i + 1;
                }
                assert countGEend(buf[..old(count)],useBy) >= nPackets ==> count == old(count) - nPackets;
                assert countGEend(buf[..old(count)],useBy) >= nPackets ==> (forall j :: 0 <= j < nPackets ==> result[j] == old(buf[lo+j]));
                assert countGEend(buf[..old(count)],useBy) >= nPackets ==> (forall j :: 0 <= j < lo ==> buf[j] == old(buf[j]));
                assert countGEend(buf[..old(count)],useBy) >= nPackets ==> (forall j :: 0 <= j < lo ==> buf[j] < useBy);
            } else {
                assert found < nPackets;
                assert lo + found == count;
                assert buf[..count] == buf[..lo] + buf[lo..count];
                assert countGEend(buf[lo..count],useBy) == found;
                assert countGEend(buf[..lo],useBy) == 0;
                distcountGEend(buf[..lo],buf[lo..count],useBy);
                assert countGEend(buf[..count],useBy) == found < nPackets;
                result := new int[0];
            }
        }
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

    method cleanUp(currDay: int, buffer: int) returns (trashIDs: array<int>) 
    modifies this.buf, this`count;
    requires Valid();
    requires currDay >= 0 && buffer >= 0;
    ensures Valid();
    ensures Sorted(buf, 0, count); // Yes this is already in Valid, no I don't know why i need to repeat it
    ensures trashIDs != null;
    ensures forall i :: 0 <= i < trashIDs.Length ==> trashIDs[i] <= currDay;
    ensures forall i :: 0 <= i < count ==> buf[i] > currDay;
    ensures trashIDs.Length + count == old(count);
    ensures old(buf[..old(count)]) == trashIDs[..] + buf[0..count];
    {
        var cutoff := 0;
        while (cutoff < count && buf[cutoff] <= currDay)
        decreases buf.Length - cutoff;
        invariant Valid();
        invariant count == old(count);
        invariant buf.Length == old(buf).Length;
        invariant buf.Length == old(buf.Length);
        invariant 0 <= cutoff <= count <= buf.Length;
        invariant forall j :: 0 <= j < cutoff ==> buf[j] <= currDay;
        invariant old(buf[..count]) == buf[..count];
        {
            // p = buf[cutoff]
            // p.setStatus(2)
            // p.sendTo("dump")
            cutoff := cutoff + 1;
        }

        assert old(buf[..cutoff]) == buf[..cutoff];
        assert cutoff <= old(buf.Length);

        var i := 0;
        while (i < count && buf[i] <= currDay + buffer) 
        decreases buf.Length - i;
        invariant Valid();
        invariant count == old(count);
        invariant buf.Length == old(buf).Length;
        invariant buf.Length == old(buf.Length);
        invariant forall j :: 0 <= j < cutoff ==> buf[j] <= currDay;
        invariant forall j :: cutoff <= j < count ==> buf[j] > currDay;
        invariant old(buf[..count]) == buf[..count];
        {
            // buf[i].setStatus();
            i := i + 1;
        }

        assert Sorted(buf,cutoff,count);

        trashIDs := new int[cutoff];
        i := 0;
        while (i < cutoff)
        decreases cutoff - i;
        invariant 0 <= i <= cutoff;
        invariant count == old(count);
        invariant Valid();
        invariant buf.Length == old(buf).Length;
        invariant buf.Length == old(buf.Length);
        invariant forall j :: 0 <= j < i ==> trashIDs[j] == buf[j];
        invariant forall j :: 0 <= j < cutoff ==> buf[j] <= currDay;
        invariant forall j :: cutoff <= j < count ==> buf[j] > currDay;
        invariant old(buf[..count]) == buf[..count];
        {
            trashIDs[i] := buf[i];
            i := i + 1;
        }

        assert Sorted(buf,cutoff,count);

        assert trashIDs[..] == buf[..cutoff];
        assert old(buf[..cutoff]) == buf[..cutoff];
        assert trashIDs[..] == old(buf[..cutoff]);
        assert buf[cutoff..count] == old(buf[cutoff..count]);
        assert old(buf[..cutoff]) + buf[cutoff..count] == old(buf[..old(count)]);
        assert trashIDs[..] + buf[cutoff..count] == old(buf[..old(count)]);

        assert (old(count) <= buf.Length);
        assert(count == old(count));
        count := count - cutoff;
        assert(count + cutoff == old(count));
        assert(count + cutoff <= buf.Length);
        assert forall j :: 0 <= j - cutoff < count ==> buf[j] > currDay;

        assert trashIDs[..] == old(buf[..cutoff]);
        assert trashIDs[..] + buf[cutoff..count+cutoff] == old(buf[..old(count)]);
        assert old(buf[..old(count)]) == trashIDs[..] + buf[cutoff..cutoff+count];
        // forall i :: 0 <= i < count ==> buf[i] > currDay;
        assert Sorted(buf,cutoff,count+cutoff);
        assert count + cutoff <= old(buf.Length);

        i := 0;
        while (i < count)
        decreases count - i;
        invariant 0 <= i <= count;
        invariant cutoff <= i + cutoff <= count + cutoff <= buf.Length;
        invariant count + cutoff == old(count);
        invariant forall j :: 0 <= j < cutoff ==> trashIDs[j] <= currDay;
        invariant forall j :: 0 <= j - cutoff < count ==> buf[j] > currDay;
        invariant forall j :: 0 <= j < i ==> buf[j] > currDay;
        invariant count + cutoff == old(count) <= buf.Length;
        invariant forall j :: cutoff + i <= j < cutoff + count ==> buf[j] == old(buf)[j];
        invariant Sorted(buf,cutoff+i,cutoff+count);
        invariant old(buf[..cutoff]) == trashIDs[..];
        invariant old(buf[..old(count)]) == trashIDs[..] + buf[0..i] + buf[cutoff+i..cutoff+count];
        {
            buf[i] := buf[cutoff+i];

            i := i + 1;
        }

        assert forall j :: 0 <= j < count ==> buf[j] > currDay;

        assert (cutoff == trashIDs.Length);
        assert (count + cutoff == old(count));

        assert old(buf[..old(count)]) == trashIDs[..] + buf[0..count];
        
        return trashIDs;
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

// Counts greater than or equal to key 
function CountGE(a: seq<int>, key: int): nat 
decreases |a|;
ensures CountGE(a, key) <= |a|;
{
    if |a| == 0 then 0 else
    (if a[0] >= key then 1 else 0) + CountGE(a[1..], key)
}

lemma DistributiveCountGE(a: seq<int>, b: seq<int>, key: int) 
ensures CountGE(a + b, key) == CountGE(a, key) + CountGE(b, key);
{
    if (a == []) 
    {
        assert a + b == b; 
    }
    else 
    { 
        DistributiveCountGE(a[1..], b, key);
        assert a + b == [a[0]] + (a[1..] + b);
    }
}

// Counts greater than or equal to key 
function countGEend(a: seq<int>, key: int): nat 
decreases |a|;
ensures 0 <= countGEend(a, key) <= |a|;
{
    if |a| == 0 then 0 else
    (if a[|a|-1] >= key then 1 else 0) + countGEend(a[..|a|-1], key)
}

lemma distcountGEend(a: seq<int>, b: seq<int>, key: int)
decreases |b|;
ensures countGEend(a,key) + countGEend(b,key) == countGEend(a+b,key);
{
    if (|b| == 0) {
        assert a + b == a;
    } else {
        distcountGEend(a,b[0..|b|-1],key);
        // assert countGEend(a,key) + countGEend(b[..|b|-1],key) == countGEend(a+b[..|b|-1],key);
        // assert b[..|b|-1] + [b[|b|-1]] == b;
        // assert countGEend(b,key) == countGEend(b[..|b|-1],key) + (if b[|b|-1] >= key then 1 else 0);
        assert a + b[..|b|-1] + [b[|b|-1]] == a + b;
    }
}

lemma inclusiveGE(a: array<int>, lo: int, hi: int, key: int)
requires a != null;
requires 0 <= lo <= hi < a.Length;
requires forall i:: lo <= i < hi ==> a[i] >= key;
requires a[hi] >= key;
ensures forall i:: lo <= i <= hi ==> a[i] >= key;
{

}

predicate allGE(a: array<int>, lo: int, hi: int, key: int)
requires a != null;
reads a;
requires 0 <= lo <= hi <= a.Length;
{
    forall i:: lo <= i < hi ==> a[i] >= key
}


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
