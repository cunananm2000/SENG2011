method Test(a:array<int>, low:nat, high:nat)
requires a != null
requires low<high<a.Length
{
	var mid := low + (high-low)/2;
	//assert a[low..mid]+a[mid..high] == a[low..high];
	//assert multiset(a[low..mid]+a[mid..high]) == multiset(a[low..high]);
	assert forall i:nat :: low<i<high<a.Length ==> a[..i] + a[i..] == a[..];
	assert forall i:nat :: low<i<high<a.Length ==> a[low..i] + a[i..high] == a[low..high];

	assert multiset(a[low..mid]) + multiset(a[mid..high]) == multiset(a[low..high]);
}


method TestR(a:array<int>, low:nat, high:nat)
decreases a, high - low
modifies a
requires a != null
requires low<high<a.Length
ensures multiset(old(a[low..high])) == multiset(a[low..high])
ensures old(a[low..high]) == a[low..high]
ensures old(a[..low]) == a[..low] && old(a[high..]) == a[high..]
{

	var mid := low + (high-low)/2;
	//assert multiset(a[low..mid]) + multiset(a[mid..high]) == multiset(a[low..high]);

	if (high-low > 0){
		
		assert mid - low < high - low;
		if (low < mid){
			TestR(a, low, mid);
		}
		assert multiset(old(a[low..mid])+old(a[mid..high])) == multiset(a[low..mid]+a[mid..high]);
		assert multiset(old(a[low..high])) == multiset(a[low..high]);
		//assert mid > low;
		//assert high - mid < high - low;
		if (mid > low){
			TestR(a, mid, high);
		}
		assert multiset(old(a[low..mid])+old(a[mid..high])) == multiset(a[low..mid]+a[mid..high]);
		assert multiset(old(a[low..high])) == multiset(a[low..high]);
	}
}

method TestSets(s:seq<int>)
{
	assert multiset(s) <= multiset(s);
	// assert forall i:: 0<=i<=|s| ==> multiset(s[..i])+multiset(s[i..]) == multiset(s[..]);
	assert forall i:nat :: i<=|s| ==> s[..i] + s[i..] == s[..];
	// assert forall i:nat :: i<=|s| ==> multiset(s[..i] + s[i..]) == multiset(s[..]);
	// assert forall i:nat :: i<=|s| ==> multiset(s[..i]) + multiset(s[i..]) == multiset(s[..]);
	// assert exists i:: 0<=i<=|s| && multiset(s[..i]) <= multiset(s[..]);
	assert forall i:nat :: i<=|s| ==> multiset(s[..i]) <= multiset(s[..]);
}

function LexCmp(a:seq<char>, b:seq<char>) : int
decreases a, b
{
	if (|a| == 0 && |b| == 0) then 0
	else if (|a| == 0) then -1
	else if (|b| == 0) then 1
	else if (a[0] < b[0]) then -1
	else if (a[0] > b[0]) then 1 
	else LexCmp(a[1..],b[1..]) 
}

method testLex(a:seq<char>, b:seq<char>)
{
	assert LexCmp(a, b) == 0 ==> LexCmp(b, a) == 0;
	assert LexCmp(a, b) == 1 ==> LexCmp(b, a) == -1;
	assert LexCmp(a, b) ==-1 ==> LexCmp(b ,a) == 1;
}

method Main(){
	assert LexCmp("a", "b") == -1;
	assert LexCmp("apple", "banana")==-1;
	assert LexCmp("aa", "aaa") == -1;
}
