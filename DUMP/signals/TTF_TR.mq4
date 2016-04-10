//+------------------------------------------------------------------+
//|                                       Trendscalpindic.mq4        |
//|                        Based on Nick Beluk's TTF implementation  |
//|                        No redrawing, no lookahead, nosmoothing   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"
#property link      "beluck[at]gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
//---- input parameters
extern int TTFbars=15;
//15=default number of bars for computation
//---- buffers
double MainBuffer[];
double SignalBuffer[];
//----
int TopLine=100;
int BottomLine=-100;
int draw_begin1=0;
int draw_begin2=0;
double  HighestHighRecent=0;
double  HighestHighOlder =0;
double  LowestLowRecent =0;
double  LowestLowOlder =0;
double  BuyPower =0;
double  SellPower=0;
double  TTF=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(2);
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, MainBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, SignalBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="TTF_TR("+TTFbars+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
//----
   draw_begin1=TTFbars*2+1;
   draw_begin2=draw_begin1;
   SetIndexDrawBegin(0,draw_begin1);
   SetIndexDrawBegin(1,draw_begin2);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| ttf                                            |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k;
   int    counted_bars=IndicatorCounted();
   double price;
//----
   if(Bars<=draw_begin2) return(0);
//---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=draw_begin1;i++) MainBuffer[Bars-i]=0;
      for(i=1;i<=draw_begin2;i++) SignalBuffer[Bars-i]=0;
     }
//---- %K line
   i=Bars-draw_begin1;
   if(counted_bars>draw_begin1) i=Bars-counted_bars-1;
   while(i>=0)
     {
   HighestHighRecent=High[Highest(Symbol(), 0, MODE_HIGH,1,i)];
   HighestHighOlder=High[Highest(Symbol(), 0, MODE_HIGH,TTFbars,i+1)];
   LowestLowRecent=Low [Lowest (Symbol(), 0, MODE_LOW,1,i)];
   LowestLowOlder=Low [Lowest (Symbol(), 0, MODE_LOW,TTFbars,i+1)];
   BuyPower=HighestHighRecent-LowestLowOlder;
   SellPower=HighestHighOlder-LowestLowRecent;
   TTF=(BuyPower-SellPower)/(0.5*(BuyPower+SellPower))*100;
     //Print (Time[i], "   ", HighestHighRecent, ",  ",HighestHighOlder, ",  ", LowestLowRecent, ",  ",LowestLowOlder    );

  MainBuffer[i]=TTF;
  i--;
 }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//---- signal line is simple movimg average
   for(i=0; i<limit; i++) {
      if (MainBuffer[i]>=0) 
         SignalBuffer[i]=TopLine;
      else
         SignalBuffer[i]=BottomLine;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

