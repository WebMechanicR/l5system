//+------------------------------------------------------------------+
//|                                          running_environment.mqh |
//|             Copyright 2014, Tim Jackson <webmechanicr@gmail.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Tim Jackson <webmechanicr@gmail.com>"
#property link      ""
#property strict

/*
 * SYSTEM INFO CLASS
 * The class created for accessing to system settings
 */
 
class SYSTEM_INFO{
	public:
		void Set(string key, string val, string symbol = "");
		
		string Get(string key, string symbol = "");
};

void SYSTEM_INFO::Set(string key, string val, string symbol){
   StringToLower(symbol);
	l5Db.Query("INSERT INTO system_info (gkey, symbol, value) VALUES ('" + key + "', '" + symbol + "', '" + val + "') ON DUPLICATE KEY UPDATE value = '" + val + "'");
	return;
}

string SYSTEM_INFO::Get(string key, string symbol){
	string result;
	StringToLower(symbol);
	bool res = l5Db.Query("SELECT value FROM system_info WHERE gkey = '" + key + "' AND symbol = '" + symbol + "'");
	if(res && l5Db.Rows()){
		result = l5Db.result[0].f[0];
	}
	return result;
}
 
 /*
  * END SYSTEM INFO
  */

/*
 * PACKET CLASS
 * The class implements of operations with groups of indicators and their arguments
 */
 
 class PACKET{
   private:
      int indicatorIndexes[];
      mstring argHashes[];
      int size;
      int reserved;
      int signal;
      ulong timeStamp;
      
   public:
      PACKET():size(0),reserved(0),signal(0),timeStamp(0){};
      void AddIndicator(int indicatorIndex, mstring& hash);
      void RemoveIndicator(int index);
      bool GetIndicator(int index, int& outIndex, ARG_LIST& outArgs);
      bool Reserve(int resSize);
      int Size();
      void Clear();
      void SetSignal(int arg);
      int GetSignal();
      void SetTimeStamp(ulong timeStamp);
      ulong GetTimeStamp();
      mstring GetPacketHash();
      bool BuildPacketByHash(mstring& hash);
 };
 
 void PACKET::AddIndicator(int indicatorIndex, mstring& args){
     if(reserved > size){
         indicatorIndexes[size] = indicatorIndex;
         argHashes[size] = args;
         size++;
         return;
     }
     
     int oldIndexes[];
     mstring oldArgs[];
     ArrayResize(oldIndexes, size);
     ArrayResize(oldArgs, size);
     ArrayCopy(oldIndexes, indicatorIndexes);
     for(int i = 0; i < size; i++)
         oldArgs[i] = argHashes[i];
     ArrayResize(indicatorIndexes, size+1);
     ArrayResize(argHashes, size+1);
     ArrayCopy(indicatorIndexes, oldIndexes);
     indicatorIndexes[size] = indicatorIndex;
     for(int i = 0; i < size; i++)
         argHashes[i] = oldArgs[i];
     argHashes[size] = args;
     
     size++;
     reserved++;
     return;
 }
 
 void PACKET::RemoveIndicator(int index){
   if(index >= 0 && index < size){
      for(int i = 0, j = 0; i < size; i++)
         if(i != index)
            argHashes[j++] = argHashes[i];
      for(int i = 0, j = 0; i < size; i++)
         if(i != index)
            indicatorIndexes[j++] = indicatorIndexes[i];
      size--;
   }  
   return; 
 }
 
 bool PACKET::GetIndicator(int index, int& indIndex, ARG_LIST& args){
   bool res = false;
   if(index >= 0 && index < size){
      indIndex = indicatorIndexes[index];
      
      if(args.SetListByHash(argHashes[index].InS()))
         res = true;
   }
   
   return res;
 }
 
 int PACKET::Size(){
   return size;
 }
 
 bool PACKET::Reserve(int resSize){
     int oldIndexes[];
     mstring oldArgs[];
     ArrayResize(oldIndexes, size);
     ArrayResize(oldArgs, size);
     ArrayCopy(oldIndexes, indicatorIndexes);
     for(int i = 0; i < size; i++)
         oldArgs[i] = argHashes[i];
     ArrayResize(indicatorIndexes, resSize);
     ArrayResize(argHashes, resSize);
     ArrayCopy(indicatorIndexes, oldIndexes);
     for(int i = 0; i < ((resSize > size)?size:resSize); i++)
         argHashes[i] = oldArgs[i];
     if(resSize < size)
      size = resSize;
     reserved = resSize;
     
     return true;
 }
 
 void PACKET::Clear(){
   ArrayFree(indicatorIndexes);
   ArrayFree(argHashes);
   size = reserved = 0;
   signal = 0;
   timeStamp = 0;
 }
 
 void PACKET::SetSignal(int arg){
   if(arg == VOID_SIGNAL ||
      arg == BUY_SIGNAL ||
      arg == SELL_SIGNAL)
         signal = arg;
 }
 
 int PACKET::GetSignal(){
   return signal;
 }
 
 mstring PACKET::GetPacketHash(){
   mstring result;
   if(size != 0){
      string res = ""; 
      for(int i = 0; i < size; i++){
        
         res = res + (indMan.GetIndicator(indicatorIndexes[i]).GetName() + "|*|" + argHashes[i].InS());
         if(i != size - 1)
            res = res + "|*I*|";
      }
      result = res;
   };
   return result;
 }
 
 bool PACKET::BuildPacketByHash(mstring& hash){
      bool res = false;
      string sHash = hash.InS();
      string indicators[];
      if(preg_match_split("\|\*I\*\|", sHash, indicators)){
         int newSize = ArraySize(indicators);
         Reserve(newSize);
         size = newSize;
         string indicator[];
         for(int i = 0; i < size; i++){
            if(preg_match_split("\|\*\|", indicators[i], indicator)){
               string iName = indicator[0];
               string iArgs = indicator[1];
               /*signal = (int) StringToInteger(indicator[2]);
               if(signal != BUY_SIGNAL && signal != SELL_SIGNAL){
                  Clear();
                  break;
               }*/
               int foundIndex = -1;
               for(int j = 0; j < indMan.GetNumIndicators(); j++)
                  if(indMan.GetIndicator(j).GetName() == iName)
                  {
                     foundIndex = j;
                     break;
                  }
               
               if(foundIndex == -1){
                  Clear();
                  break;
               }
               else{
                  indicatorIndexes[i] = foundIndex;
               }
               ARG_LIST test;
               if(!test.SetListByHash(iArgs)){
                  Clear();
                  break;
               }
               else{
                  argHashes[i] = iArgs;
               }
            }
            else{
               Clear();
               break;
            }
         } 
         
         if(size != 0)
            res = true;
      }
      
      return res;
 }
 
 void PACKET::SetTimeStamp(ulong arg){
   timeStamp = arg;
 }
 
 ulong PACKET::GetTimeStamp(void){
   return timeStamp;
}

 /*
  * END PACKET CLASS
  */
  
  
 /*
  * SOLUTION CLASS
  * The class represents data row from list of solutions
  */
  
 class SOLUTION{
   public:
      int signal;
      int signal_moment;
      int is_closing_signal;
      
      int criterion;
      int priority;
    
      PACKET inPacket;
      PACKET outPacket;
      int desired_signal;
      int adapted_by_duration;
      int average_timeframe;
      
      SOLUTION(){
         Flush();
      }
      void operator=(const SOLUTION& right);
      SOLUTION(const SOLUTION& right);
      
      int AskSolution(bool only_closing = false);
      void Flush();
      string ToString();
      bool FromString(string arg);
 };
 
 string SOLUTION::ToString(){
     string result = StringConcatenate(
            IntegerToString(signal), "|*SOL*|",
            IntegerToString(signal_moment), "|*SOL*|",
            IntegerToString(is_closing_signal), "|*SOL*|",
            IntegerToString(criterion), "|*SOL*|",
            IntegerToString(priority), "|*SOL*|",
            IntegerToString(desired_signal), "|*SOL*|",
            IntegerToString(adapted_by_duration), "|*SOL*|",
            IntegerToString(average_timeframe), "|*SOL*|",
            inPacket.GetPacketHash().InS(), "|*SOL*|",
            outPacket.GetPacketHash().InS()
         );
     return result;       
 }
 
 bool SOLUTION::FromString(string arg){
     if(arg == "")
         return false;
     string args[];
     if(preg_match_split("\|\*SOL\*\|", arg, args)){
         if(ArraySize(args) != 10)
            return false;
         
         signal = StringToInteger(args[0]);
         signal_moment = StringToInteger(args[1]);
         is_closing_signal = StringToInteger(args[2]);
         criterion  = StringToInteger(args[3]);
         priority = StringToInteger(args[4]);
         desired_signal = StringToInteger(args[5]);
         adapted_by_duration = StringToInteger(args[6]);
         average_timeframe = StringToInteger(args[7]);
         mstring hash = args[8];
         if(!inPacket.BuildPacketByHash(hash))
            return false;
         hash = args[9];
         if(!outPacket.BuildPacketByHash(hash))
            return false;   
     }
     else 
         return false;
         
     return true;
 }
 
 void SOLUTION::operator=(const SOLUTION& right){
   signal = right.signal;
   is_closing_signal = right.is_closing_signal;
   criterion = right.criterion;
   priority = right.priority;
   desired_signal = right.desired_signal;
   adapted_by_duration = right.adapted_by_duration;
   signal_moment = right.signal_moment;
   average_timeframe = right.average_timeframe;
   
   mstring hash = right.inPacket.GetPacketHash();
   inPacket.BuildPacketByHash(hash);
   hash = right.outPacket.GetPacketHash();
   outPacket.BuildPacketByHash(hash);
 }
 
 SOLUTION::SOLUTION(const SOLUTION& right){
   operator=(right);
 }
 
 void SOLUTION::Flush(){
   inPacket.Clear();
   outPacket.Clear();
   signal = is_closing_signal = VOID_SIGNAL;
   criterion = priority = 0;        
   desired_signal = 0;
   adapted_by_duration = 0;
   signal_moment = 0;
   average_timeframe = 0;
 }
 
 int SOLUTION::AskSolution(bool only_closing){
      int res = VOID_SIGNAL;
      RefreshRates();
      
      int defaultSignal = VOID_SIGNAL;
      average_timeframe = 0;
      if(!only_closing){
         int with_timeframes = 0;
         for(int j = 0; j < inPacket.Size(); j++){
            int indicatorIndex;
            ARG_LIST args;
            inPacket.GetIndicator(j, indicatorIndex, args);
            INDICATOR* ind = indMan.GetIndicator(indicatorIndex);
            if(ind.IsByTimeframes()){
               average_timeframe += StringToInteger(args.Get(0));
               with_timeframes++;
            }
            ind.SetArgs(args);
            int ssignal = ind.Perform();
            if(j == 0)
               defaultSignal = ssignal;
            else if(defaultSignal != ssignal){
                defaultSignal = VOID_SIGNAL;
            }
         }
         
         if(with_timeframes)
            average_timeframe = MathRound((double) average_timeframe / (double) with_timeframes);
      }
      
      int closingSignal = VOID_SIGNAL;
      if(only_closing || defaultSignal){
          for(int j = 0; j < outPacket.Size(); j++){
            int indicatorIndex;
            ARG_LIST args;
            outPacket.GetIndicator(j, indicatorIndex, args);
            indMan.GetIndicator(indicatorIndex).SetArgs(args);
            int ssignal = indMan.GetIndicator(indicatorIndex).Perform();
            if(j == 0)
               closingSignal = ssignal;
            else if(closingSignal != ssignal){
                closingSignal = VOID_SIGNAL;
            } 
         }
         
         if((defaultSignal != VOID_SIGNAL && closingSignal != VOID_SIGNAL) || (only_closing && closingSignal != VOID_SIGNAL)){
                  is_closing_signal = VOID_SIGNAL;
                  if(!only_closing){
                     if((defaultSignal == SELL_SIGNAL && closingSignal == BUY_SIGNAL) || (defaultSignal == BUY_SIGNAL && closingSignal == SELL_SIGNAL))
                        is_closing_signal = closingSignal;
                        
                     if(is_closing_signal == VOID_SIGNAL){
                        closingSignal = VOID_SIGNAL;
                     }
                  }
                  else
                     is_closing_signal = closingSignal;
          }
          else
            is_closing_signal = VOID_SIGNAL;
      }
      
      if(only_closing)
         res = closingSignal;
      else
         res = defaultSignal;
      
      if(defaultSignal == VOID_SIGNAL)
         signal_moment = 0;
      else if(signal != defaultSignal)
         signal_moment = getTimeStamp(true);
      
      signal = defaultSignal;
      
      return res;
 }
  
 /*
  * END SOLUTION CLASS
  */
  
  /*
   * ASKER CLASS
   * The class implements methods using in asking of indicators
   */
   
