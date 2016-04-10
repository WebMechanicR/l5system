//+------------------------------------------------------------------+
//|                                   ICWR                           |
//|                                   Copyright © 2005, John Lotoski |
//|                                   mailto:john@fayandjohn.com     |
//|                                                                  |
//|                         ICWR-0.1 beta5                           |
//|                         update code Alex.Piech.FinGeR 23.01.2006 |
//|                         mailto:regnif@gmx.net                    |  
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkGray
#property indicator_color2 Red

//---- indicator parameters
extern string Parameters_1= "ZigZag";
extern int ExtDepth=10;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
extern string Parameters_2 = "ActiveWave";
extern int calc.NumBars=100;
extern int RequiredWaveHeight=40;

//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
string buff_str;
string buff_str2;
string buff_str3;
string buff_str4;
string buff_str5;
string buff_str6;
string buff_str7;
string buff_str8;

color  MarkColor   = Blue;
int    MarkNumber  = 158;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(3);
 
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexStyle(1,DRAW_LINE);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(2,ExtMapBuffer2);
   SetIndexBuffer(1,ExtMapBuffer3);
    //SetIndexStyle(1,DRAW_NONE);
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
   
//---- indicator short name
   IndicatorShortName("ICWR("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");

//---- initialization done
   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()                           // Removes all lines and text
{                                      // from the chart upon removal
                                       // of the indicator
for(int i=0;i<=Bars;i++) {
    buff_str = "ActiveWave"+i;
    ObjectDelete(buff_str);
   }

for(int ii=0;ii<=Bars;ii++) {
    buff_str2 = "Fibo"+ii;
    ObjectDelete(buff_str2);
   }
   
for(int iii=0;iii<=Bars;iii++) {
    buff_str4 = "text"+iii;
  
    ObjectDelete(buff_str4);
   }   
   
for(int iiii=0;iiii<=Bars;iiii++) {
    buff_str5 = "V"+iiii;
  
    ObjectDelete(buff_str5);
   }   
   
for(int iiiii=0;iiiii<=Bars;iiiii++) {
    buff_str6 = "rc"+iiiii;
  
    ObjectDelete(buff_str6);
   }      
   
for(int iiiiii=0;iiiiii<=Bars;iiiiii++) {
    buff_str7 = "b"+iiiiii;
  
    ObjectDelete(buff_str7);
   }    

for(int iiiiiii=0;iiiiiii<=Bars;iiiiiii++) {
    buff_str8 = "bb"+iiiiiii;
  
    ObjectDelete(buff_str8);
   }    
      
 for( int ia=0; ia<=6; ia++ ){
  for(int iiiiiiii=0;iiiiiiii<=Bars;iiiiiiii++) {
    buff_str3 = "mml"+ia+iiiiiiii;
  
    ObjectDelete(buff_str3);
   }   

}

             
              
              
              



Comment(" ");   
 
 
 
 
 
 //ObjectDelete(buff_str2);
   return(0);
}

//+------------------------------------------------------------------+
//| Main function                                                    |
//+------------------------------------------------------------------+
int start()
{



 for(int i=0;i<=Bars;i++) {
    buff_str = "ActiveWave"+i;
    ObjectDelete(buff_str);
   }

for(int ii=0;ii<=Bars;ii++) {
    buff_str2 = "Fibo"+ii;
    ObjectDelete(buff_str2);
   }
   
for(int iii=0;iii<=Bars;iii++) {
    buff_str4 = "text"+iii;
  
    ObjectDelete(buff_str4);
   }   
   
for(int iiii=0;iiii<=Bars;iiii++) {
    buff_str5 = "V"+iiii;
  
    ObjectDelete(buff_str5);
   }   
   
for(int iiiii=0;iiiii<=Bars;iiiii++) {
    buff_str6 = "rc"+iiiii;
  
    ObjectDelete(buff_str6);
   }      
   
for(int iiiiii=0;iiiiii<=Bars;iiiiii++) {
    buff_str7 = "b"+iiiiii;
  
    ObjectDelete(buff_str7);
   }    

for(int iiiiiii=0;iiiiiii<=Bars;iiiiiii++) {
    buff_str8 = "bb"+iiiiiii;
  
    ObjectDelete(buff_str8);
   }    
      
 for( int ia=0; ia<=6; ia++ ){
  for(int iiiiiiii=0;iiiiiiii<=Bars;iiiiiiii++) {
    buff_str3 = "mml"+ia+iiiiiiii;
  
    ObjectDelete(buff_str3);
   }   

}
     
     
   int    shift,shift2,back,lasthighpos,lastlowpos,LastActivePos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow,LastActive;
   
   int AWStartPos, AWEndPos;
   double AWStart, AWEnd;
   
   double FiboL, FiboH, FiboLC, FiboLR, FiboHR, FiboHC;







   for(shift=Bars-ExtDepth; shift>=0; shift--)
   
   {
    double nsb=iBarShift(NULL, PERIOD_D1, Time[shift]);
     double RSI=iRSI(NULL,PERIOD_D1,14,PRICE_CLOSE,nsb);
    ExtMapBuffer3[shift]=iMA(NULL,0,1,0,MODE_SMMA,PRICE_CLOSE,shift);  
     
     
                                       // The beginning code of this for loop is dedicated
                                       // to finding a low endpoint of a zig-zag
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
                                       // Start at beginning of data
                                       // - Get low of last depth (12) periods
                                       // - Repeat low search of 12 periods,
                                       //   advancing 1 bar every search (for loop)
      
      if(val==lastlow)                 // If this is not a new low
         val=0.0;                      // - Reset the val marker to dbl 0
      
      else                             // Otherwise, if it is a new low
      { 
         lastlow=val;                  // - Record this new low in lastlow for future reference
         if((Low[shift]-val)>(ExtDeviation*Point)) 
            val=0.0;                   // If the low of the current bar is 6 or
                                       // more pips greater than the lowest low of the last
                                       // depth (12) periods, then reset val to dbl 0.
                                       // Ie: continue the zig because the line is going up
         
         else                          // Otherwise, if the current low is within 6 pips
         {                             // of the lowest low of the last 12 bars
            for(back=1; back<=ExtBackstep; back++)
            {                          // Check back 3 bars, and if each value over those
                                       // three bars is greater than the current lowest low,
                                       // then reset the map buffer value to 0 because
                                       // we have a new lower low.
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) 
                  ExtMapBuffer[shift+back]=0.0; 
            }
         }
      } 

      ExtMapBuffer[shift]=val;         // Set our current bar to 0 (continuation of zig) if:
                                       //    - A new low has not been reached;
                                       //    - The current bar is 6 pips beyond the lowest low
                                       // Set our current bar to the lowest low if:
                                       //    - It is within 6 pips of the lowest low and
                                       //      and go back over the last three bars and set them
                                       //      to continuation of zig as well if they are greater
                                       //      than the new lowest value
      
      
                                       // Same deal for below, except the case is reversed
                                       // and everything is done in terms of trying to find
                                       // the high zig-zag endpoint
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];

      if(val==lasthigh) 
         val=0.0;
      else 
      {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) 
            val=0.0;
         else
         {
            for(back=1; back<=ExtBackstep; back++)
            {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) 
                  ExtMapBuffer2[shift+back]=0.0; 
            } 
         }
      }
      ExtMapBuffer2[shift]=val;
   }

   // final cutting 
   lasthigh=-1; 
   lasthighpos=-1;
   lastlow=-1;  
   lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
   {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      
      if((curlow==0)&&(curhigh==0))    // Break into the next cycle of the loop
         continue;                     // to try and find the next zig-zap endpoint
      
      if(curhigh!=0)                   // If there is a current high, then:
      {
         if(lasthigh>0)                   // If there was a previous high already:
         {
            if(lasthigh<curhigh)          //    - Set the last high to 0 if it is less than the current high
               ExtMapBuffer2[lasthighpos]=0;
            else                          //    - Set the current bar to 0 if it is less than the last high
               ExtMapBuffer2[shift]=0;
         }
         
         if(lasthigh<curhigh || lasthigh<0)
         {                             // If there was no last high or the last high was less than the current high
            lasthigh=curhigh;          //    - Set the current high to be the last high (keep record of it)
            lasthighpos=shift;         //    - Set the current bar to the lasthighpos (keep record of it)
         }
         lastlow=-1;                   // Since we just had a new high, reset the lastlow flag
      }

      if(curlow!=0)                    // If there is a low, then do the same as above, except for the case of lows instead of highs
      {
         if(lastlow>0)
         {
            if(lastlow>curlow) 
               ExtMapBuffer[lastlowpos]=0;
            else 
               ExtMapBuffer[shift]=0;
         }

         if((curlow<lastlow)||(lastlow<0))
         {
            lastlow=curlow;
            lastlowpos=shift;
         } 
         lasthigh=-1;
      }
   }
  
   for(shift=Bars-1; shift>=0; shift--)
   {                                   // Go through all the bars
      if(shift>=Bars-ExtDepth)         // If we are not at the beginning comparison bars,
         ExtMapBuffer[shift]=0.0;      //    then set the low buffer to 0
      else
      {                                // Otherwise:
         res=ExtMapBuffer2[shift];     //    - If the current bar has a high, set the low
         if(res!=0.0)                  //      buffer to contain the high
            ExtMapBuffer[shift]=res;
      }                                // Looks like this function brings the highs into the lows
                                     // so that all the zig-zags can be drawn from one function
}


