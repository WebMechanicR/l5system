//+------------------------------------------------------------------+
//|                                                          TDI.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
// ָהוÿ טח ForexMagazin #58 
#property copyright "Written by Rosh"
#property link      "http://www.metaquotes.net"

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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TDI_Buffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Direction_Buffer);
   SetIndexLabel(0,"Trend Direction Index");
   SetIndexLabel(1,"Direction");
   
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
   double MomBuffer[];
   double MomAbsBuffer[];
   double MomSumBuffer[];
   double MomSumAbsBuffer[];
   double MomAbsSumBuffer[];
   double MomAbsSum2Buffer[];
   double temp;
   bool First=true;
   int limit,i;
   int    counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   if (First){limit=Bars-PeriodTDI; First=false;} else limit=Bars-counted_bars;
//   limit=Bars-PeriodTDI;
   ArrayResize(MomBuffer,limit);
   ArrayResize(MomAbsBuffer,limit);
   ArrayResize(MomSumBuffer,limit);
   ArrayResize(MomSumAbsBuffer,limit);
   ArrayResize(MomAbsSumBuffer,limit);
   ArrayResize(MomAbsSum2Buffer,limit);
   ArraySetAsSeries(MomBuffer,true);
   ArraySetAsSeries(MomAbsBuffer,true);
   ArraySetAsSeries(MomSumBuffer,true);
   ArraySetAsSeries(MomSumAbsBuffer,true);
   ArraySetAsSeries(MomAbsSumBuffer,true);
   ArraySetAsSeries(MomAbsSum2Buffer,true);
   
//---- TODO: add your code here
   for(i=0; i<limit; i++)
      {
      MomBuffer[i]=Close[i]-Close[i+PeriodTDI];
      MomAbsBuffer[i]=MathAbs(MomBuffer[i]);
      }
   for(i=limit; i>=0; i--)
      {
      temp=0;
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