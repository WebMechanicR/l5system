//+------------------------------------------------------------------+
//|                                                      Kaufman.mq4 |
//|                              Copyright © 2004, by konKop & wellx |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, by konKop, GOODMAN, Mstera, af + wellx"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Sienna
//---- input parameters
extern int       periodAMA=9;
extern int       nfast=2;
extern int       nslow=30;
extern int       G=2;

//---- buffers
double kAMAbuffer[];
//+------------------------------------------------------------------+

int    cbars=0;
double slowSC,fastSC;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   //SetIndexDrawBegin(0,nslow+nfast);
   SetIndexBuffer(0,kAMAbuffer);
   IndicatorDigits(6);
   
   //slowSC=0.064516;
   //fastSC=0.2;
   
   cbars=IndicatorCounted();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i,pos=0;
   double noise,noise0,AMA,AMA0,signal,ER;
   double dSC,ERSC,wlxSSC;
   
//---- TODO: add your code here
   slowSC=(2.0 /(nslow+1));
   fastSC=(2.0 /(nfast+1));
   

   if (Bars<=(periodAMA+2)) return(0);
   
   
   //---- check for possible errors
   if (cbars<0) return(-1);
//---- last counted bar will be recounted
   if (cbars>0) cbars--;
   pos=Bars-periodAMA-2;
   //pos=100;
   //Print("cbars1: ", cbars);
   AMA0=Close[pos+1];
   while (pos>=0)
     {
      if(pos==Bars-periodAMA-2) AMA0=Close[pos+1];
      signal=MathAbs(Close[pos]-Close[pos+periodAMA]);
      noise=0;
      for(i=0;i<periodAMA;i++)
       {
        noise=noise+MathAbs(Close[pos+i]-Close[pos+i+1]);
       };
      ER =signal/noise;
      dSC=(fastSC-slowSC);
      ERSC=ER*dSC;
      wlxSSC=ERSC+slowSC;
      AMA=AMA0+(MathPow(wlxSSC,G)*(Close[pos]-AMA0));
      kAMAbuffer[pos]=AMA;
      
      /*
      Print("dsC: ", dSC);
      Print("ERSC: ", ERSC);
      Print("slowSc: ", slowSC);
      Print("fastSc: ", fastSC);
      Print("signal: ", signal);
      Print("noise: ",  noise);
      Print("SSC: ", wlxSSC);
      Print("AMA0: ", AMA0);
      Print("AMA: ", AMA);
      Print("MathPow: ", MathPow(wlxSSC,G));
      Print("pos: ", pos);
      Print("close[pos]: ", Close[pos]);
      Print("------------------------ ", 0);
    */
      AMA0=AMA;
      pos--;
     };
     //Print("cbars2: ", cbars);
//----
   return(0);
  }