class ASKER{
      private:
         int prevAskedIndicatorIndex;
         int prevAskedIndicatorIndexInDefaultArgsAsking;
         int prevAskedArgListIndexInDefaultArgsAsking;
         int prevAskedArgListIndex[];
         ARG_LIST defaultArgs[];
         int defaultArgsMetaData[][2];
         ulong askedIndicatorsNum;
         ulong askedIndicatorsNumWithDefaultArgs;
         ulong allAskedIndicators;
         ulong allAskedIndicatorsWithDefArgs;
         ulong startAllAsking;
         bool startOfAsking;
         
         int builtPacketsNum;
         void CombinatePackets(int numOfS, int& indicatorsOfS[], int& signalsOfS[], mstring& argsHashesOfS[], PACKET& outPackets[]);
         int BuildPackets(int& I[], int sizeOfI, int& indicatorsOfS[], int& signalsOfS[], mstring& argsHashesOfS[], PACKET& outPackets[], int limit);
         
         ulong builtPacketsHashes[];
         int builtPacktesHashesNum;
         ulong builtPacketsCacheS1;
         
         int startPosOfSignalsCache[];
         char signalCache[];
         unsigned int prevTimeOfResetCache;
         int continueAskingOfDefArgs;
         
         ulong lastTimeOfAskingByPackets;
         SOLUTION cachedSolutions[];
         int sizeOfSolutionsCache;
         
