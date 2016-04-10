//+------------------------------------------------------------------+
//|                                                  rvmGann_sv2.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                      rvm_fam на fromru точка ком |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "rvm_fam на fromru точка ком"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 DodgerBlue
//---- input parameters
extern int       GSv_tend=2;
//---- buffers
double GSv_sl[];
double GSv_Up[];
bool initfl,draw_up,draw_dn;
bool curH,curL;
int sH,sL,lb,lhi,lli,fpoint,spoint;
int idFile;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_SECTION,STYLE_DOT);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID);
   SetIndexBuffer(0,GSv_sl);
   SetIndexBuffer(1,GSv_Up);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(0,"Dawn trend");
   SetIndexLabel(1,"Up trend");

   //FileDelete("GSv.txt");
   //idFile=FileOpen("GSv.txt",FILE_WRITE);
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int cb,ai,i,limit,index;
//---- 
   if( initfl!=1 )
   {
      myInit();
      if( initfl!=1 )
      {
         Alert("Сбой инициализации индикатора!");
         return(-1);
      }
   }
   index=Bars-1;
   if( counted_bars>=0 )
   {
      if( index-counted_bars<=0 )
      {
         limit=0;
      }
      else
      {
         limit=index-counted_bars;
         if( limit>index-GSv_tend )
         {
            limit=index-GSv_tend;
         }
      }
   }
   else
   {
      Alert("Сбой расчета индикатора!");
      return(-1);
   }
