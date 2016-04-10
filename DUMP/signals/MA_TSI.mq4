//+-------------------------------------------------------------------------+
//|MA_TSI.mq4                                                               |
//|http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//+-------------------------------------------------------------------------+
#property copyright "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Coral
#property indicator_color2 White
//---- input parameters
extern int FastMAPeriod=6;
extern int SlowMAPeriod=18;
extern int First_R=4;
extern int Second_S=4;
extern int SignalPeriod=4;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,233);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
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
   int    counted_bars=IndicatorCounted();
   int    i;
//---- 
   for (i=Bars-50; i>=0; i--)
      {
      
      double ask    = (MathRound(Ask/Point))*Point;
      double bid    = (MathRound(Bid/Point))*Point;
      double spread = (ask-bid);
      double one    = iMA(Symbol(),0,FastMAPeriod,0,MODE_EMA,PRICE_HIGH,i);
      double two    = iMA(Symbol(),0,FastMAPeriod,0,MODE_EMA,PRICE_LOW,i);
      double three  = iMA(Symbol(),0,SlowMAPeriod,0,MODE_EMA,PRICE_HIGH,i);
      double four   = iMA(Symbol(),0,SlowMAPeriod,0,MODE_EMA,PRICE_LOW,i);
      double LBB0   = iCustom(Symbol(),0,"TSI-Osc",First_R,Second_S,SignalPeriod,1,0,i);
      double LBB1   = iCustom(Symbol(),0,"TSI-Osc",First_R,Second_S,SignalPeriod,1,0,i+1);
      
  if (
      ((one < three) && (two < four)) &&
      ((LBB1 > 50.0000 && LBB0 < 50.0000) ||
       (LBB1 > 0.0000 && LBB0 < 0.0000) ||
       (LBB1 > -50.0000 && LBB0 < -50.0000))
     )
     
     ExtMapBuffer1[i]=High[i]+(spread*2);
      
  if (
      ((one > three) && (two > four)) &&
      ((LBB1 < -50.0000 && LBB0 > -50.0000) ||
       (LBB1 < -0.0000 && LBB0 > -0.0000) ||
       (LBB1 < 50.0000 && LBB0 > 50.0000))
     )
     ExtMapBuffer2[i]=Low[i]-(spread*2);

  }
//----
   return(0);
  }
//+------------------------------------------------------------------+