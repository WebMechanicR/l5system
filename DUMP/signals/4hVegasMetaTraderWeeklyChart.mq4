//+------------------------------------------------------------------+
//| 4Hour Vegas Model - Weekly Chart MA lines                        |
//|                                                           Spiggy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Spiggy"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Blue


//---- input parameters

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  int    limit;
  int    counted_bars=IndicatorCounted();
  double EMA21;
  double SMA5;
   
  //---- check for possible errors
  if(counted_bars<0) return(-1);
  //---- last counted bar will be recounted
  if(counted_bars>0) counted_bars--;
  limit=Bars-counted_bars;
  //---- main loop
  for(int i=0; i<limit; i++)
  {
    //---- ma_shift set to 0 because SetIndexShift called abowe
    EMA21=iMA(NULL,0,21,0,MODE_EMA,(PRICE_HIGH+PRICE_LOW)/2,i);
    SMA5 =iMA(NULL,0,5,0,MODE_SMA,(PRICE_HIGH+PRICE_LOW)/2,i);
         
    ExtMapBuffer1[i] = EMA21;
    ExtMapBuffer2[i] = SMA5;
  }

  return(0);
}
//+------------------------------------------------------------------+