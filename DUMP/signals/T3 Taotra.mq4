//+------------------------------------------------------------------+
//| T3.mq4 |
//| 
//| |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Magenta
#property indicator_color4 Aqua
#property indicator_color5 White
#property indicator_color6 Blue

extern int MA_Period_1 = 3;
extern int MA_Period_2 = 5;
extern int MA_Period_3 = 0; //8
extern int MA_Period_4 = 0; //12
extern int MA_Period_5 = 21;
extern int MA_Period_6 = 34;

extern double b = 0.7;

double MapBuffer1[];
double MapBuffer2[];
double MapBuffer3[];
double MapBuffer4[];
double MapBuffer5[];
double MapBuffer6[];

double e1[][7],e2[][7],e3[][7],e4[][7],e5[][7],e6[][7];
double c1[7],c2[7],c3[7],c4[7];
double n[7],w1[7],w2[7],b2[7],b3[7];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators setting
SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Yellow);
SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,Red);
SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,Magenta);
SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,Aqua);
SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2,White);
SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,2,Blue);
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
IndicatorShortName("T3");
SetIndexDrawBegin(0,100);
SetIndexDrawBegin(1,100);
SetIndexDrawBegin(2,100);
SetIndexDrawBegin(3,100);
SetIndexDrawBegin(4,100);
SetIndexDrawBegin(5,100);
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

//e2[l]=0; e3[l]=0; e4[l]=0; e5[l]=0; e6[l]=0;
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
limit=(Bars-counted_bars)-1;
//---- indicator calculation

ArrayResize(e1, Bars+1);
ArrayResize(e2, Bars+1);
ArrayResize(e3, Bars+1);
ArrayResize(e4, Bars+1);
ArrayResize(e5, Bars+1);
ArrayResize(e6, Bars+1);

for(i=limit; i>=0; i--)
{

for(ii=1; ii<7; ii++)
{
e1[Bars-i][ii] = w1[ii]*Close[i] + w2[ii]*e1[(Bars-i)-1][ii];
e2[Bars-i][ii] = w1[ii]*e1[Bars-i][ii] + w2[ii]*e2[(Bars-i)-1][ii];
e3[Bars-i][ii] = w1[ii]*e2[Bars-i][ii] + w2[ii]*e3[(Bars-i)-1][ii];
e4[Bars-i][ii] = w1[ii]*e3[Bars-i][ii] + w2[ii]*e4[(Bars-i)-1][ii];
e5[Bars-i][ii] = w1[ii]*e4[Bars-i][ii] + w2[ii]*e5[(Bars-i)-1][ii];
e6[Bars-i][ii] = w1[ii]*e5[Bars-i][ii] + w2[ii]*e6[(Bars-i)-1][ii];

if (ii==1) MapBuffer1[i]=c1[ii]*e6[Bars-i][ii] + c2[ii]*e5[Bars-i][ii] + c3[ii]*e4[Bars-i][ii] + c4[ii]*e3[Bars-i][ii];
if (ii==2) MapBuffer2[i]=c1[ii]*e6[Bars-i][ii] + c2[ii]*e5[Bars-i][ii] + c3[ii]*e4[Bars-i][ii] + c4[ii]*e3[Bars-i][ii];
if (ii==3) MapBuffer3[i]=c1[ii]*e6[Bars-i][ii] + c2[ii]*e5[Bars-i][ii] + c3[ii]*e4[Bars-i][ii] + c4[ii]*e3[Bars-i][ii];
if (ii==4) MapBuffer4[i]=c1[ii]*e6[Bars-i][ii] + c2[ii]*e5[Bars-i][ii] + c3[ii]*e4[Bars-i][ii] + c4[ii]*e3[Bars-i][ii];
if (ii==5) MapBuffer5[i]=c1[ii]*e6[Bars-i][ii] + c2[ii]*e5[Bars-i][ii] + c3[ii]*e4[Bars-i][ii] + c4[ii]*e3[Bars-i][ii];
if (ii==6) MapBuffer6[i]=c1[ii]*e6[Bars-i][ii] + c2[ii]*e5[Bars-i][ii] + c3[ii]*e4[Bars-i][ii] + c4[ii]*e3[Bars-i][ii];
}
}

//----
return(0);
}
//+------------------------------------------------------------------+

