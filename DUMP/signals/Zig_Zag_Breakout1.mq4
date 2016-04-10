

//+------------------------------------------------------------------

//|                                           ZigZagRealBreakOut.mq4 

//|                                                                  
//|                                                                  

//|                                        Converted by Dr. Gaines
//|                                           |
//|                                     |
//+------------------------------------------------------------------


#property copyright " Istoniz "
#property link      " http://www.kg/ "

#property indicator_chart_window
#property indicator_color1 Blue
#property indicator_buffers 2
#property indicator_color2 White
#include <stdlib.mqh>
//+------------------------------------------------------------------

//| Common External variables                                        

//+------------------------------------------------------------------


//+------------------------------------------------------------------

//| External variables                                               
//+------------------------------------------------------------------

extern int barn = 250;
extern double LengthInput = 6;
extern double delaymin = 60;
extern double nSymbolHi = 242;
extern double nSymbolLow = 241;

//+------------------------------------------------------------------

//| Special Convertion Functions                                     

//+------------------------------------------------------------------


int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
}

void SetIndexValue2(int shift, double value)
{
  ExtHistoBuffer2[shift] = value;
}

bool SetObjectText(string name, string text, string font, int size, 
color Acolor)
{
  return(ObjectSetText(name, text, size, font, Acolor));
}

bool MoveObject(string name, int type, datetime Atime, double Aprice, datetime Atime2 = 0, double Aprice2 = 0, color Acolor = CLR_NONE, int Aweight = 0, int Astyle = 0)
{
    if (ObjectFind(name) != -1)
    {
      int OType = ObjectType(name);

      if ((OType == OBJ_VLINE) ||
         (OType == OBJ_HLINE) ||
         (OType == OBJ_TRENDBYANGLE) ||
         (OType == OBJ_TEXT) ||
         (OType == OBJ_ARROW) ||
         (OType == OBJ_LABEL))
      {
        return(ObjectMove(name, 0, Atime, Aprice));
      }

      if ((OType == OBJ_GANNLINE) ||
         (OType == OBJ_GANNFAN) ||
         (OType == OBJ_GANNGRID) ||
         (OType == OBJ_FIBO) ||
         (OType == OBJ_FIBOTIMES) ||
         (OType == OBJ_FIBOFAN) ||
         (OType == OBJ_FIBOARC) ||
         (OType == OBJ_RECTANGLE) ||
         (OType == OBJ_ELLIPSE) ||
         (OType == OBJ_CYCLES) ||
         (OType == OBJ_TREND) ||
         (OType == OBJ_STDDEVCHANNEL) ||
         (OType == OBJ_REGRESSION))
      {
        return(ObjectMove(name, 0, Atime, Aprice) && ObjectMove(name, 1, Atime2, Aprice2));
      }

/*
          OBJ_CHANNEL,
          OBJ_EXPANSION,
          OBJ_FIBOCHANNEL,
          OBJ_TRIANGLE,
          OBJ_PITCHFORK
*/
    }
    else
    {
      return(ObjectCreate(name, type, 0, Atime, Aprice, Atime2,Aprice2, 0, 0) && ObjectSet(name, OBJPROP_COLOR, Acolor));
    }
}

void SetArrow(datetime ArrowTime, double Price, double ArrowCode, color ArrowColor)
{
int err;
string ArrowName = DoubleToStr(ArrowTime,0);
   if (ObjectFind(ArrowName) != -1) ObjectDelete(ArrowName);
   if(!ObjectCreate(ArrowName, OBJ_ARROW, 0, ArrowTime, Price))
    {
      err=GetLastError();
      Print("error: can't create Arrow! code #",err," ",ErrorDescription(err));
      return;
    }
   else
   {
     ObjectSet(ArrowName, OBJPROP_ARROWCODE, ArrowCode);
     ObjectSet(ArrowName, OBJPROP_COLOR , ArrowColor);
     ObjectsRedraw();
   }
}

//+------------------------------------------------------------------

//| End                                                              

//+------------------------------------------------------------------


//+------------------------------------------------------------------

//| Initialization                                                   

//+------------------------------------------------------------------


