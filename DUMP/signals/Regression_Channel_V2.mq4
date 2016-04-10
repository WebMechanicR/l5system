//+------------------------------------------------------------------+
//|                                           Regression_Channel.mq4 |
//|                                        Converted to MT4 by KimIV |
//| Modified bt MrPip to place lines at 2 different Standard Devs    |
//| Also makes StDev level an input, with some Stache mods              |
//+------------------------------------------------------------------+
/*[[
	Name := Regression_Channel
	Author := Copyright © 2004, MetaQuotes Software Corp.
	Link := http://www.metaquotes.net/
]]*/
#property copyright "KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window

//------- Внешние параметры индикатора -------------------------------
extern int    NumberName   = 1;
extern int    iPeriod      = 56;
extern double MAShoot      = 50;
extern int    LineWeight   = 1;
extern color LineColor = Magenta;
extern double StDevOutside = 1.618;
extern color Outside = SteelBlue;
extern int  OutsideWeight=1;
extern double StDevInside = 0.809;
extern color Inside = Goldenrod;
extern int  InsideWeight=1;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  ObjectCreate("Regression_middle"+NumberName, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Regression_middle"+NumberName, OBJPROP_COLOR, LineColor);
 	ObjectSet("Regression_middle"+NumberName, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Regression_middle"+NumberName, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Regression_Outside_upper" +NumberName, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_COLOR, Outside);
 	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_WIDTH, OutsideWeight);
  ObjectCreate("Regression_Outside_lower" +NumberName, OBJ_TREND, 0, 0,0, 0,0);
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_COLOR, Outside);
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_WIDTH, OutsideWeight);
  ObjectCreate("Regression_Inside_upper" +NumberName, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_COLOR, Inside);
 	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_WIDTH, InsideWeight);
  ObjectCreate("Regression_Inside_lower" +NumberName, OBJ_TREND, 0, 0,0, 0,0);
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_COLOR, Inside);
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_WIDTH, InsideWeight);

  Comment("Auto Regression channel");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  ObjectDelete("Regression_middle"+NumberName);
  ObjectDelete("Regression_Outside_upper" +NumberName);
  ObjectDelete("Regression_Outside_lower" +NumberName);
  ObjectDelete("Regression_Inside_upper" +NumberName);
  ObjectDelete("Regression_Inside_lower" +NumberName);
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  bool   check_low, check_high;
  bool   check_upper_chanel;
  double save_low, save_high;
  double MA, a1, a2, a3, b1, a_, b_, y1, y2, price;
  double stddiv_low, stddiv_high, tmp_div;
  double x_n_upOut, x_1_upOut, x_n_downOut, x_1_downOut;
  double x_n_upIn, x_1_upIn, x_n_downIn, x_1_downIn;
  double ratio_currency;
  int     shift;
  int    n, n_begin, n_end;
  int    MAType, MAPrice;
  int    save_shift_low, save_shift_high;

  save_low = -1;
  save_high = -1;
  save_shift_low = -1;
  save_shift_high = -1;

  check_low = false;	
  check_high = false;	

  MAType = MODE_SMA;
  MAPrice = PRICE_CLOSE;

  if (Close[1]>80) ratio_currency = 100;
  else ratio_currency = 10000;

  // Поиск точек пересечения с МА
  for (shift=Bars-1; shift>=0; shift--) {
  	MA = iMA(NULL, 0, iPeriod, 0, MAType, MAPrice, shift);
  	if (MA-MAShoot/ratio_currency>Close[shift])	{
  		if (Close[shift]<save_low || save_low==-1) {
  			check_low = true;
  			save_low = Close[shift];
  			save_shift_low = shift;
  		}
  	}
	
  	if (MA+MAShoot/ratio_currency<Close[shift]) {
  		if (save_high<Close[shift] || save_high==-1) {
  			check_high = true;	
  			save_high = Close[shift];
  			save_shift_high = shift;
  		}
  	}

  	if (check_low) {	
  		if (MA+MAShoot/ratio_currency<Close[shift])	{
  			check_low = false;	
  			save_low = -1;
  		}
  	}
	
  	if (check_high) {
  		if (MA-MAShoot/ratio_currency>Close[shift]) {						
  			check_high = false;	
  			save_high = -1;
  		}
  	}
  }

  //Определение границ построения каналла
  if (save_shift_low>save_shift_high) {
  	n_begin = save_shift_low;
  	n_end = save_shift_high;
  } else {
  	n_begin = save_shift_high;
  	n_end = save_shift_low;
  }

  if (n_end==0) n_end = 1; // Нулевой бар не использовать
  n = n_begin - n_end + 1; // длина канала

  a1 = 0;
  a2 = 0;
  a3 = 0;
  b1 = 0;
  a_ = 0;
  b_ = 0;
  y1 = 0;
  y2 = 0;
  tmp_div = 0;

  if (Close[n_begin]<Close[n_end]) check_upper_chanel = true;
  else check_upper_chanel = false;

  for (shift=n_begin; shift>=n_end; shift--) {
  	if (check_upper_chanel) price = Low[shift];
  	else price = High[shift];
	
  	a1 = a1 + shift*price;
  	a2 = a2 + shift;
  	a3 = a3 + price;
  	b1 = b1 + shift*shift;
  }

  b_ = (n*a1 - a2*a3)/(n*b1 - a2*a2);
  a_ = (a3 - b_*a2)/n;
  y1 = a_ + b_*n_begin;
  y2 = a_ + b_*n_end;

 	ObjectSet("Regression_middle"+NumberName, OBJPROP_TIME1, Time[n_begin]);
 	ObjectSet("Regression_middle"+NumberName, OBJPROP_TIME2, Time[n_end]);
 	ObjectSet("Regression_middle"+NumberName, OBJPROP_PRICE1, y1);
 	ObjectSet("Regression_middle"+NumberName, OBJPROP_PRICE2, y2);

  for (shift=n_begin; shift>=n_end; shift--) {
  	if (check_upper_chanel) price = Low[shift];
	  else price = High[shift];
	
  	tmp_div = tmp_div + (price - (a_ + b_*shift))*(price - (a_ + b_*shift));	
  }

  stddiv_low = MathSqrt(tmp_div/n);
  stddiv_high = MathSqrt(tmp_div/n);

  x_n_upOut = y1 + StDevOutside*stddiv_high;
  x_1_upOut = y2 + StDevOutside*stddiv_high;

  x_n_downOut = y1 - StDevOutside*stddiv_low;
  x_1_downOut = y2 - StDevOutside*stddiv_low;

  x_n_upIn = y1 + StDevInside*stddiv_high;
  x_1_upIn = y2 + StDevInside*stddiv_high;

  x_n_downIn = y1 - StDevInside*stddiv_low;
  x_1_downIn = y2 - StDevInside*stddiv_low;

	
//OUTSIDE
  //upper
 	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_TIME1, Time[n_begin]);
 	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_TIME2, Time[n_end]);
 	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_PRICE1, x_n_upOut);
 	ObjectSet("Regression_Outside_upper"+NumberName, OBJPROP_PRICE2, x_1_upOut);
  //lower
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_TIME1, Time[n_begin]);
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_TIME2, Time[n_end]);
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_PRICE1, x_n_downOut);
 	ObjectSet("Regression_Outside_lower"+NumberName, OBJPROP_PRICE2, x_1_downOut);

//INSIDE
  //upper
 	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_TIME1, Time[n_begin]);
 	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_TIME2, Time[n_end]);
 	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_PRICE1, x_n_upIn);
 	ObjectSet("Regression_Inside_upper"+NumberName, OBJPROP_PRICE2, x_1_upIn);
  //lower
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_TIME1, Time[n_begin]);
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_TIME2, Time[n_end]);
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_PRICE1, x_n_downIn);
 	ObjectSet("Regression_Inside_lower"+NumberName, OBJPROP_PRICE2, x_1_downIn);

}
//-------------------------------------------------------------------+

