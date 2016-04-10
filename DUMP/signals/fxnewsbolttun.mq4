#property indicator_chart_window

extern int StepBack=0;
extern bool Qw1=True;
extern bool Qw2=True;
extern bool Qw3=True;
extern color UpLineColor = Blue;
extern int UpLnWidth = 1;
extern color DnLineColor = Red;
extern int DnLnWidth = 1;
extern color MarkColor = Blue;
extern int MarkNumber = 217;

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

datetime nTime=0;

double UpV=0,
DownV=0,
iP=0,
target = 0,
UpP[2]={0,0},
DownP[2]={0,0},
PP1=0,PP2=0,PP3=0;

int DownBT[2]={0,0}, // Bar Time
UpBT[2]={0,0},
UpB[2]={0,0}, // Bar Num
DownB[2]={0,0};
string buff_str = "";
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function |
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
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
int Target_Style[4] = {STYLE_DASH,STYLE_DASH,STYLE_DASH,STYLE_SOLID},
Target_LW[4] = { 1, 1, 1, 2 },
i=0,ic=0;
color Target_Color[4] = {DimGray,MediumSpringGreen,SeaGreen,Blue},
Target_Up_Color[4] = {DimGray,MediumSpringGreen,SeaGreen,Blue},
Target_Dn_Color[4] = {Magenta,Orange,Yellow,Red};
double target[4];
//---- TODO: add your code here
if ( (nTime!=Time[0]) || (CurPeriod!=Period()) ) {
UpP[0] = 0;
UpP[1] = 0;
}
//=================================================
//******** Поиск опорных точек предложения ********
//=================================================
for(i=2+StepBack,D=2,NP=0; (NP<D)&&(i<Bars); i++) {//Begin
if (High[i]!= High[i+1]) { 
if( (High[i]>High[i+1] && High[i]>High[i-1] && High[i]>Close[i+2] ) 
&& High[i]> UpP[0] ) {
UpB[NP] = i;
UpBT[NP] = Time[i];
UpP[NP] = High[i];
NP++;
}
}

if (High[i]== High[i+1]) { 
if ( (High[i]>High[i+2] && High[i]>High[i-1] && High[i]>Close[i+3] ) && High[i]> UpP[0] ) {
UpB[NP] = i;
UpBT[NP] = Time[i];
UpP[NP] = High[i];
NP++;
}
}
if(i == (Bars-2) ) {
UpB[NP] = i;
UpBT[NP] = Time[i];
UpP[NP] = High[i];
break;
}
}//for(i=2+StepBack,D=2,NP=0; NP<D; ) {//End;

//=================================================
//********** Поиск опорных точек спроса ***********
//=================================================
DownP[0] = 1000000000;
DownP[1] = 1000000000;
for(i=2+StepBack,D=2,NP=0; (NP<D)&&(i<Bars); i++) {//Begin
if (Low[i]!= Low[i+1]) { 
if ( (Low[i]<Low[i+1] && Low[i]<Low[i-1] && Low[i]<Close[i+2] ) && Low[i]< DownP[0] ){
DownB[NP] = i;
DownBT[NP]= Time[i];
DownP[NP] = Low[i];
NP++;
}
//i++;
}
if (Low[i]== Low[i+1]) { 
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
}
}