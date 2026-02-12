# Grid Balanced Trading EA V8.0

Expert Advisor (EA) cho MetaTrader 5 - Chiến lược Grid Trading với cân bằng lưới tự động và giờ hoạt động.

## 📋 Mô tả

EA Grid Trading tự động tạo lưới lệnh xung quanh giá hiện tại khi khởi động, hỗ trợ 4 loại lệnh (Buy Limit, Sell Limit, Buy Stop, Sell Stop) với hệ thống quản lý rủi ro thông minh và chế độ gồng lãi (Trading Stop Step).

## ✨ Tính năng chính

### 1. Grid Trading Tự động
- ✅ Tạo lưới lệnh tự động tại giá hiện tại khi khởi động
- ✅ Hỗ trợ 4 loại lệnh: Buy Limit, Sell Limit, Buy Stop, Sell Stop
- ✅ Tự động bổ sung lệnh khi lệnh đóng (Auto Refill)
- ✅ Cân bằng lưới thông minh

### 2. Martingale (Gấp thếp)
- ✅ Bật/tắt độc lập cho từng loại lệnh
- ✅ Hệ số gấp thếp tùy chỉnh
- ✅ Bắt đầu gấp thếp từ bậc lưới chỉ định
- ✅ **Giới hạn bậc gấp thếp**: Bậc tối đa gấp thếp (0 = không giới hạn). Từ bậc này trở đi lot không tăng nữa, bằng lot tại bậc này. Chỉ áp dụng cho loại lệnh đã bật gấp thếp; loại không bật vẫn dùng lot cố định ở mọi bậc.
- ✅ Lưu lot size khi đạt TP để tái sử dụng

### 3. Quản lý Rủi ro

#### TP Tổng
- **TP tổng lệnh đang mở**: Dừng/Reset khi tổng lãi lệnh mở đạt ngưỡng
- **TP tổng phiên**: Dừng/Reset khi tổng lãi phiên đạt ngưỡng
- **TP tổng tích lũy**: Dừng/Reset khi tổng lãi tích lũy đạt ngưỡng

#### Trading Stop, Step Tổng (Gồng lãi) ⭐
- **Chế độ kích hoạt**: Theo lệnh mở / Theo phiên / Tổ hợp cả 2
- **Ngưỡng kích hoạt**: Khi tổng lãi đạt ngưỡng → Kích hoạt gồng lãi
- **Ngưỡng quay lại**: Nếu tổng lãi giảm xuống dưới ngưỡng này (trước khi đặt SL) → Hủy Trading Stop và khôi phục lại trạng thái ban đầu
- **Điểm A**: Cách lệnh dương thấp nhất X pips
- **Step size**: Khoảng cách dịch SL mỗi step
- **Trailing Stop**: Tự động dịch SL theo giá (chỉ dịch theo hướng có lợi)

**Quy trình gồng lãi:**
1. Đạt ngưỡng kích hoạt → Xóa lệnh chờ, xóa TP, tính điểm A
2. Chờ giá đến điểm A ± step → Đặt SL tại điểm A, đóng lệnh ngược hướng
3. Trailing SL: Dịch SL theo giá mỗi khi giá đi thêm 1 step
4. Kết thúc: Khi giá quay đầu chạm SL → Reset/Dừng EA

**Đặc biệt:** Nếu tổng lãi giảm xuống dưới ngưỡng quay lại TRƯỚC KHI đặt SL, EA sẽ:
- ✅ Hủy Trading Stop
- ✅ Khôi phục TP cho **TẤT CẢ lệnh đang mở** (cả dương và âm) theo input; lệnh chờ đã xóa được tạo lại **có TP theo input**
- ✅ Tiếp tục chạy như chưa từng kích hoạt Trading Stop

#### SL % so với tài khoản
- Dừng/Reset EA khi lỗ đạt % so với tài khoản
- Có thể kết hợp với điều kiện lot (lot lớn nhất, tổng lot)

#### Reset dựa trên Lot và Tổng phiên
- Reset khi đạt điều kiện lot và tổng phiên

