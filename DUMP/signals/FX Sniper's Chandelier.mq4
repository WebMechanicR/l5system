
#property link      ""
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Blue
#property indicator_chart_window


//---- buffers
double Buffer1[];
double Buffer2[];
extern int ATR_Period = 10;
extern double Chandelier_Factor = 1.25;
extern int Entry_Bar = 1;
bool iSL = true;
extern bool LONG = true;
extern double Initial_SL_Factor = 0.75;
int i;
double lprice[],hprice[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);

   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,Buffer2);
   SetIndexLabel(0,"L Stop");
   SetIndexLabel(1,"S Stop");
   SetIndexBuffer(2,lprice);
   SetIndexBuffer(3,hprice);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
 for (i=Bars;i >=0;i--)
   {
   Buffer1[i] = EMPTY_VALUE;
   Buffer2[i] = EMPTY_VALUE;
 
   }

//----
   return(0);
  }
//====================================================================
int start()
  {
   int    counted_bars=IndicatorCounted();
 
   

if (LONG==true)
//=================================  LONG =============================
{
   if (iSL == true)
   {
   Buffer1[Entry_Bar]= Open[Entry_Bar] - Initial_SL_Factor * iATR(NULL,0,ATR_Period,Entry_Bar);
   iSL = false;
   }

   else
   {
      for( i=Entry_Bar-1;i>=0;i--)
      {
         if (High[i] <= High[i+1])
         Buffer1[i]= Buffer1[i+1];
         else
         {
         if (Buffer1[i+1] >= High[i] - Chandelier_Factor * iATR(NULL,0,ATR_Period,i+1))
            Buffer1[i] = Buffer1[i+1];
         else    
            Buffer1[i]= High[i] - Chandelier_Factor * iATR(NULL,0,ATR_Period,i+1);
         }
      }   
    }
      
     
   
}   
//=================== SHORT ==========================

else
      {
         if (iSL == true)
         {
            Buffer2[Entry_Bar]= Low[Entry_Bar] + Initial_SL_Factor * iATR(NULL,0,ATR_Period,Entry_Bar);
            iSL = false;
         }
         else
         {
            for( i=Entry_Bar-1;i>=0;i--)
            {
               if (Low[i] >= Low[i+1])
               Buffer2[i]= Buffer2[i+1];
               else
               {
                  if(Buffer2[i+1] <= Low[i] + Chandelier_Factor * iATR(NULL,0,ATR_Period,i+1))
                  Buffer2[i]=Buffer2[i+1];
                  else
                  Buffer2[i]= Low[i] + Chandelier_Factor * iATR(NULL,0,ATR_Period,i+1);
               }
            }
         }

      }       
      
   return(0);
  }
//+------------------------------------------------------------------+