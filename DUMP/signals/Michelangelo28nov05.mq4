//+------------------------------------------------------------------+
//|                                               Michelangelo.mq4   |
//|                      Copyright © 2005, Matt Kennel               |
//|
//|                                                                  |
//|  Algorithm:  Apply a H/L indicator like SMI, avg'd w/ power law  |
//|              lengths.   Then apply a Kaufman AMA filter.         |
//|              Then a 'signal' EMA.  Use crossover of this as      |
//|              potential trading signal.                           |
//|                                                                  |
//|  Idea:       Try to stay on the side of a trend but reverse      |
//|              quickly if there is a breakout.  KaufmanAMA can     |
//|              be made sensitive to those.                         |
//|                                                                  |
//|  Revision date:  2005-11-30                                      |
//|                                                                  |
//|  History:                                                        |
//|  2005-11-30:   Added BreakoutEnhancementFactor to give more      |
//|                weight to breakouts.                              |
//|                                                                  |
//|  2005-11-28:   Upload to Yahoo groups.                           |
//|                                                                  |
//+------------------------------------------------------------------+
//
// LICENSED UNDER THE GNU GENERAL PUBLIC LICENSE (GPL) version 2
//
// with additional requirement that any use of this code for money management
// purposes for all uses except personal trading for one's own account
// (or immediate family members) must be licensed specially with the author.   
// Such uses are encouraged, but require separate licensing. 
//
//
// Sale or redistribution of this code in any way must be accompanied 
// with source code per GPL terms.
// 

#property copyright "Copyright © 2005, Matt Kennel (mbkennel@gmail.com)"
#property link      "http://www.metatrader.org"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Red
#property indicator_level1 0
//---- input parameters

//
// Try these on M30 charts on trendy currencies.
// THESE PARAMETERS ARE NOT OPTIMIZED BY ANY MEANS. 
//
// Brief run-down.  Structure is derived from "SMI" indicator. 
//
// The first part, minkernel, maxkernel, and exponent
// correspond to the power-law averaging of relative position of self to 
// highs and lows.   The underlying statistic is sort of like a "stochastic",
// the purpose of the averaging is to not be as dependent on a single, fixed lookback.
// If the present Close is above or below prior highs then an additional boost is
// given per BreakoutEnhancementFactor. (set to zero to turn off). 
// 
// The relative position and range series (kept separate here) are each subjected
// to a Kaufman adaptive moving average.  This AMA computes an internal 'signal to noise'
// ratio to see if it is choppy (no consistent trend), in which case the smoothing is strong
// and laggy, or if it feels like a continuing trend, in which case the smoothing is light
// and fast.  Parameters here are "periodAMA", which is the lookback for S/N, nfast, and nslow
// which control the range between fastest and slowest smoothing, and "G".  This is an exponent
// which, for larger values than '1', more greatly emphasize the high S/N versus low.  In practice,
// this means that for larger 'G', there are more flat periods, and then more sensitive to breakouts.
//
// After the KaufmanAMA filtering, the two series are 
// "predictively EMA filtered" (similar to a Hull MA), with parameter Period_R,
// and then divided to form the main indicator line in white.
//
// Finally, this indicator line is filtered with a conventional EMA with period 'Signal'
// to give the red signal line.  Trading signals are generally a crossover of white 
// with red, with the slope of the white in the proper direction.    This will probably
// require intra-bar consideration for breakouts when used in real-time trading. 
// Other possible trading signal could be just an absolute change in direction of the
// underlying statistic, ignoring the red signal line.   Who knows? 
//
// Best nutshell description is "a bastardized sort of trend-following stochastic",
// or otherwise "WTF?".  But it does occasionally seem to show some nice signals
// on trendy currencies.   Probably not good on choppy USD/CAD or highly reversing crosses. 

//
// PLEASE EXPERIMENT WITH PARAMETERS HEAVILY, and report to the Yahoo! group and
// www.metatrader.org.
// 
// There is nothing sacred with these. 
// They have quite distinct effects depending on the setting, timescale and their values.

//
// High-Low offset kernel parameters.
//
extern int       minkernel=1;
extern int       maxkernel=80; 
extern double    Exponent=1.0; 
int    KernelLength;
double kernel[]; 
double working[]; 

// Predictive EMA Smoothing parameter.
extern double    Period_R=3; 

// Kaufman AMA parameters
extern int       periodAMA=12;
extern int       nfast=6;
extern int       nslow=60;
extern double    G=2.5;

// How much 
extern double    BreakoutEnhancementFactor = 4.0; 

// how much extra to add for breakouts. 

extern double    Signal=5;
extern bool      flip = false;   // if True, then reverse order of PEMA and Kaufman AMA
extern bool      emit_running_values = true; 
// if true then emit running values to Journal output ("Experts") tab
 

