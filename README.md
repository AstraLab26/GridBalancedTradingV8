# Grid Balanced Trading EA V8

> **File EA:** `GridBalancedTradingV8.mq5`

## 📋 Mô tả

**Grid Balanced Trading EA V8** là một Expert Advisor (EA) cho MetaTrader 5, sử dụng chiến lược Grid Trading với hệ thống cân bằng lưới tự động. EA khởi động ngay khi được gắn vào biểu đồ và tự động tạo lưới lệnh tại giá hiện tại.

### ✨ Tính năng chính

- ✅ **Grid Trading tự động**: Tự động tạo và quản lý lưới lệnh Buy Limit, Sell Limit, Buy Stop, Sell Stop
- ✅ **Cân bằng lưới**: Tự động cân bằng số lượng lệnh Buy và Sell tại mỗi mức giá
- ✅ **Martingale tùy chỉnh**: Hỗ trợ gấp thếp (Martingale) cho từng loại lệnh với hệ số và mức bắt đầu tùy chỉnh
- ✅ **Giờ hoạt động**: Thiết lập giờ hoạt động tùy chỉnh. EA đang chạy thì tiếp tục; EA đang tắt thì tự động khởi động lại khi vào giờ (lấy giá hiện tại làm gốc)
- ✅ **TP tổng**: 3 loại TP tổng (lệnh mở, phiên, tích lũy) với hành động Reset hoặc Dừng EA
- ✅ **Trading Stop Step (Gồng lãi)**: Trailing stop tự động khi đạt lãi nhất định
- ✅ **SL % tài khoản**: Bảo vệ tài khoản theo % lỗ
- ✅ **Reset tự động**: Reset EA khi đạt điều kiện, tiếp tục trading tại giá mới
- ✅ **Tự động bổ sung lệnh**: Tự động đặt lại lệnh khi lệnh đóng

---

## 🚀 Cài đặt

1. Copy file `GridBalancedTradingV8.mq5` vào thư mục `MQL5/Experts/` của MetaTrader 5
2. Khởi động lại MetaTrader 5 hoặc compile file trong MetaEditor
3. Kéo EA từ Navigator vào biểu đồ
4. Cấu hình các tham số theo nhu cầu
5. Bật nút "AutoTrading" trên thanh công cụ

---

## ⚙️ Hướng dẫn sử dụng

### Cấu hình cơ bản

1. **Cài đặt lưới**:
   - `GridDistancePips`: Khoảng cách giữa các mức lưới (pips)
   - `MaxGridLevels`: Số lượng mức lưới tối đa mỗi phía

2. **Chọn loại lệnh**: Bật/tắt các loại lệnh (Buy Limit, Sell Limit, Buy Stop, Sell Stop)

3. **Thiết lập lot size**: Đặt khối lượng cho từng loại lệnh

4. **Bật Martingale** (tùy chọn): Nếu muốn sử dụng chiến lược gấp thếp

5. **Thiết lập giờ hoạt động** (tùy chọn): Nếu muốn EA chỉ hoạt động trong khung giờ nhất định

---

## 📖 Chi tiết các tham số Input

### === CÀI ĐẶT LƯỚI ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `GridDistancePips` | 20.0 | Khoảng cách giữa các mức lưới (pips) |
| `MaxGridLevels` | 10 | Số lượng mức lưới tối đa mỗi phía (trên/dưới giá cơ sở) |
| `AutoRefillOrders` | true | Tự động bổ sung lệnh khi lệnh đóng |

### === CÀI ĐẶT LỆNH BUY LIMIT ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `EnableBuyLimit` | true | Bật/tắt lệnh Buy Limit |
| `LotSizeBuyLimit` | 0.01 | Khối lượng Buy Limit ở mức 1 |
| `TakeProfitPipsBuyLimit` | 30.0 | Take Profit (pips, 0 = tắt) |
| `EnableMartingaleBuyLimit` | false | Bật gấp thếp cho Buy Limit |
| `MartingaleMultiplierBuyLimit` | 2.0 | Hệ số gấp thếp (mức 2 = x2, mức 3 = x4, ...) |
| `MartingaleStartLevelBuyLimit` | 1 | Bắt đầu gấp thếp từ bậc lưới (1 = bậc 2, 2 = bậc 3, ...) |

**Lưu ý**: Các tham số tương tự cho **Sell Limit**, **Buy Stop**, và **Sell Stop**

