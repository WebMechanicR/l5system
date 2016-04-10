//+------------------------------------------------------------------+
//|                                    indicators_representation.mqh |
//|             Copyright 2014, Tim Jackson <webmechanicr@gmail.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Tim Jackson <webmechanicr@gmail.com>"
#property link      ""
#property strict


//List of signals included below

class SPECIFICATION;
class INDICATOR;

/*
 * ARG_LIST CLASSES
 * The class provides management of indicators' arguments
 */
 class ARG_LIST{
      public:
         mstring list[];
         string Get(int index);
         void SetList(mstring& inp[]);
         void GetList(mstring& out[]);
         int Size();
         string GetHash();
         bool SetListByHash(string hash);
         void operator=(const ARG_LIST& right);
         ARG_LIST(const ARG_LIST& right);
         ARG_LIST(){};
 };
 
 string ARG_LIST::Get(int index){
   if(index < 0 || index >= ArraySize(list))
   {
      ErrPrint("ARG_LIST: out of range in getting of value");
   }
   return list[index].InS();
 };
 
 void ARG_LIST::SetList(mstring& inp[]){
   int s = ArraySize(inp);
   if(s != ArraySize(list))
      ArrayResize(list, s);
   for(int m = 0; m < s; m++)
      list[m] = inp[m];
 };
 
void ARG_LIST::GetList(mstring& out[]) {
   int s = ArraySize(list);
   if(ArraySize(out) != s)
      ArrayResize(out, s);  
   for(int m = 0; m < s; m++)
      out[m] = list[m];
};
 
int ARG_LIST::Size(){
   return ArraySize(list);
};

void ARG_LIST::operator=(const ARG_LIST& right){
   int s = ArraySize(right.list);
   if(ArraySize(list) != s)
         ArrayResize(list, s);
   for(int i = 0; i < s; i++)
      list[i] = right.list[i];
};

 ARG_LIST::ARG_LIST(const ARG_LIST& right){
     operator=(right);
 }
 
string ARG_LIST::GetHash(){
   int size = Size();
   string result = NULL;
   for(int i = 0; i < size; i++){
      if(i != 0)
         result = result + "|";
      result = result + list[i].InS();
   };
   
   return result;
};

bool ARG_LIST::SetListByHash(string hash){
   //return preg_match_split("\|", hash, list);
   bool res = true;
   string buff[];
   if(StringSplit(hash, '|', buff) <= 0)
      res = false;
   int s = ArraySize(buff);
   ArrayResize(list, s);
   for(int i = 0; i < s; i++)
      list[i] = buff[i];
   return res;
};

/*
 * END ARG_LIST
 */


/*
 * SPECIFICATION CLASS
 * The abstract class defines methods for indicators' specifications management
 */

class SPECIFICATION{
   private:
      string specifications[];
      string symbols[];
      bool specLoaded;
      string prevAskedSymbol;
      ARG_LIST cache[];
      int argsQueueSize;
      int cachePositions[2];
      
   public:
      SPECIFICATION():specLoaded(false),argsQueueSize(-1){ArrayFill(cachePositions, 0, 2, -1);};
      bool AddSpecification(string spec, string symbol = NULL, bool setting = false);
      bool SetSpecification(string spec, string symbol = NULL);
      bool Generate(int argListIndex, string symbol = NULL, bool withoutSize = false);
      int GenerateArgsSize(string symbol = NULL);
      ARG_LIST GenerateArgList(int index, string symbol = NULL);
      void LoadSpecifications(bool reload = false);
      string BuildSpecificationByDefArgs(ARG_LIST& defaultArgs, int timeframe = 0, string origin = "");
      virtual string GetName(){ return NULL; };
};

void SPECIFICATION::LoadSpecifications(bool reload = false){
   if(specLoaded && !reload)
      return;
   
   specLoaded = true;

   //loads specifications from database
   bool res = l5Db.Query("SELECT symbol, value FROM indicators_specifications WHERE indicator_name = '" + GetName() + "'");
   int size = l5Db.Rows();
   if(size != 0 && res){
      ArrayResize(specifications, size);
      ArrayResize(symbols, size);
      for(int i = 0; i < size; i++){
         specifications[i] = l5Db.result[i].f[1];
         symbols[i] = l5Db.result[i].f[0];
      }
   }
}

