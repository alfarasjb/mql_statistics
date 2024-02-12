//+------------------------------------------------------------------+
//|                                                      z_score.mq4 |
//|                             Copyright 2023, Jay Benedict Alfaras |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#include <MovingAverages.mqh>


#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Z-Score"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers


enum CalculationType{
   Single,
   Pair
};

input int               InpWindow               = 25;
input int               InpShift                = 0;
input CalculationType   InpCalcType             = Single;
input string            InpSecondarySymbol      = "EURUSD";

#property indicator_level1     2
#property indicator_level2     -2
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT


double         ExtZScoreBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorDigits(Digits + 1);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtZScoreBuffer);
   SetIndexLabel(0, "Z-Score");
   SetIndexStyle(0, indicator_type1);
   SetIndexShift(0, InpShift);
   SetIndexDrawBegin(0, InpWindow - 1);
   IndicatorShortName("Z-Score");
   
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
   
   int limit = rates_total - prev_calculated; 
   
   if (prev_calculated > 0) limit++; 
   
   for (int i = 0; i < limit; i++){
      ExtZScoreBuffer[i] = CalculateZScore(i);
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double CalculateZScore(int i){
   double diff = CalculateDiff(i);
   double mean = CalculateMean(i);
   double std_dev = CalculateStdDev(i);
   
   if (std_dev == 0) return 0;
   double z_score = (diff - mean) / std_dev; 
   return z_score; 
}


double CalculateDiff(int i){
   
   double primary_close = ClosePrice(Symbol(), i);
   double secondary_close = ClosePrice(InpSecondarySymbol, i);
   double rolling_mean = iMA(Symbol(), PERIOD_CURRENT, InpWindow, 0, MODE_SMA, PRICE_CLOSE, i);
   double diff; 
   
   switch(InpCalcType) {
      case Single:   
         
         diff = primary_close - rolling_mean;
         return diff;
         break;
         
      case Pair:
         
         if (secondary_close == 0) return 0;
         diff = primary_close / secondary_close; 
         
         return diff; 
         break;
      default: 
         break;
   }
   
   return diff;
}


double CalculateMean(int index){
   //int size = ArraySize(values);
   
   double values[]; 
   
   int num_elements = InpWindow; 
   
   for (int j = 0; j < InpWindow; j++){
      int val_size = ArraySize(values);
      ArrayResize(values, val_size + 1);
      values[val_size] = CalculateDiff(index + j); 
   }
   
   
   
   double sum = 0.0;
   int size = ArraySize(values);
   for (int i = 0; i < size; i++){
      sum += values[i];
   }
   
   double mean = sum / size; 
   return mean; 
}


double CalculateStdDev(int index){

   double sum = 0.0;
   double mu = CalculateMean(index);
   
   double diffs[];
   
   for (int i = 0; i < InpWindow; i++){
      int diff_size = ArraySize(diffs);
      ArrayResize(diffs, diff_size + 1);
      diffs[diff_size] = MathPow(CalculateDiff(index + i) - mu, 2);
   }
   
   int size = ArraySize(diffs);
   
   for (int j = 0; j < size; j++){
      sum += (diffs[j]);
   }
   
   double in = sum / InpWindow; 
   double sdev = MathSqrt(in);
   
   return sdev;
}

double ClosePrice(string symbol, int i ) { return iClose(symbol, PERIOD_CURRENT, i); }