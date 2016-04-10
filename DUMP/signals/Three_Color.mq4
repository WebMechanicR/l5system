//+------------------------------------------------------------------+
//|                                                  three_color.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int i,j,shift;
   static int width=1;
//----
   for(i=0; i<Bars-21; i+=30)
     {
      for(j=0,shift=i; j<11; j++,shift++)
        {
         ExtMapBuffer1[shift]=iMA(NULL,0,13,MODE_SMA,0,PRICE_CLOSE,shift);
         if(j>0 && j<10)
           {
            ExtMapBuffer2[shift]=EMPTY_VALUE;
            ExtMapBuffer3[shift]=EMPTY_VALUE;
           }
        }
     }
//----
   for(i=10; i<Bars-11; i+=30)
     {
      for(j=0,shift=i; j<11; j++,shift++)
        {
         ExtMapBuffer2[shift]=iMA(NULL,0,13,MODE_SMA,0,PRICE_CLOSE,shift);
         if(j>0 && j<10)
           {
            ExtMapBuffer1[shift]=EMPTY_VALUE;
            ExtMapBuffer3[shift]=EMPTY_VALUE;
           }
        }
     }
//----
   for(i=20; i<Bars-1; i+=30)
     {
      for(j=0,shift=i; j<11; j++,shift++)
        {
         ExtMapBuffer3[shift]=iMA(NULL,0,13,MODE_SMA,0,PRICE_CLOSE,shift);
         if(j>0 && j<10)
           {
            ExtMapBuffer1[shift]=EMPTY_VALUE;
            ExtMapBuffer2[shift]=EMPTY_VALUE;
           }
        }
     }
//----
   if(width>10) width=1;
   else width++;
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,width);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,width);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,width);
//----
   return(0);
  }
//+------------------------------------------------------------------+