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
#property link "http://www.lightpatch.com/forex/"

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 3

#property indicator_color1 LimeGreen
#property indicator_color2 Yellow
#property indicator_color3 Red

//User input
extern int HMA_Period=14;
extern int BarsToDraw=200;

// display buffers
double ind_buffer0[];
double ind_buffer1[];
double ind_buffer2[];

// computation buffers
double buffer[];



//Custom init
int init()
  {
   IndicatorBuffers(4);

   SetIndexBuffer(0,ind_buffer0) ;
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);

   SetIndexBuffer(1,ind_buffer1);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);

   SetIndexBuffer(2,ind_buffer2); 
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);

   SetIndexBuffer(3, buffer);
  }

//Custom DE-init
int deinit()
  {
  }


// Main Program loop
int start()
  {
   int i;
   int counted_bars=IndicatorCounted();
   double tmp, tmpPrevious;
   
   double fullMA;
   double halfMA;
   
   int fullPeriod = HMA_Period;
   int halfPeriod = HMA_Period/2;
   int sqrtPeriod = MathFloor(MathSqrt(HMA_Period*1.00));

   //---- MA difference counted in the 1-st buffer
   for(i=0; i<BarsToDraw; i++)
     {
      halfMA=iMA(NULL,0,halfPeriod,0,MODE_LWMA,PRICE_CLOSE,i)*2;
      fullMA=iMA(NULL,0,fullPeriod,0,MODE_LWMA,PRICE_CLOSE,i);
      buffer[i]=halfMA-fullMA;
     }

   //calculate bar[0]
   tmp=iMAOnArray(buffer,0,MathFloor(MathSqrt(HMA_Period)),0,MODE_LWMA,0);

   for(i=1; i<BarsToDraw; i++)
     {
      tmpPrevious=iMAOnArray(buffer,0,MathFloor(MathSqrt(HMA_Period)),0,MODE_LWMA,i);
      if (tmpPrevious > tmp)
        {
         ind_buffer0[i] = EMPTY_VALUE;
         ind_buffer1[i] = EMPTY_VALUE;
         ind_buffer2[i] = tmpPrevious+0.0005;
         ind_buffer2[i-1] = tmp-0.0005;
        }
       else if (tmpPrevious < tmp)
        {
         ind_buffer0[i] = tmpPrevious+0.0005;
         ind_buffer0[i-1] = tmp-0.0005;
         ind_buffer1[i] = EMPTY_VALUE;
         ind_buffer2[i] = EMPTY_VALUE;
        }
       else
        {
         ind_buffer0[i] = CLR_NONE;
         ind_buffer1[i] = tmpPrevious+0.0005;
         ind_buffer2[i-1] = tmp-0.0005;
         ind_buffer2[i] = CLR_NONE;
        }

      tmp = tmpPrevious;

     }//for
  }

