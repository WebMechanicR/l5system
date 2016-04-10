//+------------------------------------------------------------------+
//|                                                    ^Pivot_PP.mq4 |
//|                                      Modest, Rosh conversed only |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "Modest, Rosh conversed only"
#property link      "http://forexsystems.ru/phpBB/index.php"
//// Строим Pivot и Res/Supp по FibonacciTrader Journal Issue 6
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DarkGreen
//---- input parameters
extern int       Formula=0;
int i=1, shift;
double FP=0.0;
double FH=0.0, FL=0.0;
bool result;
//---- buffers
double ExtMapBuffer1[];

//+------------------------------------------------------------------+
//| Проверка нового дня                                              |
//+------------------------------------------------------------------+
bool isNewDay(int _shift)
  {
//---- 
   result=false;
   if (  (TimeHour(Time[_shift])==0)  && (TimeMinute(Time[_shift])==0)   ) result=true;

//----
   return(result);
  }
//+------------------------------------------------------------------+
//| Получить уровень FP прошедшего дня                               |
//+------------------------------------------------------------------+
double GetFPofDay(int _shift)
  {
  int prevDay=TimeDay(Time[_shift+1]);
//---- 
   i=1;
   while (TimeDay(Time[_shift+i])==prevDay) i++;
   i--;
   FH=High[Highest(NULL,0,MODE_HIGH,i,_shift+1)];
   FL=Low[Lowest(NULL,0,MODE_LOW,i,_shift+1)];
   if (Formula==0) FP=NormalizeDouble((FH+FL+Close[_shift+1])/3.0,Digits); else FP=NormalizeDouble((FH+FL+2*Close[_shift+1])/4.0,Digits);
//----
   return(FP);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   if (Formula!=0)Formula=1;
   string label="Pivot_PP("+Formula+")";
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,160); 
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,label);

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
   int limit,firstDay;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(0);
   if (counted_bars==0) 
      {
      limit=Bars-1;
      i=1;
      firstDay=TimeDay(Time[limit]);
      while (TimeDay(Time[limit-i])==firstDay) i++;
      limit=limit-i-PERIOD_D1/Period();
      }
   if (counted_bars>0) limit=Bars-counted_bars;
//---- 
   if (Period()>PERIOD_H4) return;
   for (shift=limit;shift>=0;shift--)
      {
      if (isNewDay(shift)) ExtMapBuffer1[shift]=GetFPofDay(shift); else  ExtMapBuffer1[shift]=ExtMapBuffer1[shift+1];
      //if (shift==0) SetNullBarValue(shift);
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+