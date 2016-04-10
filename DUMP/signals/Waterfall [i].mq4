
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

double BufferBuy[];

int init()
{
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,BufferBuy);
   SetIndexArrow(0,181);
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(BufferBuy,true);

   return(0);
}

int deinit()                           
{                                      
   return(0);
}

int start()
{
   int i,TotalBars, CountedBars;
   double LastBarsRange,Bottom20;
   
   CountedBars=IndicatorCounted();     
      
   TotalBars=Bars-CountedBars;

   for(i=TotalBars-1;i>=0;i--)
   {  
      LastBarsRange=(High[i+1]-Low[i+1]);
      Bottom20=Low[i+1]+(LastBarsRange*0.20);


         if(Highest(Symbol(),0,MODE_HIGH,50,1)==1)
            BufferBuy[i]=High[i];
 


}
}