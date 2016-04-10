//+------------------------------------------------------------------------+
//|                                                 sa#MTEI_Supertrend.mq4 |
//|http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/|
//+------------------------------------------------------------------------+
#property copyright ""
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red


double TrendUp[];
double TrendDown[];
int st = 0;
//extern int SlowerEMA = 6;



//+------------------------------------------------------------------+
//| Custom indicator initialization function|
//+------------------------------------------------------------------+
int init()
 {
//---- indicators

  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
  SetIndexBuffer(0, TrendUp);
  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
  SetIndexBuffer(1, TrendDown);

  /*SetIndexStyle(0, DRAW_ARROW, EMPTY);
  SetIndexArrow(0, 159);
  SetIndexBuffer(0, TrendUp);
  SetIndexStyle(1, DRAW_ARROW, EMPTY);
  SetIndexArrow(1, 159);
  SetIndexBuffer(1, TrendDown);*/

  /*for(int i = 0; i < Bars; i++) {
     TrendUp[i] = NULL;
     TrendDown[i] = NULL;
  }*/
//----
  return(0);
 }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function|
//+------------------------------------------------------------------+
int deinit()
 {
//----
  /*for(int i = 0; i < Bars; i++) {
     TrendUp[i] = NULL;
     TrendDown[i] = NULL;
  }*/
//----
  return(0);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function|
//+------------------------------------------------------------------+
int start()
 {

  int limit, i, counter;
  double Range, AvgRange, cciTrendNow, cciTrendPrevious, var;

  int counted_bars = IndicatorCounted();
//---- check for possible errors
  if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
  if(counted_bars > 0) counted_bars--;

  limit=Bars-counted_bars;

  for(i = limit; i >= 0; i--) {
     cciTrendNow = iCCI(NULL, 0, 50, PRICE_TYPICAL, i);
     cciTrendPrevious = iCCI(NULL, 0, 50, PRICE_TYPICAL, i+1);

     //st = st * 100;


     counter = i;
     Range = 0;
     AvgRange = 0;
     for (counter = i; counter >= i-9; counter--) {
        AvgRange = AvgRange + MathAbs(High[counter]-Low[counter]);
     }
     Range = AvgRange/10;
     if (cciTrendNow >= st && cciTrendPrevious < st) {
        TrendUp[i+1] = TrendDown[i+1];
     }

     if (cciTrendNow <= st && cciTrendPrevious > st) {
        TrendDown[i+1] = TrendUp[i+1];
     }

     if (cciTrendNow >= st) {
        TrendUp[i] = Low[i] - iATR(NULL, 0, 5, i);
        if (TrendUp[i] < TrendUp[i+1]) {
           TrendUp[i] = TrendUp[i+1];
        }
     }
     else if (cciTrendNow <= st) {
        TrendDown[i] = High[i] + iATR(NULL, 0, 5, i);
        if (TrendDown[i] > TrendDown[i+1]) {
           TrendDown[i] = TrendDown[i+1];
        }
     }
  }

//----

//----
  return(0);
 }

//+------------------------------------------------------------------+