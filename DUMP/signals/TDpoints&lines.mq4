//+------------------------------------------------------------------+
//|                                  TD_Points&Lines_mgtd1.mq4 Short |
//|                                           Vladislav Goshkov (VG) |
//|                                                      4vg@mail.ru |
//|???????? - ??? ?? ???? ????????? ???????
//+------------------------------------------------------------------+
#property copyright "Vladislav Goshkov (VG)"
#property link      "4vg@mail.ru"

#property indicator_chart_window

extern int   StepBack=0;
extern color UpLineColor = Blue;
extern int   UpLnWidth = 1;
extern color DnLineColor = Red;
extern int   DnLnWidth = 1;
extern color MarkColor   = Blue;
extern int   MarkNumber  = 217;

int i=1,NP=0,D=0,
    iB_Up=0,iB_Dn=0,
    S1=0,
    S2=0,
    UpLev=0,
    DownLev=0,
    iP_Up=0,
    iP_Dn=0,
    value=0,
    CurPeriod=0,
    shift=0;

datetime  nTime=0;

double UpV=0,
       DownV=0,
       iP=0,
       target = 0,
       UpP[2]={0,0},
       DownP[2]={0,0},
       PP1=0,PP2=0,PP3=0;

int    DownBT[2]={0,0}, // Bar Time
       UpBT[2]={0,0},
       UpB[2]={0,0},    // Bar Num
       DownB[2]={0,0};
string buff_str = "";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
Comment(" ");   
ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
int Target_Style[4] = {STYLE_DASH,STYLE_DASH,STYLE_DASH,STYLE_SOLID},
    Target_Up_Color[4] = {DimGray,MediumSpringGreen,SeaGreen,Blue},
    Target_Dn_Color[4] = {Magenta,Orange,Yellow,Red},
    Target_LW[4]    = { 1, 1, 1, 2 };
