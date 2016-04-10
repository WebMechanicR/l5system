//-----------------------
// HMA modified by Ron
//-----------------------

#property link      "http://www.justdata.com.au/Journals/AlanHull/hull_ma.htm"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 DodgerBlue

//---- External parameters
extern int _maPeriod=14;
extern int BarsToDraw=200;

//---- indicator buffers
double _hma[];
double _wma[];


int init() 
  {
	//---- indicator buffers mapping
	SetIndexBuffer(0, _hma);
	SetIndexStyle(0, DRAW_LINE, STYLE_SOLID,2);

	SetIndexBuffer(1, _wma);
	SetIndexStyle(1, DRAW_LINE, STYLE_SOLID,2);
  }


int deinit()
  {
  }



int start()
  {
   int pos;
   int i,k;
   
	int     period = _maPeriod;
	int halfPeriod = _maPeriod/2;
	int sqrtPeriod = MathFloor(MathSqrt(period*1.00));
   
   double halfMA;
   double fullMA;

   /*
   MetaStock Formula
   period:=Input("Period",1,200,20) ;
   sqrtperiod:=Input("Square Root of Period",1,20,4);
   Mov(2*(Mov(C,period/2,W))-Mov(C,period,W),sqrtperiod,W); 

   SuperCharts Formula
   Input: period (Default value 20)
   waverage(2*waverage(close,period/2)-waverage(close,period), SquareRoot(Period)) 
   */
   
   for(pos=BarsToDraw; pos>=0; pos--) 
     {
      fullMA=iMA(Symbol(), 0,     period, 0, MODE_LWMA, PRICE_CLOSE, pos);
      halfMA=iMA(Symbol(), 0, halfPeriod, 0, MODE_LWMA, PRICE_CLOSE, pos);
      _wma[pos]=(2*halfMA)-fullMA;
     }
     
   for(pos=BarsToDraw; pos>=0; pos--) 
     {
      _hma[pos]=iMAOnArray(_wma,0,sqrtPeriod,0,MODE_LWMA,pos);
     }
     
  }






/*  Testing...

      // weighted MA
      _hma[pos]=((_wma[pos]*4)+(_wma[pos+1]*3)+(_wma[pos+2]*2)+(_wma[pos+3]*1))/10;

      // simple MA
      _hma[pos]=_wma[pos]+_wma[pos+1]+_wma[pos+2]+_wma[pos+3])/4;

      // lwma
      for(i=1;i<=MA_Period;i++,pos--)
        {
         price=Volume[pos];
         sum+=price*i;
         lsum+=price;
         weight+=i;
        }



      Linear Weighted Moving Average (LWMA)
      In the case of weighted moving average, the latest data is of 
      more value than more early data. Weighted moving average is 
      calculated by multiplying each one of the closing prices within 
      the considered series, by a certain weight coefficient.

      LWMA = SUM(Close(i)*i, N)/SUM(i, N)
      Where: 
      SUM(i, N) — is the total sum of weight coefficients.

      // lwma
      k=pos;
      for(i=1;i<=period;i++,k--)
        {
         price=_wma[k];
         sum+=price*i;
         lsum+=price;
         weight+=i;
        }






//+------------------------------------------------------------------+
//| Linear Weighted Moving Average                                   |
//+------------------------------------------------------------------+
void lwma()
  {
   double sum=0.0,lsum=0.0;
   double price;
   int    i,weight=0,pos=Bars-ExtCountedBars-1;

//---- initial accumulation
   if(pos<MA_Period) pos=MA_Period;
   for(i=1;i<=MA_Period;i++,pos--)
     {
      price=Volume[pos];
      sum+=price*i;
      lsum+=price;
      weight+=i;
     }
//---- main calculation loop
   pos++;
   i=pos+MA_Period;
   while(pos>=0)
     {
      VolBuffer3[pos]=sum/weight;
      if(pos==0) break;
      pos--;
      i--;
      price=Volume[pos];
      sum=sum-lsum+price*MA_Period;
      lsum-=Volume[i];
      lsum+=price;
     }
//---- zero initial bars
   if(ExtCountedBars<1)
      for(i=1;i<MA_Period;i++) VolBuffer3[Bars-i]=0;
  }



