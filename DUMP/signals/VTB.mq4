//+------------------------------------------------------------------+
//|                                                        V-T&B.mq4 |
//|                         Copyright © 2005, Don Lawson (don_forex) |
//+------------------------------------------------------------------+

   
#property copyright "Copyright © 2005, Don Lawson (don_forex)"
#property link      "d_n_d_enterprises@sbcglobal.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double VTop[];
double VBottom[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, VTop);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, VBottom);
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
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      bool  HiClose = false,
            HiOpen  = false,
            HiWick  = false,
            LoWick  = false;
            
      if (Open[0]<Close[0])
         HiClose = true;
      else 
         HiOpen = true;
      
      if (HiClose){
         if ((High[0]-Close[0])>(Close[0]-Open[0]) && (High[0]-Close[0])>(Open[0]-Low[0]))
            HiWick = true;
      }
      if (HiOpen){
         if ((High[0]-Open[0])>(Open[0]-Close[0]) && (High[0]-Open[0])>(Close[0]-Low[0]))
            HiWick = true;
      }
      if (HiClose){
         if ((Open[0]-Low[0])>(Close[0]-Open[0]) && (Open[0]-Low[0])>(High[0]-Close[0]))
            LoWick = true;
      }
      if (HiOpen){
         if ((Close[0]-Low[0])>(Open[0]-Close[0]) && (Close[0]-Low[0])>(High[0]-Open[0]))
            LoWick = true;
      }
      
      
            
      if (HiWick) {
         VTop[i] = Low[i] - Range*0.5;
      }
      else if (LoWick) {
         VBottom[i] = High[i] + Range*0.5;
      }
   }
   return(0);
}

