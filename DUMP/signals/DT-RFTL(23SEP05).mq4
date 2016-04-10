//+------------------------------------------------------------------+ 
//|                                                       DT-FATL.mq4 | 
//+------------------------------------------------------------------+ 
#property copyright "klot" 
#property link      "klot@mail.ru" 

#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Magenta 

extern int GrossPeriod=240; // Старший период в минутах 

datetime daytimes[]; 
//---- buffers 
double ExtMapBuffer1[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 
//---- indicators 
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexArrow(0,159); 
   SetIndexBuffer(0,ExtMapBuffer1); 
   SetIndexEmptyValue(0,0.0); 
   if (Period()>GrossPeriod) { Alert("DT-RSTL: Текущий таймфрейм должен быть меньше чем ", GrossPeriod); return(0); } 
//---- 


// Все Time[] серии времени отсортировано в направлении убывания 
ArrayCopySeries(daytimes,MODE_TIME,Symbol(),GrossPeriod); 

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
   int    limit, bigshift; 
   int    counted_bars=IndicatorCounted(); 
//---- 
   if (counted_bars<0) return(-1); 
    
   if (counted_bars>0) counted_bars--; 
    
   limit=Bars-counted_bars; 
    
   for (int i=0; i<limit; i++) 
   { 
   if(Time[i]>=daytimes[0]) bigshift=0; 
   else 
     { 
      bigshift = ArrayBsearch(daytimes,Time[i-1],WHOLE_ARRAY,0,MODE_DESCEND); 
      if(Period()<=GrossPeriod) bigshift++; 
     } 
  ExtMapBuffer1[i]=iCustom(NULL,GrossPeriod,"RFTL",0,bigshift); 
   } 
//---- 
   return(0); 
  } 
//+------------------------------------------------------------------+ 

