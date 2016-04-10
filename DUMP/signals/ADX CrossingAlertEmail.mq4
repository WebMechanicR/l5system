//+------------------------------------------------------------------+
//| ADX Crossing.mq4 
//| Amir
//| Modified to give alert and send email by MrPip
//+------------------------------------------------------------------+
#property  copyright "Author - Amir"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

//---- input parameters
extern int ADXbars=14;
extern int CountBars=350;
extern bool SoundON=true;
extern bool EmailON=false;

//---- buffers
double val1[];
double val2[];
int flagval1 = 0;
int flagval2 = 0;
double b4plusdi,nowplusdi,b4minusdi,nowminusdi;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,108);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,108);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);
   GlobalVariableSet("AlertTime"+Symbol()+Period(),CurTime());
   GlobalVariableSet("SignalType"+Symbol()+Period(),OP_SELLSTOP);
//   GlobalVariableSet("LastAlert"+Symbol()+Period(),0);
//----
   return(0);
  }

int deinit()
{
   GlobalVariableDel("AlertTime"+Symbol()+Period());
   GlobalVariableDel("SignalType"+Symbol()+Period());
//   GlobalVariableDel("LastAlert"+Symbol()+Period());
   return(0);
}

//+------------------------------------------------------------------+
//| ADX Crossing                                                     |
//+------------------------------------------------------------------+
int start()
  {
   double tmp=0;
      
   if (CountBars>=Bars) CountBars=Bars;
   if (CountBars>=1000) CountBars=950;
   SetIndexDrawBegin(0,Bars-CountBars + 12);
   SetIndexDrawBegin(1,Bars-CountBars + 12);
   int i,shift,counted_bars=IndicatorCounted();


   //---- check for possible errors
   if(counted_bars<0) return(-1);

   //---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=CountBars;i++) val1[CountBars-i]=0.0;
      for(i=1;i<=CountBars;i++) val2[CountBars-i]=0.0;
     } 

   for (shift = CountBars; shift>=0; shift--) 
   { 

   	b4plusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_PLUSDI,shift-1);
	   nowplusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_PLUSDI,shift);
	   b4minusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_MINUSDI,shift-1);
	   nowminusdi=iADX(NULL,0,ADXbars,PRICE_CLOSE,MODE_MINUSDI,shift); 
      if (b4plusdi>b4minusdi && nowplusdi<nowminusdi)
      {
	      if (shift == 1 && flagval1==0){  flagval1=1; flagval2=0; }
	      val1[shift]=Low[shift]-5*Point;
      }
      if (b4plusdi<b4minusdi && nowplusdi>nowminusdi) 
      {
         if (shift == 1 && flagval2==0) { flagval2=1; flagval1=0; }
	      val2[shift]=High[shift]+5*Point;
      }
   }
   if (flagval1==1 && CurTime() > GlobalVariableGet("AlertTime"+Symbol()+Period()) && GlobalVariableGet("SignalType"+Symbol()+Period())!=OP_BUY)
   {
//      Print("Last Alert before BUY = ",GlobalVariableGet("LastAlert"+Symbol()+Period()));
//      if (GlobalVariableGet("LastAlert"+Symbol()+Period()) < 0.5)
//      {
        if (SoundON) Alert("BUY signal at Ask=",Ask,", Bid=",Bid,", Time=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime())," Symbol=",Symbol()," Period=",Period());
        if (EmailON) SendMail("BUY signal alert","BUY signal at Ask="+DoubleToStr(Ask,4)+", Bid="+DoubleToStr(Bid,4)+", Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
//      }
      tmp = CurTime() + (Period()-MathMod(Minute(),Period()))*60;
      GlobalVariableSet("AlertTime"+Symbol()+Period(),tmp);
      GlobalVariableSet("SignalType"+Symbol()+Period(),OP_SELL);
//      GlobalVariableSet("LastAlert"+Symbol()+Period(),1);
   }
   
   if (flagval2==1 && CurTime() > GlobalVariableGet("AlertTime"+Symbol()+Period()) && GlobalVariableGet("SignalType"+Symbol()+Period())!=OP_SELL)
    {
//      Print("Last Alert before SELL = ",GlobalVariableGet("LastAlert"+Symbol()+Period()));
//      if (GlobalVariableGet("LastAlert"+Symbol()+Period()) > -0.5)
//      {
        if (SoundON) Alert("SELL signal at Ask=",Ask,", Bid=",Bid,", Date=",TimeToStr(CurTime(),TIME_DATE)," ",TimeHour(CurTime()),":",TimeMinute(CurTime())," Symbol=",Symbol()," Period=",Period());
        if (EmailON) SendMail("SELL signal alert","SELL signal at Ask="+DoubleToStr(Ask,4)+", Bid="+DoubleToStr(Bid,4)+", Date="+TimeToStr(CurTime(),TIME_DATE)+" "+TimeHour(CurTime())+":"+TimeMinute(CurTime())+" Symbol="+Symbol()+" Period="+Period());
//      }
      tmp = CurTime() + (Period()-MathMod(Minute(),Period()))*60;
      GlobalVariableSet("AlertTime"+Symbol()+Period(),tmp);
      GlobalVariableSet("SignalType"+Symbol()+Period(),OP_BUY);
//      GlobalVariableSet("LastAlert"+Symbol()+Period(),-1);
   }
   return(0);
  }
//+------------------------------------------------------------------+