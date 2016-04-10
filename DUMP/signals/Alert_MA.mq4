//+------------------------------------------------------------------+
//|                                                     Alert_MA.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"
extern int range = 1;
extern int ma_period = 55;
extern int ma_shift = 0;
extern int ma_method = MODE_EMA;
extern int applied_price = PRICE_CLOSE;
 
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    
//----bb
   double ma = iMA(Symbol(),0,ma_period,ma_shift,ma_method,applied_price,0);
   
   if( (Bid <= ma+(range*Point)) && (Bid >= ma-(range*Point)))
   Alert(Symbol()+" "+ma_period+" Moving Average range reached at ",Bid);
    
   
//----
   return(0);
  }
//+------------------------------------------------------------------+