//+------------------------------------------------------------------+
//| SATLs.mq4 
//| Ramdass - Conversion only
//+------------------------------------------------------------------+
#property copyright "Copyright 2002, Finware.ru Ltd."
#property link "http://www.finware.ru/"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red

extern int CountBars=300;
//---- buffers
double UPBuffer[];
double DownBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,241);
   SetIndexBuffer(0,UPBuffer);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,242);
   SetIndexBuffer(1,DownBuffer);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| SATLs                                                             |
//+------------------------------------------------------------------+
int start()
  {
   SetIndexDrawBegin(0,Bars-CountBars+38);
   SetIndexDrawBegin(1,Bars-CountBars+38);
   int i,counted_bars=IndicatorCounted();
   double val1, val2, i1;
   bool trend,old;
//----
   if(Bars<=38) return(0);
//---- initial zero
   if(counted_bars<38)
   {
      for(i=1;i<=0;i++) UPBuffer[CountBars-i]=0.0;
      for(i=1;i<=0;i++) DownBuffer[CountBars-i]=0.0;
   }
//----
   i=CountBars-38-1;
//   if(counted_bars>=38) i=Bars-counted_bars-1;
   while(i>=0)
     {
      val1=
0.0982862174*Close[i+0]
+0.0975682269*Close[i+1]
+0.0961401078*Close[i+2]
+0.0940230544*Close[i+3]
+0.0912437090*Close[i+4]
+0.0878391006*Close[i+5]
+0.0838544303*Close[i+6]
+0.0793406350*Close[i+7]
+0.0743569346*Close[i+8]
+0.0689666682*Close[i+9]
+0.0632381578*Close[i+10]
+0.0572428925*Close[i+11]
+0.0510534242*Close[i+12]
+0.0447468229*Close[i+13]
+0.0383959950*Close[i+14]
+0.0320735368*Close[i+15]
+0.0258537721*Close[i+16]
+0.0198005183*Close[i+17]
+0.0139807863*Close[i+18]
+0.0084512448*Close[i+19]
+0.0032639979*Close[i+20]
-0.0015350359*Close[i+21]
-0.0059060082*Close[i+22]
-0.0098190256*Close[i+23]
-0.0132507215*Close[i+24]
-0.0161875265*Close[i+25]
-0.0186164872*Close[i+26]
-0.0205446727*Close[i+27]
-0.0219739146*Close[i+28]
-0.0229204861*Close[i+29]
-0.0234080863*Close[i+30]
-0.0234566315*Close[i+31]
-0.0231017777*Close[i+32]
-0.0223796900*Close[i+33]
-0.0213300463*Close[i+34]
-0.0199924534*Close[i+35]
-0.0184126992*Close[i+36]
-0.0166377699*Close[i+37]
-0.0147139428*Close[i+38]
-0.0126796776*Close[i+39]
-0.0105938331*Close[i+40]
-0.0084736770*Close[i+41]
-0.0063841850*Close[i+42]
-0.0043466731*Close[i+43]
-0.0023956944*Close[i+44]
-0.0005535180*Close[i+45]
+0.0011421469*Close[i+46]
+0.0026845693*Close[i+47]
+0.0040471369*Close[i+48]
+0.0052380201*Close[i+49]
+0.0062194591*Close[i+50]
+0.0070340085*Close[i+51]
+0.0076266453*Close[i+52]
+0.0080376628*Close[i+53]
+0.0083037666*Close[i+54]
+0.0083694798*Close[i+55]
+0.0082901022*Close[i+56]
+0.0080741359*Close[i+57]
+0.0077543820*Close[i+58]
+0.0073260526*Close[i+59]
+0.0068163569*Close[i+60]
+0.0062325477*Close[i+61]
+0.0056078229*Close[i+62]
+0.0049516078*Close[i+63]
+0.0161380976*Close[i+64];

val2=
0.0982862174*Close[i+0+1]
+0.0975682269*Close[i+1+1]
+0.0961401078*Close[i+2+1]
+0.0940230544*Close[i+3+1]
+0.0912437090*Close[i+4+1]
+0.0878391006*Close[i+5+1]
+0.0838544303*Close[i+6+1]
+0.0793406350*Close[i+7+1]
+0.0743569346*Close[i+8+1]
+0.0689666682*Close[i+9+1]
+0.0632381578*Close[i+10+1]
+0.0572428925*Close[i+11+1]
+0.0510534242*Close[i+12+1]
+0.0447468229*Close[i+13+1]
+0.0383959950*Close[i+14+1]
+0.0320735368*Close[i+15+1]
+0.0258537721*Close[i+16+1]
+0.0198005183*Close[i+17+1]
+0.0139807863*Close[i+18+1]
+0.0084512448*Close[i+19+1]
+0.0032639979*Close[i+20+1]
-0.0015350359*Close[i+21+1]
-0.0059060082*Close[i+22+1]
-0.0098190256*Close[i+23+1]
-0.0132507215*Close[i+24+1]
-0.0161875265*Close[i+25+1]
-0.0186164872*Close[i+26+1]
-0.0205446727*Close[i+27+1]
-0.0219739146*Close[i+28+1]
-0.0229204861*Close[i+29+1]
-0.0234080863*Close[i+30+1]
-0.0234566315*Close[i+31+1]
-0.0231017777*Close[i+32+1]
-0.0223796900*Close[i+33+1]
-0.0213300463*Close[i+34+1]
-0.0199924534*Close[i+35+1]
-0.0184126992*Close[i+36+1]
-0.0166377699*Close[i+37+1]
-0.0147139428*Close[i+38+1]
-0.0126796776*Close[i+39+1]
-0.0105938331*Close[i+40+1]
-0.0084736770*Close[i+41+1]
-0.0063841850*Close[i+42+1]
-0.0043466731*Close[i+43+1]
-0.0023956944*Close[i+44+1]
-0.0005535180*Close[i+45+1]
+0.0011421469*Close[i+46+1]
+0.0026845693*Close[i+47+1]
+0.0040471369*Close[i+48+1]
+0.0052380201*Close[i+49+1]
+0.0062194591*Close[i+50+1]
+0.0070340085*Close[i+51+1]
+0.0076266453*Close[i+52+1]
+0.0080376628*Close[i+53+1]
+0.0083037666*Close[i+54+1]
+0.0083694798*Close[i+55+1]
+0.0082901022*Close[i+56+1]
+0.0080741359*Close[i+57+1]
+0.0077543820*Close[i+58+1]
+0.0073260526*Close[i+59+1]
+0.0068163569*Close[i+60+1]
+0.0062325477*Close[i+61+1]
+0.0056078229*Close[i+62+1]
+0.0049516078*Close[i+63+1]
+0.0161380976*Close[i+64+1];

 i1=val1-val2;
UPBuffer[i]=0.0; DownBuffer[i]=0.0;

if (i1>0) trend=true;
if (i1<0) trend=false;

if ((! trend==old) && trend==true) UPBuffer[i]=Low[i]-5*Point;
if ((! trend==old) && trend==false) DownBuffer[i]=High[i]+5*Point;
old=trend;

      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+