double target_up[4],target_dn[4];
//---- TODO: add your code here
if ( (nTime!=Time[0]) || (CurPeriod!=Period()) ) {
   UpP[0] = 0;
   UpP[1] = 0;

//=================================================
//******** ????? ??????? ????? ??????????? ********
//=================================================
   for(i=2+StepBack,D=2,NP=0; (NP<D)&&(i<Bars); i++) {//Begin
       if (High[i]!= High[i+1]) { 
          if( (High[i]>High[i+1] && High[i]>High[i-1] && High[i]>Close[i+2] ) 
              && High[i]> UpP[0] ) {
      UpB[NP]  = i;
    UpBT[NP] = Time[i];
    UpP[NP]  = High[i];
    NP++;
    }
  }

    if (High[i]== High[i+1])  { 
       if ( (High[i]>High[i+2] && High[i]>High[i-1] && High[i]>Close[i+3] ) && High[i]> UpP[0] ) {
      UpB[NP]  = i;
    UpBT[NP] = Time[i];
    UpP[NP]  = High[i];
    NP++;
    }
  }
     if(i == (Bars-2) ) {
      UpB[NP]  = i;
    UpBT[NP] = Time[i];
    UpP[NP]  = High[i];
    break;
    }
     }//for(i=2+StepBack,D=2,NP=0; NP<D; ) {//End;

//=================================================
//********** ????? ??????? ????? ?????? ***********
//=================================================
   DownP[0] = 1000000000;
   DownP[1] = 1000000000;
   for(i=2+StepBack,D=2,NP=0; (NP<D)&&(i<Bars); i++) {//Begin
    if (Low[i]!= Low[i+1])  { 
       if ( (Low[i]<Low[i+1] && Low[i]<Low[i-1] && Low[i]<Close[i+2] ) && Low[i]< DownP[0] ){
      DownB[NP] = i;
    DownBT[NP]= Time[i];
    DownP[NP] = Low[i];
    NP++;
    }
  //i++;
  }
    if (Low[i]== Low[i+1])  { 
       if ( (Low[i]<Low[i+2] && Low[i]<Low[i-1] && Low[i]<Close[i+3] ) && Low[i]< DownP[0] ){
      DownB[NP] = i;
    DownBT[NP]= Time[i];
    DownP[NP] = Low[i];
    NP++;
    }
  //i++;
  }
     if (i == (Bars-2) ) { 
      DownB[NP] = i;
    DownBT[NP]= Time[i];
    DownP[NP] = Low[i];
    break;
    }
     }//End;
     

UpV   = (UpP[1]-UpP[0])/(UpB[0]-UpB[1]);
DownV = (DownP[1]-DownP[0])/(DownB[0]-DownB[1]);

//=================================================
//****       ??????  TD-?????                  ****
//=================================================
   buff_str = "TD_Up";
   if(ObjectFind(buff_str) == -1) {
      ObjectCreate(buff_str, OBJ_TREND, 0, UpBT[1], UpP[1],UpBT[0], UpP[0]);
      ObjectSet(buff_str, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(buff_str, OBJPROP_COLOR, UpLineColor);
      ObjectSet(buff_str, OBJPROP_WIDTH, UpLnWidth);
      }
   else {
      ObjectDelete(buff_str);
      ObjectCreate(buff_str, OBJ_TREND, 0, UpBT[1], UpP[1],UpBT[0], UpP[0]);
      ObjectSet(buff_str, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(buff_str, OBJPROP_COLOR, UpLineColor);
      ObjectSet(buff_str, OBJPROP_WIDTH, UpLnWidth);
      }

   buff_str = "TD_Dn";
   if(ObjectFind(buff_str) == -1) {
      ObjectCreate(buff_str, OBJ_TREND, 0, DownBT[1], DownP[1],DownBT[0], DownP[0]);
      ObjectSet(buff_str, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(buff_str, OBJPROP_COLOR, DnLineColor);
      ObjectSet(buff_str, OBJPROP_WIDTH, DnLnWidth);
      }
   else {
      ObjectDelete(buff_str);
      ObjectCreate(buff_str, OBJ_TREND, 0, DownBT[1], DownP[1],DownBT[0], DownP[0]);
      ObjectSet(buff_str, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(buff_str, OBJPROP_COLOR, DnLineColor);
      ObjectSet(buff_str, OBJPROP_WIDTH, DnLnWidth);
      }

   CurPeriod = Period();
   nTime = Time[0];
   }//if (nTime <> Time[0]) {
//----
   for(i=0;i<4;i++) {
       target_up[i] = 0;
       target_dn[i] = 0;
       }
for( i=UpB[0]; i>=StepBack; i--){
    iB_Up=i; 
    iP=UpP[0]+UpV*(UpB[0]-i);
    iP_Up = iP; 
    S1=Lowest(NULL,0,MODE_LOW,UpB[1]-i,i);
    S2=Lowest(NULL,0,MODE_CLOSE,UpB[1]-i,i);

       PP1=iP+((UpP[1]+UpV*(UpB[1]-S1))-Low[S1]);
       PP2=iP+((UpP[1]+UpV*(UpB[1]-S2))-Low[S2]);
          PP3=iP+((UpP[1]+UpV*(UpB[1]-S1))-Close[S1]);
          target_up[0] = PP1;
          target_up[1] = PP2;
          target_up[2] = PP3;
          target_up[3] = (PP1+PP2+PP3)/3;
   }

   for( i=DownB[0]; i>=StepBack;i--) {
       iB_Dn=i; 
    iP=DownP[0]+DownV*(DownB[0]-i);
    iP_Dn = iP;
    S1=Highest(NULL,0,MODE_HIGH,DownB[1]-i,i);
    S2=Highest(NULL,0,MODE_CLOSE,DownB[1]-i,i);

          PP1=iP-(High[S1]-(DownP[1]+DownV*(DownB[1]-S1)));
       PP2=iP-(High[S2]-(DownP[1]+DownV*(DownB[1]-S2)));
       PP3=iP-(Close[S1]-(DownP[1]+DownV*(DownB[1]-S1)));
             target_dn[0] = PP1;
             target_dn[1] = PP2;
             target_dn[2] = PP3;
             target_dn[3] = (PP1+PP2+PP3)/3;
}//for( i=DownB[1]; i>=StepBack;i--) {

   for(i=3;i>=0;i--) {
      buff_str = "Target_up"+i;
      if(ObjectFind(buff_str) == -1) {
         ObjectCreate(buff_str, OBJ_HLINE,0, Time[0], target_up[i] );
         ObjectSet(buff_str, OBJPROP_STYLE, Target_Style[i]);
         ObjectSet(buff_str, OBJPROP_COLOR, Target_Up_Color[i]);
         ObjectSet(buff_str, OBJPROP_WIDTH, Target_LW[i]);
         }
      else {
         ObjectMove(buff_str, 0, Time[0], target_up[i] );
         }
      }

   for(i=3;i>=0;i--) {
      buff_str = "Target_dn"+i;
      if(ObjectFind(buff_str) == -1) {
         ObjectCreate(buff_str, OBJ_HLINE,0, Time[0], target_dn[i] );
         ObjectSet(buff_str, OBJPROP_STYLE, Target_Style[i]);
         ObjectSet(buff_str, OBJPROP_COLOR, Target_Dn_Color[i]);
         ObjectSet(buff_str, OBJPROP_WIDTH, Target_LW[i]);
         }
      else {
         ObjectMove(buff_str, 0, Time[0], target_dn[i] );
         }
      }


//----
string buff_str = "TD_LatestCulcBar";
   if(ObjectFind(buff_str) == -1) {
      ObjectCreate(buff_str, OBJ_ARROW,0, Time[StepBack], Low[StepBack]-2*Point );
      ObjectSet(buff_str, OBJPROP_ARROWCODE, MarkNumber);
      ObjectSet(buff_str, OBJPROP_COLOR, MarkColor);
      }
   else {
      ObjectMove(buff_str, 0, Time[StepBack], Low[StepBack]-2*Point );
      }
   return(0);
  }
//+------------------------------------------------------------------+