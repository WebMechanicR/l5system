//+------------------------------------------------------------------+
//|                                                   ATR Levels.mq4 |
//|                                                    Mike Ischenko |
//|                                            mishanya_fx@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Mike Ischenko"
#property link      "mishanya_fx@yahoo.com"

#property indicator_chart_window



extern int ATRPeriod = 10;

double rates_d1[][6];
double H1, H2, H3, H4, H4t, H5, L5, L4, L4t, L3, L2, L1, halfatr, fullatr;
int timeshift=0, timeshifts=0, beginner=0;
int periods;

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
//---- TODO: add your code here
 
   
   ObjectDelete("H4atr line");
   ObjectDelete("L4atr line");
   ObjectDelete("L4atr label");
   ObjectDelete("H4atr label");
   ObjectDelete("H4tatr line");
   ObjectDelete("L4tatr line");
   ObjectDelete("L4tatr label");
   ObjectDelete("H4tatr label");   
   
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   //if (counted_bars<1) return(0);
   
   
   switch (Period())
   {
      case PERIOD_M1:  {timeshifts=60; beginner=Hour()*60;} break;
      case PERIOD_M5:  {timeshifts=300; beginner=Hour()*12;} break;
      case PERIOD_M15: {timeshifts=900; beginner=Hour()*4;} break;
      case PERIOD_M30: {timeshifts=1800; beginner=Hour()*2;} break;
      case PERIOD_H1:  {timeshifts=3600; beginner=Hour()*1;} break;
      case PERIOD_H4:  {timeshifts=14400; beginner=Hour()*0.25;} break;
      case PERIOD_D1:  {timeshifts=86400; beginner=Hour()*0;} break;
    }   

   timeshift=timeshifts*24;
   
   if(Period() > 86400)
      {
         Print("Error - Chart period is greater than 1 day.");
         return(-1); // then exit
      }   


   
   ArrayCopyRates(rates_d1, Symbol(), PERIOD_D1);



   //beginner=Hour();
   
            fullatr = iATR(Symbol(), PERIOD_D1, ATRPeriod, 1);
            
            L4 = rates_d1[1][3] - fullatr;   
            H4 = rates_d1[1][2] + fullatr;
            L4t = rates_d1[0][3] - fullatr;   
            H4t = rates_d1[0][2] + fullatr;
            halfatr = fullatr * 0.5;   
         
            H1 = H4+1.5*fullatr;
            H2 = H4+fullatr;
            H3 = H4+halfatr;
            L3 = L4-halfatr;
            L2 = L4-fullatr;
            L1 = L4-1.5*fullatr;
         
   
   
   if (ObjectFind("H4atr Line") != 0) 
     {
      ObjectCreate("H4atr line",OBJ_HLINE,0,Time[0],H4);
      ObjectSet("H4atr line",OBJPROP_COLOR,Yellow);
      ObjectSet("H4atr line",OBJPROP_WIDTH,1);
     }
     else
     {
     ObjectMove("H4atr line", 0,Time[0],H4);
     }


   if (ObjectFind("L4atr Line") != 0) 
     {
      ObjectCreate("L4atr line",OBJ_HLINE,0,Time[0],L4);
      ObjectSet("L4atr line",OBJPROP_COLOR,Yellow);
      ObjectSet("L4atr line",OBJPROP_WIDTH,1);
     }
     else
     {
     ObjectMove("L4atr line", 0,Time[0],L4);
     }

   if (ObjectFind("H4tatr Line") != 0) 
     {
      ObjectCreate("H4tatr line",OBJ_HLINE,0,Time[0],H4t);
      ObjectSet("H4tatr line",OBJPROP_COLOR,Yellow);
      ObjectSet("H4tatr line",OBJPROP_WIDTH,1);
     }
     else
     {
     ObjectMove("H4tatr line", 0,Time[0],H4t);
     }


   if (ObjectFind("L4tatr Line") != 0) 
     {
      ObjectCreate("L4tatr line",OBJ_HLINE,0,Time[0],L4t);
      ObjectSet("L4tatr line",OBJPROP_COLOR,Yellow);
      ObjectSet("L4tatr line",OBJPROP_WIDTH,1);
     }
     else
     {
     ObjectMove("L4tatr line", 0,Time[0],L4t);
     }

if(ObjectFind("H4atr label") != 0)
      {
      ObjectCreate("H4atr label", OBJ_TEXT, 0, Time[0]+timeshift, H4);
      ObjectSetText("H4atr label", "ATR(y) res: " + DoubleToStr(H4,4), 8, "Verdana", Yellow);
      }
      else
      {
      ObjectMove("H4atr label", 0, Time[0]+timeshift, H4);
      } 

if(ObjectFind("L4atr label") != 0)
      {
      ObjectCreate("L4atr label", OBJ_TEXT, 0, Time[0]+timeshift, L4);
      ObjectSetText("L4atr label", "ATR(y) sup: " + DoubleToStr(L4,4), 8, "Verdana", Yellow);
      }
      else
      {
      ObjectMove("L4atr label", 0, Time[0]+timeshift, L4);
      } 

if(ObjectFind("H4tatr label") != 0)
      {
      ObjectCreate("H4tatr label", OBJ_TEXT, 0, Time[0]+timeshift, H4t);
      ObjectSetText("H4tatr label", "ATR(t) res: " + DoubleToStr(H4t,4), 8, "Verdana", Yellow);
      }
      else
      {
      ObjectMove("H4tatr label", 0, Time[0]+timeshift, H4t);
      } 

if(ObjectFind("L4tatr label") != 0)
      {
      ObjectCreate("L4tatr label", OBJ_TEXT, 0, Time[0]+timeshift, L4t);
      ObjectSetText("L4tatr label", "ATR(t) sup: " + DoubleToStr(L4t,4), 8, "Verdana", Yellow);
      }
      else
      {
      ObjectMove("L4tatr label", 0, Time[0]+timeshift, L4t);
      } 

   return(0);
  }
//+------------------------------------------------------------------+