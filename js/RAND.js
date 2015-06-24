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

/*
 *   Cryptographic strong random number generator 
 *
 *   Unguessable seed -> SHA -> PRNG internal state -> SHA -> random numbers
 *   Slow - but secure
 *
 *   See ftp://ftp.rsasecurity.com/pub/pdfs/bull-1.pdf for a justification
 */

/* Marsaglia & Zaman Random number generator constants */


var RAND=function() 
{
/* Cryptographically strong pseudo-random number generator */
	this.ira=[]; /* random number...   */
	this.rndptr=0;  /* ...array & pointer */
	this.borrow=0;
	this.pool_ptr=0;
	this.pool=[]; /* random pool */
	this.clean();
};

RAND.prototype=
{
	NK:21,
	NJ:6,
	NV:8,

/* Terminate and clean up */
	clean : function()
	{
		var i;
		for (i=0;i<32;i++) this.pool[i]=0;
		for (i=0;i<this.NK;i++) this.ira[i]=0;
		this.rndptr=0;
		this.borrow=0;
		this.pool_ptr=0;
	},

	sbrand: function()
	{ /* Marsaglia & Zaman random number generator */
		var i,k;
		var pdiff,t; /* unsigned 32-bit */

		this.rndptr++;
		if (this.rndptr<this.NK) return this.ira[this.rndptr];
		this.rndptr=0;
		for (i=0,k=this.NK-this.NJ;i<this.NK;i++,k++)
		{ /* calculate next NK values */
			if (k==this.NK) k=0;
			t=this.ira[k]>>>0;
			pdiff=(t - this.ira[i] - this.borrow)|0;
			pdiff>>>=0;  /* This is seriously wierd shit. I got to do this to get a proper unsigned comparison... */
			if (pdiff<t) this.borrow=0;
			if (pdiff>t) this.borrow=1;
			this.ira[i]=(pdiff|0); 
		}
		return this.ira[0];
	},

	sirand: function(seed)
	{
		var i,inn;
		var t,m=1;
		this.borrow=0;
		this.rndptr=0;
		seed>>>=0;
		this.ira[0]^=seed;

		for (i=1;i<this.NK;i++)
		{ /* fill initialisation vector */
			inn=(this.NV*i)%this.NK;
			this.ira[inn]^=m;      /* note XOR */
			t=m;
			m=(seed-m)|0;
			seed=t;
		}

		for (i=0;i<10000;i++) this.sbrand(); /* "warm-up" & stir the generator */
	},

	fill_pool: function()
	{
		var sh=new HASH();
		for (var i=0;i<128;i++) sh.process(this.sbrand());
		this.pool=sh.hash();
		this.pool_ptr=0;
	},

/* Initialize RNG with some real entropy from some external source */
	seed: function(rawlen,raw)
	{ /* initialise from at least 128 byte string of raw random entropy */
		var i;
		var digest=[];
		var b=[];
		var sh=new HASH();
		this.pool_ptr=0;
		for (i=0;i<this.NK;i++) this.ira[i]=0;
		if (rawlen>0)
		{
			for (i=0;i<rawlen;i++)
				sh.process(raw[i]);
			digest=sh.hash();

/* initialise PRNG from distilled randomness */
			for (i=0;i<8;i++) 
			{
				b[0]=digest[4*i]; b[1]=digest[4*i+1]; b[2]=digest[4*i+2]; b[3]=digest[4*i+3];
				this.sirand(RAND.pack(b));
			}
		}
		this.fill_pool();
	},

/* get random byte */
	getByte: function()
	{ 
		var r=this.pool[this.pool_ptr++];
		if (this.pool_ptr>=32) this.fill_pool();
		return (r&0xff);
	}
};

RAND.pack= function(b)
{ /* pack 4 bytes into a 32-bit Word */
		return (((b[3])&0xff)<<24)|((b[2]&0xff)<<16)|((b[1]&0xff)<<8)|(b[0]&0xff);
};