//FileWrite(idFile,"  Bars="+Bars+" index="+index+" limit="+limit+" counted_bars="+counted_bars);
//-------------------->> начало цикла по барам -------------------------------
for( cb=limit;cb>=0;cb-- )
{
   ai=index-cb;
//-------------------->> действия призводимые если появился новый бар --------
if( lb!=ai )
{
   //FileWrite(idFile,"**Новый бар, ai="+ai+" "+TimeToStr(Time[cb]));
   lb=ai;
   //если предыдущий бар внутрениий - обнуляем счетчики
   if( High[cb+1]<=High[cb+2] && Low[cb+1]>=Low[cb+2] )
   {
      sH=0;
      sL=0;
      //FileWrite(idFile,"  Предыдущий бар внутренний, счетчики обнулены "+sH+"  "+sL);
   }
   else
   {
      //если предыдущий только максимум
      if( High[cb+1]>High[cb+2] && Low[cb+1]>=Low[cb+2] )
      {
         sL=0;
         //FileWrite(idFile,"  Предыдущий-только максимум, счетчик минимумов обнулен "+sL);
      }
      else
      {
         //если предыдущий только минимум
         if( High[cb+1]<=High[cb+2] && Low[cb+1]<Low[cb+2] )
         {
            sH=0;
            //FileWrite(idFile,"  Предыдущий-только минимум, счетчик максимумов обнулен "+sH);
         }
      }
   }
   //если индикатор рисовался вверх
   if( draw_up==1 )
   {
      //FileWrite(idFile,"  индикатор рисовался вверх");
      //если счетчик минимумов достиг нужного значения
      if( sL==GSv_tend )
      {
         //FileWrite(idFile,"  счетчик минимумов достиг нужного значения");
         // и последний минимум или счетчик максимумов не имеет нужного значения
         if( curL==1 || sH!=GSv_tend )
         {
            draw_up=0;
            draw_dn=1;
            fpoint=spoint;
            spoint=ai-1;
            //FileWrite(idFile,"  последним был минимум, draw_up="+draw_up+" draw_dn="+draw_dn+" fpoint="+fpoint+" spoint="+spoint+" или счетчик максимумов не имеет нужного значения");
         }
      }
      else
      {
         //иначе если счетчик минимумов не достиг нужного значения
         //если на предыдущей свечке был максимум и он выше предыдущего отрисованного
         if( High[cb+1]>High[cb+2] && High[cb+1]>High[index-spoint] )
         {
            spoint=ai-1;
            //FileWrite(idFile,"  максимум на пред.свечке выше предыдущего отрисованного, меняем spoint="+spoint);
         }
      }
   }
   else
   {
      //иначе если индикатор рисовался вниз
      if( draw_dn==1 )
      {
         //FileWrite(idFile,"  индикатор рисовался вниз");
         //если счетчик максимумов достиг нужного значения
         if( sH==GSv_tend )
         {
            //FileWrite(idFile,"  счетчик максимумов достиг нужного значения");
            //и последний - максимум или счетчик минимумов не имеет нужного значения
            if( curH==1 || sL!=GSv_tend )
            {
               draw_up=1;
               draw_dn=0;
               fpoint=spoint;
               spoint=ai-1;
               //FileWrite(idFile,"  последним был максимум, draw_up="+draw_up+" draw_dn="+draw_dn+" fpoint="+fpoint+" spoint="+spoint+" или счетчик минимумов не имеет нужного значения");
            }
         }
         else
         {
            //иначе если счетчик максимумов не достиг нужного значения
            //если на предыдущей свечке был минимум и он ниже предыдущего отрисованного
            if( Low[cb+1]<Low[cb+2] && Low[cb+1]<Low[index-spoint] )
            {
               spoint=ai-1;
               //FileWrite(idFile,"  минимум на пред.свечке ниже предыдущего отрисованного, меняем spoint="+spoint);
            }
         }
      }
   }
   //FileWrite(idFile,"  новая свеча, обнуляем наличие максимума, минимума");
   curH=0;
   curL=0;
}
//--------------------<< конец действий призводимые если появился новый бар --
//если текущий бар "внутренний" переходим к следующему циклу
if( High[cb]<=High[cb+1] && Low[cb]>=Low[cb+1] )
{
   //FileWrite(idFile,"  бар внутренний, переходим к следующей свече");
   continue;
}
//-------------------->> выяснение текущего состояния бара -------------------
//если это история
if( cb!=0 || counted_bars==0 )
{
   //FileWrite(idFile,"  по истории...");
   if( High[cb]>High[cb+1] )
   {
      if( sH<GSv_tend ) sH++;
      curH=1;
      //FileWrite(idFile,"  счетчик максимумов увеличен, последний максимум "+sH);
   }
   if( Low[cb]<Low[cb+1] )
   {
      if( sH<GSv_tend ) sL++;
      curL=1;
      //FileWrite(idFile,"  счетчик минимумов увеличен, последний минимум "+sL);
   }
   if( curH==curL && curH==1 )
   {
      if( Close[cb]>=(High[cb]+Low[cb])/2 )
      {
         curL=0;
         //FileWrite(idFile,"  внешний бар, уточнение, последний максимум");
      }
      else
      {
         curH=0;
         //FileWrite(idFile,"  внешний бар, уточнение, последний минимум");
      }
   }
}
else
{
   //FileWrite(idFile,"  реал-тайм...");
   if( Close[cb]==High[cb] )
   {
      if( sH<GSv_tend && lhi!=ai )
      {
         lhi=ai;
         sH++;
      }
      curH=1;
      curL=0;
      //FileWrite(idFile,"  последний максимум");
   }
   else
   {
      if( Close[cb]==Low[cb] )
      {
         if( sL<GSv_tend && lli!=ai )
         {
            lli=ai;
            sL++;
         }
         curH=0;
         curL=1;
         //FileWrite(idFile,"  последний минимум");
      }
   }
}
//--------------------<< конец выяснения текущего состояния бара -------------
//FileWrite(idFile,"  отрисовка индикатора...");
//если индикатор уже рисуется
if( draw_up!=draw_dn )
{
   //FileWrite(idFile,"  индикатор уже рисуется "+draw_up+"  "+draw_dn);
   //если индикатор отрисовывается вверх
   if( draw_dn!=1 )
   {
      //если счетчик минимумов достиг нужного значения и последний минимум или счетчик максимумов не имеет нужного значения
      if( (sL==GSv_tend && curL==1) || (sL==GSv_tend && sH!=GSv_tend) )
      {
         //FileWrite(idFile,"  счетчик минимумов достиг нужного значения и последний минимум или счетчик максимумов не имеет нужного значения");
         GSv_sl[cb]=Low[cb];
      }
      else
      {
         //если последний максимум выше последнего отрисованного
         if( High[cb]>High[index-spoint] )
         {
            GSv_sl[cb]=High[cb];
            for( i=cb+1;i<index-fpoint;i++ )
            {
               GSv_sl[i]=0;
            }
         }
      }
   }
   else
   {
      //иначе если отрисовывается вниз
      //если счетчик максимумов достиг нужного значения и максимум последний или счетчик минимумов не имеет нужного значения
      if( (sH==GSv_tend && curH==1) || (sH==GSv_tend && sL!=GSv_tend) )
      {
         //FileWrite(idFile,"  счетчик максимумов достиг нужного значения и последний максимум или счетчик минимумов не имеет нужного значения");
         GSv_sl[cb]=High[cb];
      }
      else
      {
         //если последний минимум ниже последнего отрисованного
         if( Low[cb]<Low[index-spoint] )
         {
            GSv_sl[cb]=Low[cb];
            for( i=cb+1;i<index-fpoint;i++ )
            {
               GSv_sl[i]=0;
            }
         }
      }
   }
}
else
{
   //FileWrite(idFile,"  индикатор пока не отрисовывался "+draw_up+"  "+draw_dn);
   //иначе если индикатор еще не рисуется
   //если счетчик максимумов достиг нужного значения
   if( sH==GSv_tend )
   {
      //FileWrite(idFile,"  счетчик максимумов достиг нужного значения");
      if( sL!=GSv_tend || curH==1 )
      {
         //FileWrite(idFile,"  последний максимум или счетчик минимумов меньше нужного");
         GSv_sl[index-fpoint]=Low[index-fpoint];
         GSv_sl[cb]=High[cb];
         draw_up=1;
         draw_dn=0;
         //FileWrite(idFile,"  начальная точка "+fpoint+" "+GSv_sl[index-fpoint]+" конечная точка "+ai+" "+GSv_sl[cb]);
      }
   }
   //если счетчик минимумов достиг нужного значения
   if( sL==GSv_tend )
   {
      //FileWrite(idFile,"  счетчик минимумов достиг нужного значения");
      if( sH!=GSv_tend || curL==1 )
      {
         //FileWrite(idFile,"  последний минимум или счетчик максимумов меньше нужного");
         GSv_sl[index-fpoint]=High[index-fpoint];
         GSv_sl[cb]=Low[cb];
         draw_up=0;
         draw_dn=1;
         //FileWrite(idFile,"  начальная точка "+fpoint+" "+GSv_sl[index-fpoint]+" конечная точка "+ai+" "+GSv_sl[cb]);
      }
   }
}
//--------------------<< конец цикла по барам --------------------------------
}
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   //FileClose(idFile);
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Функция начальной инициализации индикатора                       |
//+------------------------------------------------------------------+
int myInit()
  {
//---- 
   //если недостаточно данных
   if( Bars<GSv_tend+1 )
   {
      Alert("Недостаточно данных на графике!");
      return(-1);
   }
   if( GSv_tend<1 )
   {
      Alert("Неверный параметр индикатора!");
      return(-1);
   }
   if( High[Bars-2]>High[Bars-1] ) sH++;
   if( Low[Bars-2]<Low[Bars-1] ) sL++;
   initfl=1;
   //FileWrite(idFile,TimeToStr(CurTime())+" индикатор инициализирован");
   //FileWrite(idFile,"  баров на графике = "+Bars+", время первого бара = "+TimeToStr(Time[Bars-1]));
   //FileWrite(idFile,"  счетчик максимумов = "+sH+", счетчик минимумов = "+sL);
//----
   return(0);
  }
//+------------------------------------------------------------------+


