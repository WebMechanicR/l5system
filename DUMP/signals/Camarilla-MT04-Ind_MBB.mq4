//+------------------------------------------------------------------+
//|                                                          PV4.mq4 |
//|                                                        Jim Arner |
//|                                                                  |
//+------------------------------------------------------------------+

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
//---- indicators

//---- indicators

   

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   double yesterday_high;
   double yesterday_low;
   double yesterday_close;
   double array_price[][6];
   double P,R4,R3,S3,S4;

//---- TODO: add your code here

ArrayInitialize(array_price,0);
ArrayCopyRates(array_price,(Symbol()), PERIOD_D1);

yesterday_high = array_price[1][3];
yesterday_low = array_price[1][2];
yesterday_close = array_price[1][4];

P = yesterday_high - yesterday_low;

R4 = (1.1*P/2)+yesterday_close;
R3 = (1.1*P/4)+yesterday_close;

S3 = yesterday_close - (P*1.1/4);
S4 = yesterday_close - (P*1.1/2);

Comment("Camarilla Levels by Bin-Yagoub","\nR4=",R4,"\nR3=",R3,"\nS3=",S3,"\nS4=",S4);

ObjectDelete("S4_Line");
ObjectDelete("R4_Line");

ObjectDelete("S3_Line");
ObjectDelete("R3_Line");

ObjectCreate("S4_Line", OBJ_HLINE,0, CurTime(),S4);
ObjectSet("S4_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S4_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("R4_Line", OBJ_HLINE,0, CurTime(),R4);
ObjectSet("R4_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R4_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("S3_Line", OBJ_HLINE,0, CurTime(),S3);
ObjectSet("S3_Line",OBJPROP_COLOR,GreenYellow);
ObjectSet("S3_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectCreate("R3_Line", OBJ_HLINE,0, CurTime(),R3);
ObjectSet("R3_Line",OBJPROP_COLOR,OrangeRed);
ObjectSet("R3_Line",OBJPROP_STYLE,STYLE_DASHDOTDOT);

ObjectsRedraw();

   return(0);
 }
//+------------------------------------------------------------------+