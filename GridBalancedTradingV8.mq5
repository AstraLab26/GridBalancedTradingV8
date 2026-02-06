//+------------------------------------------------------------------+
//|                    GridBalancedTradingV8.mq5                     |
//|         EA Grid Trading với cân bằng lưới tự động và giờ hoạt động |
//+------------------------------------------------------------------+
#property copyright "Grid Balanced Trading"
#property version   "8.0"
#property description "Grid Trading EA với giờ hoạt động - EA khởi động ngay và tạo lưới tại giá hiện tại, hỗ trợ giờ hoạt động tùy chỉnh"

#include <Trade\Trade.mqh>

//--- Enum cho hành động khi đạt TP tổng
enum ENUM_TP_ACTION
{
   TP_ACTION_STOP_EA = 0,    // Dừng EA
   TP_ACTION_RESET_EA = 1    // Reset EA
};

//--- Enum cho chế độ Trading Stop
enum ENUM_TRADING_STOP_MODE
{
   TRADING_STOP_MODE_OPEN = 0,    // Theo ngưỡng các lệnh mở
   TRADING_STOP_MODE_SESSION = 1, // Theo ngưỡng phiên
   TRADING_STOP_MODE_BOTH = 2     // Tổ hợp cả 2 (ưu tiên cái đạt trước)
};

//--- Input parameters - Cài đặt lưới
input group "=== CÀI ĐẶT LƯỚI ==="
input double GridDistancePips = 20.0;           // Khoảng cách lưới (pips)
input int MaxGridLevels = 10;                   // Số lượng lưới tối đa
input bool AutoRefillOrders = true;             // Tự động bổ sung lệnh khi đóng

//--- Input parameters - Cài đặt lệnh Buy Limit
input group "=== CÀI ĐẶT LỆNH BUY LIMIT ==="
input bool EnableBuyLimit = true;               // Cho phép lệnh Buy Limit
input double LotSizeBuyLimit = 0.01;            // Khối lượng Buy Limit (mức 1)
input double TakeProfitPipsBuyLimit = 30.0;     // Take Profit Buy Limit (pips, 0=off)
input bool EnableMartingaleBuyLimit = false;    // Bật gấp thếp Buy Limit
input double MartingaleMultiplierBuyLimit = 2.0; // Hệ số gấp thếp Buy Limit (mức 2=x2, mức 3=x4...)
input int MartingaleStartLevelBuyLimit = 1;      // Bắt đầu gấp thếp từ bậc lưới (1=bậc 2, 3=bậc 3...)

//--- Input parameters - Cài đặt lệnh Sell Limit
input group "=== CÀI ĐẶT LỆNH SELL LIMIT ==="
input bool EnableSellLimit = true;              // Cho phép lệnh Sell Limit
input double LotSizeSellLimit = 0.01;           // Khối lượng Sell Limit (mức 1)
input double TakeProfitPipsSellLimit = 30.0;    // Take Profit Sell Limit (pips, 0=off)
input bool EnableMartingaleSellLimit = false;   // Bật gấp thếp Sell Limit
input double MartingaleMultiplierSellLimit = 2.0; // Hệ số gấp thếp Sell Limit (mức 2=x2, mức 3=x4...)
input int MartingaleStartLevelSellLimit = 1;     // Bắt đầu gấp thếp từ bậc lưới (1=bậc 2, 3=bậc 3...)

//--- Input parameters - Cài đặt lệnh Buy Stop
input group "=== CÀI ĐẶT LỆNH BUY STOP ==="
input bool EnableBuyStop = true;                // Cho phép lệnh Buy Stop
input double LotSizeBuyStop = 0.01;             // Khối lượng Buy Stop (mức 1)
input double TakeProfitPipsBuyStop = 30.0;      // Take Profit Buy Stop (pips, 0=off)
input bool EnableMartingaleBuyStop = false;     // Bật gấp thếp Buy Stop
input double MartingaleMultiplierBuyStop = 2.0; // Hệ số gấp thếp Buy Stop (mức 2=x2, mức 3=x4...)
input int MartingaleStartLevelBuyStop = 1;      // Bắt đầu gấp thếp từ bậc lưới (1=bậc 2, 3=bậc 3...)

//--- Input parameters - Cài đặt lệnh Sell Stop
input group "=== CÀI ĐẶT LỆNH SELL STOP ==="
input bool EnableSellStop = true;               // Cho phép lệnh Sell Stop
input double LotSizeSellStop = 0.01;            // Khối lượng Sell Stop (mức 1)
input double TakeProfitPipsSellStop = 30.0;     // Take Profit Sell Stop (pips, 0=off)
input bool EnableMartingaleSellStop = false;    // Bật gấp thếp Sell Stop
input double MartingaleMultiplierSellStop = 2.0; // Hệ số gấp thếp Sell Stop (mức 2=x2, mức 3=x4...)
input int MartingaleStartLevelSellStop = 1;     // Bắt đầu gấp thếp từ bậc lưới (1=bậc 2, 3=bậc 3...)

//--- Input parameters - TP tổng
input group "=== TP TỔNG ==="
input double TotalProfitTPOpen = 0.0;                          // TP tổng lệnh đang mở (USD, 0=off)
input ENUM_TP_ACTION ActionOnTotalProfitOpen = TP_ACTION_RESET_EA; // Hành động khi đạt TP tổng lệnh mở
input double TotalProfitTPSession = 0.0;                       // TP tổng phiên (USD, 0=off)
input ENUM_TP_ACTION ActionOnTotalProfitSession = TP_ACTION_RESET_EA; // Hành động khi đạt TP tổng phiên
input double TotalProfitTPAccumulated = 0.0;                   // TP tổng tích lũy (USD, 0=off)

//--- Input parameters - Trading Stop, Step Tổng
input group "=== TRADING STOP, STEP TỔNG (GỒNG LÃI) ==="
input bool EnableTradingStopStepTotal = false;                 // Bật Trading Stop, Step Tổng
input ENUM_TRADING_STOP_MODE TradingStopStepMode = TRADING_STOP_MODE_OPEN; // Chế độ gồng lãi (0=Theo lệnh mở, 1=Theo phiên)
input double TradingStopStepTotalProfit = 50.0;                // Lãi tổng lệnh đang mở để kích hoạt (USD, 0=off)
input double TradingStopStepSessionProfit = 50.0;              // Lãi tổng phiên để kích hoạt (USD, dùng khi chế độ = Theo phiên, 0=off)
input double TradingStopStepReturnProfitOpen = 20.0;           // Lãi tổng lệnh mở khi quay lại để tiếp tục (USD, nếu < ngưỡng kích hoạt thì hủy)
input double TradingStopStepReturnProfitSession = 20.0;       // Lãi tổng phiên khi quay lại để tiếp tục (USD, nếu < ngưỡng kích hoạt thì hủy)
input double TradingStopStepPointA = 10.0;                     // Điểm A cách lệnh dương thấp nhất (pips)
input double TradingStopStepSize = 5.0;                        // Step pips để di chuyển SL (pips)
input ENUM_TP_ACTION ActionOnTradingStopStepComplete = TP_ACTION_STOP_EA; // Hành động khi giá chạm SL (0=Dừng EA, 1=Reset EA)
input bool EnableLotBasedReset = false;                        // Bật reset dựa trên lot và tổng phiên
input double MaxLotThreshold = 0.1;                            // Lot lớn nhất của lệnh đang mở để kích hoạt (0=off)
input double TotalLotThreshold = 1.0;                          // Tổng lot của lệnh đang mở để kích hoạt (0=off)
input double SessionProfitForLotReset = 50.0;                  // Tổng phiên hiện tại (USD) để reset khi đạt điều kiện lot (0=off)

//--- Input parameters - SL % so với tài khoản
input group "=== SL % SO VỚI TÀI KHOẢN ==="
input bool EnableAccountSLPercent = false;                    // Bật SL % so với tài khoản
input double AccountSLPercent = 10.0;                         // % lỗ so với tài khoản để kích hoạt (%, 0=off)
input double MaxLotForAccountSL = 0.0;                        // Lot lớn nhất của lệnh đang mở để kích hoạt (0=off, bỏ qua nếu = 0)
input double TotalLotForAccountSL = 0.0;                      // Tổng lot lệnh đang mở để kích hoạt (0=off, bỏ qua nếu = 0)
input ENUM_TP_ACTION ActionOnAccountSL = TP_ACTION_STOP_EA;   // Hành động khi đạt SL % (0=Dừng EA, 1=Reset EA)

//--- Input parameters - Giờ hoạt động
input group "=== GIỜ HOẠT ĐỘNG ==="
input bool EnableTradingHours = false;          // Bật giờ hoạt động
input int StartHour = 0;                        // Giờ bắt đầu (0-23)
input int StartMinute = 0;                      // Phút bắt đầu (0-59)
input int EndHour = 23;                        // Giờ kết thúc (0-23)
input int EndMinute = 59;                      // Phút kết thúc (0-59)

//--- Input parameters - Cài đặt chung
input group "=== CÀI ĐẶT CHUNG ==="
input int MagicNumber = 123456;                 // Magic Number
input string CommentOrder = "Grid Balanced V8"; // Comment cho lệnh
input bool EnableResetNotification = false;     // Bật thông báo về điện thoại khi EA reset

//--- Global variables
CTrade trade;
double pnt;
int dgt;
double basePrice;                               // Giá cơ sở để tính các level
double gridLevels[];                            // Mảng chứa các level giá cố định
int gridLevelIndex[];                           // Mảng lưu chỉ số mức lưới (1, 2, 3...)

// Cấu trúc lưu lot size cho mỗi mức lưới và loại lệnh
struct GridLotSize
{
   double lotSizeBuyLimit[50];                  // Lot size cho Buy Limit theo mức (max 50 mức)
   double lotSizeSellLimit[50];                 // Lot size cho Sell Limit theo mức
   double lotSizeBuyStop[50];                   // Lot size cho Buy Stop theo mức
   double lotSizeSellStop[50];                  // Lot size cho Sell Stop theo mức
};

GridLotSize gridLotSizes;                       // Lưu trữ lot size cho mỗi mức lưới

// Biến theo dõi profit
double sessionProfit = 0.0;                     // Profit của phiên hiện tại (không dùng nữa, tính từ vốn)
double accumulatedProfit = 0.0;                 // Tích lũy = Balance hiện tại - Balance ban đầu khi EA khởi động
datetime sessionStartTime = 0;                  // Thời gian bắt đầu phiên
double initialEquity = 0.0;                     // Vốn ban đầu (Equity) khi bắt đầu phiên
double initialBalance = 0.0;                    // Số dư ban đầu (Balance) khi bắt đầu phiên
double initialBalanceAtStart = 0.0;              // Số dư ban đầu khi EA khởi động lần đầu (không reset khi EA reset)
int resetCount = 0;                              // Số lần EA reset (tích lũy lần N)
double minEquity = 0.0;                        // Vốn thấp nhất (khi lỗ lớn nhất) trong phiên
double maxNegativeProfit = 0.0;                 // Số âm lớn nhất của lệnh đang mở (không reset khi EA reset)
double balanceAtMaxLoss = 0.0;                  // Số dư tại thời điểm có số âm lớn nhất (không reset khi EA reset)
double maxLotEver = 0.0;                         // Số lot lớn nhất từng có (không reset khi EA reset)
double totalLotEver = 0.0;                      // Tổng lot lớn nhất từng có (không reset khi EA reset)
bool eaStopped = false;                         // Flag dừng EA
bool eaStoppedByTradingHours = false;           // Flag dừng EA do ngoài giờ hoạt động
bool isResetting = false;                       // Flag đang trong quá trình reset

