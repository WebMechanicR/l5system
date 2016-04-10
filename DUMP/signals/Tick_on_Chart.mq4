//+------------------------------------------------------------------+
//|                                                Tick_on_Chart.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Cornsilk
#property indicator_color2 Red
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
int tik,t;
   double buf[],MaxB,MinB=1000;
extern int period=200;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,ExtMapBuffer2);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   int i,b;
//---- 
t++;
b=period;
ArrayResize(buf,b);

if(tik==0)
   {
   for(i=0;i<b;i++)
      {
      buf[i]=Bid;
      }
   ExtMapBuffer2[0]=Bid+5*Point;   
   ExtMapBuffer2[1]=Bid-5*Point;   
   tik=1;
   }
   MaxB=0;MinB=1000;
   for(i=b-1;i>0;i--)
      {
      buf[i]=buf[i-1];
      if(MaxB<buf[i])MaxB=buf[i];
      if(MinB>buf[i])MinB=buf[i];
      } 
buf[0]=Bid;
for(i=0;i<b;i++)
   {
   ExtMapBuffer1[i]=buf[i];
   }
if(MathCeil(t/10)*10==t)
   {
   for(i=b;i<Bars;i++)
      {
      ExtMapBuffer1[i]=Bid;
      }
      ArrayInitialize(ExtMapBuffer2,Bid); 
      if(MaxB-Bid<5*Point)ExtMapBuffer2[0]=Bid+5*Point;
      if(Bid-MinB<5*Point)ExtMapBuffer2[1]=Bid-5*Point;
      //Print(MaxB,"+",Bid,"+",MinB);
   }   
//----
   return(0);
  }
//+------------------------------------------------------------------+