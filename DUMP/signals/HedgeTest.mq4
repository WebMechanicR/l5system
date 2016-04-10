//+------------------------------------------------------------------+
//|                                              TimeZone Pivots.mq4 |
//|                                 Copyright © 2005,|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 DarkOrange
#property indicator_color2 Khaki
#property indicator_color3 Khaki
#property indicator_color4 Khaki
#property indicator_color5 Khaki


#property indicator_color6 DarkViolet
#property indicator_color7 Blue
#property indicator_color8 Red
//#property indicator_color4 Gray

//---- input parameters
extern int Offset=14; // Number of pips above/below days open price
extern int TimeZoneOfData=0; // by default if time zone of data is at GMT 0
                             

//---- buffers
double PivotArray[];
double R1Array[];
double S1Array[];
double R2Array[];
double S2Array[];
double R3Array[];
double S3Array[];

double TodayOpenBuffer[];
double YesterdayCloseBuffer[];
double YesterdayHighBuffer[];
double YesterdayLowBuffer[];


//---- variables
int indexbegin = 0;
double todayopen = 0;
double yesterdayclose = 0;

double barhigh = 0;
double dayhigh = 0;
double yesterdayhigh = 0;

double barlow = 0;
double daylow = 0;
double yesterdaylow = 0;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
	
	// Pivot
SetIndexStyle(0,DRAW_LINE);
SetIndexBuffer(0,PivotArray);
IndicatorShortName("TDPivot");
SetIndexLabel(0,"Pivot");
SetIndexEmptyValue(0, 0.0);
// Resistance 1
SetIndexStyle(1,DRAW_LINE);
SetIndexBuffer(1,R1Array);
SetIndexLabel(1,"R1");
SetIndexEmptyValue(1, 0.0);
// Support 1
SetIndexStyle(2,DRAW_LINE);
SetIndexBuffer(2,S1Array);
SetIndexLabel(2,"R1");
SetIndexEmptyValue(2, 0.0);
// Resistance 2
SetIndexStyle(3,DRAW_LINE);
SetIndexBuffer(3,R2Array);
SetIndexLabel(3,"R2");
SetIndexEmptyValue(3, 0.0);
// Support 2
SetIndexStyle(4,DRAW_LINE);
SetIndexBuffer(4,S2Array);
SetIndexLabel(4,"S2");
SetIndexEmptyValue(4, 0.0);

// You may also display the previous day close - high - low

//Daily Close	
SetIndexStyle(5, DRAW_LINE);
SetIndexBuffer(5, YesterdayCloseBuffer);
SetIndexLabel(5, "Yesterday Close");
SetIndexEmptyValue(5, 0.0);

// Daily High	
SetIndexStyle(6, DRAW_LINE);
SetIndexBuffer(6, YesterdayHighBuffer);
SetIndexLabel(6, "Low Target");
SetIndexEmptyValue(6, 0.0);	
	
// Daily Low	
SetIndexStyle(7, DRAW_LINE);
SetIndexBuffer(7, YesterdayLowBuffer);
SetIndexLabel(7, "High Target");
SetIndexEmptyValue(7, 0.0);
	

//----
	indexbegin = Bars - 20;
	if (indexbegin < 0)
		indexbegin = 0;
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
   int i;
  
	int counted_bars = IndicatorCounted();
	
	
double Pivot;
double R1;
double S1;
double R2;
double S2;
	
	//---- check for possible errors
	if (counted_bars < 0) counted_bars = 0;
	//---- last counted bar will be recounted
	if (counted_bars > 0) counted_bars--;
	if (counted_bars > indexbegin) counted_bars = indexbegin;


		for (i = indexbegin-counted_bars; i >= 0; i--)
		{ 
		
		   if ( i == indexbegin-counted_bars) 
		       {
		        dayhigh = High[i];
		        daylow = Low[i];
		       }
		       
		       barlow = Low[i];	
				 barhigh = High[i];
				 
			if ( barhigh >= dayhigh) 
			    dayhigh = barhigh;	 		
			
			if ( barlow <= daylow) 
			    daylow = barlow;
		
//Cycle through all the bars and fill the indicator bars with the Pivot point values		   
		
			if ((TimeMinute(Time[i]) == 00) && (TimeHour(Time[i]) - TimeZoneOfData == 00))
				{todayopen = Open[i];
				 yesterdayclose = Close[i+1];
				 yesterdaylow = daylow;
				 daylow = Low [i]; // input new day value
				
				 yesterdayhigh = dayhigh;
				 dayhigh = High [i]; // input new day value
				
				Pivot = (yesterdayhigh + yesterdaylow + yesterdayclose)/3;
            R1 = (2*Pivot)-yesterdaylow;
            S1 = (2*Pivot)-yesterdayhigh;
				
				 }
				
				//These can be used for any calculations 
				TodayOpenBuffer[i] = todayopen;
				YesterdayHighBuffer[i] = yesterdayclose-(Offset*Point);
				YesterdayLowBuffer[i] = yesterdayclose+(Offset*Point);				

	}

	
	return(0);
}
//+------------------------------------------------------------------+