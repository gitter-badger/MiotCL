copy miotcl_.h miotcl.h

cl /c /O2 big.c
cl /c /O2 fp.c
cl /c /O2 ecp.c
cl /c /O2 hash.c
cl /c /O2 rand.c
cl /c /O2 aes.c
cl /c /O2 gcm.c
cl /c /O2 oct.c
cl /c /O2 rom.c
cl /c /O2 fp.c
cl /c /O2 fp2.c
cl /c /O2 ecp2.c
cl /c /O2 fp4.c
cl /c /O2 fp12.c
cl /c /O2 pair.c

del miotcl.lib
lib /OUT:miotcl.lib big.obj fp.obj ecp.obj hash.obj
lib /OUT:miotcl.lib miotcl.lib rand.obj aes.obj gcm.obj oct.obj rom.obj

lib /OUT:miotcl.lib miotcl.lib pair.obj fp2.obj ecp2.obj fp4.obj fp12.obj

cl /O2 testmpin.c mpin.c miotcl.lib

del miotcl.h
del *.obj
