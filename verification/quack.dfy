// CODE TAKEN FROM LECTURES!!!
// ONLY FOR REFERENCE
module Quack{
class Quack<Data>  
{    
    var buf: array<Data>;    
    var m: int, n: int; // indexes in buf[]
    ghost var shadow: seq<Data>;
    predicate Valid()
    reads this, this.buf   
    { 
        buf!=null && buf.Length!=0 && 0<=m<=n<=buf.Length && shadow==buf[m..n] 
    }
    constructor(size: int) 
    modifies this
    requires size>0    
    ensures shadow == []    
    ensures fresh(buf)    
    ensures Valid();    
    {   
        buf := new Data[size];        
        m, n, shadow := 0, 0, [];    
    }

    method Empty() 
    returns (x:bool) 
    requires Valid(); 
    ensures Valid() 
    ensures x <==> shadow==[]      // x==true is equiv to an empty shadow 
    {    
        x := m==n;                 // x is true if m and n are the same 
    }
    method Pop() 
    returns(x: Data) 
    modifies this, this`n 
    requires buf!=null && Valid() 
    requires shadow != [] 
    ensures Valid(); 
    ensures x == old(shadow)[|old(shadow)|-1]   // this is the tail element 
    ensures  shadow == old(shadow)[..|old(shadow)|-1] // this is the new shadow 
    ensures |shadow| == |old(shadow)|-1               // decrease the size 
    ensures buf == old(buf)                           // no change to buf here 
    {     
        x, n:= buf[n-1], n-1;                     // get tail, remove from buf     
        shadow:= shadow[..|shadow|-1];            // chop the tail off shadow 
    }

    method Qop() returns(x: Data) modifies this, this`m
    requires buf!=null && Valid()
    requires shadow != [];
    ensures Valid();    
    ensures        
    x == old(shadow[0])   // get head    
    ensures   shadow == old(shadow[1..]) // chop off head    
    ensures |shadow| == |old(shadow)|-1    
    ensures buf == old(buf)              // no change to buf here    
    {        
        x, m:= buf[m], m+1;        
        shadow:= shadow[1..];    
    }

    method Push(x: Data) 
    modifies this, this.buf, this`m, this`n    
    requires buf!=null && Valid();    
    ensures   shadow == old(shadow) + [x]; // new tail    
    ensures |shadow| == |old(shadow)|+1    
    ensures if old(n)==old(buf.Length) then fresh(buf) else buf==old(buf)    
    ensures Valid();    
    {   
        if n==buf.Length       
        {   
            var b:= new Data[buf.Length];               // temporary            
            if m==0 { 
                b:= new Data[2*buf.Length]; 
            }     // double size            
            forall (i | 0<=i<n-m) {
                 b[i]:= buf[m+i]; 
            }  // copy m..n to 0..n-m            
            buf, m, n:= b, 0, n-m;                      // copy b to buf, reset m,n        
        }       
        buf[n], n:= x, n+1;             // now we definitely have room        
        shadow:= shadow + [x];          // shadow never overflows, simply concat 'x'    
    }
} 
}