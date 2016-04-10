//+------------------------------------------------------------------+
//|                                                        time1.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
string t;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
int i;
     i=Bars-1;
     while(i>0)
      {
      t=DoubleToStr(i,0);
      if(TimeMinute(Time[i])==0&&TimeHour(Time[i])==8)
         {
         ObjectCreate(t, OBJ_VLINE, 0, Time[i],0);
         ObjectSet(t, OBJPROP_COLOR,Aqua);
         }
      if(TimeMinute(Time[i])==0&&TimeHour(Time[i])==11)
         {
         ObjectCreate(t, OBJ_VLINE, 0, Time[i],0);
         ObjectSet(t, OBJPROP_COLOR,Blue);
         }
      if(TimeMinute(Time[i])==30&&TimeHour(Time[i])==12)
         {
         ObjectCreate(t, OBJ_VLINE, 0, Time[i], 0);
         ObjectSet(t, OBJPROP_COLOR,Purple);
         }
      if(TimeMinute(Time[i])==0&&TimeHour(Time[i])==14)
         {
         ObjectCreate(t, OBJ_VLINE, 0, Time[i],0);
         ObjectSet(t, OBJPROP_COLOR,Orange);
         }
      if(TimeMinute(Time[i])==0&&TimeHour(Time[i])==17)
         {
         ObjectCreate(t, OBJ_VLINE, 0, Time[i],0);
         ObjectSet(t, OBJPROP_COLOR,Brown);
         }
      i--;
      }
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
//---- 
      t=TimeToStr(CurTime());
      if(TimeMinute(CurTime())==0&&TimeHour(CurTime())==8)
         {
         ObjectCreate(t, OBJ_VLINE, 0, CurTime(),0);
         ObjectSet(t, OBJPROP_COLOR,Aqua);
         }
      if(TimeMinute(CurTime())==0&&TimeHour(CurTime())==11)
         {
         ObjectCreate(t, OBJ_VLINE, 0,CurTime(),0);
         ObjectSet(t, OBJPROP_COLOR,Blue);
         }
      if(TimeMinute(CurTime())==30&&TimeHour(CurTime())==12)
         {
         ObjectCreate(t, OBJ_VLINE, 0,CurTime(), 0);
         ObjectSet(t, OBJPROP_COLOR,Purple);
         }
      if(TimeMinute(CurTime())==0&&TimeHour(CurTime())==14)
         {
         ObjectCreate(t, OBJ_VLINE, 0,CurTime(),0);
         ObjectSet(t, OBJPROP_COLOR,Orange);
         }
      if(TimeMinute(CurTime())==0&&TimeHour(CurTime())==17)
         {
         ObjectCreate(t, OBJ_VLINE, 0,CurTime(),0);
         ObjectSet(t, OBJPROP_COLOR,Brown);
         }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+