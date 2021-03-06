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

/* test driver and function exerciser for ECDH API Functions only - suitable for testing Montgomery curves */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "ecdh.h"

int main()
{   
  int i,j=0,res;
  int result;
  unsigned long ran;
  char *pp="M0ng00se";
  /* These octets are automatically protected against buffer overflow attacks */
  /* Note salt must be big enough to include an appended word */
  /* Note ECIES ciphertext C must be big enough to include at least 1 appended block */
  /* Recall EFS is field size in bytes. So EFS=32 for 256-bit curve */
  char s0[EGS],s1[EGS],w0[2*EFS+1],w1[2*EFS+1],z0[EFS],z1[EFS],raw[100],key[EAS],salt[32],pw[20];
  octet S0={0,sizeof(s0),s0};
  octet S1={0,sizeof(s1),s1};
  octet W0={0,sizeof(w0),w0};
  octet W1={0,sizeof(w1),w1};
  octet Z0={0,sizeof(z0),z0};
  octet Z1={0,sizeof(z1),z1};
  octet RAW={0,sizeof(raw),raw};
  octet KEY={0,sizeof(key),key};
  octet SALT={0,sizeof(salt),salt};
  octet PW={0,sizeof(pw),pw};

  /* Crypto Strong RNG */
  csprng RNG;                
  time((time_t *)&ran);
  /* fake random seed source */
  RAW.len=100;				
  RAW.val[0]=ran;
  RAW.val[1]=ran>>8;
  RAW.val[2]=ran>>16;
  RAW.val[3]=ran>>24;
  for (i=4;i<100;i++) RAW.val[i]=i;

  CREATE_CSPRNG(&RNG,&RAW);   /* initialise strong RNG */

  SALT.len=8;
  for (i=0;i<8;i++) SALT.val[i]=i+1;  // set Salt

  printf("Alice's Passphrase= %s\n",pp);

  OCT_clear(&PW);
  OCT_jstring(&PW,pp);   // set Password from string

  /* private key S0 of size EGS bytes derived from Password and Salt */
  PBKDF2(&PW,&SALT,1000,EGS,&S0);
  printf("Alices private key= 0x"); OCT_output(&S0);

  /* Generate Key pair S/W */
  ECP_KEY_PAIR_GENERATE(NULL,&S0,&W0); 

  res=ECP_PUBLIC_KEY_VALIDATE(1,&W0);
  if (res!=0)
  {
    printf("Alice's ECP Public Key is invalid!\n");
    return 1;
  }

  printf("Alice's public key= 0x");  OCT_output(&W0);

  /* Random private key for other party */
  ECP_KEY_PAIR_GENERATE(&RNG,&S1,&W1);
  printf("Servers private key= 0x");  OCT_output(&S1);
  printf("Servers public key= 0x");   OCT_output(&W1);

  res=ECP_PUBLIC_KEY_VALIDATE(1,&W1);
  if (res!=0)
  {
    printf("Server's ECP Public Key is invalid!\n");
    return 1;
  }

  /* Calculate common key using DH - IEEE 1363 method */

  ECPSVDP_DH(&S0,&W1,&Z0);
  ECPSVDP_DH(&S1,&W0,&Z1);
  
  if (!OCT_comp(&Z0,&Z1))
  {
    printf("*** ECPSVDP-DH Failed\n");
    return 1;
  }

  KDF2(&Z0,NULL,EAS,&KEY);

  printf("Alice's DH Key=  0x"); OCT_output(&KEY);
  printf("Servers DH Key=  0x"); OCT_output(&KEY);

  printf("SUCCESS\n");
  return 0;
}

