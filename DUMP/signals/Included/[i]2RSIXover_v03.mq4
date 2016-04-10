//+------------------------------------------------------------------+
//| 5 Min RSI cross-over INDICATOR                               |
//+------------------------------------------------------------------+
#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com"

#property indicator_chart_window
#property indicator_buffers 2

// buy sell indicators 
#property indicator_color1 White
#property indicator_color2 Red

//---- buffers
double Buffer1[]; //White
double Buffer2[]; //Red

extern int    RSISlow=14;
extern int    RSIFast=7;
extern int    RSIType=1;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {
   // 233 up arrow
   // 234 down arrow
   // 159 big dot
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0, Buffer1);
   SetIndexArrow(0,233);  //white up
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1, Buffer2);
   SetIndexArrow(1,234);  // red down
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   
   for( i=0; i<Bars; i++ ) Buffer1[i]=0;
   for( i=0; i<Bars; i++ ) Buffer2[i]=0;
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
      // RSI for Crossover
      if(RSIType==1)
        {
          RSI4=iRSI(Symbol(),0,RSIFast,RSIType,pos+0);
         pRSI4=iRSI(Symbol(),0,RSIFast,RSIType,pos+1);
          RSI7=iRSI(Symbol(),0,RSISlow,RSIType,pos+0);
         pRSI7=iRSI(Symbol(),0,RSISlow,RSIType,pos+1);
        }
         else
        {
          RSI4=iRSI(Symbol(),0,RSIFast,RSIType,pos+1);
         pRSI4=iRSI(Symbol(),0,RSIFast,RSIType,pos+2);
          RSI7=iRSI(Symbol(),0,RSISlow,RSIType,pos+1);
         pRSI7=iRSI(Symbol(),0,RSISlow,RSIType,pos+2);
        }

      // Determine if there was a cross
      if(pRSI4<pRSI7 && RSI4>RSI7) {Buffer1[pos]= Low[pos]-(2*p);} // up arrow on bottom
      if(pRSI4>pRSI7 && RSI4<RSI7) {Buffer2[pos]=High[pos]+(2*p);} // down arrow on top
 	   pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+