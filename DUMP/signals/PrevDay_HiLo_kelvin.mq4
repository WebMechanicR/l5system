/*+------------------------------------------------------------------+
 | FileName: i_DCG_Camarilla.mq4
 | Author: Copyright © 2005, Fermin Da Costa Gomez
 | Version : 01 (Inital code)
 | 
 +------------------------------------------------------------------+*/
#property copyright "Copyright © 2005, Fermin Da Costa Gomez"
#property link      "http://forex.viahetweb.nl"

#property indicator_chart_window
#property indicator_buffers 3

#property indicator_color1 Aqua
#property indicator_color2 Aqua
#property indicator_color3 Red

//---- input parameters

//---- buffers

double PrevDayHiBuffer[];
double PrevDayLoBuffer[];
double PrevDayOpenBuffer[];

int fontsize=10;
double PrevDayHi, PrevDayLo, PrevDayOpen;
double LastHigh,LastLow,x;



//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here

   
   ObjectDelete("PrevDayHi");
   ObjectDelete("PrevDayLo"); 
   ObjectDelete("PrevDayOpen");    
//
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;


//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   
  
   SetIndexBuffer(0, PrevDayHiBuffer);
   SetIndexBuffer(1, PrevDayLoBuffer);
   SetIndexBuffer(2, PrevDayOpenBuffer);
   


//---- name for DataWindow and indicator subwindow label
   short_name="Prev Hi-Lo levels";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);

//----
   SetIndexDrawBegin(0,1);
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

   int limit, i;
//---- indicator calculation
if (counted_bars==0)
{
   x=Period();
   if (x>240) return(-1);
   ObjectCreate("PrevDayHi", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("PrevDayHi", "                Prev. Day High",fontsize,"Arial", Aqua);
   ObjectCreate("PrevDayLo", OBJ_TEXT, 0, 0, 0);   
   ObjectSetText("PrevDayLo", "                Prev. Day Low",fontsize,"Arial", Aqua); 
ObjectCreate("PrevDayOpen", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("PrevDayOpen", "                Prev. Day Open",fontsize,"Arial", Red);
   //---- last counted bar will be recounted
//   if(counted_bars>0) counted_bars--;
} 
  limit=(Bars-counted_bars)-1;



for (i=limit; i>=0;i--)
{ 

if (High[i+1]>LastHigh) LastHigh=High[i+1];
if (Low[i+1]<LastLow) LastLow=Low[i+1];
//Print("TimeDay(Time[i]=",TimeDay(Time[i]),"TimeDay(Time[i+1])",TimeDay(Time[i+1]));
if (TimeDay(Time[i])!=TimeDay(Time[i+1]))
   { 
   PrevDayHi=LastHigh;
PrevDayLo=LastLow;
PrevDayOpen=Open[i];
   LastLow=Open[i];
   LastHigh=Open[i];

  
   ObjectMove("PrevDayHi", 0, Time[i], PrevDayHi);
   ObjectMove("PrevDayLo", 0, Time[i], PrevDayLo);
    ObjectMove("PrevDayOpen", 0, Time[i], PrevDayOpen);

   }
   
    PrevDayHiBuffer[i]=PrevDayHi;
    PrevDayLoBuffer[i]=PrevDayLo;
    PrevDayOpenBuffer[i]=PrevDayOpen;
}

//----
   return(0);
  }
//+------------------------------------------------------------------+