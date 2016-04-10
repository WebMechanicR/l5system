//+------------------------------------------------------------------+
//|                                                     MTF_MACD.mq4 |
//|                                      Copyright © 2006, Keris2112 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112"
#property link      "http://www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 Black

//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
**************************************************************************/
extern int TimeFrame=0;
extern int FastEMA=13;
extern int SlowEMA=17;
extern int SignalEMA=9;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(5);   
//---- indicator line
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,1);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2 );
      
   SetIndexDrawBegin(0,SignalEMA);
   SetIndexDrawBegin(1,SignalEMA);
   
//---- 4 indicator buffers mapping
   if(!SetIndexBuffer(0,ExtMapBuffer1) &&
   !SetIndexBuffer(1,ExtMapBuffer2)&&
   !SetIndexBuffer(2,ExtMapBuffer3) &&
   !SetIndexBuffer(3,ExtMapBuffer4))
   Print("cannot set indicators\' buffers!");

//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr="Current Timeframe";
   }
   IndicatorShortName("MACD-2_MTF ("+FastEMA+", "+SlowEMA+", "+SignalEMA+") ("+TimeFrameStr+")");

  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF MACD                                            |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
 
// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++;

/***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/  
 
   ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"MACD-2",FastEMA,SlowEMA,SignalEMA,0,y); 
   ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"MACD-2",FastEMA,SlowEMA,SignalEMA,1,y); 
   ExtMapBuffer3[i]=iCustom(NULL,TimeFrame,"MACD-2",FastEMA,SlowEMA,SignalEMA,2,y); 
   ExtMapBuffer4[i]=iCustom(NULL,TimeFrame,"MACD-2",FastEMA,SlowEMA,SignalEMA,3,y);   
   }  
     
//
   
  
  
   return(0);
  }
//+------------------------------------------------------------------+