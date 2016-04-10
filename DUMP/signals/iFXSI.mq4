//+------------------------------------------------------------------+
//|                                                        iFXSI.mq4 |
//|                                  Copyright © 2005, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+
#define expiryDate "2006.12.31" //expiration date yyyy.mm.dd
#define accountNum  0  //if 0 works on all accounts, if >0 then works only on this account number

#property copyright "Copyright © 2005, Forex-Experts"
#property link      "http://www.forex-experts.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Green             //buy sig color
#property indicator_color2 Red               //sell sig color
#property indicator_color3 GreenYellow       //buy ITrend color
#property indicator_color4 Magenta           //sell ITrend color
#property indicator_color5 PaleGreen         //buy ZeroLag color
#property indicator_color6 DeepPink          //sell ZeroLag color
#property indicator_color7 MediumSpringGreen //buy ADX color
#property indicator_color8 OrangeRed         //sell ADX color

//---- input parameters
extern bool useITrend=true;
extern bool useZeroLag=true;
extern bool useADX=true;
extern bool ConfirmOnCurrent=false;          //only confirmation on current bar
extern bool ShowITrend=false;
extern bool ShowZeroLag=false;
extern bool ShowADX=false;



extern int       A_period=50;
extern int       ADX_Period=14;
extern int Bands_Mode_0_2=0;  // =0-2 MODE_MAIN, MODE_LOW, MODE_HIGH
extern int Power_Price_0_6=0; // =0-6 PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW,PRICE_MEDIAN,PRICE_TYPICAL,PRICE_WEIGHTED
extern int Price_Type_0_3=0;  // =0-3 PRICE_CLOSE,PRICE_OPEN,PRICE_HIGH,PRICE_LOW
extern int Bands_Period=20;
extern int Bands_Deviation=2;
extern int Power_Period=13;


extern double  DotLoc=7;

//---- buffers
double iBuyITrend[];
double iSellITrend[];
double iBuyZeroLag[];
double iSellZeroLag[];
double iBuyAdx[];
double iSellAdx[];
double BuySig[]; //1)
double SellSig[]; //1)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,BuySig);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"buy sig");
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,SellSig);
   SetIndexEmptyValue(1,0.0);
   SetIndexLabel(1,"sell sig");

   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,iBuyITrend);
   SetIndexEmptyValue(2,0.0);
   SetIndexLabel(2,"buy ITrend");
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,iSellITrend);
   SetIndexEmptyValue(5,0.0);
   SetIndexLabel(3,"sell ITrend");

   SetIndexStyle(4,DRAW_ARROW);
   SetIndexArrow(4,233);
   SetIndexBuffer(4,iBuyZeroLag);
   SetIndexEmptyValue(4,0.0);
   SetIndexLabel(4,"buy ZeroLag");
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,234);
   SetIndexBuffer(5,iSellZeroLag);
   SetIndexEmptyValue(5,0.0);
   SetIndexLabel(5,"sell ZeroLag");

   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,233);
   SetIndexBuffer(6,iBuyAdx);
   SetIndexEmptyValue(6,0.0);
   SetIndexLabel(6,"buy ADX");
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexArrow(7,234);
   SetIndexBuffer(7,iSellAdx);
   SetIndexEmptyValue(7,0.0);
   SetIndexLabel(7,"sell ADX");




