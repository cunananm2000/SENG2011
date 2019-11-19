class User
{
    var id: int; 
    var password: string; 

    predicate Valid()
    reads this; 
    {
        id >= 0
    }
    
    method Init(id1: int, password1: string)
    modifies this; 
    requires id1 >= 0;
    ensures Valid();
    ensures id == id1;
    ensures password == password1;
    {
        id := id1; 
        password := password1;
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
}