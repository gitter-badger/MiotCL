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

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include "miotcl.h"
#include "utils.h"

void hex2bytes(char *hex, char *bin)
{
  int i;
  char v;
  int len=strlen(hex);
  for (i = 0; i < len/2; i++) {
    char c = hex[2*i];
    if (c >= '0' && c <= '9') {
        v = c - '0';
    } else if (c >= 'A' && c <= 'F') {
        v = c - 'A' + 10;
    } else if (c >= 'a' && c <= 'f') {
        v = c - 'a' + 10;
    } else {
        v = 0;
    }
    v <<= 4;
    c = hex[2*i + 1];
    if (c >= '0' && c <= '9') {
        v += c - '0';
    } else if (c >= 'A' && c <= 'F') {
        v += c - 'A' + 10;
    } else if (c >= 'a' && c <= 'f') {
        v += c - 'a' + 10;
    } else {
        v = 0;
    }
    bin[i] = v;
  }
}

/*! \brief Generate a random six digit one time password
 *
 *  Generates a random six digit one time password
 * 
 *  @param  RNG             random number generator
 *  @return OTP             One Time Password
 */
int generateOTP(csprng* RNG)
{
  int OTP=0;

  int i = 0;
  int val = 0;
  char byte[6] = {0};

  /* Generate random 6 digit random value */
  for (i=0;i<6;i++)
    {
       byte[i]=RAND_byte(RNG);
       val = byte[i];
       OTP = ((abs(val) % 10) * pow(10.0,i)) + OTP;
    }

  return OTP;
}

/*! \brief Generate a random number
 *
 *  Generate a random number
 * 
 *  @param  RNG             random number generator
 *  @return randomValue     random number
 */
void generateRandom(csprng *RNG,octet *randomValue)
{
  int i;
  for (i=0;i<randomValue->len;i++)
    randomValue->val[i]=RAND_byte(RNG);
}


