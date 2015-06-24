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

/* Test good token and correct PIN with D-TA */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "config.h"
#include "mpin.h"

// Define PIN range:
#define MAX_RANGE 10000

void rand_str(char *dest, size_t length) {
    char charset[] = "0123456789@.*"
                     "abcdefghijklmnopqrstuvwxyz"
                     "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    while (length-- > 0) {
        size_t index = rand() % (sizeof charset);
        *dest++ = charset[index];
    }
    *dest = '\0';
}

int main()
{
  int i,PIN1,PIN2,rtn,err,iter;

  char client_id[256];
  octet CLIENT_ID = {0,sizeof(client_id),client_id};

  char x[PGS],y[PGS];
  octet X={sizeof(x), sizeof(x),x};
  octet Y={sizeof(y),sizeof(y),y};

  /* Master secret shares */
  char ms1[PGS], ms2[PGS];
  octet MS1={sizeof(ms1),sizeof(ms1),ms1};
  octet MS2={sizeof(ms2),sizeof(ms2),ms2};

  /* Hash values of client ID */
  char hcid[32];
  octet HCID={sizeof(hcid),sizeof(hcid), hcid};

  /* Client secret and shares */
  char cs1[2*PFS+1], cs2[2*PFS+1], sec[2*PFS+1];
  octet SEC={sizeof(sec),sizeof(sec),sec};
  octet CS1={sizeof(cs1),sizeof(cs1), cs1};
  octet CS2={sizeof(cs2),sizeof(cs2), cs2};

  /* Server secret and shares */
  char ss1[4*PFS], ss2[4*PFS], serverSecret[4*PFS];
  octet ServerSecret={sizeof(serverSecret),sizeof(serverSecret),serverSecret};
  octet SS1={sizeof(ss1),sizeof(ss1),ss1};
  octet SS2={sizeof(ss2),sizeof(ss2),ss2};

  /* Time Permit and shares */
  char tp1[2*PFS+1], tp2[2*PFS+1], tp[2*PFS+1];
  octet TP={sizeof(tp),sizeof(tp),tp};
  octet TP1={sizeof(tp1),sizeof(tp1),tp1};
  octet TP2={sizeof(tp2),sizeof(tp2),tp2};

  /* Token stored on computer */
  char token[2*PFS+1];
  octet TOKEN={sizeof(token),sizeof(token),token};

  char ut[2*PFS+1],u[2*PFS+1];
  octet UT={sizeof(ut),sizeof(ut),ut};
  octet U={sizeof(u),sizeof(u),u};

  char hid[2*PFS+1],htid[2*PFS+1];
  octet HID={0,sizeof(hid),hid};
  octet HTID={0,sizeof(htid),htid};

  char e[12*PFS], f[12*PFS];
  octet E={sizeof(e),sizeof(e),e};
  octet F={sizeof(f),sizeof(f),f};

  char r[PGS],z[2*PFS+1],w[PGS],t[2*PFS+1];
  char g1[12*PFS],g2[12*PFS];
  char ck[PAS],sk[PAS];
  octet R={0,sizeof(r),r};
  octet Z={0,sizeof(z),z};
  octet W={0,sizeof(w),w};
  octet T={0,sizeof(t),t};
  octet G1={0,sizeof(g1),g1};
  octet G2={0,sizeof(g2),g2};
  octet SK={0,sizeof(sk),sk};
  octet CK={0,sizeof(ck),ck};

  int date = 0;

  unsigned long ran;
  int byte_count = 32;
  FILE *fp;
  char seed[32] = {0};
  octet SEED = {sizeof(seed),sizeof(seed),seed};
  csprng RNG;               
#ifdef __linux__
  fp = fopen("/dev/urandom", "r");
  fread(&seed, 1, byte_count, fp);
  fclose(fp);
#else
  /* non random seed value! */
  time((time_t *)&ran);
  SEED.val[0]=ran;
  SEED.val[1]=ran>>8;
  SEED.val[2]=ran>>16;
  SEED.val[3]=ran>>24;
  for (i=4;i<byte_count;i++) SEED.val[i]=i+1;
#endif
  printf("SEED 0x"); 
  OCT_output(&SEED);

  /* initialise random number generator */ 
  CREATE_CSPRNG(&RNG,&SEED);   
      
  for(iter=1; iter<nRandomTests+1; iter++)
    {
      /* Generate Client master secret for Certivox and Customer */
      rtn = MPIN_RANDOM_GENERATE(&RNG,&MS1); 
      if (rtn != 0)
        {
          printf("MPIN_RANDOM_GENERATE(&RNG,&MS1) Error %d\n", rtn);
          return 1;
        }
      rtn = MPIN_RANDOM_GENERATE(&RNG,&MS2); 
      if (rtn != 0)
        {
          printf("MPIN_RANDOM_GENERATE(&RNG,&MS2) Error %d\n", rtn);
          return 1;
        }
      printf("MASTER SECRET CERTIVOX:= 0x"); 
      OCT_output(&MS1);
      printf("MASTER SECRET CUSTOMER:= 0x"); 
      OCT_output(&MS2);
      
      /* Generate server secret shares */
      rtn = MPIN_GET_SERVER_SECRET(&MS1,&SS1);
      if (rtn != 0)
        {
          printf("MPIN_GET_SERVER_SECRET(&MS1,&SS1) Error %d\n", rtn);
          return 1;
        }
      rtn = MPIN_GET_SERVER_SECRET(&MS2,&SS2);
      if (rtn != 0)
        {
          printf("MPIN_GET_SERVER_SECRET(&MS2,&SS2) Error %d\n", rtn);
          return 1;
        }
      printf("SS1 = 0x"); 
      OCT_output(&SS1);
      printf("SS2 = 0x"); 
      OCT_output(&SS2);
      
      /* Combine server secret share */
      rtn = MPIN_RECOMBINE_G2(&SS1, &SS2, &ServerSecret);
      if (rtn != 0)
        {
          printf("MPIN_RECOMBINE_G2(&SS1, &SS2, &ServerSecret) Error %d\n", rtn);
          return 1;
        }
      printf("ServerSecret = 0x"); 
      OCT_output(&ServerSecret);
      
      /* Assign the End-User an ID */
      rand_str(client_id,256);
      OCT_jstring(&CLIENT_ID,client_id);
      printf("CLIENT: ID %s\n", client_id);
      
      srand ( time (NULL) );    
      PIN1 = rand()%MAX_RANGE; // Get random between 0 and MAX_RANGE
      PIN2 = PIN1;
      printf("PIN1 %d PIN2 %d\n", PIN1, PIN2);
      
      /* Hash CLIENT_ID */
      MPIN_HASH_ID(&CLIENT_ID,&HCID); 
      OCT_output(&HCID);
      
      /* Generate client secret shares */
      rtn = MPIN_GET_CLIENT_SECRET(&MS1,&HCID,&CS1);
      if (rtn != 0)
        {
          printf("MPIN_GET_CLIENT_SECRET(&MS1,&HCID,&CS1) Error %d\n", rtn);
          return 1;
        }
      rtn = MPIN_GET_CLIENT_SECRET(&MS2,&HCID,&CS2);
      if (rtn != 0)
        {
          printf("MPIN_GET_CLIENT_SECRET(&MS2,&HCID,&CS2) Error %d\n", rtn);
          return 1;
        }
      printf("CS1 = 0x"); 
      OCT_output(&CS1);
      printf("CS2 = 0x"); 
      OCT_output(&CS2);
      
      /* Combine client secret shares : TOKEN is the full client secret */
      rtn = MPIN_RECOMBINE_G1(&CS1, &CS2, &TOKEN);
      if (rtn != 0)
        {
          printf("MPIN_RECOMBINE_G1(&CS1, &CS2, &TOKEN) Error %d\n", rtn);
          return 1;
        }
      printf("Client Secret = 0x"); 
      OCT_output(&TOKEN);
      
      /* Generate Time Permit shares */
      date = today();
      printf("Date %d \n", date);
      rtn = MPIN_GET_CLIENT_PERMIT(date,&MS1,&HCID,&TP1);
      if (rtn != 0)
        {
          printf("MPIN_GET_CLIENT_PERMIT(date,&MS1,&HCID,&TP1) Error %d\n", rtn);
          return 1;
        }
      rtn = MPIN_GET_CLIENT_PERMIT(date,&MS2,&HCID,&TP2);
      if (rtn != 0)
        {
          printf("MPIN_GET_CLIENT_PERMIT(date,&MS2,&HCID,&TP2) Error %d\n", rtn);
          return 1;
        }
      printf("TP1 = 0x"); 
      OCT_output(&TP1);
      printf("TP2 = 0x"); 
      OCT_output(&TP2);
      
      /* Combine Time Permit shares */
      rtn = MPIN_RECOMBINE_G1(&TP1, &TP2, &TP);
      if (rtn != 0)
        {
          printf("MPIN_RECOMBINE_G1(&TP1, &TP2, &TP) Error %d\n", rtn);
          return 1;
        }
      printf("Time Permit = 0x"); 
      OCT_output(&TP);
      
      /* This encoding makes Time permit look random */
      if (MPIN_ENCODING(&RNG,&TP)!=0) printf("Encoding error\n");
      printf("Encoded Time Permit= "); OCT_output(&TP);
      if (MPIN_DECODING(&TP)!=0) printf("Decoding error\n");
      printf("Decoded Time Permit= "); OCT_output(&TP);
      
      /* Client extracts PIN1 from secret to create Token */
      rtn = MPIN_EXTRACT_PIN(&CLIENT_ID, PIN1, &TOKEN);
      if (rtn != 0)
        {
          printf("MPIN_EXTRACT_PIN( &CLIENT_ID, PIN, &TOKEN) Error %d\n", rtn);
          return 1;
        }
      printf("Token = 0x"); 
      OCT_output(&TOKEN);
      
      /* Client precomputation */
      MPIN_PRECOMPUTE(&TOKEN,&HCID,&G1,&G2);
      
      /* Client first pass */
      rtn = MPIN_CLIENT_1(date,&CLIENT_ID,&RNG,&X,PIN2,&TOKEN,&SEC,&U,&UT,&TP);
      if (rtn != 0)
        {
          printf("MPIN_CLIENT_1 ERROR %d\n", rtn);
          return 1;
        }
      
      /* Client sends Z=r.ID to Server */
      MPIN_GET_G1_MULTIPLE(&RNG,1,&R,&HCID,&Z);  
      
      /* Server calculates H(ID) and H(T|H(ID)) (if time permits enabled), and maps them to points on the curve HID and HTID resp. */
      MPIN_SERVER_1(date,&CLIENT_ID,&HID,&HTID);
      
      /* Server generates Random number Y and sends it to Client */
      rtn = MPIN_RANDOM_GENERATE(&RNG,&Y); 
      if (rtn != 0)
        {
          printf("MPIN_RANDOM_GENERATE(&RNG,&Y) Error %d\n", rtn);
          return 1;
        }
      printf("Y = 0x"); 
      OCT_output(&Y);
      
      /* Server sends T=w.ID to client */
      MPIN_GET_G1_MULTIPLE(&RNG,0,&W,&HTID,&T);  
      printf("T = 0x"); 
      OCT_output(&T);
      
      /* Client second pass */
      rtn = MPIN_CLIENT_2(&X,&Y,&SEC);
      if (rtn != 0)
        printf("MPIN_CLIENT_2(&X,&Y,&SEC) Error %d\n", rtn);
      printf("V = 0x"); 
      OCT_output(&SEC);
      
      /* Server second pass */
      rtn = MPIN_SERVER_2(date,&HID,&HTID,&Y,&ServerSecret,&U,&UT,&SEC,&E,&F);
      if (rtn != 0)
        {
          err=MPIN_KANGAROO(&E,&F);
          if (err==0) 
            {
              printf("FAILURE Invalid Token Error Code %d\n", rtn);
      }
          else 
            {
              printf("FAILURE PIN Error %d, Error> Code %d\n",err, rtn);
      }
        }
      
      MPIN_CLIENT_KEY(&G1,&G2,PIN2,&R,&X,&T,&CK);
      printf("Client Key = "); OCT_output(&CK); 
      
      MPIN_SERVER_KEY(&Z,&ServerSecret,&W,&U,&UT,&SK);
      printf("Server Key = "); OCT_output(&SK); 
      
      if (!OCT_comp(&CK,&SK))
        {
          printf("Iteration %d FAILURE keys are different\n", iter);
          return 1;
        }
      else
        {
          printf("Iteration %d SUCCESS\n\n", iter);
        } 
    }        
  return 0; 
}
