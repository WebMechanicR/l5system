//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property  indicator_buffers 3
#property  indicator_color1  Yellow
#property  indicator_color2  Red
#property  indicator_color3  Black

//---- indicator parameters
extern double TakeProfit = 1000;
extern double MACDCharttime = 0;
extern double MATrendPeriod= 26;
extern double ShiftFromBar = 0.01;
extern int FastLength = 12;
extern int SlowLength = 26;
extern int MACDLength =  9; 

//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtSwitchBuffer2[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_ARROW,STYLE_DOT);
   SetIndexStyle(1,DRAW_ARROW,STYLE_DOT);
   
   
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtSwitchBuffer2);

   
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(ExtMapBuffer1,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
   //ArraySetAsSeries(ExtSwitchBuffer2,true);

   //SetIndexShift(0, 20); 
   //SetIndexShift(1, 20); 
   
//---- indicator short name
   IndicatorShortName("FRUITWORKS");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
 {
   int    shift, back, lasthighpos, lastlowpos;
   double val,res;
   double curlow, curhigh,lasthigh,lastlow;
   double MacdCurrent, MacdPrevious;
   double SignalCurrent, SignalPrevious;
   double MaCurrent, MaPrevious;
   double MacdDiffy, MacDuff;
   int cnt, ticket, total;
   int limit;
   
    //if(Bars<900)
    // {
    //  Print("bars less than 900");
    //  return(0);  
    // }
   SetIndexEmptyValue(0,0.0);
   RefreshRates( ) ;
  
   for(shift=(Bars-100); shift>=0; shift--)
  {
   ExtMapBuffer1[shift] = 0;
   ExtMapBuffer2[shift] = 0;
   
   MaCurrent =iMA(NULL,MACDCharttime,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,(shift+0));
   MaPrevious=iMA(NULL,MACDCharttime,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,(shift+4));
 
   MacdCurrent  = iMACD(NULL,MACDCharttime,FastLength,SlowLength,MACDLength,PRICE_CLOSE,MODE_MAIN,(shift+0));
   MacdPrevious = iMACD(NULL,MACDCharttime,FastLength,SlowLength,MACDLength,PRICE_CLOSE,MODE_MAIN,(shift+1));
   
   SignalCurrent  = iMACD(NULL,MACDCharttime,FastLength,SlowLength,MACDLength,PRICE_CLOSE,MODE_SIGNAL,(shift+0));
   SignalPrevious = iMACD(NULL,MACDCharttime,FastLength,SlowLength,MACDLength,PRICE_CLOSE,MODE_SIGNAL,(shift+1));

    
   MacdDiffy = (MacdCurrent -  SignalCurrent);   
   MacDuff   = (MacdPrevious - SignalPrevious);
   
   ExtSwitchBuffer2[shift]  = 0;
     
   //if (shift < Bars)
   //{
   //ExtSwitchBuffer2[shift]  = ExtSwitchBuffer2[shift+1];
   //} 
  
   if ( ((MacDuff<=0) && (MacdDiffy>=0)) ||  (ExtSwitchBuffer2[shift+1]==1))
   {
    ExtSwitchBuffer2[shift]  = 1;
   } 
  
 
   if (MacdDiffy < -0.00015 && MacdDiffy > MacDuff && MaCurrent >= MaPrevious  && ExtSwitchBuffer2[shift] == 1)
   {
   ExtSwitchBuffer2[shift]  = 0;
   ExtMapBuffer1[shift] = Open[shift] + ShiftFromBar;
   if (shift == 0)
   {
   ExtMapBuffer1[shift] = Ask + ShiftFromBar;
   }
   //Comment("SELL : Macd Diff : ",MacdDiffy,":",ExtMapBuffer2[shift]," from current : ",shift);
   }
   if (MacdDiffy > 0.00015 && MacdDiffy < MacDuff && MaCurrent <= MaPrevious && ExtSwitchBuffer2[shift] ==  1)  
   {
   ExtSwitchBuffer2[shift]  = 0;
   ExtMapBuffer2[shift]     = Open[shift] - ShiftFromBar;  
   if (shift == 0)
   {
   ExtMapBuffer2[shift] = Bid + ShiftFromBar;
   }
   //Comment("BUY : Macd Diff : ",MacdDiffy,":",ExtMapBuffer2[shift]," from current : ",shift);
   }   
   //--ExtMapBuffer2[shift]=MacdDiffy;

}  
}
  