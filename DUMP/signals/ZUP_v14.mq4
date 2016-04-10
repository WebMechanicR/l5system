//compile//
//+----------------------------------------------------------------------+
//|ZigZag с чилами Песавенто                                             |
//|----------------------------------------------------------------------+
//|                                                                      |
//|ExtIndicator - выбор варианта индикатора, на основе которого          |
//|               строятся паттерны Песавенто                            |
//|           0 - Zigzag из метатрейдера,                                |
//|           1 - Zigzag Алекса,                                         |
//|           2 - индикатор подобный встроенному в Ensign                |
//|                                                                      |
//|minBars - фильтр баровый (задается количество баров)                  |
//|minSize - фильтр по количеству пунктов (задается количество пунктов)  |
//|                                                                      |
//|minPercent - процентный фильтр (задается процент, например 0.5)       |
//|             Если ипользуются проценты - ставите число, а minSize=0;  |
//|                                                                      |
//|                                                                      |
//|ExtHidden - 0 - все линии скрыты. Обычный ZigZag.                     |
//|            1 - показывает все линии между фракталами, у которых      |
//|                процент восстановления >0.21 и <5.                    |
//|            2 - показывает только те  линии, где процент восстано-    |
//|                вления равен числам Песавенто (и 0.866 для постро-    |
//|                ения паттернов Gartley)                               |
//|            3 - показывает числа, перечисленные в пункте 2            |
//|                и соответствующие линии                               |
//|            4 - показывает числа не Песавенто и соответствующие линии |
//|                                                                      |
//|                                                                      |
//|ExtFractal - количество фракталов (максимумов, минимумов),            |
//|             от которых идут линии к другим фракталам                 |
//|                                                                      |
//|ExtFractalEnd - количество фракталов, к которым идут линии            |
//|                дальше этого фрактала соединяющих линий не будет      |
//|                Если ExtFractalEnd=0 то последний фрактал равен       |
//|                максимальному числу фракталов.                        |
//|                Минимальное значение ExtFractalEnd=5                  |
//|                                                                      |
//|ExtDelta - (допуск) отклонение в расчете. Задает величину             |
//|           потенциальной разворотной зоны.                            |
//|                  должно быть 0<ExtDelta<1                            |
//|                                                                      |
//|ExtDeltaType -    0 - выводятся проценты восстановления "как есть"    |
//|                  1 - расчет допуска (%-число Песавенто)<ExtDelta     |
//|                  2 - ((%-число Песавенто)/число Песавенто)<ExtDelta  |
//|                                                                      |
//|chHL     = true     - Если хотите посмотреть уровни подтверждения     |
//|PeakDet  = true     - Если хотите посмотреть уровни предыдущих        |
//|                                                                      |
//|ExtFiboDinamic - разрешает вывод днамических уровней фибо.            |
//|                 Динамические уровни фибо выводятся на первом луче    |
//|                 ZigZag-a.                                            |
//|                                                                      |
//|ExtFiboStatic - разрешает вывод статических уровней фибо              |
//|                                                                      |
//|ExtFiboStaticNum - номер луча ZigZag-a, от которого будут выводиться  |
//|                   статические уровни Фибоначчи. 1<ExtFiboStaticNum<9 |
//|                                                                      |
//|ExtSizeTxt - размер шрифта для вывода чисел                           |
//|                                                                      |
//|ExtLine - выбор цвета соединительных линий                            |
//|                                                                      |
//|ExtPesavento - выбор цвета чисел Песавенто                            |
//|                                                                      |
//|ExtGartley866 - выбор цвета числа .866                                |
//|                                                                      |
//|ExtNotFibo - выбор цвета всех остальных чисел                         |
//|                                                                      |
//|ExtFiboS и ExtFiboD - выбор цвета статических и динамических фиб.     |
//|                                                                      |
//|ExtDeleteObj = true - включается принудительное удаление всех         |
//|               трендовых линий и текстовых объектов.                  |
//|                                                                      |
//|ExtDeviation и ExtBackstep - параметры оставшиеся от ZigZag из MT4    |
//|                                                                      |
//+----------------------------------------------------------------------+
#property copyright "nen"
#property link      "http://onix-trade.net/forum/index.php?s=&showtopic=118&view=findpost&p=46508"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Orange
#property indicator_color4 LightSkyBlue
#property indicator_color5 LemonChiffon
//---- indicator parameters
extern int ExtIndicator=2;
extern int minBars=12;
extern int minSize = 15;
extern double minPercent = 0;
extern int ExtHidden=1;
extern int ExtFractal=8;
extern int ExtFractalEnd=8;
extern double ExtDelta=0.04;
extern int ExtDeltaType=2;
extern bool chHL = false;
extern bool PeakDet = false;
//-------------------------------------
extern bool ExtFiboDinamic=false;
extern bool ExtFiboStatic=false;
extern int ExtFiboStaticNum=2;
extern int ExtSizeTxt=7;
extern color ExtLine=DarkBlue;
extern color ExtNotFibo=SlateGray;
extern color ExtPesavento=Yellow;
extern color ExtGartley866=GreenYellow;
extern color ExtFiboS=Teal;
extern color ExtFiboD=Sienna;
// Переменные от ZigZag из МТ
extern bool ExtDeleteObj=false;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

// Массивы для ZigZag 
// Массив для отрисовки ZigZag
double zz[];
// Массив минимумов ZigZag
double zzL[];
// Массив максимумов ZigZag
double zzH[];

// Переменные для оснавстки
// Массив чисел Песавенто (Фибы и модифицированные Фибы)
double fi[]={0.382, 0.5, 0.618, 0.707, 0.786, 0.841, 0.886, 1.0, 1.128, 1.272, 1.414, 1.5, 1.618, 2.0, 2.414, 2.618, 4.0};
string fitxt[]={ ".382", ".5", ".618", ".707", ".786", ".841", ".886", "1.0", "1.128", "1.272", "1.414", "1.5", "1.618", "2.0", "2.414", "2.618", "4.0" };
string nameObj,nameObjtxt;
// Матрица для поиска исчезнувших баров afr - массив значений времени пяти последних фракталов и отрисовки динамических и статических фиб
// afrl - минимумы, afrh - максимумы
int afr[]={0,0,0,0,0,0,0,0,0,0};
double afrl[]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0}, afrh[]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
bool afrm=true;
double HL,HLp,kk,kj,Angle;
// LowPrim,HighPrim,LowLast,HighLast - значения минимумов и максимумов баров
double LowPrim,HighPrim,LowLast,HighLast;
// numLowPrim,numHighPrim,numLowLast,numHighLast -номера баров
int numLowPrim,numHighPrim,numLowLast,numHighLast,k,k1,k2,ki,countLow1,countHigh1,shift,shift1;
// Время свечи с первым от нулевого бара фракталом
int timeFr1new;
// Счетчик фракталов
int countFr;
// Бар, до которого надо рисовать соединительные линии от нулевого бара
int countBarEnd=0,TimeBarEnd;
// Бар, до которого надо пересчитывать от нулевого бара
int numBar=0;
// Номер объекта
int numOb;
// flagFrNew=true - образовался новый фрактал или первый фрактал сместился на другой бар. =false - по умолчанию.
bool flagFrNew=false;
// Период текущего графика
int perTF;

