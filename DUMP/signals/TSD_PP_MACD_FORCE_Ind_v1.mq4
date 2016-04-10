//+------------------------------------------------------------------+
//|                                     TSD_PP_MACD_FORCE_Ind_v1.mq4 |
//|                                    (From Elders Book) |
//|                           Copyright ® 2005 Bob O'Brien / Barcode |
//|             TSD Indicator by Pedro Puado                         |
//|                                        TSD Indicator version 1   |
//+------------------------------------------------------------------+
#property copyright "Pedro Puado (From Elders Book)"
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
//---- input parameters
extern int       Force=2;
extern int       FastMA=12;
extern int       SlowMA=26;
extern int       Signal=9;
extern int       MaxBars=1000;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"Up");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"Down");
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
   int    counted_bars=IndicatorCounted();
   double MacdPrevious, MacdPrevious2, force, ForcePos, ForceNeg;
   int    Direction;
//---- 
   int    i,k, nDay, nWeek;
   i=Bars-1;
   if(counted_bars>0) i=Bars-counted_bars+0;
   i = MathMin(i, MaxBars);
   
   while (i >=0)
   {
      nWeek = GetWeekIndex(i);
      MacdPrevious  = iMACD(Symbol(),PERIOD_W1,SlowMA,FastMA,Signal,PRICE_CLOSE,MODE_MAIN,nWeek+1);
      MacdPrevious2 = iMACD(Symbol(),PERIOD_W1,SlowMA,FastMA,Signal,PRICE_CLOSE,MODE_MAIN,nWeek+2);

      if (MacdPrevious > MacdPrevious2) Direction = 1;
      if (MacdPrevious < MacdPrevious2) Direction = -1;
      if (MacdPrevious == MacdPrevious2) Direction = 0;

      nDay = GetDayIndex(i);
      force = iForce(Symbol(),PERIOD_D1,Force,MODE_EMA,PRICE_CLOSE,nDay+1); 
      ForcePos = force > 0;
      ForceNeg = force < 0;
      Print(nWeek, " - ", Direction, " - ", nDay, " - ", Force);

	   if(Direction == 1 && ForceNeg)
	   {
	      ExtMapBuffer1[i] = 1;
	      ExtMapBuffer2[i] = 0.0;
	   }

	   if(Direction == -1 && ForcePos)
	   {
	      ExtMapBuffer1[i] = 0.0;
	      ExtMapBuffer2[i] = -1;
	   }

      i--;
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

int GetWeekIndex(int x)
{
      datetime dSun = StrToTime(TimeToStr(Time[x]-(TimeDayOfWeek(Time[x])*86400),TIME_DATE));           
      return (((iTime(Symbol(),PERIOD_W1,0)-dSun)/86400)/7);
}
//+------------------------------------------------------------------+

int GetDayIndex(int x)
{
      if (Period() == PERIOD_D1) return (x);
      
      int nWeek = GetWeekIndex(x)*5; //number of days since 
      datetime dSun = StrToTime(TimeToStr(Time[x],TIME_DATE));           
      int i = MathAbs((iTime(Symbol(),PERIOD_D1,nWeek)-dSun)/86400);
      return (nWeek-i);
}
//+------------------------------------------------------------------+

