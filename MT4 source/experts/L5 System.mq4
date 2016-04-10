//+------------------------------------------------------------------+
//|                                                    L5_System.mq4 |
//|     Copyright 2014 - 2015, L5 System Team <support@l5system.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014 - 2015, L5 System Team <support@l5system.com>"
#property link      "http://l5system.com"
#property version   "1.06"
#property strict

#define __CHV 1 //compile non-custom version

#ifdef __CHV
//import dlls
#import "L5CommonDll.dll"
   int mql4_preg_match(string pattern, string str, int& start_packets_pos[], int& packets_lengths[], int start_position = 0);
   bool mql4_md5_hash(string msg, uchar& result[]); //!char must have size of 32!
   ulong mql4_md5_part(char& md5[], bool is_second);
   void mql4_log(string msg);
   
   /* for resolving reasons */
   bool mql4_initial_resolver(bool initOnlyDirectory, string storageDirectory, string symbol, ulong starting_size, float currentBid, float currentAsk, float optimalProfit, int anumGeneratedSolutions, int anumRowsWithSameOutPacketInSolutions, string dbHost, string dbUser, string dbPass, string dbName, string rl5DbHost = "", string rl5DbUser = "", string rl5DbPassword = "", string rl5DbName = "");
   bool mql4_deinit_resolver();
   bool mql4_write_in_time_queue(float currentPrice, ulong md5p1, ulong md5p2, char signalType, ulong timestamp, string packetHash, bool& is_exists); //and resolving by early signals
   bool mql4_write_in_price_queue(float stopLoss, float currentPrice, ulong& md5p1[], ulong& md5p2[], ulong& timestamps[], char signalType, int size); 
   bool mql4_resolving_in_price_queue(float averagePrice);
   ulong mql4_get_timestamp(bool is_withMilli = false);
   bool mql4_run_resolver();
   bool mql4_stop_resolver();
   bool mql4_get_packet_from_storage(ulong md5p1, ulong md5p2, int& pointer, int& size);
   int mql4_get_info_about_optimizer(int index);
   bool mql4_mysql_reconnect(int dbConnectId);
#import

#import "kernel32.dll"
   int lstrlenA(int);
   void RtlMoveMemory(uchar & arr[], int, int);
   int LocalFree(int); //May need to be changed depending on how the DLL allocates memory
   int CopyFileW(string strExistingFile, string strCopyOfFile, int OverwriteIfCopyAlreadyExists);
#import

#import "user32.dll"
   int MessageBoxW(int handle, string msg, string caption, unsigned int type);
   int GetForegroundWindow(void);
#import

#import "msvcrt.dll"
  int memcpy(char &Destination[], int Source, int Length);
  int memcpy(char &Destination[], long Source, int Length);
  int memcpy(int &dst,  int src, int cnt);
  int memcpy(int &dst[],  int src, int cnt);
  int memcpy(long &dst,  long src, int cnt);    
#import
 
#import "libmysql.dll"
int     mysql_init          (int dbConnectId);
int     mysql_errno         (int dbConnectId);
int     mysql_error         (int dbConnectId);
int     mysql_real_connect  (int dbConnectId, uchar & host[], uchar & user[], uchar & password[], uchar & db[], int port, int socket, int clientflag);
int     mysql_real_query    (int dbConnectId, uchar & query[], int length);
int     mysql_query         (int dbConnectId, uchar & query[]);
void    mysql_close         (int dbConnectId);
int     mysql_store_result  (int dbConnectId);
int     mysql_use_result    (int dbConnectId);
int     mysql_insert_id     (int dbConnectId);
int     mysql_fetch_row     (int resultStruct);
int     mysql_fetch_field   (int resultStruct);
int     mysql_fetch_lengths (int resultStruct);
int     mysql_num_fields    (int resultStruct);
int     mysql_num_rows      (int resultStruct);
void    mysql_free_result   (int resultStruct);
#import
#endif

