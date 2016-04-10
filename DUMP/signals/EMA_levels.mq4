//+------------------------------------------------------------------+
//|                                                  EMABands_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Silver
#property indicator_color3 Silver

//---- input parameters
extern int RPeriod=25;
extern int MA_mode=1;
extern int OffSet=40;

//---- indicator buffers
double MABuffer[];
double UpBuffer[];
double DnBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);

   SetIndexBuffer(0,MABuffer);
   SetIndexBuffer(1,UpBuffer);
   SetIndexBuffer(2,DnBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="EMA_levels("+RPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"MA");
   SetIndexLabel(1,"Up");
   SetIndexLabel(2,"Dn");
//----
   SetIndexDrawBegin(0,RPeriod);
   SetIndexDrawBegin(1,RPeriod);
   SetIndexDrawBegin(2,RPeriod);
   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| EMA_Levels                                                       |
//+------------------------------------------------------------------+
int start()
  {
   
   int shift,limit, counted_bars=IndicatorCounted();
   
   if ( counted_bars > 0 )  limit=Bars-counted_bars;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit=Bars-RPeriod-1; 
     
	for(shift=limit;shift>=0;shift--) 
   {	
   MABuffer[shift] = iMA(NULL,0,RPeriod,0,MA_mode,PRICE_CLOSE,shift);
   UpBuffer[shift] = MABuffer[shift] + OffSet*Point;
   DnBuffer[shift] = MABuffer[shift] - OffSet*Point;
	}
	return(0);	
 }

