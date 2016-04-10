//+------------------------------------------------------------------+
//|                                       i-GentorLSMA&EMA_v.1.0.mq4 |
//|                                                 FX Sniper, KimIV |
//|   2005.08.20 KimIV  v.0.0                                        |
//| Соединил в LSMA и EMA                                            |
//|   2005.08.20 KimIV  v.0.2                                        |
//| Синхронизировал нумерацию версий с i-GentorCCIM_v.0.2.mq4        |
//|   2005.08.21 KimIV  v.1.0                                        |
//| Вынес во внешний параметр расстояние от нуля для ЕМА и LSMA      |
//+------------------------------------------------------------------+
#property copyright "FX Sniper, KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_separate_window
#property indicator_buffers 4

#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Red      
#property indicator_color4 Lime

//------- Внешние параметры ------------------------------------------
extern int EMAPeriod  = 34;     // Период ЕМА
extern int LSMAPeriod = 25;     // Период LSMA
extern int FromZero   = 3;      // Расстояние от нулевого уровня

//------- Буферы индикатора ------------------------------------------
double LineHighEMA[];
double LineLowEMA[];
double LSMABuffer1[];
double LSMABuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  IndicatorDigits(2);

  SetIndexBuffer(0, LineHighEMA);
  SetIndexLabel (0, "EMA выше цены");
  SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, 3);
  SetIndexBuffer(1, LineLowEMA);
  SetIndexLabel (1, "EMA ниже цены");
  SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, 3);
  SetIndexBuffer(2, LSMABuffer1);
  SetIndexLabel (2, "LSMA выше цены");
  SetIndexStyle (2, DRAW_LINE, STYLE_SOLID, 3);
  SetIndexBuffer(3, LSMABuffer2);
  SetIndexLabel (3, "LSMA ниже цены");
  SetIndexStyle (3, DRAW_LINE, STYLE_SOLID, 3);
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  double sum, lengthvar, tmp, wt;
  int i, shift, counted_bars = IndicatorCounted();
  int Draw4HowLong, loopbegin;

  if (counted_bars<0) return;
  if (counted_bars>0) counted_bars--;
  counted_bars = Bars - counted_bars;
  for (shift=0; shift<counted_bars; shift++) {
    LineLowEMA[shift] = -FromZero;
    LineHighEMA[shift] = -FromZero;

    double EmaValue = iMA(NULL, 0, EMAPeriod, 0, MODE_EMA, PRICE_TYPICAL, shift);
    if (Close[shift]>EmaValue) LineHighEMA[shift] = EMPTY_VALUE;
    if (Close[shift]<EmaValue) LineLowEMA[shift] = EMPTY_VALUE;
  }

  Draw4HowLong = Bars-LSMAPeriod - 5;
  loopbegin = Draw4HowLong - LSMAPeriod - 1;

  for(shift=loopbegin; shift>=0; shift--) {
    sum = 0;
    for (i=LSMAPeriod; i>=1; i--) {
      lengthvar = LSMAPeriod + 1;
      lengthvar /= 3;
      tmp = 0;
      tmp = (i - lengthvar) * Close[LSMAPeriod-i+shift];
      sum+=tmp;
    }
    wt = sum * 6 / (LSMAPeriod * (LSMAPeriod + 1));

    LSMABuffer1[shift] = FromZero;
    LSMABuffer2[shift] = FromZero;

    if (wt>Close[shift]) LSMABuffer2[shift] = EMPTY_VALUE;
    if (wt<Close[shift]) LSMABuffer1[shift] = EMPTY_VALUE;
  }
}
//+------------------------------------------------------------------+

