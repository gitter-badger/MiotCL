#!/usr/bin/env python

"""
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
"""


"""
mpin

This module use cffi to access the c functions in the mpin library.

There is also an example usage program in this file.

"""
import cffi
import platform

# MPIN Group Size 
PGS=32  
# MPIN Field Size 
PFS=32
G1=2*PFS+1
G2=4*PFS
# Hash Size
HASH_BYTES=32
# AES-GCM IV length
IVL = 12
# MPIN Symmetric Key Size 
PAS=16  

ffi = cffi.FFI()
ffi.cdef("""
typedef struct {
unsigned int ira[21];  /* random number...   */
int rndptr;   /* ...array & pointer */
unsigned int borrow;
int pool_ptr;
char pool[32];    /* random pool */
} csprng;

typedef struct
{
    int len;
    int max;
    char *val;
} octet;

extern unsigned int MPIN_GET_TIME(void);
extern void MPIN_Y(int,octet *,octet *);
extern void MPIN_HASH_ID(octet *,octet *);
extern int MPIN_EXTRACT_PIN(octet *,int,octet *);
extern int MPIN_CLIENT(int date,octet *CLIENT_ID,csprng *RNG,octet *X,int pin,octet *TOKEN,octet *SEC,octet *xID,octet *xCID,octet *PERMIT,  int TimeValue, octet *Y);
extern int MPIN_CLIENT_1(int,octet *,csprng *,octet *,int,octet *,octet *,octet *,octet *,octet *);
extern int MPIN_RANDOM_GENERATE(csprng *,octet *);
extern int MPIN_CLIENT_2(octet *,octet *,octet *);
extern void MPIN_SERVER_1(int,octet *,octet *,octet *);
extern int MPIN_SERVER_2(int,octet *,octet *,octet *,octet *,octet *,octet *,octet *,octet *,octet *);
extern int MPIN_SERVER(int date,octet *HID,octet *HTID,octet *Y,octet *SST,octet *xID,octet *xCID,octet *mSEC,octet *E,octet *F,octet *CID, int TimeValue);
extern int MPIN_RECOMBINE_G1(octet *,octet *,octet *);
extern int MPIN_RECOMBINE_G2(octet *,octet *,octet *);
extern int MPIN_KANGAROO(octet *,octet *);

extern int MPIN_ENCODING(csprng *,octet *);
extern int MPIN_DECODING(octet *);

extern unsigned int today(void);
extern void CREATE_CSPRNG(csprng *,octet *);
extern void KILL_CSPRNG(csprng *);
extern int MPIN_PRECOMPUTE(octet *,octet *,octet *,octet *);
extern int MPIN_SERVER_KEY(octet *,octet *,octet *,octet *,octet *,octet *);
extern int MPIN_CLIENT_KEY(octet *,octet *,int ,octet *,octet *,octet *,octet *);
extern int MPIN_GET_G1_MULTIPLE(csprng *,int,octet *,octet *,octet *);
extern int MPIN_GET_CLIENT_SECRET(octet *,octet *,octet *); 
extern int MPIN_GET_CLIENT_PERMIT(int,octet *,octet *,octet *); 
extern int MPIN_GET_SERVER_SECRET(octet *,octet *); 
extern int MPIN_TEST_PAIRING(octet *,octet *);
extern void hex2bytes(char *hex, char *bin);
extern void generateRandom(csprng*, octet*);
extern int generateOTP(csprng*);
extern void AES_GCM_ENCRYPT(octet *K,octet *IV,octet *H,octet *P,octet *C,octet *T);
extern void AES_GCM_DECRYPT(octet *K,octet *IV,octet *H,octet *C,octet *P,octet *T);

""")

if (platform.system() == 'Windows'):
    libmpin = ffi.dlopen("libmpin.dll")
elif (platform.system() == 'Darwin'):
    libmpin = ffi.dlopen("libmpin.dylib")
else:
    libmpin = ffi.dlopen("libmpin.so")
	
def toHex(octetValue):
    """Converts an octet type into a string

    Add all the values in an octet into an array. This arrays is then
    converted to a string and hex encoded.
    
    Args::
        
        octetValue. An octet type
           
    Returns::
        
        String

    Raises:
        Exception
    """    
    i = 0
    val = []
    while i < octetValue[0].len:
        val.append(octetValue[0].val[i])
        i = i+1
    return ''.join(val).encode("hex")

    
