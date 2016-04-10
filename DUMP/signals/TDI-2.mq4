//+------------------------------------------------------------------+
//|                                                        TDI-2.mq4 |
//|                                Системная торговля на рынке Forex |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
// Идея из ForexMagazin #58 , вторая версия
#property copyright "Written by Rosh"
#property link      "http://forexsystems.ru/phpBB/index.php"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DarkBlue
#property indicator_color2 Red
#property indicator_level1 0.0
//---- input parameters
extern int PeriodTDI=20;
//---- buffers
double TDI_Buffer[];
double Direction_Buffer[];
// ---- temporary buffers
double MomBuffer[];
double MomAbsBuffer[];
double MomSumBuffer[];
double MomSumAbsBuffer[];
double MomAbsSumBuffer[];
double MomAbsSum2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TDI_Buffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Direction_Buffer);
   SetIndexLabel(0,"Trend Direction Index");
   SetIndexLabel(1,"Direction");
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexBuffer(2,MomBuffer);
   SetIndexBuffer(3,MomAbsBuffer);
   SetIndexBuffer(4,MomSumBuffer);
   SetIndexBuffer(5,MomSumAbsBuffer);
   SetIndexBuffer(6,MomAbsSumBuffer);   
   SetIndexBuffer(7,MomAbsSum2Buffer);  
   IndicatorShortName("TDI"+"("+PeriodTDI+")");
//----
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
   int limit,i;
   int    counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) limit=Bars-counted_bars;
   if (counted_bars==0) 
      {
      limit=Bars-PeriodTDI;
      for (i=Bars-1;i>limit;i--) {MomBuffer[i]=0.0;MomAbsBuffer[i]=0.0;}
      
      }


   limit--;


//---- TODO: add your code here
   for(i=limit; i>=0; i--)
      {
      MomBuffer[i]=Close[i]-Close[i+PeriodTDI];
      MomAbsBuffer[i]=MathAbs(MomBuffer[i]);
      }
   for(i=limit; i>=0; i--)
      {
      MomSumBuffer[i]=iMAOnArray(MomBuffer,0,PeriodTDI,0,MODE_SMA,i)*PeriodTDI;
      MomSumAbsBuffer[i]=MathAbs(MomSumBuffer[i]);
      Direction_Buffer[i]=MomSumBuffer[i];
      }

   for(int l=limit; l>=0; l--)
      {
      MomAbsSumBuffer[l]=iMAOnArray(MomAbsBuffer,0,PeriodTDI,0,MODE_SMA,l)*PeriodTDI;
      MomAbsSum2Buffer[l]=iMAOnArray(MomAbsBuffer,0,2*PeriodTDI,0,MODE_SMA,l)*2*PeriodTDI;
      TDI_Buffer[l]=MomSumAbsBuffer[l]-(MomAbsSum2Buffer[l]-MomAbsSumBuffer[l]);
      }
      
//---- done
   
//----
   return(0);
  }
//+------------------------------------------------------------------+