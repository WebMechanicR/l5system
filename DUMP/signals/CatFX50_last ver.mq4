//+------------------------------------------------------------------+
//|                                                 CatFX50muram.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.forex-tsd.com/showthread.php?t=523"
// 2005.01.06

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
//#property indicator_color4 Blue
//#property indicator_color5 Red
//#property indicator_color6 White

//---- input parameters

//Trading Time in server Time
extern int confirm_StepMA_Bars=3;//over 2
//extern int TradeTimeFrom=0;
//extern int TradeTimeTo=24;
extern int alert_ON=0;//ON=1,OFF=0
extern int EMA_period=50;
extern int EMA_method=0;//0=Close, 1=Open, 2=High, 3=Low, 4=median,5=typical, 6=weighted close
extern int StepMA_Stoch_PeriodWATR=10;
extern double StepMA_Stoch_Kwatr=1.0000;
extern int StepMA_Stoch_HighLow=0;
//---- buffers
double long[];
double short[];
double EMA50[];
//double profit[];
//double loss[];
//double entry[];
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
   
//  SetIndexStyle(3,DRAW_LINE);
//   SetIndexLabel(3,"profit");
//   SetIndexBuffer(3,profit);
//   SetIndexEmptyValue(3,0.0);
//   
//   SetIndexStyle(4,DRAW_LINE);
//   SetIndexLabel(4,"loss");
//   SetIndexBuffer(4,loss);
//   SetIndexEmptyValue(1,0.0);
//   
//   SetIndexStyle(5,DRAW_LINE);
//   SetIndexLabel(5,"entry");
//   SetIndexBuffer(5,entry);
//   SetIndexEmptyValue(5,0.0);
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
   int    counted_bars=IndicatorCounted(),i,j;
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
//variables
   double stepma10,stepma11;
//Main  roop
   for(i=limit; i>=0; i--)
     {
      long[i]=0;
      short[i]=0;
      EMA50[i]=iMA(NULL,0,EMA_period,0,MODE_EMA,EMA_method,i);
   //if (TimeHour(Time[i])>=TradeTimeFrom&&TimeHour(Time[i])<=TradeTimeTo)
//if (profit[i+1]>loss[i+1])//long trigered
//{
//profit[i]=MathMax(profit[i+1],High[i]);
//loss[i]=MathMin(loss[i+1],Low[i]);
//}
//if (profit[i+1]<loss[i+1])//short trigered
//{
//loss[i]=MathMax(loss[i+1],High[i]);
//profit[i]=MathMin(profit[i+1],Low[i]);
//}
//entry[i]=entry[i+1];
   {

   //Long check start
      if (((Low[i+1]<=EMA50[i+1]))&&(Open[i]>EMA50[i]))//cross EMA50
         {
            if (iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i)
               >iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i))//above StepMA
              {
               for (j=confirm_StepMA_Bars-1; j>=0; j--)
                 {
                  stepma10=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i+j+1);
                  stepma11=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i+j+1);
                  if ((stepma10<stepma11)&&(long[i+1]==0)&&(long[i+2]==0))//StepMA cross
                    {                    
                     long[i]=(Low[i])-iATR(NULL,0,5,i)/2 ;
                     //profit[i]=High[i];
                     //loss[i]=Low[i];
                     //entry[i]=Open[i];
                     if (i==0&&alert_ON==1)
                     Alert(TimeToStr(Time[i],TIME_MINUTES)," CatFX50 ",Symbol()," BUY");
                    }
                 }
              }
         }
   //Long check end

//Short check start
      if ((High[i+1]>=EMA50[i+1])&&(Open[i]<EMA50[i]))//cross EMA5
         {  
            if (iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i)
               <iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i))//below stepMA
              {
               for (j=confirm_StepMA_Bars-1; j>=0; j--)
                 {
                  stepma10=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,0,i+j+1);
                  stepma11=iCustom(NULL,0,"StepMA_Stoch_v1",StepMA_Stoch_PeriodWATR,StepMA_Stoch_Kwatr,StepMA_Stoch_HighLow,1,i+j+1);
                  if ((stepma10>stepma11)&&(short[i+1]==0)&&(short[i+2]==0))//StepMA cross
                    {
                     short[i]=High[i]+iATR(NULL,0,5,i)/2;
                     //profit[i]=Low[i];
                     //loss[i]=High[i];
                     //entry[i]=Open[i];
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