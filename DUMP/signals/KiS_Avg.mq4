//+------------------------------------------------------------------+
//| KiS_max_min_Avg.mq4 |
//+------------------------------------------------------------------+
/*[[
Name := KiS_max_min_Avg
Author := KCBT
Link := http://www.kcbt.ru/forum/index.php?
]]*/

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 MediumOrchid
#property indicator_color2 Aqua
#property indicator_color3 MediumOrchid
//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
SetIndexBuffer(0, ExtMapBuffer1);
SetIndexStyle(0, DRAW_LINE);
SetIndexBuffer(1, ExtMapBuffer2);
SetIndexStyle(1, DRAW_LINE);
SetIndexBuffer(2, ExtMapBuffer3);
SetIndexStyle(2, DRAW_LINE);
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
Comment("");
return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int shift, i, CurDay, BarCount;
double DayMax, DayMin;
double DayOpen, DayClose, Avg;

for (shift=Bars-1; shift>=0; shift--) {
if (CurDay != TimeDay(Time[shift])) {
for (i=BarCount; i>=0; i--) {
ExtMapBuffer1[shift+i] = DayMax;
ExtMapBuffer2[shift+i] = (DayMax+DayMin)/2;
ExtMapBuffer3[shift+i] = DayMin;
}
CurDay = TimeDay(Time[shift]);
BarCount = 0;
DayMax = 0;
DayMin = 1000; //Заранее больше, чтоб уменьшился в процессе
DayOpen = Open[shift];
}
if (DayMax < High[shift]) {DayMax = High[shift];}
if (DayMin > Low[shift]) {DayMin = Low[shift];}
BarCount = BarCount + 1;
}

// это дорисовка последнего, незавершенного еще, дня
for (i=BarCount; i>=0; i--) {
ExtMapBuffer1[shift+i] = DayMax;
ExtMapBuffer2[shift+i] = (DayMax+DayMin)/2;
ExtMapBuffer3[shift+i] = DayMin;
}
DayClose = Close[0];
Avg = (DayMax+DayMin)/2; //средняя за текущий день

Comment("Max:", DayMax," Min:", DayMin, "\n", "Avg:", Avg, " Width:", (DayMax-DayMin)/Point,"\n","From Avg to Open:",MathRound(MathAbs(Avg-DayOpen)/Point),"\n","From Avg to Close:",MathRound(MathAbs(Avg-DayClose)/Point));
return(0);
}
//+------------------------------------------------------------------+ 