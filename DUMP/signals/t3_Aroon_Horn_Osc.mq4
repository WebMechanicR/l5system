//+-------------------------------------------------------------------------+
//| t3_Aroon_Horn_Osc.mq4                                                   |
//| Copyright © 2005,                                                       |
//| http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/|
//+-------------------------------------------------------------------------+
#property copyright "Copyright © 2005,"
#property link      "http://finance.groups.yahoo.com/group/MetaTrader_Experts_and_Indicators/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
#property indicator_level1 0

extern double Aroon_Horn_Period = 5.0;
extern double T3_Period = 5.0;
extern double b = 0.500;
extern int CountBars=200;

double MapBuffer[];

double e1,e2,e3,e4,e5,e6;
double c1,c2,c3,c4;
double n,w1,w2,b2,b3;
double m1,m2,med;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators setting
    SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,DodgerBlue);
    IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
    IndicatorShortName("t3_Aroon_Horn_Osc "+T3_Period);
    
    SetIndexBuffer(0,MapBuffer);

//---- variable reset

    e1=0; e2=0; e3=0; e4=0; e5=0; e6=0;
    c1=0; c2=0; c3=0; c4=0; 
    n=0; 
    w1=0; w2=0; 
    b2=0; b3=0;

    b2=b*b;
    b3=b2*b;
    c1=-b3;
    c2=(3*(b2+b3));
    c3=-3*(2*b2+b+b3);
    c4=(1+3*b+b3+3*b2);
    n=T3_Period;

    if (n<1) n=1;
    n = 1 + (0.5*(n-1));
    w1 = 2 / (n + 1);
    w2 = 1 - w1;
    
//----
    return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit=500;

//---- indicator calculation

    for(int i=limit; i>=0; i--)
    {
        
        m1=(iCustom(Symbol(), 0, "Aroon_Horn",Aroon_Horn_Period,0,i));
        m2=(iCustom(Symbol(), 0, "Aroon_Horn",Aroon_Horn_Period,1,i));
        //m1=(High[i]-Low[i]);
        //m2=(High[i+1]-Low[i+1]);
        med=m1-m2;
        
        e1 = ((w1*med) + w2*e1);
        e2 = ((w1*e1) + w2*e2);
        e3 = ((w1*e2) + w2*e3);
        e4 = ((w1*e3) + w2*e4);
        e5 = ((w1*e4) + w2*e5);
        e6 = ((w1*e5) + w2*e6);
    
        MapBuffer[i]=((((c1*e6) + c2*e5) + c3*e4) + c4*e3)*1000;

    }   
//----
   return(0);
  }
//+------------------------------------------------------------------+