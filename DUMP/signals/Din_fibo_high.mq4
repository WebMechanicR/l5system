//+------------------------------------------------------------------------------------+
//|                                                Din_fibo_high.mq4                   |
//|                                 unknown author, get from kaizer, conversed by Rosh |
//| link to kaizer: http://forum.alpari-idc.ru/profile.php?mode=viewprofile&u=4196161  |
//|                                              http://forexsystems.ru/phpBB/index.php|
//+------------------------------------------------------------------------------------+
#property copyright "unknown author, get from kaizer, conversed by Rosh"
#property link      "http://forexsystems.ru/phpBB/index.php"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Yellow
//---- input parameters
extern int       Ch_Period=3;
extern double    Ratio=0.786;
extern bool      SetAllBars=false;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double tvBuffer[];
int hh,ll,first,counterPeriod;
double tv,MaH,MaL;
//+------------------------------------------------------------------+
//| ѕроверим - разделитель диапазона или нет                         |
//+------------------------------------------------------------------+
bool isDelimeter(int _Period, int _shift)
  {
  bool result=false;
//---- 
  switch (_Period)
   {
   case 5:result=(TimeMinute(Time[_shift])==0)&&(TimeHour(Time[_shift])==0); break;
   case 15:result=(TimeMinute(Time[_shift])==0)&&(TimeHour(Time[_shift])==0); break;
   case 30:result=(TimeMinute(Time[_shift])==0)&&(TimeHour(Time[_shift])==0); break;
   case 60:result=(TimeMinute(Time[_shift])==0)&&(TimeHour(Time[_shift])==0); break;
   case 240:result=(TimeDayOfWeek(Time[_shift])==1)&&(TimeHour(Time[_shift])==0); break;
   case 1440:result=(TimeDay(Time[_shift])==1)||((TimeDay(Time[_shift])==2 && TimeDay(Time[_shift+1])!=1))||((TimeDay(Time[_shift])==3 && TimeDay(Time[_shift+1])!=2)); break;
   case 10080:result=TimeDay(Time[_shift])<=7 && TimeMonth(Time[_shift])==1; break;
   default: Print("Ќедопустимый период!!!"); 
   }
//----
   return(result);
  }
//+------------------------------------------------------------------+
//| ”становим MaH и MaL на границе диапазона                           |
//+------------------------------------------------------------------+
void SetHnL(int _shift)
  {
//---- 
   int i=_shift+1;
   counterPeriod=0;
   while (counterPeriod<Ch_Period)
      {
      while (tvBuffer[i]==0.0 && i<Bars) i++;
      counterPeriod++;
      i++;
      }
   i--;   
   hh=Highest(NULL,0,MODE_HIGH,i-_shift,_shift+1);
   ll=Lowest(NULL,0,MODE_LOW,i-_shift,_shift+1);
   tv=NormalizeDouble((High[hh]+Low[ll]+Close[_shift+1])/3.0,Digits);
   MaH=tv+NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,Digits);
   MaL=tv-NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,Digits);
   tvBuffer[_shift]=tv;
   ExtMapBuffer1[_shift]=MaH;
   ExtMapBuffer2[_shift]=MaL;
   SetMovingHnL(i, _shift);    
   
//----
   return;
  }
//+------------------------------------------------------------------+
//| ”становим MaH и MaL внутри диапазона                             |
//+------------------------------------------------------------------+
void SetMovingHnL(int _DelimeterBar,int CurBar)
  {
   double delta;
//---- 
   delta=(tvBuffer[_DelimeterBar]-tvBuffer[CurBar])/(_DelimeterBar-CurBar);
//----
   return;
  }
//+------------------------------------------------------------------+
//| ”становим MaH и MaL на правом краю                               |
//+------------------------------------------------------------------+
void SetValuesNullBar(int _shift)
  {
//---- 
   int i=_shift;
   while (tvBuffer[i]==0.0) i++;
   for (int j=i-1;j>_shift;j--)
      {
      ExtMapBuffer1[j]=0.0;
      ExtMapBuffer2[j]=0.0;
      }
   i=_shift;
   counterPeriod=0;
   while (counterPeriod<Ch_Period)
      {
      while (tvBuffer[i]==0.0 && i<Bars) i++;
      counterPeriod++;
      i++;
      }
   i--;   
   hh=Highest(NULL,0,MODE_HIGH,i-_shift,_shift);
   ll=Lowest(NULL,0,MODE_LOW,i-_shift,_shift);
   tv=NormalizeDouble((High[hh]+Low[ll]+Close[_shift])/3.0,Digits);
   MaH=tv+NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,Digits);
   MaL=tv-NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,Digits);
   ExtMapBuffer1[_shift]=MaH;
   ExtMapBuffer2[_shift]=MaL;
   //SetMovingHnL(j, _shift);    
//----
   return;
  }//-------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(3);
   if (SetAllBars)
      {
      SetIndexStyle(0,DRAW_LINE);
      SetIndexBuffer(0,ExtMapBuffer1);
      SetIndexLabel(0,"MaH");
      SetIndexEmptyValue(0,0.0);

      SetIndexStyle(1,DRAW_LINE);
      SetIndexBuffer(1,ExtMapBuffer2);
      SetIndexLabel(1,"MaL");
      SetIndexEmptyValue(1,0.0);
      }
   else
      {
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"MaH");
   SetIndexEmptyValue(0,0.0);

   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,"MaL");
   SetIndexEmptyValue(1,0.0);
      }

   SetIndexBuffer(2,tvBuffer);
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
   int    counted_bars=IndicatorCounted();
   int cnt,limit;

//---- 
   if (Period()==10080) return;
   if (counted_bars<0) return(-1);
   if (counted_bars>0) limit=Bars-counted_bars;
   if (counted_bars==0)
      {
      // найти первый и второй разделитель и установить limit
      cnt=Bars-1;
      while (!isDelimeter(Period(),cnt)) cnt--;
      first=cnt;
      cnt--;
      counterPeriod=0;
      while (counterPeriod<Ch_Period)
         {
         while (!isDelimeter(Period(),cnt)) cnt--;
         cnt--;
         counterPeriod++;
         }
      cnt++;
      hh=Highest(NULL,0,MODE_HIGH,first-cnt,cnt+1);
      ll=Lowest(NULL,0,MODE_LOW,first-cnt,cnt+1);
      tv=NormalizeDouble((High[hh]+Low[ll]+Close[cnt+1])/3.0,Digits);
      MaH=tv+NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,Digits);
      MaL=tv-NormalizeDouble((High[hh]-Low[ll])/2.0*Ratio,Digits);
      tvBuffer[cnt]=tv;
      ExtMapBuffer1[cnt]=MaH;
      ExtMapBuffer2[cnt]=MaL;
      limit=cnt-1;
      }   
//----
   for (int shift=limit;shift>=0;shift--)
      {
      if (isDelimeter(Period(),shift)) SetHnL(shift);// else SetMovingHnL(shift);
      if (shift==0) SetValuesNullBar(shift);
      }
      
   return(0);
  }
//+------------------------------------------------------------------+