//Base includes
#include <my_stdlib.mqh>
#ifdef __CHV
#include <mysql_interface.mqh>
#include <regexp.mqh>
#endif
#include <stdlib.mqh>

//Input parameters
//--base parameters

enum ACTIVITY_MODE 
  {
#ifdef __CHV
      AMoptimization = 0,                //Signals optimization
      AMticks_writing = 1,               //Ticks writing
      AMindividual_optimization = 2,     //One signal optimization
      AMtesting_of_def_args = 3,         //Testing of default arguments
#endif
      AMtrading = 4                      //Trading
  };

sinput ACTIVITY_MODE activityMode = AMtrading;                              //Mode 
sinput string l5CentralServerAddress = "http://l5system.com/gateway";       //L5 System server url

//--trading parameters
enum TRADING_STRATEGIES{
   tSCommon = 1,              //Common strategy
   tSLowRisk = 2              //Low risk strategy
};

sinput TRADING_STRATEGIES tIStrategy = tSCommon;                            //Trading strategy
sinput bool tIAutomaticDefiningRisk = true;                                 //Define risk automatically
sinput double tIallowedRiskOnOnePosition = 1.0;                             //Allowed risk of one deal, %
sinput int tIOptimalNumOfOrders = 3;                                        //Optimal number of simultaneously opened positions
sinput bool tIAutomaticDefiningLevels = true;                               //Define stop levels automatically
sinput int tIstopLossLevel = 18;                                            //Minimal stoploss level, pips
sinput int tItakeProfitLevel = 72;                                          //Minimal takeprofit level, pips
sinput int tIallowedSlippage = 2;                                           //Allowed slippage, pips
sinput int tITrailingStop = 21;                                             //Optimal trailing stop level, pips
#ifdef __CHV
sinput int tImaxIntervalInSelecting = 20;                                   //Pause in selecting of solutions, sec    
#else
int tImaxIntervalInSelecting = 20;
#endif;  
enum SOLUTIONS_CRITERIONS{
   SCno_criterion = 0,              //No
   SCcommon = 1,                    //Common criterion
   SCfor_little_time_postions = 2   //Criterion by short duration
};
sinput SOLUTIONS_CRITERIONS tIdesiredCriterionInAskingOfSolutions = SCno_criterion;      //Desired criterion in selecting of solutions
sinput int tIdesiredLimitInAskingOfSolutions = 0;                                        //Limit of number of extracted solutions in selecting of solutions

#ifdef __CHV
//--signals optimization parameters
sinput bool l5DbUseL5CentralServerAsDbStorage = false;                      //Use L5 System Central Server as db
sinput string l5DbHost = "localhost";                                       //DB Host
sinput string l5DbUser = "root";                                            //DB User
sinput string l5DbPassword = "";                                            //DB Password
sinput string l5DbName = "l5_database";                                     //DB Name
sinput string directoryStorage = "D:/L5_Storage";                           //Directory for L5 System storage
sinput int optimalProfitForResolving = 6;                                   //Minimal allowed profit of one solution, pips
sinput int numGeneratedSolutions = 333;                                     //Size of solutions list by one criterion
sinput int numRowsWithSameOutPacketInSolutions = 2;                         //Maximal allowed number of rows with same out packet in solutions list
sinput unsigned int limitTimeForCachingOfSignals = 300;                     //Caching interval in asking of indicators, sec
sinput int maxNumberOfReceivedSignalsInAsking = 19;                         //Maximal number of asked signals for one iteration, signals
sinput int numberOfPacketsForIntersect = 4;                                 //Maximal size of packet, signals
sinput int maxNumberOfMadePackets = 17000;                                  //Maximal number of created packets for one iteration       

