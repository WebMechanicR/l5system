//+------------------------------------------------------------------+
//|                                              SuperWoodiesCCI.mq4 |
//|                                                           duckfu |
//|                                          http://www.dopeness.org |
//+------------------------------------------------------------------+
#property copyright "duckfu"
#property link      "http://www.dopeness.org"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 White // CCI Colour (note the superfluous vowel, cheers mates ;)
#property indicator_color2 Yellow // TCCI Colour
#property indicator_color3 LimeGreen // Long Trend Histogram Colour 
#property indicator_color4 Red // Short Trend Histogram Colour
#property indicator_color5 Blue // No Trend Histogram Colour
//---- input parameters
extern int       CCI_Period=50;
extern int       TCCI_Period=0;
//---- buffers
double ExtCCIBuffer[];
double ExtTCCIBuffer[];
double ExtLongHistBuffer[];
double ExtShortHistBuffer[];
double ExtFlatHistBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(0,ExtCCIBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtTCCIBuffer);
   SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(2,ExtLongHistBuffer);
   SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(3,ExtShortHistBuffer);
   SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,1);
   SetIndexBuffer(4,ExtFlatHistBuffer);
   ArrayInitialize(ExtCCIBuffer,0);
   ArrayInitialize(ExtTCCIBuffer,0);
   ArrayInitialize(ExtLongHistBuffer,0);
   ArrayInitialize(ExtShortHistBuffer,0);
   ArrayInitialize(ExtFlatHistBuffer,0);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){
//---- TODO: add your code here
   
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
   int i,j,limit,counted_bars=IndicatorCounted();
   int uptrending=0,downtrending=0;
//---- TODO: add your code here
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop
   for(i=0; i<limit; i++){
      ExtCCIBuffer[i]=iCCI(NULL,0,CCI_Period,PRICE_TYPICAL,i);
      ExtTCCIBuffer[i]=iCCI(NULL,0,TCCI_Period,PRICE_TYPICAL,i);
      ExtFlatHistBuffer[i]=ExtCCIBuffer[i];     
   }
   
   for(i=0;i<limit;i++){
      for(j=0;j<6;j++){
         if(ExtCCIBuffer[i+j] > 0){
            uptrending++;
         } else if(ExtCCIBuffer[i+j] < 0){
            uptrending=0;         
         }
      }
      
      if(uptrending>5){
         ExtLongHistBuffer[i]=ExtCCIBuffer[i];
         ExtShortHistBuffer[i]=0;
         ExtFlatHistBuffer[i]=0;
      }
   }
   
   for(i=0;i<limit;i++){
      for(j=0;j<6;j++){
         if(ExtCCIBuffer[i+j] < 0){
            downtrending++;
         } else if(ExtCCIBuffer[i+j] > 0){
            downtrending=0;
         }
      }
      
      if(downtrending>5){
         ExtShortHistBuffer[i]=ExtCCIBuffer[i];
         ExtLongHistBuffer[i]=0;
         ExtFlatHistBuffer[i]=0;
      }
   }
   return(0);
}
//+------------------------------------------------------------------+