int counted_bars;

// Переменные для ZigZag Алекса и индикатора подобного встроенному в Ensign
double ha[],la[],hi,li,si,sip,di,hm,lm,ham[],lam[],him,lim,LastBar0,lLast=0,hLast=0;
int fs,fsp,countBar;
int ai,aip,bi,bip,ai0,aip0,bi0,bip0,Last_Bar,last0;
datetime tai,tbi,taip,tbip,ti,ts0=0,t0=0,taiLast,tbiLast;
bool fh=false,fl=false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(7);
//---- drawing settings
// ZigZag
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,zz);
   SetIndexBuffer(5,zzL);
   SetIndexBuffer(6,zzH);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(4,0.0);
   SetIndexEmptyValue(5,0.0);
   SetIndexEmptyValue(6,0.0);
//   ArraySetAsSeries(zz,true);
//   ArraySetAsSeries(zzL,true);
//   ArraySetAsSeries(zzH,true);
// Уровни предыдущих пиков
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT); 
   SetIndexBuffer(1,ham);
   SetIndexBuffer(2,lam);
// Уровни подтверждения
   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(3,ha);
   SetIndexBuffer(4,la);
   if (ExtIndicator==1) if (minSize!=0) di=minSize*Point/2;
   if (ExtIndicator==2)
     {
      if (minSize!=0) {di=minSize*Point; countBar=minBars;}
     }
// Проверка правильности введенных внешних переменных
   if (ExtDelta<=0) ExtDelta=0.001;
   if (ExtDelta>1) ExtDelta=0.999;

   if (ExtHidden<0) ExtHidden=0;
   if (ExtHidden>4) ExtHidden=4;
 
   if (ExtDeltaType<0) ExtDeltaType=0;
   if (ExtDeltaType>3) ExtDeltaType=3;

   if (ExtFractalEnd>0)
     {
      if (ExtFractalEnd<5) ExtFractalEnd=5;
     }
   if (ExtFiboStaticNum<2) ExtFiboStaticNum=2;
   if (ExtFiboStaticNum>9) ExtFiboStaticNum=9;

   perTF=Period();

   return(0);
  }
//+------------------------------------------------------------------+
//| Деинициализация. Удаление всех трендовых линий и текстовых объектов
//+------------------------------------------------------------------+
int deinit()
  {
   if (ExtDeleteObj) {ObjectsDeleteAll(0,2); ObjectsDeleteAll(0,21);}
   else delete_objects1();

   ObjectDelete("fiboS");ObjectDelete("fiboD"); return(0);
  }
