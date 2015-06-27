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

public class TestRSA
{ 

	public static void main(String[] args) 
	{
		int i;
		int RFS=RSA.RFS;

		String message="Hello World\n";

		rsa_public_key pub=new rsa_public_key(ROM.FFLEN);
		rsa_private_key priv=new rsa_private_key(ROM.HFLEN);

		byte[] ML=new byte[RFS];
		byte[] C=new byte[RFS];
		byte[] RAW=new byte[100];
	
		RAND rng=new RAND();

		rng.clean();
		for (i=0;i<100;i++) RAW[i]=(byte)(i);

		rng.seed(100,RAW);
//for (i=0;i<10;i++)
//{
		System.out.println("Generating public/private key pair");
		RSA.KEY_PAIR(rng,65537,priv,pub);

		byte[] M=message.getBytes();
		System.out.print("Encrypting test string\n");
		byte[] E=RSA.OAEP_ENCODE(M,rng,null); /* OAEP encode message m to e  */

		RSA.ENCRYPT(pub,E,C);     /* encrypt encoded message */

		System.out.print("Ciphertext= 0x"); RSA.printBinary(C);

		System.out.print("Decrypting test string\n");
		RSA.DECRYPT(priv,C,ML); 
		byte[] MS=RSA.OAEP_DECODE(null,ML); /* OAEP encode message m to e  */

		message=new String(MS);
		System.out.print(message);
//}
		RSA.PRIVATE_KEY_KILL(priv);
	}
}
