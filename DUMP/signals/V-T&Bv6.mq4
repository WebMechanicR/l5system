//+------------------------------------------------------------------+
//|                                                        V-T&B.mq4 |
//|                                           Don Lawson (don_forex) |
//+------------------------------------------------------------------+

   
#property copyright "Coded by Don Lawson (don_forex)"
#property link      "d_n_d_enterprises@sbcglobal.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_width1 2
#property indicator_color2 Green
#property indicator_width2 2

extern double  WickRatio      = 0.5;
extern double  WickPercent    = 50;
extern int     JuicePeriod    = 7;
extern int JuiceLevelForAlert = 5;

extern bool Notify = false;
extern bool UseNew = true;


double VTop[];
double VBottom[];
double DistanceFromCandle;
int    Level = 5;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 234);
   SetIndexBuffer(0, VTop);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 233);
   SetIndexBuffer(1, VBottom);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
  
void SetVTop(int index)
{
   double Juice, JuiceLevel;
   
// Check for Juice
  JuiceLevel = Level*Point;
  if (Period()==5 ) JuiceLevel=JuiceLevel/2;
      
    Juice = iStdDev  (NULL,0,JuicePeriod,MODE_EMA,0,PRICE_CLOSE,index)-JuiceLevel;
    if (Juice > JuiceLevelForAlert*Point) {
      VTop[index] = High[index]+ DistanceFromCandle;
      if (Notify) PlaySound("V-Top.wav");
    }
}

void SetVBottom(int index)
{
   double Juice, JuiceLevel;
   
// Check for Juice
  JuiceLevel = Level*Point;
  if (Period()==5 ) JuiceLevel=JuiceLevel/2;
      
    Juice = iStdDev  (NULL,0,JuicePeriod,MODE_EMA,0,PRICE_CLOSE,index)-JuiceLevel;
    if (Juice > JuiceLevelForAlert*Point) {
       VBottom[index] = Low[index]- DistanceFromCandle;
       if (Notify) PlaySound("V-Bottom.wav");
    }
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit, i,State;
   double WickPenetration;
   double BullWickPenHi,BullWickPenLow;
   double BearWickPenHi,BearWickPenLow;
   double BullWickHi,BullWickLow,BullBody;
   double BearWickHi,BearWickLow,BearBody;
   
   
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   WickPenetration = WickPercent/100.0;
   DistanceFromCandle = Point*8;
   
   for(i = 1; i <= limit; i++) {
   
       
      bool  CurrentBull     = false,
            CurrentBear     = false,
            Bull            = false,
            Bear            = false,
            HiWick          = false,
            LoWick          = false;
            
      if (Open[i-1]<Close[i-1])
         CurrentBull = true;
      else 
         CurrentBear = true;
      
      if (Open[i]<Close[i])
         Bull = true;
      else 
         Bear = true;
      
      BullWickHi = High[i] - Close[i];
      BullWickLow = Open[i] - Low[i];
      BullBody = Close[i] - Open[i];
      BearWickHi = High[i] - Open[i];
      BearWickLow = Close[i] - Low[i];
      BearBody = Open[i] - Close[i];

// Check for VTOP

      if (High[i] > High[i+1])
      {
         if (Bull) {
           if ((BullWickHi > BullBody * WickRatio))// && (BullWickHi > BullWickLow)
             HiWick = true;
         }
         if (Bear){
           if ((BearWickHi > BearBody * WickRatio))// && (BearWickHi > BearWickLow)
             HiWick = true;
         }
      }
         
// Check for VBottom

      if (Low[i] < Low[i+1])
      {         
         if (Bull){
           if ((BullWickLow > BullBody * WickRatio))// && (BullWickLow > BullWickHi)
             LoWick = true;
         }
         if (Bear){
           if ((BearWickLow > BearBody * WickRatio))// && (BearWickLow > BearWickHi)
             LoWick = true;
         }
      }
      
      
// Set up State Table

      if (CurrentBear && Bull) State = 1;
      if (CurrentBear && Bear) State = 2;
      if (CurrentBull && Bull) State = 3;
      if (CurrentBull && Bear) State = 4;
            
// Set Arrow

      if (HiWick) {
        BullWickPenHi = Close[i] + BullWickHi * WickPenetration;
        BearWickPenHi = Open[i] + BearWickHi * WickPenetration;
        switch (State)
        {
         case 1 : // CurrentBear && Bull 
               if (UseNew)
               {
               if ( Open[i-1] < BullWickPenHi) SetVTop(i);
               }
               else
               {
               SetVTop(i);
               }
               
            break;
         case 2 : // CurrentBear && Bear 
            if (UseNew)
            {
            if (Open[i-1] < BearWickPenHi) SetVTop(i);
            }
            else
            {
             SetVTop(i);
             }
         break;
         case  3 : // CurrentBull && Bull
            if (UseNew)
            {
            if (Close[i-1] < BullWickPenHi) SetVTop(i);
            }
            else
            {
             SetVTop(i);
             }
         break;
         case 4 : // CurrentBull && Bear
            if (UseNew)
            {
            if (Close[i-1] < BearWickPenHi)  SetVTop(i);
            }
            else
            {
             SetVTop(i);
             }
         break;
        }
      }
      if (LoWick) {
        BullWickPenLow = Open[i] - BullWickLow * WickPenetration;
        BearWickPenLow = Close[i] - BearWickLow * WickPenetration;
        
        switch (State)
        {
         case 1 : // CurrentBear && Bull
            if (UseNew)
            {
            if (Close[i-1] > BullWickPenLow) SetVBottom(i);
            }
            else
            {
             SetVBottom(i);
             }
         break;
         case 2 : // CurrentBear && Bear
            if (UseNew)
            {
            if (Close[i-1] > BearWickPenLow) SetVBottom(i);
            }
            else
            {
             SetVBottom(i);
             }
         break;
         case 3 : // CurrentBull && Bull
            if (UseNew)
            {
            if (Open[i-1] > BullWickPenLow) SetVBottom(i);
            }
            else
            {
             SetVBottom(i);
             }
         break;
         case 4 : //CurrentBull && Bear)
            if (UseNew)
            {
            if (Open[i-1] > BearWickPenLow) SetVBottom(i);
            }
            else
            {
             SetVBottom(i);
             }
         break;
        }
     }
   }
   return(0);
}

