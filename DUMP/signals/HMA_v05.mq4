//-----------------------
// HMA modified by Ron
//-----------------------

#property link      "http://www.justdata.com.au/Journals/AlanHull/hull_ma.htm"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

//---- External parameters
extern int _maPeriod=14;
extern int BarsToDraw=200;

//---- indicator buffers
double _hmaG[];
double _hmaR[];
double _wma[];


int init() 
  {
  
   // 233 up arrow
   // 234 down arrow
   // 159 big dot
   // 158 little dot
   // 168 open square
   // 120 box with X
   

	//---- indicator buffers memory
	IndicatorBuffers(3);

	//---- indicator buffers mapping
	SetIndexBuffer(0, _hmaG);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0,233);

	SetIndexBuffer(1, _hmaR);
   SetIndexEmptyValue(1, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1,234);
	
	SetIndexBuffer(2, _wma);
  }


int deinit()
  {
  }



int start()
  {
   int pos;
   
	int     period = _maPeriod;
	int halfPeriod = _maPeriod/2;
	int sqrtPeriod = MathFloor(MathSqrt(period*1.00));
   
   double halfMA;
   double fullMA;

   double GorR;
   double prevGorR;
   
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
     
   prevGorR=iMAOnArray(_wma,0,sqrtPeriod,0,MODE_LWMA,1);
   GorR=iMAOnArray(_wma,0,sqrtPeriod,0,MODE_LWMA,0);
   
   
   if (prevGorR<GorR)
     {
      Print("UP_ARROW ",prevGorR," ",GorR);
      _hmaG[pos]=GorR;
      _hmaR[pos]=EMPTY_VALUE;
     }
    else
     {
      Print("DN_ARROW ",prevGorR," ",GorR);
      _hmaG[pos]=EMPTY_VALUE;
      _hmaR[pos]=GorR;
     }
     
  }