//----
//----
   for (int shift=Bars-1;shift>=0;shift--) {
      BuySig[shift]=0;
      SellSig[shift]=0;
      iBuyITrend[shift]=0;
      iSellITrend[shift]=0;
      iBuyZeroLag[shift]=0;
      iSellZeroLag[shift]=0;
      iBuyAdx[shift]=0;
      iSellAdx[shift]=0;       
   
   }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   for (int shift=Bars-1;shift>=0;shift--) {
      BuySig[shift]=0;
      SellSig[shift]=0;        
      iBuyITrend[shift]=0;
      iSellITrend[shift]=0;
      iBuyZeroLag[shift]=0;
      iSellZeroLag[shift]=0;
      iBuyAdx[shift]=0;
      iSellAdx[shift]=0;       
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int    shift;
   int    limit;
//---- 
  if (CurTime() > StrToTime(expiryDate)) {
      Alert("Version expired!");
      return;
   }

   if (accountNum!=0 && accountNum!=AccountNumber()) {
      Alert("This expert is not licensed to your account number!");
      return;
   }
   
//---- check for possible errors
if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
if(counted_bars>0) counted_bars--;
limit=Bars-counted_bars;
shift=Bars;

 for(int i=limit; i>=0; i--)
{
   double cci_cur[2],cci_prev[2];
   double BuyCCI[2],SellCCI[2];
   for (int cnt=0; cnt<=1; cnt++) {   
   //check cci crossing
   cci_cur[cnt]=iCCI(NULL,0,A_period,PRICE_TYPICAL,i+cnt);
   cci_prev[cnt]=iCCI(NULL,0,A_period,PRICE_TYPICAL,i+1+cnt);

   if (cci_cur[cnt]>0 && cci_prev[cnt]<0)   BuyCCI[cnt]=Low[i]-DotLoc*Point; else BuyCCI[cnt]=0;
   if (cci_cur[cnt]<0 && cci_prev[cnt]>0)   SellCCI[cnt]=High[i]+DotLoc*Point; else SellCCI[cnt]=0;
   }
   

   //check iTrend crossing
   double itrendg_cur[2],itrendg_prev[2],itrendr_cur[2],itrendr_prev[2],BuyiTrendCross[2],SelliTrendCross[2];
   bool BuyITrend=false, SellITrend=false;
   
   for (cnt=0; cnt<=1; cnt++) {
   itrendg_cur[cnt]=iTrend(0,i+cnt);
   itrendg_prev[cnt]=iTrend(0,i+1+cnt);
   itrendr_cur[cnt]=iTrend(1,i+cnt);
   itrendr_prev[cnt]=iTrend(1,i+1+cnt);
   if (itrendr_prev[cnt]>itrendg_prev[cnt] && itrendr_cur[cnt]<itrendg_cur[cnt]) BuyiTrendCross[cnt]=1; else BuyiTrendCross[cnt]=0;
   if (itrendr_prev[cnt]<itrendg_prev[cnt] && itrendr_cur[cnt]>itrendg_cur[cnt]) SelliTrendCross[cnt]=1; else SelliTrendCross[cnt]=0;
   }

   if ((!ConfirmOnCurrent && ((BuyiTrendCross[0] && (BuyCCI[0]>0 || BuyCCI[1]>0)) || (BuyiTrendCross[1] && BuyCCI[0]>0))) ||
      (ConfirmOnCurrent && BuyiTrendCross[0] && BuyCCI[0]>0)) BuyITrend=true; else BuyITrend=false;   
   if ((!ConfirmOnCurrent && ((SelliTrendCross[0] && (SellCCI[0]>0 || SellCCI[1]>0)) || (SelliTrendCross[1] && SellCCI[0]>0))) ||
      (!ConfirmOnCurrent && SelliTrendCross[0] && SellCCI[0]>0)) SellITrend=true; else SellITrend=false;



   //ZeroLag Crossing
   double zlsw_cur[2],zlsw_prev[2],zlsr_cur[2],zlsr_prev[2],BuyZeroLagCross[2],SellZeroLagCross[2];
   bool BuyZeroLag=false, SellZeroLag=false;
   
   for (cnt=0; cnt<=1; cnt++) {   
   zlsw_cur[cnt]=iCustom(NULL,0,"Zerolagstochs",0,i+cnt);
   zlsw_prev[cnt]=iCustom(NULL,0,"Zerolagstochs",0,i+1+cnt);   
   zlsr_cur[cnt]=iCustom(NULL,0,"Zerolagstochs",1,i+cnt);
   zlsr_prev[cnt]=iCustom(NULL,0,"Zerolagstochs",1,i+1+cnt);
   if (zlsr_prev[cnt]>zlsw_prev[cnt] && zlsr_cur[cnt]<zlsw_cur[cnt]) BuyZeroLagCross[cnt]=1; else BuyZeroLagCross[cnt]=0; 
   if (zlsr_prev[cnt]<zlsw_prev[cnt] && zlsr_cur[cnt]>zlsw_cur[cnt]) SellZeroLagCross[cnt]=1; else SellZeroLagCross[cnt]=0;
   } 

   if ((!ConfirmOnCurrent && ((BuyZeroLagCross[0] && (BuyCCI[0]>0 || BuyCCI[1]>0)) || (BuyZeroLagCross[1] && BuyCCI[0]>0))) ||
       (ConfirmOnCurrent && BuyZeroLagCross[0] && BuyCCI[0]>0)) BuyZeroLag=true; else BuyZeroLag=false;
   if ((!ConfirmOnCurrent && ((SellZeroLagCross[0] && (SellCCI[0]>0 || SellCCI[1]>0)) || (SellZeroLagCross[1] && SellCCI[0]>0))) ||
       (ConfirmOnCurrent && SellZeroLagCross[0] && SellCCI[0]>0)) SellZeroLag=true; else SellZeroLag=false;
   
   
   
   //Adx crossing
    double b4plusdi[2],b4minusdi[2],nowplusdi[2],nowminusdi[2],BuyADXCross[2],SellADXCross[2];
      
    bool BuyADX=false, SellADX=false;
    for (cnt=0; cnt<=1; cnt++) {
    b4plusdi[cnt]=iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,i+1+cnt);
    nowplusdi[cnt]=iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,i+cnt);
   
    b4minusdi[cnt]=iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,i+1+cnt);
    nowminusdi[cnt]=iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,i+cnt);
    if (b4plusdi[cnt]>b4minusdi[cnt] && nowplusdi[cnt]<nowminusdi[cnt]) SellADXCross[cnt]=1; else SellADXCross[cnt]=0;
    if (b4plusdi[cnt]<b4minusdi[cnt] && nowplusdi[cnt]>nowminusdi[cnt]) BuyADXCross[cnt]=1; else BuyADXCross[cnt]=0;
    }

    if ((!ConfirmOnCurrent && ((BuyADXCross[0] && (BuyCCI[0]>0 || BuyCCI[1]>0)) || (BuyADXCross[1] && BuyCCI[0]>0))) ||
       (ConfirmOnCurrent && BuyADXCross[0] && BuyCCI[0]>0)) BuyADX=true; else BuyADX=false;
    if ((!ConfirmOnCurrent && ((SellADXCross[0] && (SellCCI[0]>0 || SellCCI[1]>0)) || (SellADXCross[1] && SellCCI[0]>0))) ||
       (ConfirmOnCurrent && SellADXCross[0] && SellCCI[0]>0)) SellADX=true; else SellADX=false;


 //main plot 
   
   
   if (ShowITrend && BuyiTrendCross[0]) iBuyITrend[i]=Low[i]-2.0*DotLoc*Point;  
   if (ShowITrend && SelliTrendCross[0]) iSellITrend[i]=High[i]+2.0*DotLoc*Point;  
   
   if (ShowZeroLag && BuyZeroLagCross[0]) iBuyZeroLag[i]=Low[i]-3.0*DotLoc*Point;  
   if (ShowZeroLag && SellZeroLagCross[0]) iSellZeroLag[i]=High[i]+3.0*DotLoc*Point;  
   
   if (ShowADX && BuyADXCross[0]) iBuyAdx[i]=Low[i]-4.0*DotLoc*Point;  
   if (ShowADX && SellADXCross[0]) iSellAdx[i]=High[i]+4.0*DotLoc*Point;  



   if ((BuyITrend || !useITrend) && (BuyZeroLag || !useZeroLag) && (BuyADX ||!useADX))   BuySig[i]=Low[i]-DotLoc*Point; else BuySig[i]=0.0;
   if ((SellITrend || !useITrend) && (SellZeroLag || !useZeroLag)&& (SellADX||!useADX))   SellSig[i]=High[i]+DotLoc*Point; else SellSig[i]=0.0;
   if (!useITrend && !useZeroLag && !useADX) {     
      BuySig[i]=0.0;
      SellSig[i]=0.0;
   }

}
//----
 
 
//----
   return(0);
  }

  double iTrend (int mode, int index)
   {
      int Bands_Mode;
      double Power_Price,CurrentPrice;
      if (Bands_Mode_0_2==1) Bands_Mode=MODE_LOW;
      if (Bands_Mode_0_2==2) Bands_Mode=MODE_HIGH;
      if (Bands_Mode_0_2==0) Bands_Mode=MODE_MAIN;
      if (Power_Price_0_6==1) Power_Price=PRICE_OPEN;
      if (Power_Price_0_6==2) Power_Price=PRICE_HIGH;
      if (Power_Price_0_6==3) Power_Price=PRICE_LOW;
      if (Power_Price_0_6==4) Power_Price=PRICE_MEDIAN;
      if (Power_Price_0_6==5) Power_Price=PRICE_TYPICAL;
      if (Power_Price_0_6==6) Power_Price=PRICE_WEIGHTED;
      if (Power_Price_0_6==0) Power_Price=PRICE_CLOSE;
   
      if (Price_Type_0_3==1) CurrentPrice=Open[index];
      if (Price_Type_0_3==2) CurrentPrice=High[index];
      if (Price_Type_0_3==3) CurrentPrice=Low[index];
      if (Price_Type_0_3==0) CurrentPrice=Close[index];   
      if (mode==0) return (CurrentPrice-iBands(NULL,0,Bands_Period,Bands_Deviation,0,Bands_Mode,Power_Price,index));
      if (mode==1) return(-(iBearsPower(NULL,0,Power_Period,Power_Price,index)+iBullsPower(NULL,0,Power_Period,Power_Price,index)));    

     }
    

//+------------------------------------------------------------------+