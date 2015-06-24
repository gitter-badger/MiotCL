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
 * Implementation of the AES-GCM Encryption/Authentication
 *
 * Some restrictions.. 
 * 1. Only for use with AES
 * 2. Returned tag is always 128-bits. Truncate at your own risk.
 * 3. The order of function calls must follow some rules
 *
 * Typical sequence of calls..
 * 1. call GCM_init
 * 2. call GCM_add_header any number of times, as long as length of header is multiple of 16 bytes (block size)
 * 3. call GCM_add_header one last time with any length of header
 * 4. call GCM_add_cipher any number of times, as long as length of cipher/plaintext is multiple of 16 bytes
 * 5. call GCM_add_cipher one last time with any length of cipher/plaintext
 * 6. call GCM_finish to extract the tag.
 *
 * See http://www.mindspring.com/~dmcgrew/gcm-nist-6.pdf
 */

var GCM = function() {
	this.table=new Array(128);
	for (var i=0;i<128;i++)
		this.table[i]=new Array(4);  /* 2k bytes */
	this.stateX=[];
	this.Y_0=[];
	this.counter=0;
	this.lenA=[];
	this.lenC=[];
	this.status=0;
	this.a=new AES();
};

GCM.prototype={

	precompute: function(H)
	{
		var i,j,c;
		var b=[];

		for (i=j=0;i<4;i++,j+=4) 
		{
			b[0]=H[j]; b[1]=H[j+1]; b[2]=H[j+2]; b[3]=H[j+3];
			this.table[0][i]=GCM.pack(b);
		}
		for (i=1;i<128;i++)
		{
			c=0;
			for (j=0;j<4;j++) 
			{
				this.table[i][j]=c|(this.table[i-1][j])>>>1; 
				c=this.table[i-1][j]<<31;
			}
			if (c!==0) this.table[i][0]^=0xE1000000; /* irreducible polynomial */
		}
	},

	gf2mul: function()
	{ /* gf2m mul - Z=H*X mod 2^128 */
		var i,j,m,k;
		var P=[];
		var c;
		var b=[];

		P[0]=P[1]=P[2]=P[3]=0;
		j=8; m=0;
		for (i=0;i<128;i++)
		{
			c=(this.stateX[m]>>>(--j))&1;
			if (c!==0) for (k=0;k<4;k++) P[k]^=this.table[i][k];
			if (j===0)
			{
				j=8; m++;
				if (m==16) break;
			}
		}
		for (i=j=0;i<4;i++,j+=4) 
		{
			b=GCM.unpack(P[i]);
			this.stateX[j]=b[0]; this.stateX[j+1]=b[1]; this.stateX[j+2]=b[2]; this.stateX[j+3]=b[3];
		}
	},

	wrap: function()
	{ /* Finish off GHASH */
		var i,j;
		var F=[];
		var L=[];
		var b=[];

/* convert lengths from bytes to bits */
		F[0]=(this.lenA[0]<<3)|(this.lenA[1]&0xE0000000)>>>29;
		F[1]=this.lenA[1]<<3;
		F[2]=(this.lenC[0]<<3)|(this.lenC[1]&0xE0000000)>>>29;
		F[3]=this.lenC[1]<<3;
		for (i=j=0;i<4;i++,j+=4)
		{
			b=GCM.unpack(F[i]);
			L[j]=b[0]; L[j+1]=b[1]; L[j+2]=b[2]; L[j+3]=b[3];
		}
		for (i=0;i<16;i++) this.stateX[i]^=L[i];
		this.gf2mul();
	},

/* Initialize GCM mode */
	init: function(key,niv,iv)
	{ /* iv size niv is usually 12 bytes (96 bits). AES key size nk can be 16,24 or 32 bytes */
		var i;
		var H=[];
		var b=[];

		for (i=0;i<16;i++) {H[i]=0; this.stateX[i]=0;}

		this.a.init(ROM.ECB,key,iv);
		this.a.ecb_encrypt(H);     /* E(K,0) */
		this.precompute(H);
	
		this.lenA[0]=this.lenC[0]=this.lenA[1]=this.lenC[1]=0;
		if (niv==12)
		{
			for (i=0;i<12;i++) this.a.f[i]=iv[i];
			b=GCM.unpack(1);
			this.a.f[12]=b[0]; this.a.f[13]=b[1]; this.a.f[14]=b[2]; this.a.f[15]=b[3];  /* initialise IV */
			for (i=0;i<16;i++) this.Y_0[i]=this.a.f[i];
		}
		else
		{
			this.status=ROM.GCM_ACCEPTING_CIPHER;
			this.ghash(iv,niv); /* GHASH(H,0,IV) */
			this.wrap();
			for (i=0;i<16;i++) {this.a.f[i]=this.stateX[i];this.Y_0[i]=this.a.f[i];this.stateX[i]=0;}
			this.lenA[0]=this.lenC[0]=this.lenA[1]=this.lenC[1]=0;
		}
		this.status=ROM.GCM_ACCEPTING_HEADER;
	},

/* Add Header data - included but not encrypted */
	add_header: function(header,len)
	{ /* Add some header. Won't be encrypted, but will be authenticated. len is length of header */
		var i,j=0;
		if (this.status!=ROM.GCM_ACCEPTING_HEADER) return false;

		while (j<len)
		{
			for (i=0;i<16 && j<len;i++)
			{
				this.stateX[i]^=header[j++];
				this.lenA[1]++; this.lenA[1]|=0; if (this.lenA[1]===0) this.lenA[0]++;
			}
			this.gf2mul();
		}
		if (len%16!==0) this.status=ROM.GCM_ACCEPTING_CIPHER;
		return true;
	},

	ghash: function(plain,len)
	{
		var i,j=0;

		if (this.status==ROM.GCM_ACCEPTING_HEADER) this.status=ROM.GCM_ACCEPTING_CIPHER;
		if (this.status!=ROM.GCM_ACCEPTING_CIPHER) return false;
		
		while (j<len)
		{
			for (i=0;i<16 && j<len;i++)
			{
				this.stateX[i]^=plain[j++];
				this.lenC[1]++; this.lenC[1]|=0; if (this.lenC[1]===0) this.lenC[0]++;
			}
			this.gf2mul();
		}
		if (len%16!==0) this.status=ROM.GCM_NOT_ACCEPTING_MORE;
		return true;
	},

/* Add Plaintext - included and encrypted */
	add_plain: function(plain,len)
	{
		var i,j=0;
		var B=[];
		var b=[];
		var cipher=[];

		if (this.status==ROM.GCM_ACCEPTING_HEADER) this.status=ROM.GCM_ACCEPTING_CIPHER;
		if (this.status!=ROM.GCM_ACCEPTING_CIPHER) return cipher;
		
		while (j<len)
		{

			b[0]=this.a.f[12]; b[1]=this.a.f[13]; b[2]=this.a.f[14]; b[3]=this.a.f[15];
			this.counter=GCM.pack(b);
			this.counter++;
			b=GCM.unpack(this.counter);
			this.a.f[12]=b[0]; this.a.f[13]=b[1]; this.a.f[14]=b[2]; this.a.f[15]=b[3]; /* increment counter */
			for (i=0;i<16;i++) B[i]=this.a.f[i];
			this.a.ecb_encrypt(B);        /* encrypt it  */
		
			for (i=0;i<16 && j<len;i++)
			{
				cipher[j]=(plain[j]^B[i]);
				this.stateX[i]^=cipher[j++];
				this.lenC[1]++; this.lenC[1]|=0; if (this.lenC[1]===0) this.lenC[0]++;
			}
			this.gf2mul();
		}
		if (len%16!==0) this.status=ROM.GCM_NOT_ACCEPTING_MORE;
		return cipher;
	},

/* Add Ciphertext - decrypts to plaintext */
	add_cipher: function(cipher,len)
	{
		var i,j=0;
		var B=[];
		var b=[];
		var plain=[];

		if (this.status==ROM.GCM_ACCEPTING_HEADER) this.status=ROM.GCM_ACCEPTING_CIPHER;
		if (this.status!=ROM.GCM_ACCEPTING_CIPHER) return plain;
	
		while (j<len)
		{
			b[0]=this.a.f[12]; b[1]=this.a.f[13]; b[2]=this.a.f[14]; b[3]=this.a.f[15];
			this.counter=GCM.pack(b);
			this.counter++;
			b=GCM.unpack(this.counter);
			this.a.f[12]=b[0]; this.a.f[13]=b[1]; this.a.f[14]=b[2]; this.a.f[15]=b[3]; /* increment counter */
			for (i=0;i<16;i++) B[i]=this.a.f[i];
			this.a.ecb_encrypt(B);        /* encrypt it  */
			for (i=0;i<16 && j<len;i++)
			{
				plain[j]=(cipher[j]^B[i]);
				this.stateX[i]^=cipher[j++];
				this.lenC[1]++; this.lenC[1]|=0; if (this.lenC[1]===0) this.lenC[0]++;
			}
			this.gf2mul();
		}
		if (len%16!==0) this.status=ROM.GCM_NOT_ACCEPTING_MORE;
		return plain;
	},

/* Finish and extract Tag */
	finish: function(extract)
	{ /* Finish off GHASH and extract tag (MAC) */
		var i;
		var tag=[];

		this.wrap();
/* extract tag */
		if (extract)
		{
			this.a.ecb_encrypt(this.Y_0);        /* E(K,Y0) */
			for (i=0;i<16;i++) this.Y_0[i]^=this.stateX[i];
			for (i=0;i<16;i++) {tag[i]=this.Y_0[i];this.Y_0[i]=this.stateX[i]=0;}
		}
		this.status=ROM.GCM_FINISHED;
		this.a.end();
		return tag;
	}

};

GCM.pack= function(b)
{ /* pack 4 bytes into a 32-bit Word */
		return (((b[0])&0xff)<<24)|((b[1]&0xff)<<16)|((b[2]&0xff)<<8)|(b[3]&0xff);
};

GCM.unpack=function(a)
{ /* unpack bytes from a word */
	var b=[];
	b[3]=(a&0xff);
	b[2]=((a>>>8)&0xff);
	b[1]=((a>>>16)&0xff);
	b[0]=((a>>>24)&0xff);
	return b;
};

GCM.hex2bytes=function(s) 
{
	var len = s.length;
	var data = [];
	for (var i = 0; i < len; i += 2) 
		data[i / 2] = parseInt(s.substr(i,2),16);

	return data;
};
