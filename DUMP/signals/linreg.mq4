//+------------------------------------------------------------------+
//|                                                        |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, FX Sniper "
#property  link      "http://www.metaquotes.net/"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 3
#property indicator_color1 Yellow      
#property indicator_color2 Green
#property indicator_color3 Red

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
int width;

extern int Rperiod = 3;
extern int Draw4HowLongg = 1500;
int Draw4HowLong;
int shift;
int i;
int loopbegin;
double sumx[];
double sumy[],sumxy[],sumxsq[],sumysq[];
int length;
double lengthvar;
double sqsumx[], sqsumy[];
double tmp ;
double wt[],reglin[], slopem[], interceptb[], refr[], unk[];
int c;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 2 additional buffers are used for counting.
   IndicatorBuffers(5);
   
//---- drawing settings
   SetIndexBuffer(2,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(0,ExtMapBuffer3);
   SetIndexBuffer(3,sumx);
   SetIndexBuffer(4,wt);
   
   
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);

//---- initialization done
   return(0);
  }


int start()

  {   Draw4HowLong = Bars-Rperiod - 5;
      length = Rperiod;
      loopbegin = Draw4HowLong - length - 1;
 
      for(shift = loopbegin; shift >= 0; shift--)
      { 
        sumx[1] = 0;
	     sumy[1] = 0;
	     sumxy[1] = 0;
	     sumxsq[1] = 0;
	     sumysq[1] = 0;
         for(i = length; i >= 1  ; i--)
         {
         tmp = 0;
//         tmp = ( i - lengthvar)*Close[length-i+shift];
	 tmp=(length-i+1)*Close[length-i+shift];
         sumxy[1]+=tmp;
	 sumy[1]+=Close[shift];
	 sumysq[1]+=Close[shift]*Close[shift];
 	 sumxsq[1]+=i*i;
 	 sumx[1]+=i;


         }
	 sqsumx[shift]=sumx[1]*sumx[1];
 	 sqsumy[shift]=sumy[1]*sumy[1];
	 slopem[shift]=(length*sumxy[1]-sumx[1]*sumy[1])/(length*sumxsq[1]-sqsumx[shift]);
	 interceptb[shift]=(sumy[1]-slopem[shift]*sumx[1])/length;
//	 refr[shift]=(length*sumxy[1]-sumx[1]*sumy[1])/sqrt((length*sumxsq[1]-sqsumx[shift])*(length*sumysq[1]-sqsumy[shift]));
	 reglin[shift]=length*slopem[shift]+interceptb[shift];
	 wt[shift] = reglin[shift];
	
         
//========== COLOR CODING ===========================================               
        
       ExtMapBuffer3[shift] = wt[shift]; //red 
       ExtMapBuffer2[shift] = wt[shift]; //green
       ExtMapBuffer1[shift] = wt[shift]; //yellow
       
       //  for(c=loopbegin;c==shift;c++)
       // {
        if (wt[shift+1] > wt[shift])
        {
        ExtMapBuffer2[shift+1] = EMPTY_VALUE;
  // ObjectCreate("smiley_face", OBJ_ARROW, 0, Time[shift], Low[shift]-Point*20);
  // Print("time=  ",Time[shift]);
  // ObjectSet("smiley_face", OBJPROP_ARROWCODE, 242);
  // ObjectSet("smiley_face", OBJPROP_COLOR , Red);
  // ObjectSet("smiley_face", OBJPROP_WIDTH  , 1);
  // ObjectsRedraw();

        //ExtMapBuffer3[shift+1] = EMPTY_VALUE;
        //ExtMapBuffer3[shift+1] = EMPTY_VALUE;
        
        }
       else if (wt[shift+1] < wt[shift]) 
        {
        ExtMapBuffer1[shift+1] = EMPTY_VALUE; //-1 red/greem tight
       //ExtMapBuffer3[shift+1] = EMPTY_VALUE;
        
        }
         else 
         {
         
         ExtMapBuffer1[shift+1]=CLR_NONE;//EMPTY_VALUE;
         ExtMapBuffer2[shift+1]=CLR_NONE;//EMPTY_VALUE;
         }
        
      }
    
      return(0);
  }
//+------------------------------------------------------------------+