//extern int       SignalShift=0;
//---- buffers
double Michelangelo[];
double Signal_Buffer[];
double SM_Buffer[];
double EMA_SM[];
double EMA2_SM[];
double EMA_HQ[];
double EMA2_HQ[];
double HQ_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Michelangelo);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal_Buffer);
   SetIndexLabel(0,"Michelangelo");
   SetIndexLabel(1,"Signal Michelangelo");
   SetIndexBuffer(2,SM_Buffer);
   SetIndexBuffer(3,EMA_SM);
   SetIndexBuffer(4,EMA2_SM);
   SetIndexBuffer(5,EMA_HQ);
   SetIndexBuffer(6,EMA2_HQ);
   SetIndexBuffer(7,HQ_Buffer);
   
   string comment ="Michelangelo: PL["+minkernel+","+maxkernel+"],AMA["+periodAMA+","+nfast+","+nslow+","+G+"],PEMA["+Period_R+"],Signal["+Signal+"]";
   if (flip)
      comment = comment+" flip=true";
   else
      comment = comment+" flip=false"; 
   Comment(comment); 
   IndicatorShortName("Michelangelo");
//----
   KernelLength= maxkernel+1;
   initialize_kernel(minkernel,maxkernel,KernelLength,Exponent);
   ArrayResize(working,KernelLength);    
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int i;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int potentialbars = Bars-counted_bars;  
      
   //
   // Indicator logic. 
   // First time in, counted_bars will be zero and we do full computation.
   // Each additional tick, start() will be counted again (but not init())
   // and counted bars will be much larger, and we only recompute
   // what needs to be recomputed. 
   
  
   // we cannot go back further than Bars-maxkernel-1; 
   int limit1 = MathMin(potentialbars,Bars-maxkernel-1);
   for (i=limit1;i>=0;i--)
      {

      for (int j=minkernel; j<=maxkernel; j++) {
         double H = High[Highest(NULL,0,MODE_HIGH,j,i+1)];
         double L = Low[Lowest(NULL,0,MODE_LOW,j,i+1)];
         double delta = H-L;
         if (delta < Point) delta = Point; // one pip difference minimum.
         working[j] = delta;
      }
      HQ_Buffer[i] = convolve(working,kernel,minkernel,maxkernel); 
      for (j=minkernel; j<=maxkernel; j++) {
         H = High[Highest(NULL,0,MODE_HIGH,j,i+1)];
         L = Low[Lowest(NULL,0,MODE_LOW,j,i+1)];
         double C= Close[i];
         double val = C - (H+L)/2.0;
//         if (C < L) C = L;
//         if (C > H) C = H;
         if (C > H)
            val += (C-H)*BreakoutEnhancementFactor; 
            
         if (C <L)
            val -= (L-C)*BreakoutEnhancementFactor;
         
         working[j] = val; 
                  
         }
      SM_Buffer[i] = convolve(working,kernel,minkernel,maxkernel);
     }

   //
   // These next computations have theoretically 'infinite' depth
   // therefore we need to do them from the beginning on each tick.
   //

   int limit2 = Bars-maxkernel-1;
   if (flip) {
     // EMA predictive then kaufman
     EMAPredictiveSmoothOnArray(limit2, Period_R, Period_R, SM_Buffer, EMA_SM); 
     EMAPredictiveSmoothOnArray(limit2, Period_R, Period_R, HQ_Buffer, EMA_HQ); 
     KaufmanOnArray(limit2, EMA_SM, EMA2_SM, periodAMA, nfast, nslow, G);
     KaufmanOnArray(limit2, EMA_HQ, EMA2_HQ, periodAMA, nfast, nslow, G);
   } else {
      // kaufman then EMApredictive
     KaufmanOnArray(limit2, SM_Buffer, EMA_SM, periodAMA, nfast, nslow, G);
     KaufmanOnArray(limit2, HQ_Buffer, EMA_HQ, periodAMA, nfast, nslow, G);
     EMAPredictiveSmoothOnArray(limit2, Period_R, Period_R, EMA_SM, EMA2_SM); 
     EMAPredictiveSmoothOnArray(limit2, Period_R, Period_R, EMA_HQ, EMA2_HQ); 
   } 
   
   int limit3 = limit2-periodAMA-Period_R; 
   for (i=limit2;i>=0;i--) {
      val = 100*EMA2_SM[i]/0.5/EMA2_HQ[i];
      if (val > 100.0) val = 100.0;
      if (val < -100.0) val = -100.0;
      if (i >= limit3) val = 0.0; 
      Michelangelo[i]= val; 
      }
     
   EMAOnArray(limit2,2.0/(Signal+1.0),Michelangelo,Signal_Buffer);    
   for (i=limit2-1; i>= 0; i--) {
      val = Signal_Buffer[i];
      if (val > 500.0) val = 500.0;
      if (val < -500.0) val = -500.0;
      Signal_Buffer[i] = val;
   }      

   if (emit_running_values) { 
   //
   // We print out the current value to the journal.  This will be
   // updated every tick--but with limit probably set to 0 or 1;
   double statisticnow = Michelangelo[0]; 
   double signalnow = Signal_Buffer[0];
   double diff = statisticnow-signalnow; 
   Print("Time="+TimeToStr(CurTime(),TIME_SECONDS)+" Michelangelo="+statisticnow+" Signal="+signalnow+" diff="+diff); 
  }
   return(0);
  }
