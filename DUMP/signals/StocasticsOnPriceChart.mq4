//+------------------------------------------------------------------+
//|                                  StochasticONpricePriceVSwma.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "perky_z@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Violet
#property indicator_color2 Aqua


//---- input parameters


extern int K_Period=5;
extern int D_Period=3;
extern int Slowing=3;


int shift=0,  cnt=0,  prevbars=0,loopbegin=0;
double MAValue,Stoch;
bool first=true;
//---- buffers
double TrendBuffer[];
double LoBuffer[];
double HiBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(3);
//---- indicator buffers
   SetIndexBuffer(0,TrendBuffer);
   SetIndexBuffer(1,LoBuffer);
   
    SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,Yellow);
    SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,Aqua);
    IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Stochinchart("+")");
   
   SetIndexDrawBegin(0,TrendBuffer);
   SetIndexDrawBegin(1,LoBuffer);
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Average Directional Movement Index                               |
//+------------------------------------------------------------------+
int start()
  {
  // initial checkings
// check for additional bars loading or total reloading
if (Bars < prevbars )  first = true;
if (Bars-prevbars>1) first = true;
prevbars = Bars;
if (first) 
{
	// loopbegin prevent couning of counted bars exclude current
	loopbegin = Bars-1;
	if (loopbegin < 0) return(0);      // not enough bars for counting
	
	
	first = False;
   }
  
 
  loopbegin = loopbegin+1; 
             // current bar is to be recounted too
  for (shift = loopbegin; shift>= 0 ;shift--)
	{
	
  int bars_count=BarsPerWindow();
  double hl1,hl2,hl;
  hl1=High[Highest(NULL,0,MODE_HIGH,bars_count,1)];
  hl2=Low[Lowest(NULL,0,MODE_LOW,bars_count,1)];
  hl= (hl1+hl2)/2;

//Comment (bars_count,"hl",hl,"hl1 ",hl1,"hl2 ",hl2);

	TrendBuffer[shift]=((((iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,shift))-50))/10000+hl);
	LoBuffer[shift]= ((((iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,shift))-50))/10000+hl);
	loopbegin = loopbegin-1;     
	}}
	return(0);
	    // prevent to previous bars recounting

