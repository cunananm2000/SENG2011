method findWord(a: array<seq<char>>, key: seq<char>) returns (idx: int)
    requires a != null
    ensures idx == -1 || 0 <= idx < a.Length
    ensures idx == -1 <==> !(exists j::0<=j<a.Length && |a[j][..]| == |key| && a[j][..] == key)
    ensures (0 <= idx < a.Length) <==> (exists j::0<=j<a.Length && |a[j][..]| == |key| && a[j][..] == key && j == idx)
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

method Main() {
    var list: array<seq<char>> := new seq<char>[3];

    var s1: seq<char> := ['x', 'y', 'z'];
    var s2: seq<char> := ['a', 'b', 'c'];
    var s3: seq<char> := ['d', 'e', 'f'];

    var key: seq<char> := ['a', 'b', 'c'];

    list[0], list[1], list[2] := s1, s2, s3;

    assert list[0][..] == s1;
    assert list[1][..] == s2;
    assert list[2][..] == s3;
    assert key == s2;
    assert list[1][..] == key;

    var idx := findWord(list, key);
    assert 0 <= idx < list.Length ==> list[idx][..] == list[1][..];
}