//--one signal optimization and testing parameters
sinput string iOIndicatorName;                                              //Name of indicator for one signal testing or optimization
sinput ENUM_TIMEFRAMES iOTimeFrameNumberInTesting = 0;                      //Timeframe in testing of default arguments of a signal
sinput bool iOoptimzeStopProfitLevels = false;                              //Defines whether optimize stop and profit levels or not
enum CERTAIN_TIMEFRAMES_OPTIONS{
   ctoUseAll = 0,
   ctoUseBigOnly = 1,
   ctoUseSmallOnly = 2,
};
sinput CERTAIN_TIMEFRAMES_OPTIONS iOisUsingCertainTimeframes = ctoUseAll;   //Defines what timeframes use in one signal optimization
sinput int iOmaxBarsForOptimization = 30240;                                //Maximal number of bars accounted in one signal optimization process
sinput float iOmaxHoursForOptimization = 0;                                 //One signal optimization time limit, hours
#endif

//Limit constants
const int limitOfSpecificationValuesLength = 1000;                         
const int limitOfArgQueueSize = 50000;
const int limitOfCacheForQueues = 1500; 
const int timeFramesLimit = 6; //IMPORTANT!!! CONSTANT: IN CHANGES TIMEFRAMES CHANGE THE CONSTANT
//IMPORTANT!!! CONSTANT: IN CHANGES TIMEFRAMES CHANGE THE ARRAY SIZE IN SPECIFICATION::Generate in indicators_representation.mgh
const int allowedTimeFrames[6] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4};  

//Auto specifying parameters
bool needInReloadDefaultArgs = false;
double maxWaitingIntervalInAsking = 0;
int maxWaitingIntervalInGeneratingOfPackets = 0;
int maxSizeForCacheOfBuiltPackets = 0;
int maxWaitingIntervalForCacheOfBuiltPackets = 0;

//Global variables
#ifdef __CHV
MysqlDB *l5Db = NULL;
#endif
string l5Symbol = Symbol();
bool askingAllowed = true;
ulong averageDurationInAsking = 0;
ulong generatedPacketsForSession = 0;
ulong askedSignalsForSession = 0;
ulong maxAllPacketsNumWithDefArgs;
ulong allAskedIndicatorsWithDefArgsGlobal;
int definedNumCriterions = 2;
int desiredSignalBySolutions = 0;
int stopLossLevel = 0;
int takeProfitLevel = 0;
int trailingStopLevel = 0;
double allowedRiskOnOnePosition = 0;

//Includes
#ifdef __CHV
#include <indicators_representation.mqh>
INDICATOR_MANAGER* indMan;
#include <running_environment.mqh>
ASKER* asker;

PACKETS_HISTORY_MANAGER* pMan;
QUOTES_HISTORY_MANAGER* qMan;
SYSTEM_INFO* systemInfo;
#include <testing_implements.mqh>
VIRTUAL_OPTIMIZATION* virtualOptimizer;
TESTING_OF_DEF_ARGS* testerOfDefArgs;
#endif
#include <trading_implements.mqh>
TRADING* tradingController;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
      //Checking of input parameters
      stopLossLevel = tIstopLossLevel;
      takeProfitLevel = tItakeProfitLevel;
      trailingStopLevel = tITrailingStop;
      allowedRiskOnOnePosition = tIallowedRiskOnOnePosition;
      
      if(!IsTesting()){
         double stopLevel = MarketInfo(l5Symbol, MODE_STOPLEVEL) / TruePointValue(1);
        
         if(tIstopLossLevel < stopLevel || tIstopLossLevel < stopLevel || tITrailingStop < stopLevel) 
         {
            ErrPrint("L5 - Check your input arguments: stop levels are incorrected!", true);
            return INIT_FAILED;
         }
         if(tIallowedSlippage < 0 || tIallowedSlippage > 10)
         {
            ErrPrint("L5 - Check your input arguments: slippage is incorrected!", true);
            return INIT_FAILED;
         }
         
         if(tIAutomaticDefiningLevels || tIAutomaticDefiningRisk){
            MsgPrint("getting stop levels and risk measure from L5 server...");
            int newSL, newTP, newTS;
            double newRisk;
            
            int count = 0;
            bool res = false;
            do{
               res = GetStopLevelsFromL5Server(tIStrategy, l5Symbol, stopLevel, newSL, newTP, newTS, newRisk);
            }while(!res && count++ < 3);
            
            if(res)
            {
               if(tIAutomaticDefiningLevels){
                  stopLossLevel = newSL;
                  takeProfitLevel = newTP;
                  trailingStopLevel = newTS;
               }
               if(tIAutomaticDefiningRisk)
                  allowedRiskOnOnePosition = newRisk;
            }
         }
      }
      
      if(!tIAutomaticDefiningRisk && (tIallowedRiskOnOnePosition < 0.001 || tIallowedRiskOnOnePosition > 100))
      {
         ErrPrint("L5 - Check your input arguments: allowed risk is incorrected!", true);
         return INIT_FAILED;
      }
      
      if(tIOptimalNumOfOrders < 1 || tIOptimalNumOfOrders > 30)
      {
         ErrPrint("L5 - Check your input arguments: optimal number of orders is incorrected!", true);
         return INIT_FAILED;
      }
      
