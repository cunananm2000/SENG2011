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
