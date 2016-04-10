//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|  Modified 2006, Matt Kennel, Metatrader Yahoo group              |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Metatrader Yahoo group!"
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int MA_Period=13;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int MA_time_frame=60; //  The time frame you want in minutes
// M5 = 5
// M15 = 15
// M30 = 30
// H1  = 60
// H4  = 240
// D1  = 1440, etc

//---- indicator buffers
double ExtMapBuffer[];
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,MA_Shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="EMA(";  draw_begin=0; break;
      case 2 : short_name="SMMA("; break;
      case 3 : short_name="LWMA("; break;
      default :
         MA_Method=0;
         short_name="SMA(";
     }
   IndicatorShortName(short_name+MA_Period+"); TF="+MA_time_frame);
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----

   for (int i=Bars-ExtCountedBars-1; i >= 0; i--) {
      datetime tofnow = Time[i]; 
      
      int ibar_on_tf = iBarShift(Symbol(),MA_time_frame,tofnow,false);
      ExtMapBuffer[i] = iMA(Symbol(),MA_time_frame,MA_Period,MA_Shift,MA_Method,PRICE_CLOSE,ibar_on_tf); 
   
   }
//---- done
   return(0);
  }

