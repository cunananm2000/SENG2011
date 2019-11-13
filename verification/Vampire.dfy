// class Vampire
// {
    
// }




// class PacketPile 
// {
//     var buf: array<>;
//     var count: int; 
//     var low: int; 

//     predicate Valid() 
//     reads this; 
//     {
//         true
//     }

//     method Init(n: int, l: int) 
//     modifies this 
//     requires n >= 0;
//     ensures Valid();
//     {
//         buf = new 
//     }
// }

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
    ensures status == 2; 
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