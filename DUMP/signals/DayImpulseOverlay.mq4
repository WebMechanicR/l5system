/*
 * Filename:    DayImpulseOverlay.mq4
 * Author:      DriverDan, based on the original by Tartan at the link below
 * Date:        Nov 3, 2005
 *
 * Description: This is Day Impulse overlaid on the main chart. Requires DayImpulse2DD.
 *
 *              Sums the close - open for the past "per" bars and shifts it forward
 *              "drawShift" bars. Sometimes works well at predicting movement.
 *
 *              Signal2 is just the current bar's close - open shifted "drawShift"
 *              periods forward. This is what you see as the main signal draws. It
 *              isn't updated as time moves forward so that you have something to look
 *              back on.
 *
 *              WARNING: Looking at past bars will be deceiving. It may look like it
 *              predicts perfectly on some pairs but remember that it is constantly
 *              updated. The most accurate live bar is the current one.
 *
 *              The future is not set.
 *
 * Version:     2DD
 *              Released by DriverDan
 *              Almost all of the code has been changed or rewritten.
 *              Added Signal2.
 *
 *              1.1
 *              Released by DriverDan
 *              Fix horrible style, removed extra buffer, changed to draw from the
 *              beginning, added MA, and fixed gaps in signal.
 *
 *              1.0
 *              Initial release
 *              http://www.arkworldmarket.ru/forum/showthread.php?t=966&page=2&pp=10
 */

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Magenta

extern int per    = 14;  // Period for signal
extern int update = 1;   // 1 = continuously update, 0 = freeze

// Buffers for signals
double drawBuffer[];
   
int init() {
   string title = "DayImplus(" + per + ")";
   
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexBuffer(0, drawBuffer);
   
   // Shift everything forward
   SetIndexShift(0, per);
   
   // Titles for each line
   SetIndexLabel(0, "Signal(" + per + ")");
   
   IndicatorShortName(title);
   return(0);
}

int start() {
   int    counted_bars = IndicatorCounted();
   int    shift, i, limit, lim;
   double prevSignal = -1, barClose = -1, imp;

   if(update == 1) {
      imp = iCustom(NULL, 0, "DayImpulse2DD", per, 0, 0, 0, 0, 0, per) * Point;

      barClose = Close[0] - iCustom(NULL, 0, "DayImpulse2DD", per, 0, per) * Point;

      // Loop through and calculate the signals. Everytime this runs we recalculate the
      // current and all future signals. The future is not set :)
      for(shift = per - 1; shift >= 0; shift--) {
         imp = iCustom(NULL, 0, "DayImpulse2DD", per, 0, shift) * Point;
         
         drawBuffer[shift] = barClose + imp;
      }
   }
      
   return(0);
}

