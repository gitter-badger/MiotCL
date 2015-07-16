//
//  fp4.swift
//  miot2
//
//  Created by Michael Scott on 07/07/2015.
//  Copyright (c) 2015 Michael Scott. All rights reserved.
//

/* Finite Field arithmetic  Fp^4 functions */

/* FP4 elements are of the form a+ib, where i is sqrt(-1+sqrt(-1))  */

final class FP4 {
    private final var a:FP2
    private final var b:FP2

    /* constructors */
    init(_ c:Int32)
    {
        a=FP2(c)
        b=FP2(0)
    }
    
    init(_ x:FP4)
    {
        a=FP2(x.a)
        b=FP2(x.b)
    }
    
    init(_ c:FP2,_ d:FP2)
    {
        a=FP2(c)
        b=FP2(d)
    }
    
    init(_ c:FP2)
    {
        a=FP2(c)
        b=FP2(0)
    }
    /* reduce all components of this mod Modulus */
    func reduce()
    {
        a.reduce()
        b.reduce()
    }
    /* normalise all components of this mod Modulus */
    func norm()
    {
        a.norm()
        b.norm()
    }
    /* test this==0 ? */
    func iszilch() -> Bool
    {
        reduce()
        return a.iszilch() && b.iszilch()
    }
    /* test this==1 ? */
    func isunity() -> Bool
    {
    var one=FP2(1);
    return a.equals(one) && b.iszilch()
    }
    
    /* test is w real? That is in a+ib test b is zero */
    func isreal() -> Bool
    {
        return b.iszilch();
    }
    /* extract real part a */
    func real() -> FP2
    {
        return a;
    }
    
    func geta() -> FP2
    {
        return a;
    }
    /* extract imaginary part b */
    func getb() -> FP2
    {
    return b;
    }
    /* test self=x? */
    func equals(x:FP4) -> Bool
    {
        return a.equals(x.a) && b.equals(x.b)
    }
    /* copy self=x */
    func copy(x:FP4)
    {
        a.copy(x.a)
        b.copy(x.b)
    }
    /* set this=0 */
    func zero()
    {
        a.zero()
        b.zero()
    }
    /* set this=1 */
    func one()
    {
        a.one()
        b.zero()
    }
    /* set self=-self */
    func neg()
    {
        var m=FP2(a)
        var t=FP2(0)
        m.add(b)
        m.neg()
        m.norm()
        t.copy(m); t.add(b)
        b.copy(m)
        b.add(a)
        a.copy(t)
    }
    /* self=conjugate(self) */
    func conj()
    {
        b.neg(); b.norm()
    }
    /* this=-conjugate(this) */
    func nconj()
    {
        a.neg(); a.norm()
    }
    /* self+=x */
    func add(x:FP4)
    {
        a.add(x.a)
        b.add(x.b)
    }
    /* self-=x */
    func sub(x:FP4)
    {
        var m=FP4(x)
        m.neg()
        add(m)
    }
    
    /* self*=s where s is FP2 */
    func pmul(s:FP2)
    {
        a.mul(s)
        b.mul(s)
    }
    /* self*=c where c is int */
    func imul(c:Int32)
    {
        a.imul(c)
        b.imul(c)
    }
    /* self*=self */
    func sqr()
    {
        norm();
    
        var t1=FP2(a)
        var t2=FP2(b)
        var t3=FP2(a)
    
        t3.mul(b)
        t1.add(b)
        t2.mul_ip()
    
        t2.add(a)
        a.copy(t1)
    
        a.mul(t2)
    
        t2.copy(t3)
        t2.mul_ip()
        t2.add(t3)
        t2.neg()
        a.add(t2)
    
        b.copy(t3)
        b.add(t3)
    
        norm()
    }
    /* self*=y */
    func mul(y:FP4)
    {
        norm();
    
        var t1=FP2(a)
        var t2=FP2(b)
        var t3=FP2(0)
        var t4=FP2(b)
    
        t1.mul(y.a)
        t2.mul(y.b)
        t3.copy(y.b)
        t3.add(y.a)
        t4.add(a)
    
        t4.mul(t3)
        t4.sub(t1)
        t4.norm()
    
        b.copy(t4)
        b.sub(t2)
        t2.mul_ip()
        a.copy(t2)
        a.add(t1)
    
        norm()
    }
    /* convert this to hex string */
    func toString() -> String
    {
        return ("["+a.toString()+","+b.toString()+"]")
    }
    
    func toRawString() -> String
    {
        return ("["+a.toRawString()+","+b.toRawString()+"]")
    }
    /* self=1/self */
    func inverse()
    {
        norm();
    
        var t1=FP2(a)
        var t2=FP2(b)
    
        t1.sqr()
        t2.sqr()
        t2.mul_ip()
        t1.sub(t2)
        t1.inverse()
        a.mul(t1)
        t1.neg()
        b.mul(t1)
    }
    
    /* self*=i where i = sqrt(-1+sqrt(-1)) */
    func times_i()
    {
        norm();
        var s=FP2(b)
        var t=FP2(b)
        s.times_i()
        t.add(s)
        t.norm()
        b.copy(a)
        a.copy(t)
    }
    
