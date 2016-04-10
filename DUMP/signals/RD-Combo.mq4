
//+------------------------------------------------------------------+
//|                                                     RD.COmbo.mq4 |
//|                                                         Shimodax |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Shimodax & RickyD"
#property  link     "http://www.strategybuilderfx.com/forums/showthread.php?t=15187"


#property indicator_separate_window

#property indicator_buffers 4
#property indicator_color1 Gray
#property indicator_color2 OrangeRed
#property indicator_color3 LawnGreen
#property indicator_color4 Gold

#property indicator_maximum 5
#property indicator_minimum -5

#property indicator_level1 4
#property indicator_level2 -4

//---- buffers
extern bool DoAlertForEntry= false;
extern bool DoAlertForExit= false;
extern int HistorySize= 1000;
extern int ColorThreshold= 5;
extern double NoiseFilterRVI= 0.03;   // delay exit signal
extern bool DebugLogger= false;
extern bool DebugLoggerData= false;

double LongSignalBuffer[],
       ShortSignalBuffer[],
       NeutralBuffer[],
       SignalBuffer[];

double Osc[], 
       Osct3[];
       

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,NeutralBuffer);
   SetIndexEmptyValue(0, 0.0);

   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(1,ShortSignalBuffer);
   SetIndexEmptyValue(1, 0.0);

   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(2,LongSignalBuffer);
   SetIndexEmptyValue(2, 0.0);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,SignalBuffer);
   // SetIndexEmptyValue(3, 0.0);

   IndicatorShortName("RD-Combo()= ");

   return(0);
}



int start()
{
   static bool didentryalert= false, didexitalert= false;
   int counted_bars= IndicatorCounted(),
         lastbar, result;

   if (Bars<=100) 
      return(0);
      
   if (counted_bars>0)
      counted_bars--;
      
   lastbar= Bars - counted_bars;
   lastbar= MathMin(HistorySize, lastbar);

   // 
   // precalc forecast oscillater array
   //   
   ArrayResize(Osc, Bars);
   ArrayResize(Osct3, Bars);
   ForecastOsc(0, Bars, Osc, Osct3, 15, 3, 0.7);

   // 
   // check for signals
   //   
   Combo(0, lastbar, LongSignalBuffer, ShortSignalBuffer, NeutralBuffer, SignalBuffer, ColorThreshold);
        
        
        
   //
   // do alerting
   //             
   if (DoAlertForEntry>0 && SignalBuffer[0]!=0 && SignalBuffer[1]==0) {
      if (!didentryalert) {
         Alert("RD signals trade entry on ", Symbol(),"/",Period());
         didentryalert= true;
      }
   }
   else {
      didentryalert= false;
   }  

   if (DoAlertForExit>0 && SignalBuffer[0]==0 && SignalBuffer[1]!=0) {
      if (!didexitalert) {
         Alert("RD signals trade exit on ", Symbol(),"/",Period());
         didexitalert= true;
      }
   }
   else {
      didexitalert= false;
   }

   return (0);
}




