//
//  ecp.swift
//  miot2
//
//  Created by Michael Scott on 30/06/2015.
//  Copyright (c) 2015 Michael Scott. All rights reserved.
//

final class ECP {
    private var x:FP
    private var y:FP
    private var z:FP
    private var INF:Bool
    
   /* Constructor - set to O */
    init()
    {
        x=FP(0)
        y=FP(0)
        z=FP(1)
        INF=true
    }
    
    /* test for O point-at-infinity */
    func is_infinity() -> Bool
    {
        if (ROM.CURVETYPE==ROM.EDWARDS)
        {
            x.reduce(); y.reduce(); z.reduce()
            return x.iszilch() && y.equals(z)
        }
        else {return INF}
    }
 
    /* Conditional swap of P and Q dependant on d */
    private func cswap(Q: ECP,_ d:Int32)
    {
        x.cswap(Q.x,d);
        if ROM.CURVETYPE != ROM.MONTGOMERY {y.cswap(Q.y,d)}
        z.cswap(Q.z,d);
        if (ROM.CURVETYPE != ROM.EDWARDS)
        {
            var bd:Bool
            if d==0 {bd=false}
            else {bd=true}
            bd=bd && (INF != Q.INF)
            INF = (INF != bd)
            Q.INF = (Q.INF != bd)
        }
    }
    
    /* Conditional move of Q to P dependant on d */
    private func cmove(Q: ECP,_ d:Int32)
    {
        x.cmove(Q.x,d);
        if ROM.CURVETYPE != ROM.MONTGOMERY {y.cmove(Q.y,d)}
        z.cmove(Q.z,d);
        if (ROM.CURVETYPE != ROM.EDWARDS)
        {
            var bd:Bool
            if d==0 {bd=false}
            else {bd=true}
            INF != (INF != Q.INF) && bd;
        }
    }
    
    /* return 1 if b==c, no branching */
    private static func teq(b: Int32,_ c:Int32) -> Int32
    {
        var x=b^c
        x-=1  // if x=0, x now -1
        return ((x>>31)&1)
    }
 
    /* self=P */
    func copy(P: ECP)
    {
        x.copy(P.x)
        if ROM.CURVETYPE != ROM.MONTGOMERY {y.copy(P.y)}
        z.copy(P.z)
        INF=P.INF
    }
    /* self=-self */
    func neg() {
        if is_infinity() {return}
        if (ROM.CURVETYPE==ROM.WEIERSTRASS)
        {
            y.neg(); y.norm();
        }
        if (ROM.CURVETYPE==ROM.EDWARDS)
        {
            x.neg(); x.norm();
        }
        return;
    }
    
    /* Constant time select from pre-computed table */
    private func select(W:[ECP],_ b:Int32)
    {
        var MP=ECP()
        var m=b>>31
        var babs=(b^m)-m
    
        babs=(babs-1)/2
    
        cmove(W[0],ECP.teq(babs,0)); // conditional move
        cmove(W[1],ECP.teq(babs,1))
        cmove(W[2],ECP.teq(babs,2))
        cmove(W[3],ECP.teq(babs,3))
        cmove(W[4],ECP.teq(babs,4))
        cmove(W[5],ECP.teq(babs,5))
        cmove(W[6],ECP.teq(babs,6))
        cmove(W[7],ECP.teq(babs,7))
    
        MP.copy(self)
        MP.neg()
        cmove(MP,(m&1))
    }
    
