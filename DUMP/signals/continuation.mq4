//+------------------------------------------------------------------+
//|                                                 continuation.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
//---- indicator parameters
extern int ExtDepth=20;

//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
 
//---- indicator short name
   IndicatorShortName("continuation("+ExtDepth+"),");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int start()
  {
   int    shift,shiftt;
   double k_n[],k_p[],ch_p,ch_n,cff_p,cff_n;
   double CF_p[],CF_n[],Change_p[],Change_n[];

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     
     {
   if (Close[shift] > Close[shift+1])
   { Change_p[shift] = Close[shift]- Close[shift+1];
  CF_p[shift]= Change_p[shift] + CF_p[shift+1];
   Change_n[shift] = 0;
   CF_n[shift]= 0;
   }
    else
  { Change_p[shift] = 0;
  	CF_p[shift] = 0;
   Change_n[shift]  = Close[shift+1]- Close[shift];
   CF_n[shift] = Change_n[shift]+ CF_n[shift+1];
   }
  }
for(shiftt=shift+ExtDepth; shiftt>=shift; shiftt--)
     
     {
      ch_p= Change_p[shiftt+shift]+ch_p ;
      ch_n= Change_n[shiftt+shift]+ch_n ;
      cff_p=  CF_p[shiftt+shift]+cff_p; 
      cff_n=  CF_n[shiftt+shift]+ cff_n;
     }
 
 ExtMapBuffer[shift]=ch_p-cff_n; 
 ExtMapBuffer2[shift]=ch_n-cff_p;

   return(0);
  }

  
    
 