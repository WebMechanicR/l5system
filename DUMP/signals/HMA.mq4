/*+------------------------------------------------------------------+
 | FileName: i_Hull_MA.mq4
 | Description: This indicator calculates the Hull Moving Average
 |  
 | Original equation is:
 | ---------------------
 | waverage(2*waverage(close,period/2)-waverage(close,period), SquareRoot(Period)
	 Implementation below is more efficient with lengthy Weighted Moving Averages.
	 In addition, the length needs to be converted to an integer value after it is halved and
	 its square root is obtained in order for this to work with Weighted Moving Averaging

 | Version: 000 20050903 17:06 GMT
 +------------------------------------------------------------------------------------------+*/
#property link      "http://www.justdata.com.au/Journals/AlanHull/hull_ma.htm"

#property indicator_chart_window
#property indicator_buffers 1

#property indicator_color1 Silver

//---- External parameters
extern int _maPeriod=120;

//---- indicator buffers
double _hma[];
double _wma[];

//----
int ExtCountedBars=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
	int    draw_begin;
	string short_name;
	IndicatorBuffers(7);

	//---- indicator buffers mapping
	SetIndexBuffer(0, _hma);
	SetIndexEmptyValue(0, 0.0);
	SetIndexStyle(0, DRAW_LINE);
	
	SetIndexBuffer(1, _wma);
	SetIndexEmptyValue(1, 0.0);
	
	IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));

	//---- initialization done
	return(0);
}

//+------------------------------------------------------------------+
//| CalculateIndicators                                                                 |
//+------------------------------------------------------------------+
void calculateIndicators(int i) {
	int period=_maPeriod;
	double sqrtPeriod = MathSqrt(period*1.00);
	int halfPeriod=period/2;

	double wma1 = iMA(Symbol(), 0, period, 0, MODE_LWMA, PRICE_CLOSE, i);
	double wma2 = iMA(Symbol(), 0, halfPeriod, 0, MODE_LWMA, PRICE_CLOSE, i);
	_wma[i] = 2*wma2-wma1;
	
	_hma[i]=iMAOnArray(_wma, 0, sqrtPeriod, 0, MODE_LWMA, i);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() {
	int i, shift, countedBars=IndicatorCounted();
	int maxBars=_maPeriod*2;

	if(Bars<_maPeriod) return(-1);
  if(countedBars == 0) countedBars = maxBars;
	int limit=Bars-countedBars+maxBars;
	
	//---- moving average
	for(i=limit; i>=0; i--) {
		calculateIndicators(i);
	} 

	return(0);
}

