//+------------------------------------------------------------------+
//|                                           trading_implements.mqh |
//|                      Tim Jackson <tim.jackson.mailbox@gmail.com> |
//|                                             http://timjackson.ru |
//+------------------------------------------------------------------+
#property copyright "Tim Jackson <tim.jackson.mailbox@gmail.com>"
#property link      "http://timjackson.ru"
#property strict

//+------------------------------------------------------------------+
//+                        TRADING IMPLEMENTS                        +
//+------------------------------------------------------------------+

#ifndef __CHV
 /*
  * SOLUTION CLASS
  * The class represents data row from list of solutions
  */
  
  /*
   * SOLUTION CLASS END
   */

#endif

class ORDER_INFO{
   public:
      ulong open_time;
      ulong close_time;
      int opening_signal;
       
      bool is_opened;
      int order_ticket;
      
      int trailing_stop;
      int trailing_start;
      int limited_duration;
      
      double open_price;
      double profit;
      
      SOLUTION controllingSolution;
      
      ORDER_INFO():open_time(0),close_time(0),opening_signal(0),is_opened(0),order_ticket(0),trailing_stop(0),trailing_start(0), limited_duration(0), open_price(0), profit(0){
         
      }
      void operator=(const ORDER_INFO& right);
      ORDER_INFO(const ORDER_INFO& right);
      string ToString();
      bool FromString(string arg);
};

void ORDER_INFO::operator=(const ORDER_INFO& right){
   open_time = right.open_time;
   is_opened = right.is_opened;
   opening_signal = right.opening_signal;
   order_ticket = right.order_ticket;
   trailing_stop = right.trailing_stop;
   trailing_start = right.trailing_start;
   limited_duration = right.limited_duration;
   controllingSolution = right.controllingSolution;
   open_price = right.open_price;
   profit = right.profit;
   close_time = right.close_time;
 }
 
 ORDER_INFO::ORDER_INFO(const ORDER_INFO& right){
   operator=(right);
 }
 
 string ORDER_INFO::ToString(){
   string result = StringConcatenate(
               IntegerToString(open_time), "|*ORD*|",
               IntegerToString(close_time), "|*ORD*|",
               IntegerToString(opening_signal), "|*ORD*|",
               IntegerToString(is_opened), "|*ORD*|",
               IntegerToString(order_ticket), "|*ORD*|",
               IntegerToString(trailing_stop), "|*ORD*|",
               IntegerToString(trailing_start), "|*ORD*|",
               IntegerToString(limited_duration), "|*ORD*|", 
               NormalizeDouble(DoubleToString(open_price), Digits), "|*ORD*|",
               NormalizeDouble(DoubleToString(profit), 3), "|*ORD*|",
               controllingSolution.ToString()
              );
    return result;
 }
 
 bool ORDER_INFO::FromString(string order){
     if(order == "")
     {
            return false;
     }
     string args[];
     if(preg_match_split("\|\*ORD\*\|", order, args)){
         if(ArraySize(args) != 11)
         {
            return false;
         }
         
         open_time = StringToInteger(args[0]);
         close_time = StringToInteger(args[1]);
         opening_signal = StringToInteger(args[2]);
         is_opened  = StringToInteger(args[3]);
         order_ticket = StringToInteger(args[4]);
         trailing_stop = StringToInteger(args[5]);
         trailing_start = StringToInteger(args[6]);
         limited_duration = StringToInteger(args[7]);
         open_price = StringToDouble(args[8]);
         profit = StringToDouble(args[9]);
         if(!controllingSolution.FromString(args[10])){
            return false;
        }
     }
     else{
         return false;
     }
     
     return true;
 }

 class ORDERS_HISTORY{
   public:
      ORDER_INFO history[];
      int size;
      void Push(ORDER_INFO& arg);
      ORDERS_HISTORY();    
 };
 
 ORDERS_HISTORY::ORDERS_HISTORY(void){
   size = 0;
 }

 void ORDERS_HISTORY::Push(ORDER_INFO& arg){
     ORDER_INFO old[];
     ArrayResize(old, size+1);
     for(int i = 0; i < size; i++)
         old[i] = history[i];
     ArrayResize(history, size+1);
     for(int i = 0; i < size + 1; i++)
         history[i] = old[i];
     history[size] = arg;
     size++;
     
     return;
 }
 
class TRADING{
   protected:
      int countOfFundRequests;
      ulong allFundRequestingDuration;
      int currentBuySolutions;
      int currentSellSolutions; 
      int desiredLimit;
      int desiredCriterion;
      int marketMood;
      int efficientDuration;
      int intervalInSelecting;
      int curDesiredSignal;
      int curDesiredAverageTimeframe;
       
      ulong lastTimeOfSelecting;
      ulong lastTimeOfFeaturedAligning;
      int criticalForecastValueInSelecting;
      float optimalFundamentalFactorInSelecting;
      
      int minimalTimeUnit;
      double pricesForChecking[];
      
      ORDERS_HISTORY ordersHistory;
      
      int realFundamentalStateForSell;
      int realFundamentalStateForBuy;
      int fundamentalMoodForSell;
      int fundamentalMoodForBuy;
      int trackedFundamentalState;
   
      double curTakeProfit, curStopLoss;
      double curLots;
      double curTrailingStop;
      
      SOLUTION currentActualSolution; 
      ORDER_INFO orders_info[];
      int size_of_orders_metadata;
      int timeForMissing;
      string sessionId;
      double startingAllowedRisk;
      
      void Selecting();
      void AddOrder();
      
      void CloseOrder(int order_ticket, bool force = false);
      void TrailOrders(int order_ticket = 0, int new_profit_level = 0);
      void CheckConnection();
      void RegisterPriceForChecking(char id);
      double GetPriceChanges(char id);
      double GetMinimalUnitOfPriceChange();
      bool FundamentalAnalysis();
      bool CalcMarginStopOut(double lots, double stop);
      bool ControlRisks(string mode = "increase", double reserveProfit = 0, int opened_orders = 0, double customRisk = 0);
      void VolatilityMeasure(int period, double& outv, double& outpv);
      void CommonTradingInterface();
      virtual  bool IsDangerousOrder(int order_index);
      virtual void TradingInterface();
      virtual bool AllowedToTrade();
      virtual void AlignOrders(bool force = false);
      virtual float AdvantageCriterion(int fr, int criterion_num, int original_pr);
      virtual int GetFundamentalStateDegree(int optimalValue = 45);
      virtual int GetFundamentalMoodDegree(int optimalValue = 65);
      
   public:
      TRADING();
      ~TRADING();
      virtual void Trade();
      
      void SetMarketMood(int arg){
         marketMood = arg;
      }
      void SetMarketEfficientDuration(int arg){
         efficientDuration = arg;
      }
      
      void TimerProcedure(){
         string threadId = "var_" + sessionId;
         GlobalVariableSet(threadId, getTimeStamp(true));
      }
};

TRADING::TRADING(){
   desiredLimit = tIdesiredLimitInAskingOfSolutions;
   desiredCriterion = tIdesiredCriterionInAskingOfSolutions;
   marketMood = efficientDuration = 0;
   intervalInSelecting = tImaxIntervalInSelecting;
   lastTimeOfSelecting = lastTimeOfFeaturedAligning = 0;
   curTakeProfit = takeProfitLevel;
   curStopLoss = stopLossLevel;
   curTrailingStop = trailingStopLevel;
   if(curTrailingStop < stopLossLevel)
       curTrailingStop = stopLossLevel;
   
   size_of_orders_metadata = 0;
   timeForMissing = 0;
   curLots = 1;
  
   minimalTimeUnit = 3*60;
   ArrayResize(pricesForChecking, 512);
   for(int i = 0; i < 512; i++)
      pricesForChecking[i] = 0;
   curDesiredSignal = curDesiredAverageTimeframe = 0;
   realFundamentalStateForSell = realFundamentalStateForBuy = fundamentalMoodForSell = fundamentalMoodForBuy = trackedFundamentalState = 0;
   currentBuySolutions = currentSellSolutions = 0;
   countOfFundRequests = allFundRequestingDuration = 0;
   criticalForecastValueInSelecting = 75;
   optimalFundamentalFactorInSelecting = 1.3;
   startingAllowedRisk = allowedRiskOnOnePosition;
   
   AlignOrders(true);
   
   sessionId = l5Symbol;
   
   int iHandle = FileOpen("l5System/OrdersHistory_" + sessionId + ".txt" ,FILE_TXT|FILE_READ);
   if(iHandle < 1)
   {
       
   }
   else{
        int num_opened_orders = 0;
        ORDER_INFO opened_orders[];
        ArrayResize(opened_orders, 100);
        string sFile = FileReadString(iHandle);
        string strings[];
        if(sFile != "" && preg_match_split("\|\*STR\*\|", sFile, strings)){
            int l = ArraySize(strings);
            for(int i = 0; i < l; i++){
               string sString = strings[i];
               if(sString != ""){
                  ORDER_INFO order;
                  if(order.FromString(sString)){
                     if(order.is_opened){
                        if(OrderSelect(order.order_ticket, SELECT_BY_TICKET, MODE_TRADES)){
                           opened_orders[num_opened_orders++] = order;
                        }
                        else if((getTimeStamp(true) - order.open_time) < 86400 && OrderSelect(order.order_ticket, SELECT_BY_TICKET, MODE_HISTORY)){
                           order.is_opened = false;
                           order.close_time = OrderCloseTime();
                           order.profit = OrderProfit() + OrderSwap() + OrderCommission();  
                           ordersHistory.Push(order);
                        }
                     }
                     else if((getTimeStamp(true) - order.open_time) < 86400 && OrderSelect(order.order_ticket, SELECT_BY_TICKET, MODE_HISTORY))
                        ordersHistory.Push(order);
                  }
               }
            }
        }
       
        if(num_opened_orders){
            ArrayResize(orders_info, num_opened_orders);
            for(int i = 0; i < num_opened_orders; i++)
               orders_info[i] = opened_orders[i];
            size_of_orders_metadata = num_opened_orders;
        }
        
        FileClose(iHandle);
   }
   
   string threadId = "var_" + sessionId;
   if(getTimeStamp(true) - GlobalVariableGet(threadId) < 100){
      ErrPrint("L5: You cannot load L5 System of same symbol in different timeframes", true);
      ExpertRemove();
      return;
   }
    
   TimerProcedure();
}

