// Time to verify: 1.572s
// Corresponds to the pathCentre class in PathCentre.java
// Abstractions:
//      In practice this would extend a User class. For the
//      purposes of verification however, we simply include the
//      fields and methods of User in this class.
//      Because the class comprises only of getters and setters,
//      we do not need to abstract the Dafny proof in any way.
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