bool SPECIFICATION::AddSpecification(string spec,string symbol=NULL, bool setting = false){
   LoadSpecifications();
   ArrayFree(cache);
   ArrayFill(cachePositions, 0, 2, -1);
   argsQueueSize = -1;
   needInReloadDefaultArgs = true;

   string symStr = symbol;
   string wholeSpec = NULL;
   if(!symbol){
      symStr = "ANY";
   }
   
   int size = ArraySize(specifications);
   int index = -1;
   for(int i = 0; i < size; i++){
      if(symbols[i] == symStr){
         index = i;
         break;
      }
   }
   
   if(index == -1){
      string newSymbols[];
      string newSpecifications[];
      ArrayResize(newSpecifications, size + 1);
      ArrayResize(newSymbols, size + 1);
   
      ArrayCopy(newSymbols, symbols);
      ArrayCopy(newSpecifications, specifications);
      ArrayResize(symbols, size + 1);
      ArrayResize(specifications, size + 1);
      
      newSpecifications[size] = spec;
      newSymbols[size] = symStr;
      wholeSpec = spec;
      
      ArrayCopy(symbols, newSymbols);
      ArrayCopy(specifications, newSpecifications);
   }
   else{
      if(!setting)
         specifications[index] = specifications[index] + ";" + spec;
      else
         specifications[index] = spec;
         
      wholeSpec = specifications[index];
   }

   l5Db.Query("REPLACE INTO indicators_specifications (indicator_name, symbol, value) VALUES ('" + GetName() + "', '" + symStr + "', '" + wholeSpec + "')");

   return true;
};

bool SPECIFICATION::SetSpecification(string spec,string symbol=NULL){
   LoadSpecifications(true);
   return AddSpecification(spec, symbol, true);
};

