`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2026 08:52:50 PM
// Design Name: 
// Module Name: time_mode_ctrl
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


module time_mode_ctrl(

    input wire clk, //100hz
    input wire reset,
    
    //from user 
    input wire B2,
    input wire B3,
    
    output wire hund_inc,
    output wire hund_wrap,
    output wire sec_inc,
    output wire sec_wrap,
    output wire min_inc,
    output wire min_wrap,
    output wire hour_inc,
    output wire hour_wrap,
    output wire am_pm_toggle,
    
    input wire [6:0] hund_cnt,
    input wire [5:0] sec_cnt,
    input wire [5:0] min_cnt,
    input wire [4:0] hour_cnt,
    input wire [6:0] am_pm_out
    );
    
    reg [1:0] state_reg, state_next;
    localparam [1:0] IDLE = 2'd0,
                     TIME = 2'd1,
                     SET_HOURS = 2'd2,
                     SET_MINS  = 2'd3;
                     
    always @ (posedge clk) begin
        if (reset) begin
            state_reg <= IDLE;
        end else begin
            state_reg <= state_next;
        end
    end
    
    always @ (*) begin
        case (state_reg)
            IDLE: state_next = TIME;
            TIME: 
                if (B2) begin
                    state_next = SET_HOURS;
                end else begin
                    state_next = TIME;
                end
            SET_HOURS:
                if (B2) begin
                    state_next = SET_MINS;
                end else begin
                    state_next = SET_HOURS;
                end
            SET_MINS:
                if (B2) begin
                    state_next = TIME;
                end else begin
                    state_next = SET_MINS;
                end
        endcase
    end
    
   // =========================================================
    // LOGIC ĐIỀU KHIỂN ĐẾM (PULSE CHAIN ROUTING) - ĐÃ FIX
    // =========================================================
    
    // 1. Tầng Trăm Giây
    assign hund_inc  = (state_reg == TIME);
    assign hund_wrap = (hund_cnt == 7'd99) && hund_inc;

    // 2. Tầng Giây
    assign sec_inc   = hund_wrap; 
    assign sec_wrap  = (sec_cnt == 6'd59) && sec_inc;

    // 3. Tầng Phút
    assign min_inc   = sec_wrap || ((state_reg == SET_MINS) && B3);
    assign min_wrap  = (min_cnt == 6'd59) && min_inc;

    // 4. Tầng Giờ
    // ĐÃ FIX: Giờ chỉ tự tăng khi Phút tràn DO Giây tràn (Natural Wrap). 
    // Không tăng khi bấm nút B3 làm Phút tràn.
    wire natural_min_wrap;
    assign natural_min_wrap = (min_cnt == 6'd59) && sec_wrap;
    
    assign hour_inc  = natural_min_wrap || ((state_reg == SET_HOURS) && B3);
    assign hour_wrap = (hour_cnt == 5'd12) && hour_inc;

    // 5. Khối AM/PM
    assign am_pm_toggle = (hour_cnt == 5'd11) && hour_inc;
    
endmodule
