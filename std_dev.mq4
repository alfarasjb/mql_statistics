
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
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
double      ExtStdDevBuffer[], ExtMovingBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(2);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0,ExtStdDevBuffer);
   SetIndexLabel(0, "Standard Deviation");
   SetIndexStyle(0, indicator_type1);
   SetIndexShift(0, InpShift);
   SetIndexDrawBegin(0, InpWindow - 1);
   
   SetIndexBuffer(1,ExtMovingBuffer);
   SetIndexLabel(1, "MA");
   SetIndexStyle(1, indicator_type1);
   SetIndexShift(1, InpShift);
   SetIndexDrawBegin(0, InpWindow - 1);
   IndicatorShortName("Standard Deviation");
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
   int i, pos;
   int limit = rates_total - prev_calculated; 
   
   ArraySetAsSeries(ExtMovingBuffer,false);
   ArraySetAsSeries(ExtStdDevBuffer,false);
   
   if (prev_calculated > 0) limit++; 
   
    if(prev_calculated>1)
      pos=prev_calculated-1;
   else
      pos=0;
   for(i=pos; i<rates_total && !IsStopped(); i++){
      ExtMovingBuffer[i]=SimpleMA(i,InpWindow,close);
      ExtStdDevBuffer[i] = CalculateStandardDeviation(i, close, ExtMovingBuffer);
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double      CalculateStandardDeviation(int position, const double &close[], const double &ma_price[]) {

   double sum = 0;
   
   if (position >= InpWindow) {
      for (int i = 0; i < InpWindow; i++) {
         double close_price = close[position-i];
         double diff = MathPow(close_price - ma_price[position], 2);
         sum += diff;
      }
   }
   
   double sdev = MathSqrt(sum / InpWindow); 
   return sdev;   
}
