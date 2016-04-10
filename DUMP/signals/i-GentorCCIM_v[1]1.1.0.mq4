//+------------------------------------------------------------------+
//|                                           i-GentorCCIM_v.1.0.mq4 |
//|                                                  Egorov Gennadiy |
//|   2005.08.20 KimIV  v.0.0                                        |
//| Немного модернизировал, добавив LSMA и поменяв её местами с ЕМА  |
//|   2005.08.20 KimIV  v.0.1                                        |
//| Освободил один буфер                                             |
//|   2005.08.20 KimIV  v.0.2                                        |
//| Убрал LSMA и EMA.                                                |
//| Сделал сигнальный шестой бар и трендовую раскраску               |
//|   2005.08.20 KimIV  v.0.3                                        |
//| Попытка убрать глюк с трендовой окраской.                        |
//|   2005.08.21 KimIV  v.0.4                                        |
//| Последовательность отрисовки линий (TCCI поверх остальных).      |
//| Комментарии.                                                     |
//|   2005.08.21 KimIV  v.1.0                                        |
//| Номер сигнального бара и дельту во внешние параметры.            |
//+------------------------------------------------------------------+
#property copyright "Egorov Gennadiy, FX Sniper, KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_separate_window
#property indicator_buffers 6

#property indicator_color1 Silver
#property indicator_color2 Yellow
#property indicator_color3 Lime
#property indicator_color4 Red      
#property indicator_color5 Black
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
extern int  SlowCCIPeriod = 14;   // Период медленного CCI
extern int  FastCCIPeriod = 6;    // Период быстрого CCI
extern int  NSignalBar    = 6;    // Номер сигнального бара
extern int  Delta         = 3;    // Допуск в барах
extern bool ShowComment   = True; // Показывать комментарии

//------- Буферы индикатора ------------------------------------------
double FastCCI[];
double SlowCCI[];
double HistCCI[];
double SignalBar[];
double TrendUp[];
double TrendDn[];

//------- Глобальные переменные --------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  IndicatorDigits(2);

  SetIndexStyle (0, DRAW_HISTOGRAM, STYLE_SOLID, 1);
  SetIndexBuffer(0, HistCCI);
  SetIndexStyle (1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(1, SignalBar);
  SetIndexStyle (2, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(2, TrendUp);
  SetIndexStyle (3, DRAW_HISTOGRAM, STYLE_SOLID, 2);
  SetIndexBuffer(3, TrendDn);
  SetIndexStyle (4, DRAW_LINE, STYLE_SOLID, 2);
  SetIndexBuffer(4, SlowCCI);
  SetIndexStyle (5, DRAW_LINE, STYLE_SOLID, 1);
  SetIndexBuffer(5, FastCCI);
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
  bool fcu=False, fcd=False, fup=False, fdn=False;
  int shift, ss;
  string comm;
//  int counted_bars=IndicatorCounted();

//  if (counted_bars<0) return;
//  if (counted_bars>0) counted_bars--;
//  for (shift=counted_bars; shift>=0; shift--) {
  for (shift=Bars; shift>=0; shift--) {
    TrendUp[shift] = 0;
    TrendDn[shift] = 0;
    FastCCI[shift] = iCCI(NULL, 0, FastCCIPeriod, PRICE_TYPICAL, shift);
    SlowCCI[shift] = iCCI(NULL, 0, SlowCCIPeriod, PRICE_TYPICAL, shift);
    HistCCI[shift] = SlowCCI[shift];
    if (HistCCI[shift+1]*HistCCI[shift]<0) {
      if (ss<=Delta) {
        if (fup && HistCCI[shift]>0) fcu = True;
        else fcu = False;
        if (fdn && HistCCI[shift]<0) fcd = True;
        else fcd = False;
      } else {
        if (ss<NSignalBar) {
          fup = False; fdn = False;
          fcu = False; fcd = False;
          comm = "No Trend";
        }
      }
      ss = 1;
    } else ss++;
    if (ss==NSignalBar) SignalBar[shift] = HistCCI[shift];
    else SignalBar[shift] = 0;
    if ((ss>NSignalBar || fcu) && HistCCI[shift]>0) {
      TrendUp[shift] = HistCCI[shift];
      fup = True; fdn = False; fcd = False;
      comm = "Up Trend "+(ss-NSignalBar);
    }
    if ((ss>NSignalBar || fcd) && HistCCI[shift]<0) {
      TrendDn[shift] = HistCCI[shift];
      fdn = True; fup = False; fcu = False;
      comm = "Down Trend "+(ss-NSignalBar);
    }
  }
  if (ShowComment) Comment(comm);
}
//+------------------------------------------------------------------+

