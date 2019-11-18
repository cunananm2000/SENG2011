class User {

    var id: int;
    var password: string;

    // assuming ID has to be > 0 and password cannot be empty
    predicate Valid()
        reads this, this`id, this`password
    {
        id >= 0 && password != ""
    }

    method Init(ID: int, pass: string)
        modifies this, this`id, this`password
        ensures Valid()
        requires ID >= 0
        requires pass != ""
    {
        this.id := ID;
        this.password := pass;
    }

    method getPassword() returns(pass: string)
        //requires Valid(); ensures Valid()
        ensures pass == password
    {
        pass := this.password;
    }
}

class UserDatabase {

    var users: array<int>;
    var passwords: array<string>;
    var count: int;

    predicate Sorted(a: seq<int>)
    {
        forall i,j :: 0 <= i < j < |a| ==> a[i] <= a[j]
    }

    // assuming list of users is stored in sorted order
    predicate Valid()
        reads this, this.users
    {
        users != null && passwords != null && 0 <= count <= users.Length && 
        users.Length == passwords.Length &&
        Sorted(users[..])
    }

    method Init()
        modifies this, this.users
        ensures Valid()
        ensures fresh(users)
        ensures users.Length == 20
    {
        var usrs: array<int> := new int[20];
        var pwds: array<string> := new string[20];
        var i := 0;
        while i < usrs.Length
        decreases usrs.Length - i
        invariant 0 <= i <= usrs.Length
        invariant forall j :: 0 <= j < i ==> usrs[j] == -1
        invariant forall j :: 0 <= j < i ==> pwds[j] == ""
        {
            usrs[i] := -1;
            pwds[i] := "";
            i := i + 1;
        }
        this.users := usrs;
        this.passwords := pwds;
        this.count := 0;
    }

    method search(ID: int) returns (idx: int)
        requires Valid(); ensures Valid()
        ensures idx == -1 || 0 <= idx < users.Length
        ensures idx == -1 <==> !(ID in users[..])
        ensures (0 <= idx < users.Length) <==> (ID in users[..] && users[idx] == ID)
    {
        idx := 0;
        while idx < users.Length && users[idx] != ID
        decreases users.Length - idx
        invariant 0 <= idx <= users.Length
        invariant forall i :: 0 <= i < idx ==> users[i] != ID
        {  
            idx := idx + 1;
        }
        if idx == users.Length { idx := -1; }
    }

    method login(ID: int, pass: string) returns (loggedID: int, index: int)
        requires Valid(); ensures Valid()
        ensures loggedID == ID || loggedID == -1
        ensures (0 <= index < users.Length && passwords[index] == pass) ==> (loggedID == ID && users[index] == ID)
        ensures (index == -1 || (0 <= index < users.Length && passwords[index] != pass)) ==> loggedID == -1
    {
        index := search(ID);
        assert index != -1 <==> ID in users[..];
        if index != -1 && passwords[index] == pass { loggedID := ID; }
        else if index == -1 || passwords[index] != pass { loggedID := -1; }
    }

    method doubleSize()
        modifies this, this.users, this.passwords
        requires Valid(); //ensures Valid()
        requires users.Length == passwords.Length
        //ensures users.Length == passwords.Length
        //ensures users.Length == old(users.Length) * 2
        //ensures passwords.Length == old(passwords.Length) * 2
        //ensures users[..|old(users[..])|] == old(users[..])
        //ensures passwords[..|old(passwords[..])|] == old(passwords[..])
    {
        var newSize := users.Length * 2;
        //var newUsers: array<int> := new int[newSize];
        //var newPwds: array<string> := new string[newSize];
        
        var newUsers: seq<int> := [];
        var newPwds: seq<string> := [];
        
        var i := 0;
        while i < newSize
        decreases newSize - i
        invariant 0 <= i <= newSize
        // Need to fix following loop invariants
        //invariant (i < users.Length) ==> forall j :: 0 <= j < i ==> newUsers[j] == users[j]
        //invariant forall j :: 0 <= j < i ==> newPwds[j] == ""
        {
            //newUsers[i] := -1;
            //newPwds[i] := "";
            if i < users.Length {
                newUsers := newUsers + [users[i]];
                newPwds := newPwds + [passwords[i]];
            } else {
                newUsers := newUsers + [-1];
                newPwds := newPwds + [""];
            }
            i := i + 1;
        }

        /*i := 0;
        while i < users.Length
        decreases users.Length - i
        invariant 0 <= i <= users.Length
        invariant 0 <= i <= passwords.Length
        invariant forall j :: 0 <= j < i ==> users[j] == newUsers[j]
        invariant forall j :: 0 <= j < i ==> passwords[j] == newPwds[j]
        {
            newUsers[i] := users[i];
            newPwds[i] := passwords[i];
            i := i + 1;
        }
        
        users := newUsers;
        passwords := newPwds;
    }*/
    }
}
