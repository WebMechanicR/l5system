// To be used with the ZoneJemputan(TM)
#property copyright "MA plotted as dots"
#property link      "http://darmasdt.com/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 White

//---- input parameters
extern int panjang= 3;



//---- buffers
double titik[];

//---- variables

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   //IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   //---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,158);
   SetIndexBuffer(0,titik);
   SetIndexEmptyValue(0,0.0);
  
   IndicatorShortName("Darma:: MA in DOT");
   

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
   int limit;
      
   //int signal = MathRound(signal_day*1440/Period());

   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if (counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   limit = Bars - counted_bars;

   for(int i=limit; i>=0; i--)
   {
      
      double bahan = iMA(NULL,0,panjang,0,MODE_SMA,PRICE_MEDIAN,i);
      titik[i]=bahan;
      
   }
   
   //----
   return(0);
}
//+------------------------------------------------------------------+