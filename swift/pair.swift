//
//  pair.swift
//  miot2
//
//  Created by Michael Scott on 07/07/2015.
//  Copyright (c) 2015 Michael Scott. All rights reserved.
//

/* CLINT BN Curve Pairing functions */

final class PAIR {
    
    /* Line function */
    static func line(A:ECP2,_ B:ECP2,_ Qx:FP,_ Qy:FP) -> FP12
    {
        var P=ECP2()
        var a:FP4
        var b:FP4
        var c:FP4
        P.copy(A);
        var ZZ=FP2(P.getz())
        ZZ.sqr();
        var D:Int
        if A===B {D=A.dbl()} /* Check this return value in clint_ec2.c */
        else {D=A.add(B)}
        if (D<0) {return FP12(1)}
        var Z3=FP2(A.getz())
        c=FP4(0)
        if D==0
        { /* Addition */
            var X=FP2(B.getx())
            var Y=FP2(B.gety())
            var T=FP2(P.getz())
            T.mul(Y)
            ZZ.mul(T)
    
            var NY=FP2(P.gety()); NY.neg()
            ZZ.add(NY)
            Z3.pmul(Qy)
            T.mul(P.getx())
            X.mul(NY)
            T.add(X)
            a=FP4(Z3,T)
            ZZ.neg()
            ZZ.pmul(Qx)
            b=FP4(ZZ)
        }
        else
        { /* Doubling */
            var X=FP2(P.getx())
            var Y=FP2(P.gety())
            var T=FP2(P.getx())
            T.sqr()
            T.imul(3)
    
            Y.sqr()
            Y.add(Y)
            Z3.mul(ZZ)
            Z3.pmul(Qy)
    
            X.mul(T)
            X.sub(Y)
            a=FP4(Z3,X)
            T.neg()
            ZZ.mul(T)
            ZZ.pmul(Qx)
            b=FP4(ZZ)
        }
        return FP12(a,b,c)
    }
    /* Optimal R-ate pairing */
    static func ate(P:ECP2,_ Q:ECP) -> FP12
    {
        var f=FP2(BIG(ROM.CURVE_Fra),BIG(ROM.CURVE_Frb))
        var x=BIG(ROM.CURVE_Bnx)
        var n=BIG(x)
        var K=ECP2()
        
        var lv:FP12
        n.pmul(6); n.dec(2); n.norm()
        P.affine()
        Q.affine()
        var Qx=FP(Q.getx())
        var Qy=FP(Q.gety())
    
        var A=ECP2()
        var r=FP12(1)
    
        A.copy(P)
        var nb=n.nbits()
    
        for var i=nb-2;i>=1;i--
        {
            lv=line(A,A,Qx,Qy)
            r.smul(lv)
    
            if (n.bit(i)==1)
            {
				lv=line(A,P,Qx,Qy)
				r.smul(lv)
            }
            r.sqr()
        }
    
        lv=line(A,A,Qx,Qy)
        r.smul(lv)
    
    /* R-ate fixup */
    
        r.conj()
    
        K.copy(P)
        K.frob(f)
        A.neg()
        lv=line(A,K,Qx,Qy)
        r.smul(lv)
        K.frob(f)
        K.neg()
        lv=line(A,K,Qx,Qy)
        r.smul(lv)
    
        return r
    }
    /* Optimal R-ate double pairing e(P,Q).e(R,S) */
    static func ate2(P:ECP2,_ Q:ECP,_ R:ECP2,_ S:ECP) -> FP12
    {
        var f=FP2(BIG(ROM.CURVE_Fra),BIG(ROM.CURVE_Frb))
        var x=BIG(ROM.CURVE_Bnx)
        var n=BIG(x)
        var K=ECP2()
        var lv:FP12
        n.pmul(6); n.dec(2); n.norm()
        P.affine()
        Q.affine()
        R.affine()
        S.affine()
    
        var Qx=FP(Q.getx())
        var Qy=FP(Q.gety())
        var Sx=FP(S.getx())
        var Sy=FP(S.gety())
    
        var A=ECP2()
        var B=ECP2()
        var r=FP12(1)
    
        A.copy(P)
        B.copy(R)
        var nb=n.nbits()
    
        for var i=nb-2;i>=1;i--
        {
            lv=line(A,A,Qx,Qy)
            r.smul(lv)
            lv=line(B,B,Sx,Sy)
            r.smul(lv)
            if n.bit(i)==1
            {
				lv=line(A,P,Qx,Qy)
				r.smul(lv)
				lv=line(B,R,Sx,Sy)
				r.smul(lv)
            }
            r.sqr()
        }
    
        lv=line(A,A,Qx,Qy)
        r.smul(lv)
    
        lv=line(B,B,Sx,Sy)
        r.smul(lv)
    
    /* R-ate fixup */
        r.conj()
    
        K.copy(P)
        K.frob(f)
        A.neg()
        lv=line(A,K,Qx,Qy)
        r.smul(lv)
        K.frob(f)
        K.neg()
        lv=line(A,K,Qx,Qy)
        r.smul(lv)
    
        K.copy(R)
        K.frob(f)
        B.neg()
        lv=line(B,K,Sx,Sy)
        r.smul(lv)
        K.frob(f)
        K.neg()
        lv=line(B,K,Sx,Sy)
        r.smul(lv)
    
        return r
    }
    
