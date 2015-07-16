//
//  TestRSA.swift
//  miot2
//
//  Created by Michael Scott on 25/06/2015.
//  Copyright (c) 2015 Michael Scott. All rights reserved.
//

import Foundation
import clint

public func TestRSA()
{
    var RFS=RSA.RFS;

    var message="Hello World\n"

    var pub=rsa_public_key(ROM.FFLEN);
    var priv=rsa_private_key(ROM.HFLEN);

    var ML=[UInt8](count:RFS,repeatedValue:0)
    var C=[UInt8](count:RFS,repeatedValue:0)
    var RAW=[UInt8](count:100,repeatedValue:0)

    var rng=RAND()

    rng.clean();
    for var i=0;i<100;i++ {RAW[i]=UInt8(i)}

    rng.seed(100,RAW);

    println("Generating public/private key pair");
    RSA.KEY_PAIR(rng,65537,priv,pub);

    var M=[UInt8](message.utf8)
    print("Encrypting test string\n");
    var E=RSA.OAEP_ENCODE(M,rng,nil); /* OAEP encode message m to e  */

    RSA.ENCRYPT(pub,E,&C);     /* encrypt encoded message */
    print("Ciphertext= 0x"); RSA.printBinary(C);

    print("Decrypting test string\n");
    RSA.DECRYPT(priv,C,&ML);
    var MS=RSA.OAEP_DECODE(nil,&ML); /* OAEP encode message m to e  */

    message=""
    for var i=0;i<MS.count;i++
    {
        message+=String(UnicodeScalar(MS[i]))
    }
    print(message);

    RSA.PRIVATE_KEY_KILL(priv);
}