bool SPECIFICATION::Generate(int argListIndex = -1, string symbol = NULL, bool withoutSize = false){
   
   if(!symbol)
      symbol = "ANY";
   bool res = false;
   bool checkingF = false;
   string errMsg = NULL;
   int len = ArraySize(symbols);
   int index = -1;
   for(int i = 0; i < len; i++){
      if(symbols[i] == symbol){
         index = i;
         break;
      }
   }
   
   if(symbol != "ANY" && index == -1){
      symbol = "ANY";
      for(int i = 0; i < len; i++){
         if(symbols[i] == symbol){
            index = i;
            break;
         }
      }
   }
   
   if(index != -1){
      if((prevAskedSymbol == symbol) && (argsQueueSize != -1) && (argListIndex == -1 || (argListIndex != -1 && (argListIndex >= cachePositions[0] && argListIndex <= cachePositions[1]))))
         return true;
      prevAskedSymbol = symbol;
      if(withoutSize && argsQueueSize == -1)
         withoutSize = false;
      
      string spec = specifications[index];
      
      string pockets[];
      string argsNames[];
      string argsTypes[];
      string strArgs[];
      ARG_LIST argsValues[];
      string conditions[];
     
      if(preg_match_split(";", spec, strArgs)){
         int lenArgs = ArraySize(strArgs);
         ArrayResize(argsNames, lenArgs);
         ArrayResize(argsTypes, lenArgs);
         ArrayResize(argsValues, lenArgs);
         ArrayResize(conditions, lenArgs);
         
         checkingF = true;
         int newLenArgs = lenArgs;
         
         int timeframesArgsPosition = -1;
         int aTaDAtimeframes[][6];  //IMPORTANT!!!: IN CHANGES TIMEFRAMES CHANGE THE SIZE
         string aTaDAvalues[][6];
         ArrayResize(aTaDAtimeframes, lenArgs);
         ArrayResize(aTaDAvalues, lenArgs);
         
         for(int i = 0, j = 0; i < lenArgs; i++){
            if(strArgs[i] == "" || preg_match("^(\s+)$", strArgs[i], pockets)){
               newLenArgs--;
            }
            else if(preg_match("^\s*(\w+)\s*:\s*(\w+)\s*=\s*(.+)\s*$", strArgs[i], pockets)){
               argsNames[j] = pockets[1];
               argsTypes[j] = pockets[2];
               
               string definition = pockets[3];
               string definitions[];
               for(int sfi = 0; sfi < timeFramesLimit; sfi++)
                  aTaDAtimeframes[j][sfi] = 0;
              
               if(preg_match_split("\]\s*\[", definition, definitions)){
                  int defLen = ArraySize(definitions);
                  mstring valuesBuff[];
                  int limitOfNumOfValues = limitOfSpecificationValuesLength; 
                  ArrayResize(valuesBuff, limitOfNumOfValues);
                  int valuesLen = 0;
                  for(int d = 0; d < defLen; d++){
                     StringReplace(definitions[d], "]", "");
                     StringReplace(definitions[d], "[", "");
                     if(preg_match("^\s*%(\w+)%\s*$", definitions[d], pockets)){
                        //range_constant
                        string constName = pockets[1];
                        if(constName == "TIME_FRAME"){
                           if(valuesLen + timeFramesLimit > limitOfNumOfValues){
                              checkingF = false;
                              errMsg = "limit of number of values of argument in definition is reached";
                              break;
                           }
                           
                           for(int tmi = 0; tmi < timeFramesLimit; tmi++)
                               valuesBuff[valuesLen++] = (string) allowedTimeFrames[tmi];
                           
                           timeframesArgsPosition = j;
                        }
                        else {
                           checkingF = false;
                           errMsg = "unknown constant of range";
                           break;
                        }
                     }
                     else if(preg_match("^\s*([0-9.]+)\s*-\s*([0-9.]+)\s*,\s*([0-9.]+)\s*$", definitions[d], pockets)){
                        //range
                        double startV = StrToDouble(pockets[1]);
                        double endV = StrToDouble(pockets[2]);
                        double stepV = StrToDouble(pockets[3]);
                        if(stepV == 0)
                        {
                           errMsg = "step equals zero in range definition";
                           checkingF = false;
                           break;
                        }
                        int lenRange = (int) MathCeil((endV - startV) / stepV) + 1;
                        if(lenRange <= 0 || (valuesLen + lenRange > limitOfNumOfValues))
                        {
                           if(lenRange > 0)
                              errMsg = "limit of number of values of argument in definition is reached";
                           else
                              errMsg = "wrong range definition";
                              
                           checkingF = false;
                           break;
                        }
                        
                        for(int k = 0; k < lenRange; k++){
                           double val = startV + k*stepV;
                           if(val > endV)
                              break;
                           valuesBuff[valuesLen++] = (string) ((argsTypes[j] == "int")?MathRound(val):val);
                        }
                     }
                     else if(preg_match("^\s*=(.+)$", definitions[d], pockets)){
                        if(valuesLen + 1 > limitOfNumOfValues){
                              checkingF = false;
                              errMsg = "limit of number of values of argument in definition is reached";
                              break;
                        }
                        string sval = pockets[1];
                        string svals[];
                        string val = "";
                        int shcount = 0;
                        
                        if(sval != "" && preg_match_split("=", sval, svals)){
                           int svalsLen = ArraySize(svals);
                           for(int svi = 0; svi < svalsLen; svi++){
                              int sharpPos = StringFind(svals[svi], "#");
                              if(sharpPos != -1){
                                 string fval = StringSubstr(svals[svi], 0, sharpPos);
                                 int ftimeframe = StrToInteger(StringSubstr(svals[svi], sharpPos + 1));
                                 if(svi == 0)
                                    val = fval;
                                 if(ftimeframe && shcount++ < timeFramesLimit){
                                    aTaDAtimeframes[j][shcount - 1] = ftimeframe;
                                    aTaDAvalues[j][shcount - 1] = fval;
                                 }
                              }
                              else
                                 val = svals[svi];
                           }
                        }
                        else
                           val = sval;
                        
                        if(argsTypes[j] == "int")
                           val = (string) StringToInteger(val);
                        if(argsTypes[j] == "double")
                           val = (string) StringToDouble(val);
                        if(valuesLen > 0){
                           int found = -1;
                           for(int k = 0; k < valuesLen; k++)
                              if(valuesBuff[k].InS() == val){
                                 found = k;
                                 break;
                              }
                           
                           if(found == -1){
                              mstring temp = valuesBuff[0];
                              valuesBuff[0] = val;
                              valuesBuff[valuesLen++] = temp;
                           }
                           else{
                              mstring temp = valuesBuff[0];
                              valuesBuff[0] = val;
                              valuesBuff[found] = temp;
                           }
                        }
                        else{
                           valuesBuff[valuesLen++] = val;
                        }
                     }
                     else if(preg_match("^\s*where\s*\((.+)\)\s*$", definitions[d], pockets)){
                        conditions[j] = pockets[1];
                     }
                     else if(preg_match_split("\s*,\s*", definitions[d], pockets)){
                        int length = ArraySize(pockets);
                        if(valuesLen + length > limitOfNumOfValues){
                              checkingF = false;
                              errMsg = "limit of number of values of argument in definition is reached";
                              break;
                        }
                        for(int k = 0; k < length; k++){
                           string val = pockets[k];
                           if(argsTypes[j] == "int")
                              val = (string) StringToInteger(val);
                           if(argsTypes[j] == "double")
                              val = (string) StringToDouble(val);
                           valuesBuff[valuesLen++] = val;
                        }
                     }
                     else{
                        checkingF = false;
                        errMsg = "unknown definition format";
                        break;
                     }
                  }
                 
                  if(!checkingF)
                     break;
                  else{
                     mstring values[];
                     ArrayResize(values, valuesLen);
                     for(int m = 0; m < valuesLen; m++)
                        values[m] = valuesBuff[m];
                     argsValues[j].SetList(values);
                  }
               }
               else{
                  checkingF = false;
                  errMsg = "wrong definition in argument: " + argsNames[j];
                  break;
               }    
               
               j++;
            }
            else{
               checkingF = false;
               errMsg = "wrong specification format on value --" + strArgs[i] + "--";
               break;
            }
         }
         
         if(checkingF){
            if(newLenArgs <= 0)
            {
               checkingF = false;
               errMsg = "specification is defined as empty list of arguments";
            }
            else{
               //Formation of arg_queue
               int argQLen = 1;
               int sizes[];
               ArrayResize(sizes, newLenArgs);
               for(int i = 0; i < newLenArgs; i++){
                  int size = argsValues[i].Size();
                  if(!size)
                  {
                     checkingF = false;
                     errMsg = "One of specification argument is defined as empty list";
                     break;
                  }
                  argQLen *= size;
                  sizes[i] = size;
                  //Unique elements
                  int p = 0;
                  mstring newValues[]; 
                  ArrayResize(newValues, size);
                  int countNewValues = 0;
                  while(p < size){
                     int k = 0;
                     while(k < countNewValues && newValues[k] != argsValues[i].list[p]) k++;
                     if(k == countNewValues) newValues[countNewValues++] = argsValues[i].list[p];
                     p++;
                  }
                  
                  if(countNewValues != size){
                     mstring valuesA[];
                     ArrayResize(valuesA, countNewValues);
                     for(int k = 0; k < countNewValues; k++)
                        valuesA[k] = newValues[k];
                     argsValues[i].SetList(valuesA);
                  }
               }
               if(checkingF){
                  if(argQLen > limitOfArgQueueSize){
                     checkingF = false;
                     errMsg = "number of arguments in specification definition is too large {value: " + (string) argQLen + "}";
                  }
                  else{
                     //formation of condition
                     int condNumber = 0;
                     string newConditions[];
                     ArrayResize(newConditions, newLenArgs);
                     int argsIndexes[];
                     ArrayResize(argsIndexes, newLenArgs);
                     for(int d = 0; d < newLenArgs; d++)
                        if(conditions[d] != NULL){
                           newConditions[condNumber] = conditions[d];
                           argsIndexes[condNumber++] = d;
                        }
                     int tCNumberGroups[];
                     int tCIndexesInGroups[][30][2]; //30 groups is maximum
                     int tCOperatorsInGroups[][30]; 
                     string tCValuesInGroups[][30][2];
                     int tConditionBetweenGroups[][30];
                     bool tCresults[][30];
                     int arrayIntersectsIndexes[30][2];
                     
                     if(condNumber != 0){
                        ArrayCopy(conditions, newConditions);
                        ArrayResize(tCNumberGroups, condNumber);
                        ArrayResize(tCIndexesInGroups, condNumber);
                        ArrayResize(tCOperatorsInGroups, condNumber); 
                        ArrayResize(tCresults, condNumber); 
                        ArrayResize(tCValuesInGroups, condNumber); 
                        ArrayResize(tConditionBetweenGroups, condNumber);
                         
                        string argsA = "";
                        for(int i = 0; i < newLenArgs; i++)
                           argsA = argsA + "(?:" + argsNames[i] + ")|";
                        argsA = argsA + "(?:this)";
                        
                        for(int i = 0; i < condNumber; i++){
                           if(!checkingF)
                              break;
                              
                           string condition = conditions[i];
                           int startPos = 0;
                           int startPositions[];
                           int lengthes[];
                           int limitOfConditonGroups = 30; //don't forget change it value above
                           int groupsCount = 0;
                           
                           string regExp = "\s*((?:or )?|(?:and )?)\s*("+argsA+"|(?:[0-9.]+)|(?:\"(?:.+?)\"))\s*([!=<>]+)\s*("+argsA+"|(?:[0-9.]+)|(?:\"(?:.+?)\"))\s*";
                           while(preg_match_offset(regExp, condition, pockets, startPositions, lengthes, startPos)){
                                 if(groupsCount == limitOfConditonGroups)
                                 {
                                    checkingF = false;
                                    errMsg = "limit of number of condition groups has been reached";
                                 }
                                 startPos = startPositions[0] + lengthes[0];
                                 
                                 if(!checkingF)
                                    break;
                                    
                                 string c = "";
                                 if(pockets[1] == "and ")
                                    c = "and";
                                 else if(pockets[1] == "or ")
                                    c = "or";
                                  
                                  
                                 string lo = pockets[2];
                                 string o = pockets[3];
                                 string ro = pockets[4];
                                 
                                  int index1 = -1, index2 = -1;
                                 for(int k = 0; k < newLenArgs; k++)
                                    if(lo == argsNames[k])
                                    {
                                       index1 = k;
                                       break;
                                    }
                                 for(int k = 0; k < newLenArgs; k++)
                                    if(ro == argsNames[k])
                                    {
                                       index2 = k;
                                       break;
                                    }
                                 
                                 if(lo == "this")
                                   index1 = argsIndexes[i];
                                 else if(ro == "this")
                                   index2 = argsIndexes[i];
                                 
                                 if(index1 == -1 && index2 == -1)
                                 {
                                    checkingF = false;
                                    errMsg = "condition definition hasn't filter of arguments";
                                 }
                                 int operatorI = 0;
                                 if(o == "=")
                                    operatorI = 1;
                                 else if(o == "!=")
                                    operatorI = 2;
                                 else if(o == "<>")
                                    operatorI = 2;   
                                 else if(o == "<")
                                    operatorI = 3;   
                                 else if(o == ">")
                                    operatorI = 4;   
                                 else if(o == ">=")
                                    operatorI = 5;  
                                 else if(o == "<=")
                                    operatorI = 6;  
                                 else{
                                     checkingF = false;
                                     errMsg = "condition definition hasn't supported operators of comparison";
                                 }
                                 
                                 if(checkingF){
                                    StringReplace(ro, "\"", "");
                                    StringReplace(lo, "\"", "");
                                    tCIndexesInGroups[i][groupsCount][0] = index1;
                                    tCIndexesInGroups[i][groupsCount][1] = index2;
                                    tCValuesInGroups[i][groupsCount][0] = lo;
                                    tCValuesInGroups[i][groupsCount][1] = ro;
                                    tCOperatorsInGroups[i][groupsCount] = operatorI;
                                    tConditionBetweenGroups[i][((groupsCount - 1) > 0?groupsCount - 1:0)] = (c == "and")?1:2;
                                 }
                                 else{
                                    break;
                                 }
                                 
                                 groupsCount++;
                              }
                              if(groupsCount != 0)
                                 tCNumberGroups[i] = groupsCount;
                              else{
                                 checkingF = false;
                                 errMsg = "Uncorrected definition of condition: [" + (string) condition + "]";
                                 break;
                              }
                         }
                     }
                     
                     if(checkingF){
                        //generates
                        int newSize = 0;
                        
                        mstring values[];
                        ArrayResize(values, newLenArgs);
                        int indexes[];
                        ArrayResize(indexes, newLenArgs);
                        ArrayFill(indexes, 0, newLenArgs, 0);
                        bool breakF = false;
                        
                        bool cacheInited = false;
                        int cacheCount = 0;
                       
                        while(true){
                           for(int i = 0; i < newLenArgs; i++){
                               values[i] = argsValues[i].list[indexes[i]];  
                           }
                           
                           //condition parser
                           bool suitable = true;
                           if(condNumber != 0){
                              
                              for(int i = 0; i < condNumber; i++){
                                 bool localSuitable = false;
                                 for(int j = 0; j < tCNumberGroups[i]; j++){
                                    string val1, val2;
                                    double val1D = 0, val2D = 0;
                                    int index1 = tCIndexesInGroups[i][j][0];
                                    int index2 = tCIndexesInGroups[i][j][1];
                                    int operatorI = tCOperatorsInGroups[i][j];
                                    string lo = tCValuesInGroups[i][j][0]; 
                                    string ro = tCValuesInGroups[i][j][1];  
                                    
                                    if(index1 != -1 && index2 != -1){
                                       val1 = values[index1].InS();
                                       val2 = values[index2].InS();
                                    }
                                    else if(index1 != -1){
                                       val1 = values[index1].InS();
                                       val2 = ro;
                                    }
                                    else if(index2 != -1){
                                       val2 = values[index2].InS();
                                       val1 = lo;
                                    }
                                          
                                    if(operatorI == 3 || operatorI == 4 || operatorI == 5 || operatorI == 6){
                                         if(index1 != -1){
                                             if(argsTypes[index1] == "int")
                                                val1D = (double) StringToInteger(val1);
                                              else if(argsTypes[index1] == "double")
                                                val1D = StringToDouble(val1);
                                              else
                                                 checkingF = false;
                                          }else{
                                             if(index2 != -1){  
                                                if(argsTypes[index2] == "int")
                                                    val1D = (double) StringToInteger(val1);
                                                else if(argsTypes[index2] == "double")
                                                    val1D = StringToDouble(val1);
                                              }
                                          }
                                                
                                          if(index2 != -1){  
                                              if(argsTypes[index2] == "int")
                                                 val2D = (double) StringToInteger(val2);
                                              else if(argsTypes[index2] == "double")
                                                 val2D = StringToDouble(val2);
                                              else
                                                   checkingF = false;
                                           }
                                           else{
                                             if(index1 != -1){
                                                 if(argsTypes[index1] == "int")
                                                    val2D = (double) StringToInteger(val2);
                                                  else if(argsTypes[index1] == "double")
                                                     val2D = StringToDouble(val2);
                                                }
                                           } 
                                                   
                                           if(!checkingF)
                                           {
                                              errMsg = "incompatable types of arguments and operators in condition definition";
                                              break;
                                           }
                                       }
                                        
                                       tCresults[i][j] = false;
                                             
                                       switch(operatorI){
                                           case 1:{
                                              if(val1 == val2)
                                                   tCresults[i][j] = true;
                                            };break;
                                            case 2:{
                                               if(val1 != val2)
                                                   tCresults[i][j] = true;
                                             };break;
                                             case 3:{
                                                if(val1D < val2D)
                                                   tCresults[i][j] = true;
                                             };break;
                                             case 4:{
                                                if(val1D > val2D)
                                                   tCresults[i][j] = true;
                                             };break;
                                             case 5:{
                                               if(val1D >= val2D)
                                                 tCresults[i][j] = true;
                                             };break;
                                             case 6:{
                                               if(val1D <= val2D)
                                                  tCresults[i][j] = true;
                                               };break;
                                       } 
                                 }
                                 
                                 //logic realization
                                 int arrayIntersectsIndexesC = 0;
                                 int lastI = 0;
                                 if(tCNumberGroups[i] != 1){
                                    for(int d = 0; d < tCNumberGroups[i]; d++){
                                       if(tConditionBetweenGroups[i][d] != 1)//and
                                       {
                                          arrayIntersectsIndexes[arrayIntersectsIndexesC][0] = lastI;
                                          arrayIntersectsIndexes[arrayIntersectsIndexesC++][1] = d;
                                          lastI = d+1;
                                       }
                                    }
                                 }
                                 else{
                                    arrayIntersectsIndexes[arrayIntersectsIndexesC][0] = 0;
                                    arrayIntersectsIndexes[arrayIntersectsIndexesC++][1] = 0;
                                 }
                                 
                                 for(int d = 0; d < arrayIntersectsIndexesC; d++)
                                 {
                                    int index1 = arrayIntersectsIndexes[d][0];
                                    int index2 = arrayIntersectsIndexes[d][1];
                                    
                                    if(index1 == index2){
                                       localSuitable = localSuitable || tCresults[i][index1];
                                    }
                                    else{
                                       bool intersectRes = true;
                                       for(int l = index1; l <= index2; l++){
                                          intersectRes = intersectRes && tCresults[i][l];
                                       }
                                       localSuitable = localSuitable || intersectRes;
                                    }
                                 }
                                 
                                 suitable = suitable && localSuitable;
                                 if(!suitable)
                                    break;
                                    
                                 if(!checkingF)
                                 {
                                    breakF = true;
                                    break;
                                 }
                              }
                           }
                           
                           if(checkingF && suitable){
                              //association def args with timeframes
                              if(newSize < timeFramesLimit && timeframesArgsPosition != -1){
                                    int tfVal = StringToInteger(values[timeframesArgsPosition].InS());
                                    for(int at = 0; at < newLenArgs; at++){
                                       for(int at2 = 0; at2 < timeFramesLimit; at2++)
                                          if(aTaDAtimeframes[at][at2] == tfVal){
                                             values[at] = aTaDAvalues[at][at2];
                                          }
                                    }
                              }  
                           
                              newSize++;
                              if(argListIndex != -1 && cacheCount < limitOfCacheForQueues){
                                 if(!cacheInited){
                                    cachePositions[0] = argListIndex;
                                    cachePositions[1] = argListIndex + limitOfCacheForQueues - 1;
                                    ArrayResize(cache, limitOfCacheForQueues);
                                    cacheInited = true;
                                 }
                                 
                                 if(newSize > argListIndex)
                                    cache[cacheCount++].SetList(values);
                                    
                                 if(withoutSize && cacheCount == limitOfCacheForQueues)
                                 {
                                    break;
                                 }
                              }
                           }
                           
                           for(int i = 0; i < newLenArgs; i++){
                              if((indexes[i] == sizes[i]) || (i == 0 && indexes[i] == sizes[i] - 1)){
                                 if(i != newLenArgs - 1){
                                    //lower
                                    indexes[i+1]++;
                                    //upper
                                    for(int u = i; u >=0; u--)
                                       indexes[u] = 0;
                                 }
                                 else{
                                    breakF = true;
                                    break;
                                 }
                              }
                              else if(i == 0){
                                 indexes[i]++;
                              }
                           }
                           
                           if(breakF)
                              break;
                        }
                        
                        if(newSize == 0)
                        {
                           checkingF = false;
                           errMsg = "Condition definition clears all list of arguments in queue";
                        }   
                        
                        if(checkingF && !withoutSize)
                           argsQueueSize = newSize;
                        else if(!checkingF)
                           argsQueueSize = -1;
                     }
                     
                     if(checkingF)
                         res = true;
                  }  
               }
            }
         }
      }
      else{
         checkingF = false;
         errMsg = "specification hasn't arguments' definitions";
      }
   }
   else{
      checkingF = false;
      errMsg = "undefined symbol in specifications";
   }
   
   if(!checkingF){
        ErrPrint("SPECIFICATION PARSER: " + errMsg + " in " + GetName() + " indicator");
   }   
   
   return res;
}

