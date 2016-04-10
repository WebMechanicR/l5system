//+------------------------------------------------------------------+
//|                                               RAVI FX Fisher.mq4 |
//|                         Copyright © 2005, Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 MediumSeaGreen

extern int       MAfast=4;
extern int       MAslow=49;

double RAVIfxFishBuffer[];



int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RAVIfxFishBuffer);
   return(0);
  }


int deinit()
  {
   return(0);
  }


int start()
  {
      double MAValue=0;
      double IFish=0;
      
      double imaFast=0;
      double imaSlow=0;
      double iATRFast=0;
      
      for (int shift = 0; shift<=Bars-100;shift++)
      {
	     imaFast=iMA(NULL,0,MAfast,0,MODE_LWMA,PRICE_TYPICAL,shift);
	     imaSlow=iMA(NULL,0,MAslow,0,MODE_LWMA,PRICE_TYPICAL,shift);
	     iATRFast=iATR(NULL,0,MAfast,shift);

	     MAValue = 100 * (imaFast - imaSlow)* iATRFast/imaSlow/iATRFast;
	     IFish=(MathExp(2*MAValue)-1)/(MathExp(2*MAValue)+1);
	    
         RAVIfxFishBuffer[shift]=IFish;
       }
   
   return(0);
  }

