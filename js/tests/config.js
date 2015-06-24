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

var MPinAuthenticationURL = "ws://127.0.0.1:8003/authenticationToken";
var baseURL = "127.0.0.1";
var DTA_proxy = "8000";
var MPinAuthenticationServer = "8003";
var MPinRPS = "8011";

// Time for which signatures are valid
var SIGNATURE_EXPIRES_OFFSET_SECONDS = 60;

// App credentials
var app_id = "8c63aa9f7639f15bf46f142a84fedc82";
var app_key = "4802368727eccd0693692c5b36d4f206";

// Fixed Seed
seedValueHex = "3ade3d4a5c698e8910bf92f25d97ceeb7c25ed838901a5cb5db2cf25434c1fe76c7f79b7af2e5e1e4988e4294dbd9bd9fa3960197fb7aec373609fb890d74b16a4b14b2ae7e23b75f15d36c21791272372863c4f8af39980283ae69a79cf4e48e908f9e0";

var DEBUG = false;
//var DEBUG = true;