int init()
{
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, ExtHistoBuffer2);
   return(0);
}
int start()
{
//+------------------------------------------------------------------

//| Local variables                                                  

//+------------------------------------------------------------------

int shift = 0;
double LL = 0;
double HH = 0;
double Swing = 0;
double Swing_n = 0;
double BH = 0;
double BL = 0;
int i = 0;
double zu = 0;
double zd = 0;
double NH = 0;
double NL = 0;
int uzl = 0;
double summ = 0;
double current = 0;
double lasttime = 0;
double file_handle = 0;
double Length = 6;
double bs = 0;
double ss = 0;
double buyprice = 0;
double sellprice = 0;
int Uzel[10000,3];









SetLoopCount(0); 
// loop from first bar to current bar (with shift=0) 
Swing_n=0;Swing=0;uzl=0; 
BH =High[barn];BL=Low[barn];zu=barn;zd=barn; 

for(shift=barn;shift>=0 ;shift--){ 
LL=10000000;HH=-100000000; 
for(i=shift+Length;i>=shift+1 ;i--){ 
if( Low[i]< LL ) {LL=Low[i];} 
if( High[i]>HH ) {HH=High[i];} 
} 


if( Low[shift]<LL && High[shift]>HH ) 
{ 
Swing=2; 
if( Swing_n == 1 ) {zu=shift+1;} 
if( Swing_n == -1 ) {zd=shift+1;} 

} 
else 
{ 
if( Low[shift]<LL ) {Swing=-1;} 
if( High[shift]>HH ) {Swing=1;} 
} 

if( Swing != Swing_n && Swing_n != 0 ) 
{ 
if( Swing == 2 ) {Swing=-Swing_n;BH = High[shift];BL = Low[shift]; } 
uzl=uzl+1; 
if( Swing == 1 ) {Uzel[uzl,1]=zd;Uzel[uzl,2]=BL;Uzel[uzl,3]=shift;} 
if( Swing == - 1 ) {Uzel[uzl,1]=zu;Uzel[uzl,2]=BH;Uzel[uzl,3]=shift;} 
BH = High[shift];BL = Low[shift]; 
} 

if( Swing == 1 ) { if( High[shift] >= BH ) {BH=High[shift];zu=shift;}} 
if( Swing == -1 ) { if( Low[shift]<=BL ) {BL=Low[shift]; zd=shift;}} 
Swing_n=Swing; 

} 

for(i =1;i <=uzl ;i ++){ 
SetIndexValue(Uzel[i,1],Uzel[i,2]); 
SetIndexValue2(Uzel[i,3],Uzel[i,2]); 
if( Uzel[i,2]-Uzel[i-1,2]<0 ) 
      SetArrow(Time[Uzel[i,3]], MathMin(Uzel[i,2], Low[Uzel[i,3]])-10*Point,nSymbolLow, LimeGreen);
if( Uzel[i,2]-Uzel[i-1,2]>0 ) 
      SetArrow(Time[Uzel[i,3]], MathMax(Uzel[i,2], High[Uzel[i,3]])+20*Point, nSymbolHi, Red);

}  

// eugene5 added something here
summ=0;
for(i =1;i <=uzl-1 ;i ++){ 
      if( Uzel[i+1,2]-Uzel[i,2]>0 ) 
      //it means that we must sell now (calculating profit using the previous buy
            summ=summ+Close[Uzel[i+1,3]]-Close[Uzel[i,3]];
      if( Uzel[i+1,2]-Uzel[i,2]<0 ) 
      //it means that we must buy now (calculating profit using the previous sell)
            summ=summ-(Close[Uzel[i+1,3]]-Close[Uzel[i,3]]);
} 
//Comment(TimeToStr(Time[0]), "\n"," Swing UP/Swing DWN=",swing, "/", swing_n, "\n","BL/BH=",BL,"/",BH);

//if more than delaymin-mimutes - exit
//If CurTime < lasttime + delaymin*60 Then exit;
//lasttime = CurTime;
//FileDelete("report"+Symbol);
//file_handle = FileOpen("report"+Symbol," ");
summ=0;
for(i =1;i <=uzl-1;i ++){ 
      if( Uzel[i+1,2]-Uzel[i,2]>0 ) 
      //seems necessary to sell now (write in log using previous buy)
      {
            ss=MathRound((High[Uzel[i+1,3]]-Low[Uzel[i,3]])/Point)/2;
            sellprice=Low[Uzel[i+1,3]]-ss*Point;
            summ=summ+Close[Uzel[i+1,3]]-buyprice;
        //    Comment("Bought at ", buyprice,"  ", TimeToStr(Time[Uzel[i,3]]),"'#10'Closed at on the price of ", Close[Uzel[i+1,3]], " ",TimeToStr(Time[Uzel[i+1,3]]),"'#10'Profit on last position= ", (Open[Uzel[i+1,3]]-buyprice)/Point,"pips","'#10''#10''#10'Next Trade  ---> SELLSTOP @ ",sellprice);
      //      comment("Close at ", TimeToStr(Time[Uzel[i+1,3]]), "on the price of ", Close[Uzel[i+1,3]]);
      //      comment("Place SELLSTOP @ ", sellprice ,"\n",TimeToStr(Time[Uzel[i+1,3]]));
          MoveObject("sellprice",OBJ_HLINE,Time[0],sellprice,Time[0],sellprice,Red,1,STYLE_SOLID);
          SetObjectText("sellprice_txt","SELLHere ","Arial",7,White);
        MoveObject("sellprice_txt",OBJ_TEXT,Time[0],sellprice,Time[0],sellprice,White);
            }
      if( Uzel[i+1,2]-Uzel[i,2]<0 ) 
      //seems necessary to buy now (write in log using previous sell)
      {
            bs=MathRound(-(Low[Uzel[i+1,3]]-High[Uzel[i,3]])/Point)/2;
            buyprice=High[Uzel[i+1,3]]+bs*Point;
            summ=summ-(Close[Uzel[i+1,3]]-sellprice);
           // Comment("Sold at ", sellprice,"  ", TimeToStr(Time[Uzel[i,3]]),"'#10'Closed at on the price of ", Close[Uzel[i+1,3]]," ",TimeToStr(Time[Uzel[i+1,3]]),"'#10'Profit on last position= ", -(Open[Uzel[i+1,3]]-sellprice)/Point," pips","'#10''#10''#10'Next Trade  ---> BUYSTOP @ ", buyprice);
      //      comment("Close at ", TimeToStr(Time[Uzel[i+1,3]]), "on the price of ", Close[Uzel[i+1,3]]);
      //   comment("Place BUYSTOP @ ", buyprice   ,"\n",TimeToStr(Time[Uzel[i+1,3]]));
            MoveObject("buyprice",OBJ_HLINE,Time[0],buyprice,Time[0],buyprice,LimeGreen,1,STYLE_SOLID);
          SetObjectText("buyprice_txt","BUY Here ","Arial",7,White);
        MoveObject("buyprice_txt",OBJ_TEXT,Time[0],buyprice,Time[0],buyprice,White);
            //FileWrite(file_handle,"profit on this position=", -(Close[Uzel[i+1,3]]-Close[Uzel[i,3]])/Point,       "Totally inpoints=", summ/Point);
            }}}

//FileClose(file_handle);
//print(TimeToStr(Time[Uzel[i,3]]),l[Uzel[i,3]]);
  return(0);