    /* final exponentiation - keep separate for multi-pairings and to avoid thrashing stack */
    static func fexp(m:FP12) -> FP12
    {
        var f=FP2(BIG(ROM.CURVE_Fra),BIG(ROM.CURVE_Frb));
        var x=BIG(ROM.CURVE_Bnx)
        var r=FP12(m)
    
    /* Easy part of final exp */
        var lv=FP12(r)
        lv.inverse()
        r.conj()
    
        r.mul(lv)
        lv.copy(r)
        r.frob(f)
        r.frob(f)
        r.mul(lv)
        
    /* Hard part of final exp */
        lv.copy(r)
        lv.frob(f)
        var x0=FP12(lv)
        x0.frob(f)
        lv.mul(r)
        x0.mul(lv)
        x0.frob(f)
        var x1=FP12(r)
        x1.conj()
        var x4=r.pow(x)

        var x3=FP12(x4)
        x3.frob(f)
    
        var x2=x4.pow(x)
    
        var x5=FP12(x2); x5.conj()
        lv=x2.pow(x)
    
        x2.frob(f)
        r.copy(x2); r.conj()
    
        x4.mul(r)
        x2.frob(f)
    
        r.copy(lv)
        r.frob(f)
        lv.mul(r)
    
        lv.usqr()
        lv.mul(x4)
        lv.mul(x5)
        r.copy(x3)
        r.mul(x5)
        r.mul(lv)
        lv.mul(x2)
        r.usqr()
        r.mul(lv)
        r.usqr()
        lv.copy(r)
        lv.mul(x1)
        r.mul(x0)
        lv.usqr()
        r.mul(lv)
        r.reduce()
        return r
    }
    
    /* GLV method */
    static func glv(e:BIG) -> [BIG]
    {
        var t=BIG(0)
        var q=BIG(ROM.CURVE_Order)
        var u=[BIG]();
        var v=[BIG]();
        for var j=0;j<2;j++
        {
            u.append(BIG(0))
            v.append(BIG(0))
        }
        
        for var i=0;i<2;i++
        {
            t.copy(BIG(ROM.CURVE_W[i]))
            var d=BIG.mul(t,e)
            v[i].copy(d.div(q))
        }
        u[0].copy(e);
        for var i=0;i<2;i++
        {
            for var j=0;j<2;j++
            {
				t.copy(BIG(ROM.CURVE_SB[j][i]))
				t.copy(BIG.modmul(v[j],t,q))
				u[i].add(q)
				u[i].sub(t)
				u[i].mod(q)
            }
        }
        return u
    }
    /* Galbraith & Scott Method */
    static func gs(e:BIG) -> [BIG]
    {
        var t=BIG(0)
        var q=BIG(ROM.CURVE_Order)
        var u=[BIG]();
        var v=[BIG]();
        for var j=0;j<4;j++
        {
            u.append(BIG(0))
            v.append(BIG(0))
        }
        
        for var i=0;i<4;i++
        {
            t.copy(BIG(ROM.CURVE_WB[i]))
            var d=BIG.mul(t,e)
            v[i].copy(d.div(q))
        }
        u[0].copy(e);
        for var i=0;i<4;i++
        {
            for var j=0;j<4;j++
            {
				t.copy(BIG(ROM.CURVE_BB[j][i]))
				t.copy(BIG.modmul(v[j],t,q))
				u[i].add(q)
				u[i].sub(t)
				u[i].mod(q)
            }
        }
        return u
    }	
    