      public:
         ASKER();
         void AskIndicators(PACKET& outPackets[]);
         bool AskSolutions(SOLUTION& out[], int& outsize, int criterion = 0, int limit = 0);
         void AskAllWithDefaultArg(PACKET& outPackets[]);
         void ReloadDefaultArgs(bool forceStart = false);
         ulong GetAskedIndicatorsNum();
         ulong GetDefaultIndicatorsNum();
         ulong GetAllAskedIndicators();
         ulong GetAllAskedIndicatorsWithDefArgs();
         ulong GetMaxAllPacketsNumWithDefArgs();
         int GetBuiltPacketsNum();
         void ResetPacketsCache();
         void ResetSignalCache(); 
};

ASKER::ASKER(){
   maxWaitingIntervalInAsking = (6 * ((double) maxNumberOfReceivedSignalsInAsking / 18));
   askedIndicatorsNum = 0;
   askedIndicatorsNumWithDefaultArgs = 0;
   maxWaitingIntervalInGeneratingOfPackets = 5; //seconds
   maxSizeForCacheOfBuiltPackets = 10;
   maxWaitingIntervalForCacheOfBuiltPackets = 5; //seconds
   continueAskingOfDefArgs = 0;
   lastTimeOfAskingByPackets = 0;
   
   ArrayResize(prevAskedArgListIndex, indMan.GetNumIndicators());
   ArrayFill(prevAskedArgListIndex, 0, indMan.GetNumIndicators(), 0);
   ArrayResize(defaultArgsMetaData, indMan.GetNumIndicators());
   
   prevAskedIndicatorIndex = 0;
   prevAskedIndicatorIndexInDefaultArgsAsking = 0;
   prevAskedArgListIndexInDefaultArgsAsking = 0;
   startAllAsking = GetTickCount();
   startOfAsking = true;
   
   ReloadDefaultArgs(true);
   ResetPacketsCache();
}