//********************************************************
// НАЧАЛО
int start()
  {
   counted_bars=IndicatorCounted();

   if( counted_bars<0 )
   {
      Alert("Сбой расчета индикатора");
      return(-1);
   }

//-----------------------------------------
//
//     1.
//
// Блок заполнения буферов. 
// zz[] - буфер, данные из которого берутся для отрисовки самого ZigZag-a
// zzL[] - массив минимумов черновой
// zzH[] - массив максимумов черновой
// Начало. 
//-----------------------------------------   
//
// Сюда можно вставить любой инструмент,
// который заполняет три вышеперечисленых буфера.
// Индикатор будет строиться на основе данных,
// полученных от этого инструмента.
//
// Это для тех, кто захочет модифицировать индикатор.
//
//-----------------------------------------

if (perTF!=Period())
  {
   delete_objects1();  
   perTF=Period();
  }

if (ExtIndicator==0) ZigZag_();
if (ExtIndicator==1) ang_AZZ_();
if (ExtIndicator==2) Ensign_ZZ();
//-----------------------------------------
// Блок заполнения буферов. Конец.
//-----------------------------------------   

if (ExtHidden>0) // Разрешение на вывод оснастки. Начало.
  {
//======================
//======================
//======================

//-----------------------------------------
//
//     2.
//
// Блок подготовки данных. Начало.
//-----------------------------------------   

   if (Bars - counted_bars>2 || flagFrNew)
     {

      // Поиск времени и номера бара, до которого будут рисоваться соединительные линии 
      if (countBarEnd==0)
        {
         if (ExtFractalEnd>0)
           {
            k=ExtFractalEnd;
            for (shift=0; shift<Bars && k>0; shift++) 
              { 
               if (zz[shift]>0 && zzH[shift]>0) {countBarEnd=shift; TimeBarEnd=Time[shift]; k--;}
              }
           }
         else 
           {
            countBarEnd=Bars-3;
            TimeBarEnd=Time[Bars-3];
           }
        }
      else
        {
         countBarEnd=iBarShift(Symbol(),Period(),TimeBarEnd); 
        }

      // Инициализация матрицы
      matriza();
     }
//-----------------------------------------
// Блок подготовки данных. Конец.
//-----------------------------------------   


//-----------------------------------------
//
//     3.
//
// Блок проверок и удаления линий, 
// потерявших актуальность. Начало.
//-----------------------------------------   
// Коррекция соединяющих линий и чисел. Начало.

if (Bars - counted_bars<3)
  {
   // Поиск времени бара первого фрактала, считая от нулевого бара
   for (shift1=0; shift1<Bars; shift1++) 
     {
      if (zz[shift1]>0.0 && (zzH[shift1]==zz[shift1] || zzL[shift1]==zz[shift1])) 
       {
        timeFr1new=Time[shift1];
        break;
       }
     }
   // Поиск бара, на котором первый фрактал был ранее.
   shift=iBarShift(Symbol(),Period(),afr[0]); 
 
 
   // Сравнение текущего значения фрактала с тем, который был ранее

   // Образовался новый фрактал
   if (timeFr1new!=afr[0])
     {
      flagFrNew=true;
      if (shift>=shift1) numBar=shift; else  numBar=shift1;
      afrm=true;
     }

   // Фрактал на максимуме сдвинулся на другой бар
   if (afrh[0]>0 && zz[shift]==0.0)
     {
      flagFrNew=true;
      if (numBar<shift) numBar=shift;
      afrm=true;
     }
   // Фрактал на минимуме сдвинулся на другой бар
   if (afrl[0]>0 && zz[shift]==0.0)
     {
      flagFrNew=true;
      if (numBar<shift) numBar=shift;
      afrm=true;
     }


//-----------3 Сместился максимум или минимум, но остался на том же баре. Начало.

//============= 1 сместился максимум. Начало.
if (afrh[0]-High[shift]!=0 && afrh[0]>0)
  {

   numLowPrim=0; numLowLast=0;
   numHighPrim=shift; numHighLast=0;

   LowPrim=0.0; LowLast=0.0;
   HighPrim=High[shift]; HighLast=0.0;
   
   Angle=-100;

   for (k=shift+1; k<=countBarEnd; k++)
     {

      if (zzL[k]>0.0 && LowPrim==0.0 && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzL[k]>0.0 && zzL[k]<LowPrim && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzH[k]>0.0  && zzH[k]==zz[k])
        {
         if (HighLast>0) 
           {
            HighLast=High[k]; numHighLast=k;
           }
         else {numHighLast=k; HighLast=High[k];}
         
         HL=High[numHighLast]-Low[numLowPrim];
         kj=(HighPrim-HighLast)*1000/(numHighLast-numHighPrim);
         if (HL>0 && (Angle>kj || Angle==-100))  // Проверка угла наклона линии
           {
            Angle=kj;
// Создание линии
            HLp=High[numHighPrim]-Low[numLowPrim];
            k1=MathCeil((shift+numHighLast)/2);
            kj=HLp/HL;
// Поиск старой соединительной линии                 

            nameObj="ph" + Time[numHighPrim] + "_" + Time[numHighLast];
            nameObjtxt="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

            numOb=ObjectFind(nameObj);

            if (numOb>-1)
              {
               if (kj>0.21 && kj<=5)
                 {
                  // Перемещение объектов
                  ObjectMove(nameObj,0,Time[numHighPrim],High[numHighPrim]);
                  ObjectMove(nameObjtxt,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));

                  // Создание текстового объекта (числа Песавенто). % восстановления между максимумами
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)

                    // процент восстановления число Песавенто
                    if (ExtHidden!=4)
                      {
                       if (kk==0.886)
                         ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                       else
                         ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                      }
                    else
                    // процент восстановления (не Песавенто)
                      if (ExtHidden==1 || ExtHidden==4)
                        ObjectSetText(nameObjtxt,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                 }
               else
                 {
                  ObjectDelete(nameObj); 
                  ObjectDelete(nameObjtxt);
                 }
              }
            else
              {
//******* Прорисовка новой линии, если она появилась.
               if (kj>0.21 && kj<=5)
                 {
                  // Создание текстового объекта (числа Песавенто). % восстановления между максимумами
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                    // процент восстановления числа Песавенто и 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        ObjectCreate(nameObjtxt,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else
                    // процент восстановления (не Песавенто и 0.866)
                    {
                     if (ExtHidden==1 || ExtHidden==4)
                       {
                        ObjectCreate(nameObjtxt,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                        ObjectSetText(nameObjtxt,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                       }
                    }
                  if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                    {
                     ObjectCreate(nameObj,OBJ_TREND,0,Time[numHighPrim],High[numHighPrim],Time[numHighLast],High[numHighLast]);
                     ObjectSet(nameObj,OBJPROP_RAY,false);
                     ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                     ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                    }
                 }
//*******
               }
             }
        }
     }
     afrh[0]=High[shift];
     if (ExtFiboDinamic)
       {
        screenFiboD();
       }
   }
//============= 1 сместился максимум. Конец.
//
//============= 1 сместился минимум. Начало.
if (afrl[0]-Low[shift]!=0 && afrl[0]>0)
  {

   numLowPrim=0; numLowLast=0;
   numHighPrim=shift; numHighLast=0;

   LowPrim=Low[shift]; LowLast=0.0;
   HighPrim=0.0; HighLast=0.0;
   
   Angle=-100;
   for (k=shift+1; k<=countBarEnd; k++)
     {
      if (zzH[k]>HighPrim) {HighPrim=High[k]; numHighPrim=k;}
      if (zzL[k]>0.0 && zzL[k]==zz[k]) 
        {
         if (LowLast>0) 
           {
            LowLast=Low[k]; numLowLast=k;
           }
         else {numLowLast=k; LowLast=Low[k];}

         HL=High[numHighPrim]-Low[numLowLast];
         kj=(LowPrim-LowLast)*1000/(numLowLast-numLowPrim);
         if (HL>0 && (Angle<kj || Angle==-100))  // Проверка угла наклона линии
           {
            Angle=kj;

            HLp=High[numHighPrim]-Low[numLowPrim];
            k1=MathCeil((numLowPrim+numLowLast)/2);
            kj=HLp/HL;
// Поиск старой соединительной линии                 

            nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];
            nameObjtxt="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

            numOb=ObjectFind(nameObj);
            if (numOb>-1)
              {
               if (kj>0.21 && kj<=5)
                 {
                  // Перемещение объектов
                  ObjectMove(nameObj,0,Time[numLowPrim],Low[numLowPrim]);
                  ObjectMove(nameObjtxt,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));

                  // Создание текстового объекта (числа Песавенто). % восстановления между минимумами
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                  // процент восстановления числа Песавенто и 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObjtxt,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else 
                    // процент восстановления (не Песавенто и 0.866)
                    if (ExtHidden==1 || ExtHidden==4)
                      ObjectSetText(nameObjtxt,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                 }           
               else
                 {
                  ObjectDelete(nameObj); 
                  ObjectDelete(nameObjtxt);
                 }
              }  
            else
              {
//******* Прорисовка новой линии, если она появилась.
               if (kj>0.21 && kj<=5)
                 {
                  // Создание текстового объекта (числа Песавенто). % восстановления между минимумами
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                    // процент восстановления числа Песавенто и 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];
                     
                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else 
                    // процент восстановления (не Песавенто и 0.866)
                    { 
                     if (ExtHidden==1 || ExtHidden==4)
                       nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];
                     
                       ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                       ObjectSetText(nameObj,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                    }
                  if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                    {
                     nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];
                     
                     ObjectCreate(nameObj,OBJ_TREND,0,Time[numLowPrim],Low[numLowPrim],Time[numLowLast],Low[numLowLast]);
                     ObjectSet(nameObj,OBJPROP_RAY,false);
                     ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                     ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                    }
                 }           
//*******
               }
            }
        }
     }
     afrl[0]=Low[shift];
     if (ExtFiboDinamic)
       {
        screenFiboD();
       }
   }
//============= 1 сместился минимум. Конец.
//-----------3 Сместился максимум или минимум, но остался на том же баре. Конец.


   // Поиск исчезнувших фракталов и удаление линий, исходящих от этих фракталов. Начало.
   countBarEnd=iBarShift(Symbol(),Period(),TimeBarEnd); 
   for (k=0; k<5; k++)
     {

      // Проверка максимумов.
      if (afrh[k]>0)
        {
         // Поиск бара, на котором был этот фрактал
         shift=iBarShift(Symbol(),Period(),afr[k]); 
         if (zz[shift]==0)
           {
            flagFrNew=true;
            if (shift>numBar) numBar=shift;
            afrm=true;
            numHighPrim=shift; numHighLast=0;HighLast=0.0;
            for (k1=shift+1; k1<=countBarEnd; k1++)
              {
               if (zzH[k1]>0) 
                 {
                  HighLast=High[k1]; numHighLast=k1;

                  nameObj="ph" + Time[numHighPrim] + "_" + Time[numHighLast];

                  numOb=ObjectFind(nameObj);
                  if (numOb>-1)
                    {
                     ObjectDelete(nameObj); 

                     nameObjtxt="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

                     ObjectDelete(nameObjtxt);
                    }
                 }
              }

           }
        }
      
      // Проверка минимумов.
      if (afrl[k]>0)
        {
         // Поиск бара, на котором был этот фрактал
         shift=iBarShift(Symbol(),Period(),afr[k]); 
         if (zz[shift]==0)
           {
            flagFrNew=true;
            if (shift>numBar) numBar=shift;

            afrm=true;
            numLowPrim=shift; numLowLast=0;LowLast=10000000;
            for (k1=shift+1; k1<=countBarEnd; k1++)
              {
               if (zzL[k1]>0) 
                 {
                  LowLast=Low[k1]; numLowLast=k1;

                  nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];

                  numOb=ObjectFind(nameObj);
                  if (numOb>-1)
                    {
                     ObjectDelete(nameObj); 

                     nameObjtxt="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

                     ObjectDelete(nameObjtxt);
                    }
                 }
              }
           }
        }

     }
   // Поиск исчезнувших фракталов и удаление линий, исходящих от этих фракталов. Конец.

   // Перезапись матрицы. Начало.
   matriza ();
   // Перезапись матрицы. Конец.

  }
