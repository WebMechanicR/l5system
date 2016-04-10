//+------------------------------------------------------------------+
//|                                  StochasticONpricePriceVSwma.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "perky_z@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Violet
#property indicator_color2 Aqua
#property indicator_color3 Red
#property indicator_color4 LimeGreen


//---- input parameters


extern int K_Period=15;
extern int D_Period=3;
extern int Slowing=3;


int shift=0,  cnt=0,  prevbars=0,loopbegin=0;
double MAValue,Stoch;
double poynt=200; // for Jpy currencies
bool first=true;
double exStoch;
double oldexStoch;
//---- buffers
double TrendBuffer[];
double LoBuffer[];
double HiBuffer[];
double ExHi[];
double ExLo[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(4);
//---- indicator buffers
   SetIndexBuffer(0,TrendBuffer);
   SetIndexBuffer(1,LoBuffer);
   SetIndexBuffer(2,ExHi);
   SetIndexBuffer(3,ExLo);
   
    SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,Violet);
    SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,Aqua);
     SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,Red);
     SetIndexArrow(2,108);
    SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,LimeGreen);
    SetIndexArrow(3,108);
    IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Stochinchart("+")");
   
   SetIndexDrawBegin(0,TrendBuffer);
   SetIndexDrawBegin(1,LoBuffer);
   SetIndexDrawBegin(2,ExHi);
   SetIndexDrawBegin(3,ExLo);
   
   
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Average Directional Movement Index                               |
//+------------------------------------------------------------------+
int start()
  {
  if (Point*10000==1) poynt=10000;
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
	
  int bars_count=50;
  double hl1,hl2,hl;
  hl1=High[Highest(NULL,0,MODE_HIGH,bars_count,1)];
  hl2=Low[Lowest(NULL,0,MODE_LOW,bars_count,1)];
  hl= (hl1+hl2)/2;

//Comment (bars_count,"hl",hl,"hl1 ",hl1,"hl2 ",hl2,"POINT ",Point*10000);

	TrendBuffer[shift]=((((iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_SIGNAL,shift)-50)))/poynt+hl);
	LoBuffer[shift]= ((((iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,shift)-50)))/poynt+hl);
	exStoch=iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,shift);
	oldexStoch=iStochastic(NULL,0,K_Period,D_Period,Slowing,MODE_SMA,0,MODE_MAIN,shift+1);
//	Comment (exStoch);
	if (exStoch<80&& oldexStoch>80)
	{
	ExHi[shift]=TrendBuffer[shift];//High[shift];
	}
	if (exStoch>20 && oldexStoch<20)
	{
	 ExLo[shift]= LoBuffer[shift] ;//Low[shift];
	}
	
	loopbegin = loopbegin-1;
	     
	}}
	return(0);
	    // prevent to previous bars recounting

