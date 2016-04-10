//+------------------------------------------------------------------+
//| 10 Minute trader                                                 |
//+------------------------------------------------------------------+
#property copyright "Ron T"
#property link      "http://www.lightpatch.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 White
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Green

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];


// User Input


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {

   // 233 up arrow
   // 234 down arrow
   // 159 open square
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexArrow(0,159);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexArrow(1,159);

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexArrow(2,159);

   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3, ExtMapBuffer4);
   SetIndexArrow(3,159);

   return(0);
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   
   for( i=0; i<Bars; i++ ) ExtMapBuffer1[i]=0;
   for( i=0; i<Bars; i++ ) ExtMapBuffer2[i]=0;
   for( i=0; i<Bars; i++ ) ExtMapBuffer3[i]=0;
   for( i=0; i<Bars; i++ ) ExtMapBuffer4[i]=0;

   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double    wma=0,    wma_p=0;  // linear Weighted Moving Average (and _Previous)
   double    sma=0,    sma_p=0;  // Simple Moving Average (and _Previous)
   double stochm=0;              // STOCHastic Main
   double stochs=0;              // STOCHastic Signal
   double  macdm=0;              // Moving Average Convergance Divergance Main
   double  macds=0;              // Moving Average Convergance Divergance Signal
   double    rsi=0;              // Relative Strength Indicator
     
   int pos=Bars-100;             // leave room for moving average periods
      
   while(pos>=0)
     {
     
      wma_p=wma; // save previous calculations
      wma=iMA(Symbol(),0,10,0,MODE_LWMA,PRICE_CLOSE,pos);

      sma_p=sma; // save previous calculations
      sma=iMA(Symbol(),0,20,0,MODE_SMA,PRICE_CLOSE,pos);
      
      // Cannot plot these since they are 0-100
      // and chart is likely autoranging to 1.2000
      stochm=iStochastic(Symbol(),0,10,6,6,0,1,0,pos);
      stochs=iStochastic(Symbol(),0,10,6,6,0,1,1,pos);

      rsi=iRSI(Symbol(),0,28,PRICE_CLOSE,pos);
      
      macdm=iMACD(Symbol(),0,24,52,18,0,0,pos);
      macds=iMACD(Symbol(),0,24,52,18,0,1,pos);
      
      if ( wma_p < sma_p && wma > sma )
        {
         ExtMapBuffer1[pos]=wma;
        }

      if ( wma_p > sma_p && wma < sma )
        {
         ExtMapBuffer1[pos]=wma;
        }

 	   pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+