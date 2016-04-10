  //+------------------------------------------------------------------+
//|                                                          TSI.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow
//---- input parameters
extern int       First_R=5;
extern int       Second_S=8;
//---- buffers
double TSI_Buffer[];
double MTM_Buffer[];
double EMA_MTM_Buffer[];
double EMA2_MTM_Buffer[];
double ABSMTM_Buffer[];
double EMA_ABSMTM_Buffer[];
double EMA2_ABSMTM_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(7);
   SetIndexBuffer(1, MTM_Buffer);
   SetIndexBuffer(2, EMA_MTM_Buffer);
   SetIndexBuffer(3, EMA2_MTM_Buffer);
   SetIndexBuffer(4, ABSMTM_Buffer);
   SetIndexBuffer(5, EMA_ABSMTM_Buffer);
   SetIndexBuffer(6, EMA2_ABSMTM_Buffer);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TSI_Buffer);
   SetIndexLabel(0,"TSI");
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
   int    counted_bars=IndicatorCounted();
   int limit,i;
   limit=Bars-counted_bars-1;
   for (i=Bars-1;i>=0;i--)
      {
      MTM_Buffer[i]=Close[i]-Close[i+1];//iMomentum(NULL,0,1,PRICE_CLOSE,i);
      ABSMTM_Buffer[i]=MathAbs(MTM_Buffer[i]);
      //TSI_Buffer[i]=ABSMTM_Buffer[i];
      }
      
   for (i=Bars-1;i>=0;i--)
      {
      EMA_MTM_Buffer[i]=iMAOnArray(MTM_Buffer,0,First_R,0,MODE_EMA,i);
      EMA_ABSMTM_Buffer[i]=iMAOnArray(ABSMTM_Buffer,0,First_R,0,MODE_EMA,i);
      //TSI_Buffer[i]=EMA_ABSMTM_Buffer[i];
      }

   for (i=Bars-1;i>=0;i--)
      {
      EMA2_MTM_Buffer[i]=iMAOnArray(EMA_MTM_Buffer,0,Second_S,0,MODE_EMA,i);
      EMA2_ABSMTM_Buffer[i]=iMAOnArray(EMA_ABSMTM_Buffer,0,Second_S,0,MODE_EMA,i);
      //TSI_Buffer[i]=EMA2_ABSMTM_Buffer[i];
      }

   for (i=Bars-1;i>=0;i--)
      {
      TSI_Buffer[i]=100.0*EMA2_MTM_Buffer[i]/EMA2_ABSMTM_Buffer[i];
      }
      
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+