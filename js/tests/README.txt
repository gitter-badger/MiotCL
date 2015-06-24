This directory contains the file MPINAuth.js 
which is example of how to use the MiotCL 
JavaScript in order to authenticate with an 
M-Pin server. An example of how to use these
functions in given in TestMPINAuth.js and can
be run like so;

node TestMPINAuth.js

There are tests for the interaction between the 
JavaScript and C code using test vectors.


################################################

Test Vectors:

1. Install these node.js modules;

   npm install ws
   npm install assert
   npm install http
   npm install fs
   npm install crypto

2. Configuration file 

   Set DEBUG = true in config.js to enable
   more verbose output, if required

3. Run a number of test vectors.

   Copy test vector file to this directory;
 
   cp ../../testVectors/mpin/BNCX.json testVectors.json

   The file testVectors.json can be generated using this 
   script as long as the libraries are installed.

   ./genVectors.py [successful authentication] [failed authentication] [epoch days in future]

   The JavaScript tests are then run using this script;

   ./run_js_tests.sh 

   To run individual tests look inside the script for guidance. 


