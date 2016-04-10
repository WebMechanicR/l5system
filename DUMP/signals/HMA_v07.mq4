//-----------------------
// HMA modified by Ron
//-----------------------

#property link      "http://www.justdata.com.au/Journals/AlanHull/hull_ma.htm"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Red


//---- External parameters
extern int _maPeriod=14;

//---- indicator buffers
double _hmaW[];
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
	SetIndexBuffer(0, _hmaW);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID,2);
   //SetIndexArrow(0,159);
   
	SetIndexBuffer(1, _hmaR);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID,2);
   //SetIndexArrow(1,159);
	
	SetIndexBuffer(2, _wma);
  }


int deinit()
  {
  }



int start()
  {
   int pos;
   
	int fullPeriod =                    _maPeriod;
	int halfPeriod =                    _maPeriod/2;
	int sqrtPeriod = MathFloor(MathSqrt(_maPeriod*1.00));
   
   double fullMA;
   double halfMA;

   
   double pastMA;
   double prevMA;
   double currMA;
   
   /*
   MetaStock Formula
   period:=Input("Period",1,200,20) ;
   sqrtperiod:=Input("Square Root of Period",1,20,4);
   Mov(2*(Mov(C,period/2,W))-Mov(C,period,W),sqrtperiod,W); 

   SuperCharts Formula
   Input: period (Default value 20)
   waverage(2*waverage(close,period/2)-waverage(close,period), SquareRoot(Period)) 
   */
   
   for(pos=200; pos>=0; pos--) 
     {
      fullMA=iMA(Symbol(), 0, fullPeriod, 0, MODE_LWMA, PRICE_OPEN, pos);
      halfMA=iMA(Symbol(), 0, halfPeriod, 0, MODE_LWMA, PRICE_OPEN, pos);
      _wma[pos]=(2*halfMA)-fullMA;
     }
   for(pos=200; pos>=0; pos--) 
     {
      prevMA=iMAOnArray(_wma,0,sqrtPeriod,0,MODE_LWMA,pos+2);
      prevMA=iMAOnArray(_wma,0,sqrtPeriod,0,MODE_LWMA,pos+1);
      currMA=iMAOnArray(_wma,0,sqrtPeriod,0,MODE_LWMA,pos);
      if(prevMA<currMA)
        {
         _hmaW[pos]=currMA;
        }
       else
        {
         _hmaR[pos]=currMA;
        }

      if(pastMA>prevMA<currMA)
        {
         _hmaR[pos+1]=prevMA;
        }
      if(pastMA<prevMA>currMA)
        {
         _hmaW[pos+1]=prevMA;
        }


     }
    
  }

