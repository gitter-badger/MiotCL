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


import sys, os
import unittest
from mpin import *
import json
import hashlib

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

lenEF = 12 * PFS
E = ffi.new("octet*")
Eval = ffi.new("char []", lenEF)
E[0].val = Eval
E[0].max = lenEF  
E[0].len = lenEF

F = ffi.new("octet*")
Fval = ffi.new("char []", lenEF)    
F[0].val = Fval
F[0].max = lenEF  
F[0].len = lenEF

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

class TestMPIN(unittest.TestCase):
    """Tests M-Pin crypto code"""

    def setUp(self):
        
        # Form MPin ID
        endUserData = {
            "issued": "2013-10-19T06:12:28Z",
            "userID": "testUser@certivox.com",
            "mobile": 1,
            "salt": "e985da112a378c222cfc2f7226097b0c"
        }
        mpin_id = json.dumps(endUserData)   

        self.MPIN_ID = ffi.new("octet*")
        self.MPIN_IDval =  ffi.new("char [%s]" % len(mpin_id), mpin_id)
        self.MPIN_ID[0].val = self.MPIN_IDval
        self.MPIN_ID[0].max = len(mpin_id)
        self.MPIN_ID[0].len = len(mpin_id)
    
        # Hash value of MPIN_ID
        self.HASH_MPIN_ID = ffi.new("octet*")
        self.HASH_MPIN_IDval = ffi.new("char []",  HASH_BYTES)
        self.HASH_MPIN_ID[0].val = self.HASH_MPIN_IDval
        self.HASH_MPIN_ID[0].max = HASH_BYTES    
        self.HASH_MPIN_ID[0].len = HASH_BYTES
        libmpin.MPIN_HASH_ID(self.MPIN_ID, self.HASH_MPIN_ID)        

        # Assign a seed value
        seedHex = "3ade3d4a5c698e8910bf92f25d97ceeb7c25ed838901a5cb5db2cf25434c1fe76c7f79b7af2e5e1e4988e4294dbd9bd9fa3960197fb7aec373609fb890d74b16a4b14b2ae7e23b75f15d36c21791272372863c4f8af39980283ae69a79cf4e48e908f9e0"
        self.seed = seedHex.decode("hex")
        self.RAW = ffi.new("octet*")
        self.RAWval = ffi.new("char [%s]" % len(self.seed), self.seed)
        self.RAW[0].val = self.RAWval
        self.RAW[0].len = len(self.seed)
        self.RAW[0].max = len(self.seed)

        self.date = 16238
        
    def test_1(self):
        """test_1 Good PIN and good token"""
        vectors = json.load(open("./MPINTestVectors.json", "r"))
        for vector in vectors:
            print "Test vector {}".format(vector['test_no'])
        
            PIN1 = vector['PIN1']
            PIN2 = vector['PIN2']
            date = vector['DATE']
    
            # random number generator
            RNG = ffi.new("csprng*")
            libmpin.CREATE_CSPRNG(RNG,self.RAW)
    
            MS1_HEX = vector['MS1']
            MS2_HEX = vector['MS2']
        
            ms1_bin = MS1_HEX.decode("hex") 
            MS1 = ffi.new("octet*")
            MS1val = ffi.new("char [%s]" % len(ms1_bin), ms1_bin)
            MS1[0].val = MS1val
            MS1[0].max = PGS    
            MS1[0].len = PGS
        
            ms2_bin = MS2_HEX.decode("hex")     
            MS2 = ffi.new("octet*")
            MS2val = ffi.new("char [%s]" % len(ms2_bin), ms2_bin)
            MS2[0].val = MS2val
            MS2[0].max = PGS    
            MS2[0].len = PGS
        
            # Generate server secret shares 
            rtn = libmpin.MPIN_GET_SERVER_SECRET(MS1,SS1)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['SS1'], toHex(SS1))            
            rtn = libmpin.MPIN_GET_SERVER_SECRET(MS2,SS2)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['SS2'], toHex(SS2))
            
            # Combine server secret shares 
            rtn = libmpin.MPIN_RECOMBINE_G2(SS1, SS2, SERVER_SECRET)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['SERVER_SECRET'], toHex(SERVER_SECRET))

            mpin_id = vector['MPIN_ID_HEX'].decode("hex")
            MPIN_ID = ffi.new("octet*")
            MPIN_IDval =  ffi.new("char [%s]" % len(mpin_id), mpin_id)
            MPIN_ID[0].val = MPIN_IDval
            MPIN_ID[0].max = len(mpin_id)
            MPIN_ID[0].len = len(mpin_id)
        
            # Hash value of MPIN_ID
            HASH_MPIN_ID = ffi.new("octet*")
            HASH_MPIN_IDval = ffi.new("char []",  HASH_BYTES)
            HASH_MPIN_ID[0].val = HASH_MPIN_IDval
            HASH_MPIN_ID[0].max = HASH_BYTES    
            HASH_MPIN_ID[0].len = HASH_BYTES
            libmpin.MPIN_HASH_ID(MPIN_ID, HASH_MPIN_ID)
            self.assertEqual(vector['HASH_MPIN_ID_HEX'], toHex(HASH_MPIN_ID))
            
            # Generate client secret shares 
            rtn = libmpin.MPIN_GET_CLIENT_SECRET(MS1,HASH_MPIN_ID,CS1)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['CS1'], toHex(CS1))            
            rtn = libmpin.MPIN_GET_CLIENT_SECRET(MS2,HASH_MPIN_ID,CS2)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['CS2'], toHex(CS2))
            
            # Combine client secret shares : TOKEN is the full client secret 
            rtn = libmpin.MPIN_RECOMBINE_G1(CS1, CS2, TOKEN)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['CLIENT_SECRET'], toHex(TOKEN))
            
            # Generate Time Permit shares
            rtn = libmpin.MPIN_GET_CLIENT_PERMIT(date,MS1,HASH_MPIN_ID,TP1)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['TP1'], toHex(TP1))            
            rtn = libmpin.MPIN_GET_CLIENT_PERMIT(date,MS2,HASH_MPIN_ID,TP2)
            self.assertEqual(rtn, 0)        
            self.assertEqual(vector['TP2'], toHex(TP2))
            
            # Combine Time Permit shares 
            rtn = libmpin.MPIN_RECOMBINE_G1(TP1, TP2, TIME_PERMIT)
            self.assertEqual(rtn, 0)        
            self.assertEqual(vector['TIME_PERMIT'], toHex(TIME_PERMIT))
            
            # Client extracts PIN from secret to create Token 
            rtn = libmpin.MPIN_EXTRACT_PIN(MPIN_ID, PIN1, TOKEN)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['TOKEN'], toHex(TOKEN))

            x = vector['X'].decode("hex")
            X = ffi.new("octet*")
            Xval = ffi.new("char [%s]" % PGS, x)
            X[0].val = Xval
            X[0].max = PGS    
            X[0].len = PGS
            
            # Client first pass. Use X value from test vectors
            rtn = libmpin.MPIN_CLIENT_1(date,MPIN_ID,ffi.NULL,X,PIN2,TOKEN,SEC,U,UT,TIME_PERMIT)
            self.assertEqual(rtn, 0)
            self.assertEqual(vector['X'], toHex(X))
            self.assertEqual(vector['U'], toHex(U))
            self.assertEqual(vector['UT'], toHex(UT))
            self.assertEqual(vector['SEC'], toHex(SEC))                        
            
            # Server calculates H(ID) and H(T|H(ID))
            libmpin.MPIN_SERVER_1(date, MPIN_ID,HID,HTID);        
          
            # Server generates Random number Y and sends it to Client 
            # rtn = libmpin.MPIN_RANDOM_GENERATE(RNG,Y)
            # self.assertEqual(rtn, 0)                

            # Use Y value from test vectors
            y = vector['Y'].decode("hex")
            Y = ffi.new("octet*")
            Yval = ffi.new("char [%s]" % PGS, y)
            Y[0].val = Yval
            Y[0].max = PGS    
            Y[0].len = PGS
          
            # Client second pass 
            rtn = libmpin.MPIN_CLIENT_2(X,Y,SEC)
            self.assertEqual(rtn, 0)                
            self.assertEqual(vector['V'], toHex(SEC))
            
            # Server second pass
            rtn = libmpin.MPIN_SERVER_2(date,HID,HTID,Y,SERVER_SECRET,U,UT,SEC,E,F)
            self.assertEqual(rtn, vector['SERVER_OUTPUT'])
    
if __name__ == '__main__':
    # Run tests
    unittest.main()    
