// Time to verify:
// Corresponds to the blood packet class in BloodPacket.java
// Abstractions:
//      Because the class comprises only of getters and setters,
//      we do not need to abstract the Dafny proof in any way.
class BloodPacket
{
    var id: int; 
    var bloodType: int; // Blood type as ints
    var donateLoc: string;
    var donateDate: int; // Dates represented as int
    var expiryDate: int; // Dates represented as int
    var donorID: int; 
    var firstName: string; 
    var lastName: string; 
    var status: int;  // 'Clean' etc. as ints
    var currLoc: string;

    predicate Valid() 
    reads this;
    {
        id >= 0 && 
        donateDate <= expiryDate &&
        donorID >= 0 
    }

    method Init(id1: int, bloodType1: int, donateLoc1: string, 
                donateDate1: int, expiryDate1: int, donorID1: int,
                firstName1: string, lastName1: string)
    modifies this;
    requires id1 >= 0;
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
    ensures status == 0; // Assuming blood packets we get are clean
    ensures currLoc == "warehouse"; // Assumed blood packets are directly added to Vampire's warehouse
    {
        id := id1; 
        bloodType := bloodType1; 
        donateLoc := donateLoc1; 
        donateDate := donateDate1; 
        expiryDate := expiryDate1; 
        donorID := donorID1; 
        firstName := firstName1; 
        lastName := lastName1;
        status := 0; 
        currLoc := "warehouse";
    }

    method getID() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == id; 
    {
        result := id; 
    }

    method getBloodType() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == bloodType; 
    {
        result := bloodType; 
    }

    method getDonateLoc() returns (result: string)
    requires Valid(); ensures Valid();
    ensures result == donateLoc; 
    {
        result := donateLoc; 
    }

    method getDonateDate() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == donateDate; 
    {
        result := donateDate; 
    }

    method getExpiryDate() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == expiryDate; 
    {
        result := expiryDate; 
    }

    method getDonorID() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == donorID; 
    {
        result := donorID; 
    }

    method getFirstName() returns (result: string)
    requires Valid(); ensures Valid();
    ensures result == firstName; 
    {
        result := firstName; 
    }

    method getLastName() returns (result: string)
    requires Valid(); ensures Valid();
    ensures result == lastName; 
    {
        result := lastName; 
    }

    method getStatus() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == status; 
    {
        result := status; 
    }

    method getCurrLoc() returns (result: string)
    requires Valid(); ensures Valid();
    ensures result == currLoc; 
    {
        result := currLoc; 
    }

    method setStatus(status1: int) 
    modifies this`status; 
    requires Valid(); ensures Valid(); 
    ensures status == status1;
    {
        status := status1;
    }

    method sendTo(dest: string)  
    modifies this`currLoc; 
    requires Valid(); ensures Valid();
    ensures currLoc == dest; 
    {
        currLoc := dest; 
    }
}