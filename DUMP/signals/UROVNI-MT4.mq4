//+------------------------------------------------------------------+
//|                                                        Pivot.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window

extern bool pivots = true;
extern bool camarilla = true;
extern bool midpivots = true;

double day_high=0;
double day_low=0;
double yesterday_high=0;
double yesterday_open=0;
double yesterday_low=0;
double yesterday_close=0;
double today_open=0;
double today_high=0;
double today_low=0;
double P=0;
double Q=0;
double R1,R2,R3;
double S2.5,S1.5,S0.5,R0.5,R1.5,R2.5;
double S1,S2,S3;
double nQ=0;
double nD=0;
double D=0;
double rates_d1[2][6];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
 R1=0; R2=0; R3=0;
 S2.5=0; S1.5=0; S0.5=0; R0.5=0; R1.5=0; R2.5=0;
 S1=0; S2=0; S3=0;
 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
ObjectDelete("R1 Label"); 
ObjectDelete("R1 Line");
ObjectDelete("R2 Label");
ObjectDelete("R2 Line");
ObjectDelete("R3 Label");
ObjectDelete("R3 Line");
ObjectDelete("S1 Label");
ObjectDelete("S1 Line");
ObjectDelete("S2 Label");
ObjectDelete("S2 Line");
ObjectDelete("S3 Label");
ObjectDelete("S3 Line");
ObjectDelete("P Label");
ObjectDelete("P Line");
ObjectDelete("R2.5 Label");
ObjectDelete("R2.5 Line");
ObjectDelete("R1.5 Label");
ObjectDelete("R1.5 Line");
ObjectDelete("R0.5 Label");
ObjectDelete("R0.5 Line");
ObjectDelete("S0.5 Label");
ObjectDelete("S0.5 Line");
ObjectDelete("S1.5 Label");
ObjectDelete("S1.5 Line");
ObjectDelete("S2.5 Label");
ObjectDelete("S2.5 Line");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//---- TODO: add your code here
//---- exit if period is greater than daily charts
if(Period() > 1440)
{
Print("Error - Chart period is greater than 1 day.");
return(-1); // then exit
}
//---- Get new daily prices
ArrayCopyRates(rates_d1, Symbol(), PERIOD_D1);

yesterday_close = rates_d1[1][4];
yesterday_open = rates_d1[1][1];
today_open = rates_d1[0][1];
yesterday_high = rates_d1[1][3];
yesterday_low = rates_d1[1][2];
day_high = rates_d1[0][3];
day_low = rates_d1[0][2];
//---- Calculate Pivots

D = (day_high - day_low);
Q = (yesterday_high - yesterday_low);
P = (yesterday_high + yesterday_low + yesterday_close) / 3;
R1 = (2*P)-yesterday_low;
S1 = (2*P)-yesterday_high;
R2 = P+(yesterday_high - yesterday_low);
S2 = P-(yesterday_high - yesterday_low);

	//H4 = (Q*0.55)+yesterday_close;
	//H3 = (Q*0.27)+yesterday_close;
	R3 = (2*P)+(yesterday_high-(2*yesterday_low));
	R2.5 = (R2+R3)/2;
	R1.5 = (R1+R2)/2;
	R0.5 = (P+R1)/2;
	S0.5 = (P+S1)/2;
	S1.5 = (S1+S2)/2;
	S3 = (2*P)-((2* yesterday_high)-yesterday_low);
	//L3 = yesterday_close-(Q*0.27);	
	//L4 = yesterday_close-(Q*0.55);	
	S2.5 = (S2+S3)/2;
if (Q > 5) 
{
	nQ = Q;
}
else
{
	nQ = Q*10000;
}

