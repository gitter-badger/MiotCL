//
//  rom.swift
//  miot2
//
//  Created by Michael Scott on 12/06/2015.
//  Copyright (c) 2015 Michael Scott. All rights reserved.
//

final public class ROM{
    static let NLEN:Int=9
    static let CHUNK:Int=32
    static let DNLEN:Int=2*NLEN
    
/*** Enter Some Field details here  ***/
    // BN Curve
    static let MODBITS:Int32 = 254 /* Number of bits in Modulus */
    static let MOD8:Int32 = 3   /* Modulus mod 8 */
    // Curve 25519
//    static let MODBITS:Int32=255
//    static let MOD8:Int32=5
    
    // NIST256 or Brainpool
//    static let MODBITS:Int32=256
//    static let MOD8:Int32=7

    // MF254
//    static let MODBITS:Int32=254
//    static let MOD8:Int32=7
    // MS255
//    static let MODBITS:Int32 = 255
//    static let MOD8:Int32 = 3
    // MF256
//    static let MODBITS:Int32 = 256
//    static let MOD8:Int32 = 7
    // MS256
//    static let MODBITS:Int32 = 256
//    static let MOD8:Int32 = 3
  
    // ANSSI
//    static let MODBITS:Int32 = 256
//    static let MOD8:Int32 = 3
    
    static let BASEBITS:Int32=29
    static let OMASK:Int32=Int32(-1)<<Int32(MODBITS%BASEBITS)
    static let MASK:Int32=((Int32(1)<<BASEBITS)-Int32(1))
    static let TBITS:Int32=MODBITS%BASEBITS; // Number of active bits in top word
    static let TMASK:Int32=(Int32(1)<<TBITS)-1;
    static let MODBYTES:Int32=32
    static let NEXCESS:Int32 = (Int32(1)<<(Int32(CHUNK)-BASEBITS-1))
    static let FEXCESS:Int32 = (Int32(1)<<(BASEBITS*Int32(NLEN)-MODBITS));
    
    /* Don't Modify from here... */
    static let NOT_SPECIAL=0
    static let PSEUDO_MERSENNE=1
    static let MONTGOMERY_FRIENDLY=2
    static let WEIERSTRASS=0
    static let EDWARDS=1
    static let MONTGOMERY=2
    /* ...to here */
    
    
    /* Finite field support - for RSA, DH etc. */
    static let FF_BITS:Int=2048; /* Finite Field Size in bits - must be 256.2^n */
    static public let FFLEN=(FF_BITS/256)
    static public let HFLEN=(FFLEN/2);  /* Useful for half-size RSA private key operations */
    
// START SPECIFY FIELD DETAILS HERE
//*********************************************************************************
// Curve25519 Modulus
//    static let MODTYPE=PSEUDO_MERSENNE
//    static let Modulus:[Int32]=[0x1FFFFFED,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x7FFFFF]
//    static let MConst:Int32=19
    
// NIST-256 Modulus
//    static let MODTYPE=NOT_SPECIAL
//    static let Modulus:[Int32]=[0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FF,0x0,0x0,0x40000,0x1FE00000,0xFFFFFF]
//    static let MConst:Int32=1

// MF254 Modulus
//    static let MODTYPE=MONTGOMERY_FRIENDLY
//    static let Modulus:[Int32]=[0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3F80FF]
//    static let MConst:Int32=0x3F8100
// MS255 Modulus
//    static let MODTYPE = PSEUDO_MERSENNE
//    static let Modulus:[Int32]=[0x1FFFFD03,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x7FFFFF]
//    static let MConst:Int32=0x2FD
// MF256 Modulus
//    static let MODTYPE = MONTGOMERY_FRIENDLY
//    static let Modulus:[Int32]=[0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0xFFA7FF]
//    static let MConst:Int32=0xFFA800
// MS256 Modulus
//    static let MODTYPE = PSEUDO_MERSENNE
//    static let Modulus:[Int32]=[0x1FFFFF43,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0xFFFFFF]
//    static let MConst:Int32 = 0xBD
    // Brainpool Modulus
//    static let MODTYPE = NOT_SPECIAL
//    static let Modulus:[Int32]=[0x1F6E5377,0x9A40E8,0x9880A08,0x17EC47AA,0x18D726E3,0x5484EC1,0x6F0F998,0x1B743DD5,0xA9FB57]
//    static let MConst:Int32 = 0xEFD89B9
    // ANSSI Modulus
//    static let MODTYPE = NOT_SPECIAL
//    static let Modulus:[Int32]=[0x186E9C03,0x7E79A9E,0x12329B7A,0x35B7957,0x435B396,0x16F46721,0x163C4049,0x1181675A,0xF1FD17]
//    static let MConst:Int32 = 0x164E1155
    