//---
     systemInfo = new SYSTEM_INFO;
#ifdef __CHV    
     string rl5DbHost = "92.53.117.140";
     string rl5DbUser = "timjackson_l5sys";
     string rl5DbPassword = "l5systemformoney";
     string rl5DbName = "timjackson_l5sys";
     
     string cl5DbHost = l5DbHost;
     string cl5DbUser = l5DbUser;
     string cl5DbPassword = l5DbPassword;
     string cl5DbName = l5DbName;
     
     if(l5DbUseL5CentralServerAsDbStorage){
         cl5DbHost = rl5DbHost;
         cl5DbUser = rl5DbUser;
         cl5DbPassword = rl5DbPassword;
         cl5DbName = rl5DbName;
     }
     
     l5Db = new MysqlDB(cl5DbHost, cl5DbUser, cl5DbPassword, cl5DbName);
     if(CheckPointer(l5Db) == POINTER_INVALID)
         return INIT_FAILED;
     else if(!l5Db.IsInited())
         return INIT_FAILED;
//--- 
      if(activityMode == 0 || activityMode == 2 || activityMode == 3 || activityMode == 4){
         if(activityMode == 0){
            if(!IsTesting()){
               string labelName = "deletingLabel";
               ObjectCreate(0,labelName,OBJ_LABEL,0,0,0);
               ObjectSetInteger(0,labelName,OBJPROP_XDISTANCE, 4);
               ObjectSetInteger(0,labelName,OBJPROP_YDISTANCE, 33);
               ObjectSetString(0,labelName,OBJPROP_TEXT, "STOP OPTIMIZATION");
               ObjectSetInteger(0,labelName,OBJPROP_COLOR, clrRed);
               ObjectSetInteger(0,labelName,OBJPROP_ZORDER, 100);
               ObjectSet(labelName,OBJPROP_SELECTABLE, false);
            }
        }
      
        MsgPrint("loading of indicators ...");
        indMan = new INDICATOR_MANAGER;
        if(CheckPointer(indMan) == POINTER_INVALID)
            return INIT_FAILED;
        else if(indMan.GetNumIndicators() == 0){
            ErrPrint("INDICATOR MANAGER you haven't any indicator in list");
            return INIT_FAILED;
        } 
         
        MsgPrint("loading of indicators has been completed");
        
        if(activityMode != 2 && activityMode != 3){
           MsgPrint("preparing for asking...");
           asker = new ASKER;
           if(CheckPointer(asker) == POINTER_INVALID)
               return INIT_FAILED;
           pMan = new PACKETS_HISTORY_MANAGER;
           if(CheckPointer(pMan) == POINTER_INVALID)
               return INIT_FAILED;
           MsgPrint("preparing for asking has been completed");
           
           if(activityMode != 4){
              MsgPrint("Initialization of resolver ...");
              if(!mql4_initial_resolver(false, directoryStorage, l5Symbol, maxAllPacketsNumWithDefArgs * 3, (float) Bid, (float) Ask, (float) CalculatePoint(optimalProfitForResolving), numGeneratedSolutions, numRowsWithSameOutPacketInSolutions, l5DbHost, l5DbUser, l5DbPassword, l5DbName, rl5DbHost, rl5DbUser, rl5DbPassword, rl5DbName)){
                  ErrPrint("L5 Error in initialization of resover", true);
                  return INIT_FAILED;
              }
              if(!mql4_run_resolver()){
                  return INIT_FAILED;
                  ErrPrint("L5 Can't start resolving thread", true);
              }
              
              MsgPrint("optimization ...");
              EventSetTimer(60);
           }
           else{
               if(!mql4_initial_resolver(true, directoryStorage, l5Symbol, 0, 0, 0, 0, 0, 0, "", "", "", "")){
                  ErrPrint("L5 Error in initialization of directory", true);
                  return INIT_FAILED;
               }
               EventSetTimer(60);
               //TRADING MODE
               if(tIStrategy == tSCommon)
                  tradingController = new COMMON_TRADING_STRATEGY;
               else if(tIStrategy == tSLowRisk)
                  tradingController = new LOW_RISK_TRADING_STRATEGY;
           }
        }
        else{
            if((activityMode == 2 || activityMode == 3) && !IsTesting())
            {
               ErrPrint("L5: This mode supported in testing only", true);
               return INIT_FAILED;
            }
            
            if(!mql4_initial_resolver(true, directoryStorage, l5Symbol, 0, 0, 0, 0, 0, 0, "", "", "", "")){
                  ErrPrint("L5 Error in initialization of directory", true);
                  return INIT_FAILED;
            }
            
            if(activityMode == 2){
               virtualOptimizer = new VIRTUAL_OPTIMIZATION(iOIndicatorName);
               if(CheckPointer(virtualOptimizer) == POINTER_INVALID)
               {
                  return INIT_FAILED;
               }
            }
            
            if(activityMode == 3){
               testerOfDefArgs = new TESTING_OF_DEF_ARGS(iOIndicatorName);
               if(CheckPointer(testerOfDefArgs) == POINTER_INVALID)
               {
                  return INIT_FAILED;
               }
           }
        }
     }
     
     if(activityMode == 1){
        if(!mql4_initial_resolver(true, directoryStorage, l5Symbol, 0, 0, 0, 0, 0, 0, "", "", "", "")){
                  ErrPrint("L5 Error in initialization of directory", true);
                  return INIT_FAILED;
        }
     
        qMan = new QUOTES_HISTORY_MANAGER;
        if(CheckPointer(qMan) == POINTER_INVALID)
            return INIT_FAILED;
     }
