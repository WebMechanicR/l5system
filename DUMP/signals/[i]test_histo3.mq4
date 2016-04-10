// Trend Manager.mq4
// Based on indicator sold at traderstradingsystem.com

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Aqua
#property indicator_color4 LawnGreen

// Divergence controls
extern double DVLimit=0.0007;
extern bool   ShowMAs=false;
extern int    Fast_TimeFrame=0;
extern int    Fast_Period=23;
extern int    Fast_Price = PRICE_OPEN;
extern int    Fast_Mode = MODE_SMA;
extern int    Fast_Shift=0;
extern int    Slow_TimeFrame=0;
extern int    Slow_Period=84;
extern int    Slow_Price = PRICE_OPEN;
extern int    Slow_Mode = MODE_SMA;
extern int    Slow_Shift=0;
extern int    BarCount=1500;

double SpanA_Buffer[];
double SpanB_Buffer[];
double ma1[];
double ma2[];

int tickcount=0;

int init()
{
   // histogram defined by top and bottom buffer
   // pos or neg from top buffer determines color   

   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(0,SpanB_Buffer);
   //SetIndexDrawBegin(0,TM_Period+TM_Shift-1);
   //SetIndexLabel(0,"TM_Period+");
   
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
   SetIndexBuffer(1,SpanA_Buffer);
   //SetIndexDrawBegin(1,TM_Period+TM_Shift-1);
   //SetIndexLabel(1,"TM_Period");

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ma1);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ma2);

}

int start()
{
   int    pos;
   
   int iFileHandle;

   double maF1, maF2, maS1, maS2;
   double D;
   
   for(pos=BarCount; pos>=0; pos--)
     {
      // Create Divergence stage one
      maF1=iMA(Symbol(),Fast_TimeFrame,Fast_Period,Fast_Shift,Fast_Mode,Fast_Price,pos);
      maS1=iMA(Symbol(),Slow_TimeFrame,Slow_Period,Slow_Shift,Slow_Mode,Slow_Price,pos);
      D=maF1-maS1;

      if( D >= DVLimit )
        {
         SpanA_Buffer[pos]  = High[pos];
         SpanB_Buffer[pos]  = High[pos]+(D-DVLimit);
        }

      if( D <= (DVLimit*(-1)) )
        {
         SpanA_Buffer[pos]  = Low[pos];
         SpanB_Buffer[pos]  = Low[pos]+(D-DVLimit);
        }

      if(ShowMAs)
        {
          ma1[pos]=maS1;
          ma2[pos]=maF1;
        }

     } //for

  } //start


