//+------------------------------------------------------------------+
//|                                                     J_TPO_OSC.mq4 |
//|                      Copyright © 2005,                           |
//|                                                                  |
//+------------------------------------------------------------------+
//
// This is the dual oscillator using J_TPO.
// It uses two distinct timescales. If both are positive that is a trend buy,
// if both are negative a trend sell, and mixed, neutral.
//
//  Matt (mbkennel@gmail.com)
//
// This code is released under the terms of the GNU General Public License V2
// 
#property copyright "Copyright © 2005"
#property link      "www.metatrader.org"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 White
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_maximum 100
#property indicator_minimum -100

//---- input parameters
extern int       LenShort=23;
extern int       LenLong=39;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3, ExtMapBuffer4);
  
   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| J_TPO indicatop                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=MathMin(Bars-counted_bars+1,Bars-LenLong-1);
   
   
   if ((LenLong < 3) || (LenShort <3)) {
      Print("J_TPO_CD:  lengths must be at least 3");
      return(0); //  
   }
   double sqrtLenShort = MathSqrt(LenShort+0.0);
   double sqrtLenLong = MathSqrt(LenLong+0.0);
   
   for (int i=limit; i>=0; i--) {
     double J1, J2, diff;
     
     J1 = J_TPO_value(Close,LenShort,i);
     J2 = J_TPO_value(Close,LenLong,i);
     
     ExtMapBuffer1[i]=J1*100.0;
     ExtMapBuffer2[i]=J2*100.0;
     if (J1*J2 >= 0.0) {
      // same sign.
         if (J1 > 0.0) {
            ExtMapBuffer3[i] = 50.0;
            ExtMapBuffer4[i] = 0.0;
         } else if (J1 < 0.0) {
            ExtMapBuffer3[i] = 0.0;
            ExtMapBuffer4[i] = -50.0;
         }
     } else {
      ExtMapBuffer3[i] = 0.0;
      ExtMapBuffer4[i] = 0.0; 
     }
    
    
   }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

double J_TPO_value(double input[], int Len, int shift) {
//
// compute the J_TPO function on input[shift], looking back up to Len data previous
//
   double value, normalization, Lenp1half; 
   double accum, tmp, maxval; 
   int j, maxloc, m;
   double arr1[], arr2[], arr3[]; 
   bool flag;
   accum=0; 
   
   ArrayResize(arr1,Len+1); 
   ArrayResize(arr2,Len+1); 
   ArrayResize(arr3,Len+1); 

   for (m=1; m<=Len; m++) {
     arr2[m] = m; 
     arr3[m] = m; 
     arr1[m] = input[shift+Len-m]; 
   } 


   // sort arr1[] in ascending order, arr2[] is the permutation index 
   // Note, this is a poor quadratic search, and will not scale well with Len
   for (m=1; m<=(Len-1); m++) {

      //
      // find max value & its location in arr1 [m..m+Len]
      //
     maxval = arr1[m]; 
     maxloc = m; 
     for (j=m+1; j<=Len; j++) {
        if (arr1[j] < maxval) {
           maxval = arr1[j]; 
           maxloc = j;
           }
     } 
         
     //
     // Swap arr1[m] with its max value
     // amd similarly for arr2.
         
     tmp = arr1[m]; 
     arr1[m] = arr1[maxloc]; 
     arr1[maxloc] = tmp; 
     tmp = arr2[m]; 
     arr2[m] = arr2[maxloc]; 
     arr2[maxloc] = tmp;
   } 

      
   //
   // arr3[1..Len] is nominally 1..m, but this here adjusts for
   // ties.
   m = 1; 
   while (m < Len) {
   
     // Search for repeated values. 
     j = m + 1; 
     flag = true; 
     accum = arr3[m]; 
     while (flag) {
       if (arr1[m] != arr1[j]){
          if ((j - m) > 1) {
             // a streak of repeated values was found
             // and so replace arr3[] for those with 
             // its average
             accum = accum/(j - m); 
             for (int n=m; n<=(j-1); n++)
                arr3[n] = accum;
               
          } 
          flag = false; 
       } else {
          accum += arr3[j]; 
          j++;  
       }  // if
     } // while flag 
     m = j; 
   } // while (Len > m) 


      // This is the real guts of the J_TPO
      // it is a simple statistic to see if the ranks, when applied in sorted order are
      // "correlated" with 1..Len, a simple cross correlation of ranks.
      // so if they are sorted then this gives 1, and if they are anti-sorted they give -1
      // and similarly for intermediate values. 
 
   normalization = 12.0 / (Len*(Len-1)*(Len+1)); 
   Lenp1half = (Len + 1) * 0.5; 

   for (accum=0,m=1; m<=Len; m++) {
        // Print("m="+m+"Arr2[m] ="+arr2[m]+" arr3[m]="+arr3[m]); 
      accum += (arr3[m] - Lenp1half) * (arr2[m] - Lenp1half);
   }
              
   value = normalization * accum;
    // Print("JTPO_B:  accum = "+accum+" norm = "+normalization); 
   
   return(value); 
}