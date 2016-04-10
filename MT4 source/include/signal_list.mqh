//+------------------------------------------------------------------+
//|                                                  signal_list.mqh |
//|             Copyright 2014, Tim Jackson <webmechanicr@gmail.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Tim Jackson <webmechanicr@gmail.com>"
#property link      ""
#property strict


/**
 * The library of signals provides L5 System.
 * Signal class has prefix SIGNAL_. Within each signal class
 * definition specification of arguments is located, which this signal takes.
 * The specification represents string describing each of arguments.
 */


/*
 * SAMPLE OF INDICATOR
 * The class is created for example how signals should be made.

 
 class SAMPLE_OF_INDICATOR: public INDICATOR{
      public:
         SAMPLE_OF_INDICATOR(){
            name = "SAMPLE_OF_INDICATOR";
            //NoByTimeframes();
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];", //It's recommended to use this argument on first place
               "main:double = [1.0 - 34, 1.5][=8.5#t1=9#t2=10][where(this = timeFrame or this >= 2 and this <= 4 or this >=13 and this <=14)];",
               "too:string = [for,while,q,3432][=while][where(this = \"for\" and timeFrame < 150)];",
               "too2:string = [=val]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SAMPLE_OF_INDICATOR::Perform(){
      int result = VOID_SIGNAL;
      //type argName = args.Get(i);
      
      //double  iCustom(
      //   string       symbol,           // имя символа
      //   int          timeframe,        // таймфрейм
      //   string       name,             // папка/имя_пользовательского индикатора
      //   ...                            // список входных параметров индикатора
      //   int          mode,             // источник данных
      //   int          shift             // сдвиг
      //);
      
      return result;
 }
 
 
 
 
 
  * END SAMPLE OF INDICATOR
  */

 //+-----------------------------------------------------------------------+
 //                         auxiliary procedures                           |
 //+-----------------------------------------------------------------------+

 

 //+-----------------------------------------------------------------------+
 //                           LIST OF SIGNALS                              |
 //+-----------------------------------------------------------------------+
 
 
 //MA SIGNAL
 class SIGNAL_MA: public INDICATOR{
      public:
         SIGNAL_MA(){
            name = "SIGNAL_MA";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "period1:int = [10-16,1][=13];",
               "period2:int = [29-35, 1][=32];",
               "method:int = [0-3, 1][=0];",
               "applied_price:int = [0-6, 1][=0];",
               "allowedDistance:int = [1-3, 1][=2]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_MA::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));
      int period1 = StrToInteger(args.Get(1));
      int period2 = StrToInteger(args.Get(2));
      int method = StrToInteger(args.Get(3));
      int appliedPrice = StrToInteger(args.Get(4));
      double allowedDistance = CalculatePoint(StrToInteger(args.Get(5)));
      //signal code
      double line13 = iMA(l5Symbol, timeFrame, period1, 0, method, appliedPrice, 0);
      double line31 = iMA(l5Symbol, timeFrame, period2, 0, method, appliedPrice, 1);
      
      if(line13 > line31)
         result = BUY_SIGNAL;
      else{
         result = SELL_SIGNAL;
      }
   
      if(MathAbs(line13 - line31) < allowedDistance)
         result = VOID_SIGNAL;
         
      return result;
}

//END MA SIGNAL
 
 //SAR SIGNAL
 
 class SIGNAL_SAR: public INDICATOR{
      public:
         SIGNAL_SAR(){
            name = "SIGNAL_SAR";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "step:double = [0.01-0.03, 0.005][=0.02];",
               "maximum:double = [0.1-0.3, 0.05][=0.2]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_SAR::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));
      double step = StrToDouble(args.Get(1));
      double maximum = StrToDouble(args.Get(2));
      
      double cur = iSAR(l5Symbol, timeFrame, step, maximum, 0);  
      if(cur < Low[0])
         result = BUY_SIGNAL;
      else{
         if(cur > High[0])
            result = SELL_SIGNAL;
      }
      
      return result;
 }
 
 //END SAR SINGAL
 
 //AD SIGNAL
 
 class SIGNAL_AD: public INDICATOR{
      public:
         SIGNAL_AD(){
            name = "SIGNAL_AD";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_AD::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));

      double val1 = iAC(l5Symbol, timeFrame, 0);
      double val2 = iAC(l5Symbol, timeFrame, 1);
      double val3 = iAC(l5Symbol, timeFrame, 2);
      
      //Buy
      if(val1 > val2 && (val1 > 0 && val2 > 0)){
         result = BUY_SIGNAL;
      }
      
      if(val1 > val2 && val2 > val3 && (val2 < 0)){
         result = BUY_SIGNAL;
      } 
      
      if(val1 < val2 && (val1 < 0 && val2 < 0)){
         result = SELL_SIGNAL;
      }
      if(val1 < val2 && val2 < val3 && (val2 > 0)){
         result = SELL_SIGNAL;
      }
      
      //Saucer analise...
      //TO DO
      
      return result;
}
 //END AD SIGNAL
 
 //CCI SIGNAL
class SIGNAL_CCI: public INDICATOR{
      public:
         SIGNAL_CCI(){
            name = "SIGNAL_CCI";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "limit:int = [90-180, 10][=100];",
               "period:int = [10-15,1][=13];",
               "applied_price:int = [0-6, 1][=0]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_CCI::Perform(){
      int result = VOID_SIGNAL;
      
      int timeFrame = StrToInteger(args.Get(0));
      int limit = StrToInteger(args.Get(1));
      int period = StrToInteger(args.Get(2));
      int applied_price = StrToInteger(args.Get(3));
 
      double val1 = iCCI(l5Symbol,timeFrame,period,applied_price,0);
      double val2 = iCCI(l5Symbol,timeFrame,period,applied_price,1);
      double val3 = iCCI(l5Symbol,timeFrame,period,applied_price,2);
      
      if(val1 > limit && val2 > limit && val3 > limit)
         if(val1 < val2 && val3 < val2)
            result = SELL_SIGNAL;
      
       if(val1 < -limit && val2 < -limit && val3 < -limit)
         if(val1 > val2 && val3 > val2)
            result = BUY_SIGNAL;
      
      //Divergence analise...
      //TO DO
      
      return result;
}
 
 //END CCI SIGNAL
 
 //Stochastic SIGNAL
 
 class SIGNAL_STOCHASTIC: public INDICATOR{
      public:
         SIGNAL_STOCHASTIC(){
            name = "SIGNAL_STOCHASTIC";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "limit1:int = [70-90, 10][=80];",
               "limit2:int = [10-30, 10][=20];",
               "periodK:int = [4-6, 1][=5];",
               "periodD:int = [2-5, 1][=3][where(this < periodK)];",
               "slowing:int = [2-4, 1][=3];",
               "method:int = [0-3, 1][=0];",
               "price_field:int = [0,1][=0];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_STOCHASTIC::Perform(){
      int result = VOID_SIGNAL;
      
      int timeFrame = StrToInteger(args.Get(0));
      int limit1 = StrToInteger(args.Get(1));
      int limit2 = StrToInteger(args.Get(2));
      int periodK = StrToInteger(args.Get(3));
      int periodD = StrToInteger(args.Get(4));
      int slowing = StrToInteger(args.Get(5));
      int method = StrToInteger(args.Get(6));
      int price_field = StrToInteger(args.Get(7));
      
      double val1 = iStochastic(l5Symbol,timeFrame,periodK,periodD,slowing,method,price_field,MODE_MAIN,0);
      double val2 = iStochastic(l5Symbol,timeFrame,periodK,periodD,slowing,method,price_field,MODE_SIGNAL,0);
      
      if(val1 > limit1 && val2 > limit1)
         if(val1 < val2)
            result = SELL_SIGNAL;
      
      if(val1 < limit2 && val2 < limit2)
         if(val1 > val2)
            result = BUY_SIGNAL;
      
      return result;
 }
 //END Stochastic SIGNAL
 
 //Fractals SIGNAL
 
 class SIGNAL_FRACTALS: public INDICATOR{
      public:
         SIGNAL_FRACTALS(){
            name = "SIGNAL_FRACTALS";
             
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "limit:int = [80-120,20][=100];",
               "method:int = [0-3, 1][=0];",
               "applied_price:int = [0-6, 1][=0];",
               "jaw_period:int = [=13];",
               "jaw_shift:int = [=8];",
               "teeth_period:int = [7-9, 1][=8];",
               "teeth_shift:int = [4-6, 1][=5];",
               "lips_period:int = [4-6, 1][=5];",
               "lips_shift:int = [2-4, 1][=3];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_FRACTALS::Perform(){
      int result = VOID_SIGNAL;
      
      int timeFrame = StrToInteger(args.Get(0));
      int limit = StrToInteger(args.Get(1));
      int method = StrToInteger(args.Get(3));
      int applied_price = StrToInteger(args.Get(3));
      int jaw_period = StrToInteger(args.Get(4));
      int jaw_shift = StrToInteger(args.Get(5));
      int teeth_period = StrToInteger(args.Get(6));
      int teeth_shift = StrToInteger(args.Get(7));
      int lips_period = StrToInteger(args.Get(8));
      int lips_shift = StrToInteger(args.Get(9));
      
      double upperFractal = 0, lowerFractal = 0;
     
      int countL = 1;
      int countU = 1;
      while(countL <= limit){
         lowerFractal = iFractals(l5Symbol, timeFrame, MODE_LOWER, countL);
         if(lowerFractal != 0)
            break;
         countL++;
      }
      countU = 2;
      while(countU <= limit){
         upperFractal = iFractals(l5Symbol, timeFrame, MODE_UPPER, countU);
         if(upperFractal != 0)
            break;
         countU++;
      }
      
      double averagePrice = (Bid + Ask) / 2;
      
      //ForSell
      double jawVal=iAlligator(l5Symbol, timeFrame, 
                              jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORJAW, countL);
      double teethVal=iAlligator(l5Symbol, timeFrame, 
                              jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORTEETH, countL);
      double lipsVal=iAlligator(l5Symbol, timeFrame, 
                              jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORLIPS, countL);
      
      if(lipsVal < teethVal && teethVal < jawVal && lowerFractal < lipsVal  && lowerFractal != 0){
         if(averagePrice <= lowerFractal && helpingToFractalsSignal(countL, l5Symbol, timeFrame, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price)){
            result = SELL_SIGNAL;
         }
      }
      
      //ForBuy
      jawVal=iAlligator(l5Symbol, timeFrame, 
                              13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, countU);
      teethVal=iAlligator(l5Symbol, timeFrame, 
                              13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, countU);
      lipsVal=iAlligator(l5Symbol, timeFrame, 
                              13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, countU);
      
      if(lipsVal > teethVal && teethVal > jawVal && upperFractal > lipsVal){
         if(averagePrice >= upperFractal && helpingToFractalsSignal(countU, l5Symbol, timeFrame, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price)){
            result = BUY_SIGNAL;
         }
      }
     
      return result;
 }
 
 
bool helpingToFractalsSignal(int count, string symbol, int timeFrame, int jaw_period, int jaw_shift, int teeth_period, int teeth_shift, int lips_period, int lips_shift, int method, int applied_price){
   count = count + 2; 
   for(int i = 0; i < count - 1; i++){
      double jawVal=iAlligator(symbol, timeFrame, 
                           jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORJAW, i);
      double teethVal=iAlligator(symbol, timeFrame, 
                           jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORTEETH, i);
      double lipsVal=iAlligator(symbol, timeFrame, 
                           jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORLIPS, i);
      double _jawVal=iAlligator(symbol, timeFrame, 
                           jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORJAW, i + 1);
      double _teethVal=iAlligator(symbol, timeFrame, 
                           jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORTEETH, i + 1);
      double _lipsVal=iAlligator(symbol, timeFrame, 
                           jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, applied_price, MODE_GATORLIPS, i + 1);
      if((teethVal >= lipsVal && _teethVal <= _lipsVal) ||
         ((teethVal <= lipsVal && _teethVal >= _lipsVal)) ||
         (teethVal >= jawVal && _teethVal <= _jawVal) ||
         (teethVal <= jawVal && _teethVal >= _jawVal) ||
         (lipsVal <= jawVal && _lipsVal >= _jawVal) ||
         (lipsVal >= jawVal && _lipsVal <= _jawVal))
            return(false);
   }
   return(true);
}
 
 //END Fractals SIGNAL
 
 //MFI SIGNAL
 
  class SIGNAL_MFI: public INDICATOR{
      public:
         SIGNAL_MFI(){
            name = "SIGNAL_MFI";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "lowerLimit:int = [10-30, 2][=20];",
               "upperLimit:int = [70-90, 2][=80];",
               "period:int = [10-20, 1][=14];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_MFI::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));
      int lowerLimit = StrToInteger(args.Get(1));
      int upperLimit = StrToInteger(args.Get(2));
      int period = StrToInteger(args.Get(3));
      
      double value = iMFI(l5Symbol, timeFrame, period, 0);
      
      if(value > upperLimit)
         result = BUY_SIGNAL;
      if(value < lowerLimit)
         result = SELL_SIGNAL;
      
      return result;
 }
 
 //END MFI SIGNAL
 
 //OBV SIGNAL
 
class SIGNAL_OBV: public INDICATOR{
      public:
         SIGNAL_OBV(){
            name = "SIGNAL_OBV";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "period:int = [3-15, 1][=7];",
               "applied_price:int = [0-6, 1][=0];",
               "signal_corner:double = [0.52,0.524,0.6,0.8,0.9,1.1][=0.524];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_OBV::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));
      int period = StrToInteger(args.Get(1));
      int applied_price = StrToInteger(args.Get(2));
      double signal_corner = StrToDouble(args.Get(3));
      
      double val1 = iOBV(l5Symbol, timeFrame, applied_price, 0);
      double val2 = iOBV(l5Symbol, timeFrame, applied_price, period);
      
      double x = period;
      double y = val1 - val2;
      
      double corner = MathArctan( y / x);
      
      if(corner >= signal_corner)
         result = BUY_SIGNAL;
      if(corner <= -signal_corner)
         result = SELL_SIGNAL;
      
      return result;
 }
 
 //END OBV SIGNAL

//Ichimoku SIGNAL

class SIGNAL_ICHIMOKU: public INDICATOR{
      public:
         SIGNAL_ICHIMOKU(){
            name = "SIGNAL_ICHIMOKU";
           
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "tenkan_sen:int = [7-12,1][=9];",
               "kijun_sen:int = [24-28, 1][=26];",
               "senkou_span_b:int = [49-54, 1][=52];",
               "closestToLevelArea:int = [10-30, 2][=15]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_ICHIMOKU::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));
      int tenkan_sen = StrToInteger(args.Get(1));
      int kijun_sen = StrToInteger(args.Get(2));
      int senkou_span_b = StrToInteger(args.Get(3));
      double closestToLevelArea = CalculatePoint(StrToInteger(args.Get(4)));
      
      double senkouSpanA = iIchimoku(l5Symbol, timeFrame, tenkan_sen, kijun_sen, senkou_span_b, MODE_SENKOUSPANA, 0);
      double senkouSpanB = iIchimoku(l5Symbol, timeFrame, tenkan_sen, kijun_sen, senkou_span_b, MODE_SENKOUSPANB, 0);
      double chinkouSpan = iIchimoku(l5Symbol, timeFrame, tenkan_sen, kijun_sen, senkou_span_b, MODE_CHINKOUSPAN, 0);
      
      if(MathAbs(Bid - senkouSpanA) <= closestToLevelArea ||
         MathAbs(Bid - senkouSpanB) <= closestToLevelArea)
      {
         if(chinkouSpan > Bid)
            result = BUY_SIGNAL;
         else
            result = SELL_SIGNAL;
      }
      
      return result;
 }

//END Ichimoku SIGNAL

//FibboPivotPulseSn SIGNAL

class SIGNAL_FibboPivotPulseSn: public INDICATOR{
      public:
         SIGNAL_FibboPivotPulseSn(){
            name = "SIGNAL_FibboPivotPulseSn";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "closestToLevelArea:int = [10-30, 2][=15];"
            );
            
            NoByTimeframes();
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_FibboPivotPulseSn::Perform(){
      int result = VOID_SIGNAL;
      double closestToLevelArea = CalculatePoint(StrToInteger(args.Get(0)));
      
      //signal code
      double levels[];
      FibboPivotPulseHelping(l5Symbol, levels);
      
      if(MathAbs(Bid - levels[0]) <= closestToLevelArea ||
         MathAbs(Bid - levels[1]) <= closestToLevelArea ||
         MathAbs(Bid - levels[2]) <= closestToLevelArea )
            result = SELL_SIGNAL;
      if(MathAbs(Bid - levels[3]) <= closestToLevelArea ||
         MathAbs(Bid - levels[4]) <= closestToLevelArea ||
         MathAbs(Bid - levels[5]) <= closestToLevelArea )
            result = BUY_SIGNAL;
         
         
      return result;
}

void FibboPivotPulseHelping(string symbol, double& result[]){
      ArrayResize(result, 6);
      
      //----
      double rates[7][7],yesterday_close,yesterday_high,yesterday_low;
      ArrayCopyRates(rates, symbol, PERIOD_D1);

      if(DayOfWeek() == 1)
      {
         if(TimeDayOfWeek(iTime(symbol,PERIOD_D1,1)) == 5)
         {
             yesterday_close = rates[1][4];
             yesterday_high = rates[1][3];
             yesterday_low = rates[1][2];
         }
         else
         {
            for(int d = 5;d>=0;d--)
            {
               if(TimeDayOfWeek(iTime(symbol,PERIOD_D1,d)) == 5)
               {
                   yesterday_close = rates[d][4];
                   yesterday_high = rates[d][3];
                   yesterday_low = rates[d][2];
               }
            }  
         }
      }
      else
      {
          yesterday_close = rates[1][4];
          yesterday_high = rates[1][3];
          yesterday_low = rates[1][2];
      }

      //---- Calculate Pivots
      double R = yesterday_high - yesterday_low;//range
      double p = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
      double r3 = p + (R * 1.000);
      double r2 = p + (R * 0.618);
      double r1 = p + (R * 0.382);
      double s1 = p - (R * 0.382);
      double s2 = p - (R * 0.618);
      double s3 = p - (R * 1.000);
      
      result[0] = r1;
      result[1] = r2;
      result[2] = r3;
      result[3] = s1;
      result[4] = s2;
      result[5] = s3;
}
//END FibboPivotPulseSn

//PivotDaily SIGNAL

 class SIGNAL_PivotDaily: public INDICATOR{
      public:
         SIGNAL_PivotDaily(){
            name = "SIGNAL_PivotDaily";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "closestToLevelArea:int = [10-30, 2][=15]"
            );
            NoByTimeframes();
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_PivotDaily::Perform(){
      int result = VOID_SIGNAL;
      double closestToLevelArea = CalculatePoint(StrToInteger(args.Get(0)));
      
      //---- Get new daily prices
      double rates_d1[2][6];
      ArrayCopyRates(rates_d1, l5Symbol, PERIOD_D1);

      double yesterday_close = rates_d1[1][4];
      double yesterday_high = rates_d1[1][3];
      double yesterday_low = rates_d1[1][2];
      
      //---- Calculate Pivots
      double Q = (yesterday_high - yesterday_low);
      double H4 = (Q*0.55)+yesterday_close;
	   double H3 = (Q*0.27)+yesterday_close;
	   double L3 = yesterday_close-(Q*0.27);	
	   double L4 = yesterday_close-(Q*0.55);	
   
      if(MathAbs(Bid - L3) <= closestToLevelArea ||
         MathAbs(Bid - L4) <= closestToLevelArea
         )
            result = SELL_SIGNAL;
      if(MathAbs(Bid - H3) <= closestToLevelArea ||
         MathAbs(Bid - H4) <= closestToLevelArea )
            result = BUY_SIGNAL;
   
      return result;
 }

//END PivotDaily SIGNAL

//START CustomMacd SIGNAL

class SIGNAL_CUSTOM_MACD: public INDICATOR{
      public:
         SIGNAL_CUSTOM_MACD(){
            name = "SIGNAL_CUSTOM_MACD";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "fastEma:int = [7-11,1][=9];",
               "slowEma:int = [62-66,1][=64];",
               "signalSma:int = [110-114,1][=112];",
               "HstThresHold:double = [0-1.5,0.5][=0.5];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_CUSTOM_MACD::Perform(){

      int result = VOID_SIGNAL;
      
      int timeFrame = (int) StringToInteger(args.Get(0));
      int FastEMA = (int) StringToInteger(args.Get(1));
      int SlowEMA = (int) StringToInteger(args.Get(2));
      int SignalSMA = (int) StringToInteger(args.Get(3));
      double HistThreshold = StringToDouble(args.Get(4));
      
      static bool InLTrade = false;
      static bool InSTrade = false;
      double Buffer1[]; 
      double Buffer2[]; 
      double Buffer3[];
      double Buffer4[]; 
      int limit = 10;
      ArrayResize(Buffer1, limit);
      ArrayResize(Buffer2, limit);
      ArrayResize(Buffer3, limit);
      ArrayResize(Buffer4, limit);
      
      for(int i=0; i<limit; i++)//---- macd counted in the 1-st buffer histogram
         Buffer1[i]=iMA(NULL,timeFrame,FastEMA,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,timeFrame,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
    
      for(int i=0; i<limit; i++)//---- signal line counted in the 2-nd buffer line
         Buffer2[i]=iMAOnArray(Buffer1,limit,SignalSMA,0,MODE_SMA,i);
     
      for(int i=0; i<limit; i++)//---- histogram is the difference between macd and signal line
      {
         Buffer3[i]=Buffer1[i]-Buffer2[i];
      }
      
      for(int i=1; i<limit; i++)//---- macd[1]
         Buffer4[i]=iMA(NULL,timeFrame,FastEMA,0,MODE_EMA,PRICE_CLOSE,i-1)-iMA(NULL,timeFrame,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i-1);
     
      for(int i=limit - 1; i>=1; i--)
      {
         if((Buffer3[i-1]  > 0) && (Buffer3[i] < 0) && Buffer3[i-1] >= TruePointValue((int) HistThreshold))//Long Begin
         {
            InLTrade = true; 
            InSTrade = false;
            result = BUY_SIGNAL;
         }
         if ((Buffer3[i-1]  < 0) && (Buffer3[i] > 0) && Buffer3[i-1] <= -TruePointValue((int) HistThreshold))//Short Begin
         {
            InSTrade = true; 
            InLTrade = false;  
            result = SELL_SIGNAL;
         }
         
         if ((InSTrade  == true) && (Buffer3[i-1] > Buffer3[i]))//Short End
         {
            InSTrade = false; 
             result = BUY_SIGNAL;
         }
         if ((InLTrade == true) && (Buffer3[i-1] < Buffer3[i]))//Long End
         {
            InLTrade = false; 
            result = SELL_SIGNAL;  
         }
      }
      
      return result;
 }

//END CustomMacd SIGNAL

//START EA_Vegas SIGNAL

class SIGNAL_EA_VEGAS: public INDICATOR{
      public:
         SIGNAL_EA_VEGAS(){
            name = "SIGNAL_EA_VEGAS";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "RiskModel:int = [1-4,1][=1];",
               "MA1:int = [142-146,1][=144];",
               "MA2:int = [167-171,1][=169];",
               "HstThresHold:double = [0-1.5,0.5][=0.5];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_EA_VEGAS::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = (int) StringToInteger(args.Get(0));
      int RiskModel = (int) StringToInteger(args.Get(1));
      int MA1 = (int) StringToInteger(args.Get(2));
      int MA2 = (int) StringToInteger(args.Get(3));
      double HistThreshold = StringToDouble(args.Get(4));
      
      static bool InLTrade = false;
      static bool InSTrade = false;
      double ExtMapBuffer1[];
      double ExtMapBuffer2[];
      double ExtMapBuffer3[];
      double ExtMapBuffer4[];
      double ExtMapBuffer5[];
      double ExtMapBuffer6[];
      double ExtMapBuffer7[];
      double ExtMapBuffer8[];
      int limit = 1;
      ArrayResize(ExtMapBuffer1, limit);
       ArrayResize(ExtMapBuffer2, limit);
        ArrayResize(ExtMapBuffer3, limit);
         ArrayResize(ExtMapBuffer4, limit);
          ArrayResize(ExtMapBuffer5, limit);
           ArrayResize(ExtMapBuffer6, limit);
            ArrayResize(ExtMapBuffer7, limit);
             ArrayResize(ExtMapBuffer8, limit);
      
      for(int i=0; i<limit; i++)
      {
           //---- ma_shift set to 0 because SetIndexShift called abowe
           ExtMapBuffer1[i]=iMA(NULL,timeFrame,MA1,0,MODE_EMA,PRICE_CLOSE,i);
           ExtMapBuffer2[i]=iMA(NULL,timeFrame,MA2,0,MODE_EMA,PRICE_CLOSE,i);
            
           //Model #1 34,55,89
           if(RiskModel==1)
           {
               ExtMapBuffer3[i]=ExtMapBuffer2[i]+34*Point;
               ExtMapBuffer4[i]=ExtMapBuffer2[i]+55*Point;
               ExtMapBuffer5[i]=ExtMapBuffer2[i]+89*Point;
               
               ExtMapBuffer6[i]=ExtMapBuffer2[i]-34*Point;
               ExtMapBuffer7[i]=ExtMapBuffer2[i]-55*Point;
               ExtMapBuffer8[i]=ExtMapBuffer2[i]-89*Point;    
           }
            
            //Model #2 55,89,144
            if(RiskModel==2)
            {
               ExtMapBuffer3[i]=ExtMapBuffer2[i]+55*Point;
               ExtMapBuffer4[i]=ExtMapBuffer2[i]+89*Point;
               ExtMapBuffer5[i]=ExtMapBuffer2[i]+144*Point;
               
               ExtMapBuffer6[i]=ExtMapBuffer2[i]-55*Point;
               ExtMapBuffer7[i]=ExtMapBuffer2[i]-88*Point;
               ExtMapBuffer8[i]=ExtMapBuffer2[i]-144*Point;    
            }
            
             //Model #3 89,144,233
            if(RiskModel==3)
            {
               ExtMapBuffer3[i]=ExtMapBuffer2[i]+89*Point;
               ExtMapBuffer4[i]=ExtMapBuffer2[i]+144*Point;
               ExtMapBuffer5[i]=ExtMapBuffer2[i]+233*Point;
               
               ExtMapBuffer6[i]=ExtMapBuffer2[i]-89*Point;
               ExtMapBuffer7[i]=ExtMapBuffer2[i]-144*Point;
               ExtMapBuffer8[i]=ExtMapBuffer2[i]-233*Point;    
            }
            
             //Model #4 144,233,377
            if(RiskModel==4)
            {
               ExtMapBuffer3[i]=ExtMapBuffer2[i]+144*Point;
               ExtMapBuffer4[i]=ExtMapBuffer2[i]+233*Point;
               ExtMapBuffer5[i]=ExtMapBuffer2[i]+377*Point;
               
               ExtMapBuffer6[i]=ExtMapBuffer2[i]-144*Point;
               ExtMapBuffer7[i]=ExtMapBuffer2[i]-233*Point;
               ExtMapBuffer8[i]=ExtMapBuffer2[i]-377*Point;    
            }
       }
          
       if(ExtMapBuffer2[0] - ExtMapBuffer1[0] >= TruePointValue((int) HistThreshold) && Close[0] < ExtMapBuffer7[0]){
         InSTrade = true;
         InLTrade = false;
         result = SELL_SIGNAL;
       }
       
       if(ExtMapBuffer1[0] - ExtMapBuffer2[0] >= TruePointValue((int) HistThreshold) && Close[0] > ExtMapBuffer4[0]){
         InSTrade = false;
         InLTrade = true;
         result = BUY_SIGNAL;
       }
       
       if(InSTrade == true && (ExtMapBuffer1[0] - ExtMapBuffer2[0] > 0 || Close[0] > ExtMapBuffer4[0])){
            InSTrade = false;
            result = BUY_SIGNAL;
       }
       
       if(InLTrade == true && (ExtMapBuffer2[0] - ExtMapBuffer1[0] > 0 || Close[0] < ExtMapBuffer7[0])){
            InLTrade = false;
            result = SELL_SIGNAL;
       }
      
      return result;
 }

//END EA_Vegas SIGNAL

//START Volatility_Pivot SIGNAL

class SIGNAL_VOLATILITY_PIVOT: public INDICATOR{
      public:
         SIGNAL_VOLATILITY_PIVOT(){
            name = "SIGNAL_VOLATILITY_PIVOT";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "atr_range:double = [98 - 102,1][=100];",
               "ima_range:double = [8-12,0.5][=10];",
               "atr_factor:double = [2-4,0.5][=3];",
               "DeltaPrice:double = [26-34,1][=30];",
               "Mode:int = [0,1][=0];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_VOLATILITY_PIVOT::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StrToInteger(args.Get(0));
      double atr_range = StrToDouble(args.Get(1));
      double ima_range = StrToDouble(args.Get(2));
      double atr_factor = StrToDouble(args.Get(3));
      int DeltaPrice = TruePointValue(StrToInteger(args.Get(4)));
      int Mode = StrToInteger(args.Get(5));
    
    int limit = 13;
    int i;

      double DeltaStop;
      double TrStop[];
      double ATR[];
      ArrayResize(ATR, limit);
      ArrayResize(TrStop, limit);

      for(i = 0; i < limit; i ++){
         ATR[i] = iATR(NULL,timeFrame,(int) atr_range,i);
      }
   
      for(i = limit - 2; i >= 0; i --) {
        if (Mode == 0) {
            DeltaStop = iMAOnArray(ATR,0,ima_range,0,MODE_EMA,i) * atr_factor;
            //DeltaStop = iATR(NULL,0,atr_range,i) * atr_factor;
        } else {
            DeltaStop = DeltaPrice*Point;
        }
   
         if (Close[i] == TrStop[i + 1]) {
            TrStop[i] = TrStop[i + 1];
         } else {
            if (Close[i+1]<TrStop[i+1] && Close[i]<TrStop[i+1]) {
               TrStop[i] = MathMin(TrStop[i + 1], Close[i] + DeltaStop);
            } else {
               if (Close[i+1]>TrStop[i+1] && Close[i]>TrStop[i+1]) {
                  TrStop[i] = MathMax(TrStop[i+1], Close[i] - DeltaStop);         
               } else {
                  if (Close[i] > TrStop[i+1]) TrStop[i] = Close[i] - DeltaStop; else TrStop[i] = Close[i] + DeltaStop;
               }
            }
         }
      }
      
      if(TrStop[2] < Close[2] && TrStop[1] <= Close[1] && TrStop[2] != TrStop[1])
         result = BUY_SIGNAL;
      else if(TrStop[2] > Close[2] && TrStop[1] >= Close[1] && TrStop[2] != TrStop[1])
         result = SELL_SIGNAL;
      
      return result;
 }
 
 //END Volatility_Pivot SIGNAL
 
 
 //START ZigZag SIGNAL
 
 class SIGNAL_ZIGZAG: public INDICATOR{
      public:
         SIGNAL_ZIGZAG(){
            name = "SIGNAL_ZIGZAG";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "ExtDepth:int = [10-14,1][=12];",
               "ExtDeviation:int = [3-7,1][=5];",
               "ExtBackstep:int = [2-4,1][=3];",
               "ExtS:int = [2-4,1][=3];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_ZIGZAG::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int ExtDepth = StringToInteger(args.Get(1));
      int ExtDeviation = StringToInteger(args.Get(2));
      int ExtBackstep = StringToInteger(args.Get(3));
      int ExtS = StringToInteger(args.Get(4));
      
      
      double nextIsS = 0;
      for(int i = 0; i < ExtDepth + 13; i++){
         double sRes = iCustom(
            l5Symbol,           
            timeFrame,                                              
            "ZigZag",             
            ExtDepth, ExtDeviation, ExtBackstep,                           
            0,
            i
         );
         
         if(nextIsS != 0){
            if(sRes > nextIsS && Bid <= nextIsS)
            {
               result = BUY_SIGNAL;
            }
            else if(sRes < nextIsS && Bid >= nextIsS)
            {
               result = SELL_SIGNAL;
            }
            
            break;
         }
         
         if(sRes != 0 && i >= ExtS){
            nextIsS = sRes;
         }
         else if(sRes != 0)
            break;
      }
      
      return result;
 }
 
 //END ZigZag SIGNAL
 
 //HEIKEN_ASHI_SIGNAL
 class HEIKEN_ASHI_SIGNAL: public INDICATOR{
      public:
         HEIKEN_ASHI_SIGNAL(){
            name = "HEIKEN_ASHI_SIGNAL";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
              "timeFrame:int = [%TIME_FRAME%]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int HEIKEN_ASHI_SIGNAL::Perform(){
      int result = VOID_SIGNAL;
      int timeframe = StringToInteger(args.Get(0));
     
      double haOpen, haHigh, haLow, haClose;
      int countedBars = 27;
      double ExtMapBuffer1[], ExtMapBuffer2[], ExtMapBuffer3[], ExtMapBuffer4[], trend[];
      
      ArrayResize(ExtMapBuffer1, countedBars + 10);
      ArrayFill(ExtMapBuffer1, 0, countedBars + 10, 0);
      ArrayResize(ExtMapBuffer2, countedBars + 10);
      ArrayFill(ExtMapBuffer2, 0, countedBars + 10, 0);
      ArrayResize(ExtMapBuffer3, countedBars + 10);
      ArrayFill(ExtMapBuffer3, 0, countedBars + 10, 0);
      ArrayResize(ExtMapBuffer4, countedBars + 10);
      ArrayFill(ExtMapBuffer4, 0, countedBars + 10, 0);
      ArrayResize(trend, countedBars + 10);
      ArrayFill(trend, 0, countedBars + 10, 0);
       
      int pos=countedBars-1;
      while(pos>=0)
      {
         double op = iOpen(l5Symbol, timeframe, pos);
         double cl = iClose(l5Symbol, timeframe, pos);
         double hi = iHigh(l5Symbol, timeframe, pos);
         double lo = iLow(l5Symbol, timeframe, pos);
         
         haOpen=(ExtMapBuffer3[pos+1]+ExtMapBuffer4[pos+1])/2;
         haClose=(op+hi+lo+cl)/4;
         haHigh=MathMax(hi, MathMax(haOpen, haClose));
         haLow=MathMin(lo, MathMin(haOpen, haClose));
         if (haOpen<haClose) 
           {
            trend[pos]=1;
            ExtMapBuffer1[pos]=haLow;
            ExtMapBuffer2[pos]=haHigh;
           } 
         else
           {
            trend[pos]=-1;
            ExtMapBuffer1[pos]=haHigh;
            ExtMapBuffer2[pos]=haLow;
           } 
         ExtMapBuffer3[pos]=haOpen;
         ExtMapBuffer4[pos]=haClose;
    	   pos--;
      }
   
     //interpretation
     if( trend[2]<0 && trend[1]>0 && iVolume(l5Symbol, timeframe, 0) >1)
	  {
	      result = BUY_SIGNAL;
	  } 
	 	  
	  if( trend[2]>0 && trend[1]<0 && iVolume(l5Symbol, timeframe, 0)>1)
	  {
	     result = SELL_SIGNAL;
	  } 	      
   
      return result;
 }
 //END HEIKEN_ASHI_SIGNAL
 
 //MTF Forex freedom Bar
 
 class MTF_FOREX_FREEDOM_SIGNAL: public INDICATOR{
      public:
         MTF_FOREX_FREEDOM_SIGNAL(){
            name = "MTF_FOREX_FREEDOM_SIGNAL";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "gap:int = [1-5,1][=1]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int MTF_FOREX_FREEDOM_SIGNAL::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int gap = StringToInteger(args.Get(1));
      
      double r1 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 0, 0);
      double r2 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 1, 0);
      double r3 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 2, 0);
      double r4 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 3, 0);
      double r5 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 4, 0);
      double r6 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 5, 0);
      double r7 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 6, 0);
      double r8 = iCustom(l5Symbol, timeFrame, "#MTF Forex freedom Bar", gap, 7, 0);
      
      if(r1 != 0 && r3 != 0 && r5 != 0 && r7 != 0)
         result = SELL_SIGNAL;
      if(r2 != 0 && r4 != 0 && r6 != 0 && r8 != 0)
         result = BUY_SIGNAL;
         
      return result;
 }
 
 //END MTF Forex freedom Bar
 
 //RSIXover
 
  class SIGANL_RSI_XOVER: public INDICATOR{
      public:
         SIGANL_RSI_XOVER(){
            name = "SIGANL_RSI_XOVER";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];"
               "RSISlow:int = [2-6,1][=4];",
               "RSIFast:int = [5-9,1][=7];",
               "RSIType:int = [5-7,1][=6]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGANL_RSI_XOVER::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int RSISlow = StringToInteger(args.Get(1));
      int RSIFast = StringToInteger(args.Get(2));
      int RSIType = StringToInteger(args.Get(3));
      
      int count = 0;
      do{
         double r1 =  iCustom(l5Symbol,timeFrame,"[i]2RSIXover", RSISlow, RSIFast, RSIType, 0, count);
         double r2 =  iCustom(l5Symbol,timeFrame,"[i]2RSIXover", RSISlow, RSIFast, RSIType, 1, count);
        
         if(r1 != EMPTY_VALUE)
            result = SELL_SIGNAL;
         else if(r2 != EMPTY_VALUE)
            result = BUY_SIGNAL;
            
         if(result != VOID_SIGNAL)
            break;
            
         count++;
      }while(count < Bars);
      
      return result;
 }
 
 //End MA RSIXover
 
 //Silver Trend
 
  class SIGNAL_SILVER_TREND: public INDICATOR{
      public:
         SIGNAL_SILVER_TREND(){
            name = "SIGNAL_SILVER_TREND";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "RISK:int = [2-4,1][=3];",
               "countBars:int = [=1500];",
               "SSP:int = [7-11,1][=9];",
               "useClose:int = [0,1][=0]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_SILVER_TREND::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int RISK = StringToInteger(args.Get(1));
      int countBars = StringToInteger(args.Get(2));
      int SSP = StringToInteger(args.Get(3));
      int useClose = StringToInteger(args.Get(4));
      
      int count = 0;
      do{
         double r1 =  iCustom(l5Symbol,timeFrame,"[i]SilverTrend_Ron_MT4_v02", RISK, countBars, SSP, useClose, 0, count);
         double r2 =  iCustom(l5Symbol,timeFrame,"[i]SilverTrend_Ron_MT4_v02", RISK, countBars, SSP, useClose,  1, count);
        
         if(r1 != 0)
            result = BUY_SIGNAL;
         else if(r2 != 0)
            result = SELL_SIGNAL;
            
         if(result != VOID_SIGNAL)
            break;
            
         count++;
      }while(count < Bars);
      
      return result;
 }
 
 //End Silver Trend

 //SDX_ZoneBreakout
 
 class SIGNAL_SDX_ZONE_BREAKOUT: public INDICATOR{
      public:
         SIGNAL_SDX_ZONE_BREAKOUT(){
            name = "SIGNAL_SDX_ZONE_BREAKOUT";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "DoEntryAlerts:int = [=0];",
               "TimeZoneOfData:int = [2,3,4][=3];",
               "PipsForEntry:int = [4-6,1][=5];",
               "PipsTarget:int = [78-82,1][=80];",
               "PipsStop:int = [48-52,1][=50]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
 int SIGNAL_SDX_ZONE_BREAKOUT::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int DoEntryAlerts = StringToInteger(args.Get(1));
      int TimeZoneOfData = StringToInteger(args.Get(2));
      int PipsForEntry = StringToInteger(args.Get(3));
      int PipsTarget = StringToInteger(args.Get(4));
      int PipsStop = StringToInteger(args.Get(5));
      
      static double lastupper = 0;
      static double lastlower = 0;
      static int barlower = 0;
      static int barupper = 0;
      double upper =  iCustom(l5Symbol,timeFrame,"[INDI]_SDX-ZoneBreakout-Lud-Z1-v2", DoEntryAlerts, TimeZoneOfData, PipsForEntry, PipsTarget, PipsStop, 6, 0);
      double lower =  iCustom(l5Symbol,timeFrame,"[INDI]_SDX-ZoneBreakout-Lud-Z1-v2", DoEntryAlerts, TimeZoneOfData, PipsForEntry, PipsTarget, PipsStop, 7, 0);
      
      barlower++;
      barupper++;
      
      if(upper){
         barupper = 0;
         lastupper = upper;
      }
      if(lower){
         barlower = 0;
         lastlower = lower;
      }
       
      if(barupper <= barlower){
         if(lastupper != 0 && Bid <= lastupper)
            result = SELL_SIGNAL;
      }
      else if(lastupper != 0 && Bid <= lastlower && lastlower != 0)
         result = SELL_SIGNAL;
      
      if(barlower <= barupper){
          if(lastlower != 0 && Bid >= lastlower)
            result = BUY_SIGNAL;
      }
      else if(lastlower != 0 && Bid >= lastupper && lastupper)
         result = BUY_SIGNAL;
       
      return result;
 }
 
 //END SDX_ZoneBreakout
 
 //Dyn All Levels
 
 class SIGNAL_DYN_ALL_LEVELS: public INDICATOR{
      public:
         SIGNAL_DYN_ALL_LEVELS(){
            name = "SIGNAL_DYN_ALL_LEVELS";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_DYN_ALL_LEVELS::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      
      double lblue =  iCustom(l5Symbol,timeFrame,"^Dyn_AllLevels", 0, 0);
      double lred =  iCustom(l5Symbol,timeFrame,"^Dyn_AllLevels", 1, 0);
      
      if(Bid >= lblue)
         result = BUY_SIGNAL;
      else if(Bid <= lred)
         result = SELL_SIGNAL;
      
      return result;
 }
 
//END Dyn All Levels
 
 class SIGNAL_EF_DISTANCE: public INDICATOR{
      public:
         SIGNAL_EF_DISTANCE(){
            name = "SIGNAL_EF_DISTANCE";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "length:int = [7-13,1][=10];",
               "power:double = [2-4,0.5][=2]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_EF_DISTANCE::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int length = StringToInteger(args.Get(1));
      double power = StringToDouble(args.Get(2));
      
      double r =  iCustom(l5Symbol,timeFrame,"_i_EF_distance", length, power, 0, 0);
      if(Close[1] < r && Open[1] < r)
         result = BUY_SIGNAL;
      if(Close[1] > r && Open[1] > r)
         result = SELL_SIGNAL;
         
      return result;
 }
 
 //END SIGNAL EF DISTANCE
 
 //3D Oscilator SIGNAL
 
 class SIGNAL_3D_OSCILATOR: public INDICATOR{
      public:
         SIGNAL_3D_OSCILATOR(){
            name = "SIGNAL_3D_OSCILATOR";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "accountedDistance:int = [2-4,1][=3];",
               "optimalLine:int = [0-2,1][=0];",
               "D1RSIPer:int = [12-14,1][=13];",
               "D2StochPer:int = [7-9,1][=8];",
               "D3tunnelPer:int = [7-9,1][=8];",
               "hot:double = [0.2-0.6,0.1][=0.4];",
               "sigsmooth:int = [3-5,1][=4]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_3D_OSCILATOR::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int accountedDistance = StringToInteger(args.Get(1));
      int optimalLine = StringToInteger(args.Get(2));
      int D1RSIPer = StringToInteger(args.Get(3));
      int D2StochPer = StringToInteger(args.Get(4));
      int D3tunnelPer = StringToInteger(args.Get(5));
      double hot = StringToDouble(args.Get(6));
      int sigsmooth = StringToInteger(args.Get(7));
      
      int i = 0;
      double prevR1 = 0, prevR2 = 0;
      while(i < Bars - 1){
         double r1 =  iCustom(l5Symbol,timeFrame,"3D Oscilator", D1RSIPer, D2StochPer, D3tunnelPer, hot, sigsmooth, 0, i);
         double r2 =  iCustom(l5Symbol,timeFrame,"3D Oscilator", D1RSIPer, D2StochPer, D3tunnelPer, hot, sigsmooth, 1, i);
      
         if((prevR1 < prevR2 && r1 >= r2) || (prevR1 > prevR2 && r1 <= r2))
            break;
         prevR1 = r1;
         prevR2 = r2;
         i++;
      }
    
      if(i < accountedDistance)
      {
         if(prevR1 < prevR2 && prevR1 > optimalLine && prevR2 > optimalLine)
            result = SELL_SIGNAL;
         else if(prevR1 > prevR2 && prevR1 < -optimalLine && prevR2 < -optimalLine)
            result = BUY_SIGNAL; 
      }
      
      return result;
 }
 
 //END 3D Oscilator
 
 //SIGNAL_4_Trendlines_MKS
 
 class SIGNAL_4_Trendline_MKS: public INDICATOR{
      public:
         SIGNAL_4_Trendline_MKS(){
            name = "SIGNAL_4_Trendline_MKS";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "distance:int = [5-15,1][=10];"
            );
            
            NoByTimeframes();
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
 int SIGNAL_4_Trendline_MKS::Perform(){
      int result = VOID_SIGNAL;
      int distance = StringToInteger(args.Get(0));
      
      double r =  iCustom(l5Symbol,PERIOD_M15,"4_Trendline_v3-MKS", distance, 0, 0);
      if(r == -1)
         result = SELL_SIGNAL;
      else if(r == 1)
         result = BUY_SIGNAL;
      
      return result;
 }
 
 //END SIGNAL_4_TrendLines_MKS
 
 //AFSTAR SIGNAL
 class SIGNAL_AFSTAR: public INDICATOR{
      public:
         SIGNAL_AFSTAR(){
            name = "SIGNAL_AFSTAR";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "StartFast:int = [1-4,1][=3];",
               "EndFast:double = [3-4,0.5][=3.5][where(this > StartFast)];",
               "StartSlow:int = [7-9,1][=8];",
               "EndSlow:int = [8-10,1][=9][where(this > StartSlow)];",
               "StepPeriod:double = [0.1-0.3,0.1][=0.2];",
               "StartRisk:int = [0-2,1][=1];",
               "EndRisk:double = [2.7,2.8,2.9][=2.8]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_AFSTAR::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int StartFast = StringToInteger(args.Get(1));
      double EndFast = StringToDouble(args.Get(2));
      int StartSlow = StringToInteger(args.Get(3));
      int EndSlow = StringToInteger(args.Get(4));
      double StepPeriod = StringToDouble(args.Get(5));
      int StartRisk = StringToInteger(args.Get(6));
      double EndRisk = StringToDouble(args.Get(7));
      
      double r1 =  iCustom(l5Symbol,timeFrame,"AFStar1", StartFast, EndFast, StartSlow, EndSlow, StepPeriod, StartRisk, EndRisk, 0, 0);
      double r2 =  iCustom(l5Symbol,timeFrame,"AFStar1", StartFast, EndFast, StartSlow, EndSlow, StepPeriod, StartRisk, EndRisk, 1, 0);
      
      if(r1 != 0)
         result = SELL_SIGNAL;
      else if(r2 != 0)
         result = BUY_SIGNAL;
      
      return result;
 }

 //END AFSTAR_SIGNAL
 
 //SIGNAL ATR CHANELS
 
 class SIGNAL_ATR_CHANNELS: public INDICATOR{
      public:
         SIGNAL_ATR_CHANNELS(){
            name = "SIGNAL_ATR_CHANNELS";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "PeriodsATR:int = [17-19,1][=18];",
               "MA_Periods:int = [48-50,1][=49];",
               "MA_type:int = [0-3,1][=3];",
               "Mult_Factor1:double = [1.5-1.7,0.1][=1.6];",
               "Mult_Factor2:double = [3.1-3.3,0.1][=3.2];",
               "Mult_Factor3:double = [4.7-4.9,0.1][=4.8]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
 int SIGNAL_ATR_CHANNELS::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int PeriodsATR = StringToInteger(args.Get(1));
      int MA_Periods = StringToInteger(args.Get(2));
      int MA_type = StringToInteger(args.Get(3));
      double Mult_Factor1 = StringToDouble(args.Get(4));
      double Mult_Factor2 = StringToDouble(args.Get(5));
      double Mult_Factor3 = StringToDouble(args.Get(6));
      
      double r1 =  iCustom(l5Symbol,timeFrame,"ATR Channels", PeriodsATR, MA_Periods, MA_type, Mult_Factor1, Mult_Factor2, Mult_Factor3, 1, 0);
      double r2 =  iCustom(l5Symbol,timeFrame,"ATR Channels", PeriodsATR, MA_Periods, MA_type, Mult_Factor1, Mult_Factor2, Mult_Factor3, 5, 0);
      
      if(Ask > r1)
         result = SELL_SIGNAL;
      else if(Ask < r2)
         result = BUY_SIGNAL;
       
      return result;
 }
 
 //END SIGNAL ATR CHANELS
 
 //BullsBearsEyesSignal

class SIGNAL_BULLS_BEARS_EYES: public INDICATOR{
      public:
         SIGNAL_BULLS_BEARS_EYES(){
            name = "SIGNAL_BULLS_BEARS_EYES";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "periods:int = [11-15,1][=13];",
               "timeperiods:int = [=0];",
               "gamma:double = [0.4-0.8,0.1][=0.6]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_BULLS_BEARS_EYES::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int periods = StringToInteger(args.Get(1));
      int timeperiods = StringToInteger(args.Get(2));
      double gamma = StringToDouble(args.Get(3));
      
      double r0 =  iCustom(l5Symbol,timeFrame,"BullsBearsEyes(28AUG05)", periods, timeperiods, gamma, 0, 0);
      double r1 =  iCustom(l5Symbol,timeFrame,"BullsBearsEyes(28AUG05)", periods, timeperiods, gamma, 0, 1);
      if((r0 + r1) / 2 > 0.75 && r0 < r1){
         result = SELL_SIGNAL;
      }
      if((r0 + r1) / 2 < 0.25 && r0 > r1){
         result = BUY_SIGNAL;
      }
      
      return result;
 }
 
 //EndBullsBearsEyesSignal
 
 //SIGNAL DFC Next
 class SIGNAL_DFC_NEXT: public INDICATOR{
      public:
         SIGNAL_DFC_NEXT(){
            name = "SIGNAL_DFC_NEXT";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "Fibo_Channel_Period:int = [2-4,1][=3];",
               "Ratio:double = [0.78-0.79,0.01][=0.786]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_DFC_NEXT::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int Fibo_Channel_Period = StringToInteger(args.Get(1));
      double Ratio = StringToDouble(args.Get(2));
      
      double r1 =  iCustom(l5Symbol,timeFrame,"DFC Next", Fibo_Channel_Period, Ratio, 0, 1);
      double r2 =  iCustom(l5Symbol,timeFrame,"DFC Next", Fibo_Channel_Period, Ratio, 1, 1);
      
      if(r1 != 0 && r2 != 0){
         if(High[1] > r1){
            result = BUY_SIGNAL;
         }
         else if(Low[1] < r2)
         {
            result = SELL_SIGNAL;
         }
      }
      
      return result;
 }
 
 //END DFC Next Signal
 
 // DIVERGENCE SIGNAL
 class DIVERGENCE_SIGNAL : public INDICATOR{
      public:
         DIVERGENCE_SIGNAL(){
            name = "DIVERGENCE_SIGNAL";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "ind:int = [1-4,1][=3];",
               "optimalDistanceToSignal:int = [4-9,1][=7];",
               "pds:int = [=10];",
               "price_field:int = [1,2][=1];",
               "Ch:int = [0,1][=0]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int DIVERGENCE_SIGNAL::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int ind = StringToInteger(args.Get(1));
      int optimalDistanceToSignal = StringToInteger(args.Get(2));
      int pds = StringToInteger(args.Get(3));
      int price_field = StringToInteger(args.Get(4));
      int ch = StringToInteger(args.Get(5));
      
      int i = 0;
      double r1 = 0, r2 = 0;
      while(i < Bars - 1 && i < optimalDistanceToSignal){
         r1 =  iCustom(l5Symbol,timeFrame,"Divergence", ind, pds, price_field, ch, 2, i);
         r2 =  iCustom(l5Symbol,timeFrame,"Divergence", ind, pds, price_field, ch, 3, i);
         if(r1 != 0 || r2 != 0)
            break;
            
         i++;
      }
      
      if(r1 - r2 > 0 && Bid < Low[i])
         result = BUY_SIGNAL;
      else if(r1 - r2 < 0 && Bid > High[i])
         result = SELL_SIGNAL;
      
      return result;
 }
 
 //END DIVERGENCE SIGNAL
 
 //SIGNAL ICWR
 class SIGNAL_ICWR: public INDICATOR{
      public:
         SIGNAL_ICWR(){
            name = "SIGNAL_ICWR";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];"
               "optimalDistance:int = [2-7,1][=3];",
               "ExtDepth:int = [9-11,1][=10];",
               "ExtDeviation:int = [4,5,6][=5];",
               "ExtBackstep:int = [2,3,4][=3]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_ICWR::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      double optimalDistance = CalculatePoint(StringToInteger(args.Get(1)));
      int ExtDepth = StringToInteger(args.Get(2));
      int ExtDeviation = StringToInteger(args.Get(3));
      int ExtBackstep = StringToInteger(args.Get(4));
      
      iCustom(l5Symbol,timeFrame,"ICWR.a", ExtDepth, ExtDeviation, ExtBackstep, 0, 0);
      double p1 = ObjectGet("ActiveWaveICWR", OBJPROP_PRICE1);
      double p2 = ObjectGet("ActiveWaveICWR", OBJPROP_PRICE2);

      double f1 = ObjectGet("FiboICWR", OBJPROP_FIRSTLEVEL+0);
      double f2 = ObjectGet("FiboICWR", OBJPROP_FIRSTLEVEL+1);
      double f3 = ObjectGet("FiboICWR", OBJPROP_FIRSTLEVEL+2);
      double f4 = ObjectGet("FiboICWR", OBJPROP_FIRSTLEVEL+3);
      double f5 = ObjectGet("FiboICWR", OBJPROP_FIRSTLEVEL+4);
      double f6 = ObjectGet("FiboICWR", OBJPROP_FIRSTLEVEL+5);
      
     if(p1 < p2){
         double unit = p2 - p1;
         double p = p1;
         if(MathAbs(p - Bid) < optimalDistance ||
            MathAbs(p + unit * f2 - Bid) < optimalDistance ||
            MathAbs(p + unit * f3 - Bid) < optimalDistance)
              result = BUY_SIGNAL;
         if(MathAbs(p + unit * f4 - Bid) < optimalDistance ||
            MathAbs(p + unit * f5 - Bid) < optimalDistance ||
            MathAbs(p + unit * f6 - Bid) < optimalDistance)
              result = SELL_SIGNAL; 
     }
     
     if(p2 < p1){
         double unit = p1 - p2;
         double p = p1;
         if(MathAbs(p - Bid) < optimalDistance ||
            MathAbs(p - unit * f2 - Bid) < optimalDistance ||
            MathAbs(p - unit * f3 - Bid) < optimalDistance)
              result = SELL_SIGNAL;
         if(MathAbs(p - unit * f4 - Bid) < optimalDistance ||
            MathAbs(p - unit * f5 - Bid) < optimalDistance ||
            MathAbs(p - unit * f6 - Bid) < optimalDistance)
              result = BUY_SIGNAL; 
     }
      
      
     return result;
 }
 
 //END SIGNAL ICWR
 
 //SIGNAL_JMA
 
 class SIGNAL_JMA: public INDICATOR {
      public:
         SIGNAL_JMA(){
            name = "SIGNAL_JMA";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "Periods:int = [1,4,7,9,11,14,16][=14];",
               "PriceType:int = [0-6,1][=0];",
               "Offset:int = [0-2,1][=0];",
               "phase:int = [-150-150,50][=0]"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
 int SIGNAL_JMA::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int Periods = StringToInteger(args.Get(1));
      int PriceType = StringToInteger(args.Get(2));
      int Offset = StringToInteger(args.Get(3));
      int phase = StringToInteger(args.Get(4));
      
      double r1= iCustom(l5Symbol,timeFrame,"JMA_v2", Periods, PriceType, Offset, phase, 0, 0);
      double r2 = iCustom(l5Symbol,timeFrame,"JMA_v2", Periods, PriceType, Offset, phase, 0, 1);
      
      if(r2 < Close[1] && Bid > r1){
         result = BUY_SIGNAL;
      }
      else if(r2 > Close[1] && Bid < r1){
         result = SELL_SIGNAL;
      }
      
      return result;
 }
 
 //END SIGNAL_JMA
 
 //SIGNAL PATTERN RECOGINTION
 
 class SIGNAL_PATTERN_RECOGNITION: public INDICATOR{
      public:
         SIGNAL_PATTERN_RECOGNITION(){
            name = "SIGNAL_PATTERN_RECOGNITION";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "optimalShift:int = [2-8,1][=5];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_PATTERN_RECOGNITION::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int optimalShift = StringToInteger(args.Get(1));
      
      int i = 0;
      while(i < Bars && i < optimalShift){
         double r1 =  iCustom(l5Symbol,timeFrame,"Pattern Recognition", 0, i);
         double r2 =  iCustom(l5Symbol,timeFrame,"Pattern Recognition", 1, i);
         if(r1 != EMPTY_VALUE)
         {
            result = SELL_SIGNAL;
            break;
         }
         if(r2 != EMPTY_VALUE){
            result = BUY_SIGNAL;
            break;
         }
         i++;
      }
     
      return result;
 }
 
 //END PATTERN RECOGINTION SIGNAL
 
 
 //SIGNAL PIVOT RANGE

 class SIGNAL_PIVOT_RANGE: public INDICATOR{
      public:
         SIGNAL_PIVOT_RANGE(){
            name = "SIGNAL_PIVOT_RANGE";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "optimalDistance:int = [2-10,1][=4];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_PIVOT_RANGE::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      double optimalDistance = CalculatePoint(StringToInteger(args.Get(1)));
      
      double h =  iCustom(l5Symbol,timeFrame,"Pivot Range", 3, 0);
      double l =  iCustom(l5Symbol,timeFrame,"Pivot Range", 4, 0);
      double m =  iCustom(l5Symbol,timeFrame,"Pivot Range", 0, 0);
      if(MathAbs(h - Bid) < optimalDistance)
         result = SELL_SIGNAL;
      else if(MathAbs(l - Bid) < optimalDistance)
         result = BUY_SIGNAL;
      else{
         if(MathAbs(m - Bid) < optimalDistance){
            if(Close[1] > m && Close [2] > m && Close [3] > m && Close[4] > m)
               result = BUY_SIGNAL;
            else if(Close[1] < m && Close [2] < m && Close [3] < m && Close[4] < m)
               result = SELL_SIGNAL;  
         }
      }
      
      return result;
 }
 
 //END SIGNAL PIVOT RANGE

//SIGNAL TREND CONTINUATION
 
class SIGNAL_TREND_CONTINUATION: public INDICATOR{
      public:
         SIGNAL_TREND_CONTINUATION(){
            name = "SIGNAL_TREND_CONTINUATION";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "optimalShift:int = [2-8,1][=5];",
               "n:int = [18-22,1][=20];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_TREND_CONTINUATION::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int optimalShift = StringToInteger(args.Get(1));
      int n = StringToInteger(args.Get(2));
      
      int i = 0;
      double prevR1 = 0; double prevR2 = 0;
      while(i < Bars && i < optimalShift){
         double r1 =  iCustom(l5Symbol,timeFrame,"TrendContinuation", n,  0, i);
         double r2 =  iCustom(l5Symbol,timeFrame,"TrendContinuation", n,  1, i);
         if(!prevR1 || !prevR2)
         {
            prevR1 = r1;
            prevR2 = r2;
            continue;
         }
         if(prevR1 > prevR2 && r1 < r2){
            result = BUY_SIGNAL;
            break;
         }
         else if(prevR1 < prevR2 && r1 > r2){
            result = SELL_SIGNAL;
            break;
         }
         
         i++;
      }
     
      return result;
 }
 
 //END SIGNAL_TREND_CONTINUATION
 
 //SIGNAL_WSOWROTrend
 class SIGNAL_WSOWROTrend: public INDICATOR{
      public:
         SIGNAL_WSOWROTrend(){
            name = "SIGNAL_WSOWROTrend";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "optimalDistance:int = [2-10,1][=4];",
               "nPeriod:int = [6-12,1][=9];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_WSOWROTrend::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      double optimalDistance = CalculatePoint(StringToInteger(args.Get(1)));
      int nPeriod = StringToInteger(args.Get(2));
      
      iCustom(l5Symbol,timeFrame,"WSOWROTrend", nPeriod, 0, 0);
      double s1 = ObjectGet("WSOwsowrotrend-1", OBJPROP_PRICE1);
      double s2 = ObjectGet("WSOwsowrotrend-2", OBJPROP_PRICE1);
      double s3 = ObjectGet("WSOwsowrotrend-3", OBJPROP_PRICE1);
      double s4 = ObjectGet("WSOwsowrotrend-4", OBJPROP_PRICE1);
      double s5 = ObjectGet("WSOwsowrotrend-5", OBJPROP_PRICE1);
      
      double r1 = ObjectGet("WROwsowrotrend-1", OBJPROP_PRICE1);
      double r2 = ObjectGet("WROwsowrotrend-2", OBJPROP_PRICE1);
      double r3 = ObjectGet("WROwsowrotrend-3", OBJPROP_PRICE1);
      double r4 = ObjectGet("WROwsowrotrend-4", OBJPROP_PRICE1);
      double r5 = ObjectGet("WROwsowrotrend-5", OBJPROP_PRICE1);
      
      double td1 = ObjectGetValueByShift("Trend DN wsowrotrend-1", 0);
      double td2 = ObjectGetValueByShift("Trend DN wsowrotrend-2", 0);
      double td3 = ObjectGetValueByShift("Trend DN wsowrotrend-3", 0);
      double td4 = ObjectGetValueByShift("Trend DN wsowrotrend-4", 0);
      double tu1 = ObjectGetValueByShift("Trend UP wsowrotrend-1", 0);
      double tu2 = ObjectGetValueByShift("Trend UP wsowrotrend-2", 0);
      double tu3 = ObjectGetValueByShift("Trend UP wsowrotrend-3", 0);
      double tu4 = ObjectGetValueByShift("Trend UP wsowrotrend-4", 0);
     
      bool s = false, b = false;
      if(
         MathAbs(Bid - td1) <= optimalDistance || 
         MathAbs(Bid - td2) <= optimalDistance ||
         MathAbs(Bid - td3) <= optimalDistance ||
         MathAbs(Bid - td4) <= optimalDistance) 
            b = true;
     if(MathAbs(Bid - tu1) <= optimalDistance || 
         MathAbs(Bid - tu2) <= optimalDistance ||
         MathAbs(Bid - tu3) <= optimalDistance ||
         MathAbs(Bid - tu4) <= optimalDistance)
            s = true;
       
      if(MathAbs(Bid - s1) <= optimalDistance && Close[1] < s1 && Close [2] < s1 && Close[3] < s1)
         s = true;
      if(MathAbs(Bid - s2) <= optimalDistance && Close[1] < s2 && Close [2] < s2 && Close[3] < s2)
         s = true;    
      if(MathAbs(Bid - s3) <= optimalDistance && Close[1] < s3 && Close [2] < s3 && Close[3] < s3)
         s = true;
      if(MathAbs(Bid - s4) <= optimalDistance && Close[1] < s4 && Close [2] < s4 && Close[3] < s4)
         s = true;
      if(MathAbs(Bid - s5) <= optimalDistance && Close[1] < s5 && Close [2] < s5 && Close[3] < s5)
         s = true;
      if(MathAbs(Bid - r1) <= optimalDistance && Close[1] < r1 && Close [2] < r1 && Close[3] < r1)
         s = true;
      if(MathAbs(Bid - r2) <= optimalDistance && Close[1] < r2 && Close [2] < r2 && Close[3] < r2)
         s = true;    
      if(MathAbs(Bid - r3) <= optimalDistance && Close[1] < r3 && Close [2] < r3 && Close[3] < r3)
         s = true;
      if(MathAbs(Bid - r4) <= optimalDistance && Close[1] < r4 && Close [2] < r4 && Close[3] < r4)
         s = true;
      if(MathAbs(Bid - r5) <= optimalDistance && Close[1] < r5 && Close [2] < r5 && Close[3] < r5)
         s = true; 
          
      if(MathAbs(Bid - r1) <= optimalDistance && Close[1] > r1 && Close [2] > r1 && Close[3] > r1)
         b = true;
      if(MathAbs(Bid - r2) <= optimalDistance && Close[1] > r2 && Close [2] > r2 && Close[3] > r2)
         b = true;    
      if(MathAbs(Bid - r3) <= optimalDistance && Close[1] > r3 && Close [2] > r3 && Close[3] > r3)
         b = true;
      if(MathAbs(Bid - r4) <= optimalDistance && Close[1] > r4 && Close [2] > r4 && Close[3] > r4)
         b = true;
      if(MathAbs(Bid - r5) <= optimalDistance && Close[1] > r5 && Close [2] > r5 && Close[3] > r5)
         b = true;     
       if(MathAbs(Bid - s1) <= optimalDistance && Close[1] > s1 && Close [2] > s1 && Close[3] > s1)
         b = true;
      if(MathAbs(Bid - s2) <= optimalDistance && Close[1] > s2 && Close [2] > s2 && Close[3] > s2)
         b = true;    
      if(MathAbs(Bid - s3) <= optimalDistance && Close[1] > s3 && Close [2] > s3 && Close[3] > s3)
         b = true;
      if(MathAbs(Bid - s4) <= optimalDistance && Close[1] > s4 && Close [2] > s4 && Close[3] > s4)
         b = true;
      if(MathAbs(Bid - s5) <= optimalDistance && Close[1] > s5 && Close [2] > s5 && Close[3] > s5)
         b = true;  
        
      if(s)
         result = SELL_SIGNAL;
      if(b)
         result = BUY_SIGNAL;
      if(b && s)
         result = VOID_SIGNAL;  
         
      return result;
 }
 
 //END SIGNAL_WSOWROTrend
 
 //SIGNAL df-donchianfibo
 class SIGNAL_DONCHIANFIBO: public INDICATOR{
      public:
         SIGNAL_DONCHIANFIBO(){
            name = "SIGNAL_DONCHIANFIBO";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "donchianPeriod:int = [51-59,1][=55];",
               "optimalDistance:int = [3-10,1][=5];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_DONCHIANFIBO::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int donchianPeriod = StringToInteger(args.Get(1));
      double optimalDistance = CalculatePoint(StringToInteger(args.Get(2)));
      
      double r[7];
      
      r[0] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 0, 0);
      r[1] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 1, 0);
      r[2] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 2, 0);
      r[3] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 3, 0);
      r[4] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 4, 0);
      r[5] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 5, 0);
      r[6] =  iCustom(l5Symbol,timeFrame,"df-donchianfibo", "http://donforex.com", donchianPeriod, 6, 0);
      
      bool b = false, s = false;
      for(int i = 0; i < 7; i++){
         if(MathAbs(Bid - r[i]) < optimalDistance){
            if(Close[1] < r[i] && Close[2] < r[i] && i != 0)
               s = true;
            else if(Close[1] > r[i] && Close[2] > r[i] && i != 6)
               b = true;
         }
      }
      if(b)
         result = BUY_SIGNAL;
      else if(s)
         result = SELL_SIGNAL;
     
      if(b && s)
         result = VOID_SIGNAL;
      
      return result;
 }
 
 //END SIGNAL df-donchianfibo
 
 //SIGNAL ma_bbands
 
 class SIGNAL_MA_BBANDS: public INDICATOR{
      public:
         SIGNAL_MA_BBANDS(){
            name = "SIGNAL_MA_BBANDS";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "MoveShift:int = [11-13,1][=12];",
               "MAPeriod:int = [8-10,1][=9];",
               "OsMA:int = [2-5,1][=3];",
               "Dist2:int = [19-21,1][=20];",
               "Std:double = [0.3-0.5,0.1][=0.4];",
               "BPeriod:int = [19-21,1][=20];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
};
 
int SIGNAL_MA_BBANDS::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int MoveShift = StringToInteger(args.Get(1));
      int MAPeriod = StringToInteger(args.Get(2));
      int OsMA = StringToInteger(args.Get(3));
      int Dist2 = StringToInteger(args.Get(4));
      double Std = StringToDouble(args.Get(5));
      int BPeriod = StringToInteger(args.Get(6));
      
      double r1 =  iCustom(l5Symbol,timeFrame,"ma_bbands", MoveShift, MAPeriod, OsMA, Dist2, Std, BPeriod, 0, 0);
      double r2 =  iCustom(l5Symbol,timeFrame,"ma_bbands", MoveShift, MAPeriod, OsMA, Dist2, Std, BPeriod, 1, 0);
      
      if(Bid > r1)
         result = SELL_SIGNAL;
      else if(Bid < r2)
         result = BUY_SIGNAL;
      
      return result;
 }
 
 //END SIGNAL ma_bbands
 
 //SIGNAL BillWilliams_ATZ
 
 class SIGNAL_BillWilliams_ATZ:public INDICATOR{
      public:
         SIGNAL_BillWilliams_ATZ(){
            name = "SIGNAL_BillWilliams_ATZ";
            
            //Standart specifiaction definition
            string specification = StringConcatenate(
               "timeFrame:int = [%TIME_FRAME%];",
               "optimalShift:int = [2-7,1][=3];"
            );
            
            SetSpecification(specification);
         }
         virtual int Perform();
 };
 
int SIGNAL_BillWilliams_ATZ::Perform(){
      int result = VOID_SIGNAL;
      int timeFrame = StringToInteger(args.Get(0));
      int optimalShift = StringToInteger(args.Get(1));
      
      int i = 0;
      while(i < Bars && i < optimalShift){
         double r1 =  iCustom(l5Symbol,timeFrame,"BillWilliams_ATZ", 0, i);
         double r2 =  iCustom(l5Symbol,timeFrame,"BillWilliams_ATZ", 1, i);
         
         if(r1 != EMPTY_VALUE)
         {
            result = BUY_SIGNAL;
            break;
         }
         else if(r2 != EMPTY_VALUE){
            result = SELL_SIGNAL;
            break;
         }
         
         i++;
      }
      
      return result;
 }
 
 //END SIGNAL BillWilliams_ATZ
