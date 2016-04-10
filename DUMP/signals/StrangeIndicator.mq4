//+------------------------------------------------------------------+
//|                                             StrangeIndicator.mq4 |
//|                            MT4 realization created by CrazyChart |
//|                                    mailto:newcomer2003@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "MT4 realization created by CrazyChart"
#property link      "mailto:newcomer2003@yandex.ru"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
//---- input parameters
extern int       shift=5;
//---- buffers
double ExtMapBuffer1[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//----
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
//---- TODO: add your code here
   int cb=1; 
   int Ma534, Ma,ma7,cb1,min1,max1,c7; 
   double EMAclose,EMAhigh,EMAlow,ma3; 


for (cb = 1;cb<=Bars;cb++) { 
/*
period: number of periods for calculation
ma_method: mode of calculation (MODE_SMA,MODE_EMA,MODE_SMMA,MODE_LWMA)
ma_shift: MA shift
applied_price: applied price (PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW,PRICE_MEDIAN,PRICE_TYPICAL,PRICE_WEIGHTED)
shift: shift relative to the current bar (number of periods back), where the data is to be taken from
*/


EMAclose=iMA(NULL,0,shift,0,MODE_EMA,PRICE_CLOSE,cb); 
EMAlow=iMA(NULL,0,shift,0,MODE_EMA,PRICE_LOW,cb); 
EMAhigh=iMA(NULL,0,shift,0,MODE_EMA,PRICE_HIGH,cb); 

ma3=(EMAclose-EMAlow)/(EMAhigh-EMAlow)*100; 
//ma3=(close[cb]-low[cb])/(high[cb]-low[cb])*100; 

ExtMapBuffer1[cb-1]=ma3; 

} 
   
   
   
   
   
   
   
   
   
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+