//+------------------------------------------------------------------+ 
//| T3 Bands.mq4 | 
//| 
//| | 
//+------------------------------------------------------------------+ 

#property indicator_separate_window 
#property indicator_buffers 6 
#property indicator_color1 Green 
#property indicator_color2 Red 
#property indicator_color3 Blue 
#property indicator_color4 Yellow 
#property indicator_color5 Silver 
#property indicator_color6 Black 

extern int MA_Period_1 = 5; 
extern int MA_Period_2 = 15; 
extern int MA_Period_3 = 20; 
extern int MA_Period_4 = 35; 
extern int MA_Period_5 = 80; 
extern int MA_Period_6 = 280; 
#include "" 

extern double b = 0.86; 

double MapBuffer1[]; 
double MapBuffer2[]; 
double MapBuffer3[]; 
double MapBuffer4[]; 
double MapBuffer5[]; 
double MapBuffer6[]; 

double e1[6],e2[6],e3[6],e4[6],e5[6],e6[6]; 
double c1[6],c2[6],c3[6],c4[6]; 
double n[6],w1[6],w2[6],b2[6],b3[6]; 

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() 
{ 
//---- indicators setting 
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Green); 
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,Red); 
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,Blue); 
SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,Yellow); 
SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1,Silver); 
SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,2,Black); 
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)); 
IndicatorShortName("T3 Bands"); 

SetIndexBuffer(0,MapBuffer1); 
SetIndexBuffer(1,MapBuffer2); 
SetIndexBuffer(2,MapBuffer3); 
SetIndexBuffer(3,MapBuffer4); 
SetIndexBuffer(4,MapBuffer5); 
SetIndexBuffer(5,MapBuffer6); 
//---- variable reset 
n[1]=MA_Period_1; 
n[2]=MA_Period_2; 
n[3]=MA_Period_3; 
n[4]=MA_Period_4; 
n[5]=MA_Period_5; 
n[6]=MA_Period_6; 

for(int l=1; l<7; l++) 
{ 

e1[l]=0; e2[l]=0; e3[l]=0; e4[l]=0; e5[l]=0; e6[l]=0; 
c1[l]=0; c2[l]=0; c3[l]=0; c4[l]=0; 
w1[l]=0; w2[l]=0; 
b2[l]=0; b3[l]=0; 

b2[l]=b*b; 
b3[l]=b2[l]*b; 
c1[l]=-b3[l]; 
c2[l]=(3*(b2[l]+b3[l])); 
c3[l]=-3*(2*b2[l]+b+b3[l]); 
c4[l]=(1+3*b+b3[l]+3*b2[l]); 

if (n[l]<1) n[l]=1; 
n[l] = 1 + 0.5*(n[l]-1); 
w1[l] = 2 / (n[l] + 1); 
w2[l] = 1 - w1[l]; 
} 



//---- 
return(0); 
} 

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function | 
//+------------------------------------------------------------------+ 
int start() 
{ 
int limit,MB[],ii,i; 
int counted_bars=IndicatorCounted(); 
if (counted_bars<0) return (-1); 
if (counted_bars>0) counted_bars--; 
limit=Bars-counted_bars; 
//---- indicator calculation 



for(i=limit; i>=0; i--) 
{ 

for(ii=1; ii<7; ii++) 
{ 
e1[ii] = w1[ii]*Close[i] + w2[ii]*e1[ii]; 
e2[ii] = w1[ii]*e1[ii] + w2[ii]*e2[ii]; 
e3[ii] = w1[ii]*e2[ii] + w2[ii]*e3[ii]; 
e4[ii] = w1[ii]*e3[ii] + w2[ii]*e4[ii]; 
e5[ii] = w1[ii]*e4[ii] + w2[ii]*e5[ii]; 
e6[ii] = w1[ii]*e5[ii] + w2[ii]*e6[ii]; 

if (ii==1) MapBuffer1[i]=c1[ii]*e6[ii] + c2[ii]*e5[ii] + c3[ii]*e4[ii] + c4[ii]*e3[ii]; 
if (ii==2) MapBuffer2[i]=c1[ii]*e6[ii] + c2[ii]*e5[ii] + c3[ii]*e4[ii] + c4[ii]*e3[ii]; 
if (ii==3) MapBuffer3[i]=c1[ii]*e6[ii] + c2[ii]*e5[ii] + c3[ii]*e4[ii] + c4[ii]*e3[ii]; 
if (ii==4) MapBuffer4[i]=c1[ii]*e6[ii] + c2[ii]*e5[ii] + c3[ii]*e4[ii] + c4[ii]*e3[ii]; 
if (ii==5) MapBuffer5[i]=c1[ii]*e6[ii] + c2[ii]*e5[ii] + c3[ii]*e4[ii] + c4[ii]*e3[ii]; 
if (ii==6) MapBuffer6[i]=c1[ii]*e6[ii] + c2[ii]*e5[ii] + c3[ii]*e4[ii] + c4[ii]*e3[ii]; 
} 
} 

//---- 
return(0); 
} 
//+------------------------------------------------------------------+

