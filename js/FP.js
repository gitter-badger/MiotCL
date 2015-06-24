/*
Copyright 2015 CertiVox UK Ltd

This file is part of The CertiVox MIRACL IOT Crypto SDK (MiotCL)

MiotCL is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MiotCL is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MiotCL.  If not, see <http://www.gnu.org/licenses/>.

You can be released from the requirements of the license by purchasing 
a commercial license.
*/

/* Finite Field arithmetic */
/* MiotCL mod p functions */

/* General purpose COnstructor */
var FP = function(x) {
	if (x instanceof FP)
	{
		this.f=new BIG(x.f);
	}
	else
	{
		this.f=new BIG(x);
		this.nres();
	}
};

FP.prototype={
/* set this=0 */
	zero: function()
	{
		return this.f.zero();
	},

/* copy from a BIG in ROM */
	rcopy: function(y)
	{
		this.f.rcopy(y);
		this.nres();
	},

/* copy from another BIG */
	bcopy: function(y)
	{
		this.f.copy(y);
		this.nres();
	},

/* copy from another FP */
	copy: function(y)
	{
		return this.f.copy(y.f);
	},

/* conditional swap of a and b depending on d */
	cswap: function(b,d)
	{
		this.f.cswap(b.f,d);
	},

/* conditional copy of b to a depending on d */
	cmove: function(b,d)
	{
		this.f.cmove(b.f,d);
	},

/* convert to Montgomery n-residue form */
	nres: function()
	{
		if (ROM.MODTYPE!=ROM.PSEUDO_MERSENNE)
		{
			var p=new BIG();
			p.rcopy(ROM.Modulus);
			var d=new DBIG(0);
			d.hcopy(this.f);
			d.norm();
			d.shl(ROM.NLEN*ROM.BASEBITS);
			this.f.copy(d.mod(p));

		}
		return this;
	},
	
/* convert back to regular form */
	redc: function()
	{
		var r=new BIG(0);
		r.copy(this.f);
		if (ROM.MODTYPE!=ROM.PSEUDO_MERSENNE)
		{
			var d=new DBIG(0);
			d.hcopy(this.f);
			r.copy(BIG.mod(d));
		}

		return r;
	},	

/* convert this to string */
	toString: function() 
	{
		var s=this.redc().toString();
		return s;
	},

/* test this=0 */
	iszilch: function() 
	{
		this.reduce();
		return this.f.iszilch();
	},

/* reduce this mod Modulus */
	reduce: function()
	{
		var p=new BIG(0);
		p.rcopy(ROM.Modulus);
		return this.f.mod(p);
	},

/* set this=1 */
	one: function()
	{
		this.f.one(); 
		return this.nres();
	},

/* normalise this */
	norm: function()
	{
		return this.f.norm();
	},

/* this*=b mod Modulus */
	mul: function(b)
	{
		var ea=BIG.EXCESS(this.f);
		var eb=BIG.EXCESS(b.f);
		if ((ea+1)*(eb+1)+1>=ROM.FEXCESS) this.reduce();
		var d=BIG.mul(this.f,b.f);
		this.f.copy(BIG.mod(d));
		return this;
	},

/* this*=c mod Modulus where c is an int */
	imul: function(c)
	{
		var s=false;
		this.norm();
		if (c<0)
		{
			c=-c;
			s=true;
		}

		var afx=(BIG.EXCESS(this.f)+1)*(c+1)+1;
		if (c<ROM.NEXCESS && afx<ROM.FEXCESS)
		{
			this.f.imul(c);
		}
		else
		{
			if (afx<ROM.FEXCESS) this.f.pmul(c);
			else
			{
				var p=new BIG(0);
				p.rcopy(ROM.Modulus);
				var d=this.f.pxmul(c);
				this.f.copy(d.mod(p));
			}
		}
		if (s) this.neg();
		return this.norm();
	},

/* this*=this mod Modulus */
	sqr: function()
	{
		var d;
		var ea=BIG.EXCESS(this.f);
		if ((ea+1)*(ea+1)+1>=ROM.FEXCESS) this.reduce();
		d=BIG.sqr(this.f);
		var t=BIG.mod(d); 
		this.f.copy(t);
		return this;
	},

/* this+=b */
	add: function(b) 
	{
		this.f.add(b.f);
		if (BIG.EXCESS(this.f)+2>=ROM.FEXCESS) this.reduce();
		return this;
	},
/* this=-this mod Modulus */
	neg: function()
	{
		var sb,ov;
		var m=new BIG(0);
		m.rcopy(ROM.Modulus);

		this.norm();
		ov=BIG.EXCESS(this.f); 
		sb=1; while(ov!==0) {sb++;ov>>=1;} 

		m.fshl(sb);
		this.f.rsub(m);	
		if (BIG.EXCESS(this.f)>=ROM.FEXCESS) this.reduce();
		return this;
	},

/* this-=b */
	sub: function(b)
	{
		var n=new FP(0);
		n.copy(b);
		n.neg();
		this.add(n);
		return this;
	},

/* this/=2 mod Modulus */
	div2: function()
	{
		this.norm();
		if (this.f.parity()===0)
			this.f.fshr(1);
		else
		{
			var p=new BIG(0);
			p.rcopy(ROM.Modulus);

			this.f.add(p);
			this.f.norm();
			this.f.fshr(1);
		}
		return this;
	},

/* this=1/this mod Modulus */
	inverse: function()
	{
		var p=new BIG(0);
		p.rcopy(ROM.Modulus);
		var r=this.redc();
		r.invmodp(p);
		this.f.copy(r);
		return this.nres();
	},

/* return TRUE if this==a */
	equals: function(a)
	{
		a.reduce();
		this.reduce();
		if (BIG.comp(a.f,this.f)===0) return true;
		return false;
	},

/* return this^e mod Modulus */
	pow: function(e)
	{
		var bt;
		var r=new FP(1);
		e.norm();
		this.norm();
		while (true)
		{
			bt=e.parity();
			e.fshr(1);
			if (bt==1) r.mul(this);
			if (e.iszilch()) break;
			this.sqr();
		}

		r.reduce();
		return r;
	},

/* return jacobi symbol (this/Modulus) */
	jacobi: function()
	{
		var p=new BIG(0);
		p.rcopy(ROM.Modulus);
		var w=this.redc();
		return w.jacobi(p);
	},

/* return sqrt(this) mod Modulus */
	sqrt: function()
	{
		this.reduce();
		var b=new BIG(0);
		b.rcopy(ROM.Modulus);
		if (ROM.MOD8==5)
		{
			b.dec(5); b.norm(); b.shr(3);
			var i=new FP(0); 
			i.copy(this);
			i.f.shl(1);
			var v=i.pow(b);
			i.mul(v); i.mul(v);
			i.f.dec(1);
			var r=new FP(0);
			r.copy(this);
			r.mul(v); r.mul(i); 
			r.reduce();
			return r;
		}
		else
		{
			b.inc(1); b.norm(); b.shr(2);
			return this.pow(b);
		}
	}

};


