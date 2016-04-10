//+------------------------------------------------------------------+
//|                                                       MA-ATR.mq4 |
//|                         Copyright © 2006, Balidev Software Corp. |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Balidev Software Corp."
#property link      "http://www.balidev.com/"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 SlateGray
#property indicator_color3 SlateGray
#property indicator_color4 Aqua
#property indicator_color5 Aqua

//---- indicator parameters
extern int MA_Period=2;
extern int MA_Shift=0;
extern int MA_Method=0;
extern int ATR_Period=100;
extern double ATR_Factor=1;
extern int ATR_Shift=0;
extern bool ATR_UseMAOnArray=false;
extern int ATR_MAOnArrayPeriod=3;
extern int ATR_MAOnArrayMethod=MODE_EMA;
extern int ATR_MAOnArrayShift=0;
extern int MaxBar=1000;

//---- indicator buffers
double MA_Val[];
double MTR_Top_Val[];
double MTR_Btm_Val[];
double MTR_AvgTop_Val[];
double MTR_AvgBtm_Val[];
int myBar;

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int    draw_begin;
   string short_name;
//---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexShift(0,MA_Shift);
   if (!ATR_UseMAOnArray) {
      SetIndexStyle(1,DRAW_LINE);
      SetIndexShift(1,MA_Shift);
      SetIndexStyle(2,DRAW_LINE);
      SetIndexShift(2,MA_Shift);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
   } else {
      SetIndexStyle(3,DRAW_LINE);
      SetIndexShift(3,MA_Shift);
      SetIndexStyle(4,DRAW_LINE);
      SetIndexShift(4,MA_Shift);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);  
   }
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;
//---- indicator short name
   switch(MA_Method)
     {
      case 1 : short_name="EMA(";  draw_begin=0; break;
      case 2 : short_name="SMMA("; break;
      case 3 : short_name="LWMA("; break;
      default :
         MA_Method=0;
         short_name="SMA(";
     }
   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);   
//---- indicator buffers mapping
   SetIndexBuffer(0,MA_Val);
   SetIndexBuffer(1,MTR_Top_Val);
   SetIndexBuffer(2,MTR_Btm_Val);
   SetIndexBuffer(3,MTR_AvgTop_Val);
   SetIndexBuffer(4,MTR_AvgBtm_Val);

//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   myBar = MaxBar;
   if (myBar > Bars)
   {
      myBar = Bars;
   }
    
   if(myBar<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//----
   switch(MA_Method)
     {
      case 0 : sma();  break;
      case 1 : ema();  break;
      case 2 : smma(); break;
      case 3 : lwma();
     }
//---- done
   /* calculate the atr envelope */
   for (int i = 0; i < myBar - (ATR_Period + ATR_Shift); i++)
   {
     double spread = (Ask-Bid);
     double atr = iATR(NULL, 0, ATR_Period, ATR_Shift + i);
     MTR_Top_Val[i] = MA_Val[i] + (atr * ATR_Factor) + spread;
     MTR_Btm_Val[i] = MA_Val[i] - (atr * ATR_Factor);
   }

   /*if (ATR_UseMAOnArray) {
      for (i = 0; i < myBar - (ATR_Period + ATR_Shift + ATR_MAOnArrayPeriod + ATR_MAOnArrayShift); i++) {
        MTR_AvgTop_Val[i] = iMAOnArray(MTR_Top_Val, ATR_MAOnArrayPeriod + i, ATR_MAOnArrayPeriod, i, ATR_MAOnArrayMethod, ATR_MAOnArrayShift);
        MTR_AvgBtm_Val[i] = iMAOnArray(MTR_Btm_Val, ATR_MAOnArrayPeriod + i, ATR_MAOnArrayPeriod, i, ATR_MAOnArrayMethod, ATR_MAOnArrayShift);
      }
   }*/

   return(0);
  }
  
  
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void sma()
  {
   double sum=0;
   int    i,pos=myBar-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)
      sum+=Close[pos];
//---- main calculation loop
   while(pos>=0)
     {
      sum+=Close[pos];
      MA_Val[pos]=sum/MA_Period;
	   sum-=Close[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) MA_Val[myBar-i]=0;
  }
//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+
void ema()
  {
   double pr=2.0/(MA_Period+1);
   int    pos=myBar-2;
   if(ExtCountedBars>2) pos=myBar-ExtCountedBars-1;
//---- main calculation loop
   while(pos>=0)
     {
      if(pos==myBar-2) MA_Val[pos+1]=Close[pos+1];
      MA_Val[pos]=Close[pos]*pr+MA_Val[pos+1]*(1-pr);
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
void smma()
  {
   double sum=0;
   int    i,k,pos=myBar-ExtCountedBars+1;
//---- main calculation loop
   pos=myBar-MA_Period;
   if(pos>myBar-ExtCountedBars) pos=myBar-ExtCountedBars;
   while(pos>=0)
     {
      if(pos==myBar-MA_Period)
        {
         //---- initial accumulation
         for(i=0,k=pos;i<MA_Period;i++,k++)
           {
            sum+=Close[k];
            //---- zero initial bars
            MA_Val[k]=0;
           }
        }
      else sum=MA_Val[pos+1]*(MA_Period-1)+Close[pos];
      MA_Val[pos]=sum/MA_Period;
 	   pos--;
     }
  }
//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=myBar-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Close[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      MA_Val[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=Close[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Close[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) MA_Val[myBar-i]=0;
  }
//+------------------------------------------------------------------+