if (D > 5)
{
	nD = D;
}
else
{
	nD = D*10000;
}
Comment("High= ",yesterday_high,"    Previous Days Range= ",nQ,"\nLow= ",yesterday_low,"    Current Days Range= ",nD,"\nClose= ",yesterday_close);
//---- Set line labels on chart window
//---- Pivot Lines
   if (pivots==true)
   {
      if(ObjectFind("R1 label") != 0)
      {
      ObjectCreate("R1 label", OBJ_TEXT, 0, Time[20], R1);
      ObjectSetText("R1 label", " R1", 8, "Arial", White);
      }
      else
      {
      ObjectMove("R1 label", 0, Time[20], R1);
      }
      if(ObjectFind("R2 label") != 0)
      {
      ObjectCreate("R2 label", OBJ_TEXT, 0, Time[20], R2);
      ObjectSetText("R2 label", " R2", 8, "Arial", White);
      }
      else
      {
      ObjectMove("R2 label", 0, Time[20], R2);
      }
      if(ObjectFind("R3 label") != 0)
      {
      ObjectCreate("R3 label", OBJ_TEXT, 0, Time[20], R3);
      ObjectSetText("R3 label", " R3", 8, "Arial", White);
      }
      else
      {
      ObjectMove("R3 label", 0, Time[20], R3);
      }
      if(ObjectFind("P label") != 0)
      {
      ObjectCreate("P label", OBJ_TEXT, 0, Time[20], P);
      ObjectSetText("P label", "Pivot", 8, "Arial", White);
      }
      else
      {
      ObjectMove("P label", 0, Time[20], P);
      }
      if(ObjectFind("S1 label") != 0)
      {
      ObjectCreate("S1 label", OBJ_TEXT, 0, Time[20], S1);
      ObjectSetText("S1 label", "S1", 8, "Arial", White);
      }
      else
      {
      ObjectMove("S1 label", 0, Time[20], S1);
      }
      if(ObjectFind("S2 label") != 0)
      {
      ObjectCreate("S2 label", OBJ_TEXT, 0, Time[20], S2);
      ObjectSetText("S2 label", "S2", 8, "Arial", White);
      }
      else
      {
      ObjectMove("S2 label", 0, Time[20], S2);
      }
      if(ObjectFind("S3 label") != 0)
      {
      ObjectCreate("S3 label", OBJ_TEXT, 0, Time[20], S3);
      ObjectSetText("S3 label", "S3", 8, "Arial", White);
      }
      else
      {
      ObjectMove("S3 label", 0, Time[20], S3);
      }
//---  Draw  Pivot lines on chart
      if(ObjectFind("S1 line") != 0)
      {
      ObjectCreate("S1 line", OBJ_HLINE, 0, Time[40], S1);
      ObjectSet("S1 line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("S1 line", OBJPROP_COLOR, Red);
      }
      else
      {
      ObjectMove("S1 line", 0, Time[40], S1);
      }
      if(ObjectFind("S2 line") != 0)
      {
      ObjectCreate("S2 line", OBJ_HLINE, 0, Time[40], S2);
      ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("S2 line", OBJPROP_COLOR, Red);
      }
      else
      {
      ObjectMove("S2 line", 0, Time[40], S2);
      }
      if(ObjectFind("S3 line") != 0)
      {
      ObjectCreate("S3 line", OBJ_HLINE, 0, Time[40], S3);
      ObjectSet("S3 line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("S3 line", OBJPROP_COLOR, Red);
      }
      else
      {
      ObjectMove("S3 line", 0, Time[40], S3);
      }
      if(ObjectFind("P line") != 0)
      {
      ObjectCreate("P line", OBJ_HLINE, 0, Time[40], P);
      ObjectSet("P line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("P line", OBJPROP_COLOR, Magenta);
      }
      else
      {
      ObjectMove("P line", 0, Time[40], P);
      }
      if(ObjectFind("R1 line") != 0)
      {
      ObjectCreate("R1 line", OBJ_HLINE, 0, Time[40], R1);
      ObjectSet("R1 line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("R1 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("R1 line", 0, Time[40], R1);
      }
      if(ObjectFind("R2 line") != 0)
      {
      ObjectCreate("R2 line", OBJ_HLINE, 0, Time[40], R2);
      ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("R2 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("R2 line", 0, Time[40], R2);
      }
      if(ObjectFind("R3 line") != 0)
      {
      ObjectCreate("R3 line", OBJ_HLINE, 0, Time[40], R3);
      ObjectSet("R3 line", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("R3 line", OBJPROP_COLOR, LimeGreen);
      }
      else
      {
      ObjectMove("R3 line", 0, Time[40], R3);
      }
   }
//---- End of Pivot Line Draw 
//----- Camarilla Lines
   
//---- Draw Camarilla lines on Chart
     
//-------End of Draw Camarilla Lines
//------ Midpoints Pivots 
   if (midpivots==true)
   {
      if(ObjectFind("R2.5 label") != 0)
      {
      ObjectCreate("R2.5 label", OBJ_TEXT, 0, Time[20], R2.5);
      ObjectSetText("R2.5 label", " R2.5", 8, "Arial", White);
      }
      else
      {
      ObjectMove("R2.5 label", 0, Time[20], R2.5);
      }
      if(ObjectFind("R1.5 label") != 0)
      {
      ObjectCreate("R1.5 label", OBJ_TEXT, 0, Time[20], R1.5);
      ObjectSetText("R1.5 label", " R1.5", 8, "Arial", White);
      }
      else
      {
      ObjectMove("R1.5 label", 0, Time[20], R1.5);
      }
      if(ObjectFind("R0.5 label") != 0)
      {
      ObjectCreate("R0.5 label", OBJ_TEXT, 0, Time[20], R0.5);
      ObjectSetText("R0.5 label", " R0.5", 8, "Arial", White);
      }
      else
      {
      ObjectMove("R0.5 label", 0, Time[20], R0.5);
      }
      if(ObjectFind("S0.5 label") != 0)
      {
      ObjectCreate("S0.5 label", OBJ_TEXT, 0, Time[20], S0.5);
      ObjectSetText("S0.5 label", " S0.5", 8, "Arial", White);
      }
      else
      {
      ObjectMove("S0.5 label", 0, Time[20], S0.5);
      }
      if(ObjectFind("S1.5 label") != 0)
      {
      ObjectCreate("S1.5 label", OBJ_TEXT, 0, Time[20], S1.5);
      ObjectSetText("S1.5 label", " S1.5", 8, "Arial", White);
      }
      else
      {
      ObjectMove("S1.5 label", 0, Time[20], S1.5);
      }
      if(ObjectFind("S2.5 label") != 0)
      {
      ObjectCreate("S2.5 label", OBJ_TEXT, 0, Time[20], S2.5);
      ObjectSetText("S2.5 label", " S2.5", 8, "Arial", White);
      }
      else
      {
      ObjectMove("S2.5 label", 0, Time[20], S2.5);
      }
//---- Draw Midpoint Pivots on Chart
      if(ObjectFind("R2.5 line") != 0)
      {
      ObjectCreate("R2.5 line", OBJ_HLINE, 0, Time[40], R2.5);
      ObjectSet("R2.5 line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("R2.5 line", OBJPROP_COLOR, YellowGreen);
      }
      else
      {
      ObjectMove("R2.5 line", 0, Time[40], R2.5);
      }
      if(ObjectFind("R1.5 line") != 0)
      {
      ObjectCreate("R1.5 line", OBJ_HLINE, 0, Time[40], R1.5);
      ObjectSet("R1.5 line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("R1.5 line", OBJPROP_COLOR, YellowGreen);
      }
      else
      {
      ObjectMove("R1.5 line", 0, Time[40], R1.5);
      }
      if(ObjectFind("R0.5 line") != 0)
      {
      ObjectCreate("R0.5 line", OBJ_HLINE, 0, Time[40], R0.5);
      ObjectSet("R0.5 line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("R0.5 line", OBJPROP_COLOR, YellowGreen);
      }
      else
      {
      ObjectMove("R0.5 line", 0, Time[40], R0.5);
      }
      if(ObjectFind("S0.5 line") != 0)
      {
      ObjectCreate("S0.5 line", OBJ_HLINE, 0, Time[40], S0.5);
      ObjectSet("S0.5 line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("S0.5 line", OBJPROP_COLOR, Tomato);
      }
      else
      {
      ObjectMove("S0.5 line", 0, Time[40], S0.5);
      }
      if(ObjectFind("S1.5 line") != 0)
      {
      ObjectCreate("S1.5 line", OBJ_HLINE, 0, Time[40], S1.5);
      ObjectSet("S1.5 line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("S1.5 line", OBJPROP_COLOR, Tomato);
      }
      else
      {
      ObjectMove("S1.5 line", 0, Time[40], S1.5);
      }
      if(ObjectFind("S2.5 line") != 0)
      {
      ObjectCreate("S2.5 line", OBJ_HLINE, 0, Time[40], S2.5);
      ObjectSet("S2.5 line", OBJPROP_STYLE, STYLE_DOT);
      ObjectSet("S2.5 line", OBJPROP_COLOR, Tomato);
      }
      else
      {
      ObjectMove("S2.5 line", 0, Time[40], S2.5);
      }
   }
//----End of Midpoint Pivots Draw
//---- End Of Program
   return(0);
  }
//+------------------------------------------------------------------+