### 4. Giờ hoạt động
- ✅ Tự động dừng/khởi động theo khung giờ tùy chỉnh
- ✅ Tiếp tục quản lý lệnh đang mở ngoài giờ hoạt động
- ✅ Tự động khởi động lại khi vào giờ hoạt động

### 5. Reset EA
- ✅ Reset khi đạt TP tổng
- ✅ Giữ lại thống kê tích lũy
- ✅ Gửi thông báo điện thoại khi reset (tùy chọn)

## ⚙️ Cài đặt

### Cài đặt Lưới
- `GridDistancePips`: Khoảng cách lưới (pips)
- `MaxGridLevels`: Số lượng lưới tối đa
- `AutoRefillOrders`: Tự động bổ sung lệnh khi đóng

### Cài đặt Lệnh (cho mỗi loại: Buy Limit, Sell Limit, Buy Stop, Sell Stop)
- `Enable[Loại]`: Bật/tắt loại lệnh
- `LotSize[Loại]`: Khối lượng (mức 1)
- `TakeProfitPips[Loại]`: Take Profit (pips, 0=off)
- `EnableMartingale[Loại]`: Bật gấp thếp
- `MartingaleMultiplier[Loại]`: Hệ số gấp thếp
- `MartingaleStartLevel[Loại]`: Bắt đầu gấp thếp từ bậc lưới

### Giới hạn gấp thếp
- `MaxMartingaleLevel`: Bậc tối đa gấp thếp (0 = không giới hạn). Từ bậc này trở đi lot không tăng, bằng lot tại bậc này. **Chỉ áp dụng cho loại lệnh đã bật gấp thếp**; loại không bật gấp thếp luôn dùng lot cố định, không bị ảnh hưởng.

### TP Tổng
- `TotalProfitTPOpen`: TP tổng lệnh đang mở (USD, 0=off)
- `ActionOnTotalProfitOpen`: Hành động khi đạt (Dừng EA / Reset EA)
- `TotalProfitTPSession`: TP tổng phiên (USD, 0=off)
- `ActionOnTotalProfitSession`: Hành động khi đạt
- `TotalProfitTPAccumulated`: TP tổng tích lũy (USD, 0=off)

### Trading Stop, Step Tổng (Gồng lãi)
- `EnableTradingStopStepTotal`: Bật Trading Stop, Step Tổng
- `TradingStopStepMode`: Chế độ (0=Theo lệnh mở, 1=Theo phiên, 2=Tổ hợp cả 2)
- `TradingStopStepTotalProfit`: Lãi tổng lệnh đang mở để kích hoạt (USD)
- `TradingStopStepSessionProfit`: Lãi tổng phiên để kích hoạt (USD)
- `TradingStopStepReturnProfitOpen`: Lãi tổng lệnh mở khi quay lại để tiếp tục (USD)
- `TradingStopStepReturnProfitSession`: Lãi tổng phiên khi quay lại để tiếp tục (USD)
- `TradingStopStepPointA`: Điểm A cách lệnh dương thấp nhất (pips)
- `TradingStopStepSize`: Step pips để di chuyển SL (pips)
- `ActionOnTradingStopStepComplete`: Hành động khi giá chạm SL (0=Dừng EA, 1=Reset EA)

### SL % so với tài khoản
- `EnableAccountSLPercent`: Bật SL % so với tài khoản
- `AccountSLPercent`: % lỗ so với tài khoản để kích hoạt (%)
- `ActionOnAccountSL`: Hành động khi đạt SL %

### Giờ hoạt động
- `EnableTradingHours`: Bật giờ hoạt động
- `StartHour`: Giờ bắt đầu (0-23)
- `StartMinute`: Phút bắt đầu (0-59)
- `EndHour`: Giờ kết thúc (0-23)
- `EndMinute`: Phút kết thúc (0-59)

### Cài đặt chung
- `MagicNumber`: Magic Number
- `CommentOrder`: Comment cho lệnh
- `EnableResetNotification`: Bật thông báo về điện thoại khi EA reset

## 🔄 Logic hoạt động

### Khởi động EA
1. EA khởi động ngay tại giá hiện tại
2. Tạo lưới các level giá cố định xung quanh giá cơ sở
3. Đặt lệnh chờ tại các level theo cài đặt