void ASKER::ReloadDefaultArgs(bool forceStart=false){
   if(needInReloadDefaultArgs || forceStart){
      needInReloadDefaultArgs = false;
      
      MsgPrint("loading of indicators default arguments");
      
      int defaultArgsNum = 0;
      int prevPos = 0;
      allAskedIndicators = 0;
      for(int i = 0; i < indMan.GetNumIndicators(); i++){
         INDICATOR* ind = indMan.GetIndicator(i);
         ulong start1 = GetTickCount();
         int size = indMan.GetArgQueueSize(i);
         ulong start2 = GetTickCount();
         //MsgPrint("generating arguments of " + ind.GetName() + " has been completed: " + (string) size + " args; " + (string) (start2 - start1) + " ms");
         allAskedIndicators += size;
         
         size = ((size > timeFramesLimit)?timeFramesLimit:size);
         
         defaultArgsMetaData[i][0] = prevPos;
         defaultArgsMetaData[i][1] = prevPos + (size - 1);
         prevPos = prevPos + size;
         
         defaultArgsNum += size;
      }
      
      allAskedIndicatorsWithDefArgs = defaultArgsNum;
      
      MsgPrint("Arg reloading: " + (string) allAskedIndicators + " signals totally");
      MsgPrint("Arg reloading: " + (string) allAskedIndicatorsWithDefArgs + " signals with def args totally");
     
      int d = MathCeil(allAskedIndicatorsWithDefArgs / maxNumberOfReceivedSignalsInAsking);
      allAskedIndicatorsWithDefArgsGlobal = allAskedIndicatorsWithDefArgs;
      ulong imRes = 0;
      for(int j = 0; j < allAskedIndicatorsWithDefArgs; j++){
            for(int i = 1; i <= numberOfPacketsForIntersect; i++){
               imRes += (Factorial(maxNumberOfReceivedSignalsInAsking) / (Factorial(i) * Factorial(maxNumberOfReceivedSignalsInAsking - i)));
            } 
      }
      maxAllPacketsNumWithDefArgs = imRes;
      
      /*
      //TO DO for all signals
      Comment("Arg reloading: " + (string) maxAllPacketsNumWithDefArgs + " packets with def args totally");
      Print("Arg reloading: " + (string) maxAllPacketsNumWithDefArgs + " packets with def args totally");
      */
      
      ArrayResize(defaultArgs, defaultArgsNum);
      for(int i = 0; i < indMan.GetNumIndicators(); i++){
         for(int j = defaultArgsMetaData[i][0], k = 0; j <= defaultArgsMetaData[i][1]; j++)
            defaultArgs[j] = indMan.GetArgList(i, k++);
      }
      ResetSignalCache();
      MsgPrint("loading of indicators default arguments has been completed successful");
   }
}

void ASKER::ResetSignalCache(){
   ArrayResize(startPosOfSignalsCache, indMan.GetNumIndicators());
   ArrayResize(signalCache, (int) allAskedIndicators);
   ArrayFill(signalCache, 0, allAskedIndicators, 0);
   prevTimeOfResetCache = getTimeStamp();
   int sIndex = 0;
   for(int i = 0; i < indMan.GetNumIndicators(); i++){
      int size = indMan.GetArgQueueSize(i);
         startPosOfSignalsCache[i] = sIndex;
         sIndex = size;
   }
}

bool ASKER::AskSolutions(SOLUTION& out[], int& outsize, int criterion, int limit){
   sizeOfSolutionsCache = numGeneratedSolutions * definedNumCriterions;
   
   if(getTimeStamp(true) - lastTimeOfAskingByPackets > 1*3600){
      string symbol = l5Symbol;
      StringToLower(symbol);
      int curDesiredSignal = 0;
      
      bool res = false;
      
      
      int co = 0;
      while(!res && co++ < 5){
         l5Db.ReConnect();
         res = l5Db.Query("SELECT inpacket, outpacket, criterion, priority, desired_signal, adapted_by_duration FROM " + symbol + "_optimizer_solutions ORDER BY priority ASC");
      }
      
      int rowSize = l5Db.Rows();
      if(rowSize == sizeOfSolutionsCache && res){
         ArrayFree(cachedSolutions);
         ArrayResize(cachedSolutions, sizeOfSolutionsCache);
         
         int size = rowSize;
         for(int i = 0, r = 0; r < rowSize; r++){
            mstring inhash = l5Db.result[r].f[0];
            mstring outhash = l5Db.result[r].f[1];
            bool allowed = true;
            if(!cachedSolutions[i].inPacket.BuildPacketByHash(inhash)){
               ErrPrint("ASKER: Unknown packet hash in asking packets by requiring");
               allowed = false;
            }
            if(!cachedSolutions[i].outPacket.BuildPacketByHash(outhash)){
               ErrPrint("ASKER: Unknown packet hash in asking packets by requiring");
               allowed = false;
            }
            
            if(allowed){
               cachedSolutions[i].criterion = StringToInteger(l5Db.result[r].f[2]);
               cachedSolutions[i].priority = StringToInteger(l5Db.result[r].f[3]);
               cachedSolutions[i].desired_signal = StringToInteger(l5Db.result[r].f[4]);
               cachedSolutions[i].adapted_by_duration = StringToInteger(l5Db.result[r].f[5]);
               curDesiredSignal += (cachedSolutions[i].desired_signal == BUY_SIGNAL?1:-1);
              
               i++; 
               if(i >= sizeOfSolutionsCache)
                  break;
            }
            else
               size--;
         }
         
         desiredSignalBySolutions = curDesiredSignal;
         sizeOfSolutionsCache = size;
         lastTimeOfAskingByPackets = getTimeStamp(true);
      }
   }
   
   outsize = 0;
   int useful[];
   if(ArraySize(cachedSolutions) == sizeOfSolutionsCache){
      ArrayResize(useful, sizeOfSolutionsCache);
      int cindeces[];
      ArrayResize(cindeces, definedNumCriterions);
      ArrayFill(cindeces, 0, WHOLE_ARRAY, 0);
      int criterionIndex = 1;
      int count = 0;
      while(true){
         bool skip = false;
         int cind = criterionIndex;
         if(criterion && criterionIndex != criterion)
            skip = true;
            
        criterionIndex++;
        if(criterionIndex > definedNumCriterions)
               criterionIndex = 1;
             
        if(!skip && (!limit || outsize < limit)){
            for(int i = cindeces[cind - 1]; i < sizeOfSolutionsCache; i++){
               if(cachedSolutions[i].criterion == cind){
                  cindeces[cind - 1] = i + 1;
                  if(cachedSolutions[i].AskSolution() != VOID_SIGNAL){
                     useful[ outsize++ ] = i;
                     break;
                  }
               }
            }
         }
         
         if(++count >= sizeOfSolutionsCache)
               break;
      }
   }
   
   if(outsize){
      ArrayResize(out, outsize);
      for(int i = 0; i < outsize; i++){
         out[i] = cachedSolutions[useful[i]];
      }
   }
   return true;
}

