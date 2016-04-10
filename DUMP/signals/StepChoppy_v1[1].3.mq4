//+------------------------------------------------------------------+
//|                                              StepChoppy_v1.3.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_minimum -0.05
#property indicator_maximum 1.05
#property indicator_buffers 8

//---- input parameters
extern int     Length      =10;
extern double  Kv          = 1.0;
extern double  StepSize    =0;
extern int     MA_Mode     = 0; 
extern bool    HighLow     = false;
extern double  StepSizeFast=5;
extern double  StepSizeSlow=15;
int MAPeriod=1;
int Price=0;
int Mode=2;
//---- buffers
double UpBuffer1[];
double UpBuffer2[];
double UpBuffer3[];
double UpBuffer4[];

double DnBuffer1[];
double DnBuffer2[];
double DnBuffer3[];
double DnBuffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- 
   SetIndexStyle(0,DRAW_HISTOGRAM,0,3,MediumBlue);
   SetIndexStyle(1,DRAW_HISTOGRAM,0,3,DodgerBlue);
   SetIndexStyle(2,DRAW_HISTOGRAM,0,3,LightBlue);
   SetIndexStyle(3,DRAW_HISTOGRAM,0,3,Aqua);
   
   SetIndexStyle(4,DRAW_HISTOGRAM,0,3,Crimson);
   SetIndexStyle(5,DRAW_HISTOGRAM,0,3,Tomato);
   SetIndexStyle(6,DRAW_HISTOGRAM,0,3,Orange);
   SetIndexStyle(7,DRAW_HISTOGRAM,0,3,Yellow);
   
   SetIndexBuffer(0,UpBuffer1);
   SetIndexBuffer(1,UpBuffer2);
   SetIndexBuffer(2,UpBuffer3);
   SetIndexBuffer(3,UpBuffer4);
   
   SetIndexBuffer(4,DnBuffer1);
   SetIndexBuffer(5,DnBuffer2);
   SetIndexBuffer(6,DnBuffer3);
   SetIndexBuffer(7,DnBuffer4);
   
//---- 
   string short_name="StepChoppy";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Strong UpTrend");
   SetIndexLabel(1,"Retrace UpTrend");   
   SetIndexLabel(2,"Choppy UpTrend");
   SetIndexLabel(3,"Be ready to change UpTrend");
   
   SetIndexLabel(4,"Strong DownTrend");
   SetIndexLabel(5,"Retrace DownTrend");   
   SetIndexLabel(6,"Choppy DownTrend");
   SetIndexLabel(7,"Be ready to change DownTrend"); 
//----
   
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
   SetIndexDrawBegin(2,Length);
   SetIndexDrawBegin(3,Length);
   SetIndexDrawBegin(4,Length);
   SetIndexDrawBegin(5,Length);
   SetIndexDrawBegin(6,Length);
   SetIndexDrawBegin(7,Length);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| StepChoppy_v1.3                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int  i,counted_bars=IndicatorCounted();
   double RSI, FastRSI, SlowRSI, StepMA, UpTrendMA, DnTrendMA; 
//----
   if(Bars<=Length) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=Length;i++) 
      {
      UpBuffer1[Bars-i]=0.0;
      UpBuffer2[Bars-i]=0.0;
      UpBuffer3[Bars-i]=0.0;
      UpBuffer4[Bars-i]=0.0;
      
      DnBuffer1[Bars-i]=0.0;
      DnBuffer2[Bars-i]=0.0;
      DnBuffer3[Bars-i]=0.0;
      DnBuffer4[Bars-i]=0.0;
      }
//----
   if ( counted_bars > 0 )  int limit=Bars-counted_bars;
   if ( counted_bars ==0 )  limit=Bars-Length-1; 
        
   for(i=limit;i>=0;i--) 
   {	 
   
   UpTrendMA = iCustom(NULL,0,"StepMA_v7",Length,Kv,StepSize,MA_Mode,0,0,HighLow,2,0,1,i);
   DnTrendMA = iCustom(NULL,0,"StepMA_v7",Length,Kv,StepSize,MA_Mode,0,0,HighLow,2,0,2,i);         
   
   RSI=iCustom(NULL,0,"StepRSI_v5.2",Length,StepSizeFast,MAPeriod,Price,Mode,0,i);
   FastRSI=iCustom(NULL,0,"StepRSI_v5.2",Length,StepSizeFast,MAPeriod,Price,Mode,1,i);
   SlowRSI=iCustom(NULL,0,"StepRSI_v5.2",Length,StepSizeSlow,MAPeriod,Price,Mode,1,i);   
   
   UpBuffer1[i] =UpBuffer1[i+1];
   UpBuffer2[i] =UpBuffer2[i+1];
   UpBuffer3[i] =UpBuffer3[i+1];
   UpBuffer4[i] =UpBuffer4[i+1];
   
   DnBuffer1[i] =DnBuffer1[i+1];
   DnBuffer2[i] =DnBuffer2[i+1];
   DnBuffer3[i] =DnBuffer3[i+1];
   DnBuffer4[i] =DnBuffer4[i+1];
   
   if (FastRSI > SlowRSI && RSI > FastRSI && UpTrendMA!=EMPTY_VALUE) 
   {UpBuffer1[i] = 1.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 0.0;}
   
   else if (FastRSI > SlowRSI && RSI < FastRSI && UpTrendMA!=EMPTY_VALUE) 
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 1.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 0.0;}
   
   else if (FastRSI < SlowRSI && RSI > FastRSI && UpTrendMA!=EMPTY_VALUE)  
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 1.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 0.0;}
    
   else if (FastRSI < SlowRSI && RSI < FastRSI && UpTrendMA!=EMPTY_VALUE) 
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 1.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 0.0;}
   
    
   else if (FastRSI < SlowRSI && RSI < FastRSI && DnTrendMA!=EMPTY_VALUE) 
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 1.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 0.0;}
   
   else if (FastRSI < SlowRSI && RSI > FastRSI && DnTrendMA!=EMPTY_VALUE)    
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 1.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 0.0;}
   
   else if (FastRSI > SlowRSI && RSI < FastRSI && DnTrendMA!=EMPTY_VALUE)    
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 1.0;DnBuffer4[i] = 0.0;}
      
   else if (FastRSI > SlowRSI && RSI > FastRSI && DnTrendMA!=EMPTY_VALUE) 
   {UpBuffer1[i] = 0.0;UpBuffer2[i] = 0.0;UpBuffer3[i] = 0.0;UpBuffer4[i] = 0.0;
    DnBuffer1[i] = 0.0;DnBuffer2[i] = 0.0;DnBuffer3[i] = 0.0;DnBuffer4[i] = 1.0;}
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+