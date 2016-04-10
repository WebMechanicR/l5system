//+------------------------------------------------------------------+
//|                                      cam_L1_L5_Historical_V4.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//| Modified to chart historical camarilla pivots by MrPip           |
//| 3/28/06 Fixed problem of Sunday/Monday pivots                    |
//|         and added some ideas from goodtiding5 (Kenneth Z.)       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2

//---- input parameters

extern int  GMTshift=0;
extern color LColor = Red;
extern int fontsize=10;
extern int LabelShift=20;

double L1Buffer[];
double L2Buffer[];
double L3Buffer[];
double L4Buffer[];
double L5Buffer[];

double L1, L2, L3, L4, L5;

double D1=0.091667;
double D2=0.183333;
double D3=0.2750;
double D4=0.55;

double prev_high=0;
double prev_low=0;
double prev_close=0;
double cur_day=0;
double prev_day=0;
double day_high=0;
double day_low=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(5);
//---- indicators
   SetIndexStyle(0,DRAW_LINE, 0,2,Red);
   SetIndexBuffer(0,L1Buffer);
   SetIndexStyle(1,DRAW_LINE, 0,2,Red);
   SetIndexBuffer(1,L2Buffer);
   SetIndexStyle(2,DRAW_LINE, 0,2,Red);
   SetIndexBuffer(2,L3Buffer);
   SetIndexStyle(3,DRAW_LINE, 0,2,Red);
   SetIndexBuffer(3,L4Buffer);
   SetIndexStyle(4,DRAW_LINE, 0, 2, Red);
   SetIndexBuffer(4,L5Buffer);
   
   SetIndexLabel(0,"L1");
   SetIndexLabel(1,"L2");
   SetIndexLabel(2,"L3");
   SetIndexLabel(3,"L4");
   SetIndexLabel(4,"L5");

   
//----
//   IndicatorShortName("Cam Pivots");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   ObjectDelete("SupL1");
   ObjectDelete("SupL2");
   ObjectDelete("SupL3");
   ObjectDelete("SupL4");
   ObjectDelete("SupL5");
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int cnt, limit;

//---- exit if period is greater than 4 hr charts
   if(Period() > 240)
   {
      Alert("Error - Chart period is greater than 4 Hr.");
      return(-1); // then exit
   }
   if(counted_bars<0) return(-1);

//---- last counted bar will be recounted
//   if(counted_bars>0) counted_bars--;

//   limit=(Bars-counted_bars)-1;
   limit=counted_bars;

//---- Get new daily prices & calculate pivots

   for (cnt=limit;cnt >=0;cnt--)
   {
   	if (TimeDayOfWeek(Time[cnt]) == 0)
	   {
        cur_day = prev_day;
	   }
	   else
	   {
        cur_day = TimeDay(Time[cnt]- (GMTshift*3600));
	   }
	   
   	if (prev_day != cur_day)
   	{
	   	prev_close = Close[cnt+1];
		   prev_high = day_high;
		   prev_low = day_low;

	      day_high = High[cnt];
 	      day_low  = Low[cnt];


L1 = prev_close - ((prev_high - prev_low)*(D1));
L2 = prev_close - ((prev_high - prev_low)*(D2));
L3 = prev_close - ((prev_high - prev_low)*(D3));
L4 = prev_close - ((prev_high - prev_low)*(D4));
L5 = prev_close - ((prev_high/prev_low)*prev_close - prev_close);

		   prev_day = cur_day;
	   }
      if (High[cnt]>day_high)
      {
         day_high = High[cnt];
      }
      if (Low[cnt]<day_low)
      {
         day_low = Low[cnt];
      }
      
      
      
//         day_low=Open[cnt]; day_high=Open[cnt];
      
      

//---  Draw  Pivot lines on chart

      L1Buffer[cnt]=L1;
      L2Buffer[cnt]=L2;
      L3Buffer[cnt]=L3;
      L4Buffer[cnt]=L4;
      L5Buffer[cnt]=L5;
      
   }

   if (cur_day == TimeDay(CurTime()))   DisplayLabels();
//----
   return(0);
  }

void DisplayLabels()
{
     datetime LabelShiftTime;
     LabelShiftTime = Time[LabelShift];
      
      if(ObjectFind("SupL1") != 0)
      {
      ObjectCreate("SupL1", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("SupL1", "      L 1",fontsize,"Arial",LColor);
      }
      else
      {
         ObjectMove("SupL1", 0, LabelShiftTime,L1);
      }
      
      if(ObjectFind("SupL2") != 0)
      {
      ObjectCreate("SupL2", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("SupL2", "      L 2",fontsize,"Arial",LColor);
      }
      else
      {
         ObjectMove("SupL2", 0, LabelShiftTime,L2);
      }
      
      if(ObjectFind("SupL3") != 0)
      {
      ObjectCreate("SupL3", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("SupL3", "      L 3",fontsize,"Arial",LColor);
      }
      else
      {
         ObjectMove("SupL3", 0, LabelShiftTime,L3);
      }
      
      if(ObjectFind("SupL4") != 0)
      {
      ObjectCreate("SupL4", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("SupL4", "      L 4",fontsize,"Arial",LColor);
      }
      else
      {
         ObjectMove("SupL4", 0, LabelShiftTime,L4);
      }
      
      if(ObjectFind("SupL5") != 0)
      {
      ObjectCreate("SupL5", OBJ_TEXT, 0, 0, 0);
      ObjectSetText("SupL5", "      L 5",fontsize,"Arial",LColor);
      }
      else
      {
         ObjectMove("SupL5", 0, LabelShiftTime,L5);
      }
      
}
//+------------------------------------------------------------------+