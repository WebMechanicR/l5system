//+------------------------------------------------------------------+
//| LSMA indicator with global variables to drive a companion expert |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2005, FX Sniper "
#property  link      "http://www.metaquotes.net/"

//---- indicator settings
#property  indicator_chart_window

#property indicator_buffers   5
#property indicator_color1  Yellow      
#property indicator_color2  Green
#property indicator_color3  Red
#property indicator_color4  White
#property indicator_color5  White


//---- buffers
double ExtMapBuffer1[];  //Yellow
double ExtMapBuffer2[];  //Green
double ExtMapBuffer3[];  //Red
double XBuffer[];        //White
double ZBuffer[];        //White

extern int extRperiod = 32;
extern int extDraw4HowLong = 500;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   SetIndexBuffer(0,ExtMapBuffer1);   //Yellow
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);

   SetIndexBuffer(1,ExtMapBuffer2);  //Green
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);

   SetIndexBuffer(2,ExtMapBuffer3);  //Red
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);


   // 233 up arrow
   // 234 down arrow
   // 158 little dot
   // 159 big dot
   // 168 open square
   // 120 box with X
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3, XBuffer);     //White
   SetIndexArrow(3,120);

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexBuffer(4, ZBuffer);     //White
   SetIndexArrow(4,159);

   return(0);
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   
   for( i=0; i<Bars; i++ ) ExtMapBuffer1[i]=0;
   for( i=0; i<Bars; i++ ) ExtMapBuffer2[i]=0;
   for( i=0; i<Bars; i++ ) ExtMapBuffer3[i]=0;
   for( i=0; i<Bars; i++ ) XBuffer[i]=0;
   for( i=0; i<Bars; i++ ) ZBuffer[i]=0;

   return(0);
  }


int start()
  {   

   //----- variables
   int    c;
   int    i;
   int    length;
   double lengthvar;
   int    loopbegin;
   int    pos;
   double sum;
   double tmp;
   int    width;

   double wtp; //previous value
   double wt;  //current value
   int    rc=0;
   int    gc=0;
   
   double p=Point;
   
   length = extRperiod;
   loopbegin = extDraw4HowLong - length - 1;
 
   for(pos = loopbegin; pos >= 0; pos--)
     { 
      sum = 0;
      for(i = length; i >= 1  ; i--)
        {
         lengthvar = length + 1;
         lengthvar /= 3;
         tmp = 0;
         tmp = ( i - lengthvar)*Close[length-i+pos];
         sum+=tmp;
        }
         
      wtp=wt;
      wt = sum*6/(length*(length+1));
         
      ExtMapBuffer1[pos] = wt;   //yellow
      ExtMapBuffer2[pos] = wt+(10*Point());   //green
      ExtMapBuffer3[pos] = wt-(10*Point());   //red 

      if (wtp > wt)
        {
         ExtMapBuffer2[pos+1] = wt; //remove GREEN
         rc++;
         ZBuffer[pos]=Low[pos];
        }
      else
        {
         ExtMapBuffer3[pos+1] = wt; //remove RED
         gc++;
         ZBuffer[pos]=High[pos];
        }

      //Comment("wtp=",wtp,"\nwt=",wt,"\nRed=",rc,"\nGreen=",gc);
      
      
      if (gc>0 && rc>0)
        {
         // Close any orders
         gc=0; 
         rc=0;
        }
      
      if (gc==6)
        {
         // indicate buy order 
         XBuffer[pos]=High[pos];
        }
        
      if (rc==6)
        {
         // indicate sell order 
         XBuffer[pos]=Low[pos];
        }

     }

   return(0);
  }
//+------------------------------------------------------------------+



