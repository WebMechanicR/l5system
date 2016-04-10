//+------------------------------------------------------------------+
//|                                                    StocRSI 2.mq4 |
//|                                                     Emerald King |
//|                                     mailto:info@emerald-king.com |
//+------------------------------------------------------------------+
#property copyright "Emerald King"
#property link      "mailto:info@emerald-king.com"

#property indicator_separate_window
#property indicator_color1 Red
//---- input parameters
extern int Len1=8;
extern int Len2=8;
extern int Len3=5;
extern int CountBars=950;

double CU = 0;
double CD = 0;
double CUAve = 0;
double CDAve = 0;
double CUAveB = 0;
double CDAveB = 0;
double Count = 0;
double RSI0[1000];
double HiR = 0;
double LoR = 0;
double StocR = 0;
double StocRSI = 0;
double Price = 0;
int x = 0;
double TempA = 0;
double TempB = 0;
double TempC = 0;
int Lookback = 0;

double val1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   Lookback = MathMax(Len1, Len2);
   Lookback = MathMax(Lookback, Len3);   
   SetIndexBuffer(0,val1);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if (CountBars>Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+Lookback);
   
   int i;
   int    counted_bars=IndicatorCounted();

   if(CountBars<=Lookback) return(0);
   //---- initial zero
   if(counted_bars<1)
   {
      for(i=1;i<=Lookback;i++) val1[CountBars-i]=0.0;
   }

   i=CountBars-Lookback-1;
   while(i>=0)
   {
      CU = 0;
      CD = 0;
      CUAveB = CUAve;
      CDAveB = CDAve;
      
      for (x=i; x<i+Len1-1;x++)
      {
         if (Close[x] > Close[x + 1]) CU = CU + (Close[x] - Close[x + 1]);
         if (Close[x] < Close[x + 1]) CD = CD + (Close[x + 1] - Close[x]);
      }
      
      
      CU = CU / Len1;
      CD = CD / Len1;
      CUAve = CU;
      CDAve = CD;
      
      if ((CUAve + CDAve) != 0) RSI0[i] = CUAve / (CUAve+ CDAve);
      if (i > Lookback)
      {
         CUAve = (CUAveB *(Len1 - 1) + CU) / Len1;
         CDAve = (CDAveB *(Len1 - 1) + CD) / Len1;
      }
      
      if ((CUAve + CDAve) != 0) RSI0[i] = CUAve / (CUAve+ CDAve);
      
      for (x=i; x<i+Len2-1; x++) 
      {
         if ( x==i )
         {
            TempA = RSI0[x];
            TempB = RSI0[x];
         }
         
         if ( RSI0[x] > TempA )
            TempA = RSI0[x];
         if ( RSI0[x] < TempB )
            TempB = RSI0[x];
      }
            
      HiR = TempA;
      LoR = TempB;
      
      if (HiR != LoR) StocR = (RSI0[i] - LoR)/ (HiR - LoR);

      StocRSI = 0;
      TempC = 0;
      
      for (x=i; x<i+Len3-1;x++)
      {
         StocRSI = StocRSI + (Len3 - x) * StocR;
         TempC = TempC + (x+1);
      }
      
      if ( TempC != 0 ) StocRSI = StocRSI / TempC;

      if ( StocRSI > 0 )
         val1[i] = val1[i+1];
      else
         val1[i] = StocRSI;   
	  i--;
	}
   return(0);
 }
//+------------------------------------------------------------------+