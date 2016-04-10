//+------------------------------------------------------------------+
//| 4Hour Vegas Model - 4 Hour Chart MA lines                        |
//|                                                           Spiggy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Spiggy"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Green

//---- input parameters
extern bool      Alerts=true;
extern bool      PrintTags=False;
extern int       MA1=55;
extern int       MA2=8;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,1);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,2);
   SetIndexBuffer(3,ExtMapBuffer4);

   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  int    limit;
  double SMA55;
  double SMA55Prev;
  double SMA8;
  double SMA8Prev;
  string ValueIndex;
  string Direction;
  bool   BuyPrimed;
  bool   SellPrimed;
  bool   Bought1;
  bool   Bought2;
  bool   Bought3;
  bool   Sold1;
  bool   Sold2;
  bool   Sold3;
  double BoughtAt;
  double SoldAt;
  int    TagCount;
  string TagName;
  int    i;
  int    j;
  double RangeLimit;
  bool   InTrade=False;
  int    PandL=0;
  bool   FullTrade;

  // Count all bars every time (bad for performance, but good for testing)
  limit=Bars;

  // Clean up for redraw
  ObjectsDeleteAll(0);
  TagCount=0;

  //---- main loop
  for(i=limit-1; i>=0; i--)
  {
    //---- ma_shift set to 0 because SetIndexShift called abowe
    SMA55=iMA(NULL,0,MA1,0,MODE_SMA,PRICE_MEDIAN,i);
    SMA8 =iMA(NULL,0,MA2,0,MODE_SMA,PRICE_CLOSE,i);
    SMA55Prev=iMA(NULL,0,MA1,1,MODE_SMA,PRICE_MEDIAN,i);
    SMA8Prev =iMA(NULL,0,MA2,1,MODE_SMA,PRICE_CLOSE,i);

    ExtMapBuffer1[i] = SMA8;
    ExtMapBuffer2[i] = SMA55;
    ExtMapBuffer3[i] = 0;
    ExtMapBuffer4[i] = 0;

    Direction = "----";
    ValueIndex = TimeToStr(Time[i]-(TimeDayOfWeek(Time[i])*86400),TIME_DATE);
    if ( GlobalVariableGet(Symbol() + "-ThisWeekDirection-" + ValueIndex) > 0.0 )
    {
      Direction = "UP  ";
    }

    if ( GlobalVariableGet(Symbol() + "-ThisWeekDirection-" + ValueIndex) < 0.0 )
    {
      Direction = "DOWN";
    }

    if (!InTrade)
    {
      // ------------- TRADE ENTRY --------------
      // Check the MA8/55 Crossovers
      if ( Direction == "DOWN" )
      {
        // Remove any pending prime for a Buy
        BuyPrimed = False;

        // Check the SMA8 SM55 Crossover and prime the Sell signal
        if (( SMA8 > SMA55 ) && (SMA8Prev < SMA55Prev))
        {
          SellPrimed = True;
        }

        // Trigger the sell signal
        if ( SMA8 < SMA8Prev )
        {
          if (SellPrimed)
          {
            // We are opening a primed trade, do full lots 
            FullTrade = True;
          }
          else
          {
            // Otherwise do half lots
            FullTrade = False;
          }

          // Find the height of the tag - this should not cover any bars
          RangeLimit = High[i];
          for ( j = i - 7 ; j < i + 7 ; j++)
          {
            if (High[j] > RangeLimit)
            {
              RangeLimit = High[j];
            }
          }

          ExtMapBuffer3[i] = RangeLimit + 25*Point;
          SellPrimed = False;
          Sold1 = True;
          Sold2 = True;
          Sold3 = True;
          SoldAt = Close[i];
          InTrade = True;

          // Put the tag on the chart
          if (PrintTags)
          {
            TagName = "Entry" + TagCount;
            ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit+70*Point);
            ObjectSetText(TagName, "SELL " + TagCount + " (" + DoubleToStr(Close[i],4) + ")", 8, "Arial", White);
          }
        }
      }

      if ( Direction == "UP  " )
      {
        // Remove any pending prime for a SELL
        SellPrimed = False;

        // Check the SMA8 SM55 Crossover and prime the Buy signal
        if (( SMA8 < SMA55 ) && (SMA8Prev > SMA55Prev))
        {
          BuyPrimed = True;
        }

        // Trigger the Buy signal or unprime the trigger
        if ( SMA8 > SMA8Prev )
        {
          if (SellPrimed)
          {
            // We are opening a primed trade, do full lots 
            FullTrade = True;
          }
          else
          {
            // Otherwise do half lots
            FullTrade = False;
          }

          // Find the height of the tag - this should not cover any bars
          RangeLimit = Low[i];
          for ( j = i - 7 ; j < i + 7 ; j++)
          {
            if (Low[j] < RangeLimit)
            {
              RangeLimit = Low[j];
            }
          }

          ExtMapBuffer4[i] = RangeLimit - 25*Point;
          BuyPrimed = False;
          Bought1 = True;
          Bought2 = True;
          Bought3 = True;
          BoughtAt = Close[i];
          InTrade = True;

          if (PrintTags)
          {
            // Put the tag on the chart
            TagName = "Entry" + TagCount;
            ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit - 70*Point);
            ObjectSetText(TagName, "BUY " + TagCount + " (" + DoubleToStr(Close[i],4) + ")", 8, "Arial", White);
          }
        }
      }
    }
    else
    {
      // ------------- TRADE EXIT --------------
      if (Sold1 || Sold2 || Sold3)
      {
        // Trade Exit on SMA slope change
        if ( SMA8 > SMA8Prev)
        {
          // Find the height of the tag - this should not cover any bars
          RangeLimit = Low[i];
          for ( j = i - 7 ; j < i + 7 ; j++)
          {
            if (Low[j] < RangeLimit)
            {
              RangeLimit = Low[j];
            }
          }

          if (PrintTags)
          {
            // Put the tag on the chart
            ExtMapBuffer4[i] = RangeLimit - 25*Point;
            TagName = "Exit" + TagCount;
            ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit-70*Point);
            ObjectSetText(TagName, "EXIT " + TagCount + " (" + DoubleToStr((SoldAt-Close[i])/Point,0) + ")", 8, "Arial", White);
          }
          
          if ( FullTrade )
          {
            PandL = PandL + ((SoldAt-Close[i])/Point)*3;
          }
          else
          {
            PandL = PandL + ((((SoldAt-Close[i])/Point)*3)/2);
          }
          
          Sold1 = False;
          Sold2 = False;
          Sold3 = False;
          InTrade = False;
          TagCount++;
        }

        // Exit on Fib 1
        if (Sold1)
        {
          if( Low[i] < (SoldAt - 144*Point))
          {
            // Find the height of the tag - this should not cover any bars
            RangeLimit = Low[i];
            for ( j = i - 7 ; j < i + 7 ; j++)
            {
              if (Low[j] < RangeLimit)
              {
                RangeLimit = Low[j];
              }
            }

            ExtMapBuffer4[i] = RangeLimit - 25*Point;
            if (PrintTags)
            {
              TagName = "ExitFib1" + TagCount;
              ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit-70*Point);
              ObjectSetText(TagName, "EXIT1 " + TagCount + " (Fib1 144)", 8, "Arial", White);
            }
            
            Sold1 = False;
            if ( FullTrade )
            {
              PandL = PandL + 144;
            }
            else
            {
              PandL = PandL + (144)/2;
            }
          }
        }

        // Exit on Fib 2
        if (Sold1)
        {
          if ( Low[i] < (SoldAt - 233*Point))
          {
            // Find the height of the tag - this should not cover any bars
            RangeLimit = Low[i];
            for ( j = i - 7 ; j < i + 7 ; j++)
            {
              if (Low[j] < RangeLimit)
              {
                RangeLimit = Low[j];
              }
            }

            ExtMapBuffer4[i] = RangeLimit - 25*Point;
            if (PrintTags)
            {
              TagName = "ExitFib2" + TagCount;
              ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit-70*Point);
              ObjectSetText(TagName, "EXIT2 " + TagCount + " (Fib2 233)", 8, "Arial", White);
            }
            
            Sold2 = False;
            if ( FullTrade )
            {
              PandL = PandL + 233;
            }
            else
            {
              PandL = PandL + (233)/2;
            }
          }
        }

        // Exit on Fib 3
        if (Sold1)
        {
          if ( Low[i] < (SoldAt - 377*Point))
          {
            // Find the height of the tag - this should not cover any bars
            RangeLimit = Low[i];
            for ( j = i - 7 ; j < i + 7 ; j++)
            {
              if (Low[j] < RangeLimit)
              {
                RangeLimit = Low[j];
              }
            }

            ExtMapBuffer4[i] = RangeLimit - 25*Point;
            if (PrintTags)
            {
              TagName = "ExitFib3" + TagCount;
              ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit-70*Point);
              ObjectSetText(TagName, "EXIT3 " + TagCount + " (Fib3 377)", 8, "Arial", White);
            }
            
            // We are now out of the trade
            Sold3 = False;
            InTrade=False;
            if ( FullTrade )
            {
              PandL = PandL + 377;
            }
            else
            {
              PandL = PandL + (377)/2;
            }
          }
        }
      }

      if (Bought1 || Bought2 || Bought3)
      {
        // Trade Exit on SMA slope change
        if ( SMA8 < SMA8Prev)
        {
          // Find the height of the tag - this should not cover any bars
          RangeLimit = High[i];
          for ( j = i - 7 ; j < i + 7 ; j++)
          {
            if (High[j] > RangeLimit)
            {
              RangeLimit = High[j];
            }
          }
          
          // Put the tag on the chart
          ExtMapBuffer3[i] = RangeLimit + 25*Point;
          if (PrintTags)
          {
            TagName = "Exit" + TagCount;
            ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit+70*Point);
            ObjectSetText(TagName, "EXIT " + TagCount + " (" + DoubleToStr((Close[i]-BoughtAt)/Point,0) + ")", 8, "Arial", White);
          }
          
          if ( FullTrade )
          {
            PandL = PandL + ((Close[i]-BoughtAt)/Point)*3;
          }
          else
          {
            PandL = PandL + (((Close[i]-BoughtAt)/Point)*3)/2;
          }
          Bought1 = False;
          Bought2 = False;
          Bought3 = False;
          InTrade = False;
          TagCount++;
        }

        // Exit on Fib 1
        if (Bought1)
        {
          if ( High[i] > (BoughtAt + 144*Point))
          {
            // Find the height of the tag - this should not cover any bars
            RangeLimit = High[i];
            for ( j = i - 7 ; j < i + 7 ; j++)
            {
              if (High[j] > RangeLimit)
              {
                RangeLimit = High[j];
              }
            }

            ExtMapBuffer3[i] = RangeLimit + 25*Point;
            if (PrintTags)
            {
              TagName = "ExitFib1" + TagCount;
              ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit+70*Point);
              ObjectSetText(TagName, "EXIT1 " + TagCount + " (Fib1 144)", 8, "Arial", White);
            }
            
            Bought1 = False;
            if ( FullTrade )
            {
              PandL = PandL + 144;
            }
            else
            {
              PandL = PandL + (144)/2;
            }            
          }
        }

        // Exit on Fib 2
        if (Bought2)
        {
          if ( High[i] > (BoughtAt + 233*Point))
          {
            // Find the height of the tag - this should not cover any bars
            RangeLimit = High[i];
            for ( j = i - 7 ; j < i + 7 ; j++)
            {
              if (High[j] > RangeLimit)
              {
                RangeLimit = High[j];
              }
            }

            ExtMapBuffer3[i] = RangeLimit + 25*Point;
            if (PrintTags)
            {
              TagName = "ExitFib2" + TagCount;
              ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit+70*Point);
              ObjectSetText(TagName, "EXIT2 " + TagCount + " (Fib2 233)", 8, "Arial", White);
            }
            
            Bought2 = False;
            if ( FullTrade )
            {
              PandL = PandL + 233;
            }
            else
            {
              PandL = PandL + (233)/2;
            }            
          }
        }

        // Exit on Fib 3
        if (Bought3)
        {
          if ( High[i] > (BoughtAt + 377*Point))
          {
            // Find the height of the tag - this should not cover any bars
            RangeLimit = Low[i];
            for ( j = i - 7 ; j < i + 7 ; j++)
            {
              if (Low[j] < RangeLimit)
              {
                RangeLimit = Low[j];
              }
            }

            ExtMapBuffer3[i] = RangeLimit + 25*Point;
            if (PrintTags)
            {
              TagName = "ExitFib3" + TagCount;
              ObjectCreate(TagName, OBJ_TEXT, 0, Time[i], RangeLimit+70*Point);
              ObjectSetText(TagName, "EXIT3 " + TagCount + " (Fib3 377)", 8, "Arial", White);
            }
            
            // We are now out of the trade
            Bought3 = False;
            InTrade=False;
            if ( FullTrade )
            {
              PandL = PandL + 377;
            }
            else
            {
              PandL = PandL + (377)/2;
            }            
          }
        }
      }
    }
  }

  Comment(Symbol() + "-ThisWeekDirection-" + ValueIndex + "\n" + Direction + ":(" + GlobalVariableGet(Symbol() + "-ThisWeekDirection-" + ValueIndex) + ")\nP&L: " + PandL);

  return(0);
}
//+------------------------------------------------------------------+