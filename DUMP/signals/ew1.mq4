#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                             .mq4 |
//|                                                                  |
//|                                                                  |
//|                                        Converted by Mql2Mq4 v0.7 |
//|                                            http://yousky.free.fr |
//|                                    Copyright © 2006, Yousky Soft |
//+------------------------------------------------------------------+

//#property copyright " CONVERT BY "ENG.AED AL NAIRAB" ."
#property link      " http://www.nairab.com/"

#property indicator_separate_window
#property indicator_color1 Blue
#property indicator_buffers 1

//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double triger = 0.70;
extern double back_test = 20;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+

int LastTradeTime;
double ExtHistoBuffer[];

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
}

//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   return(0);
}
int start()
{
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
int shift = 0;
int i = 0;
double llv = 0;
double hhv = 0;
double taiv = 0;
double trend = 0;

/*[[
	Name := ew1
	Author := CONVERT BY "ENG.AED AL NAIRAB" .
	Link := http://www.nairab.com/
	Separate Window := yes
	First Color := Blue
	First Draw Type := Line
	First Symbol := 217
	Use Second Data := no
	Second Color := Red
	Second Draw Type := Line
	Second Symbol := 218
]]*/



SetLoopCount(0);
// loop from first bar to current bar (with shift=0)
for(shift=900;shift>=0 ;shift--){ 
llv=iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, shift)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, shift);
hhv=iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, shift)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, shift);
for(i=shift;i<=shift+back_test ;i++){ 
llv=MathMin(iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, i)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, i),llv);
hhv=MathMax(iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, i)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, i),hhv);
} 
if( ( hhv == (iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, shift)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, shift))&& trend == 0)) trend=1;
if( ( llv == (iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, shift)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, shift))&& trend == 0)) trend=-1;
if( ( llv<0 && trend == -1 && (iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, shift)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, shift))>-1*triger*llv)) trend=1;
if( ( hhv>0 && trend == 1 && (iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_MEDIAN, shift)-iMA(NULL, 0, 35, 0, MODE_SMA, PRICE_MEDIAN, shift))<-1*triger*hhv)) trend=-1;
	SetIndexValue(shift, trend);

} 

  return(0);
}