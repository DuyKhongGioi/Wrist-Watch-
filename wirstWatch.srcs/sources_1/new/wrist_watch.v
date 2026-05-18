`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2026 12:28:41 PM
// Design Name: 
// Module Name: wrist_watch
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module wrist_watch_top(
    input wire clk,       // Đã là xung 100Hz (hoặc tick_100hz)
    input wire reset,
    
    // Nút bấm từ người dùng (Giả định đã qua mạch chống rung & tạo xung đơn)
    input wire B1,        // Chuyển Mode
    input wire B2,        // Nút Set/Select
    input wire B3,        // Nút Advance/Tăng
    
    // Ngõ ra hiển thị chung
    output wire [5:0] display_sec,
    output wire [5:0] display_min,
    output wire [4:0] display_hour,
    output wire [6:0] display_am_pm,
    output wire       alarm_ringing, // Cờ báo chuông ra loa/LED
    output wire       alarm_set
    );
    
    wire B2_time, B3_time;
    wire B2_alarm, B3_alarm;
    
    wire [5:0] time_sec;
    wire [5:0] time_min;
    wire [4:0] time_hour;
    wire [6:0] time_am_pm;
    
    wire [5:0] alarm_min;
    wire [4:0] alarm_hour;
    wire [6:0] alarm_am_pm;
    
    
    
    reg [1:0] state_reg, state_next;
    localparam [1:0] TIME_MODE = 2'd0,
                     ALARM_MODE = 2'd1;
    
    //state resgister 
    always @ (posedge clk) begin
        if (reset) begin
            state_reg <= TIME_MODE;
        end else begin
            state_reg <= state_next;
        end
    end
    
    //next state logic 
    always @ (*) begin
        case (state_reg) 
            TIME_MODE: 
                if (B1) begin
                    state_next = ALARM_MODE;
                end else begin
                    state_next = TIME_MODE;
                end
            ALARM_MODE: 
                if (B1) begin
                    state_next = TIME_MODE;
                end else begin
                    state_next = ALARM_MODE;
                end
            default: state_next = TIME_MODE;
        endcase
    end
    
    //----------------------------------------------------
    assign B2_time = (state_reg == TIME_MODE) ? B2 : 1'b0;
    assign B3_time = (state_reg == TIME_MODE) ? B3 : 1'b0;
    assign B2_alarm = (state_reg == ALARM_MODE) ? B2 : 1'b0;
    assign B3_alarm = (state_reg == ALARM_MODE) ? B3 : 1'b0;
    //----------------------------------------------------
    
     alarm_mode_top alarm_module(
     .clk(clk),            // LUÔN LUÔN CẤP CLK 100Hz
     .reset(reset),
     .B2(B2_alarm), .B3(B3_alarm),
     
    // Để alarm so sánh giờ reo chuông, nó cần biết thời gian thực tế hiện tại
     .real_sec(time_sec), // ĐÃ BỔ SUNG: Rất cần thiết để so sánh giây < 49
     .real_min(time_min),
     .real_hour(time_hour),
     .real_am_pm(time_am_pm),
     
     .alarm_min(alarm_min),
     .alarm_hour(alarm_hour),
     .alarm_am_pm(alarm_am_pm),
     .alarm_ringing(alarm_ringing), // Tương ứng với cờ 'ring' trong datapath
     .alarm_set(alarm_set)
    );
    
    
    time_mode_top time_module(
    .clk(clk), //100hz
    .reset(reset),
    
    //from user 
    .B2(B2_time),
    .B3(B3_time),
    
    //output
    .sec_cnt(time_sec),
    .min_cnt(time_min),
    .hour_cnt(time_hour),
    .am_pm_out(time_am_pm)
    );
    
    //-------------------------------
    assign display_sec = (state_reg == ALARM_MODE) ? 6'b0 : time_sec;
    assign display_min = (state_reg == ALARM_MODE) ? alarm_min : time_min;
    assign display_hour = (state_reg == ALARM_MODE) ? alarm_hour : time_hour;
    assign display_am_pm = (state_reg == ALARM_MODE) ? alarm_am_pm : time_am_pm;
    //---------------------------------------------------------------------------
endmodule