////////////////////////////////////////////////////////////////////////////////////////////////7
 
   for(int shifta=0; shifta<=calc.NumBars; shifta++)
   {
LastActive = -1;
   LastActivePos = -1;
   for(shift=shifta; shift<=Bars-ExtDepth; shift++)
   {
    
    
      if(ExtMapBuffer[shift]!=0.0)
      {
         if(LastActive > 0)
         {
            if(MathAbs(LastActive - ExtMapBuffer[shift]) >= RequiredWaveHeight*Point)
            {
               AWStartPos = shift;
               AWStart = ExtMapBuffer[shift];
               AWEndPos = LastActivePos;
               AWEnd = LastActive;
               buff_str = "ActiveWave"+shift;
               buff_str2 = "Fibo"+shift;
               buff_str4 = "text"+shift;
               buff_str5 = "V"+shift;
               buff_str6 = "rc"+shift;
               buff_str7 = "b"+shift;
               buff_str8 = "bb"+shift;
               //if(ObjectFind("ActiveWave") != 0)
              // {
              
              
            
              
                 ObjectCreate(buff_str, OBJ_TREND, 0, Time[AWStartPos], AWStart, Time[AWEndPos], AWEnd);
                  ObjectSet(buff_str, OBJPROP_STYLE, STYLE_SOLID);
                             
                  ObjectSet(buff_str, OBJPROP_WIDTH, 3);
                  ObjectSet(buff_str, OBJPROP_RAY, false);  
              // }
             //  else
               //{
                 // ObjectCreate("ActiveWave", OBJ_TREND, 0, Time[AWStartPos], AWStart, Time[AWEndPos], AWEnd);
                 // ObjectSet("ActiveWave", OBJPROP_STYLE, STYLE_SOLID);
                //  ObjectSet("ActiveWave", OBJPROP_COLOR, Red);               
                //  ObjectSet("ActiveWave", OBJPROP_WIDTH, 3);
               //   ObjectSet("ActiveWave", OBJPROP_RAY, false);  
             //  }
            
               if(AWStart < AWEnd)
               {
                  FiboL = AWStart;
                  FiboH = AWEnd;
                   ObjectSet(buff_str, OBJPROP_COLOR,  Blue);    
          
           //ObjectCreate(buff_str2, OBJ_FIBO, 0, Time[AWEndPos], AWStart, Time[AWEndPos], AWEnd);
                                       
           ObjectCreate(buff_str5, OBJ_TREND, 0, Time[AWEndPos], AWStart, Time[AWEndPos], AWEnd);
           ObjectSet(buff_str5, OBJPROP_STYLE, STYLE_SOLID);
           ObjectSet(buff_str5, OBJPROP_COLOR, Blue);                  
           ObjectSet(buff_str5, OBJPROP_WIDTH, 2);
           ObjectSet(buff_str5, OBJPROP_RAY, false); 
           ObjectSet(buff_str5, OBJPROP_BACK,true);
              
               }
               else
               {
                  ObjectSet(buff_str, OBJPROP_COLOR,Red); 
                  FiboL = AWEnd;
                  FiboH = AWStart;
              //  ObjectCreate(buff_str2, OBJ_FIBO, 0, Time[AWEndPos], AWStart, Time[AWEndPos], AWEnd);
           ObjectCreate(buff_str5, OBJ_TREND, 0, Time[AWEndPos], AWStart, Time[AWEndPos], AWEnd);
           ObjectSet(buff_str5, OBJPROP_STYLE, STYLE_SOLID);
           ObjectSet(buff_str5, OBJPROP_COLOR, Red);                  
           ObjectSet(buff_str5, OBJPROP_WIDTH, 2);
           ObjectSet(buff_str5, OBJPROP_RAY, false);
           ObjectSet(buff_str5, OBJPROP_BACK,true);  
             
               }
               
          
               FiboLC = FiboL + (FiboH - FiboL)*0.25;
               FiboLR = FiboL + (FiboH - FiboL)*0.382;
               FiboHR = FiboL + (FiboH - FiboL)*0.618;
               FiboHC = FiboL + (FiboH - FiboL)*0.75;
            
               if(1==1)
               {
                  
                  ObjectSet(buff_str2, OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(buff_str2, OBJPROP_COLOR, Green);               
                  ObjectSet(buff_str2, OBJPROP_WIDTH, 1);
                  ObjectSet(buff_str2, OBJPROP_FIBOLEVELS, 6);
                  ObjectSet(buff_str2, OBJPROP_RAY, false);
                /*  
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+0, 0);ObjectSetFiboDescription(buff_str2, "0.0", 0); 
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+1, 0.25);ObjectSetFiboDescription(buff_str2, "25.0", 1);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+2, 0.382);ObjectSetFiboDescription(buff_str2, "38.2", 2);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+3, 0.618);ObjectSetFiboDescription(buff_str2, "61.8", 3);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+4, 0.75);ObjectSetFiboDescription(buff_str2, "75.0", 4);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+5, 1);ObjectSetFiboDescription(buff_str2, "100.0", 5);
                 */
                  
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+0, 0);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+1, 0.25);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+2, 0.382);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+3, 0.618);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+4, 0.75);
                  ObjectSet(buff_str2, OBJPROP_FIRSTLEVEL+5, 1);
               
               
               //
  
   
    
   if (RSI == 50.0)
   Comment("\n","ICWR: Daily RSI is Flat ",RSI);
   else if (RSI > 50.0)
   Comment("\n","ICWR: Daily RSI is Long ",RSI);
   else if (RSI < 50.0)
   Comment("ICWR: Daily RSI is Short ",RSI);
       if(RSI == 50.0)  
       {
        ObjectCreate(buff_str4, OBJ_TEXT, 0, Time[shifta+5], AWEnd+3*Point);
        ObjectSetText(buff_str4,"Daily RSI is Flat ", 8, "Arial", Gray);
       }
     
              if(RSI > 50)    
       {
        ObjectCreate(buff_str4, OBJ_TEXT, 0, Time[shifta+5], AWEnd+3*Point);
        ObjectSetText(buff_str4,"Daily RSI is Long ", 8, "Arial", LimeGreen);
       }
          if(RSI < 50)  
          {
           ObjectCreate(buff_str4, OBJ_TEXT, 0, Time[shifta+5], AWEnd+3*Point);
        ObjectSetText(buff_str4, "Daily RSI is Short ", 8, "Arial", Red);
          }
          
          
               
   for( int yi=0; yi<=6; yi++ ){
        buff_str3 = "mml"+yi+shift;
     
    if  (yi==1)      {
   
   ObjectCreate(buff_str3, OBJ_TREND, 0, Time[AWEndPos],  FiboLC, Time[shifta]+100*Period(), FiboLC);
   //ObjectMove(buff_str3, 0, Time[AWEndPos],  FiboLC ); 
   
   //ObjectMove(buff_str3, 0, Time[shifta]+100*Period(),  FiboLC );               
   }
    if  (yi==2)          
   ObjectCreate(buff_str3, OBJ_TREND, 0, Time[AWEndPos],  FiboLR, Time[shifta]+100*Period(),  FiboLR);      
   
    if  (yi==3)          
    ObjectCreate(buff_str3, OBJ_TREND, 0, Time[AWEndPos],  FiboHR, Time[shifta]+100*Period(),  FiboHR);      
            
                          
     if  (yi==4)          
      ObjectCreate(buff_str3, OBJ_TREND, 0, Time[AWEndPos],  FiboHC, Time[shifta]+100*Period(),  FiboHC);      
            
      if  (yi==5)          
      ObjectCreate(buff_str3, OBJ_TREND, 0, Time[AWEndPos],  AWStart, Time[shifta]+100*Period(),  AWStart);      
       
       if  (yi==6)          
      ObjectCreate(buff_str3, OBJ_TREND, 0, Time[AWEndPos],  AWEnd, Time[shifta]+100*Period(),  AWEnd);      
                               
                 
                 
                 
             ObjectSet(buff_str3, OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet(buff_str3, OBJPROP_COLOR, Gold);               
                  ObjectSet(buff_str3, OBJPROP_WIDTH, 1);
                  ObjectSet(buff_str3, OBJPROP_RAY, false);  
    
   
        
         ObjectCreate(buff_str6,OBJ_RECTANGLE, 0, Time[AWEndPos], FiboLR, Time[shifta]+100*Period(), FiboHR);
         ObjectSet(buff_str6, OBJPROP_COLOR, Gray);
             
         ObjectCreate(buff_str7,OBJ_RECTANGLE, 0, Time[AWEndPos], FiboLC, Time[shifta]+100*Period(), FiboL);
         ObjectSet(buff_str7, OBJPROP_COLOR, IndianRed);
                  
         ObjectCreate(buff_str8,OBJ_RECTANGLE, 0, Time[AWEndPos], FiboHC, Time[shifta]+100*Period(), FiboH);
         ObjectSet(buff_str8, OBJPROP_COLOR, Green);
            
          
            
             }  
                  
 
               
               }
               else
               {
                 
               }
               break;
            }
         }
         LastActive = ExtMapBuffer[shift];
         LastActivePos = shift;
      }
   }
}
}



