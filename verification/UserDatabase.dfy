class UserDatabase {

    var users: array<int>;
    var passwords: array<string>;
    var count: int;

    /*// since null user is represented by -1, ignore for sort
    predicate Sorted(a: seq<int>)
    {
        forall i,j :: 0 <= i < j < |a| && (a[i] != -1 && a[j] != -1) ==> a[i] <= a[j]
    }*/

    predicate Sorted(lo: int, hi: int, a: seq<int>)
    {
        forall i, j :: 0 <= lo <= i < j < hi <= |a| ==> a[i] <= a[j]
    }

    // assuming list of users is stored in sorted order
    predicate Valid()
        reads this, this.users
    {
        users != null && 
        passwords != null && 
        0 <= count <= users.Length && 
        users.Length == passwords.Length &&
        Sorted(0, count, users[..])
    }

    method Init()
        modifies this, this.users
        ensures Valid()
        ensures fresh(users)
        ensures users.Length == 20
    {
        //var usrs: array<int> := new int[20];
        //var pwds: array<string> := new string[20];
        /*var i := 0;
        while i < usrs.Length
        decreases usrs.Length - i
        invariant 0 <= i <= usrs.Length
        invariant forall j :: 0 <= j < i ==> usrs[j] == -1
        invariant forall j :: 0 <= j < i ==> pwds[j] == ""
        {
            usrs[i] := -1;
            pwds[i] := "";
            i := i + 1;
        }*/
        this.users := new int[20];
        this.passwords := new string[20];
        this.count := 0;
    }

    method search(ID: int) returns (idx: int)
        requires Valid(); ensures Valid()
        ensures idx == -1 || 0 <= idx < count
        ensures idx == -1 <==> !(ID in users[..count])
        ensures (0 <= idx < count) <==> (ID in users[..count] && users[idx] == ID)
    {
        idx := 0;
        while idx < count && users[idx] != ID
        decreases count - idx
        invariant 0 <= idx <= count
        invariant forall i :: 0 <= i < idx ==> users[i] != ID
        {  
            idx := idx + 1;
        }
        if idx == count { idx := -1; }
    }

    method login(ID: int, pass: string) returns (loggedID: int, index: int)
        requires Valid(); ensures Valid()
        ensures loggedID == ID || loggedID == -1
        ensures (0 <= index < count && passwords[index] == pass) ==> (loggedID == ID && users[index] == ID)
        ensures (index == -1 || (0 <= index < count && passwords[index] != pass)) ==> loggedID == -1
    {
        index := search(ID);
        assert index != -1 <==> ID in users[..count];
        if index != -1 && passwords[index] == pass { loggedID := ID; }
        else if index == -1 || passwords[index] != pass { loggedID := -1; }
    }

    method doubleSize()
        modifies this, this.users, this.passwords
        requires Valid(); ensures Valid();
        ensures users.Length == passwords.Length
        ensures users.Length == old(users.Length) * 2
        ensures passwords.Length == old(passwords.Length) * 2
        ensures old(users[..]) <= users[..]
        ensures users[..|old(users[..])|] == old(users[..])
        ensures old(passwords[..]) <= passwords[..]
        ensures passwords[..|old(passwords[..])|] == old(passwords[..])
        ensures count == old(count)
        ensures fresh(users) && fresh(passwords)
    {
        var newSize := users.Length * 2;
        
        var newUsers: seq<int> := [];
        var newPwds: seq<string> := [];
        
        var i := 0;
        while i < users.Length
        decreases users.Length - i
        invariant 0 <= i <= users.Length
        invariant |newUsers| == |newPwds| == i
        invariant Sorted(0, count, newUsers)
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
        invariant Sorted(0, count, newUsers);
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

    method sortedInsert(newUserID: int, newUserPass: string)
    modifies this, this.users, this.passwords, this`count; 
    requires Valid(); ensures Valid();
    requires users.Length > 0; 
    ensures count == old(count) + 1;
    ensures if old(count) == old(users.Length) 
            then fresh(users) && users.Length == 2 * old(users.Length) &&
                 fresh(passwords) && passwords.Length == users.Length 
            else users == old(users) && passwords == old(passwords);
    ensures exists index :: 0 <= index < count && (
            (forall j :: 0 <= j < index ==> users[j] == old(users[j]) && passwords[j] == old(passwords[j])) &&
            users[index] == newUserID && passwords[index] == newUserPass &&
            (forall j :: index < j < count ==> users[j] == old(users[j-1]) && passwords[j] == old(passwords[j-1]))
    );
    {
        if (count == users.Length) 
        {
            doubleSize();
        }
        
        var i: int := 0; 
        while (i < count && users[i] < newUserID) 
        invariant 0 <= i <= count; 
        invariant Sorted(0, count, users[..]);
        invariant LTRange(users, 0, i, newUserID);
        invariant forall k :: 0 <= k < count ==> users[k] == old(users[k]) && passwords[k] == old(passwords[k]);
        {
            i := i + 1; 
        }

        assert 0 <= i <= count < users.Length; 
        assert GERange(users, i, count, newUserID); // Reduces verification time

        var j: int := count - 1; 
        while (j >= i) 
        invariant i - 1 <= j <= count - 1; 
        invariant users != null;
        invariant passwords != null;
        invariant count == old(count); 
        invariant if count == old(users.Length) then fresh(users) else users == old(users);
        invariant if count == old(users.Length) then fresh(passwords) else passwords == old(passwords);
        invariant users.Length == if count == old(users.Length) then 2 * old(users.Length) else old(users.Length);
        invariant passwords.Length == users.Length;
        invariant LTRange(users, 0, i, newUserID);
        invariant forall k :: 0 <= k < j + 1 ==> users[k] == old(users[k]) && passwords[k] == old(passwords[k]);
        invariant forall k :: j + 1 < k <= count ==> users[k] == old(users[k-1]) && passwords[k] == old(passwords[k-1]);
        {
            users[j+1] := users[j];
            passwords[j+1] := passwords[j];
            j := j - 1; 
        }
        count := count + 1; 
        users[i] := newUserID;
        passwords[i] := newUserPass;
    }


    method getUsers() returns (userList: array<int>, passList: array<string>)
        requires Valid(); ensures Valid()
        ensures userList != null
        ensures passList != null
        ensures userList.Length == passList.Length
        ensures userList[..] == users[..] && passList[..] == passwords[..]
    {
        userList := new int[users.Length];
        passList := new string[passwords.Length]; 
        var i := 0;
        while i < users.Length
        decreases users.Length - i
        invariant 0 <= i <= users.Length
        invariant forall j :: 0 <= j < i ==> (userList[j] == users[j] && passList[j] == passwords[j])
        {
            userList[i] := users[i];
            passList[i] := passwords[i];
            i := i + 1;
        }
    }

}

method seqToArrInt(s: seq<int>) returns(a: array<int>)
    ensures a != null
    ensures a.Length == |s|
    ensures forall i :: 0 <= i < |s| ==> a[i] == s[i]
    ensures multiset(a[..]) == multiset(s)
    ensures fresh(a)
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
    ensures fresh(a)
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

function DualRange(a: array<int>, low: int, mid1: int, mid2: int, high: int): seq<int>
    reads a;
    requires a != null;
    requires 0 <= low <= mid1 <= mid2 <= high <= a.Length;
{
    a[low..mid1] + a[mid2..high]
}

predicate LTRange(a: array<int>, low: int, high: int, key: int) 
reads a; 
requires a != null;
requires 0 <= low <= high <= a.Length;
{
    forall j :: low <= j < high ==> a[j] < key
}

predicate GERange(a: array<int>, low: int, high: int, key: int)
reads a;
requires a != null;
requires 0 <= low <= high <= a.Length;
{
    forall j :: low <= j < high ==> a[j] >= key
}