/* TO DO 

void ASKER::AskIndicators(PACKET& outPackets[]){
   builtPacketsNum = 0;
   MathSrand(GetTickCount());
   int ownMaxNumberOfReceivedSignalsInAsking = maxNumberOfReceivedSignalsInAsking - MathAbs(MathRand() % (maxNumberOfReceivedSignalsInAsking/((maxNumberOfReceivedSignalsInAsking > 4)?4:2)));
   if(maxNumberOfReceivedSignalsInAsking == 1)
      ownMaxNumberOfReceivedSignalsInAsking = 1;
   mstring argHashesOfS[];
   int indicatorsOfS[];
   int signalsOfS[];
   int numOfS = 0;
   ArrayResize(argHashesOfS, ownMaxNumberOfReceivedSignalsInAsking);
   ArrayResize(indicatorsOfS, ownMaxNumberOfReceivedSignalsInAsking);
   ArrayResize(signalsOfS, ownMaxNumberOfReceivedSignalsInAsking);
   ulong start1 =  GetTickCount();
   ARG_LIST arg;
   while(true){
      int argSize = indMan.GetArgQueueSize(prevAskedIndicatorIndex);
      arg = indMan.GetArgList(prevAskedIndicatorIndex, prevAskedArgListIndex[prevAskedIndicatorIndex]);
      indMan.GetIndicator(prevAskedIndicatorIndex).SetArgs(arg);
      int signal = indMan.GetIndicator(prevAskedIndicatorIndex).Perform();
      char prevSignal = signalCache[startPosOfSignalsCache[prevAskedIndicatorIndex] + prevAskedArgListIndex[prevAskedIndicatorIndex]];
      
      if(signal != VOID_SIGNAL && signal != (int) prevSignal)
      {
         indicatorsOfS[numOfS] = prevAskedIndicatorIndex;
         argHashesOfS[numOfS] = arg.GetHash();
         signalsOfS[numOfS] = signal;
         numOfS++;
         signalCache[startPosOfSignalsCache[prevAskedIndicatorIndex] + prevAskedArgListIndex[prevAskedIndicatorIndex]] = (char) signal;
      }
      
      askedIndicatorsNum++;
      if(!startOfAsking && (allAskedIndicators % askedIndicatorsNum == 0)){
         Comment("All indicators have been asked in ", (GetTickCount() - startAllAsking) / 1000, " s");
         askingAllowed = false;
         startOfAsking = false;
         startAllAsking = GetTickCount();
      }
      
      prevAskedArgListIndex[prevAskedIndicatorIndex]++;
      if(prevAskedArgListIndex[prevAskedIndicatorIndex] == argSize)
         prevAskedArgListIndex[prevAskedIndicatorIndex] = 0;
      prevAskedIndicatorIndex++;
      if(prevAskedIndicatorIndex == indMan.GetNumIndicators())
         prevAskedIndicatorIndex = 0;
     
      if(numOfS == ownMaxNumberOfReceivedSignalsInAsking)
         break;
      
      ulong start2 = GetTickCount();
      if(MathRound(start2 - start1) >= MathRound(maxWaitingIntervalInAsking * 1000)){
         
         break;
      }
   }
   
  
   if(numOfS != 0)
      CombinatePackets(numOfS, indicatorsOfS, signalsOfS, argHashesOfS, outPackets);
   else{
      builtPacketsNum = 0;
      ArrayFree(outPackets);
   }
}

*/

