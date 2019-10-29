method find(a: array<int>, key: int) returns (i: int)
ensures i == -1 || 0 <= i < a.Length
ensures 0 <= i < a.Length ==> a[i] == key && forall j:: 0 <= j < i ==> a[j] != key
ensures i == -1 ==> forall j:: 0 <= j < a.Length ==> a[j] != key
{
  i := 0;
  while(i < a.Length && a[i] != key)
  decreases a.Length - i
  invariant 0 <= i <= a.Length
  invariant forall j:: 0 <= j < i ==> a[j] != key
  {
    i := i + 1;
  }
  if (i == a.Length){
    i := -1;
  }
}