    /* Test P == Q */
    func equals(Q: ECP) -> Bool
    {
        if (is_infinity() && Q.is_infinity()) {return true}
        if (is_infinity() || Q.is_infinity()) {return false}
        if (ROM.CURVETYPE==ROM.WEIERSTRASS)
        {
            var zs2=FP(z); zs2.sqr()
            var zo2=FP(Q.z); zo2.sqr()
            var zs3=FP(zs2); zs3.mul(z)
            var zo3=FP(zo2); zo3.mul(Q.z)
            zs2.mul(Q.x)
            zo2.mul(x)
            if !zs2.equals(zo2) {return false}
            zs3.mul(Q.y)
            zo3.mul(y)
            if !zs3.equals(zo3) {return false}
        }
        else
        {
            var a=FP(0)
            var b=FP(0)
            a.copy(x); a.mul(Q.z); a.reduce()
            b.copy(Q.x); b.mul(z); b.reduce()
            if !a.equals(b) {return false}
            if ROM.CURVETYPE==ROM.EDWARDS
            {
				a.copy(y); a.mul(Q.z); a.reduce()
				b.copy(Q.y); b.mul(z); b.reduce()
				if !a.equals(b) {return false}
            }
        }
        return true
    }
  
/* set self=O */
    func inf()
    {
        INF=true;
        x.zero()
        y.one()
        z.one()
    }
    
    /* Calculate RHS of curve equation */
    static func RHS(x: FP) -> FP
    {
        x.norm();
        var r=FP(x);
        r.sqr();
    
        if ROM.CURVETYPE==ROM.WEIERSTRASS
        { // x^3+Ax+B
            var b=FP(BIG(ROM.CURVE_B))
            r.mul(x)
            if (ROM.CURVE_A == -3)
            {
				var cx=FP(x)
				cx.imul(3)
				cx.neg(); cx.norm()
				r.add(cx)
            }
            r.add(b);
        }
        if (ROM.CURVETYPE==ROM.EDWARDS)
        { // (Ax^2-1)/(Bx^2-1)
            var b=FP(BIG(ROM.CURVE_B))
    
            var one=FP(1);
            b.mul(r);
            b.sub(one);
            if ROM.CURVE_A == -1 {r.neg()}
            r.sub(one)
            b.inverse()
            r.mul(b);
        }
        if ROM.CURVETYPE==ROM.MONTGOMERY
        { // x^3+Ax^2+x
            var x3=FP(0)
            x3.copy(r);
            x3.mul(x);
            r.imul(ROM.CURVE_A);
            r.add(x3);
            r.add(x);
        }
        r.reduce();
        return r;
    }
    
    /* set (x,y) from two BIGs */
    init(_ ix: BIG,_ iy: BIG)
    {
        x=FP(ix)
        y=FP(iy)
        z=FP(1)
        INF=true
        var rhs=ECP.RHS(x);
    
        if ROM.CURVETYPE==ROM.MONTGOMERY
        {
            if rhs.jacobi()==1 {INF=false}
            else {inf()}
        }
        else
        {
            var y2=FP(y)
            y2.sqr()
            if y2.equals(rhs) {INF=false}
            else {inf()}
        }
    }
    
    /* set (x,y) from BIG and a bit */
    init(_ ix: BIG,_ s:Int32)
    {
        x=FP(ix)
        var rhs=ECP.RHS(x)
        y=FP(0)
        z=FP(1)
        INF=true
        if rhs.jacobi()==1
        {
            var ny=rhs.sqrt()
            if (ny.redc().parity() != s) {ny.neg()}
            y.copy(ny)
            INF=false;
        }
        else {inf()}
    }
    
    /* set from x - calculate y from curve equation */
    init(_ ix:BIG)
    {
        x=FP(ix)
        var rhs=ECP.RHS(x)
        y=FP(0)
        z=FP(1)
        if rhs.jacobi()==1
        {
            if ROM.CURVETYPE != ROM.MONTGOMERY {y.copy(rhs.sqrt())}
            INF=false;
        }
        else {INF=true}
    }
    
    /* set to affine - from (x,y,z) to (x,y) */
    func affine()
    {
        if is_infinity() {return}
        var one=FP(1)
        if (z.equals(one)) {return}
        z.inverse()
        if ROM.CURVETYPE==ROM.WEIERSTRASS
        {
            var z2=FP(z)
            z2.sqr()
            x.mul(z2); x.reduce()
            y.mul(z2)
            y.mul(z);  y.reduce()
        }
        if ROM.CURVETYPE==ROM.EDWARDS
        {
            x.mul(z); x.reduce()
            y.mul(z); y.reduce()
        }
        if ROM.CURVETYPE==ROM.MONTGOMERY
        {
            x.mul(z); x.reduce()
 
        }
        z.copy(one)
    }
    /* extract x as a BIG */
    func getX() -> BIG
    {
        affine()
        return x.redc()
    }
    /* extract y as a BIG */
    func getY() -> BIG
    {
        affine();
        return y.redc();
    }
    
