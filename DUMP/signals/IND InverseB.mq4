//+------------------------------------------------------------------+
//|                                               IND Inverse.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, ..."
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Silver
//---- input parameters
//---- buffers
double Buffer[];

extern int iPeriod = 1;

//----
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
    IndicatorBuffers(1);
    IndicatorDigits(Digits+2);
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,Buffer);
//----
    return(0);
}

//+------------------------------------------------------------------+
//| Parabolic Sell And Reverse system                                |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();

//---- check for possible errors
   if(counted_bars<0) 
   {
      return(-1);
   }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

//---- do it
   
  
    for(int i=0; i<limit; i++)
    {
        // Easy to read
        double HD = High[Highest(NULL,0,MODE_HIGH,(iPeriod* 20),i)];
        double LD = Low[Lowest(NULL,0,MODE_LOW,(iPeriod* 20),i)];
        double amplitude = HD - LD;                
        Buffer[i]= ((Close[i]-(HD-(amplitude/2)))/amplitude) * iPeriod;
    }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+