//+------------------------------------------------------------------+



void KaufmanOnArray(int N, double input[], double& output[], int periodAMA, int nfast, int nslow, double G) {
   // perform a Kaufman moving average on input[], saving to output[]
   double slowSC=(2.0 /(nslow+1));
   double fastSC=(2.0 /(nfast+1));
   int    i;
   double AMA0, AMA, signal, noise, ER, dSC,ERSC,wlxSSC;
 //  double noise,noise0,AMA,AMA0,signal,ER;
   
   int nmax = N - periodAMA-1;
   
   AMA0 = input[nmax+1];
   for (i=nmax; i >= 0; i--) {
      // loop down
      signal=MathAbs(input[i]-input[i+periodAMA]);
      noise=0;
      for(int j=0;j<periodAMA;j++)
       {
        noise=noise+MathAbs(input[i+j]-input[i+j+1]);
       }
      if (noise < Point) noise = Point; // minimum 1 pip noise
      ER =signal/noise;
      dSC=(fastSC-slowSC);
      ERSC=ER*dSC;
      wlxSSC=ERSC+slowSC;
      AMA=AMA0+(MathPow(wlxSSC,G)*(input[i]-AMA0));
      output[i]=AMA;
      AMA0 = AMA;
   }

   for (i=N; i > nmax;i--) {
      output[i] = input[i];
   } 

}

void EMAPredictiveSmoothOnArray(int N, double L, double Lfinal, double input[], double& output[]) {
//
// This "predictive/smoothed" EMA is very much like the HMA (hull MA).
// This particular subroutine specializes to a single "L" (input length
// is short length), and no 'time ahead'.
// 
// Idea: do an EMA with lengths L and 2*L, and extrapolate from difference.
// That is a 'zero-lag' estimator of position, but has noise.  Then
// Do EMA with length sqrt(Lfinal) for final smoothing.
   double fastema[], slowema[], difference[];
  //Print("In EMAPredictiveSmooth, N = "+N); 
   ArrayResize(fastema,N);
   ArrayResize(slowema,N);
   ArrayResize(difference,N);
   
   double fastp, finalp;
   
   fastp = 2.0/(1.0+L);
   finalp = 2.0/(1.0+MathSqrt(Lfinal));
   
   EMAOnArray(N,fastp,input,fastema); 
   EMAOnArray(N,fastp,fastema,slowema); 
   for (int i=N; i>=0; i--) {
      difference[i] = 2.0*fastema[i] - slowema[i]; 
   }
   EMAOnArray(N,finalp,difference,output); 
}


void EMAOnArray(int N, double p, double input[], double& output[]) {
   // Perform an "EMA" on array input[] with mixing parameter 'p'
   // 0 < p < 1.
   //
   // p, conventionally is 2.0/(L+1.0) where L is the 'length' parameter.
   // In an EMA, the length and thus 'p' need not be integers.
   // initial value is input[N-1], and will set output[N-1] down to output[0].
   //
   
   double omp = 1.0-p; 
   double ema = input[N-1];   
   for (int i=N-1; i>=0; i--) {
      double v = input[i];
      ema = p*v + omp*ema;
      output[i] = ema; 
   }
}

void initialize_kernel(int from, int to, int KernelLength, double PowerExponent) {
   double kernelsum; 
   Print("In Initialize_kernel KernelLength = " + KernelLength); 
   ArrayResize(kernel,KernelLength); 
   
   kernelsum = 0.0; 
   for (int i=from; i<=to; i++) {
      kernel[i] = MathPow( (i)*0.01, -PowerExponent); 
      kernelsum += kernel[i];
   }
   for (i = from; i<=to; i++) {
      kernel[i] = kernel[i] / kernelsum; 
   }
}  
double convolve(double array[], double kernel[], int from, int to) {
// return sum(i=0..n-1) array[i]*kernel[i]
// conventionally kernel[*] sums to 1, but this is not enforced here.
   double sum = 0.0;
   for (int i=from; i<to; i++) 
      sum += array[i]*kernel[i];

   return(sum); 
}

