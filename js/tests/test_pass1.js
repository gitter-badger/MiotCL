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

console.log("Testing pass one request generation");
var WebSocket = require('ws');
var assert = require('assert');
var http = require('http');
var fs = require('fs');
var crypto = require('crypto');

// Javascript files from the PIN pad  are included here:
eval(fs.readFileSync('../DBIG.js')+'');
eval(fs.readFileSync('../BIG.js')+'');
eval(fs.readFileSync('../FP.js')+'');
eval(fs.readFileSync('../ROM.js')+'');
eval(fs.readFileSync('../HASH.js')+'');
eval(fs.readFileSync('../RAND.js')+'');
eval(fs.readFileSync('../AES.js')+'');
eval(fs.readFileSync('../GCM.js')+'');
eval(fs.readFileSync('../ECP.js')+'');
eval(fs.readFileSync('../FP2.js')+'');
eval(fs.readFileSync('../ECP2.js')+'');
eval(fs.readFileSync('../FP4.js')+'');
eval(fs.readFileSync('../FP12.js')+'');
eval(fs.readFileSync('../PAIR.js')+'');
eval(fs.readFileSync('./MPIN.js')+'');
eval(fs.readFileSync('../MPINAuth.js')+'');

// Configuration file
eval(fs.readFileSync('./config.js')+''); 

// Load test vectors
var vectors = require('./testVectors.json');

// Turn on DEBUG mode in MPINAuth
MPINAuth.DEBUG = DEBUG;

var RAW=[];
for (i=0;i<100;i++) RAW[i]=i;
var RAW_hex = MPIN.bytestostring(RAW);

// Initiaize RNG
MPINAuth.initializeRNG(RAW_hex);
  
for(var vector in vectors)
  {
    console.log("Test "+vectors[vector].test_no);
    if (DEBUG){console.log("MPIN_ID_HEX "+vectors[vector].MPIN_ID_HEX);}
    if (DEBUG){console.log("TIME_PERMIT "+vectors[vector].TIME_PERMIT);}
    if (DEBUG){console.log("TOKEN "+vectors[vector].TOKEN);}
    if (DEBUG){console.log("PIN2 "+vectors[vector].PIN2);}
    if (DEBUG){console.log("X "+vectors[vector].X);}
    if (DEBUG){console.log("U "+vectors[vector].U);}
    if (DEBUG){console.log("UT "+vectors[vector].UT);}
    var pass1 = MPINAuth.pass1Request(vectors[vector].MPIN_ID_HEX, vectors[vector].TOKEN, vectors[vector].TIME_PERMIT, vectors[vector].PIN2, vectors[vector].X, vectors[vector].DATE);
    if (DEBUG){console.dir("pass1 "+pass1);}
    try
      {
        assert.equal(pass1.U, vectors[vector].U, "U generation failed");
        assert.equal(pass1.UT, vectors[vector].UT, "UT generation failed");
      }
    catch(err)
      {
        txt="Error description: " + err.message;
        console.error(txt);    
        var cur_date = new Date();
        console.log("TEST FAILED: "+cur_date.toISOString());
        return;
      }
  }
console.log("TEST PASSED");
