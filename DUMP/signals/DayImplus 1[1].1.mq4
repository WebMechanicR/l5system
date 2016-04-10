//+------------------------------------------------------------------+
//| DayImplus 1.1.mq4                                                |
//|                                                                  |
//| Updated by DriverDan                                             |
//|                                                                  |
//| Versions:                                                        |
//|   1.1 Released by DriverDan                                      |
//|       Fix horrible style, removed extra buffer, changed to draw  |
//|       from the beginning, added MA, and fixed gaps in signal.    |
//|                                                                  |
//|   1.0 Original Release                                           |
//+------------------------------------------------------------------+

#property link "http://www.arkworldmarket.ru/forum/showthread.php?t=966&page=2&pp=10"
   
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Gold
#property indicator_color2  White

extern int per       = 14;  // Period for signal
extern int drawShift = 14;  // Forward shift
extern int useMA     = 1;   // 1 = use MA
extern int maPeriod  = 34;  // Moving average period

double ExtMapBuffer[];
double maBuffer[];
   
int init() {
   string title = "DayImplus(" + per + ")";
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ExtMapBuffer);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, maBuffer);
   SetIndexShift(0, drawShift);
   SetIndexShift(1, drawShift);
   SetIndexLabel(0, "Signal(" + per + ")");
   SetIndexLabel(1, "MA(" + maPeriod + ")");
   
   if(useMA == 1) {
      title = title + " MA(" + maPeriod + ")";
   }
   
   IndicatorShortName(title);
   return(0);
}

int start() {
   int    counted_bars = IndicatorCounted();
   int    shift, i;
   double imp;

   //for shift=mBar down to per 
   for(shift = Bars - counted_bars - 1; shift >= 0; shift--) {
      imp = 0;

      for(i = shift; i >= shift - per; i--) {
         imp = imp + (Open[i] - Close[i]);
      }

      imp = MathRound(imp / Point);

      if(imp != 0) {
         imp =- imp;
      }
      ExtMapBuffer[shift] = imp;
   }
   
   if(useMA == 1) {
      for(shift = Bars - counted_bars - 1; shift >= 0; shift--) {
         if(shift < Bars - maPeriod && shift < Bars - per) {
            maBuffer[shift] = iMAOnArray(ExtMapBuffer, 0, maPeriod, 0, MODE_SMA, shift);
         }
      }
   }
   
   return(0);
}