// Biến theo dõi Trading Stop, Step Tổng
bool isTradingStopActive = false;               // Flag đang ở chế độ Trading Stop
double pointA = 0.0;                            // Điểm A (SL) hiện tại cho các lệnh
double initialPointA = 0.0;                     // Điểm A ban đầu (để tính trailing)
double lastPriceForStep = 0.0;                  // Giá cuối để theo dõi step
double initialPriceForStop = 0.0;               // Giá ban đầu khi kích hoạt stop
bool firstStepDone = false;                     // Flag đã thực hiện step đầu tiên (đóng lệnh âm, set SL)
bool isTradingStopBuyDirection = false;         // Hướng của Trading Stop (true=Buy, false=Sell)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   trade.SetExpertMagicNumber(MagicNumber);
   dgt = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   pnt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // Khởi tạo giá cơ sở
   basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Tạo mảng các level giá cố định
   InitializeGridLevels();
   
   Print("========================================");
   Print("Grid Balanced Trading EA V8 đã khởi động");
   Print("Symbol: ", _Symbol);
   Print("Base Price: ", basePrice);
   Print("Grid Distance: ", GridDistancePips, " pips");
   Print("Max Levels: ", MaxGridLevels);
   Print("Auto Refill: ", AutoRefillOrders ? "ON" : "OFF");
   Print("--- Loại lệnh được bật ---");
   Print("Buy Limit: ", EnableBuyLimit ? "ON" : "OFF", " | Sell Limit: ", EnableSellLimit ? "ON" : "OFF");
   Print("Buy Stop: ", EnableBuyStop ? "ON" : "OFF", " | Sell Stop: ", EnableSellStop ? "ON" : "OFF");
   Print("--- Cài đặt lệnh ---");
   if(EnableBuyLimit)
   {
      Print("  Buy Limit - Lot: ", LotSizeBuyLimit, " | TP: ", TakeProfitPipsBuyLimit, " pips");
      if(EnableMartingaleBuyLimit)
      {
         string startLevelInfo = "Bắt đầu từ bậc " + IntegerToString(MartingaleStartLevelBuyLimit);
         double lotLevel3 = (MartingaleStartLevelBuyLimit <= 3) ? LotSizeBuyLimit * MathPow(MartingaleMultiplierBuyLimit, 3 - MartingaleStartLevelBuyLimit + 1) : LotSizeBuyLimit;
         double lotLevel4 = (MartingaleStartLevelBuyLimit <= 4) ? LotSizeBuyLimit * MathPow(MartingaleMultiplierBuyLimit, 4 - MartingaleStartLevelBuyLimit + 1) : LotSizeBuyLimit;
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierBuyLimit, "x | ", startLevelInfo, " (bậc ", MartingaleStartLevelBuyLimit, "=", LotSizeBuyLimit * MathPow(MartingaleMultiplierBuyLimit, 1), ", bậc 3=", lotLevel3, ", bậc 4=", lotLevel4, "...)");
      }
   }
   if(EnableSellLimit)
   {
      Print("  Sell Limit - Lot: ", LotSizeSellLimit, " | TP: ", TakeProfitPipsSellLimit, " pips");
      if(EnableMartingaleSellLimit)
      {
         string startLevelInfo = "Bắt đầu từ bậc " + IntegerToString(MartingaleStartLevelSellLimit);
         double lotLevel3 = (MartingaleStartLevelSellLimit <= 3) ? LotSizeSellLimit * MathPow(MartingaleMultiplierSellLimit, 3 - MartingaleStartLevelSellLimit + 1) : LotSizeSellLimit;
         double lotLevel4 = (MartingaleStartLevelSellLimit <= 4) ? LotSizeSellLimit * MathPow(MartingaleMultiplierSellLimit, 4 - MartingaleStartLevelSellLimit + 1) : LotSizeSellLimit;
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierSellLimit, "x | ", startLevelInfo, " (bậc ", MartingaleStartLevelSellLimit, "=", LotSizeSellLimit * MathPow(MartingaleMultiplierSellLimit, 1), ", bậc 3=", lotLevel3, ", bậc 4=", lotLevel4, "...)");
      }
   }
   if(EnableBuyStop)
   {
      Print("  Buy Stop - Lot: ", LotSizeBuyStop, " | TP: ", TakeProfitPipsBuyStop, " pips");
      if(EnableMartingaleBuyStop)
      {
         string startLevelInfo = "Bắt đầu từ bậc " + IntegerToString(MartingaleStartLevelBuyStop);
         double lotLevel3 = (MartingaleStartLevelBuyStop <= 3) ? LotSizeBuyStop * MathPow(MartingaleMultiplierBuyStop, 3 - MartingaleStartLevelBuyStop + 1) : LotSizeBuyStop;
         double lotLevel4 = (MartingaleStartLevelBuyStop <= 4) ? LotSizeBuyStop * MathPow(MartingaleMultiplierBuyStop, 4 - MartingaleStartLevelBuyStop + 1) : LotSizeBuyStop;
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierBuyStop, "x | ", startLevelInfo, " (bậc ", MartingaleStartLevelBuyStop, "=", LotSizeBuyStop * MathPow(MartingaleMultiplierBuyStop, 1), ", bậc 3=", lotLevel3, ", bậc 4=", lotLevel4, "...)");
      }
   }
   if(EnableSellStop)
   {
      Print("  Sell Stop - Lot: ", LotSizeSellStop, " | TP: ", TakeProfitPipsSellStop, " pips");
      if(EnableMartingaleSellStop)
      {
         string startLevelInfo = "Bắt đầu từ bậc " + IntegerToString(MartingaleStartLevelSellStop);
         double lotLevel3 = (MartingaleStartLevelSellStop <= 3) ? LotSizeSellStop * MathPow(MartingaleMultiplierSellStop, 3 - MartingaleStartLevelSellStop + 1) : LotSizeSellStop;
         double lotLevel4 = (MartingaleStartLevelSellStop <= 4) ? LotSizeSellStop * MathPow(MartingaleMultiplierSellStop, 4 - MartingaleStartLevelSellStop + 1) : LotSizeSellStop;
         Print("    Gấp thếp: ON | Hệ số: ", MartingaleMultiplierSellStop, "x | ", startLevelInfo, " (bậc ", MartingaleStartLevelSellStop, "=", LotSizeSellStop * MathPow(MartingaleMultiplierSellStop, 1), ", bậc 3=", lotLevel3, ", bậc 4=", lotLevel4, "...)");
      }
   }
   Print("Tổng số levels: ", ArraySize(gridLevels));
   Print("--- TP Tổng ---");
   if(TotalProfitTPOpen > 0)
      Print("TP Tổng lệnh mở: ", TotalProfitTPOpen, " USD | Hành động: ", ActionOnTotalProfitOpen == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
   if(TotalProfitTPSession > 0)
      Print("TP Tổng phiên: ", TotalProfitTPSession, " USD | Hành động: ", ActionOnTotalProfitSession == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
   if(TotalProfitTPAccumulated > 0)
      Print("TP Tổng tích lũy: ", TotalProfitTPAccumulated, " USD | Hành động: Dừng EA");
   Print("--- Trading Stop, Step Tổng ---");
   bool tradingStopEnabled = false;
   if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
   {
      tradingStopEnabled = (EnableTradingStopStepTotal && TradingStopStepTotalProfit > 0);
   }
   else if(TradingStopStepMode == TRADING_STOP_MODE_SESSION)
   {
      tradingStopEnabled = (EnableTradingStopStepTotal && TradingStopStepSessionProfit > 0);
   }
   else if(TradingStopStepMode == TRADING_STOP_MODE_BOTH)
   {
      tradingStopEnabled = (EnableTradingStopStepTotal && TradingStopStepTotalProfit > 0 && TradingStopStepSessionProfit > 0);
   }
   
   if(tradingStopEnabled)
   {
      Print("Trading Stop, Step Tổng: ON");
      if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
      {
         Print("  - Chế độ: Theo lệnh mở");
         Print("  - Lãi kích hoạt (lệnh mở): ", TradingStopStepTotalProfit, " USD");
      }
      else if(TradingStopStepMode == TRADING_STOP_MODE_SESSION)
      {
         Print("  - Chế độ: Theo phiên");
         Print("  - Lãi kích hoạt (phiên): ", TradingStopStepSessionProfit, " USD");
      }
      else if(TradingStopStepMode == TRADING_STOP_MODE_BOTH)
      {
         Print("  - Chế độ: Tổ hợp cả 2 (ưu tiên cái đạt trước)");
         Print("  - Lãi kích hoạt (lệnh mở): ", TradingStopStepTotalProfit, " USD");
         Print("  - Lãi kích hoạt (phiên): ", TradingStopStepSessionProfit, " USD");
      }
      if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
      {
         Print("  - Lãi quay lại (lệnh mở): ", TradingStopStepReturnProfitOpen, " USD");
      }
      else if(TradingStopStepMode == TRADING_STOP_MODE_SESSION)
      {
         Print("  - Lãi quay lại (phiên): ", TradingStopStepReturnProfitSession, " USD");
      }
      else if(TradingStopStepMode == TRADING_STOP_MODE_BOTH)
      {
         Print("  - Lãi quay lại (lệnh mở): ", TradingStopStepReturnProfitOpen, " USD");
         Print("  - Lãi quay lại (phiên): ", TradingStopStepReturnProfitSession, " USD");
      }
      Print("  - Điểm A cách lệnh dương: ", TradingStopStepPointA, " pips");
      Print("  - Step di chuyển SL: ", TradingStopStepSize, " pips");
      Print("  - Hành động khi chạm SL: ", ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA ? "Reset EA" : "Dừng EA");
   }
   else
   {
      Print("Trading Stop, Step Tổng: OFF");
   }
   Print("--- Giờ hoạt động ---");
   if(EnableTradingHours)
   {
      Print("Giờ hoạt động: ON");
      Print("  - Bắt đầu: ", StartHour, ":", (StartMinute < 10 ? "0" : ""), StartMinute);
      Print("  - Kết thúc: ", EndHour, ":", (EndMinute < 10 ? "0" : ""), EndMinute);
      Print("  - Ngoài giờ: EA không vào lệnh mới, nhưng tiếp tục quản lý lệnh đang mở");
   }
   else
   {
      Print("Giờ hoạt động: OFF");
   }
   Print("========================================");
   
   // Khởi tạo phiên
   sessionStartTime = TimeCurrent();
   sessionProfit = 0.0;
   accumulatedProfit = 0.0;
   resetCount = 0;  // Khởi tạo số lần reset = 0
   initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // Lưu vốn ban đầu (Balance + Floating)
   initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);  // Lưu số dư ban đầu
   initialBalanceAtStart = AccountInfoDouble(ACCOUNT_BALANCE);  // Lưu số dư ban đầu khi EA khởi động lần đầu (không reset)
   minEquity = initialEquity;  // Khởi tạo vốn thấp nhất bằng vốn ban đầu
   maxNegativeProfit = 0.0;  // Khởi tạo số âm lớn nhất
   balanceAtMaxLoss = AccountInfoDouble(ACCOUNT_BALANCE);  // Khởi tạo số dư tại thời điểm lỗ lớn nhất
   maxLotEver = 0.0;  // Khởi tạo số lot lớn nhất từng có
   totalLotEver = 0.0;  // Khởi tạo tổng lot lớn nhất từng có
   
   Print("Vốn ban đầu phiên: ", initialEquity, " USD");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Grid Balanced Trading EA V8 đã dừng. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Kiểm tra giờ hoạt động trước (để tự động khởi động lại nếu cần)
   bool withinTradingHours = IsWithinTradingHours();
   
   // Nếu trong giờ hoạt động và EA đang TẮT do giờ hoạt động → tự động khởi động lại
   // CHỈ khởi động lại khi EA đang TẮT (dừng do ngoài giờ). EA đang hoạt động thì tiếp tục, KHÔNG khởi động lại
   // Điều kiện: EA đang tắt (eaStoppedByTradingHours) VÀ không có lệnh đang mở (đảm bảo EA thực sự đang tắt)
   if(EnableTradingHours && withinTradingHours && eaStoppedByTradingHours && !eaStopped && !HasOpenOrders())
   {
      Print("========================================");
      Print("✓ VÀO GIỜ HOẠT ĐỘNG - EA ĐANG TẮT → TỰ ĐỘNG KHỞI ĐỘNG LẠI");
      Print("Lý do: EA đã dừng do ngoài giờ hoạt động, không còn lệnh. Lấy giá hiện tại làm gốc.");
      
      // Lấy giá hiện tại làm giá cơ sở mới (vị trí gốc)
      double oldBasePrice = basePrice;
      basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      Print("Giá cơ sở cũ: ", oldBasePrice);
      Print("Giá cơ sở mới (tại thời điểm vào giờ hoạt động): ", basePrice);
      
      // Khởi tạo lại lưới với giá cơ sở mới
      InitializeGridLevels();
      
      // Reset lot sizes đã lưu
      ZeroMemory(gridLotSizes);
      
      // Reset flag dừng do giờ hoạt động
      eaStoppedByTradingHours = false;
      
      Print("Đã khởi tạo lại lưới với giá cơ sở mới");
      Print("EA sẽ bắt đầu đặt lệnh tại các mức lưới mới");
      Print("========================================");
   }
   else if(EnableTradingHours && withinTradingHours && eaStoppedByTradingHours && !eaStopped && HasOpenOrders())
   {
      // EA đang tắt do giờ nhưng vẫn còn lệnh (bất thường) → chỉ reset flag, KHÔNG khởi động lại, tiếp tục quản lý lệnh
      eaStoppedByTradingHours = false;
   }
   
   // Nếu EA đã dừng (do TP/SL hoặc lý do khác) thì không làm gì
   // LƯU Ý: EA dừng do TP/SL sẽ KHÔNG tự động khởi động lại, kể cả khi vào giờ hoạt động
   if(eaStopped)
   {
      // Log mỗi 1000 tick để xác nhận EA đã dừng
      static int stoppedTickCount = 0;
      stoppedTickCount++;
      if(stoppedTickCount % 1000 == 0)
      {
         Print("EA đã DỪNG (do đạt TP/SL hoặc lý do khác) - Không tự động khởi động lại");
         if(EnableTradingHours && withinTradingHours)
         {
            Print("  → Lưu ý: EA đang trong giờ hoạt động nhưng vẫn DỪNG vì đã đạt TP/SL");
         }
      }
      return;
   }
   
   // Kiểm tra TP tổng
   CheckTotalProfit();
   
   // Nếu EA bị dừng sau khi kiểm tra TP tổng thì không quản lý lệnh
   if(eaStopped)
   {
      static int firstStopLog = 0;
      if(firstStopLog == 0)
      {
         Print("========================================");
         Print("EA đã được DỪNG sau khi kiểm tra TP tổng");
         Print("EA sẽ KHÔNG quản lý lệnh nữa");
         Print("========================================");
         firstStopLog = 1;
      }
      return;
   }
   
   // Kiểm tra Trading Stop, Step Tổng
   if(EnableTradingStopStepTotal)
   {
      if(!isTradingStopActive)
      {
         CheckTradingStopStepTotal();
      }
      else
      {
         ManageTradingStop();
      }
   }
   
   // Kiểm tra reset dựa trên lot và tổng phiên
   if(EnableLotBasedReset)
   {
      CheckLotBasedReset();
   }
   
   // Kiểm tra SL % so với tài khoản
   if(EnableAccountSLPercent)
   {
      CheckAccountSLPercent();
   }
   
   // Nếu EA bị dừng sau khi kiểm tra SL % thì không quản lý lệnh
   if(eaStopped)
   {
      static int firstStopLogSL = 0;
      if(firstStopLogSL == 0)
      {
         Print("========================================");
         Print("EA đã được DỪNG sau khi kiểm tra SL % so với tài khoản");
         Print("EA sẽ KHÔNG quản lý lệnh nữa");
         Print("========================================");
         firstStopLogSL = 1;
      }
      return;
   }
   
   // Kiểm tra giờ hoạt động
   bool hasOpenOrders = HasOpenOrders();
   
   // Logic: Nếu trong thời gian hoạt động HOẶC có lệnh đang mở thì cho phép chạy
   if(withinTradingHours || hasOpenOrders)
   {
      // Reset flag dừng do giờ hoạt động nếu đang trong giờ hoạt động hoặc có lệnh đang mở
      if((withinTradingHours || hasOpenOrders) && eaStoppedByTradingHours)
      {
         eaStoppedByTradingHours = false;
         if(hasOpenOrders && !withinTradingHours)
         {
            // Có lệnh đang mở nhưng ngoài giờ → EA vẫn tiếp tục chạy để quản lý lệnh
            static int firstLogAfterHours = 0;
            if(firstLogAfterHours == 0)
            {
               Print("========================================");
               Print("✓ EA VẪN CÒN LỆNH ĐANG MỞ - TIẾP TỤC HOẠT ĐỘNG");
               Print("EA sẽ tiếp tục quản lý lệnh cho đến khi reset tự động và không còn lệnh");
               Print("========================================");
               firstLogAfterHours = 1;
            }
         }
      }
      
      // Quản lý lệnh khi không ở chế độ Trading Stop
      if(!isTradingStopActive)
      {
         ManageGridOrders();
      }
   }
   else
   {
      // Ngoài thời gian hoạt động và không có lệnh đang mở
      // Đánh dấu EA dừng do giờ hoạt động (nhưng không set eaStopped = true để có thể tự động khởi động lại)
      if(!eaStoppedByTradingHours)
      {
         eaStoppedByTradingHours = true;
         Print("========================================");
         Print("⏳ NGOÀI GIỜ HOẠT ĐỘNG - EA TẠM DỪNG");
         MqlDateTime dt;
         TimeToStruct(TimeCurrent(), dt);
         Print("Giờ hiện tại: ", dt.hour, ":", (dt.min < 10 ? "0" : ""), dt.min);
         Print("Giờ bắt đầu: ", StartHour, ":", (StartMinute < 10 ? "0" : ""), StartMinute);
         Print("Giờ kết thúc: ", EndHour, ":", (EndMinute < 10 ? "0" : ""), EndMinute);
         Print("EA sẽ tự động khởi động lại khi vào giờ hoạt động");
         Print("========================================");
      }
      
      // Log mỗi 1000 tick để thông báo đang chờ giờ hoạt động
      static int waitHoursTickCount = 0;
      waitHoursTickCount++;
      if(waitHoursTickCount % 1000 == 0)
      {
         MqlDateTime dt;
         TimeToStruct(TimeCurrent(), dt);
         Print("⏳ Ngoài giờ hoạt động - EA đang chờ. Giờ hiện tại: ", dt.hour, ":", (dt.min < 10 ? "0" : ""), dt.min, " | Giờ bắt đầu: ", StartHour, ":", (StartMinute < 10 ? "0" : ""), StartMinute, " | Giờ kết thúc: ", EndHour, ":", (EndMinute < 10 ? "0" : ""), EndMinute);
      }
   }
   
   // Cập nhật thông tin theo dõi (mỗi 10 tick để giảm tải)
   static int tickCount = 0;
   tickCount++;
   if(tickCount % 10 == 0)
   {
      UpdateTrackingInfo();
      // Cập nhật tích lũy = Balance hiện tại - Balance ban đầu
      double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      accumulatedProfit = currentBalance - initialBalanceAtStart;
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra và xử lý TP tổng                                       |
//+------------------------------------------------------------------+
void CheckTotalProfit()
{
   // 1. Kiểm tra TP tổng lệnh đang mở
   if(TotalProfitTPOpen > 0)
   {
      double openProfit = GetTotalOpenProfit();
      // Debug: In thông tin mỗi 100 tick để kiểm tra
      static int tickCount = 0;
      tickCount++;
      if(tickCount % 100 == 0)
      {
         Print("Debug - TP Tổng lệnh mở: ", openProfit, " / ", TotalProfitTPOpen, " USD");
      }
      
      if(openProfit >= TotalProfitTPOpen)
      {
         Print("========================================");
         Print("=== ĐẠT TP TỔNG LỆNH MỞ: ", openProfit, " USD ===");
         Print("========================================");
         if(ActionOnTotalProfitOpen == TP_ACTION_RESET_EA)
         {
            ResetEA("TP Tổng Lệnh Mở");
         }
         else
         {
            Print("EA sẽ DỪNG HOẠT ĐỘNG (không reset)");
            Print("Lưu ý: EA dừng do đạt TP sẽ KHÔNG tự động khởi động lại, kể cả khi vào giờ hoạt động");
            StopEA();
         }
         return; // Dừng kiểm tra các TP khác
      }
   }
   
   // 2. Kiểm tra TP tổng phiên
   // TP tổng phiên = Vốn hiện tại - Vốn ban đầu (tính lãi)
   // Vốn hiện tại = Equity (Balance + Floating Profit/Loss)
   if(TotalProfitTPSession > 0)
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // Vốn hiện tại (Balance + Floating)
      double totalSessionProfit = currentEquity - initialEquity;  // Profit phiên = Vốn hiện tại - Vốn ban đầu (lãi)
      
      // Debug: In thông tin mỗi 100 tick để kiểm tra
      static int tickCountSession = 0;
      tickCountSession++;
      if(tickCountSession % 100 == 0)
      {
         Print("Debug - TP Tổng phiên: ", totalSessionProfit, " USD (Vốn hiện tại: ", currentEquity, " - Vốn ban đầu: ", initialEquity, ") / ", TotalProfitTPSession, " USD");
         Print("  - So sánh: ", totalSessionProfit, " >= ", TotalProfitTPSession, " ? ", (totalSessionProfit >= TotalProfitTPSession ? "TRUE" : "FALSE"));
         Print("  - ActionOnTotalProfitSession = ", ActionOnTotalProfitSession, " (0=Dừng EA, 1=Reset EA)");
      }
      
      // Kiểm tra điều kiện - In log khi gần đạt TP (trong vòng 5 USD)
      if(totalSessionProfit >= (TotalProfitTPSession - 5.0) && totalSessionProfit < TotalProfitTPSession)
      {
         Print("⚠ GẦN ĐẠT TP TỔNG PHIÊN: ", totalSessionProfit, " / ", TotalProfitTPSession, " USD");
      }
      
      // Kiểm tra điều kiện
      if(totalSessionProfit >= TotalProfitTPSession)
      {
         Print("========================================");
         Print("=== ĐẠT TP TỔNG PHIÊN: ", totalSessionProfit, " USD ===");
         Print("  - Vốn ban đầu: ", initialEquity, " USD");
         Print("  - Vốn hiện tại: ", currentEquity, " USD");
         Print("  - Tổng phiên (Hiện tại - Ban đầu): ", totalSessionProfit, " USD");
         Print("  - Mục tiêu: ", TotalProfitTPSession, " USD");
         Print("  - ActionOnTotalProfitSession = ", ActionOnTotalProfitSession);
         Print("========================================");
         
         if(ActionOnTotalProfitSession == TP_ACTION_RESET_EA)
         {
            Print("Hành động: RESET EA");
            ResetEA("TP Tổng Phiên");
         }
         else if(ActionOnTotalProfitSession == TP_ACTION_STOP_EA)
         {
            Print("Hành động: DỪNG EA");
            Print("Lưu ý: EA dừng do đạt TP sẽ KHÔNG tự động khởi động lại, kể cả khi vào giờ hoạt động");
            StopEA();
         }
         else
         {
            Print("⚠ LỖI: ActionOnTotalProfitSession không hợp lệ: ", ActionOnTotalProfitSession);
         }
         return; // Dừng kiểm tra các TP khác
      }
   }
   
   // 3. Kiểm tra TP tổng tích lũy
   // Tổng tích lũy = Balance hiện tại - Balance ban đầu khi EA khởi động
   if(TotalProfitTPAccumulated > 0)
   {
      double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      double totalAccumulated = currentBalance - initialBalanceAtStart;  // Tích lũy = số dư tăng lên
      if(totalAccumulated >= TotalProfitTPAccumulated)
      {
         Print("========================================");
         Print("=== ĐẠT TP TỔNG TÍCH LŨY: ", totalAccumulated, " USD ===");
         Print("EA sẽ DỪNG HOẠT ĐỘNG VĨNH VIỄN");
         Print("Lưu ý: EA dừng do đạt TP sẽ KHÔNG tự động khởi động lại, kể cả khi vào giờ hoạt động");
         Print("========================================");
         StopEA();
      }
   }
}

//+------------------------------------------------------------------+
//| Tính tổng profit của các lệnh đang mở (floating profit/loss)    |
//+------------------------------------------------------------------+
double GetTotalOpenProfit()
{
   double totalProfit = 0.0;
   
   // Duyệt qua tất cả positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            // Cộng profit và swap của mỗi position (có thể dương hoặc âm)
            totalProfit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         }
      }
   }
   
   return totalProfit;
}