    // BNCX Curve Modulus
    static let MODTYPE = NOT_SPECIAL
    static let Modulus:[Int32]=[0x1C1B55B3,0x13311F7A,0x24FB86F,0x1FADDC30,0x166D3243,0xFB23D31,0x836C2F7,0x10E05,0x240000]
    static let MConst:Int32=0x19789E85

    
    // START SPECIFY CURVE DETAILS HERE
    //*********************************************************************************
    // Original Curve25519
    // 	static let CURVETYPE=MONTGOMERY
    //	static let CURVE_A:Int32 = 486662
    //	static let CURVE_B:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    //	static let CURVE_Order:[Int32]=[0x1CF5D3ED,0x9318D2,0x1DE73596,0x1DF3BD45,0x14D,0x0,0x0,0x0,0x100000]
    //	static let CURVE_Gx:[Int32]=[0x9,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //	static let CURVE_Gy:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
// Ed25519 Curve
    //static let CURVETYPE=EDWARDS
    //static let CURVE_A:Int32 = -1
    //static let CURVE_B:[Int32]=[0x135978A3,0xF5A6E50,0x10762ADD,0x149A82,0x1E898007,0x3CBBBC,0x19CE331D,0x1DC56DFF,0x52036C]
    //static let CURVE_Order:[Int32]=[0x1CF5D3ED,0x9318D2,0x1DE73596,0x1DF3BD45,0x14D,0x0,0x0,0x0,0x100000]
    //static let CURVE_Gx:[Int32]=[0xF25D51A,0xAB16B04,0x969ECB2,0x198EC12A,0xDC5C692,0x1118FEEB,0xFFB0293,0x1A79ADCA,0x216936]
    //static let CURVE_Gy:[Int32]=[0x6666658,0x13333333,0x19999999,0xCCCCCCC,0x6666666,0x13333333,0x19999999,0xCCCCCCC,0x666666]
    
// NIST-256 Curve
    //	static let CURVETYPE=WEIERSTRASS
    //    static let CURVE_A:Int32 = -3;
    //    static let CURVE_B:[Int32]=[0x7D2604B,0x1E71E1F1,0x14EC3D8E,0x1A0D6198,0x86BC651,0x1EAABB4C,0xF9ECFAE,0x1B154752,0x5AC635]
    //    static let CURVE_Order:[Int32]=[0x1C632551,0x1DCE5617,0x5E7A13C,0xDF55B4E,0x1FFFFBCE,0x1FFFFFFF,0x3FFFF,0x1FE00000,0xFFFFFF]
    //    static let CURVE_Gx:[Int32]=[0x1898C296,0x509CA2E,0x1ACCE83D,0x6FB025B,0x40F2770,0x1372B1D2,0x91FE2F3,0x1E5C2588,0x6B17D1]
    //    static let CURVE_Gy:[Int32]=[0x17BF51F5,0x1DB20341,0xC57B3B2,0x1C66AED6,0x19E162BC,0x15A53E07,0x1E6E3B9F,0x1C5FC34F,0x4FE342]

    // MF254 Modulus, Weierstrass Curve w-254-mont
    //    static let CURVETYPE=WEIERSTRASS
    //    static let CURVE_A:Int32 = -3
    //    static let CURVE_B:[Int32]=[0x1FFFD08D,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3F80FF]
    //    static let CURVE_Order:[Int32]=[0xF8DF83F,0x1D20CE25,0x8DD701B,0x317D41B,0x1FFFFEB8,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3F80FF]
    //    static let CURVE_Gx:[Int32]=[0x2,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //    static let CURVE_Gy:[Int32]=[0x190D4EBC,0xB2EF9BF,0x14464C6B,0xE71C7F0,0x18AEBDFB,0xD3ADEBB,0x18052B85,0x1A6765CA,0x140E3F]
    