#else

EventSetTimer(60);
 if(tIStrategy == tSCommon)
     tradingController = new COMMON_TRADING_STRATEGY;
 else if(tIStrategy == tSLowRisk)
     tradingController = new LOW_RISK_TRADING_STRATEGY;

#endif
     
     return(INIT_SUCCEEDED);
  };
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
  {
      Comment("");
//---
#ifdef __CHV
      mql4_deinit_resolver();
      ObjectDelete(0, "deletingLabel");
      
      if(reason != REASON_INITFAILED){
        //...
      } 
      
      if(CheckPointer(tradingController) != POINTER_INVALID){
         delete tradingController;
      }  
      
      if(CheckPointer(virtualOptimizer) != POINTER_INVALID){
         delete virtualOptimizer;
      } 
      
      if(CheckPointer(testerOfDefArgs) != POINTER_INVALID){
         delete testerOfDefArgs;
      }
      
      if(CheckPointer(indMan) != POINTER_INVALID){
         delete indMan;
      }
      if(CheckPointer(l5Db) != POINTER_INVALID){
         
         delete l5Db;
      }
      if(CheckPointer(asker) != POINTER_INVALID){
         delete asker;
      } 
      if(CheckPointer(pMan) != POINTER_INVALID){
         delete pMan;
      } 
      if(CheckPointer(qMan) != POINTER_INVALID){
         delete qMan;
      } 
      if(CheckPointer(systemInfo) != POINTER_INVALID){
        delete systemInfo;
      }
     
      
#else
      if(CheckPointer(tradingController) != POINTER_INVALID){
         delete tradingController;
      }  
#endif

EventKillTimer();
  };

