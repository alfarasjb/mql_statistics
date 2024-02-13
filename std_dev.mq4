
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Standard Deviation"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#include <MovingAverages.mqh>
#include <MAIN/math.mqh>
input    int      InpWindow   = 3; 
input    int      InpShift    = 0;
double      SDevBuffer[], MeanBuffer[], CloseBuffer[];
double      BarBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
   IndicatorBuffers(indicator_buffers);
   IndicatorDigits(Digits + 2);
   SetIndexBuffer(0, SDevBuffer, INDICATOR_DATA);
   SetIndexStyle(0, indicator_type1, indicator_style1, indicator_width1, indicator_color1);
   SetIndexLabel(0, indicator_label1);
   
   
   SetIndexDrawBegin(0, 0);
   IndicatorShortName("Standard Deviation");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, // size of input time series 
                const int prev_calculated, // number of handled bars at the previous call
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
   
   ArraySetAsSeries(SDevBuffer, false);
   
   int limit = prev_calculated == 0 ? 0 : prev_calculated - 1;
   
   for(int i=limit; i<rates_total; i++){
      SDevBuffer[i] = CalculateStandardDeviation(i, InpWindow, close);
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
