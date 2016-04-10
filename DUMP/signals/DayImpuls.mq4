/*
 * Filename:    DayImpulse.mq4
   forex-tsd.com
 */

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  Magenta

extern int per    = 14;  // Period for signal
extern int d = 100;   

// Buffers for signals
double drawBuffer[];
   
int init() {
   string title = "DayImplus(" + per + ")";
   
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, drawBuffer);
   
   // Shift everything forward
   //SetIndexShift(0, per);
   
   // Titles for each line
   SetIndexLabel(0, "DayImpuls(" + per + ")");
   
   IndicatorShortName(title);
   return(0);
}

int start() {
   int    shift, i, mBar;
   double imp;

      mBar=d*per;
      for(shift = mBar; shift >= per; shift--) {
         imp = 0;
         for (i=shift; i>=shift-per; i--) {
            imp=imp+(Open[i]-Close[i]);
         }
         imp=MathRound(imp/Point);
         if (imp==0) imp=0.0001;
         if (imp!=0) {
            imp = -imp;
            drawBuffer[shift-per] = imp;
         }
      }
      
   return(0);
}

