
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict
#property indicator_separate_window

#property indicator_buffers   3
#property indicator_plots     1 
#property indicator_minimum    -2
#property indicator_maximum    2
#property indicator_label1    "Rolling Skew"
#property indicator_type1     DRAW_LINE 
#property indicator_color1    clrYellow
#property indicator_style1    STYLE_SOLID
#property indicator_width1    1 

#include <MovingAverages.mqh>

input    int      InpWindow   = 10;
input    int      InpShift    = 0; 

double      SkewBuffer[], SDevBuffer[], MeanBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(indicator_buffers);
   IndicatorDigits(Digits);
   
   SetIndexBuffer(0, SkewBuffer);
   SetIndexLabel(0, "Skew");
   SetIndexStyle(0, indicator_type1);
   SetIndexShift(0, InpShift);
   SetIndexDrawBegin(0, InpWindow - 1);
   
   SetIndexBuffer(1, SDevBuffer);
   SetIndexLabel(1, "Standard Deviation");
   SetIndexStyle(1, indicator_type1);
   SetIndexShift(1, InpShift);
   
   SetIndexBuffer(2, MeanBuffer);
   SetIndexLabel(2, "Mean");
   SetIndexStyle(2, indicator_type1);
   SetIndexShift(2, InpShift);
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
   ArraySetAsSeries(SkewBuffer,false);
   ArraySetAsSeries(SDevBuffer,false);
   ArraySetAsSeries(MeanBuffer,false);
   ArraySetAsSeries(close, false);
   
   int pos = prev_calculated > 1 ? prev_calculated - 1 : 0;
      
   //PrintFormat("Rates Total: %i, Prev Calculated: %i", rates_total, prev_calculated);
   //PrintFormat("Open: %f, High: %f, Low: %f, Close: %f", open[0], high[0], low[0], close[0]);
   //PrintFormat("MA: %f", ExtMovingBuffer[InpWindow]);
   for(int i=pos; i<rates_total && !IsStopped(); i++){
      MeanBuffer[i]=SimpleMA(i,InpWindow,close);
      //ExtStdDevBuffer[i] = CalculateStandardDeviation(i, close, ExtMovingBuffer);
      SkewBuffer[i] = CalculateSkew(i, close, open, MeanBuffer, SDevBuffer);
      //SkewBuffer[i] = close[i];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double      CalculateSkew(int position, const double &close[], const double &open[], const double &ma_price[], const double &sdev[]) {
   
   double sum = 0;
   double mean = ma_price[position];
   double standard_dev = sdev[position];
   if (position >= InpWindow) {
      for (int i = 0; i < InpWindow; i++) {
         double close_price = close[position-i];
         double open_price = open[position - i];
         
         double diff = MathPow((close_price - mean), 3);
         sum += diff; 
      }
   }
   
   double skew = sum / ((InpWindow - 1) * MathPow(standard_dev, 3));
   return close[position];
}