//+------------------------------------------------------------------+
//| Tính tổng lãi của lệnh Buy ĐANG MỞ (cả dương và âm)            |
//+------------------------------------------------------------------+
double GetBuyProfitTotal()
{
   double totalBuyProfit = 0.0;
   
   // Duyệt qua tất cả positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double positionProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            
            // Tính TẤT CẢ lệnh Buy (cả dương và âm)
            if(posType == POSITION_TYPE_BUY)
            {
               totalBuyProfit += positionProfit;
            }
         }
      }
   }
   
   return totalBuyProfit;
}

//+------------------------------------------------------------------+
//| Tính tổng lãi của lệnh Sell ĐANG MỞ (cả dương và âm)            |
//+------------------------------------------------------------------+
double GetSellProfitTotal()
{
   double totalSellProfit = 0.0;
   
   // Duyệt qua tất cả positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double positionProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
            
            // Tính TẤT CẢ lệnh Sell (cả dương và âm)
            if(posType == POSITION_TYPE_SELL)
            {
               totalSellProfit += positionProfit;
            }
         }
      }
   }
   
   return totalSellProfit;
}

//+------------------------------------------------------------------+
//| Reset EA - Khởi động lại tại giá mới                             |
//+------------------------------------------------------------------+
void ResetEA(string resetReason = "Thủ công")
{
   Print("=== RESET EA ===");
   Print("Lý do reset: ", resetReason);
   
   // Đánh dấu đang trong quá trình reset
   isResetting = true;
   
   // Tính profit của phiên hiện tại
   // Profit phiên = Vốn hiện tại - Vốn ban đầu (lãi)
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double totalSessionProfit = currentEquity - initialEquity;
   
   // Tính tích lũy = Balance hiện tại - Balance ban đầu khi EA khởi động lần đầu
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double accumulatedProfitBefore = accumulatedProfit; // Lưu tích lũy trước reset
   accumulatedProfit = currentBalance - initialBalanceAtStart; // Tích lũy = số dư tăng lên từ khi EA khởi động
   double profitThisReset = accumulatedProfit - accumulatedProfitBefore; // Profit của lần reset này
   
   Print("Profit phiên trước reset: ", totalSessionProfit, " USD");
   Print("  - Vốn ban đầu: ", initialEquity, " USD");
   Print("  - Vốn hiện tại: ", currentEquity, " USD");
   Print("  - Số dư ban đầu (khi EA khởi động): ", initialBalanceAtStart, " USD");
   Print("  - Số dư hiện tại: ", currentBalance, " USD");
   // Tăng số lần reset
   resetCount++;
   
   Print("Tích lũy trước reset: ", accumulatedProfitBefore, " USD");
   Print("Tích lũy mới (số dư tăng): ", accumulatedProfit, " USD");
   Print("Profit lần reset này: ", profitThisReset, " USD");
   Print("Số lần tích lũy: ", resetCount);
   
   // Đóng tất cả pending orders
   CloseAllPendingOrders();
   
   // Đóng tất cả positions đang mở
   CloseAllOpenPositions();
   
   // Đợi một chút để các lệnh đóng hoàn tất
   Sleep(500);
   
   // Tắt flag reset
   isResetting = false;
   
   // Reset basePrice tại giá mới
   basePrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Reset grid levels
   InitializeGridLevels();
   
   // Reset lot sizes đã lưu
   ZeroMemory(gridLotSizes);
   
   // Reset phiên về 0 và cập nhật vốn ban đầu mới
   sessionProfit = 0.0;  // Reset tổng phiên về 0
   sessionStartTime = TimeCurrent();
   
   // Cập nhật vốn ban đầu mới (sau khi đóng tất cả lệnh)
   double oldInitialEquity = initialEquity;
   double oldInitialBalance = initialBalance;
   initialEquity = AccountInfoDouble(ACCOUNT_EQUITY);  // Vốn mới khi EA khởi động lại
   initialBalance = AccountInfoDouble(ACCOUNT_BALANCE);  // Số dư mới khi EA khởi động lại
   minEquity = initialEquity;  // Reset vốn thấp nhất về vốn ban đầu mới
   // KHÔNG reset maxNegativeProfit và balanceAtMaxLoss - giữ lại để theo dõi lịch sử
   // KHÔNG reset maxLotEver và totalLotEver - giữ lại để theo dõi lịch sử
   
   // Đảm bảo EA tiếp tục hoạt động sau khi reset
   eaStopped = false;
   
   // Kiểm tra giờ hoạt động sau khi reset
   // Nếu ngoài giờ hoạt động và không còn lệnh nào → dừng do giờ hoạt động
   bool withinTradingHoursAfterReset = IsWithinTradingHours();
   bool hasOpenOrdersAfterReset = HasOpenOrders();
   
   if(EnableTradingHours && !withinTradingHoursAfterReset && !hasOpenOrdersAfterReset)
   {
      // Ngoài giờ hoạt động và không có lệnh → dừng do giờ hoạt động
      eaStoppedByTradingHours = true;
      Print("========================================");
      Print("⏳ SAU KHI RESET - NGOÀI GIỜ HOẠT ĐỘNG VÀ KHÔNG CÓ LỆNH");
      Print("EA sẽ tạm dừng và tự động khởi động lại khi vào giờ hoạt động");
      MqlDateTime dt;
      TimeToStruct(TimeCurrent(), dt);
      Print("Giờ hiện tại: ", dt.hour, ":", (dt.min < 10 ? "0" : ""), dt.min);
      Print("Giờ bắt đầu: ", StartHour, ":", (StartMinute < 10 ? "0" : ""), StartMinute);
      Print("Giờ kết thúc: ", EndHour, ":", (EndMinute < 10 ? "0" : ""), EndMinute);
      Print("========================================");
   }
   else
   {
      // Trong giờ hoạt động hoặc có lệnh đang mở → tiếp tục chạy
      eaStoppedByTradingHours = false;
   }
   
   // Reset biến Trading Stop
   isTradingStopActive = false;
   pointA = 0.0;
   initialPointA = 0.0;
   lastPriceForStep = 0.0;
   initialPriceForStop = 0.0;
   firstStepDone = false;
   
   
   Print("EA đã reset tại giá mới: ", basePrice);
   Print("--- Reset phiên ---");
   Print("  - Vốn ban đầu cũ: ", oldInitialEquity, " USD");
   Print("  - Vốn ban đầu mới: ", initialEquity, " USD");
   Print("  - Tổng phiên đã reset về: 0 USD");
   Print("Phiên mới đã bắt đầu - Tổng phiên sẽ tính lại từ vốn ban đầu mới");
   
   // Gửi thông báo về điện thoại nếu được bật
   if(EnableResetNotification)
   {
      SendResetNotification(resetReason, accumulatedProfitBefore, profitThisReset, accumulatedProfit, resetCount);
   }
}