#ifdef __CHV
  bool is_deinited = false;
  ulong prevInvokingMomentOfownD = 0;
  void ownDeinit(){
      if(GetTickCount() - prevInvokingMomentOfownD < 3000){
         return;
      }
      prevInvokingMomentOfownD = GetTickCount();
      
      string labelName = "deletingLabel";
      if(!is_deinited){
         ObjectSetString(0,labelName,OBJPROP_TEXT, "OPTIMIZATION STOPPING ...");
         if(!mql4_stop_resolver())
            ErrPrint("RESOLVING THREAD Can't stop resolving thread");
            
         ObjectSetString(0,"deletingLabel",OBJPROP_TEXT, "START OPTIMIZATION"); 
         ObjectSetInteger(0,labelName,OBJPROP_COLOR, clrGreen); 
         MsgPrint("Optimization has been stopped");
         is_deinited = true;
      }
      else{
         ObjectSetString(0,labelName,OBJPROP_TEXT, "STARTING OPTIMIZATION ...");
         if(!mql4_run_resolver())
            ErrPrint("RESOLVING THREAD: Can't start resolving thread");
         
         ObjectSetString(0,labelName,OBJPROP_TEXT, "STOP OPTIMIZATION");
         ObjectSetInteger(0,labelName,OBJPROP_COLOR, clrRed);
         MsgPrint("Optimization is starting ...");
         is_deinited = false;
      }
  }
#endif
 
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

long builtWithDefInSession = 0;
long durationWrCount = 0;
long wholeDuration = 0;
void OnTick()
{
#ifdef __CHV
   if(is_deinited)
      return;
   
   if(activityMode == 0){
      if(!IsTesting()){
        if(!askingAllowed){
            askingAllowed = true;
            asker.ResetSignalCache();
        }
        
        PACKET packets[];
        
        ulong askedWithDefInPrevIteration = asker.GetDefaultIndicatorsNum();
        ulong duration = 0;
        ulong count = 0;
        durationWrCount++;
        while(askingAllowed){
               RefreshRates();
               ulong s1 = GetTickCount();
               asker.AskAllWithDefaultArg(packets);
               builtWithDefInSession += asker.GetBuiltPacketsNum();
               
               if(askingAllowed)
                 pMan.WritePackets(packets, asker.GetBuiltPacketsNum());

               if(askingAllowed){
                  asker.ReloadDefaultArgs();
               }
               
               duration += (GetTickCount() - s1);
               count++; 
               
               if(askingAllowed)
                  Sleep(35); 
                  
               PrintInfo();
               
               if((asker.GetDefaultIndicatorsNum() - askedWithDefInPrevIteration) >= MathCeil(asker.GetAllAskedIndicatorsWithDefArgs()))
                  break;
         }
         
         wholeDuration += (int) (count!=0?(duration / count):0);
         
         averageDurationInAsking = (wholeDuration / durationWrCount);
         generatedPacketsForSession = builtWithDefInSession;
         askedSignalsForSession = asker.GetDefaultIndicatorsNum();
      }
      else{
         ErrPrint("L5: this mode not allowed in testing");
         ExpertRemove();
      }
   }
   else if(activityMode == 1){
         qMan.Write();
   }
   else if(activityMode == 2){
        virtualOptimizer.Tick();
        return;
   }
   else if(activityMode == 3){
        testerOfDefArgs.Tick();
        return;
   }
   else if(activityMode == 4){
      //***TRADING***
      tradingController.Trade();
   }
   else{
      ErrPrint("L5: Wrong activity mode", true);
   }
   
#else
 tradingController.Trade();
#endif
   
};

