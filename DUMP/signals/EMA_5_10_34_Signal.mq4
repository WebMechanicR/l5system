//+------------------------------------------------------------------+
//|                                         EMA-Crossover_Signal.mq4 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+

/*
  +------------------------------------------------------------------+
  | Allows you to enter two ema periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the emas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/   
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

double CrossUp[];
double CrossDown[];
extern int FasterMA = 5;
extern int FasterMode  =    1; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma
extern int MediumMA = 10;
extern int MediumMode  =    1; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma
extern int SlowerMA = 34;
extern int SlowerMode  =    1; // 0 = sma, 1 = ema, 2 = smma, 3 = lwma

double Range, AvgRange;
double fasterMAnow, fasterMAprevious;
double mediumMAnow, mediumMAprevious;
double slowerMAnow, slowerMAprevious;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY,2);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1, DRAW_ARROW, EMPTY,2);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
   SetIndexEmptyValue(1,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
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
int start() {
   int limit, i, counter;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      fasterMAnow = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i);
      fasterMAprevious = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i+1);

      mediumMAnow      = iMA(NULL, 0, MediumMA, 0, MediumMode, PRICE_CLOSE, i);
      mediumMAprevious = iMA(NULL, 0, MediumMA, 0, MediumMode, PRICE_CLOSE, i+1);

      slowerMAnow = iMA(NULL, 0, SlowerMA, 0, SlowerMode, PRICE_CLOSE, i);
      slowerMAprevious = iMA(NULL, 0, SlowerMA, 0, SlowerMode, PRICE_CLOSE, i+1);
      
      CrossUp[i] = 0.0;
      CrossDown[i] = 0.0;
      if ((fasterMAnow > slowerMAnow) && (mediumMAnow > slowerMAnow) && (mediumMAprevious < slowerMAprevious) ) {
         CrossUp[i] = Low[i] - Range*0.5;
      }
      else if ((fasterMAnow < slowerMAnow) && (mediumMAnow < slowerMAnow) && (mediumMAprevious > slowerMAprevious) ) {
         CrossDown[i] = High[i] + Range*0.5;
      }
   }
   return(0);
}