TRADING::~TRADING(){
   string threadId = "var_" + sessionId;
   GlobalVariableDel(threadId);
   
   if(!size_of_orders_metadata && !ordersHistory.size)
      return;
      
   FileDelete("l5System/OrdersHistory_" + sessionId + ".txt" );
   int iHandle = FileOpen("l5System/OrdersHistory_" + sessionId + ".txt" ,FILE_TXT|FILE_WRITE);
   if(iHandle < 1)
   {
       int iErrorCode = GetLastError();
       ErrPrint("Error in writing of orders history into file: " + ErrorDescription(iErrorCode));
       return;
   }
   string res = "";
   
   for(int i = 0; i < size_of_orders_metadata; i++)
      res = res + "|*STR*|" + orders_info[i].ToString();
   for(int i = 0; i < ordersHistory.size; i++)
      res = res + "|*STR*|" + ordersHistory.history[i].ToString();
   FileWriteString(iHandle, res);
   FileClose(iHandle);
}

void TRADING::Selecting(){
   currentActualSolution.Flush();
   
   SOLUTION solutions[];
   int outsize;
   asker.AskSolutions(solutions, outsize, desiredCriterion, desiredLimit);
   curDesiredSignal = desiredSignalBySolutions;
   
   int counts = 0;
   if(outsize){
      //selecting
      SOLUTION csols[];
      bool csolFound[];
      ArrayResize(csols, definedNumCriterions);
      ArrayResize(csolFound, definedNumCriterions);
      ArrayFill(csolFound, 0, WHOLE_ARRAY, 0);
      int buySignals = 0, sellSignals = 0;
      int accountedInEffDur = 0, effDur = 0;
      int averageSignal = 0;
      
      //filtering by real fundamental state
   	int fr = 0, interestingSignal = VOID_SIGNAL, maxFr = 0;
   	if(realFundamentalStateForBuy - realFundamentalStateForSell > 0){
   			fr = realFundamentalStateForBuy - realFundamentalStateForSell;
   			maxFr = realFundamentalStateForBuy;
   			interestingSignal = SELL_SIGNAL;
   	}
   	else if(realFundamentalStateForSell - realFundamentalStateForBuy > 0){
   		 fr = realFundamentalStateForSell - realFundamentalStateForBuy;
   		 maxFr = realFundamentalStateForSell;
   		 interestingSignal = BUY_SIGNAL;
   	}
   	
   	int requiredSignal = VOID_SIGNAL;
   	if(fr > 7 && MathMax(realFundamentalStateForBuy, realFundamentalStateForSell) >= criticalForecastValueInSelecting)
   	{
   	   if(realFundamentalStateForBuy > realFundamentalStateForSell)
   	      requiredSignal = BUY_SIGNAL;
   	   else if(realFundamentalStateForSell > realFundamentalStateForBuy)
   	      requiredSignal = SELL_SIGNAL;
   	}
   				     
   	//filtering by fundamental forecast
   	int criticalForecastValue = criticalForecastValueInSelecting;
   	bool byForecast = false;
   	if(!fr && (fundamentalMoodForBuy > criticalForecastValue || fundamentalMoodForSell > criticalForecastValue) && MathAbs(fundamentalMoodForBuy - fundamentalMoodForSell)){
   			if(fundamentalMoodForBuy - fundamentalMoodForSell > 0){
         			fr = (fundamentalMoodForBuy - fundamentalMoodForSell);
         			maxFr = fundamentalMoodForBuy;
         			interestingSignal = SELL_SIGNAL;
         	}
         	else if(fundamentalMoodForSell - fundamentalMoodForBuy > 0){
         		 fr = fundamentalMoodForSell - fundamentalMoodForBuy;
         		 maxFr = fundamentalMoodForSell;
         		 interestingSignal = BUY_SIGNAL;
         	}	    
         	byForecast = true; 
   	}
      
     for(int c = 1; c <= definedNumCriterions; c++){
		 bool selected = false;
		 bool is_checked_by_more_size = false;
		 int checked_by_desired_average_timeframe = 0;
		 int continueTo = 0;
		 int skippedByFundamental = 0;
		 int requiredSkipped = 0;
		 int allSols = 0;
		 int interestingSols = 0;
		 
       for(int i = 0; i < outsize; i++){
            if(solutions[i].criterion == c){
               if(solutions[i].is_closing_signal == VOID_SIGNAL){
      				if(solutions[i].signal == SELL_SIGNAL)
                           sellSignals++;
                  else
                           buySignals++;
                 effDur += solutions[i].adapted_by_duration;
      			  accountedInEffDur++;
      			  averageSignal += solutions[i].desired_signal;
      			 
   				  if(!selected && (!continueTo || continueTo <= i)){
   				      continueTo = 0;
   				     
      					//following selecting...
      					if(requiredSignal == VOID_SIGNAL && getTimeStamp(true) - solutions[i].signal_moment > minimalTimeUnit * 2){
      						   continue;
      				   }
      				     
      				   if(solutions[i].signal == interestingSignal && fr > 0){
      				         if(!allSols){
      				            for(int m = 0; m < outsize; m++){
      				               if(solutions[m].criterion == c && solutions[m].is_closing_signal == VOID_SIGNAL){
      				                  if(requiredSignal == VOID_SIGNAL && getTimeStamp(true) - solutions[m].signal_moment > minimalTimeUnit * 2)
      				                     continue;
      				                  allSols++;
      				                  if(solutions[m].signal == interestingSignal)
      				                     interestingSols++;  
      				               }
      				            }
      				            requiredSkipped = MathCeil((double) interestingSols * ((double) (interestingSols) / (double) allSols) * ((double) fr * optimalFundamentalFactorInSelecting / (double) maxFr));
      				            if(byForecast)
      				            {
      				               requiredSkipped = MathRound((double) requiredSkipped / 3);
      				            }
      				         }
      				         
      				         if(skippedByFundamental++ < requiredSkipped)
      				            continue;
      				     } 
      				     
      					  if(curDesiredAverageTimeframe && !fr && i < outsize - 2 && checked_by_desired_average_timeframe < 2){
      						 int j = i + 1;
      						 int lim = (j + 7 > outsize)? outsize: j + 7;
      						 bool continueF = false;
      						 for(; j < lim; j++)
      							if(solutions[j].criterion == c && solutions[j].average_timeframe != 0 && (solutions[i].average_timeframe > solutions[j].average_timeframe) &&
      							   ((solutions[j].average_timeframe <= MathAbs(curDesiredAverageTimeframe) && curDesiredAverageTimeframe > 0) ||
      							   (solutions[j].average_timeframe >= MathAbs(curDesiredAverageTimeframe) && curDesiredAverageTimeframe < 0))
      								&& (getTimeStamp(true) - solutions[j].signal_moment) <= minimalTimeUnit * 3){
      							   continueTo = j;
      							   continueF = true;
      							   checked_by_desired_average_timeframe++;
      							   break;
      							}
      						 if(continueF)
      							continue;
      					  }
      					  
      					  if(!fr && i < outsize - 2 && (!is_checked_by_more_size && !checked_by_desired_average_timeframe)){
      						 int j = i + 1;
      						 int lim = (j + 6 > outsize)? outsize: j + 6;
      						 bool continueF = false;
      						 for(; j < lim; j++)
      							if(solutions[j].criterion == c && 
      							   solutions[j].inPacket.Size() > solutions[i].inPacket.Size()
      								&& (getTimeStamp(true) - solutions[j].signal_moment) <= minimalTimeUnit * 3){
      							   continueTo = j;
      							   continueF = true;
      							   is_checked_by_more_size = true;
      							   break;
      							}
      						 if(continueF)
      							continue;
      					  }
      					  
      					  csols[c - 1] = solutions[i];
      					  csolFound[c - 1] = true;
      					  selected = true;
   				   }
               }
            }
         }
      }
      
      if(buySignals > sellSignals)
           marketMood = BUY_SIGNAL;
      else if(sellSignals > buySignals)
           marketMood = SELL_SIGNAL;
      else
           marketMood = VOID_SIGNAL;
      efficientDuration = accountedInEffDur?effDur / accountedInEffDur:0;
      currentBuySolutions = buySignals;
      currentSellSolutions = sellSignals;
      
      ulong max_priority = 9999999999999;
      int cindex = -1;
      for(int c = 0; c < definedNumCriterions; c++){
         if(csolFound[c]){
            int pr = csols[c].priority;
            pr = AdvantageCriterion(fr, csols[c].criterion, pr);
            
            if(pr < max_priority){
               max_priority = pr;
               cindex = c;
            }
         }
      }
      
      if(cindex != -1)
		  if(requiredSignal != VOID_SIGNAL && csols[cindex].signal != requiredSignal){
			 for(int c = 0; c < definedNumCriterions; c++){
				if(csolFound[c]){
				   if(requiredSignal == csols[c].signal)
				   {
					  cindex = c;
					  break;
				   }
				}
			}
		}
		
      if(cindex != -1){
         currentActualSolution = csols[cindex];
      }
   }  
}

