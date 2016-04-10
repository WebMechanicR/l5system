//+------------------------------------------------------------------+
//|                                                    SnapShotI.mq4 |
//|                                    Copyright © 2006, MichalRutka |
//|                                        http://www.mqlservice.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MichalRutka"
#property link      "http://www.mqlservice.com"

#property indicator_chart_window

int start(){
   static datetime last_bar;
   if(Time[0] != last_bar){
     last_bar = Time[0];
     MakeScreenShot();
   }
   return(0);
}

string al0(int number, int digits){
  // add leading zeros that the resulting string has 'digits' length.
  string result;
  result = DoubleToStr(number, 0);
  while(StringLen(result)<digits) result = "0"+result;
  return(result);
}

void MakeScreenShot(){
  static int no=0;
  no++;
  string fn = "SnapShot"+Symbol()+Period()+"\\"+Year()+"-"+al0(Month(),2)+"-"+al0(Day(),2)+" "+
              al0(Hour(),2)+"_"+al0(Minute(),2)+"_"+al0(Seconds(),2)+" "+no+".gif";
  if(!ScreenShot(fn,640,480)) Print("ScreenShot error: ", GetLastError());
}
//+----Coded by Michal Rutka-----------------------------------------+