int SPECIFICATION::GenerateArgsSize(string symbol=NULL){
   if(argsQueueSize == -1)
      Generate(-1, symbol);
   return argsQueueSize;
}

ARG_LIST SPECIFICATION::GenerateArgList(int index, string symbol=NULL){
   if(Generate(index, symbol, true))
      return cache[index - cachePositions[0]];
   else 
   {
      ARG_LIST fict;
      return fict;
   }
}

string SPECIFICATION::BuildSpecificationByDefArgs(ARG_LIST& defaultArgs, int timeframe, string origin){
   string symbol = l5Symbol;
   string resultSpecification = "";
   bool res = false;
   bool checkingF = false;
   string errMsg = NULL;
   int len = ArraySize(symbols);
   int index = -1;
   for(int i = 0; i < len; i++){
      if(symbols[i] == symbol){
         index = i;
         break;
      }
   }
   
   if(symbol != "ANY" && index == -1){
      symbol = "ANY";
      for(int i = 0; i < len; i++){
         if(symbols[i] == symbol){
            index = i;
            break;
         }
      }
   }
   
   string newSpec;
   if(index != -1 || origin != ""){
      string spec = origin !=""?origin:specifications[index];
      
      string pockets[];
      string argsNames[];
      string argsTypes[];
      string strArgs[];
     
      if(preg_match_split(";", spec, strArgs)){
         int lenArgs = ArraySize(strArgs);
         ArrayResize(argsNames, lenArgs);
         ArrayResize(argsTypes, lenArgs);
         
         checkingF = true;
         int newLenArgs = lenArgs;
         for(int i = 0, j = 0; i < lenArgs; i++){
            if(strArgs[i] == "" || preg_match("^(\s+)$", strArgs[i], pockets)){
               newLenArgs--;
            }
            else if(preg_match("^\s*(\w+)\s*:\s*(\w+)\s*=\s*(.+)\s*$", strArgs[i], pockets)){
               argsNames[j] = pockets[1];
               argsTypes[j] = pockets[2];
               
               string definition = pockets[3];
               string definitions[];
               
               newSpec = (newSpec + argsNames[j] + ":" + argsTypes[j] + " = ");
               if(preg_match_split("\]\s*\[", definition, definitions)){
                  int defLen = ArraySize(definitions);
                  string defVal = defaultArgs.Get(j);
                  if(argsTypes[j] == "int")
                       defVal = (string) StringToInteger(defVal);
                  if(argsTypes[j] == "double")
                       defVal = (string) StringToDouble(defVal);
                  bool foundDefArgs = false;   
                  string tfString =  + (timeframe != 0?"#" + (string) timeframe:"");
                  
                  for(int d = 0; d < defLen; d++){
                     StringReplace(definitions[d], "]", "");
                     StringReplace(definitions[d], "[", "");
                     if(preg_match("^\s*=(.+)$", definitions[d], pockets)){
                        string sval = pockets[1];
                        string svals[];
                        int shcount = 0;
                        string newDefArgsDefinition = "[=" + defVal + tfString;
                        
                        if(sval != "" && preg_match_split("=", sval, svals)){
                           int svalsLen = ArraySize(svals);
                           for(int svi = 0; svi < svalsLen; svi++){
                              if(svals[svi] == "")
                                 continue;
                           
                              int sharpPos = StringFind(svals[svi], "#");
                              if(sharpPos != -1){
                                 string fval = StringSubstr(svals[svi], 0, sharpPos);
                                 int ftimeframe = StrToInteger(StringSubstr(svals[svi], sharpPos + 1));
                                
                                 if(ftimeframe != timeframe){
                                    newDefArgsDefinition = newDefArgsDefinition + "=" + svals[svi];
                                 }
                              }
                              else if(timeframe)
                                 newDefArgsDefinition = newDefArgsDefinition + "=" + svals[svi];
                           }
                        }
                        
                        newDefArgsDefinition = newDefArgsDefinition + "]";
                        newSpec = (newSpec + newDefArgsDefinition);
                        
                        foundDefArgs = true;
                     }
                     else{
                        newSpec = (newSpec + "[" + definitions[d] + "]");
                     }
                  }
                 
                  if(!foundDefArgs){
                     newSpec = (newSpec + "[=" + defVal + tfString + "]");
                  }
                 
                  if(!checkingF)
                     break;
               }
               else{
                  checkingF = false;
                  errMsg = "wrong definition in argument: " + argsNames[j];
                  break;
               }    
               newSpec = newSpec + ";\n";
               j++;
            }
            else{
               checkingF = false;
               errMsg = "wrong specification format on value --" + strArgs[i] + "--";
               break;
            }
         }
      }
   }
   
   if(errMsg != NULL){
      ErrPrint("SPECIFICATION MANAGER: " + errMsg);
   }
   else
      resultSpecification = newSpec;
   
   
   return resultSpecification; 
}