    /* get sign of Y */
    func getS() -> Int32
    {
        affine()
        var y=getY()
        return y.parity()
    }
    /* extract x as an FP */
    func getx() -> FP
    {
        return x;
    }
    /* extract y as an FP */
    func gety() -> FP
    {
        return y;
    }
    /* extract z as an FP */
    func getz() -> FP
    {
        return z;
    }
    /* convert to byte array */
    func toBytes(inout b:[UInt8])
    {
        var RM=Int(ROM.MODBYTES)
        var t=[UInt8](count:RM,repeatedValue:0)
        if ROM.CURVETYPE != ROM.MONTGOMERY {b[0]=0x04}
        else {b[0]=0x02}
    
        affine()
        x.redc().toBytes(&t)
        for var i=0;i<RM;i++ {b[i+1]=t[i]}
        if ROM.CURVETYPE != ROM.MONTGOMERY
        {
            y.redc().toBytes(&t);
            for var i=0;i<RM;i++ {b[i+RM+1]=t[i]}
        }
    }
    /* convert from byte array to point */
    static func fromBytes(b: [UInt8]) -> ECP
    {
        var RM=Int(ROM.MODBYTES)
        var t=[UInt8](count:RM,repeatedValue:0)
        var p=BIG(ROM.Modulus);
    
        for var i=0;i<RM;i++ {t[i]=b[i+1]}
        var px=BIG.fromBytes(t)
        if BIG.comp(px,p)>=0 {return ECP()}
    
        if (b[0]==0x04)
        {
            for var i=0;i<RM;i++ {t[i]=b[i+RM+1]}
            var py=BIG.fromBytes(t)
            if BIG.comp(py,p)>=0 {return ECP()}
            return ECP(px,py)
        }
        else {return ECP(px)}
    }
    /* convert to hex string */
    func toString() -> String
    {
        if is_infinity() {return "infinity"}
        affine();
        if ROM.CURVETYPE==ROM.MONTGOMERY {return "("+x.redc().toString()+")"}
        else {return "("+x.redc().toString()+","+y.redc().toString()+")"}
    }
    
    /* self*=2 */
    func dbl()
    {
        if (ROM.CURVETYPE==ROM.WEIERSTRASS)
        {
            if INF {return}
            if y.iszilch()
            {
				inf()
				return
            }
    
            var w1=FP(x)
            var w6=FP(z)
            var w2=FP(0)
            var w3=FP(x)
            var w8=FP(x)
    
            if (ROM.CURVE_A == -3)
            {
				w6.sqr()
				w1.copy(w6)
				w1.neg()
				w3.add(w1)
				w8.add(w6)
				w3.mul(w8)
				w8.copy(w3)
				w8.imul(3)
            }
            else
            {
				w1.sqr()
				w8.copy(w1)
				w8.imul(3)
            }
    
            w2.copy(y); w2.sqr()
            w3.copy(x); w3.mul(w2)
            w3.imul(4)
            w1.copy(w3); w1.neg()
            w1.norm()
    
            x.copy(w8); x.sqr()
            x.add(w1)
            x.add(w1)
            x.norm()
    
            z.mul(y)
            z.add(z)
    
            w2.add(w2)
            w2.sqr()
            w2.add(w2)
            w3.sub(x)
            y.copy(w8); y.mul(w3)
            //w2.norm();
            y.sub(w2)
            y.norm()
            z.norm()
        }
        if ROM.CURVETYPE==ROM.EDWARDS
        {
            var C=FP(x)
            var D=FP(y)
            var H=FP(z)
            var J=FP(0)
    
            x.mul(y); x.add(x)
            C.sqr()
            D.sqr()
            if ROM.CURVE_A == -1 {C.neg()}
            y.copy(C); y.add(D)
            y.norm()
            H.sqr(); H.add(H)
            z.copy(y)
            J.copy(y); J.sub(H)
            x.mul(J)
            C.sub(D)
            y.mul(C)
            z.mul(J)
    
            x.norm();
            y.norm();
            z.norm();
        }
        if ROM.CURVETYPE==ROM.MONTGOMERY
        {
            var A=FP(x)
            var B=FP(x);
            var AA=FP(0);
            var BB=FP(0);
            var C=FP(0);
    
            if INF {return}
    
            A.add(z)
            AA.copy(A); AA.sqr()
            B.sub(z)
            BB.copy(B); BB.sqr()
            C.copy(AA); C.sub(BB)
    //C.norm();
    
            x.copy(AA); x.mul(BB)
    
            A.copy(C); A.imul((ROM.CURVE_A+2)/4)
    
            BB.add(A)
            z.copy(BB); z.mul(C)
            x.norm()
            z.norm()
        }
        return
    }
    
