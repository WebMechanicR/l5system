//+------------------------------------------------------------------+
//|                                              mysql_interface.mqh |
//|             Copyright 2013, Tim Jackson <webmechanicr@gmail.com> |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Tim Jackson <webmechanicr@gmail.com>"
#property link      "http://www.mql5.com"
#property strict

#include "mql4-mysql.mqh"

class MysqlRow{
   public:
      string f[];
};

class MysqlDB {
   private:
      int handler;
      int num_fields;
      int num_rows;
      string host;
      string user;
      string password;
      string dbName;
      int port;
      
      void clearResult(){
         if(num_rows != 0){
            for(int i = 0; i < num_rows; i++){
               if(CheckPointer(result[i]) == POINTER_INVALID)
                  continue;
               delete result[i];
            }
         }
         
         num_rows = num_fields = 0;
      };
      
      
   public:
      MysqlRow* result[];
    
      MysqlDB(string ahost, string auser, string apassword, string adbName, int aport = 3306){
          handler = 0;
          num_fields = 0;
          num_rows = 0;
          
          host = ahost;
          user = auser;
          password = apassword;
          dbName = adbName;
          port = aport;
          
          if(!init_MySQL(handler, host, user, password, dbName, port)){
               return;
          }
      }
      
      bool Query(string query){
          clearResult();
           
          if (!MySQL_Query(handler, query) ) {
              return false;
          }
          
          int resultStruct = mysql_store_result(handler);
          
          if ( !MySQL_NoError(handler) ) {
              MsgPrint("MySQL error: (fetchArray) resultStruct:" + (string) resultStruct);
              return false;
          }
          if(!resultStruct)// 0 rows selected;
          {
            return true;
          }
          
          num_rows   = mysql_num_rows(resultStruct);
          num_fields = mysql_num_fields(resultStruct);
          
          char byte[];
          
          if (num_rows == 0){// 0 rows selected;
              return true;
          }
          
          ArrayResize(result, num_rows);
          
          for(int i = 0; i < num_rows; i++ ) {
            int row_ptr = mysql_fetch_row(resultStruct);
            int len_ptr = mysql_fetch_lengths(resultStruct);
            
            result[i] = new MysqlRow;
            if(result[i] == NULL){
               MsgPrint("MySQL error: (fetchArray) error in memory allocation");
               num_rows = i; 
               break;
            }
            ArrayResize(result[i].f, num_fields);
             
            for ( int j = 0; j < num_fields; j++ ) {
               int leng;
               memcpy(leng, len_ptr + j*sizeof(int), sizeof(int));
               
               ArrayResize(byte,leng+1);
               ArrayInitialize(byte,0);
               
               int row_ptr_pos;
               memcpy(row_ptr_pos, row_ptr + j*sizeof(int), sizeof(int));
               memcpy(byte, row_ptr_pos, leng);
               
               string s = CharArrayToString(byte);
               result[i].f[j] = s;
               
               LocalFree(leng);
               LocalFree(row_ptr_pos);
            }
          }
          
          mysql_free_result(resultStruct);
          
          if (MySQL_NoError(handler) ) {
              return (true);
          }
          else{
            clearResult();
            return (false);
          } 
      }
      
      int Fields(){
         return num_fields;
      }
      
      int Rows(){
         return num_rows;
      }
      
      int InsertId(){
         int res = 0;
         if(handler)
            res = mysql_insert_id(handler);
         return res;
      }
      
      ~MysqlDB(){
         if(handler){
            deinit_MySQL(handler);
            clearResult();
         }
      }
      
      bool IsInited(){
         return (bool) handler;
      };
      
      bool ReConnect(){
         clearResult();
         deinit_MySQL(handler);
         handler = 0;
         return init_MySQL(handler, host, user, password, dbName, port);
      }
};