void ASKER::AskAllWithDefaultArg(PACKET &outPackets[]){
  builtPacketsNum = 0;
  
  MathSrand(GetTickCount());
  int ownMaxNumberOfReceivedSignalsInAsking = maxNumberOfReceivedSignalsInAsking - MathAbs(MathRand() % (maxNumberOfReceivedSignalsInAsking/((maxNumberOfReceivedSignalsInAsking > 4)?4:2)));
  if(maxNumberOfReceivedSignalsInAsking == 1)
      ownMaxNumberOfReceivedSignalsInAsking = 1;
   int ownlimitTimeForCachingOfSignals = limitTimeForCachingOfSignals - MathAbs(MathRand() % (limitTimeForCachingOfSignals/((limitTimeForCachingOfSignals > 30)?30:2)));
  if(limitTimeForCachingOfSignals == 1)
      ownlimitTimeForCachingOfSignals = 1;   
  
   mstring argHashesOfS[];
   int indicatorsOfS[];
   int signalsOfS[];
   int argsIndexes[];
   int numOfS = 0;
   ArrayResize(argHashesOfS, ownMaxNumberOfReceivedSignalsInAsking);
   ArrayResize(indicatorsOfS, ownMaxNumberOfReceivedSignalsInAsking);
   ArrayResize(signalsOfS, ownMaxNumberOfReceivedSignalsInAsking);
   ArrayResize(argsIndexes, ownMaxNumberOfReceivedSignalsInAsking);
   
   ARG_LIST arg;
   ulong start1 =  GetTickCount();
   int countNum = 0;
   
   continueAskingOfDefArgs = 0;
   while(askingAllowed){
         if(continueAskingOfDefArgs < 0)
            continueAskingOfDefArgs = 0;
         else if(continueAskingOfDefArgs > ownMaxNumberOfReceivedSignalsInAsking)
            continueAskingOfDefArgs = 1;
            
         Sleep(continueAskingOfDefArgs);
         if(!askingAllowed)
            return;
            
         int prevI = prevAskedIndicatorIndexInDefaultArgsAsking;
         int prevArgI = prevAskedArgListIndexInDefaultArgsAsking;
         int argSize = indMan.GetArgQueueSize(prevI);
         if(argSize > prevArgI)
         {
            arg = indMan.GetArgList(prevI, prevArgI);
            indMan.GetIndicator(prevI).SetArgs(arg);
            int signal = indMan.GetIndicator(prevI).Perform();
            if((getTimeStamp() - prevTimeOfResetCache) >= (ownlimitTimeForCachingOfSignals))
            {
               ResetSignalCache();
            }
   
            char prevSignal = signalCache[startPosOfSignalsCache[prevI] + prevArgI];
            if(signal != VOID_SIGNAL && signal != (int) prevSignal)
            {
               //checks whether the signal is exists or not
               bool is_exists = false;
               for(int kl = 0; kl < numOfS; kl++){
                  if(indicatorsOfS[kl] == prevI && argsIndexes[kl] == prevArgI)
                  {
                     is_exists = true;
                     break;
                  }
               }
               
               if(!is_exists){
                  indicatorsOfS[numOfS] = prevI;
                  argHashesOfS[numOfS] = arg.GetHash();
                  signalsOfS[numOfS] = signal;
                  argsIndexes[numOfS] = prevArgI;
                  numOfS++;
                  signalCache[startPosOfSignalsCache[prevI] + prevArgI] = (char) signal;
                  continueAskingOfDefArgs--;
               }
            }
            else{
               continueAskingOfDefArgs++;
            }
            askedIndicatorsNumWithDefaultArgs++;
         }
         
         prevAskedIndicatorIndexInDefaultArgsAsking++;
         if(prevAskedIndicatorIndexInDefaultArgsAsking == indMan.GetNumIndicators()){
            prevAskedIndicatorIndexInDefaultArgsAsking = 0;
            prevAskedArgListIndexInDefaultArgsAsking++;
            if(prevAskedArgListIndexInDefaultArgsAsking == timeFramesLimit)
            {
               prevAskedArgListIndexInDefaultArgsAsking = 0;
            }
         }
   
         if(numOfS == ownMaxNumberOfReceivedSignalsInAsking)
            break;
         
         ulong start2 = GetTickCount();
         if(MathRound(start2 - start1) >= MathRound(maxWaitingIntervalInAsking * 1000))
            break;
   }
            
   if(!askingAllowed)
      return;
   
   if(numOfS != 0)
      CombinatePackets(numOfS, indicatorsOfS, signalsOfS, argHashesOfS, outPackets);
   else{
      builtPacketsNum = 0;
      ArrayFree(outPackets);
   }
}

ulong ASKER::GetAskedIndicatorsNum(void){
   return askedIndicatorsNum;
}

void ASKER::CombinatePackets(int numOfS,int &indicatorsOfS[],int &signalsOfS[], mstring& argsHashesOfS[], PACKET &outPackets[]){
   if(numOfS != 0){
     int buySignals = 0;
     int sellSignals = 0;
     int bI[];
     int sI[];
     ArrayResize(bI, numOfS);
     ArrayResize(sI, numOfS);
     for(int i = 0; i < numOfS; i++){
         if(signalsOfS[i] == BUY_SIGNAL)
            bI[buySignals++] = i;
         else
            sI[sellSignals++] = i;
     }    
     int numberOfPackets = 0, numberOfSellPackets = 0, numberOfBuyPackets = 0;
     int len = (buySignals > numberOfPacketsForIntersect)?numberOfPacketsForIntersect:buySignals;
     for(int i = 1; i <= len; i++){
         numberOfBuyPackets += (int) (Factorial(buySignals)/(Factorial(buySignals - i)*Factorial(i)));
     }
     
     len = (sellSignals > numberOfPacketsForIntersect)?numberOfPacketsForIntersect:sellSignals;
     for(int i = 1; i <= len; i++){
         numberOfSellPackets += (int) (Factorial(sellSignals)/(Factorial(sellSignals - i)*Factorial(i)));
     }
     numberOfPackets = numberOfSellPackets + numberOfBuyPackets;
     if(numberOfPackets > maxNumberOfMadePackets){
        double k = (double) maxNumberOfMadePackets / (double) numberOfPackets;
        numberOfPackets = maxNumberOfMadePackets;
        numberOfBuyPackets = (int) MathFloor((double) numberOfBuyPackets * k);
        numberOfSellPackets = (int) MathFloor((double) numberOfSellPackets * k);
     }
       
     ArrayResize(outPackets, numberOfPackets);
     builtPacketsNum = 0;
     //combining
     int builtN = 0;
     if(buySignals != 0)
         builtN += BuildPackets(bI, buySignals, indicatorsOfS, signalsOfS, argsHashesOfS, outPackets, numberOfBuyPackets);
     if(sellSignals != 0)
         builtN += BuildPackets(sI, sellSignals, indicatorsOfS, signalsOfS, argsHashesOfS, outPackets, numberOfSellPackets);
   }
}

