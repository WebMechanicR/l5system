//+------------------------------------------------------------------+
//|                                                      iAvgVol.mq4 |
//|                                           Copyright © 2005, Anri |
//|                                    http://tradestation.narod.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Anri"
#property link      "http://tradestation.narod.ru/"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 WhiteSmoke
//---- input parameters
extern int       nPeriod=5;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"Volume");
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"Avg Volume");
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
   int    counted_bars=IndicatorCounted();
//---- TODO: add your code here
   int    i, shift;
   double nSum;
//---- initial zero
   if(counted_bars<1) // если текущий бар меньше единицы - нафиг с пляжа, устанавливаем все в нули
     {
      for(i=1;i<=0;i++) {ExtMapBuffer1[Bars-i]=0; ExtMapBuffer2[Bars-i]=0; };
     };
//---- вычисления
   for(shift=Bars-1;shift>=0;shift--) {
     nSum=Volume[shift]; 
     ExtMapBuffer1[shift]=nSum;
     if ((nPeriod>0)&&(shift<(Bars-1-nPeriod))) {
       for(i=nPeriod-1;i>=1;i--) {
         nSum=nSum+ExtMapBuffer1[shift+i];
	    };
	    nSum=nSum/nPeriod;
	  };
     ExtMapBuffer2[shift]=nSum;
   };
   return(0);
  }
//+------------------------------------------------------------------+