//+------------------------------------------------------------------+
//|                                                   ^Dyn_Pivot.mq4 |
//|                                      Modest, Rosh conversed only |
//|                           http://forexsystems.ru/phpBB/index.php |
//+------------------------------------------------------------------+
#property copyright "Modest, Rosh conversed only"
#property link      "http://forexsystems.ru/phpBB/index.php"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LightBlue
#property indicator_color2 Magenta
//---- input parameters
extern int       Formula=0;
int i=1, j=1, shift=0;
double FP=0.0;
double FH=0.0, FL=0.0;
bool result;
//---- buffers
double ExtMapBuffer1[];
double FR2Buffer[];
double FS2Buffer[];
//+------------------------------------------------------------------+
//| Проверка нового дня                                              |
//+------------------------------------------------------------------+
bool isNewDay(int _shift)
  {
//---- 
   result=false;
   if (  (TimeHour(Time[_shift])==0)  && (TimeMinute(Time[_shift])==0)   ) result=true;
   //Print("Дата=",TimeToStr(Time[_shift]),"  isNewDay=",result);
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| Установить уровни FP, FR2 и FS2 прошедшего дня                   |
//+------------------------------------------------------------------+
void SetLevels2(int _shift)
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
   ExtMapBuffer1[_shift]=FP;
   FR2Buffer[_shift]=NormalizeDouble(FP+(FH-FL),Digits);
   FS2Buffer[_shift]=NormalizeDouble(FP-(FH-FL),Digits);
  }

//+------------------------------------------------------------------+
//| Установить уровни FP, FR2 и FS2 в ноль                           |
//+------------------------------------------------------------------+
void SetLevels2Empty(int _shift)
  {
   ExtMapBuffer1[_shift]=0.0;
   FR2Buffer[_shift]=0.0;
   FS2Buffer[_shift]=0.0;
  }
//+------------------------------------------------------------------+
//| Установка уровней в нулевом баре                                 |
//+------------------------------------------------------------------+
void SetNullBarLevels(int _shift)
  {
  int cnt;
  int currDay=TimeDay(Time[_shift]);
//---- 
   i=1;
   while (TimeDay(Time[_shift+i])==currDay) i++;
   if (i>=2)
      {
      i=i-2;
      for (cnt=i;cnt>0;cnt--) 
         {
         ExtMapBuffer1[shift+cnt]=0.0;
         FR2Buffer[_shift]=0.0;
         FS2Buffer[_shift]=0.0;
         }
      FH=High[Highest(NULL,0,MODE_HIGH,i+1,_shift)];
      FL=Low[Lowest(NULL,0,MODE_LOW,i+1,_shift)];
      if (Formula==0) FP=NormalizeDouble((FH+FL+Close[_shift+1])/3.0,Digits); else FP=NormalizeDouble((FH+FL+2*Close[_shift+1])/4.0,Digits);
      ExtMapBuffer1[_shift]=FP;
      FR2Buffer[_shift]=NormalizeDouble(FP+(FH-FL),Digits);
      FS2Buffer[_shift]=NormalizeDouble(FP-(FH-FL),Digits);
      }
//----
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
   if (Formula!=0)Formula=1;
   string label1="FR2("+Formula+")";
   string label2="FS2("+Formula+")";
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,FR2Buffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,label1);

   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,FS2Buffer);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,label2);

   SetIndexBuffer(2,ExtMapBuffer1);
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
   int limit,firstDay;
   int counted_bars=IndicatorCounted();
   if (counted_bars<0) return(-1);
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
      if (isNewDay(shift)) SetLevels2(shift); else  SetLevels2Empty(shift);
      if (shift==0) SetNullBarLevels(shift);
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+