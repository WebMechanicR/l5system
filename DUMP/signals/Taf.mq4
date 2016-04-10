//+------------------------------------------------------------------+
//|                                                          Taf.mq4 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+------------------------------------------------------------------+
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Yellow

//---- input parameters
extern int BQUALIFY=2;
//---- buffers
double HighBuffer[];
double LowBuffer[];
double VALUE1,VALUE2,VALUE3,VALUE4,VALUE5,VALUE6;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_SECTION,EMPTY,1,Aqua);
   SetIndexStyle(1,DRAW_SECTION,EMPTY,1,Yellow);

   SetIndexBuffer(0,HighBuffer);
   SetIndexBuffer(1,LowBuffer);

   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);

//---- name for DataWindow and indicator subwindow label
   short_name="Taf";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

//----
   SetIndexDrawBegin(0,100);
   SetIndexDrawBegin(1,100);
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
   int    counted_bars=IndicatorCounted(),i,shift;

//---- TODO: add your code here
i=(Bars-counted_bars)-1;

for (shift=i; shift>=0;shift--)
{
LowBuffer[shift]=0;
HighBuffer[shift]=0;
if (High[shift]>=High[shift+1] && Low[shift]>=Low[shift+1])
   {
      if ( VALUE2 >= BQUALIFY ) LowBuffer[shift]=Low[shift+1];
      if ( VALUE2 > 0 ) VALUE5=Low[shift+1];
      VALUE1 = VALUE1+1;
      VALUE3 = VALUE1;
      VALUE2 = 0;
   }

if (Low[shift]<=Low[shift+1] && High[shift]<=High[shift+1])
   {
      if ( VALUE1 >= BQUALIFY ) HighBuffer[shift]=High[shift+1];
      if ( VALUE1 > 0 ) VALUE6=High[shift+1];
      VALUE2 = VALUE2+1;
      VALUE4 = VALUE2;
      VALUE1 = 0;
   }
//----
}
   return(0);
  }
//+------------------------------------------------------------------+

