//+------------------------------------------------------------------+
//|                                                  Heiken Ashi.mq4 |
//|                      Copyright c 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Blue

//---- buffers
   double
      ExtMapBuffer1[],
      ExtMapBuffer2[],
      ExtMapBuffer3[],
      ExtMapBuffer4[];
      
//---- vars
   int
      ExtCountedBars=0;

int init() {

   //---- indicators
   SetIndexStyle  (0, DRAW_HISTOGRAM, 0, 1, Red);
   SetIndexBuffer (0, ExtMapBuffer1);
   SetIndexLabel  (0, "HA Max / Min");
   SetIndexStyle  (1, DRAW_HISTOGRAM, 0, 1, Blue);
   SetIndexBuffer (1, ExtMapBuffer2);
   SetIndexLabel  (1, "HA Max / Min");
   SetIndexStyle  (2, DRAW_HISTOGRAM, 0, 3, Red);
   SetIndexBuffer (2, ExtMapBuffer3);
   SetIndexLabel  (2, "HA Open");
   SetIndexStyle  (3, DRAW_HISTOGRAM, 0, 3, Blue);
   SetIndexBuffer (3, ExtMapBuffer4);
   SetIndexLabel  (3, "HA Close");
   
   //----
   SetIndexDrawBegin(0, 10);
   SetIndexDrawBegin(1, 10);
   SetIndexDrawBegin(2, 10);
   SetIndexDrawBegin(3, 10);

   //---- indicator buffers mapping
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexBuffer(3, ExtMapBuffer4);
   
   IndicatorDigits(Digits);
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   
   double
      haOpen,
      haHigh,
      haLow,
      haClose;

   int
      pos = Bars - ExtCountedBars - 1;

   if( Bars <= 10 ) {
      return(0);
   }
   ExtCountedBars = IndicatorCounted();
   //---- check for possible errors
   if ( ExtCountedBars < 0 ) {
      return(-1);
   }
   //---- last counted bar will be recounted
   if ( ExtCountedBars > 0 ) {
      ExtCountedBars--;
   }

   while( pos >= 0 ) {
      haOpen   = (ExtMapBuffer3[pos + 1] + ExtMapBuffer4[pos + 1]) / 2;
      haClose  = (Open[pos] + High[pos]  + Low[pos] + Close[pos])  / 4;
      haHigh   = MathMax(High[pos], MathMax(haOpen, haClose));
      haLow    = MathMin(Low[pos],  MathMin(haOpen, haClose));
      if ( haOpen < haClose) {
         ExtMapBuffer1[pos] = haLow;
         ExtMapBuffer2[pos] = haHigh;
      } else {
         ExtMapBuffer1[pos] = haHigh;
         ExtMapBuffer2[pos] = haLow;
      }
      ExtMapBuffer3[pos] = haOpen;
      ExtMapBuffer4[pos] = haClose;
 	   pos--;
   }
   return(0);
}