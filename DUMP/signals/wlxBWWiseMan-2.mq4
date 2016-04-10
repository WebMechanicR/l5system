//+------------------------------------------------------------------+
//|                                               wlxBWWiseMan-2.mq4 |
//|                                          Copyright © 2005, wellx |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, wellx"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkOrange
#property indicator_color2 Magenta

//---- input parameters

extern int       updown=8;
//---- buffers
double BWWM2Up[];
double BWWM2Down[];

int pos=0;
double AO,AO1,AO2,AO3,AO4;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,141);
   SetIndexBuffer(0,BWWM2Up);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,141);
   SetIndexBuffer(1,BWWM2Down);
   SetIndexEmptyValue(1,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int  cbars=IndicatorCounted();
   if  (cbars<0) return(-1);
   if  (cbars>0) cbars--;
//---- TODO: add your code here
   if (cbars > (Bars-40)) pos=(Bars-40);
   else pos=cbars;
//----
   while (pos > 0)
   {
    BWWM2Up[pos]=NULL;
    BWWM2Down[pos]=NULL;    
    AO=iAO(NULL,0,pos);
    AO1=iAO(NULL,0,pos+1);
    AO2=iAO(NULL,0,pos+2);
    AO3=iAO(NULL,0,pos+3);
    AO4=iAO(NULL,0,pos+4);
   
    if (
        (AO4>0.0 && AO3>0.0 ) 
          && 
        (AO4<AO3 && AO3>AO2 && AO2>AO1 && AO1>AO)
       ) 
        BWWM2Up[pos]=(High[pos]+updown*Point);
        
    if (
        (AO4<0.0 && AO3<0.0 ) 
          && 
        (AO4>AO3 && AO3<AO2 && AO2<AO1 && AO1<AO)
       ) 
        BWWM2Down[pos]=(Low[pos]-updown*Point);
     pos--;    
    }
    
     
    return(0);
  }
//+------------------------------------------------------------------+