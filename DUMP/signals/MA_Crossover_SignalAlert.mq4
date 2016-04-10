//+------------------------------------------------------------------+
//|                                     MA-Crossover_SignalAlert.mq4 |
//|         Copyright © 2006, Robert Hill                            |
//+------------------------------------------------------------------+

/*
  +------------------------------------------------------------------+
  | Allows you to enter two ema periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the emas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/   
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LawnGreen
#property indicator_color2 Red
#property indicator_width1 3
#property indicator_width2 3

extern bool SoundON=true;
extern bool EmailON=false;

extern int FasterMode = 1; //0=sma, 1=ema, 2=smma, 3=lwma, 4=lsma
extern int FasterMA =   7;
extern int FasterPriceMode = 0;//0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2, 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4
extern int SlowerMode = 1; //0=sma, 1=ema, 2=smma, 3=lwma, 4=lsma
extern int SlowerMA =   16;
extern int SlowerPriceMode = 0;//0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2, 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4
double CrossUp[];
double CrossDown[];
int flagval1 = 0;
int flagval2 = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 3);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 3);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
   GlobalVariableSet("AlertTime"+Symbol()+Period(),CurTime());
   GlobalVariableSet("SignalType"+Symbol()+Period(),OP_SELLSTOP);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   GlobalVariableDel("AlertTime"+Symbol()+Period());
   GlobalVariableDel("SignalType"+Symbol()+Period());
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| LSMA with PriceMode                                              |
//| PrMode  0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2,    |
//| 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4  |
//+------------------------------------------------------------------+

double LSMA(int Rperiod, int prMode, int shift)
{
   int i;
   double sum, pr;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     switch (prMode)
     {
     case 0: pr = Close[length-i+shift];break;
     case 1: pr = Open[length-i+shift];break;
     case 2: pr = High[length-i+shift];break;
     case 3: pr = Low[length-i+shift];break;
     case 4: pr = (High[length-i+shift] + Low[length-i+shift])/2;break;
     case 5: pr = (High[length-i+shift] + Low[length-i+shift] + Close[length-i+shift])/3;break;
     case 6: pr = (High[length-i+shift] + Low[length-i+shift] + Close[length-i+shift] + Close[length-i+shift])/4;break;
     }
     tmp = ( i - lengthvar)*pr;
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double fasterMAnow, slowerMAnow, fasterMAprevious, slowerMAprevious, fasterMAafter, slowerMAafter;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      if (FasterMode == 4)
      {
         fasterMAnow = LSMA(FasterMA, FasterPriceMode, i);
         fasterMAprevious = LSMA(FasterMA, FasterPriceMode,  i+1);
         fasterMAafter = LSMA(FasterMA, FasterPriceMode, i-1);
         
      }
      else
      {
         fasterMAnow = iMA(NULL, 0, FasterMA, 0, FasterMode, FasterPriceMode, i);
         fasterMAprevious = iMA(NULL, 0, FasterMA, 0, FasterMode, FasterPriceMode, i+1);
         fasterMAafter = iMA(NULL, 0, FasterMA, 0, FasterMode, FasterPriceMode, i-1);
      }

      if (SlowerMode == 4)
      {
         slowerMAnow = LSMA( SlowerMA, SlowerPriceMode, i);
         slowerMAprevious = LSMA( SlowerMA, SlowerPriceMode, i+1);
         slowerMAafter = LSMA( SlowerMA, SlowerPriceMode, i-1);
      }
      else
      {
         slowerMAnow = iMA(NULL, 0, SlowerMA, 0, SlowerMode, SlowerPriceMode, i);
         slowerMAprevious = iMA(NULL, 0, SlowerMA, 0, SlowerMode, SlowerPriceMode, i+1);
         slowerMAafter = iMA(NULL, 0, SlowerMA, 0, SlowerMode, SlowerPriceMode, i-1);
      }
      
      FastMA[i] = fasterMAnow;
      SlowMA[i] = slowerMAnow;
      if ((fasterMAnow > slowerMAnow) && (fasterMAprevious < slowerMAprevious) && (fasterMAafter > slowerMAafter))
      {
//         if (CheckTime2())
//         {
         CrossUp[i] = Low[i] - Range*0.75;
         if ( alertTag!=Time[0])
         {
          PlaySound("news.wav");// buy wav
          Alert(Symbol(),"  M",Period()," MA cross BUY");
         }
          alertTag = Time[0];
//          }
          
      }
      else if ((fasterMAnow < slowerMAnow) && (fasterMAprevious > slowerMAprevious) && (fasterMAafter < slowerMAafter))
      {
//         if (CheckTime2())
//         {
         CrossDown[i] = High[i] + Range*0.75;
         if ( alertTag!=Time[0])
         {
          PlaySound("news.wav"); //sell wav
           Alert(Symbol(),"  M",Period()," MA cross SELL");
         }
          alertTag = Time[0];
//         }
      }
   }
   return(0);
}

bool CheckTime1()
{
  if (CurTime() >= StrToTime(Start1) && CurTime() <= StrToTime(Stop1)) return(true);
  return(false);
  
}

bool CheckTime2()
{
  if (CurTime() >= StrToTime(Start2) && CurTime() <= StrToTime(Stop2)) return(true);
  return(false);
  
}


