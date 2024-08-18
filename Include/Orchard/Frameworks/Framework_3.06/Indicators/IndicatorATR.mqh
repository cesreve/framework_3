#include "IndicatorBase.mqh"

class CIndicatorATR : public CIndicatorBase {

private:
protected: // member variables
   int mPeriod;

   void Init(int period);

public: // constructors
   CIndicatorATR(int period);
   CIndicatorATR(string symbol, ENUM_TIMEFRAMES timeframe, int period);
   ~CIndicatorATR();

public:
#ifdef __MQL4__
   virtual double GetData(const int buffer_num, const int index);
#endif
};

CIndicatorATR::CIndicatorATR(int period)
   : CIndicatorBase(Symbol(), (ENUM_TIMEFRAMES)Period()) {

   Init(period);
}

CIndicatorATR::CIndicatorATR(string symbol, ENUM_TIMEFRAMES timeframe, int period)
   : CIndicatorBase(symbol, timeframe) {

   Init(period);
}

void CIndicatorATR::Init(int period) {

   if (mInitResult != INIT_SUCCEEDED) return;

   mPeriod = period;

//	For MQL5 create the indicator handle here
#ifdef __MQL5__
   mIndicatorHandle = iATR(mSymbol, mTimeframe, mPeriod);
   if (mIndicatorHandle == INVALID_HANDLE) {
      InitError("Failed to create indicator handle", INIT_FAILED);
      return;
   }
#endif

   InitError("", INIT_SUCCEEDED);
}

CIndicatorATR::~CIndicatorATR() {}

#ifdef __MQL4__
double CIndicatorATR::GetData(const int buffer_num, const int index) {

   double value = iATR(mSymbol, mTimeframe, mPeriod, index);
   return (value);
}
#endif