void TRADING::AddOrder(){
   int new_ticket = -1;
   CheckConnection();
   RefreshRates();
   if(currentActualSolution.signal == BUY_SIGNAL)
   {
         double sl = Bid - CalculatePoint(curStopLoss);
         double tp = Bid + CalculatePoint(curTakeProfit);
         new_ticket = OrderSend(l5Symbol, OP_BUY, curLots, Ask, TruePointValue(tIallowedSlippage), sl, tp, NULL,
                          0, 0, Green);
         if(new_ticket == -1){
             ErrPrint("TRAIDING IMPLEMENTS: Can't open order: " + (string) ErrorDescription(GetLastError()));
         }
   }
      
   if(currentActualSolution.signal == SELL_SIGNAL)
   {
         double sl = Ask + CalculatePoint(curStopLoss);
         double tp = Ask - CalculatePoint(curTakeProfit);
         new_ticket = OrderSend(l5Symbol, OP_SELL, curLots, Bid, TruePointValue(tIallowedSlippage), sl, tp, NULL,
                          0, 0, Red);
         if(new_ticket == -1){
             ErrPrint("TRAIDING IMPLEMENTS: Can't open order: " + (string) ErrorDescription(GetLastError()));
         }
   }
   
   if(new_ticket != -1){
      //add order info
      ORDER_INFO old[];
      ORDER_INFO info;
      info.controllingSolution = currentActualSolution;
      info.opening_signal = currentActualSolution.signal;
      info.open_time = getTimeStamp(true);
      info.is_opened = true;
      info.order_ticket = new_ticket;
      info.trailing_stop = curTrailingStop;
      info.trailing_start = (int) MathRound((double) curTrailingStop / 1.3);
      if(info.trailing_start < stopLossLevel)
         info.trailing_start = stopLossLevel;
         
      info.limited_duration = currentActualSolution.adapted_by_duration;
      info.open_price = currentActualSolution.signal == SELL_SIGNAL?Bid:Ask;
      
      ArrayResize(old, size_of_orders_metadata);
      for(int i = 0; i < size_of_orders_metadata; i++){
         old[i] = orders_info[i];
      }
      ArrayResize(orders_info, size_of_orders_metadata + 1);
      for(int i = 0; i < size_of_orders_metadata; i++){
         orders_info[i] = old[i];
      }
      orders_info[size_of_orders_metadata] = info;
      size_of_orders_metadata++;
   }
}

void TRADING::CloseOrder(int order_ticket, bool force){
   bool dangerousOrder = false;
   int order_index = -1;
   for(int i = 0; i < size_of_orders_metadata; i++)
        if(orders_info[i].order_ticket == order_ticket)
        {
            order_index = i;
            break;
        }
        
   if(order_index != -1){
      dangerousOrder = IsDangerousOrder(order_index);
            
      RefreshRates();
      CheckConnection();
      if(OrderSelect(order_ticket, SELECT_BY_TICKET))
         if(!OrderCloseTime() && (OrderProfit() > 0 || dangerousOrder || force)){
             int i = 0;
             while(!OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_SELL)?Ask:Bid, TruePointValue(tIallowedSlippage), OliveDrab) && i++ < 50){
                 if(i % 5 == 0){
                     CheckConnection();
                     Sleep(300);
                 }
                 if(i == 50)
                     ErrPrint("TRAIDING IMPLEMENTS: Can't close order: " + (string) ErrorDescription(GetLastError()));
             };  
             orders_info[order_index].is_opened = false;
             orders_info[order_index].close_time = getTimeStamp(true);
             orders_info[order_index].profit = OrderProfit() + OrderSwap() + OrderCommission();
             ordersHistory.Push(orders_info[order_index]);
         }
    }
}

void TRADING::TrailOrders(int order_ticket, int new_profit_level){
   static ulong lastTimeOfSetting = 0;

   if(getTimeStamp(true) - lastTimeOfSetting >= 2 && OrdersTotal()>0){
      lastTimeOfSetting = getTimeStamp(true);
      
      CheckConnection();
      RefreshRates();
      for(int cnt=OrdersTotal();cnt>=0;cnt--){
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)){
            if(OrderSymbol() == l5Symbol){
               double TrailingStart = (int) MathRound((double) curTrailingStop / 1.3);
               if(TrailingStart < stopLossLevel)
                  TrailingStart = stopLossLevel;
               double TrailingStop = curTrailingStop;
                  
               for(int i = 0; i < size_of_orders_metadata; i++){
                    if(orders_info[i].order_ticket == OrderTicket()){
                        TrailingStart = orders_info[i].trailing_start;
                        TrailingStop = orders_info[i].trailing_stop;
                        break;
                    }  
               }
               
               if(order_ticket != 0 && OrderTicket() != order_ticket)
                  continue;
              
               if(OrderType()==OP_BUY){
                  if(Ask > (OrderOpenPrice() + CalculatePoint(TrailingStart))
                        && OrderStopLoss() < (Bid - CalculatePoint(TrailingStop))){
                     double tStopLoss = Bid - CalculatePoint(TrailingStop);
                     if(tStopLoss < OrderOpenPrice())
                        tStopLoss = OrderOpenPrice() + CalculatePoint(TrailingStart) / 7;
                     double tTakeProfit = new_profit_level != 0?OrderOpenPrice() + CalculatePoint(new_profit_level):OrderTakeProfit();
                     
                     OrderModify(OrderTicket(), OrderOpenPrice(),tStopLoss,tTakeProfit,0,CLR_NONE);
                  }
                  if(new_profit_level){
                     double tTakeProfit = OrderOpenPrice() + CalculatePoint(new_profit_level);
                     OrderModify(OrderTicket(), OrderOpenPrice(),OrderStopLoss(),tTakeProfit,0,CLR_NONE);
                  }
                  
                  
                  if(Bid < OrderStopLoss()){
                     //DANGEROUS
                     CloseOrder(OrderTicket());
                  }
               }
               
               if(OrderType()==OP_SELL){
                  if(Bid < (OrderOpenPrice() - CalculatePoint(TrailingStart))
                        && OrderStopLoss() > (Ask + CalculatePoint(TrailingStop))){
                     double tStopLoss = Ask + CalculatePoint(TrailingStop);
                     if(OrderOpenPrice() < tStopLoss)
                        tStopLoss = OrderOpenPrice() - CalculatePoint(TrailingStart) / 7;
                     double tTakeProfit = new_profit_level != 0?OrderOpenPrice() - CalculatePoint(new_profit_level):OrderTakeProfit();
                     
                     OrderModify(OrderTicket(), OrderOpenPrice(),tStopLoss,tTakeProfit,0,CLR_NONE);
                       
                  }
                  if(new_profit_level){
                     double tTakeProfit = OrderOpenPrice() - CalculatePoint(new_profit_level);
                     OrderModify(OrderTicket(), OrderOpenPrice(),OrderStopLoss(),tTakeProfit,0,CLR_NONE);
                  }
                  
                  
                  if(Ask > OrderStopLoss()){
                     //DANGEROUS
                     CloseOrder(OrderTicket());
                  }
              }
           }
        }
     }
  }
}

