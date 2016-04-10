//+------------------------------------------------------------------+
//|                                                          RSI.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_level1 30
#property indicator_level2 70

//---- input parameters
extern int RSIPeriod=11;
//---- buffers
double RSIBuffer[];
//double RSIBuffer1[];
double PosBuffer[];
double NegBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(3);
   SetIndexBuffer(1,PosBuffer);
   SetIndexBuffer(2,NegBuffer);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="D_RSI("+RSIPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,RSIPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,counted_bars=IndicatorCounted();
   double rel,negative,positive;
//----
   if(Bars<=RSIPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=RSIPeriod;i++) RSIBuffer[Bars-i]=0.0;
//----
   i=Bars-RSIPeriod-1;
   if(counted_bars>=RSIPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double sumn=0.0,sump=0.0;
      if(i==Bars-RSIPeriod-1)
        {
         int k=Bars-2;
         //---- initial accumulation
         while(k>=i)
           {
            rel=Close[k]-Close[k+1];
            if(rel>0) sump+=rel;
            else      sumn-=rel;
            k--;
           }
         positive=sump/RSIPeriod;
         negative=sumn/RSIPeriod;
        }
      else
        {
         //---- smoothed moving average
         rel=Close[i]-Close[i+1];
         if(rel>0) sump=rel;
         else      sumn=-rel;
         positive=(PosBuffer[i+1]*(RSIPeriod-2)+sump)/RSIPeriod;
         negative=(NegBuffer[i+1]*(RSIPeriod-2)+sumn)/RSIPeriod;
                  
        }
      PosBuffer[i]=positive;
      NegBuffer[i]=negative;
      
     
 if(negative==0.0) RSIBuffer[i]=0.0;
 else RSIBuffer[i]=100.0-100.0/(1+positive/negative);
  

RSIBuffer[i] =   
 0.433154403793*RSIBuffer[i+0]
 +0.364936248838*RSIBuffer[i+1]
 +0.2483161287091*RSIBuffer[i+2]
 +0.1159127094262*RSIBuffer[i+3]
 +0.001920177025782*RSIBuffer[i+4]
 -0.0690619159350*RSIBuffer[i+5]
 -0.0890366343384*RSIBuffer[i+6]
 -0.0670352313955*RSIBuffer[i+7]
 -0.02354570920082*RSIBuffer[i+8]
 +0.01860246173456*RSIBuffer[i+9]
 +0.0426761569010*RSIBuffer[i+10]
 +0.0429876844454*RSIBuffer[i+11]
 +0.02477765082083*RSIBuffer[i+12]
 -0.0001576627378414*RSIBuffer[i+13]
 -0.01967662445848*RSIBuffer[i+14]
 -0.02646547548004*RSIBuffer[i+15]
 -0.02024560032283*RSIBuffer[i+16]
 -0.00623702818584*RSIBuffer[i+17]
 +0.00780018663194*RSIBuffer[i+18]
 +0.01584087110996*RSIBuffer[i+19]
 +0.01529850741755*RSIBuffer[i+20]
 +0.00776771039355*RSIBuffer[i+21]
 -0.002822554123202*RSIBuffer[i+22]
 -0.01184238041638*RSIBuffer[i+23]
 -0.01459330298226*RSIBuffer[i+24]
 -0.00702238938753*RSIBuffer[i+25]
 +0.01182599304835*RSIBuffer[i+26]
 +0.02754073932338*RSIBuffer[i+27]
 -0.02827477612793*RSIBuffer[i+28]
 +0.00665965547380*RSIBuffer[i+29];


    
RSIBuffer[i] =
  0.462339155006*RSIBuffer[i+0]
 +0.380746443532*RSIBuffer[i+1]
 +0.2435911690640*RSIBuffer[i+2]
 +0.0930418466471*RSIBuffer[i+3]
 -0.02835684040755*RSIBuffer[i+4]
 -0.0928288862464*RSIBuffer[i+5]
 -0.0956528361680*RSIBuffer[i+6]
 -0.0539388169505*RSIBuffer[i+7]
 +0.002654987501491*RSIBuffer[i+8]
 +0.0454612622799*RSIBuffer[i+9]
 +0.0580001102616*RSIBuffer[i+10]
 +0.0402785468641*RSIBuffer[i+11]
 +0.00614866359189*RSIBuffer[i+12]
 -0.02531425814679*RSIBuffer[i+13]
 -0.0395272802058*RSIBuffer[i+14]
 -0.0321281404710*RSIBuffer[i+15]
 -0.00999834894376*RSIBuffer[i+16]
 +0.01411758199119*RSIBuffer[i+17]
 +0.02799907845255*RSIBuffer[i+18]
 +0.02616839245397*RSIBuffer[i+19]
 +0.01148168026699*RSIBuffer[i+20]
 -0.00716063840872*RSIBuffer[i+21]
 -0.02000122316853*RSIBuffer[i+22]
 -0.02129591639566*RSIBuffer[i+23]
 -0.01171727150172*RSIBuffer[i+24]
 +0.002714077142857*RSIBuffer[i+25]
 +0.01417503605156*RSIBuffer[i+26]
 +0.01719491293035*RSIBuffer[i+27]
 +0.01115628436530*RSIBuffer[i+28]
 +0.0001091928592001*RSIBuffer[i+29]
 -0.00982781479638*RSIBuffer[i+30]
 -0.01370579701559*RSIBuffer[i+31]
 -0.01021209353832*RSIBuffer[i+32]
 -0.001840552264328*RSIBuffer[i+33]
 +0.00662015497002*RSIBuffer[i+34]
 +0.01084278724001*RSIBuffer[i+35]
 +0.00907911490258*RSIBuffer[i+36]
 +0.002807403486449*RSIBuffer[i+37]
 -0.00430091936446*RSIBuffer[i+38]
 -0.00853651829218*RSIBuffer[i+39]
 -0.00797780175591*RSIBuffer[i+40]
 -0.00331517566666*RSIBuffer[i+41]
 +0.002697670688571*RSIBuffer[i+42]
 +0.00685111113574*RSIBuffer[i+43]
 +0.00709078390938*RSIBuffer[i+44]
 +0.00353516270592*RSIBuffer[i+45]
 -0.001722941012513*RSIBuffer[i+46]
 -0.00584447134884*RSIBuffer[i+47]
 -0.00662609869769*RSIBuffer[i+48]
 -0.00365461380634*RSIBuffer[i+49]
 +0.001483708889269*RSIBuffer[i+50]
 +0.00592939018204*RSIBuffer[i+51]
 +0.00693617932732*RSIBuffer[i+52]
 +0.00340198228418*RSIBuffer[i+53]
 -0.003034976534982*RSIBuffer[i+54]
 -0.00826283181286*RSIBuffer[i+55]
 -0.00766354484560*RSIBuffer[i+56]
 +0.000368305995778*RSIBuffer[i+57]
 +0.01089806279931*RSIBuffer[i+58]
 +0.01226998232534*RSIBuffer[i+59]
 -0.00558538690631*RSIBuffer[i+60]
 -0.02808106424832*RSIBuffer[i+61]
 +0.02711041260296*RSIBuffer[i+62]
 -0.00718757578535*RSIBuffer[i+63];
     i--;
     }
     
     
     
//----
   return(0);
  }
//+------------------------------------------------------------------+