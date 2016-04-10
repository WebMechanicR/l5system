#property copyright "Copyright © 2005, Gaba"
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Silver
#property indicator_color2 LimeGreen
#property indicator_color3 OrangeRed
#property indicator_color4 Silver
#property indicator_color5 Black

#property indicator_minimum -300
#property indicator_maximum  300

#property indicator_level1  200
#property indicator_level2  100
#property indicator_level3 -100
#property indicator_level4 -200


//////////////////////////////////////////////////////////////////////
// Пареметы
//////////////////////////////////////////////////////////////////////

extern int fastPeriod  = 6;
extern int slowPeriod  = 14;
extern int histLength  = 500;

//////////////////////////////////////////////////////////////////////
// Буферы данных
//////////////////////////////////////////////////////////////////////

double FastBuffer[];    // Быстрый CCI
double SlowBuffer[];    // Медленный CCI
double HistBuffer[];
double UpTrBuffer[];
double DnTrBuffer[];

//////////////////////////////////////////////////////////////////////
// Инициализация
//////////////////////////////////////////////////////////////////////

int init()
{
   string short_name;
   IndicatorBuffers(5);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   short_name="WoodiesCCI("+fastPeriod+","+slowPeriod+")";
   IndicatorShortName(short_name);
   // indicator lines ////////////////////////////////
   SetIndexStyle(0, DRAW_HISTOGRAM);   
   SetIndexBuffer(0, HistBuffer);
   SetIndexDrawBegin(0, slowPeriod);
   SetIndexLabel(0,"SlowCCI histogram");      
   SetIndexEmptyValue(0, EMPTY_VALUE);  
   //////////////////////////////////////////////////
   SetIndexStyle(1, DRAW_HISTOGRAM);   
   SetIndexBuffer(1, UpTrBuffer);
   SetIndexDrawBegin(1, slowPeriod); 
   SetIndexLabel(1,"UpTrend histogram");           
   SetIndexEmptyValue(1, EMPTY_VALUE);  
   //////////////////////////////////////////////////
   SetIndexStyle(2, DRAW_HISTOGRAM);   
   SetIndexBuffer(2, DnTrBuffer);
   SetIndexDrawBegin(2, slowPeriod);  
   SetIndexLabel(2,"DnTrend histogram");     
   SetIndexEmptyValue(2, EMPTY_VALUE);  
   //////////////////////////////////////////////////
   SetIndexStyle(3, DRAW_LINE,1,3);   
   SetIndexBuffer(3, SlowBuffer);
   SetIndexDrawBegin(3, slowPeriod);     
   SetIndexLabel(3,"SlowCCI("+slowPeriod+")");   
   SetIndexEmptyValue(3, EMPTY_VALUE);  
   //////////////////////////////////////////////////
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, FastBuffer);
   SetIndexDrawBegin(4, slowPeriod);     
   SetIndexLabel(4,"FastCCI("+fastPeriod+")");  
   SetIndexEmptyValue(4, EMPTY_VALUE);  
   //////////////////////////////////////////////////
   return(0);
}
  
//////////////////////////////////////////////////////////////////////
// Custor indicator deinitialization function                       
//////////////////////////////////////////////////////////////////////

int deinit()
{
   // TODO: add your code here
   return(0);
}

//////////////////////////////////////////////////////////////////////
// Custom indicator iteration function                              
//////////////////////////////////////////////////////////////////////

int start()
{
   string symbolName;
   int i, shift, checksum, counted_bars=IndicatorCounted();
   double slowCCI=0.0;
   if (Bars<slowPeriod) return(0); 
   // check for possible errors
   if (counted_bars<0) return(-1);
   // last counted bar will be recounted
   if (counted_bars>0) counted_bars++;
   int limit=Bars-counted_bars;
   if (counted_bars<1 || checksum!=(histLength+fastPeriod+slowPeriod+Period()) || symbolName!=Symbol())
   {
      // Параметры изменены, проводим реинициализацию 
      for(i=Bars-1; i<=Bars-histLength; i++) 
      {
         FastBuffer[i]=EMPTY_VALUE;    // Быстрый CCI
         SlowBuffer[i]=EMPTY_VALUE;    // Медленный CCI
         HistBuffer[i]=EMPTY_VALUE;    // Гистограмма медленного CCI
         UpTrBuffer[i]=EMPTY_VALUE;    // Направление тренда
         DnTrBuffer[i]=EMPTY_VALUE;    // Направление тренда
      }
      checksum = histLength+fastPeriod+slowPeriod+Period(); 
      symbolName=Symbol();
      limit = histLength;
   }   
   for (shift=limit; shift>=0; shift--)
   {
      FastBuffer[shift] = iCCI(NULL,0,fastPeriod,PRICE_TYPICAL,shift);
      SlowBuffer[shift] = iCCI(NULL,0,slowPeriod,PRICE_TYPICAL,shift);
      HistBuffer[shift] = SlowBuffer[shift];
      UpTrBuffer[shift] = EMPTY_VALUE;
      DnTrBuffer[shift] = EMPTY_VALUE;         
      //	Заполнение массива точек и определение тренда
      int a, up=0, dn=0;
      for (a=0;a<8;a++)
      {  
         slowCCI=iCCI(NULL,0,slowPeriod,PRICE_TYPICAL,shift+a);
         if (slowCCI>0) up++;
         if (slowCCI<=0) dn++;		         
		}
      if (up>=6) UpTrBuffer[shift]=SlowBuffer[shift];
      if (dn>=6) DnTrBuffer[shift]=SlowBuffer[shift];      
   }    
   return(0);
}

//////////////////////////////////////////////////////////////////////




