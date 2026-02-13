# Grid Balanced Trading EA V8

**Expert Advisor (EA)** cho MetaTrader 5 – Grid Trading với cân bằng lưới tự động và giờ hoạt động tùy chỉnh.

## Mô tả

EA khởi động ngay và tạo lưới tại giá hiện tại. Hỗ trợ giao dịch theo 4 loại lệnh: Buy Limit, Sell Limit, Buy Stop, Sell Stop. Mỗi loại có cài đặt riêng về số bậc lưới, bắt đầu từ bậc nào, lot, Take Profit và Martingale.

---

## Yêu cầu

- **MetaTrader 5**
- **Symbol**: Bất kỳ (Forex, CFD, v.v.)

---

## Cài đặt

1. Copy file `GridBalancedTradingV8.mq5` vào thư mục `MQL5/Experts/`
2. Biên dịch (Compile) trong MetaEditor
3. Gắn EA lên biểu đồ cần giao dịch

---

## Tham số đầu vào

### Cài đặt lưới
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| GridDistancePips | 20.0 | Khoảng cách giữa các mức lưới (pips) |
| AutoRefillOrders | true | Tự động đặt lại lệnh khi lệnh đóng |

Số lượng lưới tối đa và **bậc bắt đầu đặt lệnh** được cài **riêng cho từng loại lệnh** (xem từng nhóm bên dưới).

- **Bắt đầu từ bậc lưới**: Nếu = 1 thì lệnh đó đặt từ bậc 1 trở đi. Nếu = 10 thì chỉ từ bậc 10 trở đi mới có lệnh (bậc 1–9 không đặt lệnh loại đó).

### Lệnh Buy Limit
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| MaxGridLevelsBuyLimit | 10 | Số mức lưới tối đa (chỉ cho Buy Limit) |
| OrderStartLevelBuyLimit | 1 | Bắt đầu đặt lệnh từ bậc lưới (1 = bậc 1 trở đi, 10 = từ bậc 10 trở đi) |
| EnableBuyLimit | true | Bật/tắt lệnh Buy Limit |
| LotSizeBuyLimit | 0.01 | Lot (mức 1) |
| TakeProfitPipsBuyLimit | 30.0 | TP (pips, 0 = tắt) |
| EnableMartingaleBuyLimit | false | Bật gấp thếp |
| MartingaleMultiplierBuyLimit | 2.0 | Hệ số gấp thếp (mức 2 = x2, mức 3 = x4...) |
| MartingaleStartLevelBuyLimit | 1 | Bắt đầu gấp thếp từ bậc lưới |

### Lệnh Sell Limit
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| MaxGridLevelsSellLimit | 10 | Số mức lưới tối đa (chỉ cho Sell Limit) |
| OrderStartLevelSellLimit | 1 | Bắt đầu đặt lệnh từ bậc lưới (1 = bậc 1 trở đi, 10 = từ bậc 10 trở đi) |
| ... | ... | Các tham số khác giống nhóm Buy Limit |

### Lệnh Buy Stop
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| MaxGridLevelsBuyStop | 10 | Số mức lưới tối đa (chỉ cho Buy Stop) |
| OrderStartLevelBuyStop | 1 | Bắt đầu đặt lệnh từ bậc lưới (1 = bậc 1 trở đi, 10 = từ bậc 10 trở đi) |
| ... | ... | Các tham số khác tương tự nhóm Buy Limit |

### Lệnh Sell Stop
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| MaxGridLevelsSellStop | 10 | Số mức lưới tối đa (chỉ cho Sell Stop) |
| OrderStartLevelSellStop | 1 | Bắt đầu đặt lệnh từ bậc lưới (1 = bậc 1 trở đi, 10 = từ bậc 10 trở đi) |
| ... | ... | Các tham số khác tương tự nhóm Buy Limit |

### Giới hạn gấp thếp
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| MaxMartingaleLevel | 0 | Bậc tối đa gấp thếp (0 = không giới hạn) |

### TP tổng
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| TotalProfitTPOpen | 0.0 | TP tổng lệnh đang mở (USD, 0 = tắt) |
| ActionOnTotalProfitOpen | Reset EA | Dừng EA hoặc Reset EA |
| TotalProfitTPSession | 0.0 | TP tổng phiên (USD, 0 = tắt) |
| ActionOnTotalProfitSession | Reset EA | Dừng EA hoặc Reset EA |
| TotalProfitTPAccumulated | 0.0 | TP tổng tích lũy (USD, 0 = tắt) |

### Trading Stop / Gồng lãi
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| EnableTradingStopStepTotal | false | Bật chế độ gồng lãi |
| TradingStopStepMode | Theo lệnh mở | 0 = Theo lệnh mở, 1 = Theo phiên, 2 = Tổ hợp |
| TradingStopStepTotalProfit | 50.0 | Lãi lệnh mở để kích hoạt (USD) |
| TradingStopStepSessionProfit | 50.0 | Lãi phiên để kích hoạt (USD) |
| TradingStopStepReturnProfitOpen | 20.0 | Lãi quay lại (lệnh mở) để tiếp tục (USD) |
| TradingStopStepReturnProfitSession | 20.0 | Lãi quay lại (phiên) để tiếp tục (USD) |
| TradingStopStepPointA | 10.0 | Điểm A cách lệnh dương thấp nhất (pips) |
| TradingStopStepSize | 5.0 | Bước di chuyển SL (pips) |
| ActionOnTradingStopStepComplete | Dừng EA | Hành động khi giá chạm SL |

### Reset dựa trên Lot
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| EnableLotBasedReset | false | Bật reset theo lot và tổng phiên |
| MaxLotThreshold | 0.1 | Lot lớn nhất để kích hoạt (0 = tắt) |
| TotalLotThreshold | 1.0 | Tổng lot để kích hoạt (0 = tắt) |
| SessionProfitForLotReset | 50.0 | Tổng phiên để reset (USD) |

### SL % tài khoản
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| EnableAccountSLPercent | false | Bật SL % theo tài khoản |
| AccountSLPercent | 10.0 | % lỗ để kích hoạt (%) |
| MaxLotForAccountSL | 0.0 | Lot lớn nhất (0 = bỏ qua) |
| TotalLotForAccountSL | 0.0 | Tổng lot (0 = bỏ qua) |
| ActionOnAccountSL | Dừng EA | Dừng EA hoặc Reset EA |

### Giờ hoạt động
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| EnableTradingHours | false | Bật giới hạn giờ giao dịch |
| StartHour | 0 | Giờ bắt đầu (0–23) |
| StartMinute | 0 | Phút bắt đầu (0–59) |
| EndHour | 23 | Giờ kết thúc (0–23) |
| EndMinute | 59 | Phút kết thúc (0–59) |

> Ngoài giờ: EA không mở lệnh mới nhưng vẫn quản lý lệnh đang mở. EA tự động khởi động lại khi vào giờ (nếu không còn lệnh).

### Cài đặt chung
| Tham số | Mặc định | Mô tả |
|---------|----------|-------|
| MagicNumber | 123456 | Magic Number |
| CommentOrder | "Grid Balanced V8" | Comment cho lệnh |
| EnableResetNotification | false | Thông báo về điện thoại khi EA reset |

---

## Hành động khi đạt TP/SL

- **Dừng EA**: EA dừng hoàn toàn, không tự động khởi động lại.
- **Reset EA**: Đóng tất cả lệnh, khởi tạo lại lưới tại giá hiện tại và tiếp tục giao dịch.

---

## Phiên bản

- **Version**: 8.0  
- **Copyright**: Grid Balanced Trading