/*
 * END SPECIFICATION CLASS
 */

 /*
  * INDICATOR
  * The class is extended by SAMPLE_INDICATOR_CLASS
  */
  
  class INDICATOR: public SPECIFICATION{
      protected:
         string name;
         ARG_LIST args;
         bool isByTimeframes;
  
      public:
         INDICATOR():name(""),isByTimeframes(true){};
         virtual string GetName();
         void SetArgs(ARG_LIST& args);
         string GetArgsHash();
         virtual int Perform(){ return VOID_SIGNAL; }
         bool IsByTimeframes(){ return isByTimeframes; }
         void NoByTimeframes(bool arg = false){ isByTimeframes = arg; }
  };
  
string INDICATOR::GetName(){
   return name;
}

void INDICATOR::SetArgs(ARG_LIST& arg_list){
   args = arg_list;
}

string INDICATOR::GetArgsHash(){
   return args.GetHash();
}
  
 /*
  * END INDICATOR
  */
   

   /*
    * INCLUDES LIST OF SIGNALS
    */
#include "signal_list.mqh"

   /*
    * END INCLUDING
    */
    

/*
 * INDICATOR MANAGER CLASS
 * The class provides methods of control of indicators
 * Every new indicator being added in signal_list.mqh file must be added in the constructor of the class
 */

