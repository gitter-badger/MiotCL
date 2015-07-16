//
//  TestMPIN.swift
//  miot2
//
//  Created by Michael Scott on 08/07/2015.
//  Copyright (c) 2015 Michael Scott. All rights reserved.
//

import Foundation
import clint

public func TestMPIN()
{
    let PERMITS=true
    let PINERROR=true
    let FULL=true
    let SINGLE_PASS=true
   
    var rng=RAND()
    
    var RAW=[UInt8](count:100,repeatedValue:0)
    
    for var i=0;i<100;i++ {RAW[i]=UInt8((i+1)&0xff)}
    rng.seed(100,RAW)
    
    let EGS=MPIN.EFS
    let EFS=MPIN.EGS
    let G1S=2*EFS+1    /* Group 1 Size */
    let G2S=4*EFS;     /* Group 2 Size */
    let EAS=MPIN.PAS
    
    var S=[UInt8](count:EGS,repeatedValue:0)
    var SST=[UInt8](count:G2S,repeatedValue:0)
    var TOKEN=[UInt8](count:G1S,repeatedValue:0)
    var PERMIT=[UInt8](count:G1S,repeatedValue:0)
    var SEC=[UInt8](count:G1S,repeatedValue:0)
    var xID=[UInt8](count:G1S,repeatedValue:0)
    var xCID=[UInt8](count:G1S,repeatedValue:0)
    var X=[UInt8](count:EGS,repeatedValue:0)
    var Y=[UInt8](count:EGS,repeatedValue:0)
    var E=[UInt8](count:12*EFS,repeatedValue:0)
    var F=[UInt8](count:12*EFS,repeatedValue:0)
    var HID=[UInt8](count:G1S,repeatedValue:0)
    var HTID=[UInt8](count:G1S,repeatedValue:0)

    var G1=[UInt8](count:12*EFS,repeatedValue:0)
    var G2=[UInt8](count:12*EFS,repeatedValue:0)
    var R=[UInt8](count:EGS,repeatedValue:0)
    var Z=[UInt8](count:G1S,repeatedValue:0)
    var W=[UInt8](count:EGS,repeatedValue:0)
    var T=[UInt8](count:G1S,repeatedValue:0)
    var CK=[UInt8](count:EAS,repeatedValue:0)
    var SK=[UInt8](count:EAS,repeatedValue:0)

    /* Trusted Authority set-up */
    
    MPIN.RANDOM_GENERATE(rng,&S)
    print("Master Secret s: 0x");  MPIN.printBinary(S)
    
    /* Create Client Identity */
    var IDstr = "testUser@certivox.com"
    var CLIENT_ID=[UInt8](IDstr.utf8)
    
    var HCID=MPIN.HASH_ID(CLIENT_ID)  /* Either Client or TA calculates Hash(ID) - you decide! */
    
    print("Client ID= "); MPIN.printBinary(CLIENT_ID)
    
    /* Client and Server are issued secrets by DTA */
    MPIN.GET_SERVER_SECRET(S,&SST);
    print("Server Secret SS: 0x");  MPIN.printBinary(SST);
    
    MPIN.GET_CLIENT_SECRET(&S,HCID,&TOKEN);
    print("Client Secret CS: 0x"); MPIN.printBinary(TOKEN);
    
    /* Client extracts PIN from secret to create Token */
    var pin:Int32=1234
    println("Client extracts PIN= \(pin)")
    var rtn=MPIN.EXTRACT_PIN(CLIENT_ID,pin,&TOKEN)
    if rtn != 0 {println("FAILURE: EXTRACT_PIN rtn: \(rtn)")}
    
    print("Client Token TK: 0x"); MPIN.printBinary(TOKEN);

    if FULL
    {
        MPIN.PRECOMPUTE(TOKEN,HCID,&G1,&G2);
    }
    
    var date:Int32=0
    if (PERMITS)
    {
        date=MPIN.today()
        /* Client gets "Time Token" permit from DTA */
        MPIN.GET_CLIENT_PERMIT(date,S,HCID,&PERMIT)
        print("Time Permit TP: 0x");  MPIN.printBinary(PERMIT)
        
        /* This encoding makes Time permit look random - Elligator squared */
        MPIN.ENCODING(rng,&PERMIT);
        print("Encoded Time Permit TP: 0x");  MPIN.printBinary(PERMIT)
        MPIN.DECODING(&PERMIT)
        print("Decoded Time Permit TP: 0x");  MPIN.printBinary(PERMIT)
    }

    /***** NOW ENTER PIN *******/
    
        pin=1234
    
    /***************************/
    
    /* Set date=0 and PERMIT=null if time permits not in use
    
    Client First pass: Inputs CLIENT_ID, optional RNG, pin, TOKEN and PERMIT. Output xID =x .H(CLIENT_ID) and re-combined secret SEC
    If PERMITS are is use, then date!=0 and PERMIT is added to secret and xCID = x.(H(CLIENT_ID)+H(date|H(CLIENT_ID)))
    Random value x is supplied externally if RNG=null, otherwise generated and passed out by RNG
    
    IMPORTANT: To save space and time..
    If Time Permits OFF set xCID = null, HTID=null and use xID and HID only
    If Time permits are ON, AND pin error detection is required then all of xID, xCID, HID and HTID are required
    If Time permits are ON, AND pin error detection is NOT required, set xID=null, HID=null and use xCID and HTID only.
    
    
    */
    
    var pxID:[UInt8]?=xID
    var pxCID:[UInt8]?=xCID
    var pHID:[UInt8]?=HID
    var pHTID:[UInt8]?=HTID
    var pE:[UInt8]?=E
    var pF:[UInt8]?=F
    var pPERMIT:[UInt8]?=PERMIT
    
    if date != 0
    {
        if (!PINERROR)
        {
            pxID=nil;
            pHID=nil;
        }
    }
    else
    {
        pPERMIT=nil;
        pxCID=nil;
        pHTID=nil;
    }
    if (!PINERROR)
    {
        pE=nil;
        pF=nil;
    }
    
    if (SINGLE_PASS)
    {
        println("MPIN Single Pass")
        var timeValue = MPIN.GET_TIME()

        rtn=MPIN.CLIENT(date,CLIENT_ID,rng,&X,pin,TOKEN,&SEC,&pxID,&pxCID,pPERMIT!,timeValue,&Y)
        
        if rtn != 0 {println("FAILURE: CLIENT rtn: \(rtn)")}
        
        if (FULL)
        {
            HCID=MPIN.HASH_ID(CLIENT_ID);
            MPIN.GET_G1_MULTIPLE(rng,1,&R,HCID,&Z); /* Also Send Z=r.ID to Server, remember random r */
        }
        rtn=MPIN.SERVER(date,&pHID,&pHTID!,&Y,SST,pxID,pxCID!,SEC,&pE,&pF,CLIENT_ID,timeValue)
        if rtn != 0 {println("FAILURE: SERVER rtn: \(rtn)")}
        
        if (FULL)
        { /* Also send T=w.ID to client, remember random w  */
            if date != 0 {MPIN.GET_G1_MULTIPLE(rng,0,&W,pHTID!,&T)}
            else {MPIN.GET_G1_MULTIPLE(rng,0,&W,pHID!,&T)}
            
        }
    }
    else
    {
        println("MPIN Multi Pass");
        /* Send U=x.ID to server, and recreate secret from token and pin */
        rtn=MPIN.CLIENT_1(date,CLIENT_ID,rng,&X,pin,TOKEN,&SEC,&pxID,&pxCID,pPERMIT!)
        if rtn != 0 {println("FAILURE: CLIENT_1 rtn: \(rtn)")}
            
        if (FULL)
        {
            HCID=MPIN.HASH_ID(CLIENT_ID);
            MPIN.GET_G1_MULTIPLE(rng,1,&R,HCID,&Z);  /* Also Send Z=r.ID to Server, remember random r */
        }
            
        /* Server calculates H(ID) and H(T|H(ID)) (if time permits enabled), and maps them to points on the curve HID and HTID resp. */
        MPIN.SERVER_1(date,CLIENT_ID,&pHID,&pHTID!);
            
            /* Server generates Random number Y and sends it to Client */
        MPIN.RANDOM_GENERATE(rng,&Y);
            
        if (FULL)
        { /* Also send T=w.ID to client, remember random w  */
            if date != 0 {MPIN.GET_G1_MULTIPLE(rng,0,&W,pHTID!,&T)}
            else {MPIN.GET_G1_MULTIPLE(rng,0,&W,pHID!,&T)}
        }
            
        /* Client Second Pass: Inputs Client secret SEC, x and y. Outputs -(x+y)*SEC */
        rtn=MPIN.CLIENT_2(X,Y,&SEC);
        if rtn != 0 {println("FAILURE: CLIENT_2 rtn: \(rtn)")}
            
        /* Server Second pass. Inputs hashed client id, random Y, -(x+y)*SEC, xID and xCID and Server secret SST. E and F help kangaroos to find error. */
        /* If PIN error not required, set E and F = null */
            
        rtn=MPIN.SERVER_2(date,pHID,pHTID!,Y,SST,pxID,pxCID!,SEC,&pE,&pF);
            
        if rtn != 0 {println("FAILURE: SERVER_1 rtn: \(rtn)")}
    }
    if (rtn == MPIN.BAD_PIN)
    {
        println("Server says - Bad Pin. I don't know you. Feck off.\n");
        if (PINERROR)
        {
            var err=MPIN.KANGAROO(pE!,pF!);
            if err != 0 {println("(Client PIN is out by \(err))\n")}
        }
        return;
    }
    else {println("Server says - PIN is good! You really are "+IDstr)}

    if (FULL)
    {
        MPIN.CLIENT_KEY(G1,G2,pin,R,X,T,&CK);
        print("Client Key =  0x");  MPIN.printBinary(CK)
        
        MPIN.SERVER_KEY(Z,SST,W,pxID!,pxCID!,&SK);
        print("Server Key =  0x");  MPIN.printBinary(SK)
    }
    
}

TestMPIN()

