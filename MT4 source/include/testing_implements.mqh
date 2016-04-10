//+------------------------------------------------------------------+
//|                                           testing_implements.mqh |
//|             Copyright 2014, Tim Jackson <webmechanicr@gmail.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Tim Jackson <webmechanicr@gmail.com>"
#property link      ""
#property strict

//+------------------------------------------------------------------+
//+               VIRTUAL OPTIMIZATION IMPLEMENTS                    +
//+------------------------------------------------------------------+

class VORDER{
   public:
      char type;
      float opening_price;
      bool is_opened;
      VORDER(){
         type = 0;
         opening_price = 0;
         is_opened = false;
     }
};

class VIRTUAL_OPTIMIZATION {
   private:
      INDICATOR* indicator;
      int indicatorIndex;
      double efficiency[];
      bool is_signalized[];
      int timeFramesOf[];
      char prevSignals[];
      VORDER orders[];
      double curStopLoss, curTakeProfit;
      bool history_loading_req;
      ulong startMoment;
      ulong lastMoment;
      ulong startMoments[];
      ulong firstMoment;
      ulong firstStartMoment;
      ulong tickEvents; 
      ulong totalTickNumber;
      string processName;
      int missingTicks[];
      ulong prevTicksBeforeMissing[];
      double averageDurationOfAsking;
      ulong sizeOfQueue;
      int mallowedTimeFrames[];
      int mtimeFramesLimit;
      int assocMtfWithTf[];
      
      int  GetSignalOf(int i);
      void VOrderClose(int sign, int i);
      void VOrderOpen(int sign, int i);
   public:
      VIRTUAL_OPTIMIZATION(string indicatorName);
      ~VIRTUAL_OPTIMIZATION();
      void Tick();
};