//+------------------------------------------------------------------+
//| Combo Indicator (All-In-One signal)                              |
//+------------------------------------------------------------------+
int Combo(int offset, int lastbar, double &longsignalbuf[], double &shortsignalbuf[], double &neutralbuffer[], double &signalbuffer[], int colthreshold)
{
   
   int  val, 
        lookupidx= 0,
        signalstate= 0;

   double 
         adxmain,
         adxplus,
         adxminus,
         adxmain2,
         adxplus2,
         adxminus2,
         cci, 
         rvimain,
         rvisignal, 
         ma5, 
         ma20, 
         ma100, 
         ma200,
         fcblue, 
         fcred;
         

   if (lastbar>Bars)
      lastbar= Bars;
  
       
   for (int i= lastbar+5; i>=offset; i--) {
  
      lookupidx= i;

      ma5= iMA(NULL, 0, 5, 0, MODE_LWMA, PRICE_CLOSE, lookupidx);
      ma20= iMA(NULL, 0, 20, 0, MODE_LWMA, PRICE_CLOSE, lookupidx);
      ma100= iMA(NULL, 0, 100, 0, MODE_LWMA, PRICE_CLOSE, lookupidx);
      ma200= iMA(NULL, 0, 200, 0, MODE_LWMA, PRICE_CLOSE, lookupidx);
   
      cci= iCCI(NULL, 0, 5, PRICE_CLOSE, lookupidx);
   
      rvimain= iRVI(NULL, 0, 1, MODE_MAIN, lookupidx);   
      rvisignal= iRVI(NULL, 0, 1, MODE_SIGNAL, lookupidx); 
   
      adxmain= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, lookupidx);
      adxplus= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, lookupidx);
      adxminus= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, lookupidx);

      adxmain2= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MAIN, lookupidx+1);
      adxplus2= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_PLUSDI, lookupidx+1);
      adxminus2= iADX(NULL, 0, 14, PRICE_CLOSE, MODE_MINUSDI, lookupidx+1);
   
      fcblue= Osc[lookupidx];   // forecast
      fcred= Osct3[lookupidx];  // forecast

      /*     
         fcblue= iCustom(NULL, 0, "RD-ForecastOsc", 0, lookupidx);
         fcred= iCustom(NULL, 0, "RD-ForecastOsc", 1, lookupidx);
   
      double
         fc2blue= iCustom(NULL, 0, "RD-ForecastOsc", 0, lookupidx);
         fc2red= iCustom(NULL, 0, "RD-ForecastOsc", 1, lookupidx);
      
      if (fc2blue!=fcblue) 
         Print("#", lookupidx, "Blue ", fc2blue, " ", fcblue);
      
      if (fc2red!=fcred) 
         Print("#", lookupidx, "Red ", fc2red, " ", fcred);
      */
      
      
      //
      // calc entry signal
      //

      int maval= 0,
          ccival= 0,
          rvival= 0,
          adxval= 0,
          fcval= 0;
  
  
      if (ma5>ma20)
         maval= 1;
      else
         maval= -1;
         
         
      if (cci>0)
         ccival= 1;
      else
      if (cci<0)
         ccival= -1;
      else
         ccival= 0;

         
      if (fcblue>0 && fcred>0 && fcblue>fcred) 
         fcval= 1;
      else
      if (fcblue<0 && fcred<0 && fcblue<fcred) 
         fcval= -1;
      else
         fcval= 0;
         

      if (rvimain>0 && rvisignal>0 && rvimain-rvisignal>0)
         rvival= 1;
      else
      if (rvimain<0 && rvisignal<0 && rvimain-rvisignal<0)
         rvival= -1;
      else
         rvival= 0;

      
      if (adxmain>adxmain2 && adxplus>adxplus2 && adxmain>20 && adxplus>20)
         adxval= 1;
      else
      if (adxmain>adxmain2 && adxminus>adxminus2 && adxmain>20 && adxminus>20)
         adxval= -1;
      else
         adxval= 0;
         
              
      val= maval + ccival + fcval + rvival + adxval;
      
      
      //      
      // exit signal      
      //
      if (signalstate!=0) {

         if (signalstate==1 && (rvimain<0 || rvisignal-rvimain>0.2)) {
             signalstate= 0;
         }

         if (signalstate==-1 && (rvimain>0 || rvimain-rvisignal>0.2)) {
             signalstate= 0;
         }

         if (DebugLogger)
            Print(TimeToStr(Time[i]), " #", i, " rvimain= ", rvimain, ", rvisignal= ", rvisignal, ", diff= ", DoubleToStr(rvimain-rvisignal,2), 
                                               " => signalstate", signalstate);
      }

      
      if (i<=lastbar) {    // ignore the first few loops that were only used to catch previous signal state
      
         if (DebugLogger || DebugLoggerData){
            if (DebugLoggerData) {
               Print(TimeToStr(Time[i]), " # --------------------------------------------------------------------------");
               Print(TimeToStr(Time[i]), " #", i, " MA 5/20/100/200", ma5, "/", ma20, "/", ma100, "/", ma200);
               Print(TimeToStr(Time[i]), " #", i, " CCI ", cci, ", RVI ", rvimain, "/", rvisignal);
               Print(TimeToStr(Time[i]), " #", i, " ADX(now)  main/+DI/-DI ", adxmain, "/", adxplus, "/", adxminus);
               Print(TimeToStr(Time[i]), " #", i, " ADX(prev) main/+DI/-DI ", adxmain2, "/", adxplus2, "/", adxminus2);
               Print(TimeToStr(Time[i]), " #", i, " Forecast blue/red ", fcblue, "/", fcred);
            }
         
            if (DebugLogger || DebugLoggerData)
               Print(TimeToStr(Time[i]), " #", i, " MAtrend(", maval, ") + CCI(", ccival, ") + FC(", fcval, 
                                                  ") + RVItrend( ", rvival, ") + ADXtrend(", adxval, ") => ", val, " # trade state =", signalstate);
         }

 
         longsignalbuf[i]= 0;
         shortsignalbuf[i]= 0;
         neutralbuffer[i]= 0;

         if (val>=colthreshold) {
            longsignalbuf[i]= val;
            signalstate= 1;
         }
         else
         if (val<=-colthreshold) {
            shortsignalbuf[i]= val;
            signalstate= -1;
         }
         else
            neutralbuffer[i]= val;
            
         signalbuffer[i]= 2*signalstate;
      }
   }

   return (signalstate);
}




//+------------------------------------------------------------------+
//| Calc forecast buffers  from lastbar down to offset               |
//+------------------------------------------------------------------+
void ForecastOsc(int offset, int lastbar, double &osc[], double &osct3[], int regress, int t3, double b)
{

   int shift, length;
   double b2=b*b,
            b3=b2*b, 
            c1=-b3,
            c2=(3*(b2+b3)),
            c3=-3*(2*b2+b+b3),
            c4=(1+3*b+b3+3*b2), 
            n = 1 + 0.5*(t3-1),
            w1 = 2 / (n + 1),
            w2 = 1 - w1,
            wt,forecastosc,t3_fosc,sum,
            e1,e2,e3,e4,e5,e6,tmp,tmp2;
          
   lastbar= MathMin(Bars-31-regress, lastbar);   
 
   for (shift= lastbar+30; shift>=offset; shift--)   {

      length= regress; 
      sum = 0; 
      for (int i = length; i>0; i--) {
         tmp = length+1;
         tmp = tmp/3;
         tmp2 = i;
         tmp = tmp2 - tmp;
         sum = sum + tmp*Close[shift+length-i]; 
      }
      tmp = length;

      wt = sum*6/(tmp*(tmp+1)); 

      forecastosc= (Close[shift]-wt)/wt*100; 

      e1 = w1*forecastosc + w2*e1; 
      e2 = w1*e1 + w2*e2; 
      e3 = w1*e2 + w2*e3; 
      e4 = w1*e3 + w2*e4; 
      e5 = w1*e4 + w2*e5; 
      e6 = w1*e5 + w2*e6; 

      t3_fosc = c1*e6 + c2*e5 + c3*e4 + c4*e3; 

      if (shift<=lastbar) {   // don't put swing in cycle into the signal buffers
         osc[shift] = forecastosc;
         osct3[shift] = t3_fosc;
      }
      
    }
  
   return(0);
}