### === TP TỔNG ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `TotalProfitTPOpen` | 0.0 | TP tổng lệnh đang mở (USD, 0 = tắt) |
| `ActionOnTotalProfitOpen` | Reset EA | Hành động khi đạt TP: Dừng EA hoặc Reset EA |
| `TotalProfitTPSession` | 0.0 | TP tổng phiên (USD, 0 = tắt) |
| `ActionOnTotalProfitSession` | Reset EA | Hành động khi đạt TP phiên |
| `TotalProfitTPAccumulated` | 0.0 | TP tổng tích lũy (USD, 0 = tắt) - Luôn dừng EA |

**Giải thích**:
- **TP lệnh mở**: Tổng profit của tất cả lệnh đang mở (floating)
- **TP phiên**: Profit từ khi bắt đầu phiên (tính từ Equity)
- **TP tích lũy**: Profit tích lũy từ khi EA khởi động lần đầu (tính từ Balance)

### === TRADING STOP, STEP TỔNG (GỒNG LÃI) ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `EnableTradingStopStepTotal` | false | Bật Trading Stop Step |
| `TradingStopStepMode` | Theo lệnh mở | Chế độ: Theo lệnh mở / Theo phiên / Cả 2 |
| `TradingStopStepTotalProfit` | 50.0 | Lãi tổng lệnh mở để kích hoạt (USD) |
| `TradingStopStepSessionProfit` | 50.0 | Lãi tổng phiên để kích hoạt (USD) |
| `TradingStopStepReturnProfitOpen` | 20.0 | Lãi quay lại để tiếp tục (USD) |
| `TradingStopStepReturnProfitSession` | 20.0 | Lãi phiên quay lại để tiếp tục (USD) |
| `TradingStopStepPointA` | 10.0 | Điểm A cách lệnh dương thấp nhất (pips) |
| `TradingStopStepSize` | 5.0 | Step pips để di chuyển SL (pips) |
| `ActionOnTradingStopStepComplete` | Dừng EA | Hành động khi giá chạm SL: Dừng EA hoặc Reset EA |
| `EnableLotBasedReset` | false | Bật reset dựa trên lot và tổng phiên |
| `MaxLotThreshold` | 0.1 | Lot lớn nhất để kích hoạt reset (0 = tắt) |
| `TotalLotThreshold` | 1.0 | Tổng lot để kích hoạt reset (0 = tắt) |
| `SessionProfitForLotReset` | 50.0 | Tổng phiên để reset khi đạt điều kiện lot (USD) |

**Cách hoạt động**:
1. Khi đạt lãi nhất định → Chọn hướng có lãi cao hơn (Buy hoặc Sell), kích hoạt Trading Stop
2. **Thứ tự khi kích hoạt**:
   - **Bước 1**: Xóa lệnh chờ gần giá hiện tại nhất (ưu tiên lệnh dễ bị kích hoạt)
   - **Bước 2**: Xóa TP tất cả lệnh đang mở
   - **Bước 3**: Xóa các lệnh chờ còn lại
3. Tính điểm A từ lệnh dương gần giá nhất, đặt SL tại điểm A khi giá đi đến A ± 1 step
4. Đóng tất cả lệnh ngược hướng, bắt đầu gồng lãi
5. Khi giá di chuyển theo hướng có lợi → Di chuyển SL theo step (trailing stop)
6. Nếu lãi quay lại dưới ngưỡng → Hủy Trading Stop

### === SL % SO VỚI TÀI KHOẢN ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `EnableAccountSLPercent` | false | Bật SL % so với tài khoản |
| `AccountSLPercent` | 10.0 | % lỗ so với tài khoản để kích hoạt (%) |
| `MaxLotForAccountSL` | 0.0 | Lot lớn nhất để kích hoạt (0 = bỏ qua) |
| `TotalLotForAccountSL` | 0.0 | Tổng lot để kích hoạt (0 = bỏ qua) |
| `ActionOnAccountSL` | Dừng EA | Hành động khi đạt SL %: Dừng EA hoặc Reset EA |

**Lưu ý**: SL % được tính dựa trên số tiền lỗ floating so với Balance ban đầu.

### === GIỜ HOẠT ĐỘNG ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `EnableTradingHours` | false | Bật giờ hoạt động |
| `StartHour` | 0 | Giờ bắt đầu (0-23) |
| `StartMinute` | 0 | Phút bắt đầu (0-59) |
| `EndHour` | 23 | Giờ kết thúc (0-23) |
| `EndMinute` | 59 | Phút kết thúc (0-59) |

**Logic hoạt động**:
- **Vào giờ hoạt động**:
  - EA đang **chạy** (có lệnh) → Tiếp tục chạy bình thường, **không** khởi động lại, **không** thay đổi giá cơ sở
  - EA đang **tắt** (không còn lệnh) → Tự động khởi động lại, lấy **giá hiện tại làm giá cơ sở mới**, tạo lưới mới
  - EA đã **dừng do TP/SL** → Vẫn dừng, **không** tự động khởi động lại