int ASKER::BuildPackets(int &I[], int sizeOfI, int &indicatorsOfS[],int &signalsOfS[],mstring& argsHashesOfS[] ,PACKET &outPackets[], int limit){
   int builtForSession = 0;
   int signalsNumber = sizeOfI;
   int forIntersect = (signalsNumber > numberOfPacketsForIntersect)?numberOfPacketsForIntersect:signalsNumber;
   int len = forIntersect;
   
   if(!askingAllowed)
      return builtForSession;
      
   while(len >= 1){
      uint comb[];
      ArrayResize(comb, len);
      int k = len;
      uint n = (uint) signalsNumber;
    
      ulong start1 = getTimeStamp();
      
      int ci;
      for (ci = 0; ci < k; ci++) comb[ci] = k - ci;
       
      do
      {      
                {
                  ulong start2 = GetTickCount();
                  if((int) MathAbs(start2 - start1) >= maxWaitingIntervalInGeneratingOfPackets * 1000)
                  {
                     ErrPrint("ASKER: time limit in generating of packets was reached");
                     break;
                  }
                  outPackets[builtPacketsNum].Clear();
                  outPackets[builtPacketsNum].Reserve(k);
                  outPackets[builtPacketsNum].SetTimeStamp(getTimeStamp());
                  outPackets[builtPacketsNum].SetSignal(signalsOfS[I[0]]);
                   
                  for (ci = k; ci--;){
                        int ind = I[comb[ci] - 1];
                        mstring hash = argsHashesOfS[ind];
                        int indicatorInd = indicatorsOfS[ind];
                        
                        outPackets[builtPacketsNum].AddIndicator(indicatorInd, hash);
                  }
                   
                   builtPacketsNum++;
                   builtForSession++;
                   if(builtForSession >= limit)
                        return builtForSession;
                }
                
            	 if(comb[0]++ < n) continue;
            	
            	 bool breakF = false;
            	 for (ci = 0; comb[ci] >= n - ci;) if (++ci >= k){breakF = true; break; }
            	 if(breakF)
            	   break;
            	   
            	 for (comb[ci]++; ci; ci--) comb[ci-1] = comb[ci] + 1;
               
        } while(askingAllowed);
           
        len--;
     }
   
   return builtForSession;
}

int ASKER::GetBuiltPacketsNum(){
   return builtPacketsNum;
}

ulong ASKER::GetDefaultIndicatorsNum(void){
   return askedIndicatorsNumWithDefaultArgs;
}

ulong ASKER::GetAllAskedIndicators(void){
   return allAskedIndicators;
};

ulong ASKER::GetAllAskedIndicatorsWithDefArgs(void){
   return allAskedIndicatorsWithDefArgs;
};

ulong ASKER::GetMaxAllPacketsNumWithDefArgs(void){
   return maxAllPacketsNumWithDefArgs;
};

