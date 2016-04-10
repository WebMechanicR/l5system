//+-----------------------------------------------------------------------+
//|                                                       BrainTrend1.mq4 |
//|                                   Copyright © 2005. Alejandro Galindo |
//|                                                   http://elCactus.com |
//|         ASCTrend1 modified to generate similar signals to BrainTrend1 |
//|           	Author := C0Rpus - big thanks CHANGE2002, STEPAN and SERSH |
//|	                                 Notes := ASCTrend1 3.0 Open Source |
//+-----------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- input parameters
extern int RISK=3;
extern int CountBars=5000;

//---- buffers
double Buffer1[];
double Buffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexBuffer(0,Buffer1);
   SetIndexBuffer(1,Buffer2);
   SetIndexArrow(0,108);
   SetIndexArrow(1,108);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| ASCTrend1                                                  |
//+------------------------------------------------------------------+
int start()
  {   
   int i,shift,counted_bars=IndicatorCounted();
   //int Counter,i1,value10,value11;
   //double value1,x1,x2;
   //double value2,value3;
   //double TrueCount,Range,AvgRange,MRO1,MRO2;
   double BT1=0, BT2=0, BT3=0, BT4=0;
   if (CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+11+1);
   SetIndexDrawBegin(1,Bars-CountBars+11+1);
  
//---- initial zero
//----
   shift=CountBars-11-1;
   while(shift>=0)
     {
         Buffer1[shift]=0;           
         Buffer2[shift]=0;
         BT1=iCustom(NULL,0,"BrainTrend1Stop",10,0,shift);
         BT2=iCustom(NULL,0,"BrainTrend1Stop",10,0,shift+1);      
         BT3=iCustom(NULL,0,"BrainTrend1Stop",10,1,shift);
         BT4=iCustom(NULL,0,"BrainTrend1Stop",10,1,shift+1);                     
         if (BT1 && !BT2) { Buffer2[shift]=BT1; }
         if (BT3 && !BT4) { Buffer1[shift]=BT3; }
         
      shift--;
     }

   return(0);
  }
//+------------------------------------------------------------------+


