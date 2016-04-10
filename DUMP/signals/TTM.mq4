//+------------------------------------------------------------------+
//|                                                          TTM.mq4 |
//|                             Copyright © 2005, adoleh2000 and dwt5|
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//| Based on code offered at MT Yahoo group                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, adoleh2000"
#property link      "adoleh2000@yahoo.com"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 EMPTY
#property indicator_color4 EMPTY



//---- input parameters
extern int TTMperiod=6;
//---- buffers
double HighBuffer[];
double LowBuffer[];
double  Low_ma,
	     High_ma,
	     Low_third[],
	     High_third[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);

 
   SetIndexBuffer(0,HighBuffer);
   SetIndexBuffer(1,LowBuffer);
   SetIndexBuffer(2,High_third);
   SetIndexBuffer(3,Low_third);


//---- name for DataWindow and indicator subwindow label
   short_name="TTM";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

//----
   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   SetIndexDrawBegin(2,10);
   SetIndexDrawBegin(3,10);

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
if (counted_bars==0) counted_bars=TTMperiod+1;
i=(Bars-counted_bars);

for (shift=i; shift>=0;shift--)
{

Low_ma= iMA(NULL,0,TTMperiod,0,MODE_EMA,PRICE_LOW,shift);
High_ma = iMA(NULL,0,TTMperiod,0,MODE_EMA,PRICE_HIGH,shift);
Low_third[shift] = (High_ma- Low_ma) / 3 + Low_ma;
High_third[shift] = 2 * (High_ma- Low_ma) / 3 + Low_ma;

//Comment ("Low_third=",Low_third[shift],"; ","High_third=",High_third[shift]);

if (Close[shift] > High_third[shift]) 
   { 
      HighBuffer[shift]=High[shift];
      LowBuffer[shift]=Low[shift]; 
   }
   
   else

if (Close[shift] < Low_third[shift]) 
   { 
      LowBuffer[shift]=High[shift];
      HighBuffer[shift]=Low[shift];
    }


 //----
}
   return(0);
  }
//+------------------------------------------------------------------+

