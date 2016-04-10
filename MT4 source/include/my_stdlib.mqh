//+------------------------------------------------------------------+
//|                                                    constants.mq4 |
//|             Copyright 2014, Tim Jackson <webmechanicr@gmail.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Tim Jackson <webmechanicr@gmail.com>"


//Constants
#define BUY_SIGNAL  1
#define SELL_SIGNAL 2
#define VOID_SIGNAL 0



//Other functions
void ErrPrint(string amsg){
   string msg = "SYSTEM ERROR: " + amsg;
#ifdef __CHV
   mql4_log(msg);
#endif
   Print(msg);
}

void ErrPrint(string amsg, bool is_error){
   string msg = "SYSTEM ERROR: " + amsg;
#ifdef __CHV
   mql4_log(msg);
#endif
   Print(msg);
   if(is_error){
      if(!IsTesting())
         MessageBox(msg, "ERROR", MB_ICONERROR);
#ifdef __CHV
      else
         MessageBoxW(0, msg, "ERROR", MB_ICONERROR);
#endif
      ExpertRemove();
   }
}

void ErrPrint(string type, string msg, int code = 0){
   string str = type + " ERROR " + (string) code + ": " + msg;
#ifdef __CHV
   mql4_log(str);
#endif
   Print(str);
}

void MsgPrint(string msg){
   string str = "L5 MESSAGE: " + msg;
#ifdef __CHV
   mql4_log(str);
#endif
   Print(str);
}

int cStringFind(const uchar& str[], string match, int start_pos = 0){
   int res = -1;
   
   int size = ArraySize(str);
   int size2 = StringLen(match);
   if(start_pos < 0 || start_pos >= size || size2 == 0)
      return res;
      
   bool breakF = false;
   for(int i = start_pos; i < size; i++){
      for(int j = i; j - i < size2; j++){
         if(j == size || str[j] != StringGetChar(match, j - i))
            break;
         else if(j - i == size2 - 1){
            res = i;
            breakF = true;
            break;  
         }
      }
      if(breakF)
         break;   
    }
   return res;
}

string cStringSubstr(uchar& str[], int start_pos = 0, int length = -1){
   string res = NULL;
   
   int size = ArraySize(str);
   if(start_pos < 0 || start_pos >= size)
       return res;
   res = CharArrayToString(str, start_pos, length); 
   return res;
}

class mstring{ 
   public:
      uchar data[];
      mstring(){};
      mstring(string arg);
      mstring(mstring&);
      void operator=(mstring&);   
      void operator=(string); 
      bool operator==(mstring&);
      bool operator!=(mstring&);
      string InS() const;
};

mstring::mstring(string arg){
   StringToCharArray(arg, data);
}

mstring::mstring(mstring& arg){
   operator=(arg);
}

void mstring::operator=(mstring& arg){
   ArrayResize(data, ArraySize(arg.data));
   ArrayCopy(data, arg.data);
}

void mstring::operator=(string arg){
   StringToCharArray(arg, data);
}

bool mstring::operator==(mstring& arg){
   if(ArraySize(arg.data) == ArraySize(data)){
      int s = ArraySize(arg.data);
      for(int i = 0; i < s; i++)
         if(arg.data[i] != data[i])
            return false;
      return true;
   }  
   else
      return false;
}

bool mstring::operator!=(mstring& arg){
   return (!operator==(arg));
}

string mstring::InS() const {
   return CharArrayToString(data);
}

#ifdef __CHV
string md5(string msg){
   uchar res[];
   ArrayResize(res, 32);
   mql4_md5_hash(msg, res);
   
   return CharArrayToString(res);
}

ulong md5_part(string msg, bool is_second = false, string calcmd5 = ""){
   uchar res[];
   double result = 0;
   
   ArrayResize(res, 33);
   if(calcmd5 == "")
      mql4_md5_hash(msg, res);
   else{
      StringToCharArray(calcmd5, res);
   }
   res[32] = 0;
   
   return mql4_md5_part(res, is_second);
}
#endif

double Factorial(double arg){
   double result = 1;
   double operand = arg;
   for(ulong i = 2; i <= (ulong) arg; i++){
      result *= operand;
      operand--;
   }
   return result;
}