void TRADING::CheckConnection(void){
   if(!IsConnected()){
      int i = 0;
      while(!IsConnected()){
         if(i++ % 1800 == 0)
            ErrPrint("Can't connect with server during trading");
         Sleep(1000);
      }
   }
}

void TRADING::RegisterPriceForChecking(char id){
   RefreshRates();
   pricesForChecking[(int) id] = (Ask + Bid) / 2;
}

double TRADING::GetPriceChanges(char id){
   if(!pricesForChecking[(int) id])
      return 0;

   return ((Ask + Bid) / 2 - pricesForChecking[id]);
}

double TRADING::GetMinimalUnitOfPriceChange(void){
   int unit = stopLossLevel / 2;
   if(unit > 15)
      unit = 15;
   if(unit < 7)
      unit = 7;   
   return CalculatePoint(unit);
}

void TRADING::VolatilityMeasure(int period, double& outv, double& outpv){
   double volatilityK = 0;
   double priceMoving = 0;
   double allV = 0, partV = 0, maxH = -99999999, minLow = 99999999;
   int board = MathCeil(period / 3);
   if(board == 0)
      board = 1;
   for(int i = 0; i < period; i++){
        double k = iHigh(l5Symbol, 1, i) - iLow(l5Symbol, 1, i);
        double k2 = iClose(l5Symbol, 1, i) - iOpen(l5Symbol, 1, i);
        if(i < board)
            priceMoving += k2;
        if(i < board)
           partV += k;
        allV += k;
                           
        if(maxH < iHigh(l5Symbol, 1, i))
           maxH = iHigh(l5Symbol, 1, i);
        if(minLow > iLow(l5Symbol, 1, i))
           minLow = iLow(l5Symbol, 1, i);
    }
                        
    if(allV)
       volatilityK = partV / allV;
    if(maxH - minLow != 0 && (maxH - minLow) >= priceMoving)
       priceMoving = priceMoving / (maxH - minLow);
    else if(maxH - minLow == 0)
       priceMoving = 0;
    if(MathAbs(priceMoving) > 1)
       priceMoving = priceMoving < 0?-1:1;
       
   outv = volatilityK;
   outpv = priceMoving;           
}

bool TRADING::FundamentalAnalysis(){
   static int timeout = 25000;
   static ulong lastRequestMoment = 0;
   static int requestInterval = 10;
   static int errcount = 0;
   static double meta[];
   static bool is_tracking_stopped = true;
   
   int currentTime = getTimeStamp(true);
   
   int countedPeriodOfTracking = 10; 
   int importantRange = 30;
   int optimalTimeForTracking = 17*60;
   
   if(currentTime - lastRequestMoment >= requestInterval){
      if(!ArraySize(meta)){
         ArrayResize(meta, 50);
         ArrayFill(meta, 0, 50, 0);
      }
   
      lastRequestMoment = currentTime; 
      
      string spost = "type=get_news&currency=" + l5Symbol;
      ulong st = GetTickCount();
      
      string sresponse = "";
      if(!IsTesting())
         sresponse = QueryToL5Server(l5CentralServerAddress, spost, timeout);
      else{
         if(l5Db.Query("SELECT data FROM " + l5Symbol + "_events_chain_for_testing WHERE moment BETWEEN " + (string) currentTime + " - 60 AND " + (string) currentTime + " ORDER BY moment DESC LIMIT 1")){
            if(l5Db.Rows())
               sresponse = l5Db.result[0].f[0];
         }
      }
      
      if(StringFind(sresponse, "|") != -1){
         errcount = 0;
         string blocks[];
         int len;
         if((len = StringSplit(sresponse, StringGetChar("|", 0), blocks)) == 5){
            fundamentalMoodForBuy = MathRound(StringToDouble(blocks[0]));
            fundamentalMoodForSell = MathRound(StringToDouble(blocks[1]));
            realFundamentalStateForBuy = MathRound(StringToDouble(blocks[2]));
            realFundamentalStateForSell = MathRound(StringToDouble(blocks[3]));
            int lastEventMoment = StringToInteger(blocks[4]); 
            
            /*Self assignment*/
            RefreshRates();
            
            if(MathAbs(meta[0] - lastEventMoment) > 0.5){
#ifdef __CHV
               //send data about previous event
               if(!IsTesting() && (int) meta[1]){
                  if(!((int) meta[6]))
                     meta[6] = Bid;
                     
                  int strength = MathAbs(meta[6] - meta[1]) / CalculatePoint(importantRange) * 100;
                  if(strength > 100)
                     strength = 100;
                  int action = 0;
                  if(meta[6] - meta[1] < 0)
                     action = -1;
                  else if(meta[6] - meta[1] > 0)
                     action = 1;
                  spost = "type=sending_info&currency=" + l5Symbol + "&st_act=" + (string) action + "&st_strength=" + (string) strength + "&event_moment=" + (string) meta[0];
                  QueryToL5Server(l5CentralServerAddress, spost, timeout);
               }
#endif
              
               if(lastEventMoment != 0)
                  is_tracking_stopped = false;
               else{
                  is_tracking_stopped = true;
                  meta[1] = 0;
               }
               meta[0] = lastEventMoment;
               meta[1] = Bid;    //starting pice; 
               meta[2] = Bid;    //prev pice; 
               meta[3] = realFundamentalStateForBuy;  //start val
               meta[4] = realFundamentalStateForSell; //start val
               meta[5] = 0; //count
               meta[6] = 0; //price in moment of stopping tracking
               trackedFundamentalState = 0;
            }
            else{
               if(!is_tracking_stopped){
                  meta[5]++;
                  if(meta[5] > 1){
                     double absoluteMoving = Bid - meta[1];
                     double volatilityK = 0; //%
                     double priceMoving = 0; //%
                     
                     if(currentTime - meta[0] > 3*60){
                        VolatilityMeasure(countedPeriodOfTracking, volatilityK, priceMoving);
                     }
                     
                     double timeFactor =  1 - (currentTime - meta[0]) / (optimalTimeForTracking);
                     if(timeFactor < 0)
                        timeFactor = 0;
                     double movingFactor = MathAbs(absoluteMoving) / CalculatePoint(importantRange);
                     if(movingFactor > 1)
                        movingFactor = 1;
                     
                     double res = (timeFactor * movingFactor * 0.5);
                     
                     res += (volatilityK * 0.2);
                     
                     double currentMovingFactor = 0;
                     if((priceMoving < 0 && absoluteMoving > 0) || (absoluteMoving < 0 && priceMoving > 0))
                        currentMovingFactor = -MathAbs(priceMoving)*0.15;
                     else if((priceMoving < 0 && absoluteMoving < 0) || (absoluteMoving > 0 && priceMoving > 0))
                        currentMovingFactor = MathAbs(priceMoving) * 0.3;
                     res += currentMovingFactor;
                     
                     //trackedFundamentalState = MathRound(res * 100);
                    
                     if(absoluteMoving < 0)
                        trackedFundamentalState = -trackedFundamentalState;
                     
                     if(currentTime - meta[0] > optimalTimeForTracking && MathAbs(trackedFundamentalState) < 13)
                     {
                        trackedFundamentalState = 0;
                        is_tracking_stopped = true;
                        meta[6] = Bid;
                     }
                  }
               }
            }
            
            meta[2] = Bid;
            
            if(trackedFundamentalState != 0 && ((int) meta[3] || (int) meta[4])){
               if(trackedFundamentalState < 0 && (int) meta[4])
                  realFundamentalStateForSell += MathRound((meta[4] / 100) * MathAbs(trackedFundamentalState) * (1 - (realFundamentalStateForSell / 100)));
               else if(trackedFundamentalState > 0 && (int) meta[3])
                  realFundamentalStateForBuy += MathRound((meta[3] / 100) * MathAbs(trackedFundamentalState) * (1 - (realFundamentalStateForBuy / 100))); 
            }
         }
         else{
            errcount++;
         }
      }
      
      if(errcount % 15 == 0 && errcount){
         ErrPrint("Ошибка получения фундаментальных показателей");
      }
      
      countOfFundRequests++;
      allFundRequestingDuration = GetTickCount() - st;
      
      ulong dur = allFundRequestingDuration / countOfFundRequests;
      if(dur > 3000){
         requestInterval *= MathCeil((double) dur / (double)4000);
         timeout = 10000 * MathCeil((double) dur / (double)4000);
      }
      else
      {
         requestInterval = 10;
         timeout = 6000;
      }
   }
   
   return true;
}