    // MF254 Modulus, Edwards Curve ed-254-mont
    //    static let CURVETYPE = EDWARDS
    //    static let CURVE_A:Int32 = -1
    //    static let CURVE_B:[Int32]=[0x367B,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //    static let CURVE_Order:[Int32]=[0x46E98C7,0x179E9FF6,0x158BEC3A,0xA60D917,0x1FFFFEB9,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0xFE03F]
    //    static let CURVE_Gx:[Int32]=[0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //    static let CURVE_Gy:[Int32]=[0xF2701E5,0x29687ED,0xC84861F,0x535081C,0x3F4E363,0x6A811B,0xCD65474,0x121AD498,0x19F0E6]

    // MF254 Modulus, Montgomery Curve
    //static let CURVETYPE = MONTGOMERY
    //static let CURVE_A:Int32 = -55790;
    //static let CURVE_B:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    //static let CURVE_Order:[Int32]=[0x46E98C7,0x179E9FF6,0x158BEC3A,0xA60D917,0x1FFFFEB9,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0xFE03F]
    //static let CURVE_Gx:[Int32]=[0x3,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
 
    // MS255 Modulus, Weierstrass Curve
    //static let CURVETYPE = WEIERSTRASS
    //static let CURVE_A:Int32 = -3
    //static let CURVE_B:[Int32]=[0x1FFFAB46,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x7FFFFF]
    //static let CURVE_Order:[Int32]=[0x1C594AEB,0x1C7D64C1,0x14ACF7EA,0x14705075,0x1FFFF864,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x7FFFFF]
    //static let CURVE_Gx:[Int32]=[0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x9CB44BA,0x199FFB3B,0x1F698345,0xD8F19BB,0x17D177DB,0x1FFCD97F,0xCE487A,0x181DB74F,0x6F7A6A]

    // MS255 Modulus, Edwards Curve
    //static let CURVETYPE = EDWARDS
    //static let CURVE_A:Int32 = -1
    //static let CURVE_B:[Int32]=[0xEA97,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Order:[Int32]=[0x436EB75,0x24E8F68,0x9A0CBAB,0x34F0BDB,0x1FFFFDCF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFF]
    //static let CURVE_Gx:[Int32]=[0x4,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x108736A0,0x11512ADE,0x1116916E,0x29715DA,0x47E5529,0x66EC706,0x1517B095,0xA694F76,0x26CB78]

    // MS255 Modulus, Montgomery Curve
    //static let CURVETYPE=MONTGOMERY
    //static let CURVE_A:Int32 = -240222
    //static let CURVE_B:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    //static let CURVE_Order:[Int32]=[0x436EB75,0x24E8F68,0x9A0CBAB,0x34F0BDB,0x1FFFFDCF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFF]
    //static let CURVE_Gx:[Int32]=[0x4,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    
    // MF256 Modulus, Weierstrass Curve
    //static let CURVETYPE = WEIERSTRASS
    //static let CURVE_A:Int32 = -3;
    //static let CURVE_B:[Int32]=[0x14E6A,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Order:[Int32]=[0x79857EB,0x8862F0D,0x1941D2E7,0x2EA27CD,0x1FFFFFC5,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0xFFA7FF]
    //static let CURVE_Gx:[Int32]=[0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0xB724D2A,0x3CAA61,0x5371984,0x128FD71B,0x1AE28956,0x1D13091E,0x339EEAE,0x10F7C301,0x20887C]
    
    // MF256, Edwards Curve
    //static let CURVETYPE = EDWARDS
    //static let CURVE_A:Int32 = -1
    //static let CURVE_B:[Int32]=[0x350A,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Order:[Int32]=[0x18EC7BAB,0x16C976F6,0x19CCF259,0x9775F70,0x1FFFFB15,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3FE9FF]
    //static let CURVE_Gx:[Int32]=[0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x12F3C908,0xF553917,0x1FA9A35F,0xBCC91B,0x1AACA0C,0x1779ED96,0x156BABAF,0x1F1F1989,0xDAD8D4]
   
    // MF256 Modulus, Montgomery Curve
    //static let CURVETYPE = MONTGOMERY
    //static let CURVE_A:Int32 = -54314
    //static let CURVE_B:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    //static let CURVE_Order:[Int32]=[0x18EC7BAB,0x16C976F6,0x19CCF259,0x9775F70,0x1FFFFB15,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3FE9FF]
    //static let CURVE_Gx:[Int32]=[0x8,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used