class INDICATOR_MANAGER{
   private:
      INDICATOR* indicators[];
      int length;
      
   public:
      INDICATOR_MANAGER();
      ~INDICATOR_MANAGER();
      int GetNumIndicators();
      INDICATOR* GetIndicator(int indicatorIndex);
      int  GetArgQueueSize(int indicatorIndex);
      ARG_LIST GetArgList(int indicatorIndex, int argListIndex);
      bool SetSpecification(int indicatorIndex, string spec, string symbol = NULL);
      string GetTips();
};

//*************************************************************************************
//new indicators must be added in the constructor
//*************************************************************************************

INDICATOR_MANAGER::INDICATOR_MANAGER(){
    length = 0;
    
    int limitOfIndicators = 1000;
    ArrayResize(indicators, limitOfIndicators);
    
    //indicators[length++] = new SAMPLE_OF_INDICATOR
    indicators[length++] = new SIGNAL_MA;
    indicators[length++] = new SIGNAL_SAR;
    indicators[length++] = new SIGNAL_AD;
    indicators[length++] = new SIGNAL_CCI;
    indicators[length++] = new SIGNAL_STOCHASTIC;
    indicators[length++] = new SIGNAL_FRACTALS;
    indicators[length++] = new SIGNAL_MFI;
    indicators[length++] = new SIGNAL_OBV;
    indicators[length++] = new SIGNAL_ICHIMOKU;
    indicators[length++] = new SIGNAL_FibboPivotPulseSn;
    indicators[length++] = new SIGNAL_PivotDaily;
    indicators[length++] = new SIGNAL_CUSTOM_MACD;
    indicators[length++] = new SIGNAL_EA_VEGAS;
    indicators[length++] = new SIGNAL_VOLATILITY_PIVOT;
    indicators[length++] = new SIGNAL_ZIGZAG;
    indicators[length++] = new HEIKEN_ASHI_SIGNAL;
    indicators[length++] = new MTF_FOREX_FREEDOM_SIGNAL;
    indicators[length++] = new SIGANL_RSI_XOVER;
    indicators[length++] = new SIGNAL_SILVER_TREND;
    indicators[length++] = new SIGNAL_SDX_ZONE_BREAKOUT;
    indicators[length++] = new SIGNAL_DYN_ALL_LEVELS;
    indicators[length++] = new SIGNAL_EF_DISTANCE;
    indicators[length++] = new SIGNAL_3D_OSCILATOR;
    indicators[length++] = new SIGNAL_4_Trendline_MKS;
    indicators[length++] = new SIGNAL_AFSTAR;
    indicators[length++] = new SIGNAL_ATR_CHANNELS;
    indicators[length++] = new SIGNAL_BULLS_BEARS_EYES;
    indicators[length++] = new SIGNAL_DFC_NEXT;
    indicators[length++] = new DIVERGENCE_SIGNAL;
    indicators[length++] = new SIGNAL_ICWR;
    indicators[length++] = new SIGNAL_JMA;
    indicators[length++] = new SIGNAL_PATTERN_RECOGNITION;
    indicators[length++] = new SIGNAL_PIVOT_RANGE;
    indicators[length++] = new SIGNAL_TREND_CONTINUATION;
    indicators[length++] = new SIGNAL_WSOWROTrend;
    indicators[length++] = new SIGNAL_DONCHIANFIBO;
    indicators[length++] = new SIGNAL_MA_BBANDS;
    indicators[length++] = new SIGNAL_BillWilliams_ATZ;
    
    if(length > limitOfIndicators){
         ErrPrint("INDICATOR MANAGER: limit of number of indicators has been reached");
         ExpertRemove();
    }
}

INDICATOR_MANAGER::~INDICATOR_MANAGER(void){
   for(int i = 0; i < length; i++)
      if(CheckPointer(indicators[i]) != POINTER_INVALID)
         delete indicators[i];
}

int INDICATOR_MANAGER::GetNumIndicators(){
   return length;
}

INDICATOR* INDICATOR_MANAGER::GetIndicator(int indicatorIndex){
   return indicators[indicatorIndex];
}

bool INDICATOR_MANAGER::SetSpecification(int indicatorIndex, string spec, string symbol=NULL){
   return indicators[indicatorIndex].SetSpecification(spec, symbol); 
}

string INDICATOR_MANAGER::GetTips(){
   string result = "";
   
   return result;
}

int INDICATOR_MANAGER::GetArgQueueSize(int indicatorIndex){
   return indicators[indicatorIndex].GenerateArgsSize(l5Symbol);
}

ARG_LIST INDICATOR_MANAGER::GetArgList(int indicatorIndex,int argListIndex){
   return indicators[indicatorIndex].GenerateArgList(argListIndex, l5Symbol);
}

/*
 * END INDICATOR MANAGER CLASS
 */ 