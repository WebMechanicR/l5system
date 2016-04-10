//+------------------------------------------------------------------+ 
//| RBCI.mq4 
//| 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2002, Finware.ru Ltd." 
#property link "http://www.finware.ru/" 

#property indicator_separate_window 
#property indicator_buffers 1 
#property indicator_color1 Blue 


//---- buffers 
double RBCIBuffer[]; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() 
{ 
string short_name; 
//---- indicator line 
SetIndexStyle(0,DRAW_LINE); 
SetIndexBuffer(0,RBCIBuffer); 
SetIndexDrawBegin(0,55); 
//---- 
return(0); 
} 
//+------------------------------------------------------------------+ 
//| RBCI | 
//+------------------------------------------------------------------+ 
int start() 
{ 
int i,counted_bars=IndicatorCounted(); 
//---- 
if(Bars<=55) return(0); 
//---- initial zero 
if(counted_bars<55) 
for(i=1;i<=0;i++) RBCIBuffer[Bars-i]=0.0; 
//---- 
i=Bars-55-1; 
if(counted_bars>=55) i=Bars-counted_bars-1; 
while(i>=0) 
{ 
RBCIBuffer[i]= 
-( 
-35.5241819400*Close[i+0] 
-29.3339896500*Close[i+1] 
-18.4277449600*Close[i+2] 
-5.3418475670*Close[i+3] 
+7.0231636950*Close[i+4] 
+16.1762815600*Close[i+5] 
+20.6566210400*Close[i+6] 
+20.3266115800*Close[i+7] 
+16.2702390600*Close[i+8] 
+10.3524012700*Close[i+9] 
+4.5964239920*Close[i+10] 
+0.5817527531*Close[i+11] 
-0.9559211961*Close[i+12] 
-0.2191111431*Close[i+13] 
+1.8617342810*Close[i+14] 
+4.0433304300*Close[i+15] 
+5.2342243280*Close[i+16] 
+4.8510862920*Close[i+17] 
+2.9604408870*Close[i+18] 
+0.1815496232*Close[i+19] 
-2.5919387010*Close[i+20] 
-4.5358834460*Close[i+21] 
-5.1808556950*Close[i+22] 
-4.5422535300*Close[i+23] 
-3.0671459820*Close[i+24] 
-1.4310126580*Close[i+25] 
-0.2740437883*Close[i+26] 
+0.0260722294*Close[i+27] 
-0.5359717954*Close[i+28] 
-1.6274916400*Close[i+29] 
-2.7322958560*Close[i+30] 
-3.3589596820*Close[i+31] 
-3.2216514550*Close[i+32] 
-2.3326257940*Close[i+33] 
-0.9760510577*Close[i+34] 
+0.4132650195*Close[i+35] 
+1.4202166770*Close[i+36] 
+1.7969987350*Close[i+37] 
+1.5412722800*Close[i+38] 
+0.8771442423*Close[i+39] 
+0.1561848839*Close[i+40] 
-0.2797065802*Close[i+41] 
-0.2245901578*Close[i+42] 
+0.3278853523*Close[i+43] 
+1.1887841480*Close[i+44] 
+2.0577410750*Close[i+45] 
+2.6270409820*Close[i+46] 
+2.6973742340*Close[i+47] 
+2.2289941280*Close[i+48] 
+1.3536792430*Close[i+49] 
+0.3089253193*Close[i+50] 
-0.6386689841*Close[i+51] 
-1.2766707670*Close[i+52] 
-1.5136918450*Close[i+53] 
-1.3775160780*Close[i+54] 
-1.6156173970*Close[i+55]); 


i--; 
} 
return(0); 
} 
//+------------------------------------------------------------------+ 