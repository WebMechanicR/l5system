//+------------------------------------------------------------------+
//| 4Hour Vegas Model - Weekly Chart Direction Calculator            |
//|                                                           Spiggy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Spiggy"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

//---- input parameters

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ExtMapBuffer3);

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
  int    limit;
  double EMA21;
  double SMA5;
  double EMA21Prev;
  double SMA5Prev;
  string ValueIndex;
  string Direction;
   
  // Always prepare all of the information for the other indicators
  limit=Bars;
  
  //---- main loop
  for(int i=limit; i>=0; i--)
  {
    //---- Calculate the current weekly trend
    EMA21=iMA(NULL,0,21,0,MODE_EMA,(PRICE_HIGH+PRICE_LOW)/2,i);
    SMA5 =iMA(NULL,0,5,0,MODE_SMA,(PRICE_HIGH+PRICE_LOW)/2,i);
         
    //---- Calculate the previous weekly trend
    EMA21Prev=iMA(NULL,0,21,0,MODE_EMA,(PRICE_HIGH+PRICE_LOW)/2,i+1);
    SMA5Prev =iMA(NULL,0,5,0,MODE_SMA,(PRICE_HIGH+PRICE_LOW)/2,i+1);

    // Calculate the difference of the MAs
    ExtMapBuffer1[i] = SMA5-EMA21;

    // Calculate the difference of the MAs
    if (((SMA5-EMA21) - (SMA5Prev-EMA21Prev)) > 0.0 )
    {
      ExtMapBuffer2[i] = (SMA5-EMA21) - (SMA5Prev-EMA21Prev);
      ExtMapBuffer3[i] = 0.0;
      Direction = "UP";
    }
    
    if (((SMA5-EMA21) - (SMA5Prev-EMA21Prev)) < 0.0 )
    {
      ExtMapBuffer2[i] = 0.0;
      ExtMapBuffer3[i] = (SMA5-EMA21) - (SMA5Prev-EMA21Prev);
      Direction = "DOWN";
    }
    
    // Calculate the start of the week and publish the value in a global variable
    // Publish this with the previous Sunday as the index
    ValueIndex = TimeToStr(Time[i]-TimeDayOfWeek(Time[i]),TIME_DATE);
    Comment(Symbol() + "-ThisWeekDirection-" + ValueIndex + "\n" + Direction + ":(" + ((SMA5-EMA21) - (SMA5Prev-EMA21Prev)) + ")");
    GlobalVariableSet(Symbol() + "-ThisWeekDirection-" + ValueIndex, ((SMA5-EMA21) - (SMA5Prev-EMA21Prev)));

  }
         
   return(0);
  }
//+------------------------------------------------------------------+