bool TRADING::CalcMarginStopOut(double lots, double stop){
   ENUM_ACCOUNT_STOPOUT_MODE stop_out_mode = (ENUM_ACCOUNT_STOPOUT_MODE) AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   double lotCost = MarketInfo(l5Symbol, MODE_TICKVALUE);
   
   if(stop_out_mode == ACCOUNT_STOPOUT_MODE_PERCENT){
      if(MathCeil((AccountInfoDouble(ACCOUNT_EQUITY) - lotCost*lots*stop*TruePointValue(1)) / 
        (AccountInfoDouble(ACCOUNT_MARGIN) + curLots *  MarketInfo(l5Symbol, MODE_MARGINREQUIRED)) * 100) < AccountInfoDouble(ACCOUNT_MARGIN_SO_SO))
            return false;
   }
   
   if(stop_out_mode == ACCOUNT_STOPOUT_MODE_MONEY){
     if(MathCeil((AccountInfoDouble(ACCOUNT_EQUITY) - lotCost*lots*stop*TruePointValue(1)) < AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)))
         return false;
   }
   
   return true; 
}

bool TRADING::ControlRisks(string mode,double reserveProfit, int opened_orders, double acustomRisk){
   double lotCost = MarketInfo(l5Symbol, MODE_TICKVALUE);
   double tickSize = MarketInfo(l5Symbol, MODE_TICKSIZE);
   double customRisk = allowedRiskOnOnePosition;
   if(acustomRisk != 0)
      customRisk = acustomRisk;
   
   if(mode == "increase"){
         double calculatedBalance = AccountInfoDouble(ACCOUNT_BALANCE) + reserveProfit;
         double prevStopLoss = curStopLoss;
        
         while((lotCost * curLots * curStopLoss * TruePointValue(1)) / calculatedBalance * 100 < customRisk){
            if(startingAllowedRisk < customRisk)
            {
               while((lotCost * curLots * curStopLoss * TruePointValue(1)) / calculatedBalance * 100 < customRisk){
                  customRisk -= 0.01;
                  if(customRisk <= startingAllowedRisk)
                     break;
               }
            }
            
            curStopLoss++;
            if(curStopLoss > stopLossLevel*1.6)
               curStopLoss = stopLossLevel*1.6;
            if((lotCost * curLots * curStopLoss * TruePointValue(1)) / calculatedBalance * 100 > customRisk){
               curStopLoss--;
               break;
            }
            
            curLots += MarketInfo(l5Symbol, MODE_LOTSTEP);  
            if((lotCost*curLots* curStopLoss * TruePointValue(1)) / calculatedBalance * 100 > customRisk){
               curLots -= MarketInfo(l5Symbol, MODE_LOTSTEP);
               break;
            }
            if(curLots >= MarketInfo(l5Symbol, MODE_MAXLOT)){
   			   curLots = MarketInfo(l5Symbol, MODE_MAXLOT);
   			   break;
   		   }  
         }
         curTrailingStop = MathRound((double) curTrailingStop * ((double) curStopLoss / (double) prevStopLoss));
         if(curTrailingStop < stopLossLevel)
            curTrailingStop = stopLossLevel;
         if(curTrailingStop > takeProfitLevel / 2)
            curTrailingStop = takeProfitLevel / 2;
   }
   else if(mode == "decrease"){
      //checking by risks
      double calculatedBalance = AccountInfoDouble(ACCOUNT_BALANCE) + reserveProfit;
      double potentialLoss = lotCost*curLots*curStopLoss*TruePointValue(1);
      double prevStopLoss = curStopLoss;
      
      if((((potentialLoss / calculatedBalance) * 100) > customRisk)
       || (AccountFreeMarginCheck(l5Symbol,currentActualSolution.signal == BUY_SIGNAL?OP_BUY:OP_SELL,curLots)<=0 || GetLastError()==ERR_NOT_ENOUGH_MONEY)){
         
         ResetLastError();
         bool checked_by_stopLoss = false;
         while(((lotCost*curLots*curStopLoss*TruePointValue(1) / calculatedBalance * 100) > customRisk)
             || (AccountFreeMarginCheck(l5Symbol,currentActualSolution.signal == BUY_SIGNAL?OP_BUY:OP_SELL,curLots) <= 0 || GetLastError()==ERR_NOT_ENOUGH_MONEY)){
             
           ResetLastError();
           if(!checked_by_stopLoss && curStopLoss > stopLossLevel){
   			 curStopLoss--;
   			 checked_by_stopLoss = !checked_by_stopLoss;
   			 continue;
   		  }
            
           curLots -= MarketInfo(l5Symbol, MODE_LOTSTEP);
           checked_by_stopLoss = !checked_by_stopLoss;
           if(curLots < MarketInfo(l5Symbol, MODE_MINLOT))
              curLots = MarketInfo(l5Symbol, MODE_MINLOT);
               
            if(curLots - MarketInfo(l5Symbol, MODE_MINLOT) < 0.00001){
                if(opened_orders == 0){
                     if(tIAutomaticDefiningRisk || acustomRisk != 0){
                        customRisk += 0.01;
                        if(customRisk >= 100 || (acustomRisk != 0 && !tIAutomaticDefiningRisk && customRisk > allowedRiskOnOnePosition)){
                            ErrPrint("TRADING IMPLEMENTS: You cannot trade because your balance is less than it must be according to measure of risk or you have not enough money", true);
                            ExpertRemove();
                        }
                        else
                           continue;
                     }
                     else{
                        ErrPrint("TRADING IMPLEMENTS: You cannot trade because your balance is less than it must be according to measure of risk or you have not enough money", true);
                        ExpertRemove();  
                     }
               }
               return false;
            }
         }
      } 
      
      while(!CalcMarginStopOut(curLots, curStopLoss)){ 
           curLots -= MarketInfo(l5Symbol, MODE_LOTSTEP);
           if(curLots < MarketInfo(l5Symbol, MODE_MINLOT))
              curLots = MarketInfo(l5Symbol, MODE_MINLOT);
               
            if(curLots - MarketInfo(l5Symbol, MODE_MINLOT) < 0.00001 && curStopLoss <= stopLossLevel){
                break;
            }
            
            if(curStopLoss > stopLossLevel){
      			 curStopLoss--;
      			 
      			 continue;
   		   }
      }
      
      curTrailingStop = MathRound((double) curTrailingStop * ((double) curStopLoss / (double) (prevStopLoss)));
      if(curTrailingStop < stopLossLevel)
         curTrailingStop = stopLossLevel;
      if(curTrailingStop > takeProfitLevel / 2)
         curTrailingStop = takeProfitLevel / 2;
   }
   else if(mode == "increase_of_low_risk_strategy"){
       double calculatedBalance = AccountInfoDouble(ACCOUNT_BALANCE) + reserveProfit;
       while((lotCost * curLots * curStopLoss * TruePointValue(1)) / calculatedBalance * 100 < customRisk){
            if(startingAllowedRisk < customRisk)
            {
               while((lotCost * curLots * curStopLoss * TruePointValue(1)) / calculatedBalance * 100 < customRisk){
                  customRisk -= 0.01;
                  if(customRisk <= startingAllowedRisk)
                     break;
               }
            }
            
            curLots += MarketInfo(l5Symbol, MODE_LOTSTEP);  
            if((lotCost*curLots* curStopLoss * TruePointValue(1)) / calculatedBalance * 100 > customRisk){
               curLots -= MarketInfo(l5Symbol, MODE_LOTSTEP);
               break;
            }
            if(curLots >= MarketInfo(l5Symbol, MODE_MAXLOT)){
   			   curLots = MarketInfo(l5Symbol, MODE_MAXLOT);
   			   break;
   		   }  
         }
   }
   return true;
}

void TRADING::CommonTradingInterface(void){
   string curSignal = "VOID";
   if(currentActualSolution.signal == BUY_SIGNAL)
      curSignal = "BUY";
   else if(currentActualSolution.signal == SELL_SIGNAL)
      curSignal = "SELL";
      
   string commentStr = "\n\nFundamental Mood For Buy: " + fundamentalMoodForBuy + "\n" +
                       "Fundamental Mood For Sell: " + fundamentalMoodForSell + "\n" +
                       "Fundamental Real State For Buy: " + realFundamentalStateForBuy + "\n" +
                       "Fundamental Real State For Sell: " + realFundamentalStateForSell + "\n" + 
                       "Buy active solutions: " + currentBuySolutions + "\n" + 
                       "Sell active solutions: " + currentSellSolutions + "\n" +
                       "Current signal: " + curSignal + "\n" +
                       "Tracked Fundamental State: " + trackedFundamentalState + "\n";
   Comment(commentStr);
}

//------------------------------------
// VIRTUAL METHODS OF TRADING CLASS
//------------------------------------

void TRADING::Trade(){
   
}

void TRADING::AlignOrders(bool force){

}

bool TRADING::IsDangerousOrder(int order_index){
   
   return false;
}

bool TRADING::AllowedToTrade(void){
   
   return true;
}

void TRADING::TradingInterface(){
  
}

float TRADING::AdvantageCriterion(int fr, int criterion_num, int original_pr){
   return original_pr;
}

