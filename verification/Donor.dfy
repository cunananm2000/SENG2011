class PathCentre
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