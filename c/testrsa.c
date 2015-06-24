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

/* test driver and function exerciser for RSA API Functions */
/* gcc -std=c99 -O3 testrsa.c rsa.c miotcl.a -o testrsa.exe */

 
#include <stdio.h>
#include <time.h>
#include "rsa.h"

int main()
{   
    int i,bytes,res;
	unsigned long ran;
 	char m[RFS],ml[RFS],c[RFS],e[RFS],raw[100];
    rsa_public_key pub;
    rsa_private_key priv;
    csprng RNG;  
	octet M={0,sizeof(m),m};
	octet ML={0,sizeof(ml),ml};
	octet C={0,sizeof(c),c};
	octet E={0,sizeof(e),e};
	octet RAW={0,sizeof(raw),raw};

	time((time_t *)&ran);

    RAW.len=100;				/* fake random seed source */
    RAW.val[0]=ran;
    RAW.val[1]=ran>>8;
    RAW.val[2]=ran>>16;
    RAW.val[3]=ran>>24;
    for (i=4;i<100;i++) RAW.val[i]=i;

    CREATE_CSPRNG(&RNG,&RAW);   /* initialise strong RNG */
//for (i=0;i<10;i++)
//{

	printf("Generating public/private key pair\n");
    RSA_KEY_PAIR(&RNG,65537,&priv,&pub);

	printf("Encrypting test string\n");
	OCT_jstring(&M,(char *)"Hello World\n");
	OAEP_ENCODE(&M,&RNG,NULL,&E); /* OAEP encode message m to e  */

	RSA_ENCRYPT(&pub,&E,&C);     /* encrypt encoded message */
	printf("Ciphertext= "); OCT_output(&C); 

	printf("Decrypting test string\n");
    RSA_DECRYPT(&priv,&C,&ML);   /* ... and then decrypt it */

    OAEP_DECODE(NULL,&ML);    /* decode it */
	OCT_output_string(&ML);

    OCT_clear(&M); OCT_clear(&ML);   /* clean up afterwards */
    OCT_clear(&C); OCT_clear(&RAW); OCT_clear(&E); 
//}
	KILL_CSPRNG(&RNG);

	RSA_PRIVATE_KEY_KILL(&priv);

	return 0;
}
