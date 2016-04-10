//+------------------------------------------------------------------+
//| RBCI_hist.mq4 
//| Ramdass - Conversion only
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int CountBars=300;
//---- buffers
double Up[];
double Down[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Down);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| RBCI                                                             |
//+------------------------------------------------------------------+
int start()
  {
   SetIndexDrawBegin(0,Bars-CountBars+73);
   SetIndexDrawBegin(1,Bars-CountBars+73);
   int i,i2,counted_bars=IndicatorCounted();
   double RBCI,RBCI1,value1,value2,value3,value4;
//----
   if(CountBars<=73) return(0);
//---- initial zero
   if(counted_bars<73)
   {
      for(i=1;i<=0;i++) Up[CountBars-i]=0.0;
      for(i=1;i<=0;i++) Down[CountBars-i]=0.0;
   }
//----
   i=CountBars-73-1;
//   if(counted_bars>=73) i=Bars-counted_bars-1;
   while(i>=0)
     {

value2 = 
0.08269258*Close[i+0]
+0.08210489*Close[i+1]
+0.08093874*Close[i+2]
+0.07921003*Close[i+3]
+0.07694005*Close[i+4]
+0.07415944*Close[i+5]
+0.07090508*Close[i+6]
+0.06722010*Close[i+7]
+0.06314921*Close[i+8]
+0.05874928*Close[i+9]
+0.05407277*Close[i+10]
+0.04918011*Close[i+11]
+0.04413127*Close[i+12]
+0.03898817*Close[i+13]
+0.03381087*Close[i+14]
+0.02866037*Close[i+15]
+0.02359602*Close[i+16]
+0.01867285*Close[i+17]
+0.01394154*Close[i+18]
+0.00945020*Close[i+19]
+0.00524380*Close[i+20]
+0.00135856*Close[i+21]
-0.00217576*Close[i+22]
-0.00533362*Close[i+23]
-0.00809235*Close[i+24]
-0.01044596*Close[i+25]
-0.01238246*Close[i+26]
-0.01390515*Close[i+27]
-0.01501922*Close[i+28]
-0.01573813*Close[i+29]
-0.01607903*Close[i+30]
-0.01606501*Close[i+31]
-0.01572265*Close[i+32]
-0.01508076*Close[i+33]
-0.01417155*Close[i+34]
-0.01303199*Close[i+35]
-0.01170149*Close[i+36]
-0.01021570*Close[i+37]
-0.00860941*Close[i+38]
-0.00692232*Close[i+39]
-0.00519812*Close[i+40]
-0.00345733*Close[i+41]
-0.00174477*Close[i+42]
-0.00008354*Close[i+43]
+0.00149695*Close[i+44]
+0.00297402*Close[i+45]
+0.00432644*Close[i+46]
+0.00553786*Close[i+47]
+0.00659613*Close[i+48]
+0.00749328*Close[i+49]
+0.00822608*Close[i+50]
+0.00879528*Close[i+51]
+0.00920238*Close[i+52]
+0.00944568*Close[i+53]
+0.00952717*Close[i+54]
+0.00946588*Close[i+55]
+0.00929962*Close[i+56]
+0.00898757*Close[i+57]
+0.00859207*Close[i+58]
+0.00810829*Close[i+59]
+0.00755924*Close[i+60]
+0.00696141*Close[i+61]
+0.00633350*Close[i+62]
+0.00569343*Close[i+63]
+0.00505929*Close[i+64]
+0.00444999*Close[i+65]
+0.00388521*Close[i+66]
+0.00338555*Close[i+67]
+0.00297397*Close[i+68]
+0.00267839*Close[i+69]
+0.00253170*Close[i+70]
+0.00257620*Close[i+71]
-0.00816217*Close[i+72];

value1 = 
0.36423990*Close[i+0]
+0.33441085*Close[i+1]
+0.25372851*Close[i+2]
+0.14548806*Close[i+3]
+0.03934469*Close[i+4]
-0.03871426*Close[i+5]
-0.07451349*Close[i+6]
-0.06903411*Close[i+7]
-0.03611022*Close[i+8]
+0.00422528*Close[i+9]
+0.03382809*Close[i+10]
+0.04267885*Close[i+11]
+0.03120441*Close[i+12]
+0.00816037*Close[i+13]
-0.01442877*Close[i+14]
-0.02678947*Close[i+15]
-0.02525534*Close[i+16]
-0.01272910*Close[i+17]
+0.00350063*Close[i+18]
+0.01565175*Close[i+19]
+0.01895659*Close[i+20]
+0.01328613*Close[i+21]
+0.00252297*Close[i+22]
-0.00775517*Close[i+23]
-0.01301467*Close[i+24]
-0.01164808*Close[i+25]
-0.00527241*Close[i+26]
+0.00248750*Close[i+27]
+0.00793380*Close[i+28]
+0.00897632*Close[i+29]
+0.00583939*Close[i+30]
+0.00059669*Close[i+31]
-0.00405186*Close[i+32]
-0.00610944*Close[i+33]
-0.00509042*Close[i+34]
-0.00198138*Close[i+35]
+0.00144873*Close[i+36]
+0.00373774*Close[i+37]
+0.01047723*Close[i+38]
-0.00022625*Close[i+39];



value4 = 
0.08269258*Close[i+0+1]
+0.08210489*Close[i+1+1]
+0.08093874*Close[i+2+1]
+0.07921003*Close[i+3+1]
+0.07694005*Close[i+4+1]
+0.07415944*Close[i+5+1]
+0.07090508*Close[i+6+1]
+0.06722010*Close[i+7+1]
+0.06314921*Close[i+8+1]
+0.05874928*Close[i+9+1]
+0.05407277*Close[i+10+1]
+0.04918011*Close[i+11+1]
+0.04413127*Close[i+12+1]
+0.03898817*Close[i+13+1]
+0.03381087*Close[i+14+1]
+0.02866037*Close[i+15+1]
+0.02359602*Close[i+16+1]
+0.01867285*Close[i+17+1]
+0.01394154*Close[i+18+1]
+0.00945020*Close[i+19+1]
+0.00524380*Close[i+20+1]
+0.00135856*Close[i+21+1]
-0.00217576*Close[i+22+1]
-0.00533362*Close[i+23+1]
-0.00809235*Close[i+24+1]
-0.01044596*Close[i+25+1]
-0.01238246*Close[i+26+1]
-0.01390515*Close[i+27+1]
-0.01501922*Close[i+28+1]
-0.01573813*Close[i+29+1]
-0.01607903*Close[i+30+1]
-0.01606501*Close[i+31+1]
-0.01572265*Close[i+32+1]
-0.01508076*Close[i+33+1]
-0.01417155*Close[i+34+1]
-0.01303199*Close[i+35+1]
-0.01170149*Close[i+36+1]
-0.01021570*Close[i+37+1]
-0.00860941*Close[i+38+1]
-0.00692232*Close[i+39+1]
-0.00519812*Close[i+40+1]
-0.00345733*Close[i+41+1]
-0.00174477*Close[i+42+1]
-0.00008354*Close[i+43+1]
+0.00149695*Close[i+44+1]
+0.00297402*Close[i+45+1]
+0.00432644*Close[i+46+1]
+0.00553786*Close[i+47+1]
+0.00659613*Close[i+48+1]
+0.00749328*Close[i+49+1]
+0.00822608*Close[i+50+1]
+0.00879528*Close[i+51+1]
+0.00920238*Close[i+52+1]
+0.00944568*Close[i+53+1]
+0.00952717*Close[i+54+1]
+0.00946588*Close[i+55+1]
+0.00929962*Close[i+56+1]
+0.00898757*Close[i+57+1]
+0.00859207*Close[i+58+1]
+0.00810829*Close[i+59+1]
+0.00755924*Close[i+60+1]
+0.00696141*Close[i+61+1]
+0.00633350*Close[i+62+1]
+0.00569343*Close[i+63+1]
+0.00505929*Close[i+64+1]
+0.00444999*Close[i+65+1]
+0.00388521*Close[i+66+1]
+0.00338555*Close[i+67+1]
+0.00297397*Close[i+68+1]
+0.00267839*Close[i+69+1]
+0.00253170*Close[i+70+1]
+0.00257620*Close[i+71+1]
-0.00816217*Close[i+72+1];

value3 = 
0.36423990*Close[i+0+1]
+0.33441085*Close[i+1+1]
+0.25372851*Close[i+2+1]
+0.14548806*Close[i+3+1]
+0.03934469*Close[i+4+1]
-0.03871426*Close[i+5+1]
-0.07451349*Close[i+6+1]
-0.06903411*Close[i+7+1]
-0.03611022*Close[i+8+1]
+0.00422528*Close[i+9+1]
+0.03382809*Close[i+10+1]
+0.04267885*Close[i+11+1]
+0.03120441*Close[i+12+1]
+0.00816037*Close[i+13+1]
-0.01442877*Close[i+14+1]
-0.02678947*Close[i+15+1]
-0.02525534*Close[i+16+1]
-0.01272910*Close[i+17+1]
+0.00350063*Close[i+18+1]
+0.01565175*Close[i+19+1]
+0.01895659*Close[i+20+1]
+0.01328613*Close[i+21+1]
+0.00252297*Close[i+22+1]
-0.00775517*Close[i+23+1]
-0.01301467*Close[i+24+1]
-0.01164808*Close[i+25+1]
-0.00527241*Close[i+26+1]
+0.00248750*Close[i+27+1]
+0.00793380*Close[i+28+1]
+0.00897632*Close[i+29+1]
+0.00583939*Close[i+30+1]
+0.00059669*Close[i+31+1]
-0.00405186*Close[i+32+1]
-0.00610944*Close[i+33+1]
-0.00509042*Close[i+34+1]
-0.00198138*Close[i+35+1]
+0.00144873*Close[i+36+1]
+0.00373774*Close[i+37+1]
+0.01047723*Close[i+38+1]
-0.00022625*Close[i+39+1];



RBCI=value1-value2;
RBCI1=value3-value4;


if (RBCI>RBCI1) {Up[i]=RBCI;Down[i]=0.0;} else {Down[i]=RBCI;Up[i]=0.0;}

      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+