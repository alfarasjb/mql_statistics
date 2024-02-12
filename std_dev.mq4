
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Rolling Standard Deviation"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#include <MovingAverages.mqh>
input    int      InpWindow   = 10; 
input    int      InpShift    = 0;
double      SDevBuffer[], MeanBuffer[], CloseBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(indicator_buffers);
   IndicatorDigits(Digits);
   SetIndexBuffer(0,SDevBuffer, INDICATOR_DATA);
   SetIndexLabel(0, "Standard Deviation");
   SetIndexStyle(0, indicator_type1);
   SetIndexShift(0, InpShift);
   SetIndexDrawBegin(0, InpWindow + InpShift);
   
   SetIndexBuffer(1, MeanBuffer, INDICATOR_DATA);
   //SetIndexLabel(1, "Mean");
   //SetIndexShift(1, InpShift);
   SetIndexDrawBegin(1, InpWindow - 1);
   
   /*
   SetIndexBuffer(2, CloseBuffer, INDICATOR_DATA);
   SetIndexLabel(2, "Close");
   SetIndexShift(2, InpShift);
   SetIndexDrawBegin(2, InpWindow - 1);
   */
   //SetIndexBuffer(1,MeanBuffer);
   //SetIndexLabel(1, "MA");
   //SetIndexStyle(1, indicator_type1);
   //SetIndexShift(1, InpShift);
   //SetIndexDrawBegin(0, InpWindow - 1);
   IndicatorShortName("Std Dev");
   
   ArraySetAsSeries(MeanBuffer,false);
   ArraySetAsSeries(SDevBuffer,false);
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
   
   
   
   int pos = prev_calculated > 1 ? prev_calculated - 1 : 0;
      
   //PrintFormat("Rates Total: %i, Prev Calculated: %i", rates_total, prev_calculated);
   //PrintFormat("Open: %f, High: %f, Low: %f, Close: %f", open[0], high[0], low[0], close[0]);
   //PrintFormat("MA: %f", ExtMovingBuffer[InpWindow]);
   for(int i=pos; i<rates_total && !IsStopped(); i++){
      
      //CloseBuffer[i] = close[i];
      //MeanBuffer[i]=SimpleMA(i,InpWindow,close);
      SDevBuffer[i] = CalculateStandardDeviation(i, close);
      
      
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double      CalculateStandardDeviation(int position, const double &close[]) {

   double sum = 0;
   double mean = SimpleMA(position, InpWindow, close);
   if (position >= InpWindow) {
      for (int i = 0; i < InpWindow; i++) {
         double close_price = close[position-i];
         double diff = MathPow(close_price - mean, 2);
         sum += diff;
      }
   }
   
   double sdev = MathSqrt(sum / InpWindow); 
   return sdev;   
}