int TRADING::GetFundamentalStateDegree(int optimalValue){
   int res = 0;
   int fAbsValue = MathMax(realFundamentalStateForBuy, realFundamentalStateForSell);
   int fBSDiff = realFundamentalStateForBuy - realFundamentalStateForSell;

   int fmoodAbsValue = MathMax(fundamentalMoodForBuy, fundamentalMoodForSell);
   int fmoodBSDiff = fundamentalMoodForBuy - fundamentalMoodForSell;
   
   res = ((fAbsValue > 45) || fmoodAbsValue > 95)?1:res;
   res = ((MathAbs(fBSDiff) > 5) && fAbsValue > optimalValue || (fAbsValue > optimalValue + 15 && MathAbs(fBSDiff > 3)) || fAbsValue > optimalValue + 25)?2:res;
   res = (((MathAbs(fBSDiff) > 7) && fAbsValue > optimalValue + 10) || (fAbsValue > optimalValue + 25 && MathAbs(fBSDiff) > 3) || fAbsValue > optimalValue + 38)?3:res;
   return res;
}

int TRADING::GetFundamentalMoodDegree(int optimalValue){
   int fmoodAbsValue = MathMax(fundamentalMoodForBuy, fundamentalMoodForSell);
   int fmoodBSDiff = fundamentalMoodForBuy - fundamentalMoodForSell;
   int res = 0;
   res = (fmoodAbsValue > optimalValue)?1:res;
   res = ((fmoodAbsValue > optimalValue + 20) || (MathAbs(fmoodBSDiff) > 10 && fmoodAbsValue > optimalValue))?2:res;
   res = ((fmoodAbsValue > optimalValue + 30) || MathAbs(fmoodBSDiff) > 20 && (fmoodAbsValue > optimalValue + 5))?3:res;
   
   return res;
}

//-----------------------------------------------------------------------------------------
//                               COMMON TRADING STRATEGY
//-----------------------------------------------------------------------------------------

class COMMON_TRADING_STRATEGY : public TRADING {
   protected:
      virtual  bool IsDangerousOrder(int order_index);
      virtual void TradingInterface();
      virtual bool AllowedToTrade();
      virtual void AlignOrders(bool force = false);
      virtual float AdvantageCriterion(int fr, int criterion_num, int original_pr);
      
   public:
      COMMON_TRADING_STRATEGY();
      ~COMMON_TRADING_STRATEGY();
      virtual void Trade();
};

COMMON_TRADING_STRATEGY::COMMON_TRADING_STRATEGY(void){
   AlignOrders(true);
}

COMMON_TRADING_STRATEGY::~COMMON_TRADING_STRATEGY(void){

}

void COMMON_TRADING_STRATEGY::Trade(){
   if(getTimeStamp(true) - lastTimeOfSelecting > (GetFundamentalStateDegree() >= 2?10:intervalInSelecting)){
        Selecting();
        //Taking decision
        if(AllowedToTrade()){
            AddOrder();
        }
        lastTimeOfSelecting = getTimeStamp(true);
    } 
    
    AlignOrders(); 
    
    FundamentalAnalysis();
    TradingInterface();
}

void COMMON_TRADING_STRATEGY::AlignOrders(bool force){

   if(size_of_orders_metadata == 0 && !force)
      return;
   int fState = GetFundamentalStateDegree();
   int fDiff = realFundamentalStateForBuy - realFundamentalStateForSell;
            
   if(getTimeStamp(true) - lastTimeOfFeaturedAligning > intervalInSelecting + 10 || fState >= 2 || force){
      RefreshRates();
      double reserveProfit = 0;
      double lotCost = MarketInfo(l5Symbol, MODE_TICKVALUE);
      double tickSize = MarketInfo(l5Symbol, MODE_TICKSIZE);
      int ordersOpened = 0;
      double volatilityK = 0;
      double priceMoving = 0;
      VolatilityMeasure(10, volatilityK, priceMoving);
      
      for(int i = 0; i < size_of_orders_metadata; i++){
         //mark of deleted orders;
         if(orders_info[i].is_opened){
            bool deleteOrder = true;
            double profitOrder = 0;
            
            if(OrderSelect(orders_info[i].order_ticket, SELECT_BY_TICKET))
               if(!OrderCloseTime()){
                  deleteOrder = false;
                  if(OrderType() == OP_BUY)
                     reserveProfit += (lotCost*OrderLots()*(OrderStopLoss() - OrderOpenPrice()) / tickSize);
                  else if(OrderType() == OP_SELL)
                     reserveProfit += (lotCost*OrderLots()*(OrderOpenPrice() - OrderStopLoss()) / tickSize);
                  ordersOpened++;
                  
                  if(orders_info[i].limited_duration != 0 && (getTimeStamp(true) - orders_info[i].open_time) < minimalTimeUnit){
                     if((marketMood != VOID_SIGNAL && orders_info[i].opening_signal == marketMood)
                        && ((orders_info[i].opening_signal == SELL_SIGNAL && curDesiredSignal > 0) || (orders_info[i].opening_signal == BUY_SIGNAL && curDesiredSignal < 0)))
                           orders_info[i].limited_duration = 0;
                  }
                  
                  if(fState == 3 && volatilityK > 0.7 && MathAbs(priceMoving) > 0.6 && 
                        ((fDiff > 0 && orders_info[i].opening_signal == BUY_SIGNAL) || (fDiff < 0 && orders_info[i].opening_signal == SELL_SIGNAL))){
                        //increases profit level
                        orders_info[i].trailing_stop = curTrailingStop * 1.4;
                        orders_info[i].trailing_start = (int) MathRound((double) curTrailingStop * 1.5 / 1.3);
                        TrailOrders(orders_info[i].order_ticket, MathRound((double) takeProfitLevel * (double) (1 + 0.75 * volatilityK))); 
                  }
               }
               else{
                  profitOrder = OrderProfit() + OrderSwap() + OrderCommission();
               }
           
            if(deleteOrder){
               orders_info[i].is_opened = false; 
               orders_info[i].close_time = getTimeStamp(true);
               orders_info[i].profit = profitOrder;
               ordersHistory.Push(orders_info[i]);
            }
         }
      
         if(orders_info[i].is_opened){
            
            bool not_close = (((orders_info[i].opening_signal == BUY_SIGNAL && fDiff > 3) || (fDiff < 3 && orders_info[i].opening_signal == SELL_SIGNAL)) && fState >= 1 || fState >= 2);
            bool force_close = (((orders_info[i].opening_signal == BUY_SIGNAL && fDiff < 0) || (orders_info[i].opening_signal == SELL_SIGNAL && fDiff > 0))&& fState >= 2);
            
            if(force_close){
               CloseOrder(orders_info[i].order_ticket, true);
            }
            else if(!not_close){
               orders_info[i].controllingSolution.AskSolution();
               if(((orders_info[i].controllingSolution.is_closing_signal != VOID_SIGNAL && orders_info[i].controllingSolution.is_closing_signal != orders_info[i].opening_signal) || 
                  (orders_info[i].controllingSolution.signal != VOID_SIGNAL && orders_info[i].controllingSolution.signal != orders_info[i].opening_signal))){
                  if(getTimeStamp(true) - orders_info[i].open_time > minimalTimeUnit)
                     CloseOrder(orders_info[i].order_ticket);
               }
             
               if(orders_info[i].limited_duration && (getTimeStamp(true) - orders_info[i].open_time > orders_info[i].limited_duration)){
                  if(OrderSelect(orders_info[i].order_ticket, SELECT_BY_TICKET))
                     if(!OrderCloseTime())
                        if(OrderProfit() >= lotCost * OrderLots() * orders_info[i].trailing_start * TruePointValue(1))
                           CloseOrder(orders_info[i].order_ticket);
               }
            }
         }
      }
      
      //risk management
      //icreases risks
      ControlRisks("increase", reserveProfit);
         
      //deleting marked orders
      int numOrdForDeleting = 0;
      for(int i = 0; i < size_of_orders_metadata; i++)
         if(!orders_info[i].is_opened)
            numOrdForDeleting++;
      ORDER_INFO newOrders[];
      ArrayResize(newOrders, size_of_orders_metadata - numOrdForDeleting);
      for(int i = 0, k = 0; i < size_of_orders_metadata; i++)
         if(orders_info[i].is_opened)
            newOrders[k++] = orders_info[i];
      size_of_orders_metadata = size_of_orders_metadata - numOrdForDeleting;
      ArrayResize(orders_info, size_of_orders_metadata);
      for(int i = 0; i < size_of_orders_metadata; i++)
            orders_info[i] = newOrders[i];
      
      lastTimeOfFeaturedAligning = getTimeStamp(true);
   }
   
   //common aligning
   TrailOrders();
   
   datetime now = getTimeStamp(true);
   if(TimeDayOfWeek(now) == 5 && TimeHour(now) >= 21){
      for(int i = 0; i < size_of_orders_metadata; i++)
         if(orders_info[i].is_opened)
            CloseOrder(orders_info[i].order_ticket, true);
   }
}