VIRTUAL_OPTIMIZATION::VIRTUAL_OPTIMIZATION(string indicatorName){
   indicatorIndex = -1;
   firstMoment = getTimeStamp(true);
   averageDurationOfAsking = 0;
   curStopLoss = CalculatePoint(stopLossLevel) * 1.6;
   curTakeProfit = CalculatePoint(takeProfitLevel) * 1.6;
   firstStartMoment = 0;
   processName = "Optimization_by_" + l5Symbol + "_of_" + iOIndicatorName;
   mtimeFramesLimit = 0;
   for(int tmi = 0; tmi < timeFramesLimit; tmi++){
         if(iOisUsingCertainTimeframes == ctoUseAll || (iOisUsingCertainTimeframes == ctoUseBigOnly && allowedTimeFrames[tmi] >= PERIOD_M15)
            || (iOisUsingCertainTimeframes == ctoUseSmallOnly && allowedTimeFrames[tmi] < PERIOD_M15))
            mtimeFramesLimit++;
   }
   
   if(!mtimeFramesLimit)
   {
      MessageBoxW(GetForegroundWindow(), 
                           StringConcatenate(
                              "Use all available timeframes but not big only!"
                           ),
                           "Error", 
                           MB_ICONERROR);
      ExpertRemove();
      return;
   }
   
   ArrayResize(mallowedTimeFrames, mtimeFramesLimit);
   ArrayResize(assocMtfWithTf, mtimeFramesLimit);
   for(int tmi = 0, mtmi = 0; tmi < timeFramesLimit; tmi++){
         if(iOisUsingCertainTimeframes == ctoUseAll || (iOisUsingCertainTimeframes == ctoUseBigOnly && allowedTimeFrames[tmi] >= PERIOD_M15)
            || (iOisUsingCertainTimeframes == ctoUseSmallOnly && allowedTimeFrames[tmi] < PERIOD_M15)
         ){
            mallowedTimeFrames[mtmi++] = allowedTimeFrames[tmi];
            assocMtfWithTf[mtmi - 1] = tmi;
         }
   }
   
   for(int i = 0; i < indMan.GetNumIndicators(); i++)
       if(indMan.GetIndicator(i).GetName() == iOIndicatorName){
          indicatorIndex = i;
          break;
       }
            
   if(indicatorIndex == -1)
   {
       ErrPrint("VIRTUAL OPTIMIZATION: Unknown indicator", true);
       ExpertRemove();
       return;
   }
            
   indicator = indMan.GetIndicator(indicatorIndex);
   MsgPrint("Total arguments for optimization: " + (string) indMan.GetArgQueueSize(indicatorIndex));
   
   tickEvents = 0;
   sizeOfQueue = indMan.GetArgQueueSize(indicatorIndex);
   
   ArrayResize(efficiency, indMan.GetArgQueueSize(indicatorIndex));
   ArrayFill(efficiency, 0, indMan.GetArgQueueSize(indicatorIndex), 0);
   ArrayResize(is_signalized, indMan.GetArgQueueSize(indicatorIndex));
   ArrayFill(is_signalized, 0, indMan.GetArgQueueSize(indicatorIndex), 0);
   ArrayResize(timeFramesOf, indMan.GetArgQueueSize(indicatorIndex));
   ArrayFill(timeFramesOf, 0, indMan.GetArgQueueSize(indicatorIndex), 0);
   ArrayResize(startMoments, mtimeFramesLimit);
   ArrayFill(startMoments, 0, mtimeFramesLimit, 0);
   ArrayResize(missingTicks, mtimeFramesLimit);
   ArrayFill(missingTicks, 0, mtimeFramesLimit, 0);
   ArrayResize(prevTicksBeforeMissing, mtimeFramesLimit);
   ArrayFill(prevTicksBeforeMissing, 0, mtimeFramesLimit, 0);
   ArrayResize(orders, indMan.GetArgQueueSize(indicatorIndex));
   ArrayResize(prevSignals, indMan.GetArgQueueSize(indicatorIndex));
   ArrayFill(prevSignals, 0, indMan.GetArgQueueSize(indicatorIndex), VOID_SIGNAL);

   totalTickNumber = 0;
   history_loading_req = false;
      string tester_history_meta_data = systemInfo.Get(processName + "_tester_history_meta_data", l5Symbol);
      if(StringFind(tester_history_meta_data, "_") != -1){
         string range[];
         if(StringSplit(tester_history_meta_data, StringGetChar("_", 0), range) == 4){
            ulong moment = StringToInteger(range[0]);
            ulong moment2 = StringToInteger(range[3]);
            
            if(MathAbs(getTimeStamp() - moment) > 3600 || MathAbs(firstMoment - moment2) > 86400)
               history_loading_req = true;
            else{
               lastMoment = StringToInteger(range[2]);
               totalTickNumber = StringToInteger(range[1]);
            }
         }
         else
            history_loading_req = true;
      }
      else
         history_loading_req = true;
         
      if(history_loading_req){
         MessageBoxW(GetForegroundWindow(), "The optimization requires collection of meta data before its start. So you must wait for next process end and run optimization with same parameters again.", "Notice", 0x00000000);
      }
    
    if(!history_loading_req){
         //defining start moments and timeframes indexes;
         firstStartMoment = 9999999999999;
         for(int tmi = 0; tmi < mtimeFramesLimit; tmi++){
            ulong range = mallowedTimeFrames[tmi] * iOmaxBarsForOptimization * 60;
            
            if(mallowedTimeFrames[tmi] < PERIOD_H4 && mallowedTimeFrames[tmi] >= PERIOD_H1){
               if(range > 9072000) //three and half months
                  range = 9072000;
            }
            else if(mallowedTimeFrames[tmi] < PERIOD_H1 && mallowedTimeFrames[tmi] >= PERIOD_M15){
               if(range > 5184000) //two months
                  range = 5184000;
            }
            else if(mallowedTimeFrames[tmi] < PERIOD_M15 && mallowedTimeFrames[tmi] >= PERIOD_M5){
               if(range > 2592000)
                  range = 2592000; //a month;
            }
            else if(mallowedTimeFrames[tmi] < PERIOD_M5 && mallowedTimeFrames[tmi] >= PERIOD_M1){
               if(range > 1814400)
                     range = 1814400; //three weeks;
            }else{
               if(range > 31536000) //one year
                  range = 31536000;
            }
            
            int recommendedStartMoment = lastMoment - (range);
            if(recommendedStartMoment < firstMoment){
                MessageBoxW(GetForegroundWindow(), 
                           StringConcatenate(
                              "You must increase time range for optimization!"
                           ),
                           "Error", 
                           MB_ICONERROR);
                           
                systemInfo.Set(processName + "_tester_history_meta_data", "", l5Symbol);
                ExpertRemove();
                return;
            }
            
            startMoments[tmi] = recommendedStartMoment;
            if(firstStartMoment > recommendedStartMoment)
               firstStartMoment = recommendedStartMoment;
         }
         
         if(!indicator.IsByTimeframes()){
            timeFramesOf[0] = -1;
            firstStartMoment = lastMoment - 5184000; //two months
         }
         else{
            for(int i = 0; i < sizeOfQueue; i++){
               ARG_LIST args = indMan.GetArgList(indicatorIndex, i);
               timeFramesOf[i] = StringToInteger(args.Get(0));
               bool tfound = false;
               for(int tmi = 0; tmi < timeFramesLimit; tmi++)
                  if(timeFramesOf[i] == allowedTimeFrames[tmi])
                  {
                     tfound = true;
                     break;
                  }
               if(!tfound){
                  ErrPrint("VIRTUAL OPTIMIZATION: It seems the first paramter of " + indicator.GetName() + " does not means timeframe");
                  ExpertRemove();
                  return;
               }
            }
         }
         
         if(iOmaxHoursForOptimization != 0){
            ulong len = (indicator.IsByTimeframes() && iOisUsingCertainTimeframes != ctoUseAll)?sizeOfQueue / timeFramesLimit * mtimeFramesLimit:sizeOfQueue;
            for(int i = 0; i < len; i++){
               GetSignalOf(i);
            }
            ulong st = getMilliSeconds();
            for(int i = 0; i < len; i++){
               GetSignalOf(i);
            }
            ulong durationOfOne = MathCeil(getMilliSeconds() - st) + 5;
            averageDurationOfAsking = durationOfOne / (double) 1000 / (1.1 * mtimeFramesLimit);
            int countedTickNumber = ((double) (lastMoment - firstStartMoment) / (double) (lastMoment - firstMoment)) * (double) totalTickNumber;
            ulong wh_d = ((countedTickNumber) * averageDurationOfAsking);
           
            if(iOmaxHoursForOptimization * 3600 < wh_d && averageDurationOfAsking){
               int max_missing_ticks = 0;
               int min_missing_ticks = 999999999;
               for(int tmi = 0; tmi < mtimeFramesLimit; tmi++){
                  missingTicks[tmi] = MathCeil(countedTickNumber / ((double)(iOmaxHoursForOptimization * 3600) / (double) averageDurationOfAsking)) * ((double) (mallowedTimeFrames[tmi] <= 5?1:MathCeil(mallowedTimeFrames[tmi] / 5)) / (double) mtimeFramesLimit);
                  if(max_missing_ticks < missingTicks[tmi])
                     max_missing_ticks = missingTicks[tmi];
                  if(min_missing_ticks > missingTicks[tmi])
                     min_missing_ticks = missingTicks[tmi];
               } 
               MessageBoxW(GetForegroundWindow(), 
                        "As you've set up optimization time limit some ticks will be skipped (from " + (string) min_missing_ticks + " to " + (string) max_missing_ticks + "; duration of one tick process: " + (string) + (durationOfOne) + ")", 
                        "Notice", 0x00000000);
            }
         }
     }
};

