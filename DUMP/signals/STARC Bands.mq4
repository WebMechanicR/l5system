//+------------------------------------------------------------------+
//| STARCBands.mq4                                                   |
//| Copyright © 2005, scorpion@fxfisherman.com                       |
//| http://www.fxfisherman.com/                                      |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, scorpion@fxfisherman.com"
#property link "http://www.fxfisherman.com/"

#property indicator_chart_window
#property indicator_buffers 3

//---- indicator parameters
extern int MA_Period=6;
extern int ATR_Period=15;
extern double KATR=2;
extern int Shift=1;
extern color UpperColor=Red;
extern color MiddleColor=White;
extern color LowerColor=Red;

//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
  //---- indicators
  SetIndexStyle(0,DRAW_LINE,0,1,MiddleColor);
  SetIndexBuffer(0,MovingBuffer);
  SetIndexStyle(1,DRAW_LINE,0,1,UpperColor);
  SetIndexBuffer(1,UpperBuffer);
  SetIndexStyle(2,DRAW_LINE,0,1,LowerColor);
  SetIndexBuffer(2,LowerBuffer);
  //----
  SetIndexDrawBegin(0,MA_Period+Shift);
  SetIndexDrawBegin(1,ATR_Period+Shift);
  SetIndexDrawBegin(2,ATR_Period+Shift);
  //----
  return(0);
}

//+------------------------------------------------------------------+
//| Bollinger Bands |
//+------------------------------------------------------------------+
int start()
{
  int i,k,counted_bars=IndicatorCounted();
  
  //----
  if(Bars<=MA_Period) return(0);
  
  //---- initial zero
  if(counted_bars<1)
  for(i=1;i<=MA_Period;i++)
  {
    MovingBuffer[Bars-i]=EMPTY_VALUE;
    UpperBuffer[Bars-i]=EMPTY_VALUE;
    LowerBuffer[Bars-i]=EMPTY_VALUE;
  }
  
  //----
  int limit=Bars-counted_bars;
  if(counted_bars>0) limit++;
  for(i=0; i<limit; i++)
  {
    MovingBuffer[i] = iMA(NULL,0,MA_Period,Shift,MODE_EMA,PRICE_CLOSE,i);
    UpperBuffer[i] = MovingBuffer[i] + (KATR * iATR(NULL,0,ATR_Period,i+Shift));
    LowerBuffer[i] = MovingBuffer[i] - (KATR * iATR(NULL,0,ATR_Period,i+Shift));
  }
  
  //----
  return(0);
}

//+----------scorpion@fxfisherman.com--------------------------------+