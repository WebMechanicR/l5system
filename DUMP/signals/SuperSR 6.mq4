//+------------------------------------------------------------------+
//|                SuperSR 6.mq4                                     |
//|                Copyright © 2006  Scorpion@fxfisherman.com        |
//+------------------------------------------------------------------+
#property copyright "FxFisherman.com"
#property link      "http://www.fxfisherman.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Contract_Step=150;
extern int Precision=10;
extern int Shift_Bars=1;

//---- buffers
double v1[];
double v2[];
double val1;
double val2;
  
int init()
  {

   IndicatorBuffers(2);
  
   SetIndexArrow(0, 159);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,1,Red);
   SetIndexDrawBegin(0,-1);
   SetIndexBuffer(0, v1);
   SetIndexLabel(0,"Resistance");
   
   SetIndexArrow(1, 159); 
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1,Blue);
   SetIndexDrawBegin(1,-1);
   SetIndexBuffer(1, v2);
   SetIndexLabel(1,"Support");
   
   watermark();
 
   return(0);
  }

int start()
 {
  double gap;
  double contract = (Contract_Step + Precision) * Point;
  int i = Bars;
  int shift; 
  bool fractal;
  double price;
  
  while(i>=0)
   {
    shift = i + Shift_Bars;
    
    // Resistance
    price = High[shift+2];
    fractal = price >= High[shift+4] &&
              price >= High[shift+3] &&
              price > High[shift+1] &&
              price > High[shift];
              
    gap = v1[i+1] - price;
    if (fractal && (gap >= contract || gap < 0))
    {
      v1[i] = price + (Precision * Point);
    }else{
      v1[i] = v1[i+1];
    }

    // Support
    price = Low[shift+2];
    fractal = price <= Low[shift+4] &&
              price <= Low[shift+3] &&
              price < Low[shift+1] &&
              price < Low[shift];
              
    gap = price - v2[i+1];
    if (fractal && (gap >= contract || gap < 0))
    {
      v2[i] = price - (Precision * Point);
    }else{
      v2[i] = v2[i+1];
    }
    
    i--;
   }   
  return(0);
 }
 
//+------------------------------------------------------------------+

void watermark()
  {
   ObjectCreate("fxfisherman", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("fxfisherman", "fxfisherman.com", 11, "Lucida Handwriting", RoyalBlue);
   ObjectSet("fxfisherman", OBJPROP_CORNER, 2);
   ObjectSet("fxfisherman", OBJPROP_XDISTANCE, 5);
   ObjectSet("fxfisherman", OBJPROP_YDISTANCE, 10);
   return(0);
  }