VIRTUAL_OPTIMIZATION::~VIRTUAL_OPTIMIZATION(){
      if(history_loading_req)
      {
         systemInfo.Set(processName + "_tester_history_meta_data", (string) getTimeStamp() + "_" + (string) tickEvents + "_" + (string) + getTimeStamp(true) + "_" + (string) firstMoment, l5Symbol);
         return;
      }

      //closes all opened orders
      for(int i = 0; i < sizeOfQueue; i++){
           if(orders[i].is_opened){
               if(orders[i].type == BUY_SIGNAL)
               {
                  efficiency[i] += (orders[i].opening_price - Bid);
               }
               
               if(orders[i].type == SELL_SIGNAL)
               {
                  efficiency[i] += (Ask - orders[i].opening_price);
               }
            }
        }
      
        //Saving of specification
        string specification = "";
        if(timeFramesOf[0] != 0 && timeFramesOf[0] != -1){
           for(int tmi = 0; tmi < mtimeFramesLimit; tmi++){
              double max = -999999999999999;
              int foundI = -1;
              
              for(int i = 0; i < sizeOfQueue; i++)
                     if(timeFramesOf[i] == mallowedTimeFrames[tmi] && efficiency[i] > max && is_signalized[i]){
                        max = efficiency[i];
                        foundI = i;
                     }
                     
               if(foundI != -1){
                  ARG_LIST args = indMan.GetArgList(indicatorIndex, foundI);
                  specification = indicator.BuildSpecificationByDefArgs(args, mallowedTimeFrames[tmi], specification);
                  if(specification == ""){
                     break;
                  }
               }
           }
        }
        else{
            double max = -999999999999999;
            int foundI = -1;
              
            for(int i = 0; i < indMan.GetArgQueueSize(indicatorIndex); i++)
               if(efficiency[i] > max && is_signalized[i]){
                   max = efficiency[i];
                   foundI = i;
               }
                     
               if(foundI != -1){
                  ARG_LIST args = indMan.GetArgList(indicatorIndex, foundI);
                  specification = indicator.BuildSpecificationByDefArgs(args);
               }
        }
     
    //auxiliary variant
    if(specification != "")
        MsgPrint("Calculated specification: " + specification);
            
    if(specification == ""){
       ErrPrint("VIRTUAL OPTIMIZATION: Cannot build new specification");
    }
    else if(!l5Db.ReConnect()){
       ErrPrint("VIRTUAL OPTIMIZATION: Cannot connect with MySQL in optimization");
    }
    else if(!indicator.SetSpecification(specification, l5Symbol)){
       ErrPrint("VIRTUAL OPTIMIZATION: Cannot save new specification");
    }
}

