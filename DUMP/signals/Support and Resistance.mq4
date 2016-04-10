//+------------------------------------------------------------------+
//|                                      Support and Resistance .mq4 |
//|                                                                  |
//|                                                                  |
//|                                    Conversion: Dr_Richard_Gaines |
//|                                      dr_richard_gaines@yahoo.com |
//+------------------------------------------------------------------+

#property copyright " Copyright © 2004, MetaQuotes Software Corp."
#property link      " http://www.metaquotes.net/"
#include <stdlib.mqh>
#property indicator_chart_window
#property indicator_color1 Blue
#property indicator_buffers 2
#property indicator_color2 Red

//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+

int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
}

void SetIndexValue2(int shift, double value)
{
  ExtHistoBuffer2[shift] = value;
}

bool MoveObject(string name, int type, datetime Atime, double Aprice, datetime Atime2 = 0, double Aprice2 = 0, color Acolor = CLR_NONE, int Aweight = 0, int Astyle = 0)
{
    if (ObjectFind(name) != -1)
    {
      int OType = ObjectType(name);

      if ((OType == OBJ_VLINE) ||
         (OType == OBJ_HLINE) ||
         (OType == OBJ_TRENDBYANGLE) ||
         (OType == OBJ_TEXT) ||
         (OType == OBJ_ARROW) ||
         (OType == OBJ_LABEL))
      {
        return(ObjectMove(name, 0, Atime, Aprice));
      }

      if ((OType == OBJ_GANNLINE) ||
         (OType == OBJ_GANNFAN) ||
         (OType == OBJ_GANNGRID) ||
         (OType == OBJ_FIBO) ||
         (OType == OBJ_FIBOTIMES) ||
         (OType == OBJ_FIBOFAN) ||
         (OType == OBJ_FIBOARC) ||
         (OType == OBJ_RECTANGLE) ||
         (OType == OBJ_ELLIPSE) ||
         (OType == OBJ_CYCLES) ||
         (OType == OBJ_TREND) ||
         (OType == OBJ_STDDEVCHANNEL) ||
         (OType == OBJ_REGRESSION))
      {
        return(ObjectMove(name, 0, Atime, Aprice) && ObjectMove(name, 1, Atime2, Aprice2));
      }

/*
          OBJ_CHANNEL,
          OBJ_EXPANSION,
          OBJ_FIBOCHANNEL,
          OBJ_TRIANGLE,
          OBJ_PITCHFORK
*/
    }
    else
    {
      return(ObjectCreate(name, type, 0, Atime, Aprice, Atime2, Aprice2, 0, 0) && ObjectSet(name, OBJPROP_COLOR, Acolor));
    }
}

//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID);
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID);
   SetIndexBuffer(1, ExtHistoBuffer2);
   return(0);
}
int start()
{
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
int shift = 0;
double res = 0;
double sup = 0;

/*[[
	Name := sup_res
	Author := Copyright © 2004, MetaQuotes Software Corp.
	Link := http://www.metaquotes.net/
	Separate Window := No
	First Color := Blue
	First Draw Type := Symbol
	First Symbol := 119
	Use Second Data := Yes
	Second Color := Red
	Second Draw Type := Symbol
	Second Symbol := 119
]]*/


SetLoopCount(0);
// loop from first bar to current bar (with shift=0)
for(shift=Bars-1;shift>=0 ;shift--){ 
if( Close[shift+2]>= iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, shift+2)&&
 Close[shift+1]< iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, shift+1)) 
res=High[Highest(NULL, 0, MODE_HIGH,shift+20,20)];
if( Close[shift+2]<= iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, shift+2)&&
Close[shift+1]> iMA(NULL, 0, 10, 0, MODE_SMA, PRICE_CLOSE, shift+1)) 
sup=Low[Lowest(NULL, 0, MODE_LOW,shift+20,20)];
	SetIndexValue(shift, res);
	SetIndexValue2(shift, sup);
	if( Close[shift+1]<sup ) 
	MoveObject("trade",OBJ_FIBO,Time[shift+1],sup,Time[shift+1],res,Green,1,STYLE_DASH); else 
if( Close[shift+1]>res ) 
	MoveObject("trade",OBJ_FIBO,Time[shift+1],res,Time[shift+1],sup,Green,1,STYLE_DASH); else 
if( Close[shift+1]<res && Close[shift+1]>sup   ) 
	MoveObject("trade",OBJ_FIBO,Time[shift+1],res,Time[shift+1],sup,Green,1,STYLE_DASH);
} 


  return(0);
}