//+------------------------------------------------------------------+
//| Dừng EA - Đóng tất cả lệnh và xóa pending orders                |
//+------------------------------------------------------------------+
void StopEA()
{
   Print("========================================");
   Print("=== DỪNG EA ===");
   Print("Đang đóng tất cả lệnh...");
   
   // Đóng tất cả pending orders
   int pendingCount = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            if(trade.OrderDelete(ticket))
               pendingCount++;
         }
      }
   }
   Print("Đã xóa ", pendingCount, " pending orders");
   
   // Đóng tất cả positions đang mở
   int positionCount = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            if(trade.PositionClose(ticket))
               positionCount++;
         }
      }
   }
   Print("Đã đóng ", positionCount, " positions");
   
   // Set flag dừng EA (dừng do TP/SL hoặc lý do khác, không phải do giờ hoạt động)
   // LƯU Ý: EA dừng do TP/SL sẽ KHÔNG tự động khởi động lại, kể cả khi vào giờ hoạt động
   eaStopped = true;
   eaStoppedByTradingHours = false; // Reset flag dừng do giờ hoạt động vì đây là dừng vĩnh viễn
   
   Print("EA đã DỪNG - Không quản lý lệnh nữa");
   Print("Lưu ý: EA dừng do đạt TP/SL sẽ KHÔNG tự động khởi động lại");
   Print("========================================");
}

