//+------------------------------------------------------------------+
//|                                                   Supertrend.mq4 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). |
//|                                      http://www.jnrtrading.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)."
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red


double TrendUp[];
double TrendDown[];
int st = 0;
//extern int SlowerEMA = 6;

extern bool Enable_AudibleAlert = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(0, TrendUp);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(1, TrendDown);
   
   /*SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 159);
   SetIndexBuffer(0, TrendUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 159);
   SetIndexBuffer(1, TrendDown);*/
   
   /*for(int i = 0; i < Bars; i++) {
      TrendUp[i] = NULL;
      TrendDown[i] = NULL;
   }*/
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   /*for(int i = 0; i < Bars; i++) {
      TrendUp[i] = NULL;
      TrendDown[i] = NULL;
   }*/
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| This fucntion will make audible alert when condition has met                      |
//+------------------------------------------------------------------+
void AudibleAlert(bool condition)
{
   int iCurrent = 0;
   static int iLast = 0;
   static bool first_time = true;
     
   
   if(condition==true)  
      iCurrent = 1; 
   else
      iCurrent = 2; 
   
   if(first_time == true) 
   {
      iLast = iCurrent; //is it first run?
      first_time = false;
   }
   
   if(iCurrent != iLast) 
   {
      string sDirection="";
      if(iCurrent==1) sDirection = "TrendUp";
      if(iCurrent==2) sDirection = "TrendDown";
      string sMsg = "Supertrend on ("+ Symbol() + ") has changed (" + sDirection + ")!";
      Alert(sMsg);
      iLast = iCurrent;
   }
   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   
   int limit, i, counter;
   double Range, AvgRange, cciTrendNow, cciTrendPrevious, var;

   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) counted_bars--;
   

   limit=Bars-counted_bars;
   
     
   for(i = limit; i >= 0; i--) {
      cciTrendNow = iCCI(NULL, 0, 50, PRICE_TYPICAL, i);
      cciTrendPrevious = iCCI(NULL, 0, 50, PRICE_TYPICAL, i+1);
      
      //st = st * 100;
      
      
      counter = i;
      Range = 0;
      AvgRange = 0;
      for (counter = i; counter >= i-9; counter--) {
         AvgRange = AvgRange + MathAbs(High[counter]-Low[counter]);
      }
      Range = AvgRange/10;
      if (cciTrendNow >= st && cciTrendPrevious < st) {
         TrendUp[i+1] = TrendDown[i+1];
      }
      
      if (cciTrendNow <= st && cciTrendPrevious > st) {
         TrendDown[i+1] = TrendUp[i+1];
      }
      
      if (cciTrendNow >= st) {
         TrendUp[i] = Low[i] - iATR(NULL, 0, 5, i);         
         if (TrendUp[i] < TrendUp[i+1]) {
            TrendUp[i] = TrendUp[i+1];
         }
      }
      else if (cciTrendNow <= st) {
         TrendDown[i] = High[i] + iATR(NULL, 0, 5, i);
         if (TrendDown[i] > TrendDown[i+1]) {
            TrendDown[i] = TrendDown[i+1];
         }
      }
   }
   
   
   //---- code added by coders guru 
   //---- Alerts on color changing
   if(Enable_AudibleAlert)
   AudibleAlert(cciTrendNow >= st);
        
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+