//+------------------------------------------------------------------+
//|                                                        Hi-Lo.mq4 |
//|                                                                  |
//|                                        Ramdass - Conversion only |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Lime
//---- input parameters
extern int Per=3;
extern int CountBars=300;
//---- buffers
double Up[];
double Down[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Down);
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Hi-Lo                                                         |
//+------------------------------------------------------------------+
int start()
  {
   SetIndexDrawBegin(0,Bars-CountBars+Per);
   SetIndexDrawBegin(1,Bars-CountBars+Per);
   int i,counted_bars=IndicatorCounted();
   bool Pr=false, PrevPr=false;
   double val,val2;
//----
   if(CountBars<=Per) return(0);
//---- initial zero
   if(counted_bars<1)
   {
      for(i=1;i<=Per;i++) Up[CountBars-i]=0.0;
      for(i=1;i<=Per;i++) Down[CountBars-i]=0.0;
   }
//----
   i=CountBars-Per-1;
//   if(counted_bars>=CCIPeriod1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      val=iMA(NULL,0,Per,1,MODE_SMA,PRICE_HIGH,i);
      val2=iMA(NULL,0,Per,1,MODE_SMA,PRICE_LOW,i);

if (Close[i]<val2 && PrevPr==true) Pr=false;   
if (Close[i]>val && PrevPr==false) Pr=true;
PrevPr=Pr;   
Up[i]=0.0; Down[i]=0.0;
if (Pr==false) Up[i] = val+2*Point; 
if (Pr==true) Down[i] = val2-2*Point;

      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+