//+------------------------------------------------------------------+
//| Đóng tất cả positions đang mở                                    |
//+------------------------------------------------------------------+
void CloseAllOpenPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            trade.PositionClose(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Tính profit/loss của position đã đóng (realized profit/loss)     |
//+------------------------------------------------------------------+
double CalculateClosedPositionProfit(ulong positionId)
{
   double totalProfit = 0.0;
   
   if(HistorySelectByPosition(positionId))
   {
      int totalDeals = HistoryDealsTotal();
      
      for(int i = 0; i < totalDeals; i++)
      {
         ulong dealTicket = HistoryDealGetTicket(i);
         if(dealTicket > 0)
         {
            long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
            string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
            
            if(dealMagic == MagicNumber && dealSymbol == _Symbol)
            {
               totalProfit += HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
               totalProfit += HistoryDealGetDouble(dealTicket, DEAL_SWAP);
               totalProfit += HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
            }
         }
      }
   }
   
   return totalProfit;
}

//+------------------------------------------------------------------+
//| Đóng tất cả pending orders                                       |
//+------------------------------------------------------------------+
void CloseAllPendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            trade.OrderDelete(ticket);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Trade transaction handler                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                       const MqlTradeRequest& request,
                       const MqlTradeResult& result)
{
   // Chỉ xử lý khi position đóng
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      // Kiểm tra xem có phải position đóng do TP không
      if(HistoryDealSelect(trans.deal))
      {
         long reason = HistoryDealGetInteger(trans.deal, DEAL_REASON);
         
         // Xử lý khi position đóng do TP hoặc SL
         if(reason == DEAL_REASON_TP || reason == DEAL_REASON_SL || reason == DEAL_REASON_SO)
         {
            // Lấy thông tin position đã đóng
            long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
            
            if(magic == MagicNumber && symbol == _Symbol)
            {
               // Lấy Position ID từ deal
               ulong positionId = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
               
               // Tính profit của position đã đóng (có thể lãi hoặc lỗ)
               double positionProfit = CalculateClosedPositionProfit(positionId);
               
               // Nếu đang trong quá trình reset, không cộng vào sessionProfit
               // (profit đã được tính vào tích lũy khi reset)
               if(!isResetting)
               {
                  // Cộng profit/loss của lệnh đã đóng vào tổng phiên
                  sessionProfit += positionProfit;
               }
               
               Print("Position đóng - Lý do: ", reason == DEAL_REASON_TP ? "TP" : (reason == DEAL_REASON_SL ? "SL" : "SO"), 
                     " | Profit: ", positionProfit, " USD | Tổng phiên: ", sessionProfit, " USD");
            }
         }
         
         // Chỉ xử lý logic bổ sung lệnh khi đạt TP
         if(reason == DEAL_REASON_TP)
         {
            // Lấy thông tin position đã đóng
            long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            string symbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
            
            if(magic == MagicNumber && symbol == _Symbol)
            {
               // Lấy Position ID từ deal
               ulong positionId = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);
               
               // Lấy thông tin position từ History
               if(HistorySelectByPosition(positionId))
               {
                  int totalDeals = HistoryDealsTotal();
                  double lotSize = 0;
                  double priceOpen = 0;
                  ENUM_ORDER_TYPE orderType = WRONG_VALUE;
                  
                  // Tìm deal mở position (deal đầu tiên)
                  for(int i = 0; i < totalDeals; i++)
                  {
                     ulong dealTicket = HistoryDealGetTicket(i);
                     if(dealTicket > 0)
                     {
                        long dealType = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
                        if(dealType == DEAL_TYPE_BUY || dealType == DEAL_TYPE_SELL)
                        {
                           lotSize = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
                           priceOpen = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
                           
                           // Xác định loại lệnh dựa trên giá mở và giá hiện tại
                           double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                           
                           if(dealType == DEAL_TYPE_BUY)
                           {
                              // Buy Limit: giá mở < giá hiện tại, Buy Stop: giá mở > giá hiện tại
                              if(priceOpen < currentPrice)
                                 orderType = ORDER_TYPE_BUY_LIMIT;
                              else
                                 orderType = ORDER_TYPE_BUY_STOP;
                           }
                           else // DEAL_TYPE_SELL
                           {
                              // Sell Limit: giá mở > giá hiện tại, Sell Stop: giá mở < giá hiện tại
                              if(priceOpen > currentPrice)
                                 orderType = ORDER_TYPE_SELL_LIMIT;
                              else
                                 orderType = ORDER_TYPE_SELL_STOP;
                           }
                           break;
                        }
                     }
                  }
                  
                  // Tìm mức lưới tương ứng
                  if(orderType != WRONG_VALUE && priceOpen > 0 && lotSize > 0)
                  {
                     int levelNumber = GetGridLevelNumber(priceOpen);
                     if(levelNumber > 0)
                     {
                        // Lưu lot size cho mức lưới này
                        SaveLotSizeForLevel(orderType, levelNumber, lotSize);
                        
                        Print("✓ Position đạt TP - Mức ", levelNumber, " | ", EnumToString(orderType), " | Lot: ", lotSize, " | Giá mở: ", priceOpen);
                        
                        // Nếu AutoRefillOrders được bật, bổ sung lệnh lại
                        if(AutoRefillOrders)
                        {
                           // Đợi một chút để đảm bảo position đã đóng hoàn toàn
                           Sleep(100);
                           double levelPrice = GetLevelPrice(levelNumber, orderType);
                           if(levelPrice > 0)
                           {
                              EnsureOrderAtLevel(orderType, levelPrice, levelNumber);
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Khởi tạo các level giá cố định cho lưới                        |
//+------------------------------------------------------------------+
void InitializeGridLevels()
{
   double gridDistance = GridDistancePips * pnt * 10.0;
   int totalLevels = MaxGridLevels * 2 + 1; // Cả 2 phía + giá cơ sở
   
   ArrayResize(gridLevels, totalLevels);
   ArrayResize(gridLevelIndex, totalLevels);
   
   int index = 0;
   
   // Level phía trên giá cơ sở (mức 1 là gần nhất, MaxGridLevels là xa nhất)
   for(int i = 1; i <= MaxGridLevels; i++)
   {
      gridLevels[index] = NormalizeDouble(basePrice + (i * gridDistance), dgt);
      gridLevelIndex[index] = i; // Mức lưới: 1, 2, 3... MaxGridLevels
      index++;
   }
   
   // Level giá cơ sở (không dùng, nhưng giữ để tương thích)
   gridLevels[index] = NormalizeDouble(basePrice, dgt);
   gridLevelIndex[index] = 0;
   index++;
   
   // Level phía dưới giá cơ sở (mức 1 là gần nhất, MaxGridLevels là xa nhất)
   for(int i = 1; i <= MaxGridLevels; i++)
   {
      gridLevels[index] = NormalizeDouble(basePrice - (i * gridDistance), dgt);
      gridLevelIndex[index] = i; // Mức lưới: 1, 2, 3... MaxGridLevels
      index++;
   }
   
   Print("Đã khởi tạo ", totalLevels, " grid levels");
}

//+------------------------------------------------------------------+
//| Quản lý hệ thống lưới                                           |
//+------------------------------------------------------------------+
void ManageGridOrders()
{
   // Nếu EA đã dừng thì không quản lý lệnh
   if(eaStopped)
      return;
   
   // Nếu EA đang dừng do giờ hoạt động và không có lệnh đang mở thì không đặt lệnh mới
   // LƯU Ý: Nếu có lệnh đang mở thì EA vẫn tiếp tục quản lý lệnh, kể cả khi ngoài giờ hoạt động
   if(EnableTradingHours && eaStoppedByTradingHours && !HasOpenOrders())
      return;
   
   // Nếu đang ở chế độ Trading Stop thì không đặt lệnh mới
   if(isTradingStopActive)
      return;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Duyệt qua tất cả các level và đảm bảo có lệnh
   for(int i = 0; i < ArraySize(gridLevels); i++)
   {
      double level = gridLevels[i];
      
      // Bỏ qua level quá gần giá hiện tại
      double minDistance = GridDistancePips * pnt * 5.0;
      if(MathAbs(level - currentPrice) < minDistance)
         continue;
      
      // Quyết định loại lệnh dựa trên vị trí level so với giá hiện tại
      // Chỉ đặt lệnh nếu loại lệnh đó được bật trong input
      int levelNumber = gridLevelIndex[i]; // Mức lưới: 1, 2, 3...
      
      if(level > currentPrice)
      {
         // Level phía trên giá hiện tại - chỉ đặt Buy Stop và/hoặc Sell Limit nếu được bật
         if(EnableBuyStop)
            EnsureOrderAtLevel(ORDER_TYPE_BUY_STOP, level, levelNumber);
         if(EnableSellLimit)
            EnsureOrderAtLevel(ORDER_TYPE_SELL_LIMIT, level, levelNumber);
      }
      else if(level < currentPrice)
      {
         // Level phía dưới giá hiện tại - chỉ đặt Buy Limit và/hoặc Sell Stop nếu được bật
         if(EnableBuyLimit)
            EnsureOrderAtLevel(ORDER_TYPE_BUY_LIMIT, level, levelNumber);
         if(EnableSellStop)
            EnsureOrderAtLevel(ORDER_TYPE_SELL_STOP, level, levelNumber);
      }
   }
}

//+------------------------------------------------------------------+
//| Đảm bảo có lệnh tại level - tạo nếu chưa có                    |
//+------------------------------------------------------------------+
void EnsureOrderAtLevel(ENUM_ORDER_TYPE orderType, double priceLevel, int levelNumber)
{
   // Nếu EA đã dừng thì không đặt lệnh
   if(eaStopped)
      return;
   
   // Nếu đang ở chế độ Trading Stop thì không đặt lệnh mới
   if(isTradingStopActive)
      return;
   
   // Kiểm tra xem đã có lệnh hoặc position tại level này chưa
   if(OrderOrPositionExistsAtLevel(orderType, priceLevel))
      return;
   
   // Kiểm tra cân bằng lưới
   if(!CanPlaceOrderAtLevel(orderType, priceLevel))
      return;
   
   // Đặt lệnh mới với mức lưới
   PlacePendingOrder(orderType, priceLevel, levelNumber);
}

//+------------------------------------------------------------------+
//| Kiểm tra có lệnh hoặc position tại level không                 |
//+------------------------------------------------------------------+
bool OrderOrPositionExistsAtLevel(ENUM_ORDER_TYPE orderType, double priceLevel)
{
   double tolerance = GridDistancePips * pnt * 5.0;
   bool isBuyOrder = (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP);
   
   // Kiểm tra pending orders
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
            if(MathAbs(orderPrice - priceLevel) < tolerance)
            {
               ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
               bool isOrderBuy = (ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP);
               
               if(isBuyOrder == isOrderBuy)
                  return true;
            }
         }
      }
   }
   
   // Kiểm tra positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            if(MathAbs(posPrice - priceLevel) < tolerance)
            {
               ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               bool isPosBuy = (pt == POSITION_TYPE_BUY);
               
               if(isBuyOrder == isPosBuy)
                  return true;
            }
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có trong thời gian hoạt động không                |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
   if(!EnableTradingHours)
      return true; // Nếu không bật giờ hoạt động thì luôn cho phép
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   int currentMinutes = dt.hour * 60 + dt.min;
   int startMinutes = StartHour * 60 + StartMinute;
   int endMinutes = EndHour * 60 + EndMinute;
   
   // Xử lý trường hợp thời gian kết thúc nhỏ hơn thời gian bắt đầu (qua đêm)
   if(endMinutes < startMinutes)
   {
      // Thời gian hoạt động qua đêm (ví dụ: 22:00 - 06:00)
      return (currentMinutes >= startMinutes || currentMinutes <= endMinutes);
   }
   else
   {
      // Thời gian hoạt động trong cùng một ngày
      return (currentMinutes >= startMinutes && currentMinutes <= endMinutes);
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra xem có lệnh đang mở không (positions hoặc pending orders) |
//+------------------------------------------------------------------+
bool HasOpenOrders()
{
   // Kiểm tra positions đang mở
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            return true;
         }
      }
   }
   
   // Kiểm tra pending orders
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Kiểm tra có thể đặt lệnh tại level không (cân bằng lưới)       |
//+------------------------------------------------------------------+
bool CanPlaceOrderAtLevel(ENUM_ORDER_TYPE orderType, double priceLevel)
{
   double tolerance = GridDistancePips * pnt * 5.0;
   bool isBuyOrder = (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP);
   
   int buyCount = 0;
   int sellCount = 0;
   
   // Đếm pending orders tại level này
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
      {
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber && 
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
            if(MathAbs(orderPrice - priceLevel) < tolerance)
            {
               ENUM_ORDER_TYPE ot = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
               if(ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP)
                  buyCount++;
               else if(ot == ORDER_TYPE_SELL_LIMIT || ot == ORDER_TYPE_SELL_STOP)
                  sellCount++;
            }
         }
      }
   }
   
   // Đếm positions tại level này
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && 
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double posPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            if(MathAbs(posPrice - priceLevel) < tolerance)
            {
               ENUM_POSITION_TYPE pt = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               if(pt == POSITION_TYPE_BUY)
                  buyCount++;
               else if(pt == POSITION_TYPE_SELL)
                  sellCount++;
            }
         }
      }
   }
   
   // Kiểm tra cân bằng: mỗi level tối đa 1 Buy và 1 Sell
   if(isBuyOrder && buyCount >= 1)
      return false;
   if(!isBuyOrder && sellCount >= 1)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Đặt lệnh chờ với TP                                            |
//+------------------------------------------------------------------+
void PlacePendingOrder(ENUM_ORDER_TYPE orderType, double priceLevel, int levelNumber)
{
   double price = NormalizeDouble(priceLevel, dgt);
   double lotSize = 0;
   double tp = 0;
   bool enableMartingale = false;
   double martingaleMultiplier = 1.0;
   int martingaleStartLevel = 1;
   
   // Xác định Lot Size và Take Profit dựa trên loại lệnh
   if(orderType == ORDER_TYPE_BUY_LIMIT)
   {
      lotSize = LotSizeBuyLimit;
      enableMartingale = EnableMartingaleBuyLimit;
      martingaleMultiplier = MartingaleMultiplierBuyLimit;
      martingaleStartLevel = MartingaleStartLevelBuyLimit;
      if(TakeProfitPipsBuyLimit > 0)
         tp = NormalizeDouble(price + TakeProfitPipsBuyLimit * pnt * 10.0, dgt);
   }
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
   {
      lotSize = LotSizeSellLimit;
      enableMartingale = EnableMartingaleSellLimit;
      martingaleMultiplier = MartingaleMultiplierSellLimit;
      martingaleStartLevel = MartingaleStartLevelSellLimit;
      if(TakeProfitPipsSellLimit > 0)
         tp = NormalizeDouble(price - TakeProfitPipsSellLimit * pnt * 10.0, dgt);
   }
   else if(orderType == ORDER_TYPE_BUY_STOP)
   {
      lotSize = LotSizeBuyStop;
      enableMartingale = EnableMartingaleBuyStop;
      martingaleMultiplier = MartingaleMultiplierBuyStop;
      martingaleStartLevel = MartingaleStartLevelBuyStop;
      if(TakeProfitPipsBuyStop > 0)
         tp = NormalizeDouble(price + TakeProfitPipsBuyStop * pnt * 10.0, dgt);
   }
   else if(orderType == ORDER_TYPE_SELL_STOP)
   {
      lotSize = LotSizeSellStop;
      enableMartingale = EnableMartingaleSellStop;
      martingaleMultiplier = MartingaleMultiplierSellStop;
      martingaleStartLevel = MartingaleStartLevelSellStop;
      if(TakeProfitPipsSellStop > 0)
         tp = NormalizeDouble(price - TakeProfitPipsSellStop * pnt * 10.0, dgt);
   }
   
   // Kiểm tra xem có lot size đã lưu cho mức lưới này không (từ lệnh TP trước đó)
   double savedLotSize = GetSavedLotSize(orderType, levelNumber);
   if(savedLotSize > 0)
   {
      // Sử dụng lot size đã lưu (từ lệnh đạt TP trước đó)
      lotSize = savedLotSize;
      Print("  → Sử dụng lot size đã lưu: ", lotSize, " cho mức ", levelNumber);
   }
   else
   {
      // Tính toán lot size với gấp thếp mới
      // Nếu levelNumber < martingaleStartLevel: dùng lot cố định
      // Nếu levelNumber >= martingaleStartLevel: tính gấp thếp
      // Ví dụ: martingaleStartLevel = 3
      //   Bậc 1, 2: lotSize (cố định)
      //   Bậc 3: lotSize * multiplier^1
      //   Bậc 4: lotSize * multiplier^2
      //   Bậc n: lotSize * multiplier^(n - martingaleStartLevel + 1)
      if(enableMartingale && levelNumber >= martingaleStartLevel && martingaleMultiplier > 0)
      {
         int exponent = levelNumber - martingaleStartLevel + 1;
         double multiplier = MathPow(martingaleMultiplier, exponent);
         lotSize = NormalizeDouble(lotSize * multiplier, 2);
      }
   }
   
   // Đặt lệnh (không có Stop Loss)
   bool result = false;
   if(orderType == ORDER_TYPE_BUY_LIMIT)
      result = trade.BuyLimit(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
      result = trade.SellLimit(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   else if(orderType == ORDER_TYPE_BUY_STOP)
      result = trade.BuyStop(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   else if(orderType == ORDER_TYPE_SELL_STOP)
      result = trade.SellStop(lotSize, price, _Symbol, 0, tp, ORDER_TIME_GTC, 0, CommentOrder);
   
   if(result)
   {
      string martingaleInfo = "";
      if(enableMartingale && levelNumber >= martingaleStartLevel)
      {
         int exponent = levelNumber - martingaleStartLevel + 1;
         double multiplierValue = MathPow(martingaleMultiplier, exponent);
         martingaleInfo = " | Mức " + IntegerToString(levelNumber) + " (x" + DoubleToString(multiplierValue, 2) + ", bắt đầu từ bậc " + IntegerToString(martingaleStartLevel) + ")";
      }
      Print("✓ Đã đặt lệnh: ", EnumToString(orderType), " tại ", price, " | Lot: ", lotSize, " | TP: ", tp, martingaleInfo);
   }
   else
   {
      Print("✗ Lỗi đặt lệnh: ", EnumToString(orderType), " | Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Lưu lot size cho mức lưới khi đạt TP                            |
//+------------------------------------------------------------------+
void SaveLotSizeForLevel(ENUM_ORDER_TYPE orderType, int levelNumber, double lotSize)
{
   if(levelNumber < 1 || levelNumber >= 50)
      return;
   
   int index = levelNumber - 1; // Mảng bắt đầu từ 0
   
   if(orderType == ORDER_TYPE_BUY_LIMIT)
      gridLotSizes.lotSizeBuyLimit[index] = lotSize;
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
      gridLotSizes.lotSizeSellLimit[index] = lotSize;
   else if(orderType == ORDER_TYPE_BUY_STOP)
      gridLotSizes.lotSizeBuyStop[index] = lotSize;
   else if(orderType == ORDER_TYPE_SELL_STOP)
      gridLotSizes.lotSizeSellStop[index] = lotSize;
}

//+------------------------------------------------------------------+
//| Lấy lot size đã lưu cho mức lưới                                |
//+------------------------------------------------------------------+
double GetSavedLotSize(ENUM_ORDER_TYPE orderType, int levelNumber)
{
   if(levelNumber < 1 || levelNumber >= 50)
      return 0;
   
   int index = levelNumber - 1;
   
   if(orderType == ORDER_TYPE_BUY_LIMIT)
      return gridLotSizes.lotSizeBuyLimit[index];
   else if(orderType == ORDER_TYPE_SELL_LIMIT)
      return gridLotSizes.lotSizeSellLimit[index];
   else if(orderType == ORDER_TYPE_BUY_STOP)
      return gridLotSizes.lotSizeBuyStop[index];
   else if(orderType == ORDER_TYPE_SELL_STOP)
      return gridLotSizes.lotSizeSellStop[index];
   
   return 0;
}

//+------------------------------------------------------------------+
//| Lấy số mức lưới từ giá                                          |
//+------------------------------------------------------------------+
int GetGridLevelNumber(double price)
{
   double tolerance = GridDistancePips * pnt * 5.0;
   
   for(int i = 0; i < ArraySize(gridLevels); i++)
   {
      if(MathAbs(gridLevels[i] - price) < tolerance)
      {
         return gridLevelIndex[i];
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Lấy giá của mức lưới theo số mức và loại lệnh                  |
//+------------------------------------------------------------------+
double GetLevelPrice(int levelNumber, ENUM_ORDER_TYPE orderType)
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < ArraySize(gridLevels); i++)
   {
      if(gridLevelIndex[i] == levelNumber)
      {
         double level = gridLevels[i];
         
         // Kiểm tra xem level có phù hợp với loại lệnh không
         if(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_SELL_STOP)
         {
            if(level < currentPrice)
               return level;
         }
         else if(orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_SELL_LIMIT)
         {
            if(level > currentPrice)
               return level;
         }
      }
   }
   
   return 0;
}

//+------------------------------------------------------------------+
//| Kiểm tra điều kiện kích hoạt Trading Stop, Step Tổng           |
//+------------------------------------------------------------------+
void CheckTradingStopStepTotal()
{
   // Kiểm tra theo chế độ đã chọn
   if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
   {
      // Chế độ: Theo lệnh mở
      if(TradingStopStepTotalProfit <= 0)
         return;
      
      double currentProfit = GetTotalOpenProfit();
      if(currentProfit >= TradingStopStepTotalProfit)
      {
         // Tính tổng lãi Buy và Sell để chọn hướng
         double buyProfit = GetBuyProfitTotal();
         double sellProfit = GetSellProfitTotal();
         bool chosenBuy = (buyProfit >= sellProfit);
         
         Print("========================================");
         Print("=== KÍCH HOẠT TRADING STOP, STEP TỔNG ===");
         Print("Chế độ: Theo lệnh mở");
         Print("Tổng lãi lệnh đang mở: ", currentProfit, " USD");
         Print("Mức kích hoạt: ", TradingStopStepTotalProfit, " USD");
         Print("Tổng lãi lệnh Buy (cả dương và âm): ", buyProfit, " USD");
         Print("Tổng lãi lệnh Sell (cả dương và âm): ", sellProfit, " USD");
         Print("Ưu tiên hướng: ", chosenBuy ? "BUY" : "SELL", " (lãi hơn)");
         Print("========================================");
         
         ActivateTradingStop(chosenBuy);
      }
   }
   else if(TradingStopStepMode == TRADING_STOP_MODE_SESSION)
   {
      // Chế độ: Theo phiên
      if(TradingStopStepSessionProfit <= 0)
         return;
      
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      double currentProfit = currentEquity - initialEquity;  // Lãi phiên = Vốn hiện tại - Vốn ban đầu
      
      if(currentProfit >= TradingStopStepSessionProfit)
      {
         // Tính tổng lãi Buy và Sell ĐANG MỞ để chọn hướng
         double buyProfit = GetBuyProfitTotal();
         double sellProfit = GetSellProfitTotal();
         bool chosenBuy = (buyProfit >= sellProfit);
         
         Print("========================================");
         Print("=== KÍCH HOẠT TRADING STOP, STEP TỔNG ===");
         Print("Chế độ: Theo phiên");
         Print("Tổng lãi phiên: ", currentProfit, " USD");
         Print("Mức kích hoạt: ", TradingStopStepSessionProfit, " USD");
         Print("Tổng lãi lệnh Buy ĐANG MỞ (cả dương và âm): ", buyProfit, " USD");
         Print("Tổng lãi lệnh Sell ĐANG MỞ (cả dương và âm): ", sellProfit, " USD");
         Print("Ưu tiên hướng: ", chosenBuy ? "BUY" : "SELL", " (lãi hơn)");
         Print("========================================");
         
         ActivateTradingStop(chosenBuy);
      }
   }
   else if(TradingStopStepMode == TRADING_STOP_MODE_BOTH)
   {
      // Chế độ: Tổ hợp cả 2 - ưu tiên cái đạt trước
      if(TradingStopStepTotalProfit <= 0 || TradingStopStepSessionProfit <= 0)
         return;
      
      double openProfit = GetTotalOpenProfit();
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      double sessionProfit = currentEquity - initialEquity;
      
      // Kiểm tra xem cái nào đạt trước
      bool openReached = (openProfit >= TradingStopStepTotalProfit);
      bool sessionReached = (sessionProfit >= TradingStopStepSessionProfit);
      
      if(openReached || sessionReached)
      {
         // Tính tổng lãi Buy và Sell để chọn hướng
         double buyProfit = GetBuyProfitTotal();
         double sellProfit = GetSellProfitTotal();
         bool chosenBuy = (buyProfit >= sellProfit);
         
         Print("========================================");
         Print("=== KÍCH HOẠT TRADING STOP, STEP TỔNG ===");
         Print("Chế độ: Tổ hợp cả 2 (ưu tiên cái đạt trước)");
         Print("Tổng lãi lệnh đang mở: ", openProfit, " USD (ngưỡng: ", TradingStopStepTotalProfit, " USD) - ", (openReached ? "ĐẠT" : "Chưa đạt"));
         Print("Tổng lãi phiên: ", sessionProfit, " USD (ngưỡng: ", TradingStopStepSessionProfit, " USD) - ", (sessionReached ? "ĐẠT" : "Chưa đạt"));
         if(openReached && sessionReached)
            Print("Cả 2 điều kiện đều đạt - Kích hoạt");
         else if(openReached)
            Print("Điều kiện lệnh mở đạt trước - Kích hoạt");
         else
            Print("Điều kiện phiên đạt trước - Kích hoạt");
         Print("Tổng lãi lệnh Buy (cả dương và âm): ", buyProfit, " USD");
         Print("Tổng lãi lệnh Sell (cả dương và âm): ", sellProfit, " USD");
         Print("Ưu tiên hướng: ", chosenBuy ? "BUY" : "SELL", " (lãi hơn)");
         Print("========================================");
         
         ActivateTradingStop(chosenBuy);
      }
   }
}

//+------------------------------------------------------------------+
//| Kích hoạt Trading Stop - Xóa lệnh chờ gần giá → xóa TP → xóa lệnh chờ còn lại |
//| isBuyDirection: true = Buy, false = Sell                        |
//+------------------------------------------------------------------+
void ActivateTradingStop(bool isBuyDirection = true)
{
   isTradingStopActive = true;
   isTradingStopBuyDirection = isBuyDirection;
   firstStepDone = false;
   initialPriceForStop = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   lastPriceForStep = initialPriceForStop;
   
   // Thứ tự: 1) Xóa lệnh chờ gần giá hiện tại → 2) Xóa TP → 3) Xóa các lệnh chờ còn lại
   double currentPriceForActivate = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   Print("=== BƯỚC 1: XÓA LỆNH CHỜ GẦN GIÁ HIỆN TẠI ===");
   
   // Thu thập lệnh chờ: ticket và khoảng cách tới giá hiện tại
   ulong orderTickets[];
   double orderDistances[];
   ArrayResize(orderTickets, 0);
   ArrayResize(orderDistances, 0);
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0 &&
         OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
         OrderGetString(ORDER_SYMBOL) == _Symbol)
      {
         double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         double dist = MathAbs(orderPrice - currentPriceForActivate);
         int n = ArraySize(orderTickets);
         ArrayResize(orderTickets, n + 1);
         ArrayResize(orderDistances, n + 1);
         orderTickets[n] = ticket;
         orderDistances[n] = dist;
      }
   }
   
   // Sắp xếp theo khoảng cách tăng dần (gần giá nhất trước)
   for(int i = 0; i < ArraySize(orderTickets) - 1; i++)
   {
      for(int j = i + 1; j < ArraySize(orderTickets); j++)
      {
         if(orderDistances[j] < orderDistances[i])
         {
            ulong tmpTicket = orderTickets[i];
            double tmpDist = orderDistances[i];
            orderTickets[i] = orderTickets[j];
            orderDistances[i] = orderDistances[j];
            orderTickets[j] = tmpTicket;
            orderDistances[j] = tmpDist;
         }
      }
   }
   
   // 1. Chỉ xóa lệnh chờ gần giá hiện tại nhất (lệnh có khoảng cách nhỏ nhất)
   double minDist = (ArraySize(orderDistances) > 0) ? orderDistances[0] : -1;
   int closeCount = 0;
   for(int i = 0; i < ArraySize(orderTickets) && orderDistances[i] <= minDist; i++)
   {
      if(!trade.OrderDelete(orderTickets[i]))
         Print("⚠ Lỗi xóa lệnh chờ gần giá ", orderTickets[i], ": ", GetLastError());
      else
      {
         Print("  ✓ Đã xóa lệnh chờ gần giá Ticket ", orderTickets[i], " (", orderDistances[i] / pnt / 10.0, " pips)");
         closeCount++;
      }
   }
   
   Print("=== BƯỚC 2: XÓA TP CÁC LỆNH ĐANG MỞ ===");
   // 2. Xóa TP của tất cả lệnh đang mở
   int tpCount = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
         PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         double currentTP = PositionGetDouble(POSITION_TP);
         if(currentTP > 0)
         {
            double currentSL = PositionGetDouble(POSITION_SL);
            if(!trade.PositionModify(ticket, currentSL, 0))
               Print("⚠ Lỗi xóa TP cho position ", ticket, ": ", GetLastError());
            else
            {
               Print("  ✓ Đã xóa TP cho lệnh Ticket ", ticket);
               tpCount++;
            }
         }
      }
   }
   
   Print("=== BƯỚC 3: XÓA CÁC LỆNH CHỜ CÒN LẠI ===");
   // 3. Xóa các lệnh chờ còn lại (xa giá hơn)
   int remainingCount = 0;
   for(int i = closeCount; i < ArraySize(orderTickets); i++)
   {
      if(!trade.OrderDelete(orderTickets[i]))
         Print("⚠ Lỗi xóa lệnh chờ còn lại ", orderTickets[i], ": ", GetLastError());
      else
      {
         Print("  ✓ Đã xóa lệnh chờ còn lại Ticket ", orderTickets[i], " (", orderDistances[i] / pnt / 10.0, " pips)");
         remainingCount++;
      }
   }
   Print("✓ Hoàn tất: Xóa ", closeCount, " lệnh chờ gần giá → Xóa TP ", tpCount, " lệnh → Xóa ", remainingCount, " lệnh chờ còn lại");
   
   // 3. Tính tổng lệnh BUY và SELL để log
   double totalBuyProfit = GetBuyProfitTotal();
   double totalSellProfit = GetSellProfitTotal();
   Print("Tổng lệnh BUY (cả dương và âm): ", totalBuyProfit, " USD | Tổng lệnh SELL (cả dương và âm): ", totalSellProfit, " USD");
   Print("Hướng được chọn: ", isBuyDirection ? "BUY" : "SELL", " (lãi hơn)");
   
   // 4. Tìm lệnh dương gần giá nhất TRONG HƯỚNG ĐƯỢC CHỌN và tính điểm A
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double nearestProfitPrice = 0.0;
   double minDistance = DBL_MAX;
   bool foundProfitPosition = false;
   Print("=== Tìm lệnh dương gần giá hiện tại nhất trong hướng ", (isBuyDirection ? "BUY" : "SELL"), " ===");
   Print("Giá hiện tại khi đạt ngưỡng: ", currentPrice);
   
   Print("--- Bước 3: Tìm lệnh DƯƠNG gần giá hiện tại nhất TRONG HƯỚNG ", (isBuyDirection ? "BUY" : "SELL"), " ---");
   Print("Lưu ý: Chỉ tìm lệnh DƯƠNG (đang lãi) trong hướng được chọn, bỏ qua lệnh âm và lệnh hướng ngược lại");
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            bool isBuy = (posType == POSITION_TYPE_BUY);
            
            // Tìm lệnh dương gần giá nhất TRONG HƯỚNG ĐƯỢC CHỌN
            // Điều kiện: (hướng được chọn là Buy VÀ lệnh là Buy VÀ lệnh dương) HOẶC (hướng được chọn là Sell VÀ lệnh là Sell VÀ lệnh dương)
            if((isBuyDirection && isBuy && positionProfit > 0) || (!isBuyDirection && !isBuy && positionProfit > 0))
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               double distance = MathAbs(openPrice - currentPrice);
               
               Print("  ✓ Lệnh ", (isBuy ? "BUY" : "SELL"), " DƯƠNG: Ticket ", ticket, " | Giá mở: ", openPrice, " | Lãi: ", positionProfit, " USD | Khoảng cách từ giá hiện tại: ", distance / pnt / 10.0, " pips");
               
               // Tìm lệnh dương gần giá nhất (khoảng cách nhỏ nhất)
               if(distance < minDistance)
               {
                  minDistance = distance;
                  nearestProfitPrice = openPrice;
                  foundProfitPosition = true;
                  Print("    → ĐƯỢC CHỌN: Lệnh dương gần giá hiện tại nhất trong hướng ", (isBuyDirection ? "BUY" : "SELL"), " (khoảng cách: ", distance / pnt / 10.0, " pips)");
               }
            }
         }
      }
   }
   
   Print("========================================");
   
   if(!foundProfitPosition)
   {
      Print("⚠ Không tìm thấy lệnh ", (isBuyDirection ? "Buy" : "Sell"), " dương nào để gồng lãi");
      isTradingStopActive = false;
      return;
   }
   
   // 4. Tính điểm A: từ lệnh dương gần giá nhất TRONG HƯỚNG ĐƯỢC CHỌN
   Print("--- Bước 3: Tính điểm A từ lệnh dương gần giá nhất trong hướng ", (isBuyDirection ? "BUY" : "SELL"), " ---");
   double pointADistance = TradingStopStepPointA * pnt * 10.0;
   
   if(isBuyDirection)
   {
      // Buy: điểm A = giá lệnh Buy dương gần nhất + X pips (phía trên)
      pointA = NormalizeDouble(nearestProfitPrice + pointADistance, dgt);
      Print("  - Công thức: Điểm A = Giá lệnh Buy dương gần nhất + ", TradingStopStepPointA, " pips");
      Print("  - Điểm A = ", nearestProfitPrice, " + ", TradingStopStepPointA, " pips = ", pointA);
   }
   else
   {
      // Sell: điểm A = giá lệnh Sell dương gần nhất - X pips (phía dưới)
      pointA = NormalizeDouble(nearestProfitPrice - pointADistance, dgt);
      Print("  - Công thức: Điểm A = Giá lệnh Sell dương gần nhất - ", TradingStopStepPointA, " pips");
      Print("  - Điểm A = ", nearestProfitPrice, " - ", TradingStopStepPointA, " pips = ", pointA);
   }
   
   Print("========================================");
   Print("✓ ĐÃ TÍNH ĐIỂM A THÀNH CÔNG");
   Print("  - Hướng được chọn: ", (isBuyDirection ? "BUY" : "SELL"));
   Print("  - Giá hiện tại khi đạt ngưỡng: ", currentPrice);
   Print("  - Lệnh dương gần giá nhất: ", (isBuyDirection ? "BUY" : "SELL"), " tại giá ", nearestProfitPrice);
   Print("  - Khoảng cách từ giá hiện tại đến lệnh dương: ", minDistance / pnt / 10.0, " pips");
   Print("  - Điểm A cách lệnh dương: ", TradingStopStepPointA, " pips");
   Print("  - Điểm A = ", pointA);
   Print("  - Đã xóa TP của TẤT CẢ lệnh (CẢ BUY VÀ SELL, cả dương và âm)");
   Print("  - Khi giá đi đến điểm A + ", TradingStopStepSize, " pips sẽ đặt SL tại điểm A cho TẤT CẢ lệnh ", (isBuyDirection ? "BUY" : "SELL"));
   Print("  - SAU KHI đặt SL xong sẽ đóng TẤT CẢ lệnh ", (isBuyDirection ? "SELL" : "BUY"), " (lệnh ngược hướng)");
   Print("  - KHÔNG đóng lệnh ngay khi kích hoạt - chỉ xóa lệnh chờ và xóa TP");
}