void VIRTUAL_OPTIMIZATION::Tick(){
     if(history_loading_req)
     {
         tickEvents++;
         return;
     }
    
     ulong currentTime = getTimeStamp(true);
     if(firstStartMoment && currentTime < firstStartMoment)
         return;
    
     tickEvents++;
     
     if(timeFramesOf[0] == -1){  //without timeframe
        for(int i = 0; i < sizeOfQueue; i++){
           int sign = GetSignalOf(i);
           VOrderClose(sign, i);
           VOrderOpen(sign, i);
        }
     }
     
     for(int tmi = 0; tmi < mtimeFramesLimit; tmi++){
        if(startMoments[tmi] <= currentTime){
           if(missingTicks[tmi] != 0 && (tickEvents - prevTicksBeforeMissing[tmi] <=  missingTicks[tmi]))
               continue;
           prevTicksBeforeMissing[tmi] = tickEvents;
           
           int i = assocMtfWithTf[tmi];
           do{
              int sign = GetSignalOf(i);
              VOrderClose(sign, i);
              VOrderOpen(sign, i);
              i+=timeFramesLimit;
           }while(i < sizeOfQueue);  
        }
     }
}

int VIRTUAL_OPTIMIZATION::GetSignalOf(int i){
   int result = VOID_SIGNAL; 
   ARG_LIST args = indMan.GetArgList(indicatorIndex, i);
   indicator.SetArgs(args);
   int sign = indicator.Perform();
   
   if(sign != prevSignals[i]){
      result = sign;
      prevSignals[i] = (char) sign;
      is_signalized[i] = true;
   }
   return(result);
}

