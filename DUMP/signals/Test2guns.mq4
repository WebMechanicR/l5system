//+------------------------------------------------------------------+
//|                                                         Test.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Rosh"
#property link      "http://forexsystems.ru/phpBB/"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow
//---- input parameters
extern int       PeriodMin=1440;
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
   SetIndexLabel(0,"MRO1");
   SetIndexLabel(1,"MRO2");
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
   int bigshift;
   int shift;
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here
   for (shift=Bars;shift>=0;shift--)
      {
      bigshift=MathFloor(shift*Period()/PeriodMin);
//      ExtMapBuffer1[shift]=iCustom(NULL,PeriodMin,"GATO",22,300,120,50,6,0,bigshift);
      ExtMapBuffer1[shift]=iCustom(NULL,PeriodMin,"MRO1",10,0,bigshift);
      ExtMapBuffer2[shift]=iCustom(NULL,PeriodMin,"MRO2",7,0,bigshift);
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+