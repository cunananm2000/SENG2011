class PacketPile
{
    var buf: array<int>; // int represents expiry date 
    var count: int; 
    var low: int; 
    // bloodStatuses 


    predicate Sorted(a: array<int>, low: int, high: int)
    reads a;
    requires a != null;
    requires 0 <= low <= high <= a.Length;  
    {
        forall i, j :: low <= i < j < high ==> a[i] <= a[j]
    }

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
    ensures el == old(buf[index]);
    ensures count == old(count) - 1;
    ensures buf[0..count] == old(buf[0..index]) + old(buf[index+1..old(count)]);
    {
        el := buf[index]; 
        
        var i: int := index; 
        while (i < count - 1)
        invariant index <= i <= count - 1; 
        invariant count == old(count);
        invariant buf == old(buf);
        invariant index == old(index); 
        invariant buf[0..i] + buf[i+1..count] == old(buf[0..index]) + old(buf[index+1..old(count)]);
        invariant Sorted(buf, 0, count)
        {
            buf[i] := buf[i + 1];
            i := i + 1; 
        }
        count := count - 1; 
    }

    // method push(el: int) 
    // modifies this.buf, this`count; 
    // requires Valid(); ensures Valid();
    // {
    //     if (count == buf.Length)
    //     {
    //         var p: int := popAtIndex(0); // Take the oldest away
    //         // Set blood packet to 
    //     }
    // }
}