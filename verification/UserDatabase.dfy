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

    // since null user is represented by -1, ignore for sort
    predicate Sorted(a: seq<int>)
    {
        forall i,j :: 0 <= i < j < |a| && (a[i] != -1 && a[j] != -1) ==> a[i] <= a[j]
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
        requires Valid(); ensures Valid()
        requires users.Length == passwords.Length
        ensures users.Length == passwords.Length
        ensures users.Length == old(users.Length) * 2
        ensures passwords.Length == old(passwords.Length) * 2
        ensures old(users[..]) <= users[..]
        ensures users[..|old(users[..])|] == old(users[..])
        ensures old(passwords[..]) <= passwords[..]
        ensures passwords[..|old(passwords[..])|] == old(passwords[..])
    {
        var newSize := users.Length * 2;
        
        var newUsers: seq<int> := [];
        var newPwds: seq<string> := [];
        
        var i := 0;
        while i < users.Length
        decreases users.Length - i
        invariant 0 <= i <= users.Length
        invariant |newUsers| == |newPwds| == i
        invariant Sorted(newUsers)
        invariant forall j :: 0 <= j < i ==> (newUsers[j] == users[j] && newPwds[j] == passwords[j])
        {
            newUsers := newUsers + [users[i]];
            newPwds := newPwds + [passwords[i]];
            i := i + 1;
        }

        i := 0;
        while i < newSize
        decreases newSize - i
        invariant 0 <= i <= newSize
        invariant (i < users.Length) ==> (|newUsers| == |newPwds| == users.Length)
        invariant (i >= users.Length) ==> (|newUsers| == |newPwds| == users.Length + (i - users.Length))
        invariant users[..] <= newUsers
        invariant passwords[..] <= newPwds
        invariant Sorted(newUsers);
        invariant (i < users.Length) ==> forall j :: 0 <= j < i ==> (newUsers[j] == users[j] && newPwds[j] == passwords[j])
        invariant (i >= users.Length) ==> forall j :: users.Length <= j < i ==> (newUsers[j] == -1 && newPwds[j] == "");
        {
            if (i >= users.Length) {
                newUsers := newUsers + [-1];
                newPwds := newPwds + [""];
            }
            i := i + 1;
        }
        
        var newUsersArr := seqToArrInt(newUsers);
        var newPwdsArr := seqToArrStr(newPwds);

        users := newUsersArr;
        passwords := newPwdsArr;

    }

}

method seqToArrInt(s: seq<int>) returns(a: array<int>)
    ensures a != null
    ensures a.Length == |s|
    ensures forall i :: 0 <= i < |s| ==> a[i] == s[i]
    ensures multiset(a[..]) == multiset(s)
{
    a := new int[|s|];
    var i := 0;
    while i < |s|
    decreases |s| - i
    invariant 0 <= i <= |s|
    invariant forall j :: 0 <= j < i ==> a[j] == s[j]
    {
        a[i] := s[i];
        i := i + 1;
    }
    assert a[..] == s;
}

method seqToArrStr(s: seq<string>) returns(a: array<string>)
    ensures a != null
    ensures a.Length == |s|
    ensures forall i :: 0 <= i < |s| ==> a[i] == s[i]
    ensures multiset(a[..]) == multiset(s)
{
    a := new string[|s|];
    var i := 0;
    while i < |s|
    decreases |s| - i
    invariant 0 <= i <= |s|
    invariant forall j :: 0 <= j < i ==> a[j] == s[j]
    {
        a[i] := s[i];
        i := i + 1;
    }
    assert a[..] == s;
}
