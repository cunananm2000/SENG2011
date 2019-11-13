def simpleLinearSearch(a, key):
    i = 0
    while (i < len(a) and a[i] != key):
        i = i + 1
    if (i == len(a)):
        i = -1
    return i

def objectLinearSearch(a, field, key):
    i = 0
    while (i < len(a) and a[i].getField(field) != key):
        i = i + 1
    if (i == len(a)):
        return None
    return a[i]

def objectBubbleSort(a,field):
    if (len(a) <= 1):
        return
    
    i = len(a) - 1
    while (i > 0):
        j = 0
        while (j < i):
            if (a[j].getField(field) > a[j+1].getField(field)):
                a[j],a[j+1] = a[j+1],a[j]
            j = j + 1
        i = i - 1

def objectSortedInsert(a,field,obj):
    i = 0
    while(i < len(a) and a[i].getField(field) < obj.getField(field)):
        i += 1
    a.insert(i,obj)

def notifSortedInsert(a,obj):
    i = 0
    while(i < len(a) and (a[i].getDate() < obj.getDate() or (a[i].getDate() == obj.getDate() and a[i].getPriority() >= obj.getPriority()))):
        i += 1
    a.insert(i,obj)

# Returns a sorted list using given comparator, doesn't change original list
# NOTE python has recursive limit that can be changed
def mergeSorted(a, cmp):
    if len(a) > 1:
        mid = len(a)//2
        l = mergeSorted(a[:mid], cmp)
        r = mergeSorted(a[mid:], cmp)
        m = _merge(l,r, cmp)
    else:
        m = a.copy() 
    return m

# Sorts a given list using given comparator, modifies list
# Wrapper function for _mergeSortArray
def mergeSort(a, cmp):
    _mergeSortArray(a, 0, len(a), cmp)

# Sorts a list using comparator within the given indices
def _mergeSortArray(a, low, high, cmp):
    mid = low + (high-low)//2
    if len(a) > 1 and low < mid:
        _mergeSortArray(a, low, mid, cmp)
        _mergeSortArray(a, mid, high, cmp)
        _mergeSubarrays(a, low, mid, high, cmp)

# Takes 2 sorted lists and returns a merged list
def _merge(left, right, cmp):
    # Make copies of l and r and treat them as queues
    l = left.copy()     
    r = right.copy()
    m = []

    # While there are items in either list
    while len(l) > 0 or len(r) > 0:
        # If there is items in both list, compare them and append the smaller one
        if len(l) > 0 and len(r) > 0:
            if (cmp(l[0], r[0])):
                m.append(l.pop(0))
            else:
                m.append(r.pop(0))
        # Else append from whichever list has items remaining
        elif len(l) > 0:
            m.append(l.pop(0))
        else:
            m.append(r.pop(0))
    return m

# Merges to subarrays in a given by indices using given comparator
def _mergeSubarrays(a, low, mid, high, cmp):
    m = _merge(a[low:mid], a[mid:high], cmp)
    a[low:high] = m[:]

# Xand needed to accomadate comparators which return true upon equivalence (=), and those which don't
def xand(a,b,cmp):
    return (cmp(a,b) and cmp(b,a)) or (not cmp(a,b) and not cmp(b,a))

# Returns index of object matching key using given comparator
# Assumes that list is already ordered by given cmp
# Returns index of first it finds, not first in list
def binarySearch(a, key, cmp):
    low, high = 0, len(a)
    while low < high:
        mid = (low+high)//2
        if xand(a[mid], key, cmp):       # Found key
            return mid
        elif cmp(key, a[mid]):  # Check bottom half
            high = mid
        elif cmp(a[mid], key):  # Check top half
            low = mid + 1
    return -1   # Couldn't find key

# Wrapper for above which returns object instead, or None if key not found
def objectBinarySearch(a, key, cmp):
    i = binarySearch(a, key, cmp)
    if i == -1:
        return None
    return a[i]