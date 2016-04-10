//+------------------------------------------------------------------+
//|                                                  TSI Signals.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 MediumBlue
//---- input parameters
extern int       First_R=8;
extern int       Second_S=5;
extern int       SignalPeriod=5;
extern int       Mode_Smooth=1;
extern int       ArrowShift=5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,217);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"UpArrow");
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,218);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"DownArrow");
   SetIndexEmptyValue(1,0.0);
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
   int limit,i;
   double curTSI=0.0,prevTSI=0.0,curSignal=0.0,prevSignal=0.0;
   limit=Bars-counted_bars-First_R-Second_S-SignalPeriod;
   for (i=limit;i>=0;i--)
      {
      curTSI=iCustom(NULL,0,"TSI-Osc",First_R,Second_S,SignalPeriod,Mode_Smooth,0,i);
      prevTSI=iCustom(NULL,0,"TSI-Osc",First_R,Second_S,SignalPeriod,Mode_Smooth,0,i+1);
      curSignal=iCustom(NULL,0,"TSI-Osc",First_R,Second_S,SignalPeriod,Mode_Smooth,1,i);
      prevSignal=iCustom(NULL,0,"TSI-Osc",First_R,Second_S,SignalPeriod,Mode_Smooth,1,i+1);
      if ((curTSI>curSignal)&&(prevTSI<prevSignal)) ExtMapBuffer1[i]=Close[i]+3*ArrowShift*Point;
      if ((curTSI<curSignal)&&(prevTSI>prevSignal)) ExtMapBuffer2[i]=Close[i]-ArrowShift*Point;
      }
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+