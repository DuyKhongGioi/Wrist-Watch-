`timescale 1ns / 1ps

module wristwatch(
    input  wire sysclk_100mhz,  
    input  wire pb_reset,       
    input  wire pb_b1,          // Chuyển Mode (B1)
    input  wire pb_b2,          // Set/Select (B2)
    input  wire pb_b3,          // Advance/Tăng (B3)
    
    // Xuất ra 16 LED đơn trên Basys 3
    output wire [15:0] leds_out,
    
    // Cổng điều khiển LED 7 đoạn
    output wire [6:0] seg,      
    output wire [3:0] an,       
    
    output wire buzzer_ring     
);

    // Dây tín hiệu kết nối nội bộ
    wire clk_100hz_clean;
    wire b1_clean, b2_clean, b3_clean;
    
    wire [5:0] d_sec;
    wire [5:0] d_min;
    wire [4:0] d_hour;
    wire [6:0] d_am_pm;
    wire       alarm_set;

    // 1. Khối xử lý tín hiệu nút bấm và hạ tần xung nhịp
    input_module u_input_processing (
        .sysclk(sysclk_100mhz), .reset(pb_reset),
        .PB1(pb_b1), .PB2(pb_b2), .PB3(pb_b3),
        .clk_100Hz(clk_100hz_clean),
        .B1(b1_clean), .B2(b2_clean), .B3(b3_clean)
    );

    // 2. Bộ xử lý logic đồng hồ lõi (Time + Alarm FSMD)
    wrist_watch_top u_watch_core (
        .clk(clk_100hz_clean), .reset(pb_reset),
        .B1(b1_clean), .B2(b2_clean), .B3(b3_clean),
        .display_sec(d_sec),
        .display_min(d_min),
        .display_hour(d_hour),
        .display_am_pm(d_am_pm),
        .alarm_ringing(buzzer_ring),
        .alarm_set(alarm_set)
    );

    // 3. Khối quét hiển thị LED 7 đoạn (HH:MM)
    seven_seg_mux u_7seg_display (
        .clk_100mhz(sysclk_100mhz),
        .reset(pb_reset),
        .hour(d_hour),
        .min(d_min),
        .seg(seg),
        .an(an)
    );

    // =========================================================
    // QUY HOẠCH LED ĐƠN TRÊN BOARD (leds_out)
    // =========================================================
    assign leds_out[15]    = alarm_set; // LED15 báo cờ Alarm đang bật hay tắt
    assign leds_out[14:9]  = d_sec;     
    assign leds_out[6:0]   = d_am_pm;      
    assign leds_out[8:7]   = 2'd0;
endmodule