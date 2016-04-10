//+------------------------------------------------------------------+
//|                                               J_TPO_Velocity.mq4 |
//|                      Copyright © 2005,                           |
//|                                                                  |
//+------------------------------------------------------------------+
//
// J_TPO_Velocity is a modification by Matt Kennel of J_TPO_Clean.
// J_TPO is in its original form, an oscillator between -1 and +1, 
// a nonparametric statistic quantifying how well the prices are ordered
// in consecutive ups (+1) or downs (-1) or intermediate cases in between.
//
// J_TPO_Velocity takes that value and multiplies it by the range, highest high
// to lowest low in the period (in pips), divided by the period length. 
// Therefore, J_TPO_Velocity is a rough estimate of "velocity" as in 
// "pips per bar".  Positive of course means going up and negative means going down.
// 
// J_TPO_Velocity thus crosses zero at exactly the same time as J_TPO, but hte
// absolute magnitude is different. 
//
//  Matt (mbkennel@gmail.com)
//
// This code is released under the terms of the GNU General Public License V2
// 
#property copyright "Copyright © 2005"
#property link      "www.metatrader.org"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int       Len=14;
//---- buffers
double ExtMapBuffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer1);
   
   
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
   limit=MathMin(Bars-counted_bars-Len,Bars-Len-1);
   
   
   if (Len < 3) {
      Print("J_TPO_B:  length must be at least 3");
      return(0); //  
   }

   for (int i=limit; i>=0; i--) {
     
     ExtMapBuffer1[i]=J_TPO_value(Close,Len,i) * Range(Len,i)/Len;  
    
   }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

double Range(int Len, int shift) {
     // Return the range between highest and lowest of Len
     // bars, starting at shift, measured in pips.
     double H = High[Highest(NULL,0,MODE_HIGH,Len,shift)];
     double L = Low[Lowest(NULL,0,MODE_LOW,Len,shift)];

     return ((H-L)/Point);
} 

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