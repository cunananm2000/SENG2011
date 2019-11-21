predicate inList(a: seq<seq<char>>, key: seq<char>)
{
    exists j :: 0 <= j < |a| && |a[j]| == |key| && a[j] == key
}

method findWord(a: array<seq<char>>, key: seq<char>) returns (idx: int)
    requires a != null
    ensures idx == -1 || 0 <= idx < a.Length
    ensures idx == -1 <==> !inList(a[..], key);
    ensures (0 <= idx < a.Length) <==> (inList(a[..], key) && a[idx] == key)
{
    idx := 0;
    while idx < a.Length && !(|a[idx][..]| == |key| && a[idx][..] == key)
    invariant 0 <= idx <= a.Length
    invariant forall i :: 0 <= i < idx ==> !(|a[i][..]| == |key| && a[i][..] == key)
    {  
        idx := idx + 1;
    }
    if idx == a.Length { idx := -1; }
}

method Test() {
    var s1: seq<char> := ['a', 'b', 'c'];
    var s2: seq<char> := ['d', 'e', 'f'];
    var s3: seq<char> := ['g', 'h', 'i'];

    var a: array<seq<char>> := new seq<char>[3];
    a[0], a[1], a[2] := s1, s2, s3;

    assert a[0] == s1;
    assert a[1] == s2;
    assert a[2] == s3;

    var key: seq<char> := ['a', 'b', 'c'];
    var idx := findWord(a, key);
    assert 0 <= idx < a.Length && a[idx] == key;

    key := ['x', 'y', 'z'];
    idx := findWord(a, key);
    assert key[0] == 'x' && key[1] == 'y' && key[2] == 'z';
    assert idx == -1;
}