    /* self+=Q */
    func add(Q:ECP)
    {
        if ROM.CURVETYPE==ROM.WEIERSTRASS
        {
            if (INF)
            {
				copy(Q)
				return
            }
            if Q.INF {return}
    
            var aff=false;
    
            var one=FP(1);
            if Q.z.equals(one) {aff=true}
    
            var A:FP
            var C:FP
            var B=FP(z)
            var D=FP(z)
            if (!aff)
            {
				A=FP(Q.z)
				C=FP(Q.z)
    
				A.sqr(); B.sqr()
				C.mul(A); D.mul(B)
    
				A.mul(x)
				C.mul(y)
            }
            else
            {
				A=FP(x)
				C=FP(y)
    
				B.sqr()
				D.mul(B)
            }
    
            B.mul(Q.x); B.sub(A)
            D.mul(Q.y); D.sub(C)
    
            if B.iszilch()
            {
				if (D.iszilch())
				{
                    dbl()
                    return
				}
				else
				{
                    INF=true
                    return
				}
            }
    
            if !aff {z.mul(Q.z)}
            z.mul(B);
    
            var e=FP(B); e.sqr()
            B.mul(e)
            A.mul(e)
    
            e.copy(A)
            e.add(A); e.add(B)
            x.copy(D); x.sqr(); x.sub(e)
    
            A.sub(x)
            y.copy(A); y.mul(D)
            C.mul(B); y.sub(C)
    
            x.norm()
            y.norm()
            z.norm()
        }
        if ROM.CURVETYPE==ROM.EDWARDS
        {
            var b=FP(BIG(ROM.CURVE_B))
            var A=FP(z)
            var B=FP(0)
            var C=FP(x)
            var D=FP(y)
            var E=FP(0)
            var F=FP(0)
            var G=FP(0)
            var H=FP(0)
            var I=FP(0)
    
            A.mul(Q.z)
            B.copy(A); B.sqr()
            C.mul(Q.x)
            D.mul(Q.y)
    
            E.copy(C); E.mul(D); E.mul(b)
            F.copy(B); F.sub(E)
            G.copy(B); G.add(E)
            C.add(D)
    
            if ROM.CURVE_A==1
            {
				E.copy(D); D.sub(C)
            }
    
            B.copy(x); B.add(y)
            D.copy(Q.x); D.add(Q.y)
            B.mul(D)
            B.sub(C)
            B.mul(F)
            x.copy(A); x.mul(B)

            if ROM.CURVE_A==1
            {
				C.copy(E); C.mul(G)
            }
            if ROM.CURVE_A == -1
            {
				C.mul(G)
            }
            y.copy(A); y.mul(C)
            z.copy(F); z.mul(G)
            x.norm(); y.norm(); z.norm()
        }
        return;
    }
    