//+------------------------------------------------------------------+
//| Quản lý Trading Stop - Đóng lệnh âm, di chuyển SL theo step    |
//+------------------------------------------------------------------+
void ManageTradingStop()
{
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double stepDistance = TradingStopStepSize * pnt * 10.0;
   
   // Kiểm tra nếu chưa hoàn thành step đầu tiên và tổng lãi giảm xuống
   if(!firstStepDone)
   {
      double currentProfit = 0.0;
      double threshold = 0.0;
      string profitType = "";
      bool shouldCheckReturn = false;
      
      // Tính tổng lãi theo chế độ đã chọn
      if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
      {
         // Chế độ: Theo lệnh mở
         currentProfit = GetTotalOpenProfit();
         threshold = TradingStopStepTotalProfit;
         profitType = "lệnh đang mở";
         shouldCheckReturn = true;
      }
      else if(TradingStopStepMode == TRADING_STOP_MODE_SESSION)
      {
         // Chế độ: Theo phiên
         double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
         currentProfit = currentEquity - initialEquity;  // Lãi phiên = Vốn hiện tại - Vốn ban đầu
         threshold = TradingStopStepSessionProfit;
         profitType = "phiên";
         shouldCheckReturn = true;
      }
      else if(TradingStopStepMode == TRADING_STOP_MODE_BOTH)
      {
         // Chế độ: Tổ hợp cả 2 - kiểm tra cả 2 điều kiện
         double openProfit = GetTotalOpenProfit();
         double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
         double sessionProfit = currentEquity - initialEquity;
         
         // Kiểm tra xem cả 2 điều kiện có còn đạt không
         bool openStillReached = (openProfit >= TradingStopStepTotalProfit);
         bool sessionStillReached = (sessionProfit >= TradingStopStepSessionProfit);
         
         // Nếu cả 2 điều kiện đều không đạt nữa, kiểm tra ngưỡng quay lại
         if(!openStillReached && !sessionStillReached)
         {
            // Kiểm tra xem có điều kiện nào >= ngưỡng quay lại tương ứng không
            if(openProfit >= TradingStopStepReturnProfitOpen || sessionProfit >= TradingStopStepReturnProfitSession)
            {
               // Vẫn ở chế độ Trading Stop, chỉ log
               static int logCount = 0;
               logCount++;
               if(logCount % 100 == 0)
               {
                  Print("Trading Stop đang chờ - Lệnh mở: ", openProfit, " USD, Phiên: ", sessionProfit, " USD");
               }
            }
            else
            {
               // Cả 2 điều kiện đều < ngưỡng quay lại → Hủy Trading Stop
               Print("========================================");
               Print("=== HỦY TRADING STOP - TỔNG LÃI GIẢM ===");
               Print("Chế độ: Tổ hợp cả 2");
               Print("Tổng lãi lệnh mở: ", openProfit, " USD (ngưỡng: ", TradingStopStepTotalProfit, " USD)");
               Print("Tổng lãi phiên: ", sessionProfit, " USD (ngưỡng: ", TradingStopStepSessionProfit, " USD)");
               Print("Ngưỡng quay lại (lệnh mở): ", TradingStopStepReturnProfitOpen, " USD");
               Print("Ngưỡng quay lại (phiên): ", TradingStopStepReturnProfitSession, " USD");
               Print("EA sẽ khôi phục lại bình thường");
               Print("========================================");
               
               // Khôi phục TP cho các lệnh dương
               RestoreTPForProfitPositions();
               
               // Hủy chế độ Trading Stop
               isTradingStopActive = false;
               pointA = 0.0;
               initialPointA = 0.0;
               lastPriceForStep = 0.0;
               initialPriceForStop = 0.0;
               firstStepDone = false;
               
               // EA sẽ tự động bổ sung lại lệnh chờ khi ManageGridOrders() chạy
               return;
            }
         }
         // Nếu ít nhất 1 điều kiện vẫn đạt, tiếp tục chế độ Trading Stop
         shouldCheckReturn = false;
      }
      
      // Kiểm tra ngưỡng quay lại cho chế độ OPEN hoặc SESSION
      if(shouldCheckReturn && currentProfit < threshold)
      {
         // Xác định ngưỡng quay lại tương ứng
         double returnThreshold = 0.0;
         if(TradingStopStepMode == TRADING_STOP_MODE_OPEN)
         {
            returnThreshold = TradingStopStepReturnProfitOpen;
         }
         else if(TradingStopStepMode == TRADING_STOP_MODE_SESSION)
         {
            returnThreshold = TradingStopStepReturnProfitSession;
         }
         
         // Nếu >= ngưỡng quay lại, tiếp tục chế độ Trading Stop
         if(currentProfit >= returnThreshold)
         {
            // Vẫn ở chế độ Trading Stop, chỉ log
            static int logCount = 0;
            logCount++;
            if(logCount % 100 == 0)
            {
               Print("Trading Stop đang chờ - Tổng lãi ", profitType, ": ", currentProfit, " USD (ngưỡng: ", threshold, " USD)");
            }
         }
         else
         {
            // Tổng lãi < ngưỡng quay lại → Hủy Trading Stop, khôi phục bình thường
            Print("========================================");
            Print("=== HỦY TRADING STOP - TỔNG LÃI GIẢM ===");
            string modeText = (TradingStopStepMode == TRADING_STOP_MODE_OPEN) ? "Theo lệnh mở" : "Theo phiên";
            Print("Chế độ: ", modeText);
            Print("Tổng lãi ", profitType, " hiện tại: ", currentProfit, " USD");
            Print("Ngưỡng quay lại: ", returnThreshold, " USD");
            Print("EA sẽ khôi phục lại bình thường");
            Print("========================================");
            
            // Khôi phục TP cho các lệnh dương
            RestoreTPForProfitPositions();
            
            // Hủy chế độ Trading Stop
            isTradingStopActive = false;
            pointA = 0.0;
            initialPointA = 0.0;
            lastPriceForStep = 0.0;
            initialPriceForStop = 0.0;
            firstStepDone = false;
            
            // EA sẽ tự động bổ sung lại lệnh chờ khi ManageGridOrders() chạy
            return;
         }
      }
   }
   
   // Lưu điểm A ban đầu khi hoàn thành step đầu tiên
   if(!firstStepDone)
   {
      // initialPointA sẽ được set sau khi đặt SL lần đầu
   }
   
   // 1. Step đầu tiên: Khi giá đi đến điểm A + 1 step
   //    → Đặt SL tại điểm A cho TẤT CẢ lệnh cùng hướng, đóng hết lệnh ngược còn lại, bắt đầu gồng lãi
   if(!firstStepDone)
   {
      double targetPrice = 0.0;
      bool shouldSetSL = false;
      
      if(!isTradingStopBuyDirection) // Sell
      {
         // Với Sell: giá đi xuống đến điểm A - 1 step
         // Điểm A ở phía dưới, nên giá cần <= điểm A - 1 step
         targetPrice = NormalizeDouble(pointA - stepDistance, dgt);
         if(currentPrice <= targetPrice)
         {
            shouldSetSL = true;
            Print("=== ĐIỀU KIỆN ĐẠT: Giá đi đến A - 1 step ===");
            Print("  - Điểm A: ", pointA);
            Print("  - Giá hiện tại: ", currentPrice, " <= ", targetPrice, " (A - 1 step)");
            Print("  - Sẽ đặt SL tại điểm A cho TẤT CẢ lệnh ", (isTradingStopBuyDirection ? "BUY" : "SELL"), ", sau đó đóng lệnh ngược hướng");
         }
      }
      else
      {
         // Với Buy: giá đi lên đến điểm A + 1 step
         // Điểm A ở phía trên, nên giá cần >= điểm A + 1 step
         targetPrice = NormalizeDouble(pointA + stepDistance, dgt);
         if(currentPrice >= targetPrice)
         {
            shouldSetSL = true;
            Print("=== ĐIỀU KIỆN ĐẠT: Giá đi đến A + 1 step ===");
            Print("  - Điểm A: ", pointA);
            Print("  - Giá hiện tại: ", currentPrice, " >= ", targetPrice, " (A + 1 step)");
            Print("  - Sẽ đặt SL tại điểm A cho TẤT CẢ lệnh ", (isTradingStopBuyDirection ? "BUY" : "SELL"), ", sau đó đóng lệnh ngược hướng");
         }
      }
      
      if(shouldSetSL)
      {
         Print("=== BƯỚC 1: ĐẶT SL TẠI ĐIỂM A ===");
         // Đặt SL tại điểm A cho TẤT CẢ lệnh cùng hướng
         SetSLToPointAForAllPositions(isTradingStopBuyDirection);
         
         Print("=== BƯỚC 2: ĐÓNG TẤT CẢ LỆNH NGƯỢC HƯỚNG ===");
         // Đóng hết lệnh ngược còn lại
         CloseAllOppositePositions(isTradingStopBuyDirection);
         
         Print("=== BƯỚC 3: BẮT ĐẦU GỒNG LÃI ===");
         firstStepDone = true;
         initialPointA = pointA; // Lưu điểm A ban đầu để tính trailing
         lastPriceForStep = targetPrice; // Lưu giá tại step 1
         Print("✓ Đã đặt SL tại điểm A (", pointA, ") và đóng lệnh ngược hướng - Bắt đầu gồng lãi");
         Print("  - Điểm A ban đầu: ", initialPointA);
         Print("  - Khi giá đi đến A + 2step, SL sẽ được dịch lên A + 1step");
      }
   }
   else
   {
      // 2. Các step tiếp theo: Dịch SL theo giá (chỉ khi giá di chuyển theo hướng có lợi)
      double priceChange = 0.0;
      double newSL = pointA;
      bool shouldUpdateSL = false;
      
      if(!isTradingStopBuyDirection) // Sell
      {
         // Với Sell: CHỈ dịch SL xuống khi giá đi xuống thêm 1 step
         // KHÔNG dịch SL khi giá đi lên
         priceChange = lastPriceForStep - currentPrice; // Giá đi xuống → priceChange > 0
         
         if(priceChange >= stepDistance)
         {
            // Giá đi xuống thêm 1 step → dịch SL xuống 1 step
            newSL = NormalizeDouble(pointA - stepDistance, dgt);
            shouldUpdateSL = true;
            
            Print("=== STEP TIẾP: Giá đi xuống thêm ", TradingStopStepSize, " pips - Dịch SL xuống ===");
            Print("  - Giá cũ: ", lastPriceForStep);
            Print("  - Giá mới: ", currentPrice);
            Print("  - Khoảng cách: ", priceChange / pnt / 10.0, " pips");
            Print("  - SL cũ: ", pointA);
            Print("  - SL mới: ", newSL, " (dịch xuống ", TradingStopStepSize, " pips)");
         }
         else if(currentPrice > lastPriceForStep)
         {
            // Giá đi lên → KHÔNG dịch SL, chỉ log
            static int logCountSell = 0;
            logCountSell++;
            if(logCountSell % 100 == 0)
            {
               Print("  - Giá đi lên (", currentPrice, " > ", lastPriceForStep, ") - KHÔNG dịch SL (chờ giá đi xuống)");
            }
         }
      }
      else // Buy
      {
         // Với Buy: CHỈ dịch SL lên khi giá đi lên thêm 1 step
         // KHÔNG dịch SL khi giá đi xuống
         priceChange = currentPrice - lastPriceForStep; // Giá đi lên → priceChange > 0
         
         if(priceChange >= stepDistance)
         {
            // Giá đi lên thêm 1 step → dịch SL lên 1 step
            newSL = NormalizeDouble(pointA + stepDistance, dgt);
            shouldUpdateSL = true;
            
            Print("=== STEP TIẾP: Giá đi lên thêm ", TradingStopStepSize, " pips - Dịch SL lên ===");
            Print("  - Giá cũ: ", lastPriceForStep);
            Print("  - Giá mới: ", currentPrice);
            Print("  - Khoảng cách: ", priceChange / pnt / 10.0, " pips");
            Print("  - SL cũ: ", pointA);
            Print("  - SL mới: ", newSL, " (dịch lên ", TradingStopStepSize, " pips)");
         }
         else if(currentPrice < lastPriceForStep)
         {
            // Giá đi xuống → KHÔNG dịch SL, chỉ log
            static int logCountBuy = 0;
            logCountBuy++;
            if(logCountBuy % 100 == 0)
            {
               Print("  - Giá đi xuống (", currentPrice, " < ", lastPriceForStep, ") - KHÔNG dịch SL (chờ giá đi lên)");
            }
         }
      }
      
      // Cập nhật SL nếu cần
      if(shouldUpdateSL)
      {
         // Cập nhật SL cho TẤT CẢ lệnh cùng hướng
         pointA = newSL;
         UpdateSLForAllPositions(newSL, isTradingStopBuyDirection);
         
         // Cập nhật lastPriceForStep để theo dõi step tiếp theo
         lastPriceForStep = currentPrice;
         
         Print("✓ Đã dịch SL ", (isTradingStopBuyDirection ? "lên" : "xuống"), " ", newSL, " cho TẤT CẢ lệnh ", (isTradingStopBuyDirection ? "BUY" : "SELL"));
      }
      
      // Kiểm tra xem giá có quay đầu chạm SL không
      bool priceHitSL = false;
      if(!isTradingStopBuyDirection) // Sell
      {
         // Với Sell: giá tăng lên >= điểm A (SL)
         if(currentPrice >= pointA)
         {
            priceHitSL = true;
         }
      }
      else
      {
         // Với Buy: giá giảm xuống <= điểm A (SL)
         if(currentPrice <= pointA)
         {
            priceHitSL = true;
         }
      }
      
      if(priceHitSL)
      {
         Print("========================================");
         Print("=== GIÁ QUAY ĐẦU CHẠM SL ===");
         Print("Giá hiện tại: ", currentPrice);
         Print("Điểm A (SL): ", pointA);
         
         string actionText = "";
         if(ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA)
            actionText = "Reset EA";
         else if(ActionOnTradingStopStepComplete == TP_ACTION_STOP_EA)
            actionText = "Dừng EA";
         else
            actionText = "Khôi phục bình thường";
         
         Print("Hành động: ", actionText);
         Print("========================================");
         
         // Reset biến Trading Stop
         isTradingStopActive = false;
         pointA = 0.0;
         initialPointA = 0.0;
         lastPriceForStep = 0.0;
         initialPriceForStop = 0.0;
         firstStepDone = false;
         
         // Thực hiện hành động theo cài đặt
         if(ActionOnTradingStopStepComplete == TP_ACTION_RESET_EA)
         {
            // Reset EA - Mở lại từ đầu tại giá mới
            ResetEA("Trading Stop, Step Tổng");
         }
         else
         {
            // Dừng EA - Dừng hoàn toàn, không đặt lệnh nữa
            StopEA();
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Đóng tất cả lệnh âm (đang lỗ)                                   |
//+------------------------------------------------------------------+
void CloseNegativePositions()
{
   int closedCount = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ đóng lệnh âm (đang lỗ)
            if(positionProfit < 0)
            {
               if(trade.PositionClose(ticket))
               {
                  closedCount++;
                  Print("✓ Đã đóng lệnh âm: Ticket ", ticket, " | Profit: ", positionProfit, " USD");
               }
            }
         }
      }
   }
   
   Print("Đã đóng ", closedCount, " lệnh âm");
}

//+------------------------------------------------------------------+
//| Đặt SL tại điểm A cho tất cả lệnh dương                         |
//+------------------------------------------------------------------+
void SetSLToPointAForProfitPositions()
{
   int modifiedCount = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ set SL cho lệnh dương
            if(positionProfit > 0)
            {
               if(trade.PositionModify(ticket, pointA, 0))
               {
                  modifiedCount++;
                  Print("✓ Đã set SL tại điểm A (", pointA, ") cho position ", ticket);
               }
               else
               {
                  Print("⚠ Lỗi set SL cho position ", ticket, ": ", GetLastError());
               }
            }
         }
      }
   }
   
   Print("Đã set SL tại điểm A cho ", modifiedCount, " lệnh dương");
}

