//+------------------------------------------------------------------+
//|                                                Freeway - All.mq4 |
//|                                      Copyright © 2006, Eli hayun |
//|                                          http://www.elihayun.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eli hayun"
#property link      "http://www.elihayun.com"

#property indicator_chart_window
//---- input parameters
extern int       CCI_Value=50;
extern bool      UseCurrentCurrency = false;

string Currencies[] = {"AUDUSD","CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP",
                       "EURJPY","EURUSD","GBPCHF","GBPJPY","GBPUSD","USDCAD",
                       "USDCHF","USDJPY"};

string   Alerted[] = {"","","","","","","","","","","","","",""};
string sComment = "", sCurrComment = "";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

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
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   bool GoCheck;
   // For every 15 minutes check if the freeway is open (all > 0 or all < 0)
   if (NewBar())
   {
      sComment = "";
      for (int ii=0; ii<ArraySize(Currencies); ii++)
      {
         GoCheck = !UseCurrentCurrency;
         if (UseCurrentCurrency)
            if (Symbol() == Currencies[ii])
               GoCheck = true;
               
         if (GoCheck)
         {
            CheckFreeway(Currencies[ii],ii);      
            if (sCurrComment != "")
               sComment = sCurrComment + "\n" + sComment;
         }
      }
      if (sComment != "")
         Comment(sComment);
   }
   return(0);
  }
//+------------------------------------------------------------------+

bool NewBar()
{
   static datetime dt = 0;
   if (iTime(NULL, PERIOD_M15, 0) != dt)
   {
      dt = iTime(NULL, PERIOD_M15, 0);
      return(true);
   }
   return(false);
}

void CheckFreeway(string Curr, int idx)
{
   int cci[4];
   int tf[4] = {PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4};
   string  tfName[4] = {"M15", "M30", "H1", "H4"};
   string sDir = "";
   
   sCurrComment = Curr + ": ";
   
   for (int ii=0; ii<4; ii++)
   {
      double c = iCCI(Curr, tf[ii], CCI_Value, PRICE_TYPICAL, 0);
      sCurrComment = sCurrComment + " " + tfName[ii] + ": " + DoubleToStr(c,4);
      cci[ii] = -1;
      if (c > 0) cci[ii] = 1;
      if (c < 0) cci[ii] = 0;
   }
   
   // If all values in cci[] are 1 - go up 
   // If all values in cci[] are 0 - go down
   if (cci[0] + cci[1] + cci[2] + cci[3] == 4)
      sDir = "Up";
   if (cci[0] + cci[1] + cci[2] + cci[3] == 0)
      sDir = "Down";
      
   if (sDir != "" && (Alerted[idx] != sDir))
   {
      Alert("Freeway: ", Curr, " road clear to go ", sDir);
      PlaySound("alert1.wav");
      Alerted[idx] = sDir;
   } else {
      sCurrComment = "";
   }
}

