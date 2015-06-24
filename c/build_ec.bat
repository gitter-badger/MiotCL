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

gcc -std=c99 -c -O3 ff.c

del miotcl.a
ar rc miotcl.a big.o fp.o ecp.o hash.o ff.o
ar r miotcl.a rand.o aes.o gcm.o oct.o rom.o

gcc -std=c99 -O3 testecm.c ecdh.c miotcl.a -o testecm.exe
gcc -std=c99 -O3 testecdh.c ecdh.c miotcl.a -o testecdh.exe
gcc -std=c99 -O3 testrsa.c rsa.c miotcl.a -o testrsa.exe

del miotcl.h
del *.o