//+------------------------------------------------------------------+
//| Đặt SL tại điểm A cho TẤT CẢ lệnh cùng hướng (BUY hoặc Sell)   |
//+------------------------------------------------------------------+
void SetSLToPointAForAllPositions(bool isBuyDirection)
{
   int modifiedCount = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            bool isBuy = (posType == POSITION_TYPE_BUY);
            
            // Chỉ set SL cho lệnh cùng hướng
            if(isBuy == isBuyDirection)
            {
               if(trade.PositionModify(ticket, pointA, 0))
               {
                  modifiedCount++;
                  double positionProfit = PositionGetDouble(POSITION_PROFIT);
                  Print("✓ Đã set SL tại điểm A (", pointA, ") cho ", (isBuy ? "BUY" : "SELL"), " position ", ticket, " (Profit: ", positionProfit, " USD)");
               }
               else
               {
                  Print("⚠ Lỗi set SL cho position ", ticket, ": ", GetLastError());
               }
            }
         }
      }
   }
   
   Print("Đã set SL tại điểm A cho ", modifiedCount, " lệnh ", (isBuyDirection ? "BUY" : "SELL"), " (tất cả, không chỉ lệnh dương)");
}

//+------------------------------------------------------------------+
//| Cập nhật SL cho tất cả lệnh dương theo điểm A mới               |
//+------------------------------------------------------------------+
void UpdateSLForProfitPositions(double newSL)
{
   int modifiedCount = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ update SL cho lệnh dương
            if(positionProfit > 0)
            {
               if(trade.PositionModify(ticket, newSL, 0))
               {
                  modifiedCount++;
               }
            }
         }
      }
   }
   
   if(modifiedCount > 0)
   {
      Print("✓ Đã cập nhật SL cho ", modifiedCount, " lệnh dương tại ", newSL);
   }
}

//+------------------------------------------------------------------+
//| Cập nhật SL cho TẤT CẢ lệnh cùng hướng (BUY hoặc Sell)         |
//+------------------------------------------------------------------+
void UpdateSLForAllPositions(double newSL, bool isBuyDirection)
{
   int modifiedCount = 0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            bool isBuy = (posType == POSITION_TYPE_BUY);
            
            // Chỉ update SL cho lệnh cùng hướng
            if(isBuy == isBuyDirection)
            {
               if(trade.PositionModify(ticket, newSL, 0))
               {
                  modifiedCount++;
               }
            }
         }
      }
   }
   
   if(modifiedCount > 0)
   {
      Print("✓ Đã cập nhật SL cho ", modifiedCount, " lệnh ", (isBuyDirection ? "BUY" : "SELL"), " tại ", newSL, " (tất cả, không chỉ lệnh dương)");
   }
}