bool COMMON_TRADING_STRATEGY::IsDangerousOrder(int order_index){
   bool dangerousOrder = false;
   
   int fDiff = realFundamentalStateForBuy - realFundamentalStateForSell;
      
   if(((marketMood != VOID_SIGNAL && orders_info[order_index].opening_signal != marketMood) &&
         (efficientDuration && (getTimeStamp(true) - orders_info[order_index].open_time > efficientDuration))) || 
            (GetFundamentalStateDegree() >= 1 && ((orders_info[order_index].opening_signal == BUY_SIGNAL && fDiff < 3 ) || (orders_info[order_index].opening_signal == SELL_SIGNAL && fDiff > 3))))
            dangerousOrder = true;
            
   return dangerousOrder;
}

bool COMMON_TRADING_STRATEGY::AllowedToTrade(void){
   static ulong prevCheckingTime = 0;
   static double decreasingRisk = 0; 
  
   if(currentActualSolution.signal == VOID_SIGNAL)
      return false;
      
   datetime now = getTimeStamp(true);
   if(TimeDayOfWeek(now) == 5 && TimeHour(now) >= 21)
      return false;
   
   //checking by fundamental analysis
   int fBSDiff = realFundamentalStateForBuy - realFundamentalStateForSell;
   
   int fState = GetFundamentalStateDegree();
   int fMood = GetFundamentalMoodDegree();
   
   if(fMood >= 3 && !fState)
      return false;
   
   if(fState >= 2 && ((currentActualSolution.signal == BUY_SIGNAL && fBSDiff < 5) || (currentActualSolution.signal == SELL_SIGNAL && fBSDiff > 5)))
      return false;
      
   //checking by missing time   
   if(timeForMissing && (!fState)){
      if(!prevCheckingTime)
         prevCheckingTime = getTimeStamp(true);
      if(getTimeStamp(true) - prevCheckingTime <= timeForMissing)
         return false;
   }
  
   //checking by frequent openings, by same solution
   ulong prev_opening_time = 0;
   bool is_based_on_same_solution = false;
   for(int i = size_of_orders_metadata - 1; i >= 0; i--)
      if(orders_info[i].is_opened){
         if(!prev_opening_time)
             prev_opening_time = orders_info[i].open_time;
         if(orders_info[i].controllingSolution.criterion == currentActualSolution.criterion && 
               orders_info[i].controllingSolution.priority == currentActualSolution.priority)
         {
            is_based_on_same_solution = true;
            break;
         }
      }
   
   if(is_based_on_same_solution && fState < 2)
      return false;   
   
   if(!fState < 2 && 
    getTimeStamp(true) - prev_opening_time <= 
         (((currentActualSolution.signal == SELL_SIGNAL && curDesiredSignal > 0) || (currentActualSolution.signal == BUY_SIGNAL && curDesiredSignal < 0) || fState >= 1)?3:7) * minimalTimeUnit)
      return false;
   
   RefreshRates();
   
   //checking by quantity of orders
   int maximalQuantity = tIOptimalNumOfOrders;
   if(marketMood == currentActualSolution.signal && marketMood != VOID_SIGNAL){
      maximalQuantity += MathFloor((double) tIOptimalNumOfOrders / (double) 2);
   }
   else if(marketMood != VOID_SIGNAL && fState < 2){
      maximalQuantity -= MathCeil((double) tIOptimalNumOfOrders / (double) 3);
   }
   if(maximalQuantity < 1)
      maximalQuantity = 1;
   
   int buyOrders = 0;
   int sellOrders = 0;
   double summaryProfitOfBuyOrders = 0;
   double summaryProfitOfSellOrders = 0;
   double reserveProfit = 0;
   double lotCost = MarketInfo(l5Symbol, MODE_TICKVALUE);
   double tickSize = MarketInfo(l5Symbol, MODE_TICKSIZE);
   
   //checking by previous orders
   int prevOrderType = VOID_SIGNAL;
   double prevOrderProfit = 0;
   double summaryPrevProfit = 0;
   int count = 0;
 
   for(int i = 0; i < size_of_orders_metadata; i++){
      if(orders_info[i].is_opened && OrderSelect(orders_info[i].order_ticket, SELECT_BY_TICKET, MODE_TRADES)){
            if(OrderType() == OP_SELL){
               sellOrders++;
               summaryProfitOfSellOrders += OrderProfit();
               reserveProfit += (lotCost*OrderLots()*(OrderOpenPrice() - OrderStopLoss()) / tickSize * TruePointValue(1));
            }
            if(OrderType() == OP_BUY){
               buyOrders++;
               summaryProfitOfBuyOrders += OrderProfit();
               reserveProfit += (lotCost*OrderLots()*(OrderStopLoss() - OrderOpenPrice()) / tickSize * TruePointValue(1));
            }
      }
   }
   
   for(int i = ordersHistory.size - 1; i >= 0; i--){   
      ORDER_INFO info = ordersHistory.history[i];
      if(count < 4){
          if(count == 0){
               prevOrderType = info.opening_signal;
               prevOrderProfit = info.profit;
          }
         
         summaryPrevProfit += info.profit;
         count++;
      }    
   }
   
   if(prevOrderProfit >= 0)
      decreasingRisk = 0;
   else if(prevOrderType == currentActualSolution.signal)
      decreasingRisk = decreasingRisk != 0?(decreasingRisk + (1 - decreasingRisk) * 0.3):0.4;
   else if(prevOrderType != currentActualSolution.signal)
      decreasingRisk = decreasingRisk != 0?(decreasingRisk + (1 - decreasingRisk) * 0.15):0.2;
   if(decreasingRisk > 0.9)
      decreasingRisk = 0.9;
    
   double newRisk = allowedRiskOnOnePosition;
   if(decreasingRisk != 0)
      newRisk = newRisk * decreasingRisk;
      
   if(!ControlRisks("decrease", reserveProfit, buyOrders + sellOrders, newRisk))
      return false;
   
   double potentialLoss = lotCost*curLots*curStopLoss*TruePointValue(1);
   
   //checking by intersect orders
   if(currentActualSolution.signal == SELL_SIGNAL && summaryProfitOfBuyOrders < potentialLoss / ((fState >= 2 || marketMood == SELL_SIGNAL)?1.5:1) && buyOrders)
   {
	  if(sellOrders){
		  for(int i = 0; i < size_of_orders_metadata; i++)
			if(orders_info[i].is_opened && 
			orders_info[i].opening_signal == SELL_SIGNAL && 
			Bid - orders_info[i].open_price < potentialLoss / 1.5)
				return false;	
	  }
	   
      if(fState < 3)
         return false;
   }
    
   if(currentActualSolution.signal == BUY_SIGNAL && summaryProfitOfSellOrders < potentialLoss / ((fState >= 2 || marketMood == BUY_SIGNAL)?1.5:1) && sellOrders)
   {
      if(buyOrders){
		  for(int i = 0; i < size_of_orders_metadata; i++)
			if(orders_info[i].is_opened && 
			orders_info[i].opening_signal == BUY_SIGNAL && 
			orders_info[i].open_price - Ask < potentialLoss / 1.5)
				return false;	
	   }
	   
     if(fState < 3)
         return false;
   }   
      
   //checking by additional orders
   if(currentActualSolution.signal == BUY_SIGNAL && summaryProfitOfBuyOrders > -potentialLoss / ((fState >= 2 || marketMood == BUY_SIGNAL)?1.2:1) && buyOrders)
   {
	  if(buyOrders){
		  for(int i = 0; i < size_of_orders_metadata; i++)
			if(orders_info[i].is_opened && 
			orders_info[i].opening_signal == BUY_SIGNAL && 
			orders_info[i].open_price - Ask < potentialLoss / 1.2)
				return false;	
	  } 
	   
     if(fState < 2)
         return false;
   }
   
   if(currentActualSolution.signal == SELL_SIGNAL && summaryProfitOfSellOrders > -potentialLoss / ((fState >= 2 || marketMood == SELL_SIGNAL)?1.2:1) && sellOrders)
   {
	   if(sellOrders){
		  for(int i = 0; i < size_of_orders_metadata; i++)
			if(orders_info[i].is_opened && 
			orders_info[i].opening_signal == SELL_SIGNAL && 
			Bid - orders_info[i].open_price < potentialLoss / 1.2)
				return false;	
	  } 
	   
     if(fState < 2)
         return false;
   }
      
   if(buyOrders + sellOrders >= maximalQuantity)
      return false;
   
   if(prevOrderType != currentActualSolution.signal && prevOrderProfit < 0 && fState < 3)
   {
      if(!pricesForChecking[0]){
         RegisterPriceForChecking(0);
         return false;  
      }
      else{
         double units = GetMinimalUnitOfPriceChange();
         if(GetPriceChanges(0) > -units && prevOrderType == SELL_SIGNAL)
            return false;
         if(GetPriceChanges(0) < units && prevOrderType == BUY_SIGNAL)
            return false;
         pricesForChecking[0] = 0;
      }
   }
   else
      pricesForChecking[0] = 0;
    
   if(prevOrderProfit < 0){
      if(!pricesForChecking[1]){
         RegisterPriceForChecking(1);
         return false;  
      }
      else{
         double units = GetMinimalUnitOfPriceChange() / 2;
         if(MathAbs(GetPriceChanges(1)) < units)
            return false;
         pricesForChecking[1] = 0;
      }
   }
   else
       pricesForChecking[1] = 0;
       
   if(prevOrderType == currentActualSolution.signal && prevOrderProfit >= 0 && fState < 3){
      if(!pricesForChecking[3]){
         RegisterPriceForChecking(3);
         prevCheckingTime = getTimeStamp(true);
         return false;  
      }
      else{
         bool isTimeLimited = false;
         if(getTimeStamp(true) - prevCheckingTime > 3600){
            isTimeLimited = true;
         }
      
         double units = GetMinimalUnitOfPriceChange();
         if(GetPriceChanges(3) < units && prevOrderType == SELL_SIGNAL && !isTimeLimited)
            return false;
         if(GetPriceChanges(3) > -units && prevOrderType == BUY_SIGNAL && !isTimeLimited)
            return false;
            
         pricesForChecking[3] = 0;
      }
   }
   else
      pricesForChecking[3] = 0;
   
   if(summaryPrevProfit < 0 && !prevCheckingTime && fState < 2){
      prevCheckingTime = 0;
      timeForMissing = minimalTimeUnit * 3;
      return false;
   }
   
   prevCheckingTime = 0;
   timeForMissing = 0;
  
   return true;
}

