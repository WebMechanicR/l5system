//+------------------------------------------------------------------+
//|                                                     Renko_v1.mq4 |
//|                           Copyright © 2005, TrendLaboratory Ltd. |
//|                                       E-mail: igorad2004@list.ru |
//|                                            Many Thanks To Konkop |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "E-mail: igorad2004@list.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Magenta
//---- input parameters
extern int PeriodATR=10;
extern double Katr=1.00;
//---- indicator buffers
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
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="Renko("+PeriodATR+","+Katr+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Renko");
//----
   SetIndexDrawBegin(0,PeriodATR);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Renko_v1                                                        |
//+------------------------------------------------------------------+
int start()
  {
   int i,shift;
   double Up,Dn,Brick,AvgRange,dK,ATR,BrickUp,BrickDn;
	
   for(shift=Bars-1-PeriodATR;shift>=0;shift--)
   {	
	AvgRange=0;
	for (i=PeriodATR-1;i>=0;i--)
	    { 
       dK = 1;
       AvgRange+=dK*MathAbs(High[i+shift]-Low[i+shift]);
       }
	ATR = AvgRange/PeriodATR;
	
	if (shift==Bars-1-PeriodATR)
	{
	Up=High[shift];
	Dn=Low[shift];
	Brick=Katr*(High[shift]-Low[shift]);
	} 
	
	if (shift<Bars-1-PeriodATR)  
	{
		if (Close[shift] > Up + Brick)
		{
		if (Brick==0) 
		BrickUp=0;
		else
		BrickUp=MathRound((Close[shift]-Up)/Brick)*Brick;	
		
		Up = Up + BrickUp;
		Brick = Katr*ATR;
		Dn = Up - Brick;
		BrickDn = 0;
		}
		
		if (Close[shift] < Dn - Brick) 
		{
		if (Brick==0) 
		BrickDn=0;
		else
		BrickDn=MathRound((Dn-Close[shift])/Brick)*Brick;
		
		Dn = Dn - BrickDn;
		Brick = Katr*ATR;
		Up = Dn + Brick;
		BrickUp = 0;
		}
	}
	UpBuffer[shift]=Up;
	DnBuffer[shift]=Dn;
	}	
	return(0);	
 }