    // MS256, Weierstrass Curve
    //static let CURVETYPE  = WEIERSTRASS
    //static let CURVE_A:Int32 = -3
    //static let CURVE_B:[Int32]=[0x25581,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Order:[Int32]=[0x751A825,0x559014A,0x9971808,0x1904EBD4,0x1FFFFE43,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0xFFFFFF]
    //static let CURVE_Gx:[Int32]=[0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x2B56C77,0x1FA31836,0x253B042,0x185F26EB,0xDD6BD02,0x4B66777,0x1B5FF20B,0xA783C8C,0x696F18]

    // MS256, Edwards Curve
    //static let CURVETYPE = EDWARDS
    //static let CURVE_A:Int32 = -1;
    //static let CURVE_B:[Int32]=[0x3BEE,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Order:[Int32]=[0x1122B4AD,0xDC27378,0x9AF1939,0x154AB5A1,0x1FFFFBE6,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3FFFFF]
    //static let CURVE_Gx:[Int32]=[0xD,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x131CADBA,0x3FB7DA9,0x134C0FDC,0x14DAC704,0x46BFBE2,0x1859CFD0,0x1B6E8F4C,0x3C5424E,0x7D0AB4]

    // MS256 Modulus, Montgomery Curve
    //static let CURVETYPE = MONTGOMERY
    //static let CURVE_A:Int32 = -61370
    //static let CURVE_B:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    //static let CURVE_Order:[Int32]=[0x1122B4AD,0xDC27378,0x9AF1939,0x154AB5A1,0x1FFFFBE6,0x1FFFFFFF,0x1FFFFFFF,0x1FFFFFFF,0x3FFFFF]
    //static let CURVE_Gx:[Int32]=[0xb,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    //static let CURVE_Gy:[Int32]=[0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0] // not used
    
    // Brainpool
    //static let CURVETYPE = WEIERSTRASS
    //static let CURVE_A:Int32 = -3
    //static let CURVE_B:[Int32]=[0x1EE92B04,0x172C080F,0xBD2495A,0x7D7895E,0x176B7BF9,0x13B99E85,0x1A93F99A,0x18861B09,0x662C61]
    //static let CURVE_Order:[Int32]=[0x174856A7,0xF07414,0x1869BDE4,0x12F5476A,0x18D718C3,0x5484EC1,0x6F0F998,0x1B743DD5,0xA9FB57]
    //static let CURVE_Gx:[Int32]=[0xE1305F4,0xD0C8AB1,0xBEF0ADE,0x28588F5,0x16149AFA,0x9D91D32,0x1EDDCC88,0x79839FC,0xA3E8EB]
    //static let CURVE_Gy:[Int32]=[0x1B25C9BE,0xD5F479A,0x1409C007,0x196DBC73,0x417E69B,0x1170A322,0x15B5FDEC,0x10468738,0x2D996C]
    
    // ANSSI
    //static let CURVETYPE = WEIERSTRASS
    //static let CURVE_A:Int32 = -3;
    //static let CURVE_B:[Int32]=[0x1B7BB73F,0x3AF6CB3,0xC68600C,0x181935C9,0xC00FDFE,0x1D3AA522,0x4C0352A,0x194A8515,0xEE353F]
    //static let CURVE_Order:[Int32]=[0x6D655E1,0x1FEEA2CE,0x14AFE507,0x18CFC281,0x435B53D,0x16F46721,0x163C4049,0x1181675A,0xF1FD17]
    //static let CURVE_Gx:[Int32]=[0x198F5CFF,0x64BD16E,0x62DC059,0xFA5B95F,0x23958C2,0x1EA3A4EA,0x7ACC460,0x186AD827,0xB6B3D4]
    //static let CURVE_Gy:[Int32]=[0x14062CFB,0x188AD0AA,0x19327860,0x3860FD1,0xEF8C270,0x18F879F6,0x12447E49,0x1EF91640,0x6142E0]

    // BNCX Curve
    
