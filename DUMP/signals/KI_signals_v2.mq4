
//+------------------------------------------------------------------+
//|                                                KI_signals_v1.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 SteelBlue
#property indicator_color2 Orange
#property indicator_color3 DodgerBlue
#property indicator_color4 Magenta
#property indicator_color5 Blue
#property indicator_color6 Red

#property indicator_level1 0

extern int Length1 = 3;
extern int Length2 = 10;
extern int Length3 = 16;
 bool showHL = false; 
 bool showCrosses = false;

double Histo[];
double MaHisto[];

double up[];
double dn[]; 

double high[];
double valley[];

double cUp[];
double cDn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- additional buffers are used for counting
   IndicatorBuffers(8);

   SetIndexStyle(0,DRAW_ARROW,EMPTY,0);
   SetIndexStyle(1,DRAW_ARROW,EMPTY,0);

   SetIndexStyle(2,DRAW_ARROW,EMPTY,1);
   SetIndexStyle(3,DRAW_ARROW,EMPTY,1);
   
   SetIndexStyle(4,DRAW_ARROW,EMPTY,0);
   SetIndexStyle(5,DRAW_ARROW,EMPTY,0);
   
   SetIndexArrow(0,217);
   SetIndexArrow(1,218);

   SetIndexArrow(2,233);
   SetIndexArrow(3,234);

   SetIndexArrow(4,108);
   SetIndexArrow(5,108);
   
   IndicatorDigits(6);
   
   SetIndexBuffer(0,high);
   SetIndexBuffer(1,valley);

   SetIndexBuffer(2,up);
   SetIndexBuffer(3,dn);

   SetIndexBuffer(4,cUp);
   SetIndexBuffer(5,cDn);
   
   SetIndexBuffer(6,Histo);
   SetIndexBuffer(7,MaHisto);
   
   IndicatorShortName("KI signals v1");
   
   SetIndexLabel(2,"UP SIGNAL");
   SetIndexLabel(3,"DN SIGNAL");
   
   
   
   return(0);
  }
//+------------------------------------------------------------------+
//| SignalIndicator                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
      
   for(int i = 0 ;i <= limit ;i++)Histo[i] = iMA(Symbol(),0,Length1,0,MODE_EMA,PRICE_CLOSE,i) - iMA(Symbol(),0,Length2,0,MODE_EMA,PRICE_CLOSE,i);      
   
   for(int j = 0 ;j <= limit ;j++)MaHisto[j] = iMAOnArray(Histo,0,Length3,0,MODE_EMA,j);
   
   for(int m = 0 ;m <= limit ;m++)
   {
      if(MaHisto[m+1] <= 0 && MaHisto[m]>0)
      {
         up[m] = Open[m]-(5*Point);
      }
      
      if(MaHisto[m+1] >= 0 && MaHisto[m]<0)
      {
         dn[m] = Open[m]+(5*Point);
      }
   
   
      if(showHL)
      {   
         if(Histo[m]<= 0 && Histo[m+2]<= Histo[m+1] && Histo[m+1]>Histo[m])
         {
            high[m+1] = High[m+1]+(2*Point);
         }
      
         if(Histo[m]>= 0 && Histo[m+2]>= Histo[m+1] && Histo[m+1]<Histo[m])
         {
            valley[m+1] = Low[m+1]+(2*Point);
         }
      }  
      
      if(showCrosses)
      {
         if(Histo[m+1] <= MaHisto[m+1] && Histo[m] > MaHisto[m])
         {
            cUp[m] = Open[m];
         }
      
         if(Histo[m+1] >= MaHisto[m+1] && Histo[m] < MaHisto[m])
         {
            cDn[m] = Open[m];
         }
      }      
      
      
   }
//----
 return(0);
  }
//+------------------------------------------------------------------+