// Коррекция соединяющих линий и чисел. Конец.
//-----------------------------------------
// Блок проверок и удаления линий, 
// потерявших актуальность. Конец.
//-----------------------------------------   


      // Подсчет количества фракталов. Начало.
      countFractal();
      // Подсчет количества фракталов. Конец.

//-----------------------------------------
//
//     4.
//
// Блок вывода соединительных линий. Начало.
//-----------------------------------------   
if (Bars - counted_bars>2)
  {
//-----------1 Отрисовка максимумов. Начало.
//+--------------------------------------------------------------------------+
//| Вывод соединяющих линий и чисел Песавенто и 0.866 для максимумов ZigZag-a
//| Отрисовка идет от нулевого бара
//+--------------------------------------------------------------------------+

   numLowPrim=0; numLowLast=0;
   numHighPrim=0; numHighLast=0;

   LowPrim=0.0; LowLast=0.0;
   HighPrim=0.0; HighLast=0.0;
   
   Angle=-100;
   
   if (flagFrNew) countFr=1;
   else countFr=ExtFractal;

   for (k=0; (k<Bars-1 && countHigh1>0 && countFr>0); k++)
     {
      if (zzL[k]>0.0 && LowPrim==0.0 && HighPrim>0 && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzL[k]>0.0 && zzL[k]<LowPrim && HighPrim>0 && zzL[k]==zz[k]) {LowPrim=zzL[k]; numLowPrim=k;}
      if (zzH[k]>0.0 && zzH[k]==zz[k])
        {
         if (HighPrim>0) 
           {
            if (HighLast>0) 
              {
               HighLast=High[k]; numHighLast=k;
              }
            else {numHighLast=k; HighLast=High[k];}

            HL=High[numHighLast]-Low[numLowPrim];
            kj=(HighPrim-HighLast)*10000/(numHighLast-numHighPrim);
            if (HL>0 && (Angle>kj || Angle==-100))  // Проверка угла наклона линии
              {
               Angle=kj;
               // Создание линии и текстового объекта
               HLp=High[numHighPrim]-Low[numLowPrim];
               k1=MathCeil((numHighPrim+numHighLast)/2);
               kj=HLp/HL;

               if (kj>0.21 && kj<=5)
                 {
                  // Создание текстового объекта (числа Песавенто). % восстановления между максимумами
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                    // процент восстановления числа Песавенто и 0.866
                    {
                    if (ExtHidden!=4)                  
                      {
                       nameObj="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

                       ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                       if (kk==0.886) // Gartley
                         ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                       else
                         ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                      }
                     }
                  else
                    // процент восстановления (не Песавенто и 0.866)
                    {
                     if (ExtHidden==1 || ExtHidden==4)
                       {
                        nameObj="phtxt" + Time[numHighPrim] + "_" + Time[numHighLast];

                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((High[numHighPrim]+High[numHighLast])/2));
                        ObjectSetText(nameObj,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                       }
                    }

                  if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                    {
                     nameObj="ph" + Time[numHighPrim] + "_" + Time[numHighLast];

                     ObjectCreate(nameObj,OBJ_TREND,0,Time[numHighPrim],High[numHighPrim],Time[numHighLast],High[numHighLast]);
                     ObjectSet(nameObj,OBJPROP_RAY,false);
                     ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                     ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                    }
                 }
              }
           }
         else 
            {numHighPrim=k; HighPrim=High[k];}
        }
       // Переход на следующий фрактал
       if (k>countBarEnd) 
         {
          k=numHighPrim+1; countHigh1--; countFr--;
          numLowPrim=0; numLowLast=0;
          numHighPrim=0; numHighLast=0;

          LowPrim=0.0; LowLast=0.0;
          HighPrim=0.0; HighLast=0.0;
   
          Angle=-100;
         }
     }
//-----------1 Отрисовка максимумов. Конец.

//-----------2 Отрисовка минимумов. Начало.
//+-------------------------------------------------------------------------+
//| Вывод соединяющих линий и чисел Песавенто и 0.866 для минимумов ZigZag-a
//| Отрисовка идет от нулевого бара
//+-------------------------------------------------------------------------+

   numLowPrim=0; numLowLast=0;
   numHighPrim=0; numHighLast=0;

   LowPrim=0.0; LowLast=0.0;
   HighPrim=0.0; HighLast=0.0;
   
   Angle=-100;

   if (flagFrNew) countFr=1;
   else countFr=ExtFractal;

   for (k=0; (k<Bars-1 && countLow1>0 && countFr>0); k++)
     {
      if (zzH[k]>HighPrim && LowPrim>0) {HighPrim=High[k]; numHighPrim=k;}
      if (zzL[k]>0.0 && zzL[k]==zz[k]) 
        {
         if (LowPrim>0) 
           {
            if (LowLast>0) 
              {
               LowLast=Low[k]; numLowLast=k;
              }
            else {numLowLast=k; LowLast=Low[k];}

            // вывод соединяющих линий и процентов восстановления(чисел Песавенто)
            HL=High[numHighPrim]-Low[numLowLast];
            kj=(LowPrim-LowLast)*1000/(numLowLast-numLowPrim);
            if (HL>0 && (Angle<kj || Angle==-100))  // Проверка угла наклона линии
              {
               Angle=kj;

               HLp=High[numHighPrim]-Low[numLowPrim];
               k1=MathCeil((numLowPrim+numLowLast)/2);
               kj=HLp/HL;

               if (kj>0.21 && kj<=5)
                 {
                  // Создание текстового объекта (числа Песавенто). % восстановления между минимумами
                  kk=kj;
                  k2=1;

                  if (ExtDeltaType==2) for (ki=0;ki<=16;ki++) {if (MathAbs((fi[ki]-kj)/fi[ki])<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}
                  if (ExtDeltaType==1) for (ki=0;ki<=16;ki++) {if (MathAbs(fi[ki]-kj)<=ExtDelta) {kk=fi[ki]; k2=-1; break;}}

                  if (k2<0)
                  // процент восстановления числа Песавенто и 0.866
                    {
                     if (ExtHidden!=4)                  
                       {
                        nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                        if (kk==0.886) // Gartley
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial", ExtGartley866);
                        else
                          ObjectSetText(nameObj,fitxt[ki],ExtSizeTxt,"Arial",ExtPesavento);
                       }
                    }
                  else 
                    // процент восстановления (не Песавенто и 0.866)
                    { 
                     if (ExtHidden==1 || ExtHidden==4)
                       {
                        nameObj="pltxt" + Time[numLowPrim] + "_" + Time[numLowLast];

                        ObjectCreate(nameObj,OBJ_TEXT,0,Time[k1],MathAbs((Low[numLowPrim]+Low[numLowLast])/2));
                        ObjectSetText(nameObj,""+DoubleToStr(kk,2),ExtSizeTxt,"Arial",ExtNotFibo);
                       }
                     }
                     
                   if ((ExtHidden==2 && k2<0) || ExtHidden!=2)
                     {
                      nameObj="pl" + Time[numLowPrim] + "_" + Time[numLowLast];

                      ObjectCreate(nameObj,OBJ_TREND,0,Time[numLowPrim],Low[numLowPrim],Time[numLowLast],Low[numLowLast]);
                      ObjectSet(nameObj,OBJPROP_RAY,false);
                      ObjectSet(nameObj,OBJPROP_STYLE,STYLE_DOT);
                      ObjectSet(nameObj,OBJPROP_COLOR,ExtLine);
                     }
                  }
               }
           }
         else {numLowPrim=k; LowPrim=Low[k];}
        }
       // Переход на следующий фрактал
       if (k>countBarEnd) 
         {
          k=numLowPrim+1; countLow1--; countFr--;

          numLowPrim=0; numLowLast=0;
          numHighPrim=0; numHighLast=0;

          LowPrim=0.0; LowLast=0.0;
          HighPrim=0.0; HighLast=0.0;
  
          Angle=-100;
         }
     }

//-----------2 Отрисовка минимумов. Конец.

  }
//-----------------------------------------
// Блок вывода соединительных линий. Конец.
//-----------------------------------------   

//======================
//======================
//======================
  } // Разрешение на вывод оснастки. Конец.
