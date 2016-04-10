//+----------------------------------------------------------------------------+
//|                                                             mql4-mysql.mqh |
//+----------------------------------------------------------------------------+
//|                                                      Built by Sergey Lukin |
//|                                                    contact@sergeylukin.com |
//|                                                   Modified by Tim Jackson  |
//|                                                   <webmechanicr@gmail.com> |
//| This libarry is highly based on following:                                 |
//|                                                                            |
//| - MySQL wrapper by "russel": http://codebase.mql4.com/5040                 |
//| - MySQL wrapper modification by "vedroid": http://codebase.mql4.com/8122   |
//| - EAX Mysql: http://www.mql5.com/en/code/855                               |
//| - This thread: http://forum.mql4.com/60708 (Cheers to user "gchrmt4" for   |
//|   expanded explanations on how to deal with ANSI <-> UNICODE hell in MQL4  |
//|                                                                            |
//+----------------------------------------------------------------------------+
#property copyright "Unlicense"
#property link      "http://unlicense.org/"
 

//+----------------------------------------------------------------------------+
//| Connect to MySQL and write connection ID to the first argument             |
//| Probably not the most elegant way but it works well for simple purposes    |
//| and is flexible enough to allow multiple connections                       |
//+----------------------------------------------------------------------------+
bool init_MySQL(int & dbConnectId, string host, string user, string pass, string dbName, int port = 3306, int socket = 0, int client = 0) {
    dbConnectId = mysql_init(dbConnectId);
    
    if ( dbConnectId == 0 ) {
        MsgPrint("init_MySQL: mysql_init failed. There was insufficient memory to allocate a new object");
        return (false);
    }
    
    // Convert the strings to uchar[] arrays
   uchar hostChar[];
   StringToCharArray(host, hostChar);
   uchar userChar[];
   StringToCharArray(user, userChar);
   uchar passChar[];
   StringToCharArray(pass, passChar);
   uchar dbNameChar[];
   StringToCharArray(dbName, dbNameChar);
   
    if(!mql4_mysql_reconnect(dbConnectId))
      return false;
      
    int result = mysql_real_connect(dbConnectId, hostChar, userChar, passChar, dbNameChar, port, socket, client); 
    
    if ( result != dbConnectId ) {
        int errno = mysql_errno(dbConnectId);
        string error = mql4_mysql_ansi2unicode(mysql_error(dbConnectId));
        
        MsgPrint("init_MySQL: mysql_errno: " + (string) errno + "; mysql_error: " + error);
        return (false);
    }
    return (true);
}
 
//+----------------------------------------------------------------------------+
//|                                                                            |
//+----------------------------------------------------------------------------+
void deinit_MySQL(int dbConnectId){
    mysql_close(dbConnectId);
}
 
//+----------------------------------------------------------------------------+
//| Check whether there was an error with last query                           |
//|                                                                            |
//| return (true): no error; (false): there was an error;                      |
//+----------------------------------------------------------------------------+
bool MySQL_NoError(int dbConnectId) {
    int errno = mysql_errno(dbConnectId);
    string error = mql4_mysql_ansi2unicode(mysql_error(dbConnectId));
    
    if ( errno > 0 ) {
        MsgPrint("MySQL_NoError: mysql_errno: " + (string) errno + "; mysql_error: " + error);
        return (false);
    }
    return (true);
}
 
//+----------------------------------------------------------------------------+
//| Simply run a query, perfect for actions like INSERTs, UPDATEs, DELETEs     |
//+----------------------------------------------------------------------------+
bool MySQL_Query(int dbConnectId, string query) {
    uchar queryChar[];
    StringToCharArray(query, queryChar);
    
    mysql_query(dbConnectId, queryChar);
    if ( MySQL_NoError(dbConnectId) ) {
        return (true);
    }
    return (false);
}
 
//+----------------------------------------------------------------------------+
//| Fetch row(s) in a 2-dimansional array                                      |
//|                                                                            |
//| return (-1): error; (0): 0 rows selected; (1+): some rows selected;         |
//+----------------------------------------------------------------------------+
int MySQL_FetchArray(int dbConnectId, string query, string & data[][]){
 
    if ( !MySQL_Query(dbConnectId, query) ) {
        return (-1);
    }
    
    int resultStruct = mysql_store_result(dbConnectId);
    
    if ( !MySQL_NoError(dbConnectId) ) {
        MsgPrint("mysqlFetchArray: resultStruct: " +  (string) resultStruct);
        return (-1);
    }
    int num_rows   = mysql_num_rows(resultStruct);
    int num_fields = mysql_num_fields(resultStruct);
    
    char byte[];
    
    if ( num_rows == 0 ) {  // 0 rows selected;
        return (0);
    }
    
    ArrayResize(data, num_rows);
    
    for ( int i = 0; i < num_rows; i++ ) {
    
      int row_ptr = mysql_fetch_row(resultStruct);
      int len_ptr = mysql_fetch_lengths(resultStruct);
      
      for ( int j = 0; j < num_fields; j++ ) {
         int leng;
         memcpy(leng, len_ptr + j*sizeof(int), sizeof(int));
         
         ArrayResize(byte,leng+1);
         ArrayInitialize(byte,0);
         
         int row_ptr_pos;
         memcpy(row_ptr_pos, row_ptr + j*sizeof(int), sizeof(int));
         memcpy(byte, row_ptr_pos, leng);
         
         string s = CharArrayToString(byte);
         data[i][j] = s;
         
         LocalFree(leng);
         LocalFree(row_ptr_pos);
      }
    }
    
    mysql_free_result(resultStruct);
    
    if ( MySQL_NoError(dbConnectId) ) {
        return (1);
    }    
    return (-1);
}
 
//+----------------------------------------------------------------------------+
//| Lovely function that helps us to get ANSI strings from DLLs to our UNICODE |
//| format                                                                     |
//| http://forum.mql4.com/60708                                                |
//+----------------------------------------------------------------------------+
string mql4_mysql_ansi2unicode(int ptrStringMemory)
{
  int szString = lstrlenA(ptrStringMemory);
  uchar ucValue[];
  ArrayResize(ucValue, szString + 1);
  RtlMoveMemory(ucValue, ptrStringMemory, szString + 1);
  string str = CharArrayToString(ucValue);
  LocalFree(ptrStringMemory);
  return str;
}
//+----------------------------------------------------------------------------+