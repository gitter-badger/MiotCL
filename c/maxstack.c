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
	How to determine maximum stack usage
	1. Compile this file *with no optimization*, for example gcc -c maxstack.c
	2. Rename your main() function to mymain()
	3. Compile with normal level of optimization, linking to maxstack.o for example gcc maxstack.o -O3 myprogram.c -o myprogam
	4. Execute myprogram
	5. Program runs, at end prints out maximum stack usage

	Caveat Code!
	Mike Scott October 2014
*/

#include <stdio.h>

#define MAXSTACK 65536  /* greater than likely stack requirement */

extern void mymain();

void start()
{
	char stack[MAXSTACK];
	int i;
	for (i=0;i<MAXSTACK;i++) stack[i]=0x55;
}

void finish()
{
	char stack[MAXSTACK];
	int i;
	for (i=0;i<MAXSTACK;i++)
		if (stack[i]!=0x55) break;
	printf("Max Stack usage = %d\n",MAXSTACK-i);
}

int main()
{
 start();

 mymain();

 finish();
 return 0;
}
