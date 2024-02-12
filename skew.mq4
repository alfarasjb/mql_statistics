
#property copyright "Copyright 2023, Jay Benedict Alfaras"
#property version   "1.00"
#property strict
#property indicator_separate_window

#property indicator_buffers   5
#property indicator_plots     1 
#property indicator_label1    "Rolling Skew"
#property indicator_type1     DRAW_LINE 
#property indicator_color1    clrYellow
#property indicator_style1    STYLE_SOLID
#property indicator_width1    1 

#property indicator_label2    "Rolling SDEV"
#property indicator_type2     DRAW_LINE 
#property indicator_color2    clrYellow
#property indicator_style2    STYLE_SOLID
#property indicator_width2    1 

#include <MovingAverages.mqh>

input    int      InpWindow   = 10;
input    int      InpShift    = 0; 

double      SkewBuffer[], SDevBuffer[], MeanBuffer[], DiffBuffer[], CloseBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(indicator_buffers);
   IndicatorDigits(Digits);
   
   SetIndexBuffer(0, SkewBuffer, INDICATOR_DATA);
   SetIndexLabel(0, "Skew");
   SetIndexStyle(0, indicator_type1);
   SetIndexShift(0, InpShift);
   SetIndexDrawBegin(0, InpWindow + InpShift);
   
   SetIndexBuffer(1, SDevBuffer);
   SetIndexLabel(1, "Standard Deviation");
   SetIndexStyle(1, indicator_type2);
   SetIndexShift(1, InpShift);
   SetIndexDrawBegin(1, InpWindow - 1);
   
   //ArraySetAsSeries(SkewBuffer, false);
   ArraySetAsSeries(SDevBuffer,false);
   ArraySetAsSeries(MeanBuffer,false);
   ArraySetAsSeries(DiffBuffer, false);
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
      //MeanBuffer[i]=SimpleMA(i,InpWindow,close);
      //ExtStdDevBuffer[i] = CalculateStandardDeviation(i, close, ExtMovingBuffer);
      //DiffBuffer[i] = Diff_Mean(i, InpWindow, close, open);
      double sdev = iCustom(NULL, PERIOD_CURRENT, "b63//statistics//std_dev", InpWindow, 0, 0, i);
      SkewBuffer[i] = CalculateSkew(i, close, sdev);
      //CloseBuffer[i] = close[i];
      
      //SkewBuffer[i] = close[i];
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double      CalculateSkew(int position, const double &close[], const double standard_dev) {
   
   double sum = 0;
   double mean = SimpleMA(position, InpWindow, close);
   //double standard_dev = iCustom(NULL, PERIOD_CURRENT, "b63//statistics//std_dev", InpWindow, 0, 0, position);
   //return standard_dev;
   
   if (position >= InpWindow) {
      for (int i = 0; i < InpWindow; i++) {
         double close_price = close[position-i];
         
         double diff = MathPow((close_price - mean), 3);
         sum += diff; 
      }
   }
   double skew = standard_dev != 0 ? sum / ((InpWindow - 1) * MathPow(standard_dev, 3)) : 0;
   //Print(skew);
   return skew;
}


double Diff_Mean(const int position,const int period,const double &close[], const double &open[])
  {
//---
   double result=0.0;
//--- check position
   if(position>=period-1 && period>0)
     {
      //--- calculate value
      for(int i=0;i<period;i++) result+= (close[position-i]-open[position-i]);
      result/=period;
     }
//---
   return(result);
  }