//+------------------------------------------------------------------+
//|                                           MultiMovingAverage.mq4 |
//+------------------------------------------------------------------+
#property copyright "Ron T"
#property link      "http://www.lightpatch.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 White

//---- buffers
double VolBuffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, VolBuffer1);

   return(0);
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   
   for( i=0; i<Bars; i++ ) VolBuffer1[i]=0;

   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   double curTYP=0;
   double oldTYP=0;
   double change=0;

   int pos=Bars/5;
   
   // Print ("Start SHOW5TICKS with bars=",pos);

   while(pos>=0)
     {
      VolBuffer1[pos]=Volume[pos];
 	   pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+