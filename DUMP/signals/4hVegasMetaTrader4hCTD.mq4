//+------------------------------------------------------------------+
//| 4Hour Vegas Model - 4 Hour Chart Direction Indicator             |
//|                                                           Spiggy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Spiggy"
#property link      ""

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue


//---- input parameters

//---- buffers
double ExtMapBuffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);

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
  int    counted_bars=IndicatorCounted();
  double SMA55;
  double SMA8;
  string ValueIndex;
  string Direction;
   
  limit=Bars;
  //---- main loop
  for(int i=0; i<limit; i++)
  {
    Direction = "----"; 
    ValueIndex = TimeToStr(Time[i]-(TimeDayOfWeek(Time[i])*86400),TIME_DATE);
    if ( GlobalVariableGet(Symbol() + "-ThisWeekDirection-" + ValueIndex) > 0.0 ) 
    {
      Direction = "UP";
    }
    
    if ( GlobalVariableGet(Symbol() + "-ThisWeekDirection-" + ValueIndex) < 0.0 )
    {
      Direction = "DOWN";
    }
    
    ExtMapBuffer1[i] = 0;

    if ( Direction == "UP" )
    {
      ExtMapBuffer1[i] = 1;
    }

    if ( Direction == "DOWN" )
    {
      ExtMapBuffer1[i] = -1;
    }
    
  }

   return(0);
  }
//+------------------------------------------------------------------+