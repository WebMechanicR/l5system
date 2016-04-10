//+------------------------------------------------------------------+
//|                                                  ZZ MTF XO A.mq4 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright " ZZ MTF XO A "
#property link      " ZZ MTF XO A "

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 LimeGreen
#property indicator_color2 Red

#property indicator_maximum 1                     
#property indicator_minimum -1

extern int TimeFrame=0;
extern double KirPER=10;                            //10
//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
**************************************************************************/
//---- buffers

double ExtMapBuffer1[];
double ExtMapBuffer2[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,2);
   SetIndexBuffer(1,ExtMapBuffer2);


  
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
   }
   string short_name;
   short_name=("XO A("+TimeFrame+","+KirPER+")");
    IndicatorShortName(short_name);
     SetIndexLabel(0,short_name);  
  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                         |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();

// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars;
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++;

/***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/  
 
   ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"XO",KirPER,0,y);
   ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"XO",KirPER,1,y); 

   
   }  
   return(0);
  }
//+------------------------------------------------------------------+