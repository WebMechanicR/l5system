//+------------------------------------------------------------------+
//|                                      PrevDayAndFloatingPivot.mq4 |
//|                             Copyright © 2006, mbkennel@gmail.com |
//|                                        http://www.metatrader.org |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, mbkennel@gmail.com"
#property link      "http://www.metatrader.org"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Magenta
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
   
   SetIndexLabel(0,"Previous Day Pivot");
   SetIndexLabel(1,"Floating current pivot"); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }

  
int TodaysBarShift(int shift) {
   // return the bar shift for today. 
   // i.e. not today.
   
   datetime timenow= iTime(NULL,Period(),shift); // shift of current bar on lower TF chart.
   int idaybarshift = iBarShift(NULL,PERIOD_D1,timenow,false); 
   datetime timedaybegin = iTime(NULL,PERIOD_D1,idaybarshift);
   
   if ((timedaybegin) > timenow) idaybarshift++; 
   
   return(idaybarshift);    
}  

int PreviousNonSundayBarShift(int shift) {
   int tbs = TodaysBarShift(shift); 
   int ybs = tbs+1; 
   datetime yesterdaybegin = iTime(NULL,PERIOD_D1,ybs);
   if (TimeDayOfWeek(yesterdaybegin) == 0) ybs++; // we found a Sunday bar so screw it. 
   return(ybs); 
}

void TodaysHighestLowest(double& H, double& L, int shift) {
   // return the higest and lowest so far today.
   datetime now = iTime(NULL,Period(),shift); // time value of bar.
   int tbs = TodaysBarShift(shift);
   datetime daybegin = iTime(NULL,PERIOD_D1,tbs); 
   
   
   H = High[shift];
   L = Low[shift]; 
   int j = shift+1;
   while ( iTime(NULL,Period(),j) >= daybegin) {
      double Ht = High[j];
      double Lt = Low[j];
      H = MathMax(H,Ht);
      L = MathMin(L,Lt);
      j++;
      if ((j-shift) > 24) {
         Print ("Shit!");
         break;
      } 
   }
   return; 
}

  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   int limit = Bars-counted_bars;
   
   for (int i=limit; i >= 0; i--) {
      // Get the prev days pivot. Today's pivot.
      int ybs = PreviousNonSundayBarShift(i); 
      int tdbar = TodaysBarShift(i);
      
      // Prev day's pivot:
      double p = (iHigh(NULL,PERIOD_D1,ybs)+iLow(NULL,PERIOD_D1,ybs)+
         iClose(NULL,PERIOD_D1,ybs) + iOpen(NULL,PERIOD_D1,tdbar))*0.25;
      
      double TH,TL;
      TodaysHighestLowest(TH,TL,i);
      
      double flp = (TH+TL+Close[i])*0.33333;   
      ExtMapBuffer1[i] = p;
      ExtMapBuffer2[i] = flp; 
      // 
   
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+