### Quản lý lệnh
- Kiểm tra và đảm bảo có lệnh tại mỗi level
- Tự động bổ sung lệnh khi lệnh đóng (nếu bật Auto Refill)
- Cân bằng lưới: Kiểm tra trước khi đặt lệnh mới

### Chế độ Gồng lãi (Trading Stop Step)

#### Kích hoạt
- Khi tổng lãi đạt ngưỡng kích hoạt
- Chọn hướng: So sánh tổng lãi Buy và Sell, chọn hướng lãi hơn
- Xóa lệnh chờ gần giá
- Xóa TP của tất cả lệnh đang mở
- Tính điểm A từ lệnh dương gần giá nhất trong hướng được chọn

#### Step đầu tiên
- Khi giá đến điểm A ± step:
  - Đặt SL tại điểm A cho tất cả lệnh cùng hướng
  - Đóng tất cả lệnh ngược hướng
  - Bắt đầu trailing SL

#### Trailing SL
- Buy: Chỉ dịch SL lên khi giá đi lên thêm 1 step
- Sell: Chỉ dịch SL xuống khi giá đi xuống thêm 1 step
- KHÔNG dịch SL khi giá đi ngược lại

#### Hủy Trading Stop (trước khi đặt SL)
- Nếu tổng lãi giảm xuống dưới ngưỡng quay lại TRƯỚC KHI đặt SL:
  - Hủy Trading Stop
  - Khôi phục TP cho TẤT CẢ lệnh đang mở theo input
  - Tạo lại lệnh chờ với TP theo input
  - EA tiếp tục chạy bình thường

#### Kết thúc
- Khi giá quay đầu chạm SL:
  - Reset EA hoặc Dừng EA (theo cài đặt)

## 📊 Thống kê theo dõi

EA tự động theo dõi:
- Profit phiên hiện tại
- Profit tích lũy (từ khi EA khởi động)
- Số lần reset
- Vốn thấp nhất trong phiên
- Số âm lớn nhất của lệnh đang mở
- Lot lớn nhất từng có
- Tổng lot lớn nhất từng có

## ⚠️ Lưu ý quan trọng

1. **Magic Number**: Đảm bảo Magic Number không trùng với EA khác
2. **Giờ hoạt động**: EA sẽ tự động dừng ngoài giờ nhưng vẫn quản lý lệnh đang mở
3. **Gồng lãi**: Chỉ dịch SL theo hướng có lợi, không dịch ngược lại
4. **Khôi phục**: Khi hủy Trading Stop trước khi đặt SL, EA khôi phục TP cho mọi lệnh đang mở và tạo lại lệnh chờ, tất cả có TP đúng theo input
5. **Giới hạn gấp thếp**: Chỉ áp dụng cho loại lệnh đã bật gấp thếp; loại không bật gấp thếp luôn dùng lot cố định
6. **Reset**: Khi reset, EA sẽ đóng tất cả lệnh và khởi động lại tại giá mới

## 📝 Version History

### V8.0
- ✅ Cải thiện logic khôi phục Trading Stop: Khôi phục TP cho TẤT CẢ lệnh đang mở (cả dương và âm) theo input
- ✅ Tự động tạo lại lệnh chờ với TP theo input khi hủy Trading Stop
- ✅ Cải thiện logic chọn hướng trong Trading Stop
- ✅ Hỗ trợ ngưỡng quay lại để hủy Trading Stop trước khi đặt SL
- ✅ **Giới hạn gấp thếp**: Thêm input `MaxMartingaleLevel` – bậc tối đa gấp thếp; từ bậc này trở đi lot không tăng. Chỉ áp dụng cho loại lệnh đã bật gấp thếp

## 📧 Liên hệ

Nếu có câu hỏi hoặc góp ý, vui lòng liên hệ qua GitHub Issues.

---

**Lưu ý**: EA này chỉ dành cho mục đích giáo dục và nghiên cứu. Giao dịch có rủi ro, hãy sử dụng cẩn thận và quản lý rủi ro tốt.
