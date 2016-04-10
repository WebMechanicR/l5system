
//+------------------------------------------------------------------+
//|                                                         RFTL.mq4 |
//|                            Copyright 2005, Gordago Software Ltd. |
//|                                          http://www.gordago.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2005, Gordago Software Ltd."
#property link      "http://www.gordago.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Aquamarine

double RFTLBuffer[];

#define RFTLPeriods 44  

double g_RFTLKoef[RFTLPeriods]=
 {-0.0025097319, +0.0513007762 , +0.1142800493 , +0.1699342860 , +0.2025269304 ,
  +0.2025269304, +0.1699342860 , +0.1142800493 , +0.0513007762 , -0.0025097319 ,
  -0.0353166244, -0.0433375629 , -0.0311244617 , -0.0088618137 , +0.0120580088 ,
  +0.0233183633, +0.0221931304 , +0.0115769653 , -0.0022157966 , -0.0126536111 ,
  -0.0157416029, -0.0113395830 , -0.0025905610 , +0.0059521459 , +0.0105212252 ,
  +0.0096970755, +0.0046585685 , -0.0017079230 , -0.0063513565 , -0.0074539350 ,
  -0.0050439973, -0.0007459678 , +0.0032271474 , +0.0051357867 , +0.0044454862 ,
  +0.0018784961, -0.0011065767 , -0.0031162862 , -0.0033443253 , -0.0022163335 ,
  +0.0002573669, +0.0003650790 , +0.0060440751 , +0.0018747783 };

int init()
  {
   IndicatorBuffers(1);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0, RFTLBuffer);
   SetIndexDrawBegin(0,44);
   
   return(0);
  }
int deinit()
  {
   return(0);
  }
int start()
{
   int    counted_bars=IndicatorCounted();
   int    j,pos;
   double sum2;
   if(counted_bars<0)  return(-1);
   
   for (pos=Bars-counted_bars-1;pos>=0;pos--)
     {
	   sum2=0;          // zero summary
      for(j=0;j<RFTLPeriods;j++) sum2+=g_RFTLKoef[j]*Close[pos+j];//Counted RFTL[pos]
	   RFTLBuffer[pos]=sum2;
     }
   return(0);
}		