//+------------------------------------------------------------------+ 
//|                                                  BrainTrend2.mq4 | 
//|                                                BrainTrading Inc. | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "BrainTrading Inc." 
#property link      "" 

#property indicator_chart_window 
#property indicator_buffers 2 
#property indicator_color1 Blue 
#property indicator_color2 Red 
//---- input parameters 
extern int       NumBars=5000; 
//---- buffers 
double ExtMapBuffer1[]; 
double ExtMapBuffer2[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init() 
  { 
//---- indicators 
   SetIndexStyle(0,DRAW_HISTOGRAM); 
   SetIndexBuffer(0,ExtMapBuffer1); 
   SetIndexStyle(1,DRAW_HISTOGRAM); 
   SetIndexBuffer(1,ExtMapBuffer2); 
//---- 
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
   int    counted_bars=IndicatorCounted(); 
//---- 
    
double    artp=7; 
double    cecf=0.7; 
int     satb=0; 
int    Shift=0; 
double    river=True; 
double    Emaxtra=0; 
double    widcha=0; 
double    TR=0; 
double    Values[100]; 
int    glava=0; 
double    ATR=0; 
int   J=0; 
double    Weight=0; 
double    r=0; 
double    r1=0; 
double    p=0; 
int    Curr=0; 
double    Range1=0; 
double    s=2; 
double    f=10; 
double    val1=0; 
double    val2=0; 
double    h11=0; 
double    h12=0; 
double    h13=0; 
double    const=0; 
double    orig=0; 
double    st=0; 
double    h2=0; 
double    h1=0; 
double    h10=0; 
double    sxs=0; 
double    sms=0; 
double    temp=0; 
double    h5=0; 
double    r1s=0; 
double    r2s=0; 
double    r3s=0; 
double    r4s=0; 
double    pt=0; 
double    pts=0; 
double    r2=0; 
double    r3=0; 
double    r4=0; 
double    tt=0; 


st=1; 
if( st == 1) 
   { 
   if( Bars < NumBars) satb = Bars; else satb = NumBars; 
   if( Close[satb - 2] > Close[satb - 1]) river = True; else river = False; 
   Emaxtra = Close[satb - 2]; 
  Shift=satb-3; 
    
   while(Shift>=0) 
  
  
      { 
      TR = High[Shift] - Low[Shift]; 
      if( MathAbs(High[Shift] - Close[Shift + 1]) > TR ) TR = MathAbs(High[Shift] - Close[Shift + 1]); 
      if( MathAbs(Low[Shift] - Close[Shift + 1]) > TR)  TR = MathAbs(Low[Shift] - Close[Shift + 1]); 
      if (Shift == satb - 3 ) 
         { 
         for(J=0;Shift==artp-1;Shift++) 
      
         { Values[J] = TR; } 
         }    
    
 Values[glava] = TR; 
      ATR = 0; 
      Weight = artp; 
      Curr = glava; 
      for (J = 0;J== artp - 1;J++) 
         { 
         ATR += Values[Curr] * Weight; 
         Weight -= 1; 
         Curr -= 1; 
         if (Curr == -1) Curr = artp - 1; 
         } 
      ATR = 2 * ATR / (artp * (artp + 1)); 
      glava += 1; 
      if (glava == artp) glava = 0; 
      widcha = cecf * ATR; 
      if (river && Low[Shift] < Emaxtra - widcha) 
         { 
         river = False; 
         Emaxtra = High[Shift]; 
         } 
      if (river && High[Shift] < Emaxtra + widcha) 
         { 
         river = True; 
         Emaxtra = Low[Shift]; 
         } 
      if (river && Low[Shift] > Emaxtra) 
         { 
         Emaxtra = Low[Shift]; 
         } 
      if (river && High[Shift] < Emaxtra ) 
         { 
         Emaxtra = High[Shift]; 
         } 
      Range1 = iATR(NULL,0,10,Shift); 
      if( river==true ) 
               { 
         val1 = High[Shift]; 
         val2 = Low[Shift]; 
         } 
            else 
         { 
         val1 = Low[Shift]; 
         val2 = High[Shift]; 
         } 
       ExtMapBuffer1[Shift]=val1; 
       ExtMapBuffer2[Shift]=val1;  
     Shift--; 
      } 
   } 
    
//---- 
   return(0); 
  } 
//+------------------------------------------------------------------+