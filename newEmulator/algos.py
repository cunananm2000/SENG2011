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
    if (i == len(a)):
        a.append(obj)
    else:
        a.insert(i,obj)