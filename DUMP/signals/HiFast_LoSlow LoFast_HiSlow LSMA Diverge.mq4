//+-------------------------------------------------------------------------+
//|                            HiFast_LoSlow LoFast_HiSlow LSMA Diverge.mq4 |
//|http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/ |
//+-------------------------------------------------------------------------+
#property copyright "Open Source , Not For Sale"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

//Thank You , FX Sniper , Robert Hill , MojoFx and whoever it was that originally posted the 21/34 Trend ID settings .

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Coral
#property indicator_color2 White
//---- input parameters

extern int HiFast = 12;
extern int LoSlow = 36;
extern int LoFast = 12;
extern int HiSlow = 36;
extern int BarsToCalculate = 15000;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,233);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(1,0.0);
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
   int    i,counted_bars=IndicatorCounted();
//---- 
   for (i=counted_bars; i>=0; i--)
      {
      
      double dayhighest = High[Highest(NULL, 0, MODE_HIGH, 24, i)];
      double daylowest  = Low[Lowest(NULL, 0, MODE_LOW, 24, i)];
      double spread = (Ask-Bid);
      double HiF    = iCustom(Symbol(),0,"LSMA_AppliedPrice",HiFast, BarsToCalculate, 2,0,i+1);
      double LoS    = iCustom(Symbol(),0,"LSMA_AppliedPrice",LoSlow, BarsToCalculate, 3,0,i+1);
      double LoF    = iCustom(Symbol(),0,"LSMA_AppliedPrice",LoFast, BarsToCalculate, 3,0,i+1);
      double HiS    = iCustom(Symbol(),0,"LSMA_AppliedPrice",HiSlow, BarsToCalculate, 2,0,i+1);
      
      if ((HiF < LoS) && (High[i] >= dayhighest))
         ExtMapBuffer1[i]=High[i]+(spread*3);
      
      if ((LoF > HiS) && (Low[i] <= daylowest))
         ExtMapBuffer2[i]=Low[i]-(spread*3);
      
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+