void ASKER::ResetPacketsCache(void){
   ArrayResize(builtPacketsHashes, maxSizeForCacheOfBuiltPackets);
   ArrayFill(builtPacketsHashes, 0, maxSizeForCacheOfBuiltPackets, 0);
   builtPacktesHashesNum = 0;
   builtPacketsCacheS1 = GetTickCount();
}
   /*
    * END ASKER CLASS
    */
    
 /*
  * PACKETS_HISTORY_MANAGER CLASS
  * The class implements methods for writing of packets into database
  */
  
  class PACKETS_HISTORY_MANAGER{
      private:
         ulong writtenNum;
         double stopLoss;
         double prevPrice;
        
      public:
         PACKETS_HISTORY_MANAGER();
         ~PACKETS_HISTORY_MANAGER();
         bool WritePackets(PACKET& packets[], int arrSize);
         ulong GetWrittenPacketsNum();
  };
  
  PACKETS_HISTORY_MANAGER::PACKETS_HISTORY_MANAGER(void){
      writtenNum = 0;
      stopLoss = CalculatePoint(stopLossLevel*1.6);
      string symbol = l5Symbol;
      StringToUpper(symbol);
      prevPrice = MarketInfo(symbol, MODE_BID);
  }
  
  PACKETS_HISTORY_MANAGER::~PACKETS_HISTORY_MANAGER(void){
    
      
  }
  
 bool PACKETS_HISTORY_MANAGER::WritePackets(PACKET &packets[], int arrSize){
      ulong md5p1B[], md5p2B[], momentsB[], md5p1S[], md5p2S[], momentsS[];
      bool res = true;
      bool is_exists = false;
      
      int countB = 0, countS = 0;
      ArrayResize(md5p1B, arrSize);
      ArrayResize(md5p2B, arrSize);
      ArrayResize(momentsB, arrSize);
      ArrayResize(md5p1S, arrSize);
      ArrayResize(md5p2S, arrSize);
      ArrayResize(momentsS, arrSize);
      string symbol = l5Symbol;
      StringToUpper(symbol);
      
      for(int i = 0; i < arrSize; i++){
         is_exists = false;
         mstring md5S = packets[i].GetPacketHash();
         string md5 = md5(md5S.InS());
         ulong md5p1 = md5_part("NULL", false, md5);
         ulong md5p2 = md5_part("NULL", true, md5);
         if(i % 50 == 0)
            RefreshRates();
         float averagePrice = MarketInfo(symbol, MODE_BID);
         res = res & mql4_write_in_time_queue(averagePrice, md5p1, md5p2,  packets[i].GetSignal(), packets[i].GetTimeStamp(), md5S.InS(), is_exists);
         
         if(packets[i].GetSignal() == BUY_SIGNAL){
            md5p1B[countB] = md5p1;
            md5p2B[countB] = md5p2;
            momentsB[countB] = packets[i].GetTimeStamp();
            countB++;
         }
         else{
            md5p1S[countS] = md5p1;
            md5p2S[countS] = md5p2;
            momentsS[countS] = packets[i].GetTimeStamp();
            countS++;
         }
      }
      
      if(!res) {
         ErrPrint("L5 PACKETS_HISTORY_MANAGER: Error occured in writing of packets into time queue");
      }
      else{
         float buyStopLoss =  MarketInfo(symbol, MODE_ASK) - stopLoss;
         float sellStopLoss = MarketInfo(symbol, MODE_BID) + stopLoss;
         float averagePrice = MarketInfo(symbol, MODE_BID);
         
         res = mql4_write_in_price_queue(buyStopLoss, averagePrice, md5p1B, md5p2B, momentsB, BUY_SIGNAL, countB);
         res = res && mql4_write_in_price_queue(sellStopLoss, averagePrice, md5p1S, md5p2S, momentsS, SELL_SIGNAL, countS);
               
         if(!res){
            ErrPrint("L5 PACKETS_HISTORY_MANAGER: Error occured in writing of packets into price queue");
         }
         else{
            float averagePrice = MarketInfo(symbol, MODE_BID); 
            res = mql4_resolving_in_price_queue(averagePrice);
         } 
      }
      
      writtenNum += arrSize;
     
      prevPrice = MarketInfo(symbol, MODE_BID);
     
      return res;
  }
  
  ulong PACKETS_HISTORY_MANAGER::GetWrittenPacketsNum(){
      return writtenNum;
  }
  
  /*
   * PACKETS_HISTORY_MANAGER END
   */


  /*
   *  QUOTES_HISTORY_MANAGER CLASS
   *  The Class provides writing of quotes into database
   */
   
   class QUOTES_HISTORY_MANAGER{
      private:
         ulong writtenTicks;
         string allowedQuotes[];
         double prevTicksAsk[];
         double prevTicksBid[];
         
      public:
         QUOTES_HISTORY_MANAGER();
         bool Write();
         ulong GetWrittenTicks();
   };
   
   QUOTES_HISTORY_MANAGER::QUOTES_HISTORY_MANAGER(){
      writtenTicks = 0;
      int numQuotes = 1;
      ArrayResize(allowedQuotes, numQuotes);
      ArrayResize(prevTicksAsk, numQuotes);
      ArrayFill(prevTicksAsk, 0, numQuotes, 0);
      ArrayResize(prevTicksBid, numQuotes);
      ArrayFill(prevTicksBid, 0, numQuotes, 0);
      //after moment of: 2014-09-06 22:05:46
      allowedQuotes[0] = "eurusd";
      //allowedQuotes[1] = "gbpusd";
      //allowedQuotes[2] = "usdjpy";
      //allowedQuotes[3] = "usdcad";
      //allowedQuotes[4] = "audusd";
      //allowedQuotes[5] = "xauusd";
      //allowedQuotes[6] = "xagusd"; 
     
      for(int i = 0; i < numQuotes; i++){
				l5Db.Query(StringConcatenate(
				                             " CREATE TABLE IF NOT EXISTS " + allowedQuotes[i] + "_ticks ",
							                    " (moment TIMESTAMP,",
							                    "  bid DECIMAL(15,5),",
							                    "  ask DECIMAL(15,5),",
							                    "  INDEX moment (moment),",
							                    "  INDEX bid (bid),",
							                    "  INDEX ask (ask),",
							                    "  PRIMARY KEY (moment,bid,ask))",
         								        "  ENGINE = INNODB;"
         					)
             );
      }
   }
   
   ulong QUOTES_HISTORY_MANAGER::GetWrittenTicks(){
      return writtenTicks;
   }
   
   bool QUOTES_HISTORY_MANAGER::Write(void){
      
      bool res = false;
      for(int i = 0; i < ArraySize(allowedQuotes); i++){
         RefreshRates();
         string uppName = allowedQuotes[i];
         StringToUpper(uppName);
         double ask = NormalizeDouble(MarketInfo(uppName, MODE_ASK), 5);
         double bid = NormalizeDouble(MarketInfo(uppName, MODE_BID), 5);
         if(prevTicksAsk[i] != ask || prevTicksBid[i] != bid){
            prevTicksAsk[i] = ask;
            prevTicksBid[i] = bid;
            string query = StringConcatenate("INSERT IGNORE INTO " + allowedQuotes[i] + "_ticks (moment,bid,ask) VALUES (UTC_TIMESTAMP(), " + 
                                             (string) bid + ", " + 
                                             (string) ask + ")");
            l5Db.Query(query);
          
            res = true;
         }
      }
      
      return res;
   }
   
   /*
    * QUOTES_HISTORY_MANAGER END
    */
