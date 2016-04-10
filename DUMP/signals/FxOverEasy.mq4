//| FirstIndicator.mq4 |
//| Copyright © 2004, MetaQuotes Software Corp. |
//| http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
//---- input parameters
extern bool SpeakToMe= true;
extern bool BellAlert= false;





//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
int firstup=0;
double PS,PS1;
int alertTag;
string symbolTxt;

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
SetIndexStyle(0,DRAW_ARROW,EMPTY);
SetIndexArrow(0,233);
SetIndexBuffer(0, ExtMapBuffer1);

SetIndexStyle(1,DRAW_ARROW,EMPTY);
SetIndexArrow(1,234);
SetIndexBuffer(1, ExtMapBuffer2);
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
//---- TODO: add your code here

//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
if (Symbol()=="EURUSD") { symbolTxt = "Euro Dollar"; }
if (Symbol()=="EURJPY") { symbolTxt = "Euro Yen "; }
if (Symbol()=="EURAUD") { symbolTxt = "Euro Aussie "; }
if (Symbol()=="EURCAD") { symbolTxt = "Euro Canadian"; }
if (Symbol()=="EURCHF") { symbolTxt = "Euro Swiss"; }
if (Symbol()=="GBPUSD") { symbolTxt = "Cable Dollar"; }
if (Symbol()=="GBPJPY") { symbolTxt = "Cable Yen "; }
if (Symbol()=="GBPCHF") { symbolTxt = "Cable Swiss"; }
if (Symbol()=="AUDUSD") { symbolTxt = "Aussie"; }
if (Symbol()=="USDCHF") { symbolTxt = "Swiss Dollar"; }
if (Symbol()=="USDCAD") { symbolTxt = "Canada"; }
if (Symbol()=="USDJPY") { symbolTxt = "Yen Dollar"; } 
if (Symbol()=="CHFJPY") { symbolTxt = "Swiss Yen "; }
if (Symbol()=="GOLD")   { symbolTxt = "Gold"; }


int limit;
int counted_bars=IndicatorCounted();





limit = 300;

   firstup = 0;
   
 for(int i=limit; i>=0; i--)
{
   PS =iSAR(NULL,0,0.02,0.2,i);
   PS1=iSAR(NULL,0,0.02,0.2,i+1);
   // Comment(PS," PS");


    if( PS1 > (High[i+1]+Low[i+1])/2 && PS < (Low[i]+High[i])/2 )
    {         
      ExtMapBuffer1[i]=PS;
            
      if ( BellAlert && firstup && !i && alertTag != Time[0])
               {
                     Alert( Symbol(), " ", Period(), "  FXOverEasy  BUY" );
                     alertTag = Time[0];
               }
     if ( SpeakToMe && firstup && !i && alertTag != Time[0])
               {   
                     SpeechText("Check for Buy. "+symbolTxt);
                     alertTag = Time[0];
               }
          
   }
 
   
    if( PS > (High[i]+Low[i])/2 && PS1 <= (Low[i+1]+Low[i])/2 )
    {
      ExtMapBuffer2[i]=PS;
            
      if ( BellAlert && firstup && !i && alertTag != Time[0])
            {
                   Alert (Symbol()," ",Period(),"  FXOverEasy  SELL");
                   alertTag = Time[0];
            }
     if ( SpeakToMe && firstup && !i && alertTag != Time[0])
            {
                  SpeechText("Check for Sell. "+symbolTxt);
                  alertTag = Time[0];
            }
   } 
   firstup = firstup + 1;
}
//----
return(0);
}