void OnTimer(){
#ifdef __CHV
   if(activityMode == AMoptimization){
      PrintInfo();
   }
   else if(activityMode == AMtrading){
      tradingController.TimerProcedure();
   }
#endif
};

#ifdef __CHV
void OnChartEvent(const int id,         // идентификатор события  
                  const long& lparam,   // параметр события типа long
                  const double& dparam, // параметр события типа double
                  const string& sparam) // параметр события типа string
  {
//--- нажатие левой кнопкой мышки на графике
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam == "deletingLabel"){
         ownDeinit();
      }
   }
  }



//+------------------------------------------------------------------+

struct INFO_ABOUT_OPTIMIZER{
	int size_of_packet_table;
	int num_rows_in_packet_table;
	int num_collisions_in_packet_table;
	int signals_num_in_time_queue;
	int registered_moments_num;
	int sell_signals_in_price_queue;
	int buy_signals_in_price_queue;
	int num_moments_for_resolving;
	int num_moments_for_resolving_in_buffer;
	int averageDurationOfWritingInTimeQueue;
	int averageDurationOfWritingInPriceQueue;
	int averageDurationOfResolvingInPriceQueue;
	int averageDurationOfResolvingProcedure;
	int lastGeneratedSolutions;
	int lastMomentsForResolving;
	int numResolvedResults;
	int lastWeekendProcessingDuration;
	int is_in_weekend_processing;

} info_about_optimizer;

void PrintInfo(){
   int len = sizeof(INFO_ABOUT_OPTIMIZER) / sizeof(int);
   
   string prStr = "\n\n\n\n";
   
   for(int i = 0; i <= len; i++){
      switch(i){
         case 0:
                 //prStr += ("Theoretical number of all packets with default arguments: " + (string) maxAllPacketsNumWithDefArgs + "\n");
                 prStr += ("Signals for asking with default argumetns: " + (string) allAskedIndicatorsWithDefArgsGlobal + "\n");
                 prStr += ("Average duration in asking: " + (string) averageDurationInAsking + "ms\n");
                 prStr += ("Generated packets for session: " + (string) generatedPacketsForSession + "\n");
                 prStr += ("Asked signals for session: " + (string) askedSignalsForSession + "\n");
         break;
         case 1: prStr += ("Packet table size: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 2: prStr += ("Rows in packet table: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 3: prStr += ("Collisions in packet table: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 4: prStr += ("Signals in time queue: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 5: prStr += ("Registered signals: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 6: prStr += ("Signals in price queue for short: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 7: prStr += ("Signals in price queue for long: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 8: prStr += ("Positions for resolving: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
         case 9: prStr += ("Positions for resolving in buffer: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
        case 10: prStr += ("Average duration of writing in time queue: " + (string) mql4_get_info_about_optimizer(i) + "ms\n"); break;
        case 11: prStr += ("Average duration of writing in price queue: " + (string) mql4_get_info_about_optimizer(i) + "ms\n"); break;
        case 12: prStr += ("Average duration of price queue resolving: " + (string) mql4_get_info_about_optimizer(i) + "ms\n"); break;
        case 13: prStr += ("Average duration of positions resolivng: " + (string) mql4_get_info_about_optimizer(i) + "sec\n"); break;
        case 14: prStr += ("Number of last generated results for solutions: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
        case 15: prStr += ("Number of last resolved positions: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
        case 16: prStr += ("Number of results for solutions: " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
        case 17: prStr += ("Last weekend processing duration: " + (string) mql4_get_info_about_optimizer(i) + "sec\n"); break;
        case 18: prStr += ("Weekend processing: " + (string) (mql4_get_info_about_optimizer(i)?"processing...":"stopped") + "\n"); break;
       //case 1: prStr += (": " + (string) mql4_get_info_about_optimizer(i) + "\n"); break;
      }
   }
   Comment(prStr);
};
#endif