// КОНЕЦ
  } // start



//----------------------------------------------------
//  Подпрограммы и функции
//----------------------------------------------------

//--------------------------------------------------------
// Подсчет количества фракталов. Минимумов и максимумов. Начало.
//--------------------------------------------------------
void countFractal()
  {
   int shift;
   countLow1=0;
   countHigh1=0;
   if (flagFrNew)
     {
      for(shift=0; shift<=numBar; shift++)
        {
         if (zzL[shift]>0.0) {countLow1++;}
         if (zzH[shift]>0.0) {countHigh1++;}    
        }
      flagFrNew=false;
      numBar=0;  
      counted_bars=Bars-4;
     }
   else
     {
      for(shift=0; shift<=countBarEnd; shift++)
        {
         if (zzL[shift]>0.0) {countLow1++;}
         if (zzH[shift]>0.0) {countHigh1++;}
        }
     }
   return ;
  }
//--------------------------------------------------------
// Подсчет количества фракталов. Минимумов и максимумов. Конец.
//--------------------------------------------------------

//--------------------------------------------------------
// Формирование матрицы. Начало.
//
// Матрица используется для поиска исчезнувших фракталов.
// Это инструмент компенсации непредвиденных закидонов стандартного ZigZag-a.
//--------------------------------------------------------
void matriza()
  {
   if (afrm)
     {
      int shift,k;
      k=0;
      for (shift=0; shift<Bars && k<10; shift++)
        {
         if (zz[shift]>0)
           {
            afr[k]=Time[shift];
            if (zz[shift]==zzL[shift]) {afrl[k]=Low[shift]; afrh[k]=0.0;}
            if (zz[shift]==zzH[shift]) {afrh[k]=High[shift]; afrl[k]=0.0;}
            k++;
           }
        }
      afrm=false;
      // Вывод статических и динамических фиб.
      if (ExtFiboStatic)
        {
         ExtFiboStatic=false;
         screenFiboS();
        }
      if (ExtFiboDinamic)
        {
         screenFiboD();
        }
     }
   return ;
  }
//--------------------------------------------------------
// Формирование матрицы. Конец.
//--------------------------------------------------------