    /* self=self^p using Frobenius */
    func frob(f:FP2)
    {
        a.conj()
        b.conj()
        b.mul(f)
    }
    /* self=self^e */
    func pow(e:BIG) -> FP4
    {
        norm()
        e.norm()
        var w=FP4(self)
        var z=BIG(e)
        var r=FP4(1)
        while (true)
        {
            var bt=z.parity()
            z.fshr(1)
            if bt==1 {r.mul(w)}
            if z.iszilch() {break}
            w.sqr()
        }
        r.reduce()
        return r
    }
    /* XTR xtr_a function */
    func xtr_A(w:FP4,_ y:FP4,_ z:FP4)
    {
        var r=FP4(w)
        var t=FP4(w)
        r.sub(y)
        r.pmul(a)
        t.add(y)
        t.pmul(b)
        t.times_i()
    
        copy(r)
        add(t)
        add(z)
    
        norm()
    }
    /* XTR xtr_d function */
    func xtr_D()
    {
        var w=FP4(self)
        sqr(); w.conj()
        w.add(w)
        sub(w)
        reduce()
    }
    /* r=x^n using XTR method on traces of FP12s */
    func xtr_pow(n:BIG) -> FP4
    {
        var a=FP4(3)
        var b=FP4(self)
        var c=FP4(b)
        c.xtr_D()
        var t=FP4(0)
        var r=FP4(0)
    
        n.norm();
        var par=n.parity()
        var v=BIG(n); v.fshr(1)
        if par==0 {v.dec(1); v.norm()}
    
        var nb=v.nbits()
        for var i=nb-1;i>=0;i--
        {
            if (v.bit(i) != 1)
            {
				t.copy(b)
				conj()
				c.conj()
				b.xtr_A(a,self,c)
				conj()
				c.copy(t)
				c.xtr_D()
				a.xtr_D()
            }
            else
            {
				t.copy(a); t.conj()
				a.copy(b)
				a.xtr_D()
				b.xtr_A(c,self,t)
				c.xtr_D()
            }
        }
        if par==0 {r.copy(c)}
        else {r.copy(b)}
        r.reduce()
        return r
    }
    
    /* r=ck^a.cl^n using XTR double exponentiation method on traces of FP12s. See Stam thesis. */
    func xtr_pow2(ck:FP4,_ ckml:FP4,_ ckm2l:FP4,_ a:BIG,_ b:BIG) -> FP4
    {
        a.norm(); b.norm()
        var e=BIG(a)
        var d=BIG(b)
        var w=BIG(0)
    
        var cu=FP4(ck)  // can probably be passed in w/o copying
        var cv=FP4(self)
        var cumv=FP4(ckml)
        var cum2v=FP4(ckm2l)
        var r=FP4(0)
        var t=FP4(0)
    
        var f2:Int=0
        while d.parity()==0 && e.parity()==0
        {
            d.fshr(1);
            e.fshr(1);
            f2++;
        }
    
        while (BIG.comp(d,e) != 0)
        {
            if BIG.comp(d,e)>0
            {
				w.copy(e); w.imul(4); w.norm()
				if BIG.comp(d,w)<=0
				{
                    w.copy(d); d.copy(e)
                    e.rsub(w); e.norm()
    
                    t.copy(cv)
                    t.xtr_A(cu,cumv,cum2v)
                    cum2v.copy(cumv)
                    cum2v.conj()
                    cumv.copy(cv)
                    cv.copy(cu)
                    cu.copy(t)
    
				}
				else if d.parity()==0
				{
                    d.fshr(1)
                    r.copy(cum2v); r.conj()
                    t.copy(cumv)
                    t.xtr_A(cu,cv,r)
                    cum2v.copy(cumv)
                    cum2v.xtr_D()
                    cumv.copy(t)
                    cu.xtr_D()
				}
				else if e.parity()==1
				{
                    d.sub(e); d.norm()
                    d.fshr(1)
                    t.copy(cv)
                    t.xtr_A(cu,cumv,cum2v)
                    cu.xtr_D()
                    cum2v.copy(cv)
                    cum2v.xtr_D()
                    cum2v.conj()
                    cv.copy(t)
				}
				else
				{
                    w.copy(d)
                    d.copy(e); d.fshr(1)
                    e.copy(w)
                    t.copy(cumv)
                    t.xtr_D()
                    cumv.copy(cum2v); cumv.conj()
                    cum2v.copy(t); cum2v.conj()
                    t.copy(cv)
                    t.xtr_D()
                    cv.copy(cu)
                    cu.copy(t)
				}
            }
            if BIG.comp(d,e)<0
            {
				w.copy(d); w.imul(4); w.norm()
				if BIG.comp(e,w)<=0
				{
                    e.sub(d); e.norm()
                    t.copy(cv)
                    t.xtr_A(cu,cumv,cum2v)
                    cum2v.copy(cumv)
                    cumv.copy(cu)
                    cu.copy(t)
				}
				else if e.parity()==0
				{
                    w.copy(d)
                    d.copy(e); d.fshr(1)
                    e.copy(w)
                    t.copy(cumv)
                    t.xtr_D()
                    cumv.copy(cum2v); cumv.conj()
                    cum2v.copy(t); cum2v.conj()
                    t.copy(cv)
                    t.xtr_D()
                    cv.copy(cu)
                    cu.copy(t)
				}
				else if d.parity()==1
				{
                    w.copy(e)
                    e.copy(d)
                    w.sub(d); w.norm()
                    d.copy(w); d.fshr(1)
                    t.copy(cv)
                    t.xtr_A(cu,cumv,cum2v)
                    cumv.conj()
                    cum2v.copy(cu)
                    cum2v.xtr_D()
                    cum2v.conj()
                    cu.copy(cv)
                    cu.xtr_D()
                    cv.copy(t)
				}
				else
				{
                    d.fshr(1)
                    r.copy(cum2v); r.conj()
                    t.copy(cumv)
                    t.xtr_A(cu,cv,r)
                    cum2v.copy(cumv)
                    cum2v.xtr_D()
                    cumv.copy(t)
                    cu.xtr_D()
				}
            }
        }
        r.copy(cv)
        r.xtr_A(cu,cumv,cum2v)
        for var i=0;i<f2;i++
            {r.xtr_D()}
        r=r.xtr_pow(d)
        return r
    }
    
}