- **Ngoài giờ hoạt động**:
  - EA đang chạy (có lệnh) → Tiếp tục quản lý lệnh, **không** đặt lệnh mới, chờ reset tự động hoặc đóng hết lệnh
  - EA đang chạy (không còn lệnh) → Tạm dừng, chờ vào giờ để khởi động lại
  - Sau khi reset tự động, nếu ngoài giờ và không còn lệnh → EA tạm dừng

**Bảng tóm tắt**:

| Thời điểm | Trạng thái EA | Hành động |
|-----------|---------------|-----------|
| Vào giờ | Đang chạy (có lệnh) | Tiếp tục chạy, **không** khởi động lại |
| Vào giờ | Đang tắt (không còn lệnh) | Khởi động lại, lấy giá hiện tại làm gốc |
| Vào giờ | Dừng do TP/SL | Vẫn dừng |
| Ngoài giờ | Đang chạy (có lệnh) | Tiếp tục quản lý lệnh, không đặt lệnh mới |
| Ngoài giờ | Đang chạy (không còn lệnh) | Tạm dừng, chờ vào giờ |

**Lưu ý**: Hỗ trợ khung giờ qua đêm (ví dụ: 22:00 - 06:00). Chi tiết các tình huống xem file [TINH_HUONG_GIO_HOAT_DONG.md](TINH_HUONG_GIO_HOAT_DONG.md).

### === CÀI ĐẶT CHUNG ===

| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| `MagicNumber` | 123456 | Magic Number để nhận diện lệnh của EA |
| `CommentOrder` | "Grid Balanced V8" | Comment cho các lệnh |
| `EnableResetNotification` | false | Bật thông báo về điện thoại khi EA reset |

---

## 🔄 Logic hoạt động

### 1. Khởi động EA

- EA khởi động ngay khi được gắn vào biểu đồ
- Lấy giá hiện tại làm giá cơ sở (`basePrice`)
- Tạo lưới các mức giá dựa trên `GridDistancePips` và `MaxGridLevels`
- Đặt lệnh pending tại các mức giá phù hợp

### 2. Quản lý lưới

- **Cân bằng lưới**: Mỗi mức giá chỉ có tối đa 1 lệnh Buy và 1 lệnh Sell
- **Tự động bổ sung**: Khi lệnh đóng, EA tự động đặt lại lệnh tại mức đó
- **Martingale**: Tăng lot size theo hệ số tại các mức được chỉ định

### 3. Xử lý khi đạt TP tổng

- **Reset EA**: Đóng tất cả lệnh, reset về giá mới, tiếp tục trading
- **Dừng EA**: Đóng tất cả lệnh, EA dừng hoàn toàn (không tự động khởi động lại)

### 4. Giờ hoạt động

- **EA đang chạy** khi vào giờ → Tiếp tục chạy, **không** khởi động lại
- **EA đang tắt** (dừng do ngoài giờ, không còn lệnh) khi vào giờ → Khởi động lại, lấy giá hiện tại làm gốc, tạo lưới mới
- **EA dừng do TP/SL** → Không tự động khởi động lại, kể cả khi vào giờ
- **Ngoài giờ + còn lệnh** → Tiếp tục quản lý lệnh cho đến khi reset/không còn lệnh

### 5. Trading Stop Step (Gồng lãi)

- Khi đạt lãi nhất định → Chọn hướng lãi cao hơn (Buy/Sell), kích hoạt
- **Thứ tự**: Xóa lệnh chờ gần giá → Xóa TP → Xóa lệnh chờ còn lại
- Đặt SL tại điểm A, đóng lệnh ngược hướng
- Trailing stop tự động theo step khi giá đi theo hướng có lợi
- Nếu lãi quay lại dưới ngưỡng → Hủy Trading Stop

---

## ⚠️ Lưu ý quan trọng

1. **Rủi ro**: Grid Trading có thể tạo nhiều lệnh cùng lúc, cần quản lý vốn cẩn thận

2. **Martingale**: Chiến lược gấp thếp có rủi ro cao, chỉ nên sử dụng khi hiểu rõ

3. **Giờ hoạt động**: 
   - EA **đang chạy** khi vào giờ → Tiếp tục chạy, **không** khởi động lại
   - EA **đang tắt** (dừng do ngoài giờ) khi vào giờ → Tự động khởi động lại, lấy giá hiện tại làm gốc
   - EA dừng do TP/SL → **Không** tự động khởi động lại

