//+------------------------------------------------------------------+
//|                                                    TimeZones.mq4 |
//|                       Copyright © 2004, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.net |
//|                                Made/Modified by Alejandro Galindo |
//|                                                                   |
//|                                                                   |
//|                       if this work/modification is helpful to you |
//|                      send me a PayPal donation to ag@elcactus.com |
//|                                         any help is apreciated :) |
//|                                                           Thanks. |
//+-------------------------------------------------------------------+
#property copyright "Copyright © 2005. Alejandro Galindo"
#property link      "http://elCactus.com"

#property indicator_chart_window

extern int EST=7;
extern int MST=6;
extern int GMT=2;
extern int CountBars=500;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   int shift=0;
   for  (shift=Bars-1;shift>=0;shift--) {
   ObjectDelete("EST"+shift);
   ObjectDelete("MST"+shift);
   ObjectDelete("GMT"+shift);
   ObjectDelete("Broker"+shift);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int shift, NumBars=500;
   double CloseTime,OpenTime;
   
   if (Bars<CountBars)  { NumBars=Bars-1; } else { NumBars=CountBars; }

   for  (shift=Bars-1;shift>=0;shift--) {
 
//      OpenTime=StrToTime(TimeDay(Time[shift])+" "+EST+":"+OpenTimeMin);
//      CloseTime=StrToTime(TimeDay(Time[shift])+" "+MST+":"+CloseTimeMin);	 
	  
	  
	  if (TimeHour(Time[shift])== EST && TimeMinute(Time[shift])==0) {
	     if(ObjectFind("EST"+shift) != 0)
         {            
            ObjectCreate("EST"+shift, OBJ_VLINE, 0, Time[shift], 0);
            ObjectSet("EST"+shift, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            ObjectSet("EST"+shift, OBJPROP_COLOR, Blue);
         }           
      }
      
     	  if (TimeHour(Time[shift])== MST && TimeMinute(Time[shift])==0) {
	     if(ObjectFind("MST"+shift) != 0)
         {            
            ObjectCreate("MST"+shift, OBJ_VLINE, 0, Time[shift], 0);
            ObjectSet("MST"+shift, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            ObjectSet("MST"+shift, OBJPROP_COLOR, Red);
         }           
      }  
      
      if (TimeHour(Time[shift])== GMT && TimeMinute(Time[shift])==0) {
	     if(ObjectFind("GMT"+shift) != 0)
         {            
            ObjectCreate("GMT"+shift, OBJ_VLINE, 0, Time[shift], 0);
            ObjectSet("GMT"+shift, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            ObjectSet("GMT"+shift, OBJPROP_COLOR, Yellow);
         }           
      }  
      
      if (TimeHour(Time[shift])== 0 && TimeMinute(Time[shift])==0) {
	     if(ObjectFind("Broker"+shift) != 0)
         {            
            ObjectCreate("Broker"+shift, OBJ_VLINE, 0, Time[shift], 0);
            ObjectSet("Broker"+shift, OBJPROP_STYLE, STYLE_DASHDOTDOT);
            ObjectSet("Broker"+shift, OBJPROP_COLOR, White);
         }           
      }  

   }


   return(0);
  }
//+------------------------------------------------------------------+