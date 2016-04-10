//+------------------------------------------------------------------+
//|                                                      KAMARev.mq4 |
//|                       Copyright ?2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Black
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Red

//---- input parameters
extern int KAMAPeriod=4;
extern int LookBack=3;
extern double RevPoint=0.0004;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {   string short_name;
//---- indicators
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
    SetIndexBuffer(2, ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3, ExtMapBuffer4);
   
   short_name="KAMA("+KAMAPeriod+","+LookBack+","+RevPoint+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  int Scale=500;
  int    i,counted_bars=IndicatorCounted();
  double tmp[];
   double rel,negative,positive;
  if(Bars<=KAMAPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=KAMAPeriod;i++) ExtMapBuffer1[Bars-i]=0.0;

   if(counted_bars>=KAMAPeriod) i=Bars-counted_bars-1;
  
   if(counted_bars<0) return(-1);

   int limit=Bars-counted_bars;
//---- TODO: add your code here
  // double FastSC = (double)(2.0/(2.0 + 1.0));
	//	double SlowSC = (double)(2.0/(30.0 + 1.0));
		double FastSC = (2.0/(2.0 + 1.0));
		double SlowSC = (2.0/(30.0 + 1.0));
		
		double Direction=0;
		double Volatility=0;
		double ER=0;
		double SSC=0;	
		double Constant=0;
		int start=counted_bars-1;
		
		int handle;
      
  
       start=0;
       limit=Bars;
	   for(i=start+limit; i>=start; i--){
				 Direction=Close[i]-Close[i+KAMAPeriod];
				 
				 double sum=0;
	for(int j=i+KAMAPeriod-1;(j>=i);j--){
		       sum+=MathAbs(Close[j]-Close[j+1]);
	}
	           Volatility=sum;
	           
				 if (Volatility==0) ER=0;
				 else
				 	ER=MathAbs(Direction/Volatility);
				 SSC= ER * (FastSC - SlowSC) + SlowSC;
				 Constant=SSC*SSC;
				if (i<KAMAPeriod)
					ExtMapBuffer1[i]=Close[i+1]+Constant*(Close[i]-Close[i+1]);
				else
					ExtMapBuffer1[i]=ExtMapBuffer1[i+1]+Constant*(Close[i]-ExtMapBuffer1[i+1]);
					
			
		
		//		ExtMapBuffer1[i]=ExtMapBuffer2[i]-ExtMapBuffer2[i+LookBack];
		double tmpd=ExtMapBuffer1[i]-ExtMapBuffer1[i+LookBack];
				ExtMapBuffer2[i]=tmpd*Scale;
				ExtMapBuffer3[i]=RevPoint*Scale;
				ExtMapBuffer4[i]=-1*RevPoint*Scale;

				
				
				
			
		}
//----
//   FileClose(handle);
   return(0);
  }
//+------------------------------------------------------------------+