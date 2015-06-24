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

/**
 * @file rsa.h
 * @author Mike Scott and Kealan McCusker
 * @date 2nd June 2015
 * @brief RSA Header file for implementation of RSA protocol
 *
 * declares functions
 * 
 */

#ifndef RSA_H
#define RSA_H

#include "miotcl.h"

#define RFS MODBYTES*FFLEN /**< RSA Public Key Size in bytes */

/* RSA Auxiliary Functions */
/**	@brief Initialise a random number generator
 *
	@param R is a pointer to a cryptographically secure random number generator
	@param S is an input truly random seed value
 */
extern void CREATE_CSPRNG(csprng *R,octet *S);
/**	@brief Kill a random number generator
 *
	Deletes all internal state
	@param R is a pointer to a cryptographically secure random number generator
 */
extern void KILL_CSPRNG(csprng *R);
/**	@brief RSA Key Pair Generator
 *
	@param R is a pointer to a cryptographically secure random number generator
	@param e the encryption exponent
	@param PRIV the output RSA private key
	@param PUB the output RSA public key
 */
extern void RSA_KEY_PAIR(csprng *R,sign32 e,rsa_private_key* PRIV,rsa_public_key* PUB);
/**	@brief OAEP padding of a message prior to RSA encryption
 *
	@param M is the input message
	@param R is a pointer to a cryptographically secure random number generator
	@param P are input encoding parameter string (could be NULL)
	@param F is the output encoding, ready for RSA encryption
	@return 1 if OK, else 0
 */
extern int	OAEP_ENCODE(octet *M,csprng *R,octet *P,octet *F); 
/**	@brief OAEP unpadding of a message after RSA decryption
 *
	Unpadding is done in-place
	@param P are input encoding parameter string (could be NULL)
	@param F is input padded message, unpadded on output
	@return 1 if OK, else 0
 */
extern int  OAEP_DECODE(octet *P,octet *F);
/**	@brief RSA encryption of suitably padded plaintext
 *
	@param PUB the input RSA public key
	@param F is input padded message
	@param G is the output ciphertext
 */
extern void RSA_ENCRYPT(rsa_public_key* PUB,octet *F,octet *G); 
/**	@brief RSA decryption of ciphertext
 *
	@param PRIV the input RSA private key
	@param G is the input ciphertext
	@param F is output plaintext (requires unpadding)

 */
extern void RSA_DECRYPT(rsa_private_key* PRIV,octet *G,octet *F);  
/**	@brief Destroy an RSA private Key
 *
	@param PRIV the input RSA private key. Destroyed on output.
 */
extern void RSA_PRIVATE_KEY_KILL(rsa_private_key *PRIV);

#endif
