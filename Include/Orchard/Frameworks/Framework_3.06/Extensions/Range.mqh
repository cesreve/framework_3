/*
   Range.mqh
   Framework 3.06 Extension

   Copyright 2023, Your Name
   https://www.yourwebsite.com
*/

#include "../Common/CommonBase.mqh"

class CRange : public CCommonBase {
private:
    datetime mStartTime;
    datetime mEndTime;
    double mHighPoint;
    double mLowPoint;
    int mRectangleId;
public:
    // Constructors
    CRange() : CCommonBase() { Init(_Symbol, (ENUM_TIMEFRAMES)_Period); }
    CRange(string symbol) : CCommonBase(symbol) { Init(symbol, (ENUM_TIMEFRAMES)_Period); }
    CRange(ENUM_TIMEFRAMES timeframe) : CCommonBase(timeframe) { Init(_Symbol, timeframe); }
    CRange(string symbol, ENUM_TIMEFRAMES timeframe) : CCommonBase(symbol, timeframe) { Init(symbol, timeframe); }

    // Destructor
    ~CRange() {
    for (int i = 0; i < mRectangleId; i++) {
        string name = "Range_" + IntegerToString(i);
        ObjectDelete(0, name);
    }
}

    // Initialization
    int Init(string symbol, ENUM_TIMEFRAMES timeframe) {
        int result = CCommonBase::Init(symbol, timeframe);
        if (result != INIT_SUCCEEDED) return result;

        mStartTime = 0;
        mEndTime = 0;
        mHighPoint = 0;
        mLowPoint = 0;
        mRectangleId = 0;

        return INIT_SUCCEEDED;
    }

    // Setters
    void SetTimeRange(datetime now, int startHour, int startMinute, int endHour, int endMinute) {
        mEndTime = SetNextTime(now+60, endHour, endMinute);
        mStartTime = SetPrevTime(mEndTime, startHour, startMinute);
        CalculateHighLow();
    }

    // Getters
    datetime GetStartTime() const { return mStartTime; }
    datetime GetEndTime() const { return mEndTime; }
    double GetHighPoint() const { return mHighPoint; }
    double GetLowPoint() const { return mLowPoint; }

    // Methods
    bool IsInRange(datetime time) const {
        return (time >= mStartTime && time <= mEndTime);
    }

    // New method to display the range as a rectangle
    void DisplayRangeOnChart(color fillColor = clrNONE, color borderColor = clrRed, int width = 1) {
        if (mStartTime == 0 || mEndTime == 0) return;

        string name = "Range_" + IntegerToString(mRectangleId++);
        ObjectCreate(0, name, OBJ_RECTANGLE, 0, mStartTime, mLowPoint, mEndTime, mHighPoint);
        ObjectSetInteger(0, name, OBJPROP_COLOR, borderColor);
        // ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
        // ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
        // ObjectSetInteger(0, name, OBJPROP_FILL, fillColor != clrNONE);
        ObjectSetInteger(0, name, OBJPROP_FILL, true);
        ObjectSetInteger(0, name, OBJPROP_BACK, true);
        // ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        // ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        // if (fillColor != clrNONE) {
        //     ObjectSetInteger(0, name, OBJPROP_BGCOLOR, fillColor);
        // }
    }

private:
    void CalculateHighLow() {
        mHighPoint = DBL_MIN;
        mLowPoint = DBL_MAX;

        int startBar = iBarShift(mSymbol, mTimeframe, mStartTime);
        int endBar = iBarShift(mSymbol, mTimeframe, mEndTime);

        for (int i = MathMin(startBar, endBar); i <= MathMax(startBar, endBar); i++) {
            double high = iHigh(mSymbol, mTimeframe, i);
            double low = iLow(mSymbol, mTimeframe, i);

            if (high > mHighPoint) mHighPoint = high;
            if (low < mLowPoint) mLowPoint = low;
        }
    }

    //+------------------------------------------------------------------+
    datetime SetNextTime(datetime now, int hour, int minute) {
    
    MqlDateTime nowStruct;
    TimeToStruct(now, nowStruct);
    
    nowStruct.sec = 0;
    datetime nowTime = StructToTime(nowStruct);
    
    nowStruct.hour = hour;
    nowStruct.min = minute;
    datetime nextTime = StructToTime(nowStruct);
    
    while(nextTime + 86400 < nowTime || !IsTradingDay(nextTime)) {
        nextTime += 86400;
    }   
    return nextTime;
    }
    //+------------------------------------------------------------------+
    datetime SetPrevTime(datetime now, int hour, int minute) {
    
    MqlDateTime nowStruct;
    TimeToStruct(now, nowStruct);
    
    nowStruct.sec = 0;
    datetime nowTime = StructToTime(nowStruct);
    
    nowStruct.hour = hour;
    nowStruct.min = minute;
    datetime prevTime = StructToTime(nowStruct);
    
    while(prevTime >= nowTime || !IsTradingDay(prevTime)) {
        prevTime -= 86400;
    }   
    return prevTime;
    }
    //+------------------------------------------------------------------+
    bool IsTradingDay(datetime time) {
    MqlDateTime timeStruct;
    TimeToStruct(time, timeStruct);
    datetime fromTime;
    datetime toTime;
    return SymbolInfoSessionTrade(Symbol(), (ENUM_DAY_OF_WEEK)timeStruct.day_of_week, 0, fromTime, toTime);
    }
};