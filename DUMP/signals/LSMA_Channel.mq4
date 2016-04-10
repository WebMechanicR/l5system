//+------------------------------------------------------------------+
//|                                                    LSMA_Line.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
//---- indicator parameters
extern int    IdNum   = 1;
extern int    RPeriod = 28;
extern color  MidColor = Red;
extern int    LineWeight   = 1;
extern int    PriceVal = 0;         // 0 = Close, 1 = Low, 2 = High
extern double StDevOutside2 = 2.55;
extern color Outside2 = Red;
extern double StDevOutside = 1.618;
extern color Outside = Brown;
extern double StDevInside = 0.809;
extern color Inside = Green;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
  ObjectCreate("Reg_line"+IdNum, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Reg_line"+IdNum, OBJPROP_COLOR, MidColor);
 	ObjectSet("Reg_line"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_line"+IdNum, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Reg_Outside_upper" +IdNum, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_COLOR, Outside);
 	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Reg_Outside_lower" +IdNum, OBJ_TREND, 0, 0,0, 0,0);
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_COLOR, Outside);
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Reg_Inside_upper" +IdNum, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_COLOR, Inside);
 	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Reg_Inside_lower" +IdNum, OBJ_TREND, 0, 0,0, 0,0);
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_COLOR, Inside);
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Reg_Outside2_upper" +IdNum, OBJ_TREND, 0, 0,0, 0,0);
	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_COLOR, Outside2);
 	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_WIDTH, LineWeight);
  ObjectCreate("Reg_Outside2_lower" +IdNum, OBJ_TREND, 0, 0,0, 0,0);
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_COLOR, Outside2);
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_STYLE, STYLE_SOLID);
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_WIDTH, LineWeight);

  Comment("Regression channel");
   return(0);
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  ObjectDelete("Reg_line"+IdNum);
  ObjectDelete("Reg_Outside_upper" +IdNum);
  ObjectDelete("Reg_Outside_lower" +IdNum);
  ObjectDelete("Reg_Inside_upper" +IdNum);
  ObjectDelete("Reg_Inside_lower" +IdNum);
  ObjectDelete("Reg_Outside2_upper" +IdNum);
  ObjectDelete("Reg_Outside2_lower" +IdNum);
  Comment("");
}

//+------------------------------------------------------------------+
//| Regression Line                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double y1,y2, price;
   double a1, a2, a3, b1, a, b;
   double stddiv, tmp_div;
   double x_n_upOut, x_1_upOut, x_n_downOut, x_1_downOut;
   double x2_n_upOut, x2_1_upOut, x2_n_downOut, x2_1_downOut;
   double x_n_upIn, x_1_upIn, x_n_downIn, x_1_downIn;
   int shift, n;
   
//----
   if(Bars<=RPeriod) return(0);
   a1 = 0;
   a2 = 0;
   a3 = 0;
   b1 = 0;
   a = 0;
   b = 0;
   y1 = 0;
   y2 = 0;
   tmp_div = 0;
   n = RPeriod;
  	for(shift=RPeriod;shift>0;shift--)
  	{
  	  switch (PriceVal)
  	  {
  	     case 0: price = Close[shift];
  	             break;
  	     case 1: price = Low[shift];
  	             break;
  	     case 2: price = High[shift];
  	             break;
  	  }
     a1 = a1 + shift*price;
     a2 = a2 + shift;
     a3 = a3 + price;
     b1 = b1 + shift*shift;
  }

  b = (n*a1 - a2*a3)/(n*b1 - a2*a2);
  a = (a3 - b*a2)/n;
  y1 = a + b*n;
  y2 = a + b;
      
 	ObjectSet("Reg_line"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_line"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_line"+IdNum, OBJPROP_PRICE1, y1);
 	ObjectSet("Reg_line"+IdNum, OBJPROP_PRICE2, y2);
 	
  for (shift=RPeriod; shift>0; shift--) {
  	  switch (PriceVal)
  	  {
  	     case 0: price = Close[shift];
  	             break;
  	     case 1: price = Low[shift];
  	             break;
  	     case 2: price = High[shift];
  	             break;
  	  }
	
  	tmp_div = tmp_div + (price - (a + b*shift))*(price - (a + b*shift));	
  }

  stddiv = MathSqrt(tmp_div/n);

  x_n_upOut = y1 + StDevOutside*stddiv;
  x_1_upOut = y2 + StDevOutside*stddiv;

  x_n_downOut = y1 - StDevOutside*stddiv;
  x_1_downOut = y2 - StDevOutside*stddiv;

  x_n_upIn = y1 + StDevInside*stddiv;
  x_1_upIn = y2 + StDevInside*stddiv;

  x_n_downIn = y1 - StDevInside*stddiv;
  x_1_downIn = y2 - StDevInside*stddiv;

  x2_n_upOut = y1 + StDevOutside2*stddiv;
  x2_1_upOut = y2 + StDevOutside2*stddiv;

  x2_n_downOut = y1 - StDevOutside2*stddiv;
  x2_1_downOut = y2 - StDevOutside2*stddiv;
  
// OUTSIDE	
  //upper
 	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_PRICE1, x_n_upOut);
 	ObjectSet("Reg_Outside_upper"+IdNum, OBJPROP_PRICE2, x_1_upOut);
  //lower
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_PRICE1, x_n_downOut);
 	ObjectSet("Reg_Outside_lower"+IdNum, OBJPROP_PRICE2, x_1_downOut);

// OUTSIDE2	
  //upper
 	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_PRICE1, x2_n_upOut);
 	ObjectSet("Reg_Outside2_upper"+IdNum, OBJPROP_PRICE2, x2_1_upOut);
  //lower
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_PRICE1, x2_n_downOut);
 	ObjectSet("Reg_Outside2_lower"+IdNum, OBJPROP_PRICE2, x2_1_downOut);

//INSIDE
  //upper
 	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_PRICE1, x_n_upIn);
 	ObjectSet("Reg_Inside_upper"+IdNum, OBJPROP_PRICE2, x_1_upIn);
  //lower
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_TIME1, Time[RPeriod]);
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_TIME2, Time[0]);
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_PRICE1, x_n_downIn);
 	ObjectSet("Reg_Inside_lower"+IdNum, OBJPROP_PRICE2, x_1_downIn);
   return(0);
  }
//+------------------------------------------------------------------+