    /* Multiply P by e in group G1 */
    static func G1mul(P:ECP,_ e:BIG) -> ECP
    {
        var R:ECP
        if (ROM.USE_GLV)
        {
            P.affine()
            R=ECP()
            R.copy(P)
            var Q=ECP()
            Q.copy(P)
            var q=BIG(ROM.CURVE_Order)
            var cru=FP(BIG(ROM.CURVE_Cru))
            var t=BIG(0)
            var u=PAIR.glv(e)
            Q.getx().mul(cru);
    
            var np=u[0].nbits()
            t.copy(BIG.modneg(u[0],q))
            var nn=t.nbits()
            if (nn<np)
            {
				u[0].copy(t)
				R.neg()
            }
    
            np=u[1].nbits()
            t.copy(BIG.modneg(u[1],q))
            nn=t.nbits()
            if (nn<np)
            {
				u[1].copy(t)
				Q.neg()
            }
    
            R=R.mul2(u[0],Q,u[1])
        }
        else
        {
            R=P.mul(e)
        }
        return R
    }
    
    /* Multiply P by e in group G2 */
    static func G2mul(P:ECP2,_ e:BIG) -> ECP2
    {
        var R:ECP2
        if (ROM.USE_GS_G2)
        {
            var Q=[ECP2]()
            var f=FP2(BIG(ROM.CURVE_Fra),BIG(ROM.CURVE_Frb));
            var q=BIG(ROM.CURVE_Order);
            var u=PAIR.gs(e);
    
            var t=BIG(0);
            P.affine()
            Q.append(ECP2())
            Q[0].copy(P);
            for var i=1;i<4;i++
            {
                Q.append(ECP2()); Q[i].copy(Q[i-1]);
				Q[i].frob(f);
            }
            for var i=0;i<4;i++
            {
				var np=u[i].nbits();
				t.copy(BIG.modneg(u[i],q));
				var nn=t.nbits();
				if (nn<np)
				{
                    u[i].copy(t);
                    Q[i].neg();
				}
            }
    
            R=ECP2.mul4(Q,u);
        }
        else
        {
            R=P.mul(e);
        }
        return R;
    }
    /* f=f^e */
    /* Note that this method requires a lot of RAM! Better to use compressed XTR method, see FP4.java */
    static func GTpow(d:FP12,_ e:BIG) -> FP12
    {
        var r:FP12
        if (ROM.USE_GS_GT)
        {
            var g=[FP12]()
            var f=FP2(BIG(ROM.CURVE_Fra),BIG(ROM.CURVE_Frb))
            var q=BIG(ROM.CURVE_Order)
            var t=BIG(0)
        
            var u=gs(e)
            g.append(FP12(0))
            g[0].copy(d);
            for var i=1;i<4;i++
            {
                g.append(FP12(0)); g[i].copy(g[i-1])
				g[i].frob(f)
            }
            for var i=0;i<4;i++
            {
				var np=u[i].nbits()
				t.copy(BIG.modneg(u[i],q))
				var nn=t.nbits()
				if (nn<np)
				{
                    u[i].copy(t)
                    g[i].conj()
				}
            }
            r=FP12.pow4(g,u)
        }
        else
        {
            r=d.pow(e)
        }
        return r
    }
    /* test group membership */
    /* with GT-Strong curve, now only check that m!=1, conj(m)*m==1, and m.m^{p^4}=m^{p^2} */
    static func GTmember(m:FP12) -> Bool
    {
        if m.isunity() {return false}
        var r=FP12(m)
        r.conj()
        r.mul(m)
        if !r.isunity() {return false}
    
        var f=FP2(BIG(ROM.CURVE_Fra),BIG(ROM.CURVE_Frb))
    
        r.copy(m); r.frob(f); r.frob(f)
        var w=FP12(r); w.frob(f); w.frob(f)
        w.mul(m)
        if !ROM.GT_STRONG
        {
            if !w.equals(r) {return false}
            var x=BIG(ROM.CURVE_Bnx)
            r.copy(m); w=r.pow(x); w=w.pow(x)
            r.copy(w); r.sqr(); r.mul(w); r.sqr()
            w.copy(m); w.frob(f)
        }
        return w.equals(r)
    }
    
}