void COMMON_TRADING_STRATEGY::TradingInterface(){
   CommonTradingInterface();
}

float COMMON_TRADING_STRATEGY::AdvantageCriterion(int fr, int criterion_num, int pr){
   if(!fr && criterion_num == 2)
       pr = pr - pr*0.03;
   return pr;
}

//-----------------------------------------------------------------------------------------
//                               LOW RISK TRADING STRATEGY
//-----------------------------------------------------------------------------------------

class LOW_RISK_TRADING_STRATEGY : public TRADING {
   protected:
      virtual  bool IsDangerousOrder(int order_index);
      virtual void TradingInterface();
      virtual bool AllowedToTrade();
      virtual void AlignOrders(bool force = false);
      virtual float AdvantageCriterion(int fr, int criterion_num, int original_pr);
      
   public:
      LOW_RISK_TRADING_STRATEGY();
      ~LOW_RISK_TRADING_STRATEGY();
      virtual void Trade();
};

LOW_RISK_TRADING_STRATEGY::LOW_RISK_TRADING_STRATEGY(void){
   curDesiredAverageTimeframe = PERIOD_M15;
   
   AlignOrders(true);
}

LOW_RISK_TRADING_STRATEGY::~LOW_RISK_TRADING_STRATEGY(void){

}

void LOW_RISK_TRADING_STRATEGY::Trade(){
   
   int fState = GetFundamentalStateDegree();
   
   if(getTimeStamp(true) - lastTimeOfSelecting > (fState > 2?10:intervalInSelecting)){
        Selecting();
        //Take decision
        if(AllowedToTrade()){
            AddOrder();
        }
        lastTimeOfSelecting = getTimeStamp(true);
    } 
    
    AlignOrders(); 
    
    FundamentalAnalysis();
    TradingInterface();
}

void LOW_RISK_TRADING_STRATEGY::AlignOrders(bool force){

   if(size_of_orders_metadata == 0 && !force)
      return;

   int fState = GetFundamentalStateDegree();
   int fDiff = realFundamentalStateForBuy - realFundamentalStateForSell;

   if(getTimeStamp(true) - lastTimeOfFeaturedAligning > intervalInSelecting + 10 || fState > 2 || force){
      RefreshRates();
      int ordersOpened = 0;
      
      for(int i = 0; i < size_of_orders_metadata; i++){
         //mark of deleted orders;
         if(orders_info[i].is_opened){
            bool deleteOrder = true;
            double profitOrder = 0;
            
            if(OrderSelect(orders_info[i].order_ticket, SELECT_BY_TICKET))
               if(!OrderCloseTime()){
                  deleteOrder = false;
               }
               else{
                  profitOrder = OrderProfit() + OrderSwap() + OrderCommission();
               }
           
            if(deleteOrder){
               orders_info[i].is_opened = false; 
               orders_info[i].close_time = getTimeStamp(true);
               orders_info[i].profit = profitOrder;
               ordersHistory.Push(orders_info[i]);
            }
         }
      
         if(orders_info[i].is_opened){
            bool not_close = (((orders_info[i].opening_signal == BUY_SIGNAL && fDiff > 3) || (fDiff < 3 && orders_info[i].opening_signal == SELL_SIGNAL)) && fState >= 1 || fState >= 2);
            bool force_close = (((orders_info[i].opening_signal == BUY_SIGNAL && fDiff < 0) || (orders_info[i].opening_signal == SELL_SIGNAL && fDiff > 0))&& fState >= 2);
            
            if(force_close){
               CloseOrder(orders_info[i].order_ticket, true);
            }
            else if(!not_close){
               
            }
         }
      }
      
      //risk management
      //increases risks
      ControlRisks("increase_of_low_risk_strategy", 0);
         
      //deleting marked orders
      int numOrdForDeleting = 0;
      for(int i = 0; i < size_of_orders_metadata; i++)
         if(!orders_info[i].is_opened)
            numOrdForDeleting++;
      ORDER_INFO newOrders[];
      ArrayResize(newOrders, size_of_orders_metadata - numOrdForDeleting);
      for(int i = 0, k = 0; i < size_of_orders_metadata; i++)
         if(orders_info[i].is_opened)
            newOrders[k++] = orders_info[i];
      size_of_orders_metadata = size_of_orders_metadata - numOrdForDeleting;
      ArrayResize(orders_info, size_of_orders_metadata);
      for(int i = 0; i < size_of_orders_metadata; i++)
            orders_info[i] = newOrders[i];
      
      lastTimeOfFeaturedAligning = getTimeStamp(true);
   }
   
   //common aligning
   TrailOrders();

   datetime now = getTimeStamp(true);
   if(TimeDayOfWeek(now) == 5 && TimeHour(now) >= 21){
      for(int i = 0; i < size_of_orders_metadata; i++)
         if(orders_info[i].is_opened)
            CloseOrder(orders_info[i].order_ticket, true);
   }
}

bool LOW_RISK_TRADING_STRATEGY::IsDangerousOrder(int order_index){
   bool dangerousOrder = false;
   
   int fDiff = realFundamentalStateForBuy - realFundamentalStateForSell;
      
   if((orders_info[order_index].limited_duration && (getTimeStamp(true) - orders_info[order_index].open_time) > orders_info[order_index].limited_duration) || 
          (GetFundamentalStateDegree() >= 1 && ((orders_info[order_index].opening_signal == BUY_SIGNAL && fDiff < 3 ) || (orders_info[order_index].opening_signal == SELL_SIGNAL && fDiff > 3))))
            dangerousOrder = true;
            
   return dangerousOrder; 
}

bool LOW_RISK_TRADING_STRATEGY::AllowedToTrade(void){
   if(currentActualSolution.signal == VOID_SIGNAL)
      return false;
   
   datetime now = getTimeStamp(true);
   if(TimeDayOfWeek(now) == 5 && TimeHour(now) >= 21)
      return false;
   
   int fState = GetFundamentalStateDegree();
   int fBSDiff = realFundamentalStateForBuy - realFundamentalStateForSell;
   
   if(GetFundamentalMoodDegree() >= 3 && fState)
      return false;
   
   if(fState >= 3 && ((currentActualSolution.signal == BUY_SIGNAL && fBSDiff < 5 && fBSDiff) || (currentActualSolution.signal == SELL_SIGNAL && fBSDiff > 5 && fBSDiff)))
      return false;
   
   RefreshRates();
   
   //checking by quantity of orders
   int maximalQuantity = 1;
   int num_orders = 0;
   
   for(int i = 0; i < size_of_orders_metadata; i++){
       if(orders_info[i].is_opened && OrderSelect(orders_info[i].order_ticket, SELECT_BY_TICKET, MODE_TRADES)){
            num_orders++;
       }
   }
   
   if(num_orders >= maximalQuantity)
      return false;
   
   if(!ControlRisks("decrease", 0, num_orders))
      return false;
    
   return true;
}

void LOW_RISK_TRADING_STRATEGY::TradingInterface(){
   CommonTradingInterface();
}

float LOW_RISK_TRADING_STRATEGY::AdvantageCriterion(int fr, int criterion_num, int pr){
   if(!fr && criterion_num == 2)
       pr = pr - pr*0.13;
   return pr;
}