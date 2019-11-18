predicate inList(a: seq<string>, key: string)
{
    exists i :: 0 <= i < |a| && a[i] == key
}

method findWord(a: array<string>, key: string) returns (idx: int)
    requires a != null
    ensures idx == -1 || 0 <= idx < a.Length
    ensures idx == -1 <==> !inList(a[..], key)
    ensures (0 <= idx < a.Length) <==> (inList(a[..], key) && a[idx] == key)
{
    idx := 0;
    while idx < a.Length && !(|a[idx][..]| == |key| && a[idx][..] == key)
    decreases a.Length - idx
    invariant 0 <= idx <= a.Length
    invariant forall i :: 0 <= i < idx ==> !(|a[i][..]| == |key| && a[i][..] == key)
    {  
        idx := idx + 1;
    }
    if idx == a.Length { idx := -1; }
}

method Test() {
    var s1: string := "abc";
    var s2: string := "def";
    var s3: string := "ghi";

    var a: array<string> := new string[3];
    a[0], a[1], a[2] := s1, s2, s3;

    assert a[0] == s1;
    assert a[1] == s2;
    assert a[2] == s3;

    var key: string := "abc";
    var idx := findWord(a, key);
    assert 0 <= idx < a.Length && a[idx] == key;

    key := "xyz";
    idx := findWord(a, key);
    assert key[0] == 'x' && key[1] == 'y' && key[2] == 'z';
    assert idx == -1;
}
