//+------------------------------------------------------------------+
//| TD Sequential.mq4 |
//| Copyright © 2004, MetaQuotes Software Corp. |
//| http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "James OBrien"
#property link "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 LimeGreen
//#property indicator_color2 Red
//---- input parameters
//int shift=0;
int i;
int num=0;
int num1=0;
string textVar;
//---- buffers
double ExtMapBuffer1[];
//double ExtMapBuffer2[];

//double b4plusdi,b4minusdi,nowplusdi,nowminusdi;

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators

SetIndexStyle(0,DRAW_ARROW);
SetIndexArrow(0,159);
SetIndexBuffer(0, ExtMapBuffer1);
/*
SetIndexStyle(1,DRAW_ARROW,EMPTY);
SetIndexArrow(1,234);
SetIndexBuffer(1, ExtMapBuffer2);
*/
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//---- TODO: add your code here
int limit;
limit=1500;
for(int i=limit; i>=0; i--)
{
	ObjectDelete(""+i);
}	

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int limit;
int counted_bars=IndicatorCounted();
//---- check for possible errors
if(counted_bars<0) return(-1);

//---- last counted bar will be recounted
if(counted_bars>0) counted_bars--;
limit=1500-counted_bars;
//---- macd counted in the 1-st buffer



for(int i=limit; i>=0; i--)
{
if(Close[i+1]<Close[i+5])num = num + 1; 
else num = 0;	
	if (num > 0 && num < 10) {
		textVar = num;
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num,0), 10, "Arial", Red);
		}
		if (num == 9) {
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num,0), 16, "Arial", Red);
      }				
		else if((Close[i+1]<Close[i+5])&& num>=10)
		{
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],Low[i+1]-5*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num,0), 10, "Arial", Orange);				
		}
	

if(Close[i+1]>Close[i+5]) num1 = num1 + 1; 
else num1 = 0;

	if (num1 > 0 && num1 < 10) 
	   {
		textVar = num1;
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num1,0), 10, "Arial", RoyalBlue);
		}
		if (num1 == 9) {
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num1,0), 16, "Arial", RoyalBlue);
      }				
		else if((Close[i+1]>Close[i+5])&& num1>=10)
		{
		ObjectCreate(""+i, OBJ_TEXT, 0, Time[i+1],High[i+1]+10*Point );
      ObjectSetText(""+i, ""+DoubleToStr(num1,0), 10, "Arial", LightSkyBlue);
					
		}
  
  	
}

//----
return(0);
}




