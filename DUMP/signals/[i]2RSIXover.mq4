//+------------------------------------------------------------------+
//| 5 Min RSI cross-over INDICATOR                               |
//+------------------------------------------------------------------+
#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com"

#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1 White
#property indicator_color2 Red

//---- buffers
double Buffer1[];
double Buffer2[];

extern int    RSISlow=4;
extern int    RSIFast=7;
extern int    RSIType=6;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {

   // 233 up arrow
   // 234 down arrow
   // 159 big dot
   // 158 little dot
   // 168 open square
   // 120 box with X
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0, Buffer1);
   SetIndexArrow(0,233);  //white up
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1, Buffer2);
   SetIndexArrow(1,234);  // red down

   return(0);
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   
   for( i=0; i<Bars; i++ ) Buffer1[i]=0;
   for( i=0; i<Bars; i++ ) Buffer2[i]=0;

   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+


int start()
  {
   int      pos=Bars-100; // leave room for moving average periods
   int      ctr=0;
   
   double p=Point();
   
   double  pRSI4=0,  RSI4=0;
   double  pRSI7=0,  RSI7=0;
 
   
   while(pos>=1)
     {
      // 2-period moving average on Bar[2]
       RSI4=iRSI(Symbol(),0,RSIFast,RSIType,pos+1);
      pRSI4=iRSI(Symbol(),0,RSIFast,RSIType,pos+2);
       RSI7=iRSI(Symbol(),0,RSISlow,RSIType,pos+1);
      pRSI7=iRSI(Symbol(),0,RSISlow,RSIType,pos+2);

      // Determine if there was a cross
      if(pRSI4<pRSI7 && RSI4>RSI7) {Buffer1[pos]=High[pos]+(2*p);}
      if(pRSI4>pRSI7 && RSI4<RSI7) {Buffer2[pos]=Low[pos] -(2*p);}
   
 	   pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+