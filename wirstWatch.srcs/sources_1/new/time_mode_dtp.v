module time_mode_dtp(
    input wire clk,
    input wire reset,
    
    input wire hund_inc,
    input wire hund_wrap,
    input wire sec_inc,
    input wire sec_wrap,
    input wire min_inc,
    input wire min_wrap,
    input wire hour_inc,
    input wire hour_wrap,
    input wire am_pm_toggle,
    
    output wire [6:0] hund_cnt,
    output wire [5:0] sec_cnt,
    output wire [5:0] min_cnt,
    output wire [4:0] hour_cnt,
    output wire [6:0] am_pm_out
    );
   
    // --- Mạch chọn lật trạng thái AM/PM ---
    // Nếu hiện tại đang là PM (0011000) thì giá trị tiếp theo sẽ là AM (0001000) và ngược lại
    wire [6:0] am_pm_next;
    assign am_pm_next = (am_pm_out == 7'b0011000) ? 7'b0001000 : 7'b0011000;
    
    // --- Các bộ đếm (Counters) ---
    counter #(
        .CNT_WIDTH(7)
    ) hundred_counter (
        .clk(clk),
        .reset(reset),
        .load(hund_wrap),
        .in_val(7'd0),
        .inc(hund_inc), 
        .dec(1'b0),
        .cnt(hund_cnt)
    );
    
    counter #(
        .CNT_WIDTH(6)
    ) second_counter (
        .clk(clk),
        .reset(reset),
        .load(sec_wrap),
        .in_val(7'd0),
        .inc(sec_inc), 
        .dec(1'b0),
        .cnt(sec_cnt)
    );
    
    counter #(
        .CNT_WIDTH(6)
    ) minute_counter (
        .clk(clk),
        .reset(reset),
        .load(min_wrap),
        .in_val(7'd0),
        .inc(min_inc), 
        .dec(1'b0),
        .cnt(min_cnt)
    );
    
    counter #(
        .CNT_WIDTH(5)
    ) hour_counter (
        .clk(clk),
        .reset(reset),
        .load(hour_wrap),
        .in_val(5'd1),      // Đã FIX: Nạp trực tiếp giá trị 1 khi wrap
        .inc(hour_inc), 
        .dec(1'b0),
        .cnt(hour_cnt)
    );
    
    // --- Thanh ghi AM/PM ---
    register #(
        .DATA_WIDTH(7)
    ) am_pm_inst (
        .clk(clk),
        .reset(reset),
        .en(am_pm_toggle),
        .din(am_pm_next),   // Đã FIX: Truyền biến trạng thái đảo vào din
        .dout(am_pm_out)
    );
    
endmodule