    /* Differential Add for Montgomery curves. self+=Q where W is self-Q and is affine. */
    func dadd(Q:ECP,_ W:ECP)
    {
        var A=FP(x)
        var B=FP(x)
        var C=FP(Q.x)
        var D=FP(Q.x)
        var DA=FP(0)
        var CB=FP(0)
    
        A.add(z)
        B.sub(z)
    
        C.add(Q.z)
        D.sub(Q.z)
    
        DA.copy(D); DA.mul(A)
        CB.copy(C); CB.mul(B)
        
        A.copy(DA); A.add(CB); A.sqr()
        B.copy(DA); B.sub(CB); B.sqr()
    
        x.copy(A)
        z.copy(W.x); z.mul(B)
    
        if z.iszilch() {inf()}
        else {INF=false}
    
        x.norm()
    }
    /* this-=Q */
    func sub(Q:ECP)
    {
        Q.neg()
        add(Q)
        Q.neg()
    }
    static func multiaffine(m: Int,_ P:[ECP])
    {
        var t1=FP(0)
        var t2=FP(0)
    
        var work=[FP]()
        
        for var i=0;i<m;i++
            {work.append(FP(0))}
    
        work[0].one()
        work[1].copy(P[0].z)
    
        for var i=2;i<m;i++
        {
            work[i].copy(work[i-1])
            work[i].mul(P[i-1].z)
        }
    
        t1.copy(work[m-1]);
        t1.mul(P[m-1].z);
        t1.inverse();
        t2.copy(P[m-1].z);
        work[m-1].mul(t1);
    
        for var i=m-2;;i--
        {
            if i==0
            {
				work[0].copy(t1)
				work[0].mul(t2)
				break
            }
            work[i].mul(t2);
            work[i].mul(t1);
            t2.mul(P[i].z);
        }
    /* now work[] contains inverses of all Z coordinates */
    
        for var i=0;i<m;i++
        {
            P[i].z.one();
            t1.copy(work[i]);
            t1.sqr();
            P[i].x.mul(t1);
            t1.mul(work[i]);
            P[i].y.mul(t1);
        }
    }
    /* constant time multiply by small integer of length bts - use ladder */
    func pinmul(e:Int32,_ bts:Int32) -> ECP
    {
        if ROM.CURVETYPE==ROM.MONTGOMERY
            {return self.mul(BIG(e))}
        else
        {
            var P=ECP()
            var R0=ECP()
            var R1=ECP(); R1.copy(self)
    
            for var i=bts-1;i>=0;i--
            {
				var b=(e>>i)&1;
				P.copy(R1);
				P.add(R0);
				R0.cswap(R1,b);
				R1.copy(P);
				R0.dbl();
				R0.cswap(R1,b);
            }
            P.copy(R0);
            P.affine();
            return P;
        }
    }
    
    /* return e.self */
    
    func mul(e:BIG) -> ECP
    {
        if (e.iszilch() || is_infinity()) {return ECP()}
    
        var P=ECP()
        if ROM.CURVETYPE==ROM.MONTGOMERY
        {
            /* use Ladder */
            var D=ECP()
            var R0=ECP(); R0.copy(self)
            var R1=ECP(); R1.copy(self)
            R1.dbl();
            D.copy(self); D.affine();
            var nb=e.nbits();
            
            for var i=nb-2;i>=0;i--
            {
				var b=e.bit(i)
                //print("\(b)")
				P.copy(R1)
				P.dadd(R0,D)
				R0.cswap(R1,b)
				R1.copy(P)
				R0.dbl()
				R0.cswap(R1,b)
            }
            P.copy(R0)
        }
        else
        {
    // fixed size windows
            var mt=BIG()
            var t=BIG()
            var Q=ECP()
            var C=ECP()
            var W=[ECP]()
            var n=1+(ROM.NLEN*Int(ROM.BASEBITS)+3)/4
            var w=[Int8](count:n,repeatedValue:0)
    
            affine();
    
    // precompute table
            Q.copy(self)
            Q.dbl()
            W.append(ECP())
            
            W[0].copy(self)
    
            for var i=1;i<8;i++
            {
                W.append(ECP())
				W[i].copy(W[i-1])
				W[i].add(Q)
            }
    
    // convert the table to affine
            if ROM.CURVETYPE==ROM.WEIERSTRASS
                {ECP.multiaffine(8,W)}
    
    // make exponent odd - add 2P if even, P if odd
            t.copy(e);
            var s=t.parity();
            t.inc(1); t.norm(); var ns=t.parity();
            mt.copy(t); mt.inc(1); mt.norm();
            t.cmove(mt,s);
            Q.cmove(self,ns);
            C.copy(Q);
    
            var nb=1+(t.nbits()+3)/4;
    
    // convert exponent to signed 4-bit window
            for var i=0;i<nb;i++
            {
				w[i]=Int8(t.lastbits(5)-16);
				t.dec(Int32(w[i])); t.norm();
				t.fshr(4);
            }
            w[nb]=Int8(t.lastbits(5))
    
            P.copy(W[Int((w[nb])-1)/2]);
            for var i=nb-1;i>=0;i--
            {
				Q.select(W,Int32(w[i]));
				P.dbl();
				P.dbl();
				P.dbl();
				P.dbl();
				P.add(Q);
            }
            P.sub(C); /* apply correction */
        }
        P.affine();
        return P;
    }
    
