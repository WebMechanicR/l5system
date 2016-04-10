//+------------------------------------------------------------------+
//|                                                 CatFX50.mq4 muram|
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.forex-tsd.com/showthread.php?t=523"
// 2005.01.06
// 2005.01.12 my birth day!!!

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua


//---- input parameters


extern int confirm_StepMA_Bars=3;
extern int confirm_EMA_Bars=3;
extern int alert_ON=0;//ON=1,OFF=0
extern int TradeTimeFrom=8;//sever time
extern int TradeTimeTo=18;//sever time
extern int EMA_period=50;
extern int EMA_method=0;//0=Close, 1=Open, 2=High, 3=Low, 4=median,5=typical, 6=weighted close
extern int StepMA_Stoch_PeriodWATR=10;
extern double StepMA_Stoch_Kwatr=1.0000;
extern int StepMA_Stoch_HighLow=0;
//---- buffers
double long[];
double short[];
double EMA50[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,long);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,short);
   SetIndexEmptyValue(1,0.0);
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexLabel(2,"EMA50");
   SetIndexBuffer(2,EMA50);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexEmptyValue(2,0.0);
   

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
   int    counted_bars=IndicatorCounted(),i,j,k;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//variables
   double stepma10,stepma11;
   bool EMA_cross,long_signal=0,short_signal=0;
//Main  roop
   for(i=limit; i>=0; i--)
     {
      EMA_cross=0;
      long[i]=0;
      short[i]=0;
      EMA50[i]=iMA(NULL,0,EMA_period,0,MODE_EMA,EMA_method,i);
      if (iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i)
         >iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i))//above StepMA
         short_signal=0;
      if (iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i)
         <iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i))//above StepMA
         long_signal=0;
if (TimeHour(Time[i])>=TradeTimeFrom&&TimeHour(Time[i])<=TradeTimeTo)
   {
   //Long check start
      if ((long_signal==0)&&(Open[i]>EMA50[i]))//above EMA50
        {
         short_signal=0;
         for (k=1; k<=confirm_EMA_Bars; k++)//EMAcross
           {
            if (MathMin(Close[i+k],Open[i+k])<EMA50[i+k])
               EMA_cross=1;
           }
            if ((iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i)
               >iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i))&&(EMA_cross==1))//above StepMA
              {
               for (j=1; j<=confirm_StepMA_Bars; j++)
                 {
                  stepma10=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i+j);
                  stepma11=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i+j);
                  if (stepma10<=stepma11)//StepMA cross
                    {                    
                     long[i]=Low[i]-iATR(NULL,0,5,i)/2 ;
                     long_signal=1;
                     break;
                     if (i==0&&alert_ON==1)
                     Alert(TimeToStr(Time[i],TIME_MINUTES)," CatFX50 ",Symbol()," BUY");
                    }
                 }
              }
         }
   //Long check end

//Short check start
      if ((short_signal==0)&&(Open[i]<EMA50[i]))//below EMA5
         {
         long_signal=0;
         for (k=1; k<=confirm_EMA_Bars; k++)//EMA cross
           {
            if (MathMax(Close[i+k],Open[i+k])>EMA50[i+k])
               EMA_cross=1;
           }
            if ((EMA_cross==1)&&(iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i)
               <iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i)))//below stepMA
              {
               for (j=confirm_StepMA_Bars-1; j>=0; j--)
                 {
                  stepma10=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i+j+1);
                  stepma11=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i+j+1);
                  if (stepma10>=stepma11)//StepMA cross
                    {
                     short[i]=High[i]+iATR(NULL,0,5,i)/2;
                     short_signal=1;
                     if (i==0&&alert_ON==1)
                     Alert(TimeToStr(Time[i],TIME_MINUTES)," CatFX50 ",Symbol()," SELL");
                    }
                 }
              }
         }
//Short check end
      }
   }
   return(0);
  }
//+------------------------------------------------------------------+