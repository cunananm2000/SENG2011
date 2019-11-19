class PathCentre
{
    var id: int; 
    var password: string; 
    var name: string;

    predicate Valid()
    reads this; 
    {
        id >= 0
    }

    method Init(id1: int, password1: string, name1: string)
    modifies this; 
    requires id1 >= 0;
    ensures Valid();
    ensures id == id1;
    ensures password == password1;
    ensures name == name1;
    {
        id := id1; 
        password := password1;
        name := name1;
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

    method getName() returns (result: string)
    requires Valid(); ensures Valid();
    ensures result == name; 
    {
        result := name;
    }
}