//--------------------------------------------------------
// Вывод фиб статических. Начало.
//--------------------------------------------------------
void screenFiboS()
  {
   double fibo_0, fibo_100, fiboPrice, fiboPrice1;

   nameObj="fiboS";
   numOb=ObjectFind(nameObj);
   if (numOb>-1) ObjectDelete(nameObj);
   if (afrl[ExtFiboStaticNum-1]>0) 
     {
      fibo_0=afrh[ExtFiboStaticNum];fibo_100=afrl[ExtFiboStaticNum-1];
      fiboPrice=afrh[ExtFiboStaticNum]-afrl[ExtFiboStaticNum-1];fiboPrice1=afrl[ExtFiboStaticNum-1];
     }
   else 
     {
      fibo_0=afrl[ExtFiboStaticNum];fibo_100=afrh[ExtFiboStaticNum-1];
      fiboPrice=afrl[ExtFiboStaticNum]-afrh[ExtFiboStaticNum-1];fiboPrice1=afrh[ExtFiboStaticNum-1];
     }

   ObjectCreate(nameObj,OBJ_FIBO,0,afr[2],fibo_0,afr[1],fibo_100);
   ObjectSet(nameObj,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(nameObj,OBJPROP_FIBOLEVELS,18);
   ObjectSet(nameObj,OBJPROP_LEVELCOLOR,ExtFiboS);

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL,0);
   ObjectSetFiboDescription(nameObj, 0, "0  -->  "+DoubleToStr(fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSetFiboDescription(nameObj, 1, "38.2  -->  "+DoubleToStr(fiboPrice*0.382+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+2,0.5);
   ObjectSetFiboDescription(nameObj, 2, "50.0  -->  "+DoubleToStr(fiboPrice*0.5+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSetFiboDescription(nameObj, 3, "61.8  -->  "+DoubleToStr(fiboPrice*0.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+4,0.707);
   ObjectSetFiboDescription(nameObj, 4, "70.7  -->  "+DoubleToStr(fiboPrice*0.707+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+5,0.786);
   ObjectSetFiboDescription(nameObj, 5, "78.6  -->  "+DoubleToStr(fiboPrice*0.786+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+6,0.841);
   ObjectSetFiboDescription(nameObj, 6, "84.1  -->  "+DoubleToStr(fiboPrice*0.841+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+7,0.886);
   ObjectSetFiboDescription(nameObj, 7, "88.6  -->  "+DoubleToStr(fiboPrice*0.886+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+8,1.0);
   ObjectSetFiboDescription(nameObj, 8, "100.0  -->  "+DoubleToStr(fiboPrice+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+9,1.127);
   ObjectSetFiboDescription(nameObj, 9, "112.8  -->  "+DoubleToStr(fiboPrice*1.128+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+10,1.272);
   ObjectSetFiboDescription(nameObj, 10, "127.2  -->  "+DoubleToStr(fiboPrice*1.272+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+11,1.414);
   ObjectSetFiboDescription(nameObj, 11, "141.4  -->  "+DoubleToStr(fiboPrice*1.414+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+12,1.618);
   ObjectSetFiboDescription(nameObj, 12, "161.8  -->  "+DoubleToStr(fiboPrice*1.618+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+13,2.0);
   ObjectSetFiboDescription(nameObj, 13, "200.0  -->  "+DoubleToStr(fiboPrice*2.0+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+14,2.414);
   ObjectSetFiboDescription(nameObj, 14, "241.4  -->  "+DoubleToStr(fiboPrice*2.414+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+15,2.618);
   ObjectSetFiboDescription(nameObj, 15, "261.8  -->  "+DoubleToStr(fiboPrice*2.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+16,4.236);
   ObjectSetFiboDescription(nameObj, 16, "423.6  -->  "+DoubleToStr(fiboPrice*4.236+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+17,6.854);
   ObjectSetFiboDescription(nameObj, 17, "685.4  -->  "+DoubleToStr(fiboPrice*6.854+fiboPrice1, 4) ); 

   return ;
  }
//--------------------------------------------------------
// Вывод фиб статических. Конец.
//--------------------------------------------------------

//--------------------------------------------------------
// Вывод фиб динамических. Начало.
//--------------------------------------------------------
void screenFiboD()
  {
   double fibo_0, fibo_100, fiboPrice, fiboPrice1;

   nameObj="fiboD";
   numOb=ObjectFind(nameObj);
   if (numOb>-1) ObjectDelete(nameObj);
   if (afrh[1]>0) {fibo_0=afrh[1];fibo_100=afrl[0];fiboPrice=afrh[1]-afrl[0];fiboPrice1=afrl[0];}
   else {fibo_0=afrl[1];fibo_100=afrh[0];fiboPrice=afrl[1]-afrh[0];fiboPrice1=afrh[0];}

   ObjectCreate(nameObj,OBJ_FIBO,0,afr[2],fibo_0,afr[1],fibo_100);
   ObjectSet(nameObj,OBJPROP_LEVELSTYLE,STYLE_DOT);
   ObjectSet(nameObj,OBJPROP_FIBOLEVELS,18);
   ObjectSet(nameObj,OBJPROP_LEVELCOLOR,ExtFiboD);

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL,0);
   ObjectSetFiboDescription(nameObj, 0, "0  -->  "+DoubleToStr(fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+1,0.382);
   ObjectSetFiboDescription(nameObj, 1, "38.2  -->  "+DoubleToStr(fiboPrice*0.382+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+2,0.5);
   ObjectSetFiboDescription(nameObj, 2, "50.0  -->  "+DoubleToStr(fiboPrice*0.5+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+3,0.618);
   ObjectSetFiboDescription(nameObj, 3, "61.8  -->  "+DoubleToStr(fiboPrice*0.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+4,0.707);
   ObjectSetFiboDescription(nameObj, 4, "70.7  -->  "+DoubleToStr(fiboPrice*0.707+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+5,0.786);
   ObjectSetFiboDescription(nameObj, 5, "78.6  -->  "+DoubleToStr(fiboPrice*0.786+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+6,0.841);
   ObjectSetFiboDescription(nameObj, 6, "84.1  -->  "+DoubleToStr(fiboPrice*0.841+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+7,0.886);
   ObjectSetFiboDescription(nameObj, 7, "88.6  -->  "+DoubleToStr(fiboPrice*0.886+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+8,1.0);
   ObjectSetFiboDescription(nameObj, 8, "100.0  -->  "+DoubleToStr(fiboPrice+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+9,1.127);
   ObjectSetFiboDescription(nameObj, 9, "112.8  -->  "+DoubleToStr(fiboPrice*1.128+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+10,1.272);
   ObjectSetFiboDescription(nameObj, 10, "127.2  -->  "+DoubleToStr(fiboPrice*1.272+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+11,1.414);
   ObjectSetFiboDescription(nameObj, 11, "141.4  -->  "+DoubleToStr(fiboPrice*1.414+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+12,1.618);
   ObjectSetFiboDescription(nameObj, 12, "161.8  -->  "+DoubleToStr(fiboPrice*1.618+fiboPrice1, 4) ); 
         
   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+13,2.0);
   ObjectSetFiboDescription(nameObj, 13, "200.0  -->  "+DoubleToStr(fiboPrice*2.0+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+14,2.414);
   ObjectSetFiboDescription(nameObj, 14, "241.4  -->  "+DoubleToStr(fiboPrice*2.414+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+15,2.618);
   ObjectSetFiboDescription(nameObj, 15, "261.8  -->  "+DoubleToStr(fiboPrice*2.618+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+16,4.236);
   ObjectSetFiboDescription(nameObj, 16, "423.6  -->  "+DoubleToStr(fiboPrice*4.236+fiboPrice1, 4) ); 

   ObjectSet(nameObj,OBJPROP_FIRSTLEVEL+17,6.854);
   ObjectSetFiboDescription(nameObj, 17, "685.4  -->  "+DoubleToStr(fiboPrice*6.854+fiboPrice1, 4) ); 

   return ;
  }
//--------------------------------------------------------
// Вывод фиб динамических. Конец.
//--------------------------------------------------------


//Print (); 
//--------------------------------------------------------
// Удаление объектов. Начало.
// Удаление соединительных линий и чисел.
//--------------------------------------------------------
void delete_objects1()
{
int i;
string txt;

for (i=ObjectsTotal(); i>=0; i--)
  {
   txt=ObjectName(i);
   if (StringFind(txt,"pl")>-1)ObjectDelete (txt);
   if (StringFind(txt,"ph")>-1) ObjectDelete (txt);
  }
return;
}
//--------------------------------------------------------
// Удаление объектов. Начало.
// Удаление соединительных линий и чисел.
//--------------------------------------------------------
//----------------------------------------------------
//  ZigZag (из МТ4 немного измененный). Начало.
//----------------------------------------------------
void ZigZag_()
  {
//  ZigZag из МТ. Начало.
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   for(shift=Bars-minBars; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,minBars,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=zzL[shift+back];
               if((res!=0)&&(res>val)) zzL[shift+back]=0.0; 
              }
           }
        } 
      zzL[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,minBars,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=zzH[shift+back];
               if((res!=0)&&(res<val)) zzH[shift+back]=0.0; 
              } 
           }
        }
      zzH[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-minBars; shift>=0; shift--)
     {
      curlow=zzL[shift];
      curhigh=zzH[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) zzH[lasthighpos]=0;
            else zzH[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) zzL[lastlowpos]=0;
            else zzL[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      zz[shift]=zzL[shift];
      if(shift>=Bars-minBars) {zzH[shift]=0.0;zzL[shift]=0.0; zz[shift]=0.0;}
      else
        {
         res=zzH[shift];
         if(res!=0.0) zz[shift]=res;
        }
     }

   return;
  }
//--------------------------------------------------------
// ZigZag из МТ. Конец. 
//--------------------------------------------------------


//----------------------------------------------------
//  ZigZag Алекса немного измененный. Начало.
//----------------------------------------------------
void ang_AZZ_()
 {
   int i,n,cbi;
//   double res;
   cbi=Bars-IndicatorCounted()-1;
//---------------------------------
   for (i=cbi; i>=0; i--) 
     {
//-------------------------------------------------
      // запоминаем значение направления тренда fs и средней цены si на предыдущем баре
      if (ti!=Time[i]) {fsp=fs; sip=si;} ti=Time[i];
      // Вычисляем значение ценового фильтра от процента отклонения
      if (minSize==0 && minPercent!=0) di=minPercent*Close[i]/2/100;
//-------------------------------------------------
      // Корректировка средней цены
      if (High[i]>=si+di && Low[i]<si-di) // Внешний бар по отношению к ценовому фильтру di
        {
         if (High[i]-si>=si-Low[i]) si=High[i]-di;  // Отклонение хая от средней цены больше отклонения лова
         if (High[i]-si<si-Low[i]) si=Low[i]+di;  // соответственно, меньше
        } 
      else  // Не внешний бар
        {
         if (High[i]>=si+di) si=High[i]-di;   // 
         if (Low[i]<=si-di) si=Low[i]+di;   // 
        }

      // Вычисление начального значения средней цены
      if (i>Bars-2) {si=(High[i]+Low[i])/2;}
      // Заполняем буферы для уровней подтверждения
      if (chHL) {ha[i]=si+di; la[i]=si-di;} 

      // Определяем направление тренда для расчетного бара
      if (si>sip) fs=1; // Тренд восходящий
      if (si<sip) fs=2; // Тренд нисходящий

//-------------------------------------------------

      if (fs==1 && fsp==2) // Тредн сменился с нисходящего на восходящий
        {
         hm=High[i];
         Last_Bar=iBarShift(Symbol(),Period(),tbiLast);
         zz[Last_Bar]=Low[Last_Bar];
         zzL[Last_Bar]=Low[Last_Bar];
         zzH[Last_Bar]=0;
         if (PeakDet) for (n=bip; n>=bi; n--) {lam[n]=Low[bip];}
         aip=ai; ai=i; taiLast=Time[i];
         t0=Time[i];
         LastBar0=0;
         fsp=fs;
        }

      if (fs==2 && fsp==1) // Тредн сменился с восходящего на нисходящий
        {
         lm=Low[i]; 
         Last_Bar=iBarShift(Symbol(),Period(),taiLast); 
         zz[Last_Bar]=High[Last_Bar];
         zzH[Last_Bar]=High[Last_Bar];
         zzL[Last_Bar]=0;
         if (PeakDet) for (n=aip; n>=ai; n--) {ham[n]=High[aip];}
         bip=bi; bi=i; tbiLast=Time[i];
         t0=Time[i];
         LastBar0=0;
         fsp=fs;
        }

      // Продолжение tренда. Отслеживание тренда.
      if (fs==1 && High[i]>hm) 
        {hm=High[i]; ai=i; taiLast=Time[i];}
      if (fs==2 && Low[i]<lm) 
        {lm=Low[i]; bi=i; tbiLast=Time[i];}

//===================================================================================================
      // Нулевой бар.
      if (i==0) 
        {
         tai=Time[ai];
         tbi=Time[bi];
         taip=Time[aip];
         tbip=Time[bip];

         ai0=iBarShift(Symbol(),Period(),tai); 
         bi0=iBarShift(Symbol(),Period(),tbi);
         aip0=iBarShift(Symbol(),Period(),taip); 
         bip0=iBarShift(Symbol(),Period(),tbip);

         if (fs==1) 
           {

            if (LastBar0==0) // Определение максимума для "нулевого" луча. Начало.
              {
               last0=iBarShift(Symbol(),Period(),tbiLast);
               LastBar0=High[last0];
               t0=Time[last0];
               for (n=bi;n>=0;n--)
                 {
                  if (LastBar0<High[n])
                    {
                     LastBar0=High[n];
                     t0=Time[n];
                     last0=n;
                    }
                 }
               zz[last0]=LastBar0;
               zzH[last0]=LastBar0;
               zzL[last0]=0;
              }             // Определение максимума для "нулевого" луча. Конец.

            if (LastBar0<High[i])
              {
               if (t0<Time[i])
                 {
                  last0=iBarShift(Symbol(),Period(),t0);
                  zz[last0]=0;
                  zzH[last0]=0;
                 }
               LastBar0=High[i];
               t0=Time[i];
               zz[i]=High[i];
               zzH[i]=High[i];
               zzL[i]=0;
              }
           }

         if (fs==2) 
           {

            if (LastBar0==0) // Определение минимума для "нулевого" луча. Начало.
              {
               last0=iBarShift(Symbol(),Period(),taiLast);
               LastBar0=Low[last0];
               t0=Time[last0];
               for (n=ai;n>=0;n--)
                 {
                  if (LastBar0>Low[n])
                    {
                     LastBar0=Low[n];
                     t0=Time[n];
                     last0=n;
                    }
                 }
               zz[last0]=LastBar0;
               zzH[last0]=0;
               zzL[last0]=LastBar0;
              }             // Определение минимума для "нулевого" луча. Конец.

            if (LastBar0>Low[i])
              {
               if (t0<Time[i])
                 {
                  last0=iBarShift(Symbol(),Period(),t0); 
                  zz[last0]=0;
                  zzL[last0]=0;
                 }
               LastBar0=Low[i];
               t0=Time[i];
               zz[i]=Low[i];
               zzL[i]=Low[i];
               zzH[i]=0;
              }
           }

         if (PeakDet)
           {
            if (fs==1) {for (n=aip0; n>=0; n--) {ham[n]=High[aip0];} for (n=bi0; n>=0; n--) {lam[n]=Low[bi0];} }
            if (fs==2) {for (n=bip0; n>=0; n--) {lam[n]=Low[bip0];} for (n=ai0; n>=0; n--) {ham[n]=High[ai0];} } 
           }
//-------------------------------------------------------------
        }
//====================================================================================================
     }
//--------------------------------------------

  return(0);
 }

//--------------------------------------------------------
// ZigZag Алекса. Конец. 
//--------------------------------------------------------



//----------------------------------------------------
// Индикатор подобный встроенному в Ensign. Начало.
//----------------------------------------------------
void Ensign_ZZ()
 {
   int i,n,cbi;

   cbi=Bars-IndicatorCounted()-1;
//---------------------------------
   for (i=cbi; i>=0; i--) 
     {
//-------------------------------------------------
      // Устанавливаем начальные значения минимума и максимума бара
      if (lLast==0) {lLast=Low[i];hLast=High[i];}
      // Определяем направление тренда до первой точки смены тренда.
      // Или до точки начала первого луча за левым краем.
      if (fs==0)
        {
         if (lLast<Low[i] && hLast<High[i]) {fs=1; si=High[i]; ai=i;}  // тренд восходящий
         if (lLast>Low[i] && hLast>High[i]) {fs=2; si=Low[i]; bi=i;}  // тренд нисходящий
        }
      
      if (ti!=Time[i])
        {
         // запоминаем значение направления тренда fs на предыдущем баре
         fsp=fs;
         ti=Time[i];
         // Остановка. Определение дальнейшего направления тренда.
         if (fs==1 && hLast>High[i]) fh=true;
         if (fh && countBar>0) countBar--;
         if (fs==2 && lLast<Low[i]) fl=true;
         if (fl && countBar>0) countBar--;
        } 

      // Продолжение тренда
      if (fs==1 && High[i]>si) {ai=i; tai=Time[i]; hLast=High[i]; si=High[i]; countBar=minBars; fh=false;}
      if (fs==2 && Low[i]<si) {bi=i; tbi=Time[i]; lLast=Low[i]; si=Low[i]; countBar=minBars; fl=false;}

      if ((countBar==0 || Close[i]<lLast) && fh)
        {
         fh=false;
         if (si-di>Low[i] && High[i]<hLast) {fs=2; countBar=minBars; fh=false;}
        }

      if ((countBar==0 || Close[i]>hLast) && fl)
        {
         fl=false;
         if (si+di<High[i] && Low[i]>lLast) {fs=1; countBar=minBars; fl=false;}
        }
      
//-------------------------------------------------
      if (fs==1 && fsp==2) // Тредн сменился с нисходящего на восходящий
        {
         zz[bi]=Low[bi];
         zzL[bi]=Low[bi];
         if (PeakDet) for (n=bip; n>=bi; n--) {lam[n]=Low[bip];}
         hLast=High[i];
         si=High[i];
         aip=ai; 
         ai=i;
         tai=Time[i];
         taip=Time[i];
         fsp=fs;
        }

      if (fs==2 && fsp==1) // Тредн сменился с восходящего на нисходящий
        {
         zz[ai]=High[ai];
         zzH[ai]=High[ai];
         if (PeakDet) for (n=aip; n>=ai; n--) {ham[n]=High[aip];}
         lLast=Low[i];
         si=Low[i];
         bip=bi; 
         bi=i;
         tbi=Time[i];
         tbip=Time[i];
         fsp=fs;
        }

//===================================================================================================
      // Нулевой бар. Расчет первого луча ZigZag-a

      if (i==0) 
        {
         ai0=iBarShift(Symbol(),Period(),tai); 
         bi0=iBarShift(Symbol(),Period(),tbi);
         aip0=iBarShift(Symbol(),Period(),taip); 
         bip0=iBarShift(Symbol(),Period(),tbip);

         if (fs==1) { for (n=bi0-1; n>ai0; n--) {zzH[n]=0; zz[n]=0;} zz[ai0]=High[ai0]; zzH[ai0]=High[ai0]; zzL[ai0]=0;}         
         if (fs==2) {for (n=ai0-1; n>bi0; n--) {zzL[n]=0; zz[n]=0;} zz[bi0]=Low[bi0]; zzL[bi0]=Low[bi0]; zzH[bi0]=0;}

         if (PeakDet)
           {
            if (fs==1) {for (n=aip0; n>=0; n--) {ham[n]=High[aip0];} for (n=bi0; n>=0; n--) {lam[n]=Low[bi0];} }
            if (fs==2) {for (n=bip0; n>=0; n--) {lam[n]=Low[bip0];} for (n=ai0; n>=0; n--) {ham[n]=High[ai0];} } 
           }
//-------------------------------------------------------------
        }

//====================================================================================================
     }
//--------------------------------------------
  return(0);
 }
//--------------------------------------------------------
// Индикатор подобный встроенному в Ensign. Конец. 
//--------------------------------------------------------