//+------------------------------------------------------------------+
//| Đóng hết lệnh ngược hướng còn lại (khi đặt SL)                 |
//+------------------------------------------------------------------+
void CloseAllOppositePositions(bool isBuyDirection)
{
   int closedCount = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            bool isBuy = (posType == POSITION_TYPE_BUY);
            
            // Chỉ đóng lệnh ngược hướng
            if(isBuy != isBuyDirection)
            {
               double positionProfit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
               if(trade.PositionClose(ticket))
               {
                  closedCount++;
                  Print("✓ Đã đóng lệnh ngược ", (isBuy ? "BUY" : "SELL"), ": Ticket ", ticket, " (Profit: ", positionProfit, " USD)");
               }
            }
         }
      }
   }
   
   if(closedCount > 0)
   {
      Print("✓ Đã đóng ", closedCount, " lệnh ngược hướng còn lại");
   }
   else
   {
      Print("✓ Không còn lệnh ngược hướng nào để đóng");
   }
}

//+------------------------------------------------------------------+
//| Khôi phục TP cho tất cả lệnh dương (khi hủy Trading Stop)       |
//+------------------------------------------------------------------+
void RestoreTPForProfitPositions()
{
   int restoredCount = 0;
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double positionProfit = PositionGetDouble(POSITION_PROFIT);
            
            // Chỉ khôi phục TP cho lệnh dương
            if(positionProfit > 0)
            {
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
               double tp = 0;
               
               // Xác định loại lệnh và tính TP tương ứng
               if(posType == POSITION_TYPE_BUY)
               {
                  // Buy Limit: giá mở < giá hiện tại
                  // Buy Stop: giá mở > giá hiện tại
                  if(openPrice < currentPrice)
                  {
                     // Buy Limit
                     if(TakeProfitPipsBuyLimit > 0)
                     {
                        tp = NormalizeDouble(openPrice + TakeProfitPipsBuyLimit * pnt * 10.0, dgt);
                     }
                  }
                  else
                  {
                     // Buy Stop
                     if(TakeProfitPipsBuyStop > 0)
                     {
                        tp = NormalizeDouble(openPrice + TakeProfitPipsBuyStop * pnt * 10.0, dgt);
                     }
                  }
               }
               else // POSITION_TYPE_SELL
               {
                  // Sell Limit: giá mở > giá hiện tại
                  // Sell Stop: giá mở < giá hiện tại
                  if(openPrice > currentPrice)
                  {
                     // Sell Limit
                     if(TakeProfitPipsSellLimit > 0)
                     {
                        tp = NormalizeDouble(openPrice - TakeProfitPipsSellLimit * pnt * 10.0, dgt);
                     }
                  }
                  else
                  {
                     // Sell Stop
                     if(TakeProfitPipsSellStop > 0)
                     {
                        tp = NormalizeDouble(openPrice - TakeProfitPipsSellStop * pnt * 10.0, dgt);
                     }
                  }
               }
               
               // Khôi phục TP (giữ nguyên SL hiện tại nếu có)
               double currentSL = PositionGetDouble(POSITION_SL);
               if(tp > 0)
               {
                  if(trade.PositionModify(ticket, currentSL, tp))
                  {
                     restoredCount++;
                     Print("✓ Đã khôi phục TP (", tp, ") cho position ", ticket);
                  }
                  else
                  {
                     Print("⚠ Lỗi khôi phục TP cho position ", ticket, ": ", GetLastError());
                  }
               }
            }
         }
      }
   }
   
   if(restoredCount > 0)
   {
      Print("Đã khôi phục TP cho ", restoredCount, " lệnh dương");
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra reset dựa trên lot và tổng phiên                       |
//+------------------------------------------------------------------+
void CheckLotBasedReset()
{
   // Kiểm tra các ngưỡng có được bật không
   if(MaxLotThreshold <= 0 || TotalLotThreshold <= 0 || SessionProfitForLotReset <= 0)
      return;
   
   // Tính lot lớn nhất và tổng lot của lệnh đang mở
   double maxLot = GetMaxLot();
   double totalLot = GetTotalLot();
   
   // Tính tổng phiên hiện tại
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double sessionProfit = currentEquity - initialEquity;
   
   // Kiểm tra điều kiện reset
   if(maxLot >= MaxLotThreshold && totalLot >= TotalLotThreshold && sessionProfit >= SessionProfitForLotReset)
   {
      Print("========================================");
      Print("=== RESET DỰA TRÊN LOT VÀ TỔNG PHIÊN ===");
      Print("Lot lớn nhất: ", maxLot, " (ngưỡng: ", MaxLotThreshold, ")");
      Print("Tổng lot: ", totalLot, " (ngưỡng: ", TotalLotThreshold, ")");
      Print("Tổng phiên: ", sessionProfit, " USD (ngưỡng: ", SessionProfitForLotReset, " USD)");
      Print("EA sẽ RESET và khởi động lại từ đầu tại giá mới");
      Print("========================================");
      
      ResetEA("Lot-based Reset");
   }
}

//+------------------------------------------------------------------+
//| Kiểm tra SL % so với tài khoản                                    |
//+------------------------------------------------------------------+
void CheckAccountSLPercent()
{
   // Kiểm tra nếu tính năng không được bật
   if(!EnableAccountSLPercent || AccountSLPercent <= 0)
      return;
   
   // Tính % lỗ so với số dư (Balance)
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Tính % lỗ so với số dư ban đầu: (initialBalance - currentBalance) / initialBalance * 100
   // Hoặc tính % lỗ floating: (Balance - Equity) / Balance * 100
   // Sử dụng cách tính % lỗ floating so với Balance hiện tại (phổ biến hơn)
   double lossAmount = currentBalance - currentEquity; // Số tiền lỗ floating (nếu dương thì đang lỗ)
   double lossPercent = 0.0;
   
   if(currentBalance > 0)
   {
      lossPercent = (lossAmount / currentBalance) * 100.0; // % lỗ so với số dư hiện tại
   }
   
   // Tính lot lớn nhất và tổng lot (nếu cần kiểm tra)
   double maxLot = 0.0;
   double totalLot = 0.0;
   bool checkLotCondition = (MaxLotForAccountSL > 0 || TotalLotForAccountSL > 0);
   
   if(checkLotCondition)
   {
      maxLot = GetMaxLot();
      totalLot = GetTotalLot();
   }
   
   // Kiểm tra điều kiện
   bool lotConditionMet = true;
   if(checkLotCondition)
   {
      // Nếu có điều kiện lot, kiểm tra cả hai (nếu được bật)
      if(MaxLotForAccountSL > 0 && maxLot < MaxLotForAccountSL)
         lotConditionMet = false;
      if(TotalLotForAccountSL > 0 && totalLot < TotalLotForAccountSL)
         lotConditionMet = false;
   }
   
   // Kiểm tra % lỗ đạt ngưỡng và điều kiện lot (nếu có)
   if(lossPercent >= AccountSLPercent && lotConditionMet)
   {
      Print("========================================");
      Print("=== SL % SO VỚI TÀI KHOẢN ĐẠT NGƯỠNG ===");
      Print("Số dư ban đầu: ", initialBalance, " USD");
      Print("Balance hiện tại: ", currentBalance, " USD");
      Print("Equity hiện tại: ", currentEquity, " USD");
      Print("Số tiền lỗ floating: ", lossAmount, " USD");
      Print("% lỗ so với số dư: ", lossPercent, "% (ngưỡng: ", AccountSLPercent, "%)");
      if(checkLotCondition)
      {
         Print("Lot lớn nhất: ", maxLot, (MaxLotForAccountSL > 0 ? " (ngưỡng: " + DoubleToString(MaxLotForAccountSL, 2) + ")" : " (không kiểm tra)"));
         Print("Tổng lot: ", totalLot, (TotalLotForAccountSL > 0 ? " (ngưỡng: " + DoubleToString(TotalLotForAccountSL, 2) + ")" : " (không kiểm tra)"));
      }
      
      // Đóng tất cả lệnh mở
      int closedPositions = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0)
         {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol)
            {
               if(trade.PositionClose(ticket))
                  closedPositions++;
            }
         }
      }
      Print("Đã đóng ", closedPositions, " lệnh mở");
      
      // Xóa tất cả lệnh chờ
      int deletedOrders = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket > 0)
         {
            if(OrderGetInteger(ORDER_MAGIC) == MagicNumber &&
               OrderGetString(ORDER_SYMBOL) == _Symbol)
            {
               if(trade.OrderDelete(ticket))
                  deletedOrders++;
            }
         }
      }
      Print("Đã xóa ", deletedOrders, " lệnh chờ");
      
      // Đợi một chút để các lệnh đóng hoàn tất
      Sleep(500);
      
      // Thực hiện hành động
      if(ActionOnAccountSL == TP_ACTION_STOP_EA)
      {
         Print("EA sẽ DỪNG hoàn toàn");
         Print("Lưu ý: EA dừng do đạt SL % sẽ KHÔNG tự động khởi động lại, kể cả khi vào giờ hoạt động");
         eaStopped = true;
         eaStoppedByTradingHours = false; // Reset flag dừng do giờ hoạt động vì đây là dừng vĩnh viễn
      }
      else if(ActionOnAccountSL == TP_ACTION_RESET_EA)
      {
         Print("EA sẽ RESET và khởi động lại từ đầu tại giá mới");
         ResetEA("Account SL % Reset");
      }
      
      Print("========================================");
   }
}

//+------------------------------------------------------------------+
//| Lấy lot lớn nhất của lệnh đang mở                                |
//+------------------------------------------------------------------+
double GetMaxLot()
{
   double maxLot = 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            double lotSize = PositionGetDouble(POSITION_VOLUME);
            if(lotSize > maxLot)
               maxLot = lotSize;
         }
      }
   }
   
   return maxLot;
}

//+------------------------------------------------------------------+
//| Lấy tổng lot của lệnh đang mở                                     |
//+------------------------------------------------------------------+
double GetTotalLot()
{
   double totalLot = 0.0;
   
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            totalLot += PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   
   return totalLot;
}

//+------------------------------------------------------------------+
//| Cập nhật thông tin theo dõi (không có panel)                     |
//+------------------------------------------------------------------+
void UpdateTrackingInfo()
{
   // Theo dõi vốn thấp nhất (khi lỗ lớn nhất)
   double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(minEquity == 0.0 || currentEquity < minEquity)
   {
      minEquity = currentEquity;
   }
   
   // Tính số âm lớn nhất của lệnh đang mở
   double currentOpenProfit = GetTotalOpenProfit();
   if(currentOpenProfit < maxNegativeProfit)
   {
      maxNegativeProfit = currentOpenProfit;
      balanceAtMaxLoss = AccountInfoDouble(ACCOUNT_BALANCE);  // Lưu số dư tại thời điểm có số âm lớn nhất
   }
   
   // Số lot lớn nhất (cập nhật giá trị lớn nhất từng có, không reset khi EA reset)
   double maxLot = GetMaxLot();
   if(maxLot > maxLotEver)
      maxLotEver = maxLot;
   
   // Tổng lot lớn nhất (cập nhật giá trị lớn nhất từng có, không reset khi EA reset)
   double totalLot = GetTotalLot();
   if(totalLot > totalLotEver)
      totalLotEver = totalLot;
}

//+------------------------------------------------------------------+
//| Format số tiền với K và M                                          |
//+------------------------------------------------------------------+
string FormatMoney(double amount)
{
   string result = "";
   double absAmount = MathAbs(amount);
   
   if(absAmount >= 1000000.0)
   {
      // Triệu (M)
      double mValue = absAmount / 1000000.0;
      result = DoubleToString(mValue, 2) + "M";
   }
   else if(absAmount >= 1000.0)
   {
      // Nghìn (K)
      double kValue = absAmount / 1000.0;
      result = DoubleToString(kValue, 2) + "K";
   }
   else
   {
      // Dưới 1000
      result = DoubleToString(absAmount, 2);
   }
   
   // Thêm dấu âm nếu cần
   if(amount < 0)
      result = "-" + result;
   
   return result + "$";
}

//+------------------------------------------------------------------+
//| Gửi thông báo về điện thoại khi EA reset                          |
//+------------------------------------------------------------------+
void SendResetNotification(string resetReason, double accumulatedBefore, double profitThisTime, double accumulatedAfter, int resetNumber)
{
   // 1. Biểu đồ
   string symbolName = _Symbol;
   
   // 2. EA Reset về chức năng gì
   string functionName = resetReason;
   
   // 3. Số dư hiện tại
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   string balanceText = FormatMoney(currentBalance);
   
   // 4. Số tiền lỗ lớn nhất / vốn (%)
   double maxLoss = maxNegativeProfit;
   double maxLossPercent = (balanceAtMaxLoss > 0) ? (MathAbs(maxLoss) / balanceAtMaxLoss * 100.0) : 0.0;
   string maxLossText = FormatMoney(maxLoss) + " / " + FormatMoney(balanceAtMaxLoss) + " (" + DoubleToString(maxLossPercent, 2) + "%)";
   
   // 5. Số lot lớn nhất / tổng lot lớn nhất
   string lotText = DoubleToString(maxLotEver, 2) + " / " + DoubleToString(totalLotEver, 2);
   
   // 6. Tích lũy với số lần
   string accumulatedText = "Tích lũy lần " + IntegerToString(resetNumber) + ": " + FormatMoney(accumulatedBefore) + " + " + FormatMoney(profitThisTime) + " = " + FormatMoney(accumulatedAfter);
   
   // Tạo nội dung thông báo
   string message = "EA RESET\n";
   message += "Biểu đồ: " + symbolName + "\n";
   message += "Chức năng: " + functionName + "\n";
   message += "Số dư: " + balanceText + "\n";
   message += accumulatedText + "\n";
   message += "Lỗ lớn nhất: " + maxLossText + "\n";
   message += "Lot: " + lotText;
   
   // Gửi thông báo
   SendNotification(message);
   
   Print("========================================");
   Print("Đã gửi thông báo về điện thoại:");
   Print(message);
   Print("========================================");
}
