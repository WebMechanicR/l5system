//+------------------------------------------------------------------+
//|                                           MultiMovingAverage.mq4 |
//+------------------------------------------------------------------+
#property copyright "Ron T"
#property link      "http://www.lightpatch.com"

//in chart or out of chart 
#property indicator_chart_window

// buffer allocation and color 
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Red

// actual line buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];


//+------------------------------------------------------------------+
//| Custom indicator init function                                   |
//|------------------------------------------------------------------|
int init()
   {
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexArrow(0,158);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexArrow(1,158);

   return(0);
   }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
   {
   return(0);
   }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
   {
   double hitot=Low[120];     // yes, high=low - must start at lowest point
   double lotot=High[120];    // yes, low=high - must start at highest point 

   int size=120;  // make this external one day
   int i;
   int pos=size;

   if ( Bars <= size*2 ) return(0);
   if ( size < 2 ) size = 10;
   if ( size > Bars ) size = 250;

// MAIN

   while(pos>=0)
      {
      if ( Low[pos]  < lotot ) lotot = Low[pos];
      if ( High[pos] > hitot ) hitot = High[pos];
      ExtMapBuffer1[pos]=lotot;
      ExtMapBuffer2[pos]=hitot;
 	   pos--;
      }

   // clean up old indicators in array 
   for(i=size;i<size+10;i++) ExtMapBuffer1[i]=0;
   for(i=size;i<size+10;i++) ExtMapBuffer2[i]=0;
   
   
   
   return(0);
  }
  
//+------------------------------------------------------------------+