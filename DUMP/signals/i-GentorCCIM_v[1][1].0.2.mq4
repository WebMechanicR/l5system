//+------------------------------------------------------------------+
//|                                           i-GentorCCIM_v.0.2.mq4 |
//|                                                  Egorov Gennadiy |
//| 2005.08.20 KimIV  v.0.0                                          |
//| Немного модернизировал, добавив LSMA и поменяв её местами с ЕМА  |
//| 2005.08.20 KimIV  v.0.1                                          |
//| Освободил один буфер                                             |
//| 2005.08.20 KimIV  v.0.2                                          |
//| Убрал LSMA и EMA.                                                |
//| Сделал сигнальный шестой бар и трендовую раскраску               |
//+------------------------------------------------------------------+
#property copyright "Egorov Gennadiy, FX Sniper, KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_separate_window
#property indicator_buffers 6

#property indicator_color1 Red
#property indicator_color2 Black
#property indicator_color3 Silver
#property indicator_color4 Yellow
#property indicator_color5 Lime
#property indicator_color6 Red      

#property indicator_level1 300
#property indicator_level2 200
#property indicator_level3 100
#property indicator_level4 50
#property indicator_level5 -50
#property indicator_level6 -100
#property indicator_level7 -200
#property indicator_level8 -300

//------- Внешние параметры ------------------------------------------
extern int SlowCCIPeriod = 14;  // Период медленного CCI
extern int FastCCIPeriod = 6;   // Период быстрого CCI

//------- Буферы индикатора ------------------------------------------
double FastCCI[];
double SlowCCI[];
double HistCCI[];
double SignalBar[];
double TrendUp[];
double TrendDown[];

//------- Глобальные переменные --------------------------------------
bool fct=False, fup=False, fdn=False;
int ss=1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  IndicatorDigits(2);

  SetIndexStyle (0, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexBuffer(0, FastCCI);
  SetIndexStyle (1, DRAW_LINE, STYLE_SOLID, 2);
  SetIndexBuffer(1, SlowCCI);
  SetIndexStyle (2, DRAW_HISTOGRAM, STYLE_SOLID, 1);
  SetIndexBuffer(2, HistCCI);
  SetIndexStyle (3, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(3, SignalBar);
  SetIndexStyle (4, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(4, TrendUp);
  SetIndexStyle (5, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(5, TrendDown);
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  int shift;
  int counted_bars=IndicatorCounted();

  if (counted_bars<0) return;
  if (counted_bars>0) counted_bars--;
//  for (shift=counted_bars; shift>=0; shift--) {
  for (shift=Bars; shift>=0; shift--) {
    TrendUp[shift] = 0;
    TrendDown[shift] = 0;
    FastCCI[shift] = iCCI(NULL, 0, FastCCIPeriod, PRICE_TYPICAL, shift);
    SlowCCI[shift] = iCCI(NULL, 0, SlowCCIPeriod, PRICE_TYPICAL, shift);
    HistCCI[shift] = SlowCCI[shift];
    if (HistCCI[shift+1]*HistCCI[shift]<0) {
      if (ss<=3) {
        if ((fup && HistCCI[shift]>0)
        || (fdn && HistCCI[shift]<0)) fct = True;
      } else fct = False;
      ss = 1;
    }
    if (ss==6) SignalBar[shift] = HistCCI[shift];
    else SignalBar[shift] = 0;
    if (ss>6 || fct) {
      if (HistCCI[shift]>=0) {
        TrendUp[shift] = HistCCI[shift];
        fup = True; fdn = False;
      } else {
        TrendDown[shift] = HistCCI[shift];
        fdn = True; fup = False;
      }
    }
    ss++;
  }
}
//+------------------------------------------------------------------+