ulong getTimeStamp(bool forTesting = false){
#ifdef __CHV
   if(!forTesting)
      return mql4_get_timestamp();
   else{
      if(!IsTesting())
         return mql4_get_timestamp();
      else
         return (ulong) TimeGMT();
   }
#else
      return TimeGMT();
#endif
}

#ifdef __CHV
ulong getMilliSeconds(){
   return mql4_get_timestamp(true);
}
#endif

double CalculatePoint(int intPoints){
      double result = Point;
      
      if(Digits == 5)
         result = 0.0001;
      if(Digits == 3)
         result = 0.01;
      
      return(result*intPoints);
 }
 
 double TruePointValue(int intPoints){
      if(Digits == 5)
         intPoints *= 10;
      return intPoints;
 }
 
 string QueryToL5Server(string get, string spost = "", int timeout = 25000){
      string result = "";
      static int errcount = 0;
      
      string headers;
      char response[];
      char post[];
      if(spost)
          StringToCharArray(spost, post, 0, WHOLE_ARRAY);
          
      if(!IsConnected()){
          errcount++;
          Sleep(700);
          if(errcount > 3){
               errcount = 0;
               
               result = "err";
               return result;
          }
          else
            return QueryToL5Server(get, spost);
      }
      
      if(WebRequest("POST", l5CentralServerAddress, NULL, NULL, timeout, post, ArraySize(post), response, headers) == -1){
         int err = GetLastError();
         if(err == ERR_WEBREQUEST_INVALID_ADDRESS)
         {
            MessageBox("WebRequest не разрешен. Добавьте сервер " + l5CentralServerAddress + " в настройки терминала", NULL, MB_ICONERROR);
            ErrPrint("WebRequest не разрешен. Добавьте сервер " + l5CentralServerAddress + " в настройки терминала");
            result = "err";
         }
         else if(err == ERR_FUNCTION_NOT_CONFIRMED){
            MessageBox("Ошибка запроса к удаленному серверу. Функция WebRequest выключена.", NULL, MB_ICONERROR);
            ErrPrint("Ошибка запроса к удаленному серверу. Функция WebRequest выключена");
            result = "err";
         }
         else if(err == ERR_WEBREQUEST_TIMEOUT){
            
         }
         else{
            errcount++;
            if(errcount > 3){
               errcount = 0;
               
               result = "err";
               return result;
            }
            else
               return QueryToL5Server(get, spost);
         }
      }
      else{
         result = CharArrayToString(response, 0, WHOLE_ARRAY);
         return result;
      }
      
      return result;
 }
 
 bool GetStopLevelsFromL5Server(int strategy, string symbol, double stopLevel, int& stopLoss, int& takeProfit, int& trailingStop, double& risk){
      bool res = false;
      string spost = "type=getting_levels&currency=" + symbol + "&strategy=" + (string) strategy;
      string response = QueryToL5Server(l5CentralServerAddress, spost, 10000);
      string blocks[];
      int len;
      if((len = StringSplit(response, StringGetChar("|", 0), blocks)) == 4){
            int rSL = StringToInteger(blocks[0]);
            int rTP = StringToInteger(blocks[1]);
            int rTS = StringToInteger(blocks[2]);
            double rRisk = StringToDouble(blocks[3]);
            
            if(tIAutomaticDefiningLevels && (rSL < stopLevel || rTP < stopLevel || rTS < stopLevel)) 
            {
               MessageBox("Stop levels taken from L5 Server do not correspond to minimal stop level! Trading strategy may work incorrectly!", NULL, MB_ICONERROR);
               ErrPrint("Stop levels taken from L5 Server do not correspond to minimal stop level! Trading strategy may work incorrectly!");
               if(rSL < stopLevel)
                  rSL = stopLevel;
               if(rTP < stopLevel)
                  rTP = stopLevel;
               if(rTS < stopLevel)
                  rTS = stopLevel;
            }
            
            stopLoss = rSL;
            takeProfit = rTP;
            trailingStop = rTS;
            risk = rRisk;
            res = true;
     }
     
     return res;
 }
