`timescale 1ns / 1ps

module seven_seg_mux(
    input wire clk_100mhz,   // Xung gốc 100MHz để quét LED cực mượt
    input wire reset,
    input wire [4:0] hour,   // Giờ thực tế (1 - 12)
    input wire [5:0] min,    // Phút thực tế (0 - 59)
    output reg [6:0] seg,    // Cathodes điều khiển thanh ghi {g,f,e,d,c,b,a}
    output reg [3:0] an      // Anodes điều khiển chọn bật LED nào (0..3)
    );

    // Mạch chia lấy hàng chục và hàng đơn vị dạng tổ hợp (BCD)
    wire [3:0] hour_tens = hour / 4'd10;
    wire [3:0] hour_ones = hour % 4'd10;
    wire [3:0] min_tens  = min / 4'd10;
    wire [3:0] min_ones  = min % 4'd10;

    // Bộ đếm tạo chu kỳ quét (Refresh Counter)
    // 100MHz / 2^18 ~ 381Hz. Mỗi LED bật khoảng ~95Hz (Không bị ghosting/flicker)
    reg [17:0] refresh_counter;
    always @(posedge clk_100mhz or posedge reset) begin
        if (reset)
            refresh_counter <= 18'd0;
        else
            refresh_counter <= refresh_counter + 1'b1;
    end

    wire [1:0] digit_select = refresh_counter[17:16];
    reg [3:0] current_digit;
    reg blank_digit; // Cờ tắt LED nếu là số 0 vô nghĩa ở hàng chục

    // Khối chọn vị trí hiển thị (Mux dữ liệu và chọn Anode)
    always @(*) begin
        blank_digit = 1'b0;
        case (digit_select)
            2'b00: begin
                an = 4'b1110; // Bật LED 0 (phải cùng) - Hàng đơn vị của PHÚT
                current_digit = min_ones;
            end
            2'b01: begin
                an = 4'b1101; // Bật LED 1 - Hàng chục của PHÚT
                current_digit = min_tens;
            end
            2'b10: begin
                an = 4'b1011; // Bật LED 2 - Hàng đơn vị của GIỜ
                current_digit = hour_ones;
            end
            2'b11: begin
                an = 4'b0111; // Bật LED 3 (trái cùng) - Hàng chục của GIỜ
                current_digit = hour_tens;
                if (hour_tens == 4'd0) blank_digit = 1'b1; // Ví dụ: "01:25" sẽ ẩn số 0 thành " 1:25"
            end
            default: begin
                an = 4'b1111;
                current_digit = 4'd0;
            end
        endcase
    end

    // Khối giải mã từ số 4-bit ra thanh hiển thị 7 đoạn (Active-Low: 0 là SÁNG)
    always @(*) begin
        if (blank_digit) begin
            seg = 7'b1111111; // Tắt toàn bộ các đoạn g->a
        end else begin
            case (current_digit)
                4'd0: seg = 7'b1000000; // Tắt đoạn g
                4'd1: seg = 7'b1111001; 
                4'd2: seg = 7'b0100100; 
                4'd3: seg = 7'b0110000; 
                4'd4: seg = 7'b0011001; 
                4'd5: seg = 7'b0010010; 
                4'd6: seg = 7'b0000010; 
                4'd7: seg = 7'b1111000; 
                4'd8: seg = 7'b0000000; // Sáng hết
                4'd9: seg = 7'b0010000; 
                default: seg = 7'b1111111;
            endcase
        end
    end

endmodule