//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "TraderSeven"
#property link      "TraderSeven@gmx.net"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Orange
#property indicator_color3 Blue
#property indicator_color4 MediumSeaGreen
#property indicator_color5 Red
#property indicator_color6 White
//---- indicator parameters
extern int MA_Period=10;


extern double Percent=2;

double UpperBand;
double LowerBand;
UpperBand=(1+Percent/100);
LowerBand=1-Percent/100;

//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
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
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   if(MA_Period<2) MA_Period=13;
   draw_begin=MA_Period-1;

   IndicatorShortName(short_name+MA_Period+")");
   SetIndexDrawBegin(0,draw_begin);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexBuffer(5,ExtMapBuffer6);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=MA_Period) return(0);
   ExtCountedBars=IndicatorCounted();
//---- check for possible errors
   if (ExtCountedBars<0) return(-1);
//---- last counted bar will be recounted
   if (ExtCountedBars>0) ExtCountedBars--;
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
  {
   double sum=0;
   int    i,pos=Bars-ExtCountedBars-1;
//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<MA_Period;i++,pos--)
      sum+=Open[pos];
//---- main calculation loop
   while(pos>=0)
     {
      sum+=Open[pos];
      ExtMapBuffer1[pos]=(sum/MA_Period)*UpperBand;
      //ExtMapBuffer2[pos]=(((sum/MA_Period)*1.02)-(Open[pos]*0.0025));      
      ExtMapBuffer3[pos]=(sum/MA_Period)*LowerBand;
      //ExtMapBuffer4[pos]=((sum/MA_Period)*0.98)+(Open[pos]*0.0025);  
	   sum-=Open[pos+MA_Period-1];
 	   pos--;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) ExtMapBuffer1[Bars-i]=0;
  }
//+------------------------------------------------------------------+
}





