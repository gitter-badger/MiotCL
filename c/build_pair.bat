copy miotcl_.h miotcl.h

gcc -std=c99 -c -O3 big.c
gcc -std=c99 -c -O3 fp.c
gcc -std=c99 -c -O3 ecp.c
gcc -std=c99 -c -O3 hash.c
gcc -std=c99 -c -O3 rand.c
gcc -std=c99 -c -O3 aes.c
gcc -std=c99 -c -O3 gcm.c
gcc -std=c99 -c -O3 oct.c
gcc -std=c99 -c -O3 rom.c

gcc -std=c99 -c -O3 fp2.c
gcc -std=c99 -c -O3 ecp2.c
gcc -std=c99 -c -O3 fp4.c
gcc -std=c99 -c -O3 fp12.c
gcc -std=c99 -c -O3 pair.c

del miotcl.a
ar rc miotcl.a big.o fp.o ecp.o hash.o
ar r miotcl.a rand.o aes.o gcm.o oct.o rom.o

ar r miotcl.a pair.o fp2.o ecp2.o fp4.o fp12.o

gcc -std=c99 -O3 testmpin.c mpin.c miotcl.a -o testmpin.exe

del miotcl.h
del *.o