4. **Magic Number**: Đảm bảo Magic Number khác nhau cho các EA khác nhau trên cùng một tài khoản

5. **Spread**: Xem xét spread khi thiết lập `GridDistancePips` để tránh lệnh bị kích hoạt ngay lập tức

6. **VPS**: Khuyến nghị sử dụng VPS để EA chạy 24/7

7. **Backtest**: Luôn backtest trước khi sử dụng trên tài khoản thật

---

## 📊 Ví dụ cấu hình

### Cấu hình cơ bản (Conservative)

```
GridDistancePips = 30.0
MaxGridLevels = 5
LotSizeBuyLimit = 0.01
LotSizeSellLimit = 0.01
EnableMartingale = false
TotalProfitTPSession = 50.0
ActionOnTotalProfitSession = Reset EA
```

### Cấu hình với Martingale

```
GridDistancePips = 20.0
MaxGridLevels = 10
LotSizeBuyLimit = 0.01
EnableMartingaleBuyLimit = true
MartingaleMultiplierBuyLimit = 2.0
MartingaleStartLevelBuyLimit = 2
```

### Cấu hình với giờ hoạt động

```
EnableTradingHours = true
StartHour = 8
StartMinute = 0
EndHour = 20
EndMinute = 0
```

---

## 🐛 Xử lý sự cố

### EA không đặt lệnh

- Kiểm tra nút "AutoTrading" đã bật chưa
- Kiểm tra giờ hoạt động (nếu đã bật)
- Kiểm tra EA có bị dừng do TP/SL không
- Kiểm tra Magic Number có trùng với EA khác không

### EA tự động dừng

- Kiểm tra log để xem lý do dừng
- Nếu dừng do TP/SL → EA sẽ **không** tự động khởi động lại
- Nếu dừng do giờ hoạt động (EA đang tắt, không còn lệnh) → EA sẽ tự động khởi động lại khi vào giờ, lấy giá hiện tại làm gốc

### Lệnh không được bổ sung

- Kiểm tra `AutoRefillOrders` đã bật chưa
- Kiểm tra EA có đang ở chế độ Trading Stop không

---

## 📋 Tài liệu bổ sung

- **[TINH_HUONG_GIO_HOAT_DONG.md](TINH_HUONG_GIO_HOAT_DONG.md)** – Chi tiết các tình huống khi vào giờ / ngoài giờ hoạt động (ví dụ cụ thể, bảng tóm tắt, log mẫu)

---

## 📝 Changelog

### Version 8.0
- Phiên bản V8 - Kế thừa đầy đủ tính năng từ V7.2
- File EA: `GridBalancedTradingV8.mq5`

### Version 7.2
- ✅ **Gồng lãi**: Cập nhật thứ tự khi kích hoạt Trading Stop
  - Bước 1: Xóa lệnh chờ gần giá hiện tại nhất (ưu tiên lệnh dễ bị kích hoạt)
  - Bước 2: Xóa TP tất cả lệnh đang mở
  - Bước 3: Xóa các lệnh chờ còn lại

### Version 7.1
- ✅ Thêm tính năng giờ hoạt động (giờ bắt đầu / kết thúc tùy chỉnh)
- ✅ Logic: EA đang chạy khi vào giờ → tiếp tục; EA đang tắt khi vào giờ → khởi động lại, lấy giá hiện tại làm gốc
- ✅ Ngoài giờ + còn lệnh → tiếp tục quản lý lệnh; không còn lệnh → tạm dừng
- ✅ Xóa bộ lọc RSI (không còn cần thiết)

### Version 7.0
- ✅ Grid Trading với cân bằng lưới tự động
- ✅ Hỗ trợ 4 loại lệnh (Buy Limit, Sell Limit, Buy Stop, Sell Stop)
- ✅ Martingale tùy chỉnh cho từng loại lệnh
- ✅ TP tổng (lệnh mở, phiên, tích lũy)
- ✅ Trading Stop Step (Gồng lãi)
- ✅ SL % so với tài khoản

---

## 📞 Hỗ trợ

- Kiểm tra log của EA trong tab **Experts** của MetaTrader 5
- Tham khảo [TINH_HUONG_GIO_HOAT_DONG.md](TINH_HUONG_GIO_HOAT_DONG.md) để hiểu rõ logic giờ hoạt động

---

## ⚖️ Disclaimer

EA này được cung cấp "as is" không có bảo hành. Trading forex có rủi ro cao, chỉ nên đầu tư số tiền bạn có thể chấp nhận mất. Luôn test kỹ trên tài khoản demo trước khi sử dụng trên tài khoản thật.

---

**Copyright © 2025 Grid Balanced Trading**
