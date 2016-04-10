//+------------------------------------------------------------------+
//|                                                       regexp.mqh |
//|             Copyright 2013, Tim Jackson <webmechanicr@gmail.com> |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Tim Jackson <webmechanicr@gmail.com>"
#property link      ""
#property strict

/*
 * The library defines functions for regular expressions in MQL.
 * It requires Poco Library .dll file.
 */

bool preg_match(string pattern, string str, string& pockets[], int start_position = 0){
   if(start_position < 0)
      start_position = 0;
   bool result = false;
   
   if(pattern == "" || str == "")
      return result;
   if(start_position >= StringLen(str))
      return result;
   
   int start_packets_pos[1000];
   int packets_lengths[1000];
   int size = mql4_preg_match(pattern, str, start_packets_pos, packets_lengths, start_position);
   if(size != 0){
      result = true;
      ArrayResize(pockets, size);
      for(int i = 0; i < size; i++){
         pockets[i] = StringSubstr(str, start_packets_pos[i], packets_lengths[i]);
      }
   }
   
   return result;
};

bool preg_match_offset(string pattern, string str, string& pockets[], int& st_positions[], int& pack_lengths[], int start_position = 0){
   if(start_position < 0)
      start_position = 0;
   bool result = false;
   if(pattern == "" || str == "")
      return result;
   if(start_position >= StringLen(str))
      return result;
   
   
   int start_packets_pos[1000];
   int packets_lengths[1000];
   
   int size = mql4_preg_match(pattern, str, start_packets_pos, packets_lengths, start_position);
   if(size != 0){
      result = true;
      ArrayResize(pockets, size);
      ArrayResize(st_positions, size);
      ArrayResize(pack_lengths, size);
      for(int i = 0; i < size; i++){
         st_positions[i] = start_packets_pos[i];
         pack_lengths[i] = packets_lengths[i];
         pockets[i] = StringSubstr(str, start_packets_pos[i], packets_lengths[i]);
      }
   }
   
   return result;
};

bool preg_match_split(string pattern, string str, string& out[]){
   bool res = false;
   if(pattern == "" || str == "")
      return res;
      
   string pockets[];
   int st_positions[];
   int pack_lengths[];
   int startPos = 0;
   int matches = 0;
   string result[];
   while(preg_match_offset(pattern, str, pockets, st_positions, pack_lengths, startPos)){
         ArrayResize(result, matches + 1);
         res = true;
         int len = st_positions[0] - startPos;
         if(len != 0)
            result[matches] = StringSubstr(str, startPos, len);
         else
            result[matches] = "";  
         startPos = st_positions[0] + pack_lengths[0];
         matches++; 
   };
   
   if(str != ""){
      if(!res){
         res = true;
      }
      //takes last element
      ArrayResize(result, matches + 1);
      result[matches] = StringSubstr(str, startPos);
   }
   
   ArrayResize(out, ArraySize(result));
   ArrayCopy(out, result);
  
   return res;
}