void VIRTUAL_OPTIMIZATION::VOrderClose(int sign, int i){
      if(orders[i].is_opened){
         if(orders[i].type == BUY_SIGNAL && sign == SELL_SIGNAL && orders[i].opening_price - Bid >= 0)
         {
            orders[i].type = VOID_SIGNAL;
            efficiency[i] += (orders[i].opening_price - Bid);
            orders[i].opening_price = 0;
            orders[i].is_opened = false;
         }
         
         if(orders[i].type == SELL_SIGNAL && sign == BUY_SIGNAL && Ask - orders[i].opening_price >= 0)
         {
            orders[i].type = VOID_SIGNAL;
            efficiency[i] += (Ask - orders[i].opening_price);
            orders[i].opening_price = 0;
            orders[i].is_opened = false;
         }
      
         if(orders[i].is_opened){
            if(orders[i].type == BUY_SIGNAL){
               double sl = Bid - CalculatePoint(curStopLoss);
               double tp = Bid + CalculatePoint(curTakeProfit);
               
               if(orders[i].opening_price <= sl){
                  orders[i].is_opened = false;
                  orders[i].type = VOID_SIGNAL;
                  efficiency[i] += (orders[i].opening_price - Bid);
                  orders[i].opening_price = 0;
               }
               
               if(orders[i].opening_price >= tp){
                  orders[i].is_opened = false;
                  orders[i].type = VOID_SIGNAL;
                  efficiency[i] += (orders[i].opening_price - Bid);
                  orders[i].opening_price = 0;
               }
            }
            else{
               double sl = Ask + CalculatePoint(curStopLoss);
               double tp = Ask - CalculatePoint(curTakeProfit);
               
               if(orders[i].opening_price >= sl){
                  orders[i].is_opened = false;
                  orders[i].type = VOID_SIGNAL;
                  efficiency[i] += (Ask - orders[i].opening_price);
                  orders[i].opening_price = 0;
               }
               
               if(orders[i].opening_price <= tp){
                  orders[i].is_opened = false;
                  orders[i].type = VOID_SIGNAL;
                  efficiency[i] += (Ask - orders[i].opening_price);
                  orders[i].opening_price = 0;
               }
            }
         }
      }
}

void VIRTUAL_OPTIMIZATION::VOrderOpen(int sign, int i){
   if(!orders[i].is_opened){
         if(sign == BUY_SIGNAL)
         {
            orders[i].is_opened = true;
            orders[i].type = BUY_SIGNAL;
            orders[i].opening_price = (float) MarketInfo(l5Symbol, MODE_ASK);
         }
         
         if(sign == SELL_SIGNAL)
         {
            orders[i].is_opened = true;
            orders[i].type = SELL_SIGNAL;
            orders[i].opening_price = (float) MarketInfo(l5Symbol, MODE_BID);
         }
   }
}

/*
 * END VIRTUAL OPTIMIZATION IMPLEMENTS
 */


//+------------------------------------------------------------------+
//+               DEFAULT ARGUMENTS TESTING IMPLEMENTS               +
//+------------------------------------------------------------------+

class TESTING_OF_DEF_ARGS {
   private:
      INDICATOR* indicator;
      int indicatorIndex;
      double curStopLoss, curTakeProfit;
      char prevSignal;
      int timeFrameNumberInTesting;
      bool optimizeSL;
      
      int  GetSignalOf(int i);
      void VOrderClose(int sign);
      void VOrderOpen(int sign);
      
   public:
      TESTING_OF_DEF_ARGS(string indicatorName);
      ~TESTING_OF_DEF_ARGS();
      void Tick();
};