if __name__ == "__main__":
    # Print hex values
    DEBUG = False
    SINGLE_PASS = True
    TIME_PERMITS = True
    MPIN_FULL = False
    PIN_ERROR = True

    if TIME_PERMITS:
        date = libmpin.today()
    else:
        date = 0

    # Seed
    seedHex = "3ade3d4a5c698e8910bf92f25d97ceeb7c25ed838901a5cb5db2cf25434c1fe76c7f79b7af2e5e1e4988e4294dbd9bd9fa3960197fb7aec373609fb890d74b16a4b14b2ae7e23b75f15d36c21791272372863c4f8af39980283ae69a79cf4e48e908f9e0"
    seed = seedHex.decode("hex")

    # Identity
    identity = raw_input("Please enter identity:")
    MPIN_ID = ffi.new("octet*")
    MPIN_IDval =  ffi.new("char [%s]" % len(identity), identity)
    MPIN_ID[0].val = MPIN_IDval
    MPIN_ID[0].max = len(identity)
    MPIN_ID[0].len = len(identity)
    
    # Master Secret Shares
    MS1 = ffi.new("octet*")
    MS1val = ffi.new("char []", PGS)
    MS1[0].val = MS1val
    MS1[0].max = PGS    
    MS1[0].len = PGS
    
    MS2 = ffi.new("octet*")
    MS2val = ffi.new("char []", PGS)
    MS2[0].val = MS2val
    MS2[0].max = PGS    
    MS2[0].len = PGS

    # Hash value of MPIN_ID
    HASH_MPIN_ID = ffi.new("octet*")
    HASH_MPIN_IDval = ffi.new("char []",  HASH_BYTES)
    HASH_MPIN_ID[0].val = HASH_MPIN_IDval
    HASH_MPIN_ID[0].max = HASH_BYTES    
    HASH_MPIN_ID[0].len = HASH_BYTES

    # Client secret and shares 
    CS1 = ffi.new("octet*")
    CS1val = ffi.new("char []", G1)
    CS1[0].val = CS1val
    CS1[0].max = G1    
    CS1[0].len = G1
    
    CS2 = ffi.new("octet*")
    CS2val = ffi.new("char []", G1)    
    CS2[0].val = CS2val
    CS2[0].max = G1    
    CS2[0].len = G1

    SEC = ffi.new("octet*")
    SECval = ffi.new("char []", G1)    
    SEC[0].val = SECval
    SEC[0].max = G1    
    SEC[0].len = G1

    # Server secret and shares 
    SS1 = ffi.new("octet*")
    SS1val = ffi.new("char []", G2)    
    SS1[0].val = SS1val
    SS1[0].max = G2    
    SS1[0].len = G2

    SS2 = ffi.new("octet*")
    SS2val = ffi.new("char []", G2)
    SS2[0].val = SS2val
    SS2[0].max = G2    
    SS2[0].len = G2

    SERVER_SECRET = ffi.new("octet*")
    SERVER_SECRETval = ffi.new("char []", G2)
    SERVER_SECRET[0].val = SERVER_SECRETval
    SERVER_SECRET[0].max = G2    
    SERVER_SECRET[0].len = G2

    # Time Permit and shares 
    TP1 = ffi.new("octet*")
    TP1val = ffi.new("char []", G1)
    TP1[0].val = TP1val
    TP1[0].max = G1    
    TP1[0].len = G1

    TP2 = ffi.new("octet*")
    TP2val = ffi.new("char []", G1)
    TP2[0].val = TP2val
    TP2[0].max = G1    
    TP2[0].len = G1

    TIME_PERMIT = ffi.new("octet*")
    TIME_PERMITval = ffi.new("char []", G1)    
    TIME_PERMIT[0].val = TIME_PERMITval
    TIME_PERMIT[0].max = G1    
    TIME_PERMIT[0].len = G1

    # Token stored on computer 
    TOKEN = ffi.new("octet*")
    TOKENval = ffi.new("char []", G1)    
    TOKEN[0].val = TOKENval
    TOKEN[0].max = G1    
    TOKEN[0].len = G1

    # H(ID)
    HID = ffi.new("octet*")
    HIDval = ffi.new("char []", G1)    
    HID[0].val = HIDval
    HID[0].max = G1    
    HID[0].len = G1

    # H(T|H(ID))    
    HTID = ffi.new("octet*")
    HTIDval = ffi.new("char []", G1)    
    HTID[0].val = HTIDval
    HTID[0].max = G1    
    HTID[0].len = G1

    UT = ffi.new("octet*")
    UTval = ffi.new("char []", G1)
    UT[0].val = UTval
    UT[0].max = G1    
    UT[0].len = G1

    U = ffi.new("octet*")
    Uval = ffi.new("char []", G1)
    U[0].val = Uval
    U[0].max = G1    
    U[0].len = G1

    X = ffi.new("octet*")
    Xval = ffi.new("char []", PGS)    
    X[0].val = Xval
    X[0].max = PGS    
    X[0].len = PGS

    Y = ffi.new("octet*")
    Yval = ffi.new("char []", PGS)    
    Y[0].val = Yval
    Y[0].max = PGS    
    Y[0].len = PGS

    E = ffi.new("octet*")
    Eval = ffi.new("char []", 12*PFS)    
    E[0].val = Eval
    E[0].max = 12*PFS    
    E[0].len = 12*PFS

    F = ffi.new("octet*")
    Fval = ffi.new("char []", 12*PFS)    
    F[0].val = Fval
    F[0].max = 12*PFS    
    F[0].len = 12*PFS

    # MPIN Full
    R = ffi.new("octet*")
    Rval = ffi.new("char []", PGS)    
    R[0].val = Rval
    R[0].max = PGS    
    R[0].len = PGS

    W = ffi.new("octet*")
    Wval = ffi.new("char []", PGS)    
    W[0].val = Wval
    W[0].max = PGS    
    W[0].len = PGS

    Z = ffi.new("octet*")
    Zval = ffi.new("char []", G1)
    Z[0].val = Zval
    Z[0].max = G1    
    Z[0].len = G1

    T = ffi.new("octet*")
    Tval = ffi.new("char []", G1)
    T[0].val = Tval
    T[0].max = G1    
    T[0].len = G1

    TATE1 = ffi.new("octet*")
    TATE1val = ffi.new("char []", 12*PFS)
    TATE1[0].val = TATE1val
    TATE1[0].max = 12*PFS
    TATE1[0].len = 12*PFS

    TATE2 = ffi.new("octet*")
    TATE2val = ffi.new("char []", 12*PFS)
    TATE2[0].val = TATE2val
    TATE2[0].max = 12*PFS
    TATE2[0].len = 12*PFS

    SK = ffi.new("octet*")
    SKval = ffi.new("char []", PAS)
    SK[0].val = SKval
    SK[0].max = PAS
    SK[0].len = PAS

    CK = ffi.new("octet*")
    CKval = ffi.new("char []", PAS)
    CK[0].val = CKval
    CK[0].max = PAS
    CK[0].len = PAS

    if date:
        prHID = HTID
        if not PIN_ERROR:
            HID = ffi.NULL
            U = ffi.NULL            
    else:
        HTID = ffi.NULL
        UT = ffi.NULL
        prHID = HID
        TIME_PERMIT = ffi.NULL

    if not PIN_ERROR:
        E = ffi.NULL
        F = ffi.NULL
        
    # Assign a seed value
    RAW = ffi.new("octet*")
    RAWval = ffi.new("char [%s]" % len(seed), seed)
    RAW[0].val = RAWval
    RAW[0].len = len(seed)
    RAW[0].max = len(seed)
    if DEBUG:
        print "RAW: %s" % toHex(RAW)

    # random number generator
    RNG = ffi.new("csprng*")
    libmpin.CREATE_CSPRNG(RNG,RAW)

    # Hash MPIN_ID
    libmpin.MPIN_HASH_ID(MPIN_ID, HASH_MPIN_ID)
    if DEBUG:
        print "MPIN_ID: %s" % toHex(MPIN_ID)
        print "HASH_MPIN_ID: %s" % toHex(HASH_MPIN_ID)
        
    # Generate master secret for Certivox and Customer
    rtn = libmpin.MPIN_RANDOM_GENERATE(RNG,MS1)
    if rtn != 0:
      print "libmpin.MPIN_RANDOM_GENERATE(RNG,MS1) Error %s", rtn
    rtn = libmpin.MPIN_RANDOM_GENERATE(RNG,MS2)
    if rtn != 0:
        print "libmpin.MPIN_RANDOM_GENERATE(RNG,MS2) Error %s" % rtn
    if DEBUG:
        print "MS1: %s" % toHex(MS1)
        print "MS2: %s" % toHex(MS2)        

    # Generate server secret shares 
    rtn = libmpin.MPIN_GET_SERVER_SECRET(MS1,SS1)
    if rtn != 0:
        print "libmpin.MPIN_GET_SERVER_SECRET(MS1,SS1) Error %s" % rtn
    rtn = libmpin.MPIN_GET_SERVER_SECRET(MS2,SS2)
    if rtn != 0:
        print "libmpin.MPIN_GET_SERVER_SECRET(MS2,SS2) Error %s" % rtn
    if DEBUG:
        print "SS1: %s" % toHex(SS1)
        print "SS2: %s" % toHex(SS2)        
  
    # Combine server secret shares
    rtn = libmpin.MPIN_RECOMBINE_G2(SS1, SS2, SERVER_SECRET)
    if rtn != 0:
        print "libmpin.MPIN_RECOMBINE_G2( SS1, SS2, SERVER_SECRET) Error %s" % rtn
    if DEBUG:
        print "SERVER_SECRET: %s" % toHex(SERVER_SECRET)
        
    # Generate client secret shares 
    rtn = libmpin.MPIN_GET_CLIENT_SECRET(MS1,HASH_MPIN_ID,CS1)
    if rtn != 0:
        print "libmpin.MPIN_GET_CLIENT_SECRET(MS1,HASH_MPIN_ID,CS1) Error %s" % rtn
    rtn = libmpin.MPIN_GET_CLIENT_SECRET(MS2,HASH_MPIN_ID,CS2)
    if rtn != 0:
        print "libmpin.MPIN_GET_CLIENT_SECRET(MS2,HASH_MPIN_ID,CS2) Error %s" % rtn
    if DEBUG:
        print "CS1: %s" % toHex(CS1)
        print "CS2: %s" % toHex(CS2)        
  
    # Combine client secret shares : TOKEN is the full client secret 
    rtn = libmpin.MPIN_RECOMBINE_G1( CS1, CS2, TOKEN)
    if rtn != 0:
        print "libmpin.MPIN_RECOMBINE_G1( CS1, CS2, TOKEN) Error %s" % rtn
    print "Client Secret: %s" % toHex(TOKEN)
  
    # Generate Time Permit shares
    if DEBUG:
        print "Date %s" % date
    rtn = libmpin.MPIN_GET_CLIENT_PERMIT(date,MS1,HASH_MPIN_ID,TP1)
    if rtn != 0:
        print "libmpin.MPIN_GET_CLIENT_PERMIT(date,MS1,HASH_MPIN_ID,TP1) Error %s" % rtn
    rtn = libmpin.MPIN_GET_CLIENT_PERMIT(date,MS2,HASH_MPIN_ID,TP2)
    if rtn != 0:
        print "libmpin.MPIN_GET_CLIENT_PERMIT(date,MS2,HASH_MPIN_ID,TP2) Error %s" % rtn
    if DEBUG:
        print "TP1: %s" % toHex(TP1)
        print "TP2: %s" % toHex(TP2)        
  
    # Combine Time Permit shares 
    rtn = libmpin.MPIN_RECOMBINE_G1( TP1, TP2, TIME_PERMIT)
    if rtn != 0:
        print "libmpin.MPIN_RECOMBINE_G1(TP1, TP2, TIME_PERMIT) Error %s" % rtn
    if DEBUG:
        print "TIME_PERMIT: %s" % toHex(TIME_PERMIT)
  
    # Client extracts PIN from secret to create Token
    PIN = int(raw_input("Please enter four digit PIN to create M-Pin Token:"))
    rtn = libmpin.MPIN_EXTRACT_PIN(MPIN_ID, PIN, TOKEN)
    if rtn != 0:
        print "libmpin.MPIN_EXTRACT_PIN( MPIN_ID, PIN, TOKEN) Error %s" % rtn
    print "Token: %s" % toHex(TOKEN)

    if SINGLE_PASS:
        print "M-Pin Single Pass"
        PIN = int(raw_input("Please enter PIN to authenticate:"))        
        TimeValue = libmpin.MPIN_GET_TIME()
        if DEBUG:
            print "TimeValue %s" % TimeValue

        # Client precomputation
        if MPIN_FULL:
            libmpin.MPIN_PRECOMPUTE(TOKEN,HASH_MPIN_ID,TATE1,TATE2)

        # Client MPIN
        rtn = libmpin.MPIN_CLIENT(date, MPIN_ID, RNG, X, PIN, TOKEN, SEC, U, UT, TIME_PERMIT, TimeValue, Y)
        if rtn != 0:
            print "MPIN_CLIENT ERROR %s" % rtn
        if DEBUG:
            print "X: %s" % toHex(X)

        # Client sends Z=r.ID to Server
        if MPIN_FULL:
            libmpin.MPIN_GET_G1_MULTIPLE(RNG,1,R,HASH_MPIN_ID,Z)
        
        # Server MPIN
        rtn = libmpin.MPIN_SERVER(date, HID, HTID, Y, SERVER_SECRET, U, UT, SEC, E, F, MPIN_ID, TimeValue)
        if rtn != 0:
            print "ERROR: Single Pass %s is not authenticated" % identity
            if PIN_ERROR:
               err=libmpin.MPIN_KANGAROO(E,F)
               print "Client PIN error %d " % err
        else:
            print "SUCCESS: Single Pass %s is authenticated" % identity

        # Server sends T=w.ID to client
        if MPIN_FULL:
            libmpin.MPIN_GET_G1_MULTIPLE(RNG,0,W,prHID,T)
            print "T: %s" % toHex(T)

        if MPIN_FULL:
            libmpin.MPIN_CLIENT_KEY(TATE1,TATE2,PIN,R,X,T,CK)
            print "Client Key: %s" % toHex(CK)

            libmpin.MPIN_SERVER_KEY(Z,SERVER_SECRET,W,U,UT,SK)
            print "Server Key: %s" % toHex(SK)
     
    else:
        print "M-Pin Multi Pass"
        PIN = int(raw_input("Please enter PIN to authenticate:"))
        if MPIN_FULL:
            rtn = libmpin.MPIN_PRECOMPUTE(TOKEN,HASH_MPIN_ID,TATE1,TATE2)
            if rtn != 0:
                print "MPIN_PERCOMPUTE  ERROR %s" % rtn
        
        # Client first pass
        rtn = libmpin.MPIN_CLIENT_1(date, MPIN_ID, RNG, X, PIN, TOKEN, SEC, U, UT, TIME_PERMIT)
        if rtn != 0:
            print "MPIN_CLIENT_1  ERROR %s" % rtn
        if DEBUG:
            print "X: %s" % toHex(X)
    
        # Server calculates H(ID) and H(T|H(ID)) (if time permits enabled),
        # and maps them to points on the curve HID and HTID resp. 
        libmpin.MPIN_SERVER_1(date, MPIN_ID, HID, HTID);
      
        # Server generates Random number Y and sends it to Client 
        rtn = libmpin.MPIN_RANDOM_GENERATE(RNG,Y)
        if rtn != 0:
            print "libmpin.MPIN_RANDOM_GENERATE(RNG,Y) Error %s" % rtn
        if DEBUG:
            print "Y: %s" % toHex(Y)
      
        # Client second pass 
        rtn = libmpin.MPIN_CLIENT_2(X,Y,SEC)
        if rtn != 0:
            print "libmpin.MPIN_CLIENT_2(X,Y,SEC) Error %s" % rtn
        if DEBUG:
            print "V: %s" % toHex(SEC)
    
        # Server second pass
        rtn = libmpin.MPIN_SERVER_2(date, HID, HTID, Y, SERVER_SECRET, U, UT, SEC, E, F);
        if rtn != 0:
            print "ERROR: Multi Pass %s is not authenticated" % identity
            if PIN_ERROR:
                err=libmpin.MPIN_KANGAROO(E,F)
                print "Client PIN error %d " % err
        else:
            print "SUCCESS: Multi Pass %s is authenticated" % identity

        # Client sends Z=r.ID to Server
        if MPIN_FULL:
            rtn = libmpin.MPIN_GET_G1_MULTIPLE(RNG,1,R,HASH_MPIN_ID,Z)
            if rtn != 0:
                print "ERROR: Generating Z %s" % rtn

        # Server sends T=w.ID to client
        if MPIN_FULL:
            libmpin.MPIN_GET_G1_MULTIPLE(RNG,0,W,prHID,T)

            libmpin.MPIN_CLIENT_KEY(TATE1,TATE2,PIN,R,X,T,CK)
            print "Client Key: %s" % toHex(CK)

            libmpin.MPIN_SERVER_KEY(Z,SERVER_SECRET,W,U,UT,SK)
            print "Server Key: %s" % toHex(SK)


