//+------------------------------------------------------------------+
//|                                                 StepRSI_v5.2.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_separate_window
#property indicator_minimum 20
#property indicator_maximum 80
#property indicator_level1 40
#property indicator_level2 60
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Yellow
//---- input parameters
extern int RSIPeriod=14;
extern double StepSize=5;
extern int MAPeriod=1;
extern int Price=0;
extern int Mode=1;
//---- buffers
double RSIBuffer[];
double FastBuffer[];
double trend[];
double smax[],smin[];

int limit; 
//---- StepMA Calculation   
      
   double StepMACalc (double Size, int k)
   {
   int count, counted_bars=IndicatorCounted();
   double result;
   	
	  smax[k]=RSIBuffer[k] +2.0*Size;
	  smin[k]=RSIBuffer[k] -2.0*Size;
     
	  trend[k]=trend[k+1];   
	  
	  if (trend[k+1]<=0 && RSIBuffer[k]>smax[k+1]) trend[k]=1;   
	 
	  if (trend[k+1]>=0 && RSIBuffer[k]<smin[k+1]) trend[k]=-1;  
	 
	  if(trend[k]>0)
	  {
	  if(smin[k]<smin[k+1]) smin[k]=smin[k+1];
	  result=smin[k]+Size;
	  
	  } 
	  else
	  if(trend[k]<0)
	  {
	  if(smax[k]>smax[k+1]) smax[k]=smax[k+1];
	  result=smax[k]-Size;
	  }
     return(result); 
     } 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(5);
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSIBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,FastBuffer);
   SetIndexBuffer(2,smin);
   SetIndexBuffer(3,smax);
   SetIndexBuffer(4,trend);
//---- name for DataWindow and indicator subwindow label
   short_name="StepRSI("+RSIPeriod+","+MAPeriod+","+Price+","+DoubleToStr(StepSize,1)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Fast");   
//----
   
   SetIndexDrawBegin(0,RSIPeriod);
   SetIndexDrawBegin(1,RSIPeriod);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| StepRSI_v5.2                                                       |
//+------------------------------------------------------------------+
int start()
  {
   int    count,i,counted_bars=IndicatorCounted();
   double rel,negative,positive;
//----
   if(Bars<=RSIPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=RSIPeriod;i++) 
      {RSIBuffer[Bars-i]=0.0;FastBuffer[Bars-i]=0.0;}
//----
   if ( counted_bars > 0 )  limit=Bars-counted_bars;
   if ( counted_bars ==0 )  limit=Bars-RSIPeriod-1; 
   
   for(i=limit;i>=0;i--) 
   {	 
      
      double sumn=0.0,sump=0.0;
      for (int k=RSIPeriod-1;k>=0;k--)
           { 
            rel=iMA(NULL,0,MAPeriod,0,MODE_SMA,Price,i+k)-iMA(NULL,0,MAPeriod,0,MODE_SMA,Price,i+k+1);
            if(rel>0) sump+=rel;
            else      sumn-=rel;
           }
         positive=sump/RSIPeriod;
         negative=sumn/RSIPeriod;
      
      if (Mode==1)
      {
      if(negative==0.0) RSIBuffer[i]=100.0;
      else 
      RSIBuffer[i]=100.0-100.0/(1.0+positive/negative);
      }
      else
      RSIBuffer[i]=iRSI(NULL,0,RSIPeriod,Price,i);
      FastBuffer[i]=StepMACalc(StepSize,i);
	}
//----
   return(0);
  }
//+------------------------------------------------------------------+