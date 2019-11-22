// Time to verify: 5.432s
// Corresponds to the UserDatabase class in UserDatabase.java
// Abstractions:
//      In implementation, the userDatabase would hold a buffer of User
//      objects. However for the purposes of verification, we simply
//      keep a list of user ID's and password strings. From this, we simply
//      replace every instance of buf[i].getID and buf[i].getPassword()
//      with users[id] and passwords[i]. Otherwise, the code proven below
//      is identical to the implemented code. Thus this proof is sufficient.
class UserDatabase {

    var users: array<int>;
    var passwords: array<string>;
    var count: int;

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
        ensures fresh(users) && fresh(passwords)
        ensures users.Length == passwords.Length == 20
    {
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

    method binarySearch(key: int) returns (r: int)
        requires Valid(); ensures Valid()
        ensures r == -1 || 0 <= r < count
        ensures r == -1 <==> !(key in users[..count])
        ensures (0 <= r < count) <==> (key in users[..count] && users[r] == key)
    {
        var low, high := 0, count;	// Setting range
        // Keep on looking while there are items within bounds
        while (low < high)
        decreases high-low
        invariant 0<=low<=high<=count
        invariant key !in users[..low] && key !in users[high..count]
        {
            // Finding midpoint 
            var mid := (low+high)/2;
            if (key == users[mid]){							
                r := mid;
                return;
            } 
            else if (key < users[mid]){		// Key must be in lower half
                high := mid;
            } else if (key > users[mid]){	// Key must be in upper half
                low := mid + 1;
            } 
        }
        r := -1;	// Couldn't find key
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
        modifies this, this`users, this`passwords
        requires Valid(); ensures Valid();
        ensures users.Length == passwords.Length
        ensures users.Length == old(users.Length) * 2
        ensures passwords.Length == old(passwords.Length) * 2
        ensures old(users[..count]) <= users[..count]
        ensures users[..count] == old(users[..count])
        ensures old(passwords[..count]) <= passwords[..count]
        ensures passwords[..count] == old(passwords[..count])
        ensures count == old(count)
        ensures fresh(users) && fresh(passwords)
    {
        var currSize := users.Length;
        var newSize := users.Length * 2;
        
        var newUsers: array<int> := new int[newSize];
        var newPwds: array<string> := new string[newSize];

        var i := 0;

        while i < count
            invariant 0 <= i <= count;
            invariant count == old(count)
            invariant users == old(users)
            invariant passwords == old(passwords)
            invariant newUsers[..i] == users[..i] && newPwds[..i] == passwords[..i]
            invariant users[..count] == old(users[..count]) && passwords[..count] == old(passwords[..count])
        {
            newUsers[i] := users[i]; 
            newPwds[i] := passwords[i];
            i := i + 1;
        }

        users := newUsers;
        passwords := newPwds;
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
