// class Vampire
// {
    
// }




class PacketPile 
{
    var buf: array<BloodPacket>;
    var count: int; 
    var low: int; 

    // ghost var shadow: seq<BloodPacket>; 

    predicate Valid()
    reads this, this.buf; 
    { 
        buf != null && 
        0 <= count <= buf.Length && 
        forall i :: (0 <= i < count ==> buf[i] != null) &&
        0 <= low <= buf.Length
        // shadow == buf[..count]
    }

    method Init(n: int, low1: int) 
    modifies this 
    requires n >= 0;
    requires 0 <= low1 <= n;
    ensures Valid();
    ensures fresh(buf);
    ensures buf.Length == n; 
    ensures count == 0; 
    ensures low == low1;
    {
        buf := new BloodPacket[n];
        // shadow := [];
        count := 0; 
        low := low1;
    }


    // ensures el == old(shadow)[n];
    // ensures shadow == old(shadow[0..n]) + old(shadow[n+1..]);
    // ensures |shadow| == |old(shadow)| - 1;

    // method Pop(n: int) returns (el: BloodPacket)
    // modifies this, this.buf; 
    // requires Valid(); ensures Valid(); 
    // requires count > 0;
    // requires 0 <= n < count; 
    // ensures el == old(buf)[n];
    // ensures old(buf)[..old(count)] == buf[..n] + [el] + buf[n..count];
    // ensures count == old(count) - 1;
    // {
    //     el := buf[n]; 
    //     var i: int := n; 

    //     while (i < count - 1) 
    //     invariant n <= i <= count - 1; 
    //     invariant old(buf)[..old(count)] == buf[..n] + [el] + buf[n..i] + buf[(i+1)..count]
    //     {
    //         buf[i] := buf[i + 1];
    //         i := i + 1;
    //     }
    //     count := count - 1; 
    // }
}

class BloodPacket
{
    var id: int; 
    var bloodType: int; // idk type
    var donateLoc: string;
    var donateDate: int; // Dates represented as int
    var expiryDate: int; // Dates represented as int
    var donorID: int; 
    var firstName: string; // aren't these querable?
    var lastName: string; 
    var status: int; 
    var currLoc: string;

    predicate Valid() 
    reads this;
    {
        id >= 0 &&
        0 <= bloodType < 8 && 
        donateDate <= expiryDate &&
        donorID >= 0 && 
        0 <= status < 3
    }

    method Init(id1: int, bloodType1: int, donateLoc1: string, 
                donateDate1: int, expiryDate1: int, donorID1: int,
                firstName1: string, lastName1: string)
    modifies this;
    requires id1 >= 0;
    requires 0 <= bloodType1 < 8;
    requires donateDate1 <= expiryDate1;
    requires donorID1 >= 0;
    ensures Valid(); 
    ensures id == id1; 
    ensures bloodType == bloodType1;
    ensures donateLoc == donateLoc1;
    ensures donateDate == donateDate1;
    ensures expiryDate == expiryDate1;
    ensures donorID == donorID1;
    ensures firstName == firstName1;
    ensures lastName == lastName1; 
    ensures status == 2; // Assuming blood packets we get are clean
    ensures currLoc == "warehouse";
    {
        id := id1; 
        bloodType := bloodType1; 
        donateLoc := donateLoc1; 
        donateDate := donateDate1; 
        expiryDate := expiryDate1; 
        donorID := donorID1; 
        firstName := firstName1; 
        lastName := lastName1;
        status := 2; 
        currLoc := "warehouse";
    }

    // SKIPPED GETTERS

    method sendTo(dest: string)  
    modifies this`currLoc; 
    requires Valid(); ensures Valid();
    ensures currLoc == dest; 
    {
        currLoc := dest; 
    }

    method setStatus(status1: int) 
    modifies this`status; 
    requires Valid(); ensures Valid(); 
    requires 0 <= status1 < 3; 
    ensures status == status1; 
    {
        status := status1;
    }
}