TESTING_OF_DEF_ARGS::TESTING_OF_DEF_ARGS(string indicatorName){
   indicatorIndex = -1;
   optimizeSL = iOoptimzeStopProfitLevels;
   
   for(int i = 0; i < indMan.GetNumIndicators(); i++)
       if(indMan.GetIndicator(i).GetName() == iOIndicatorName){
          indicatorIndex = i;
          break;
       }
            
   if(indicatorIndex == -1)
   {
       ErrPrint("TESTING_OF_DEF_ARGS: Unknown indicator", true);
       ExpertRemove();
       return;
   }
            
   indicator = indMan.GetIndicator(indicatorIndex);
   
   prevSignal = VOID_SIGNAL;
   
   curStopLoss = CalculatePoint(stopLossLevel) * 1.6;
   curTakeProfit = CalculatePoint(takeProfitLevel) * 1.6;
   
   
   timeFrameNumberInTesting = -1;
   for(int tmi = 0; tmi < timeFramesLimit; tmi++)
         if(allowedTimeFrames[tmi] == (iOTimeFrameNumberInTesting == 0?Period():iOTimeFrameNumberInTesting))
         {
            timeFrameNumberInTesting = tmi;
            break;
         }
   
   
   if(timeFrameNumberInTesting == -1)
   {
      ErrPrint("TESTING_OF_DEF_ARGS: Selected timeframe is not allowed in testing", true);
      ExpertRemove();
      return;
   }
  
   if(timeFrameNumberInTesting > indMan.GetArgQueueSize(indicatorIndex))
         timeFrameNumberInTesting = indMan.GetArgQueueSize(indicatorIndex); 
};

TESTING_OF_DEF_ARGS::~TESTING_OF_DEF_ARGS(){
  
}

void TESTING_OF_DEF_ARGS::Tick(){
   int sign = GetSignalOf(timeFrameNumberInTesting);
   VOrderClose(sign);
   VOrderOpen(sign);
}

int TESTING_OF_DEF_ARGS::GetSignalOf(int i){
   int result = VOID_SIGNAL; 
   ARG_LIST args = indMan.GetArgList(indicatorIndex, i);
   indicator.SetArgs(args);
   int sign = indicator.Perform();
   
   if(sign != prevSignal){
      result = sign;
      prevSignal = (char) sign;
   }
   return(result);
}

void TESTING_OF_DEF_ARGS::VOrderClose(int sign){
      int count = OrdersTotal();
      for(int i = 0; i < count; i++)
      {
         if(OrderSelect(i, SELECT_BY_POS)){
            if(OrderSymbol()== l5Symbol){
               if(OrderType() == OP_BUY && sign == SELL_SIGNAL && OrderProfit() >= 0)
                  if(OrderClose(OrderTicket(), OrderLots(), Bid, TruePointValue(tIallowedSlippage), OliveDrab)){};
               
               if(OrderType() == OP_SELL && sign == BUY_SIGNAL && OrderProfit() >= 0)
                  if(OrderClose(OrderTicket(), OrderLots(), Ask, TruePointValue(tIallowedSlippage), Salmon)){};
            }
         }
         else{
            ErrPrint("TESTING IMPLEMENTS" , ErrorDescription(GetLastError()));
         }
      }
}

void TESTING_OF_DEF_ARGS::VOrderOpen(int sign){
  if(OrdersTotal() == 0){
      if(sign == BUY_SIGNAL)
      {
         
         double sl = Bid - curStopLoss;
         double tp = Bid + curTakeProfit;
   
         if(OrderSend(l5Symbol, OP_BUY, 1, Ask, TruePointValue(tIallowedSlippage), sl, tp, NULL,
                          0, 0, Green)){};
      }
      
      if(sign == SELL_SIGNAL)
      {
         
         double sl = Ask + curStopLoss;
         double tp = Ask - curTakeProfit;
         if(OrderSend(l5Symbol, OP_SELL, 1, Bid, TruePointValue(tIallowedSlippage), sl, tp, NULL,
                          0, 0, Red)){};
      }
   }
}

/*
 * END VIRTUAL OPTIMIZATION IMPLEMENTS
 */