    static let CURVETYPE = WEIERSTRASS
    static let CURVE_A:Int32 = 0
    static let CURVE_B:[Int32]=[0x2,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    static let CURVE_Order:[Int32]=[0x16EB1F6D,0x108E0531,0x1241B3AF,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000]
    static let CURVE_Bnx:[Int32]=[0x3C012B1,0x0,0x10,0x0,0x0,0x0,0x0,0x0,0x0]
    static let CURVE_Cru:[Int32]=[0x14235C97,0xF0498BC,0x1BE1D58C,0x1BBEC8E3,0x3F1440B,0x654,0x12000,0x0,0x0]
    static let CURVE_Fra:[Int32]=[0x15C80EA3,0x1EC8419A,0x1CFE0856,0xEE64DE2,0x11898686,0x5C55653,0x592BF86,0x5F4C740,0x135908]
    static let CURVE_Frb:[Int32]=[0x6534710,0x1468DDE0,0x551B018,0x10C78E4D,0x4E3ABBD,0x9ECE6DE,0x2A40371,0x1A0C46C5,0x10A6F7]
    static let CURVE_Pxa:[Int32]=[0x4D2EC74,0x428E777,0xF89C9B0,0x190B7F40,0x14BBB907,0x12807AE1,0x958D62C,0x58E0A76,0x19682D]
    static let CURVE_Pxb:[Int32]=[0xE29CFE1,0x1D2C7459,0x270C3D1,0x172F6184,0x19743F81,0x49BD474,0x192A8047,0x1D87C33E,0x1466B9]
    static let CURVE_Pya:[Int32]=[0xF0BE09F,0x7DFE75E,0x1FB06CC3,0x3667B08,0xE209636,0x110ABED7,0xE376078,0x1B2E4665,0xA79ED]
    static let CURVE_Pyb:[Int32]=[0x898EE9D,0xC825914,0x14BB7AFB,0xC9D4AD3,0x13461C28,0x122896C6,0x240D71B,0x73D9898,0x6160C]
    static let CURVE_Gx:[Int32]=[0x1C1B55B2,0x13311F7A,0x24FB86F,0x1FADDC30,0x166D3243,0xFB23D31,0x836C2F7,0x10E05,0x240000]
    static let CURVE_Gy:[Int32]=[0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]
    static let CURVE_W:[[Int32]]=[[0x162FEB83,0x2A31A48,0x100E0480,0x16,0x600,0x0,0x0,0x0,0x0],[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0]]

    
    static let CURVE_SB:[[[Int32]]]=[[[0x1DB010E4,0x2A31A48,0x100E04A0,0x16,0x600,0x0,0x0,0x0,0x0],[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0]],[[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0],[0xBB33EA,0xDEAEAE9,0x233AF2F,0x1FADDC03,0x166D2643,0xFB23D31,0x836C2F7,0x10E05,0x240000]]]
    
    static let CURVE_WB:[[Int32]]=[[0x167A84B0,0xE108C2,0x1004AC10,0x7,0x200,0x0,0x0,0x0,0x0],[0x1E220475,0x166FCCAD,0x129FE68D,0x1D29DB51,0x2A0DC07,0x438,0xC000,0x0,0x0],[0xF10B93,0x1B37E657,0x194FF34E,0x1E94EDA8,0x1506E03,0x21C,0x6000,0x0,0x0],[0x1DFAAA11,0xE108C2,0x1004AC30,0x7,0x200,0x0,0x0,0x0,0x0]]
    
    static let CURVE_BB:[[[Int32]]]=[[[0x132B0CBD,0x108E0531,0x1241B39F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000],[0x132B0CBC,0x108E0531,0x1241B39F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000],[0x132B0CBC,0x108E0531,0x1241B39F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000],[0x7802562,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0]],[[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0],[0x132B0CBC,0x108E0531,0x1241B39F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000],[0x132B0CBD,0x108E0531,0x1241B39F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000],[0x132B0CBC,0x108E0531,0x1241B39F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000]],[[0x7802562,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0],[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0],[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0],[0x7802561,0x0,0x20,0x0,0x0,0x0,0x0,0x0,0x0]],[[0x3C012B2,0x0,0x10,0x0,0x0,0x0,0x0,0x0,0x0],[0xF004AC2,0x0,0x40,0x0,0x0,0x0,0x0,0x0,0x0],[0xF6AFA0A,0x108E0531,0x1241B38F,0x1FADDC19,0x166D2C43,0xFB23D31,0x836C2F7,0x10E05,0x240000],[0x3C012B2,0x0,0x10,0x0,0x0,0x0,0x0,0x0,0x0]]]
    
    static let USE_GLV = true
    static let USE_GS_G2 = true
    static let USE_GS_GT = true
    static let GT_STRONG = true
    
}
