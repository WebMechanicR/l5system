/**
* ACD_3.mq4
* Three Day Rolling Pivot
**/

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green 
#property indicator_color2 LimeGreen
#property indicator_color3 LimeGreen

//Input Params
extern string PivotRangeStart = "21:00";
extern string PivotRangeEnd = "21:00";
extern bool DisplayPivotPoint = true;

double Buffer1[];
double Buffer2[];
double Buffer3[];

double pivotRangeHigh;
double pivotRangeLow;
double pivotRangeClose;
double pivotTop=0;
double pivotBottom=0;
    
int init()
{
   SetIndexStyle(0,DRAW_LINE, STYLE_DOT, 1);
   SetIndexBuffer(0,Buffer1);
   SetIndexLabel(0,"Pivot Point");

   SetIndexStyle(1,DRAW_LINE, STYLE_DASH, 1);
   SetIndexBuffer(1,Buffer2);
   SetIndexLabel(1,"Pivot Range Top");

   SetIndexStyle(2,DRAW_LINE, STYLE_DASH, 1);
   SetIndexBuffer(2,Buffer3);
   SetIndexLabel(2,"Pivot Range Bottom");

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{   
   string barTime="", lastBarTime="";    
   string barDay="", lastBarDay="";        
   int openBars[3], tempBars[3];
   int openBar, closeBar;
          
   for(int i=Bars; i>=0; i--)
   {  
      barTime = TimeToStr(Time[i], TIME_MINUTES);
      lastBarTime = TimeToStr(Time[i+1], TIME_MINUTES); 
      barDay = TimeToStr(Time[i],TIME_DATE);
      lastBarDay = TimeToStr(Time[i+1],TIME_DATE);
      
      if ((PivotRangeEnd == "00:00" && barTime>=PivotRangeEnd && barDay>lastBarDay) || (barTime>=PivotRangeEnd && lastBarTime<PivotRangeEnd))     
      {  
         closeBar = i + 1;
         openBar = openBars[2];
         
         ArrayCopy(tempBars, openBars, 1, 0, 2);
         ArrayCopy(openBars, tempBars);
         
         if (openBar>0)
         {
            calculatePivotRangeValues(openBar, closeBar);
         }
      }
      
      if ((PivotRangeStart == "00:00" && barTime>=PivotRangeStart && barDay>lastBarDay) || (barTime>=PivotRangeStart && lastBarTime<PivotRangeStart))
      {
          openBars[0] = i;
      }
      
      if (openBar>0)
      {
          drawIndicators(i);
      }     
   }
   return(0);
}

void calculatePivotRangeValues(int openBar, int closeBar)
{
   pivotRangeHigh = High[Highest(NULL, 0, MODE_HIGH, (openBar - closeBar + 1), closeBar)];
   pivotRangeLow = Low[Lowest(NULL, 0, MODE_LOW, (openBar - closeBar + 1), closeBar)];
   pivotRangeClose = Close[closeBar];
}

void drawIndicators(int curBar)
{
   double pivotPoint, pivotDiff;
   
   if (pivotRangeHigh<=0 || pivotRangeLow <=0 || pivotRangeClose <= 0)
   {
      return(0);
   }
   
   pivotPoint=(pivotRangeHigh + pivotRangeLow + pivotRangeClose)/3;
   pivotDiff = MathAbs(((pivotRangeHigh + pivotRangeLow)/2) - pivotPoint);
   pivotTop = pivotPoint + pivotDiff;
   pivotBottom = pivotPoint - pivotDiff;   

   if (DisplayPivotPoint) Buffer1[curBar]=pivotPoint;
   Buffer2[curBar]=pivotTop;
   Buffer3[curBar]=pivotBottom;
   Comment("H " + DoubleToStr(pivotRangeHigh, Digits) + " L " + DoubleToStr(pivotRangeLow, Digits) + " C " + DoubleToStr(pivotRangeClose,Digits));
}