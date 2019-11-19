class NotifFile {
    var buf : array<real>;
    var count : int;

    predicate validNotif(n: real){
        n > 0.0 && 0 <= getDate(n) && 0 <= getPriority(n) <= 2
    }

    predicate notifCmp(n1: real, n2: real)
    requires validNotif(n1) && validNotif(n2)
    {
        getDate(n1) < getDate(n2) || (getDate(n1) == getDate(n2) && getPriority(n1) <= getPriority(n2))
    }

    predicate sortedNotifs(lo: int, hi: int, a: array<real>)
    requires a != null;
    reads this;
    reads a;
    {
        forall i,j :: 0 <= lo <= i < j < hi <= a.Length ==> (
            validNotif(a[i]) && 
            validNotif(a[j]) && 
            notifCmp(a[i],a[j])
        )
    }

    predicate Valid()
    reads this;
    reads this.buf;
    {
        // I can't just write 0 <= count <= buf.Length, because the buffer can't be 0 length
        buf != null &&
        0 < buf.Length && 
        count <= buf.Length && 
        0 <= count &&
        forall i :: 0 <= i < count ==> validNotif(buf[i]) &&
        sortedNotifs(0,count,buf)
    }

    constructor(size: int)
	requires size > 0
	modifies this;
	modifies this`count;
	ensures Valid();
	ensures count == 0;
	ensures buf.Length == size;
    ensures fresh(buf);
	{
		buf := new real[size];
		count := 0;
	}

	method pop() returns (el : real)
	requires Valid();
	modifies this`count;
	modifies this.buf;
    ensures Valid();
    ensures buf.Length == old(buf.Length);
	ensures old(count) == 0 ==> el == -1.0;
	ensures old(count) > 0 ==> el == old(buf[0]);
    ensures old(count) > 0 ==> count == old(count) - 1;
    ensures old(count) > 0 ==> (forall i :: 0 <= i < count ==> buf[i] == old(buf[i+1]));
	{
		if (count == 0) {
			el := -1.0;
		} else {
			el := buf[0];
			var i := 0;
			while (i < count - 1)
			decreases count - 1 - i;
			invariant count <= buf.Length;
			invariant 0 <= i <= count - 1;
            invariant count == old(count);
            invariant forall j :: 0 <= j < count  ==> validNotif(buf[j]);
            invariant forall j :: 0 <= j < i ==> buf[j] == old(buf[j+1]);
            invariant forall j :: i <= j < count ==> buf[j] == old(buf[j])
            invariant sortedNotifs(0,old(count),old(buf))
			{
                assert notifCmp(old(buf[i]),old(buf[i+1]));
				buf[i] := buf[i+1];
                i := i + 1;
			}

            count := count - 1;
		}
	}

    function method getDate(n: real): int
    requires n > 0.0;
    {
        n.Trunc
    }

    function method getPriority(n: real): int
    requires n > 0.0;
    {
        (10.0*n).Trunc - 10*n.Trunc
    }

    method push(el: real)
    modifies this`count;
	modifies this.buf;
    requires Valid();
    requires validNotif(el);
    ensures Valid();
    ensures buf.Length == old(buf.Length);
    ensures old(count) < buf.Length ==> count == old(count) + 1;
    ensures old(count) == buf.Length ==> count == old(count);
    ensures old(count) < buf.Length ==> exists index :: 0 <= index < count && (
            (forall j :: 0 <= j < index ==> buf[j] == old(buf[j])) &&
            buf[index] == el &&
            (forall j :: index < j < count ==> buf[j] == old(buf[j-1]))
    );
    ensures old(count) == buf.Length ==> exists index :: 0 <= index < count && (
            (forall j :: 0 <= j < index ==> buf[j] == old(buf[j+1])) &&
            buf[index] == el &&
            (forall j :: index < j < count ==> buf[j] == old(buf[j]))
    );

    {
        if (count == buf.Length) {
            var trash := pop();
            assert count == old(count) - 1;
            assert buf.Length != 0;
            assert forall i :: 0 <= i < count - 1 ==> buf[i] == old(buf[i+1]);
        }
        // assert (count < buf.Length);
        // assert (old(count) < buf.Length ==> count == old(count));
        // assert (old(count) == buf.Length ==> count == old(count) - 1);
        // assert buf.Length == old(buf.Length);
        assert forall i :: 0 <= i < buf.Length ==> buf[i] == old(buf)[i];
        assert old(count) == buf.Length ==> (forall i :: 0 <= i < count  ==> buf[i] == old(buf[i+1]));
        assert old(count) < buf.Length ==> (forall i :: 0 <= i < count  ==> buf[i] == old(buf[i]));

        var index := 0;
        while 
        (index < count && 
            (
                getDate(buf[index]) < getDate(el) || 
                (
                    getDate(buf[index]) == getDate(el) && 
                    getPriority(buf[index]) <= getPriority(el)
                )
            )
        )
        decreases count - index;
        invariant 0 <= index <= count;
        invariant sortedNotifs(0,count,buf);
        invariant forall j :: 0 <= j < count ==> validNotif(buf[j]);
        invariant forall j :: 0 <= j < index ==> notifCmp(buf[j],el);
        invariant old(count) == buf.Length ==> (forall i :: 0 <= i < count ==> buf[i] == old(buf[i+1]));
        invariant old(count) < buf.Length ==> (forall i :: 0 <= i < count ==> buf[i] == old(buf[i]));
        {
            index := index + 1;
        }
        assert forall j :: 0 <= j < index ==> notifCmp(buf[j],el);
        assert forall j :: 0 <= j < count ==> validNotif(buf[j]);
        assert 0 <= index <= count < buf.Length;
        assert index < count ==> validNotif(buf[index]);
        assert forall j :: index <= j < count ==> !notifCmp(buf[j],el);
        // assert old(count) == buf.Length ==> (forall i :: 0 <= i < count  ==> buf[i] == old(buf[i+1]));
        // assert old(count) < buf.Length ==> (forall i :: 0 <= i < count  ==> buf[i] == old(buf[i]));

        var i := count;
        while (i > index)
        decreases i - index;
        invariant count <= buf.Length;
        invariant index <= i <= count;
        invariant buf.Length == old(buf.Length);
        invariant old(count) < buf.Length ==> count == old(count);
        invariant old(count) == buf.Length ==> count == old(count) - 1;
        invariant old(count) < buf.Length ==> (forall j :: 0 <= j < i ==> buf[j] == old(buf[j]));
        invariant old(count) == buf.Length ==> (forall j :: 0 <= j < i ==> buf[j] == old(buf[j+1]));
        invariant old(count) < buf.Length ==> (forall j :: i < j <= count ==> buf[j] == old(buf[j-1]));
        invariant old(count) == buf.Length ==> (forall j :: i < j <= count ==> buf[j] == old(buf[j]));
        invariant forall j :: 0 <= j < index ==> notifCmp(buf[j],el);
        {
            buf[i] := buf[i-1];
            i := i - 1;
        }

        // assert old(count) < buf.Length ==> (forall j :: index < j <= count ==> buf[j] == old(buf[j-1]));
        // assert old(count) == buf.Length ==> (forall j :: index < j <= count ==> buf[j] == old(buf[j]));

        count := count + 1;
        buf[index] := el;

        // assert old(count) < buf.Length ==> (forall j :: 0 <= j < index ==> buf[j] == old(buf[j]));
        // assert old(count) == buf.Length ==> (forall j :: 0 <= j < index ==> buf[j] == old(buf[j+1]));

        // assert old(count) < buf.Length ==> (forall j :: index < j < count ==> buf[j] == old(buf[j-1]));
        // assert old(count) == buf.Length ==> (forall j :: index < j < count ==> buf[j] == old(buf[j]));

        // assert old(count) < buf.Length ==> (
        //     (forall j :: 0 <= j < index ==> buf[j] == old(buf[j])) &&
        //     buf[index] == el &&
        //     (forall j :: index < j < count ==> buf[j] == old(buf[j-1]))
        // );

        // assert old(count) == buf.Length ==> (
        //     (forall j :: 0 <= j < index ==> buf[j] == old(buf[j+1])) &&
        //     buf[index] == el &&
        //     (forall j :: index < j < count ==> buf[j] == old(buf[j]))
        // );

        // assert 0 < buf.Length && count <= buf.Length && 0 <= count;
        // assert forall j :: 0 <= j < count ==> validNotif(buf[j]);
        // assert forall j :: 0 <= j < index ==> notifCmp(buf[j],el);
        // assert sortedNotifs(0,index,buf);
        // assert buf[index] == el;
        // assert sortedNotifs(index+1,count,buf);

        // assert sortedNotifs(0,count,buf);
    }

    method getNotifs() returns (r : array<real>)
    ensures r == buf;
    {
		r := buf;
	}
}