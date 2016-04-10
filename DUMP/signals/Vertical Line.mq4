//+------------------------------------------------------------------+
//|                                                Vertical Line.mq4 |
//|                              Copyright © 2006, fxid10t@yahoo.com |
//|                               http://www.forexprogramtrading.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, fxid10t@yahoo.com"
#property link      "http://www.forexprogramtrading.com"
#property indicator_chart_window

extern int Place.Line.Bars.Back=1;
extern color Line.Color=Orange;
extern int Line.Style=1;
extern int Line.Width=1;
extern bool Draw.as.Background=true;

int init(){return(0);}
int deinit(){ObjectDelete("V-Line"); return(0);}
int start(){
ObjectDelete("V-Line");
ObjectCreate("V-Line",OBJ_VLINE,0,Time[Place.Line.Bars.Back],Bid);
ObjectSet("V-Line",OBJPROP_COLOR,Line.Color);
ObjectSet("V-Line",OBJPROP_STYLE,Line.Style);
ObjectSet("V-Line",OBJPROP_WIDTH,Line.Width);
ObjectSet("V-Line",OBJPROP_BACK,Draw.as.Background);
return(0);}
//+------------------------------------------------------------------+