    /* Return e.this+f.Q */
    
    func mul2(e:BIG,_ Q:ECP,_ f:BIG) -> ECP
    {
        var te=BIG()
        var tf=BIG()
        var mt=BIG()
        var S=ECP()
        var T=ECP()
        var C=ECP()
        var W=[ECP]()
        var n=1+(ROM.NLEN*Int(ROM.BASEBITS)+1)/2
        var w=[Int8](count:n,repeatedValue:0);
        
        affine();
        Q.affine();
    
        te.copy(e);
        tf.copy(f);
    
    // precompute table
        for var i=0;i<8;i++ {W.append(ECP())}
        W[1].copy(self); W[1].sub(Q)
        W[2].copy(self); W[2].add(Q)
        S.copy(Q); S.dbl();
        W[0].copy(W[1]); W[0].sub(S)
        W[3].copy(W[2]); W[3].add(S)
        T.copy(self); T.dbl()
        W[5].copy(W[1]); W[5].add(T)
        W[6].copy(W[2]); W[6].add(T)
        W[4].copy(W[5]); W[4].sub(S)
        W[7].copy(W[6]); W[7].add(S)
    
    // convert the table to affine
        if ROM.CURVETYPE==ROM.WEIERSTRASS
            {ECP.multiaffine(8,W)}
    
    // if multiplier is odd, add 2, else add 1 to multiplier, and add 2P or P to correction
    
        var s=te.parity()
        te.inc(1); te.norm(); var ns=te.parity(); mt.copy(te); mt.inc(1); mt.norm()
        te.cmove(mt,s)
        T.cmove(self,ns)
        C.copy(T)
    
        s=tf.parity()
        tf.inc(1); tf.norm(); ns=tf.parity(); mt.copy(tf); mt.inc(1); mt.norm()
        tf.cmove(mt,s)
        S.cmove(Q,ns)
        C.add(S)
    
        mt.copy(te); mt.add(tf); mt.norm()
        var nb=1+(mt.nbits()+1)/2
    
    // convert exponent to signed 2-bit window
        for var i=0;i<nb;i++
        {
            var a=(te.lastbits(3)-4);
            te.dec(a); te.norm();
            te.fshr(2);
            var b=(tf.lastbits(3)-4);
            tf.dec(b); tf.norm();
            tf.fshr(2);
            w[i]=Int8(4*a+b);
        }
        w[nb]=Int8(4*te.lastbits(3)+tf.lastbits(3));
        S.copy(W[(w[nb]-1)/2]);
    
        for var i=nb-1;i>=0;i--
        {
            T.select(W,Int32(w[i]));
            S.dbl();
            S.dbl();
            S.add(T);
        }
        S.sub(C); /* apply correction */
        S.affine();
        return S;
    }
    
    
   
    
}