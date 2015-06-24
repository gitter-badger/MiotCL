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

console.log("Testing sha256");
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

// Turn on DEBUG mode in MPINAuth
MPINAuth.DEBUG = DEBUG;

// Compare M-Pin sha256 with crypto version
for (i=0;i<100;i++)
  {
    console.log("Test "+i);
    // Data for mpin_id
    var randomUser = crypto.randomBytes(32);
    var userID = randomUser.toString("hex");
    var cur_date = new Date();
    var issued = cur_date.toISOString();
    var salt = crypto.randomBytes(16);
    var salt_hex = salt.toString("hex");
    
    // Form MPin ID
    var endUserdata = {
      "issued": issued,
      "userID": userID,
      "mobile": 1,
      "salt": salt_hex
    };
    mpin_id = JSON.stringify(endUserdata);
    hash_mpin_id_hex1 = crypto.createHash('sha256').update(mpin_id).digest('hex');
    
    var mpin_id_bytes =MPIN.stringtobytes(mpin_id);  
    var hash_mpin_id_bytes=[];
    hash_mpin_id_bytes = MPIN.HASH_ID(mpin_id_bytes)
    var hash_mpin_id_hex2 = MPIN.bytestostring(hash_mpin_id_bytes);

    if (DEBUG){console.log("hash_mpin_id_hex1: "+hash_mpin_id_hex1 + "\nhash_mpin_id_hex2: "+hash_mpin_id_hex2);}
    try
      {
        assert.equal(hash_mpin_id_hex1, hash_mpin_id_hex2, "sha256 test failed");
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
