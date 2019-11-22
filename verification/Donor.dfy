// Time to verify: 0m1.644s
// Corresponds to the donor class in Donor.java
// Abstractions:
//      In practice this would extend a User class. For the
//      purposes of verification however, we simply include the
//      fields and methods of User in this class.
//      Because the class comprises only of getters and setters,
//      we do not need to abstract the Dafny proof in any way.
class Donor
{
    var id: int; 
    var password: string; 
    var firstName: string;
    var lastName: string; 

    predicate Valid()
    reads this; 
    {
        id >= 0
    }

    method Init(id1: int, password1: string, firstName1: string, lastName1: string)
    modifies this; 
    requires id1 >= 0;
    ensures Valid();
    ensures id == id1;
    ensures password == password1;
    ensures firstName == firstName1;
    ensures lastName == lastName1;
    {
        id := id1; 
        password := password1;
        firstName := firstName1; 
        lastName := lastName1;
    }

    method getId() returns (result: int)
    requires Valid(); ensures Valid();
    ensures result == id;
    {
        result := id; 
    }

    method getPassword() returns (result: string) 
    requires Valid(); ensures Valid(); 
    ensures result == password;
    {
        result := password;
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
}