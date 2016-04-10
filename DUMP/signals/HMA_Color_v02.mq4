//+----------------+
//| HMA.mq4  by Ron|
//+----------------+

/*
MetaStock Formula
period:=Input("Period",1,200,20) ;
sqrtperiod:=Input("Square Root of Period",1,20,4);
Mov(2*(Mov(C,period/2,W))-Mov(C,period,W),sqrtperiod,W); 

SuperCharts Formula
Input: period (Default value 20)
waverage(2*waverage(close,period/2)-waverage(close,period), SquareRoot(Period)) 

Added color on direction change

*/


#property copyright "Ron Thompson"
#property link "http://www.metaquotes.net/"

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 3

#property indicator_color1 LimeGreen
#property indicator_color2 Yellow
#property indicator_color3 Red

//User input
extern int HMA_Period=14;

//---- indicator buffers
double ind_buffer0[];
double ind_buffer1[];
double ind_buffer2[];

double buffer[];

int draw_begin0;


//Custom init
int init()
{
//---- indicator buffers mapping
IndicatorBuffers(4);

if(   !SetIndexBuffer(0,ind_buffer0) 
   && !SetIndexBuffer(1,ind_buffer1)
   && !SetIndexBuffer(2,ind_buffer2) 
   && !SetIndexBuffer(3, buffer))
      Print("cannot set indicator buffers!");
// ArraySetAsSeries(ind_buffer1,true);

//---- drawing settings
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);

draw_begin0=HMA_Period+MathFloor(MathSqrt(HMA_Period));

SetIndexDrawBegin(0,draw_begin0);
SetIndexDrawBegin(1,draw_begin0);
SetIndexDrawBegin(2,draw_begin0);

IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);

//---- name for DataWindow and indicator subwindow label
IndicatorShortName("HMA("+HMA_Period+")");
SetIndexLabel(0,"Hull Moving Average");

}


// Main Program loop
int start()
  {
   int limit,i;
   int counted_bars=IndicatorCounted();
   double tmp, tmpPrevious;
   
   double fullMA;
   double halfMA;
   
   int fullPeriod = HMA_Period;
   int halfPeriod = HMA_Period/2;
   int sqrtPeriod = MathFloor(MathSqrt(HMA_Period*1.00));

   //---- check for possible errors
   if(counted_bars<1)
     {
      for(i=1;i<=draw_begin0;i++)
        {
         buffer[Bars-i]=0;
        }
        
      for(i=1;i<=fullPeriod;i++)
        {
         ind_buffer0[Bars-i]=0;
         ind_buffer1[Bars-i]=0;
         ind_buffer2[Bars-i]=0;
        }
     }// if counted
     
   //---- last counted bar will be recounted
   if(counted_bars>0)
     {
      counted_bars--;
     }
        
   limit=Bars-counted_bars;
   //---- MA difference counted in the 1-st buffer
   for(i=0; i<limit; i++)
     {
      halfMA=iMA(NULL,0,halfPeriod,0,MODE_LWMA,PRICE_CLOSE,i)*2;
      fullMA=iMA(NULL,0,fullPeriod,0,MODE_LWMA,PRICE_CLOSE,i);
      buffer[i]=halfMA-fullMA;
     }

   //---- HMA counted in the 0-th buffer
   tmp=iMAOnArray(buffer,0,MathFloor(MathSqrt(HMA_Period)),0,MODE_LWMA,0);

   for(i=1; i<limit; i++)
     {
      tmpPrevious=iMAOnArray(buffer,0,MathFloor(MathSqrt(HMA_Period)),0,MODE_LWMA,i);
      if (tmpPrevious > tmp)
        {
         ind_buffer0[i] = EMPTY_VALUE;
         ind_buffer1[i] = EMPTY_VALUE;
         ind_buffer2[i] = tmpPrevious;
         ind_buffer2[i-1] = tmp; // !
        }
       else if (tmpPrevious < tmp)
        {
         ind_buffer0[i] = tmpPrevious;
         ind_buffer0[i-1] = tmp; // !
         ind_buffer1[i] = EMPTY_VALUE;
         ind_buffer2[i] = EMPTY_VALUE;
        }
       else
        {
         ind_buffer0[i] = CLR_NONE;
         ind_buffer1[i] = tmpPrevious;
         ind_buffer2[i-1] = tmp; // !
         ind_buffer2[i] = CLR_NONE;
        }
      tmp = tmpPrevious;
     }//for
  }

