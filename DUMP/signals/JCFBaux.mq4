//версия от 09.10.2005
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//|                                                      JCFBaux.mq4 |
//|       JCFBaux: Copyright © 2005,            Weld, Jurik Research | 
//|                                          http://weld.torguem.net | 
//|          MQL4: Copyright © 2005,                Nikolay Kositsin | 
//|                                   Khabarovsk, violet@mail.kht.ru |   
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
#property copyright "Weld" 
#property link "http://weld.torguem.net" 
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Magenta
//---- input parameters
extern int Depth=15;
extern int Input_Price_Customs = 2;//Выбор цен, по которым производится расчёт индикатора 
//(0-"Close", 1-"Open", 2-"High+Low", 3-"High", 4-"Low", 5-"Open+High+Low+Close", 6-Open+Close", по умолчанию-2.) 
//---- buffers
double JCFBaux[];
double @Series[];
//----
int    Bar,jrc07,Tnew,T0,T1,x;
double jrc04,jrc05,jrc06,jrc08,jrc03,jrc13,JRC04,JRC05,JRC06,Value;
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| Custom indicator initialization function                         |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int init()
  {
//---- indicators
   int draw_begin;draw_begin=Depth;
   SetIndexDrawBegin(0,draw_begin);
   SetIndexStyle (0,DRAW_LINE);
   IndicatorBuffers(2); 
   SetIndexBuffer(0,JCFBaux);
   SetIndexBuffer(1,@Series);
   SetIndexLabel (0,"JCFBaux");  
   IndicatorShortName ("JCFBaux");  
   SetIndexEmptyValue(0,0.0); 
   SetIndexEmptyValue(1,0.0); 
//----
return(0);
  }
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
//| JCFBaux CODE                                                     |
//+SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS+
int start()
{
int counted_bars=IndicatorCounted();
if (counted_bars<0) return(-1);
int limit=Bars-counted_bars-1; 

Tnew=Time[limit+1];

//+--- восстановление переменных ===================================================================+
if((Tnew!=T0)&&(limit!=Bars-1))if (Tnew==T1){jrc04=JRC04; jrc05=JRC05; jrc06=JRC06;}else return(-1);
//+--- =============================================================================================+  

switch(Input_Price_Customs)
{
//----+ Выбор цен, по которым производится расчёт индикатора +----------------------+
case   0:for(x=limit; x>=0; x--)@Series[x]=Close[x];break;
case   1:for(x=limit; x>=0; x--)@Series[x]=Open [x];break;
case   2:for(x=limit; x>=0; x--)@Series[x]=High [x]+Low  [x];break;
case   3:for(x=limit; x>=0; x--)@Series[x]=High [x];break;
case   4:for(x=limit; x>=0; x--)@Series[x]=Low  [x];break;
case   5:for(x=limit; x>=0; x--)@Series[x]=Open [x]+High [x]+Low[x]+Close[x];break;
case   6:for(x=limit; x>=0; x--)@Series[x]=Open [x]+Close[x];break;
default :for(x=limit; x>=0; x--)@Series[x]=High [x]+Low  [x];break;
//----+-----------------------------------------------------------------------------+
}
  for(Bar=limit;Bar>=0;Bar--)
  {
//+++++++++++++++++++++++++++++++++
    if(Bar>=Bars-Depth*2)  
    {
      jrc04 = 0.0;jrc05 = 0.0;jrc06 = 0.0;
      
      for(jrc07=Depth-1;jrc07>=0;jrc07--)
       {
        jrc04 = jrc04 + MathAbs(@Series[Bar+jrc07] - @Series[Bar+jrc07+1]);
        jrc05 = jrc05 + (Depth + jrc07) * MathAbs(@Series[Bar+jrc07] - @Series[Bar+jrc07+1]);
        jrc06 = jrc06 + @Series[Bar+jrc07+1];
       }
    }     
    if(Bar<Bars-Depth*2)   
    {
      jrc03 = MathAbs(@Series[Bar] - @Series[Bar+1]);
      jrc13 = MathAbs(@Series[Bar+Depth] - @Series[Bar+Depth+1]);
      jrc04 = jrc04 - jrc13 + jrc03;
      jrc05 = jrc05 - jrc04 + jrc03 * Depth;
      jrc06 = jrc06 - @Series[Bar+Depth+1] + @Series[Bar+1];
    }
    jrc08 = MathAbs(Depth * @Series[Bar] - jrc06);
    if (jrc05 == 0.0) Value = 0.0;else Value = jrc08 / jrc05;
    JCFBaux[Bar] = Value;
    
//+--- Сохранение переменных ================================================+  
    if (Bar==1){T1=Time[1];T0=Time[0];JRC04=jrc04; JRC05=jrc05; JRC06=jrc06;}
//+--- ======================================================================+        
  }
//+++++++++++++++++++++++++++++++++
return(0);
}