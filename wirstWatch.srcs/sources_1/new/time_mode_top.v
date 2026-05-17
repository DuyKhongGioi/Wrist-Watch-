`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2026 09:53:09 PM
// Design Name: 
// Module Name: time_mode_top
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


module time_mode_top(
    input wire clk, //100hz
    input wire reset,
    
    //from user 
    input wire B2,
    input wire B3,
    
    //output
    output wire [5:0] sec_cnt,
    output wire [5:0] min_cnt,
    output wire [4:0] hour_cnt,
    output wire [6:0] am_pm_out
    );
    
    wire hund_inc;
    wire hund_wrap;
    wire sec_inc;
    wire sec_wrap;
    wire min_inc;
    wire min_wrap;
    wire hour_inc;
    wire hour_wrap;
    wire am_pm_toggle;
    wire [6:0] hund_cnt;
    
    time_mode_ctrl controller(

    .clk(clk), //100hz
    .reset(reset),
    
    //from user 
    .B2(B2),
    .B3(B3),
    
    .hund_inc(hund_inc),
    .hund_wrap(hund_wrap),
    .sec_inc(sec_inc),
    .sec_wrap(sec_wrap),
    .min_inc(min_inc),
    .min_wrap(min_wrap),
    .hour_inc(hour_inc),
    .hour_wrap(hour_wrap),
    .am_pm_toggle(am_pm_toggle),
    
    .hund_cnt(hund_cnt),
    .sec_cnt(sec_cnt),
    .min_cnt(min_cnt),
    .hour_cnt(hour_cnt),
    .am_pm_out(am_pm_out)
    );
    
    time_mode_dtp datapath(
    .clk(clk),
    .reset(reset),
    
    .hund_inc(hund_inc),
    .hund_wrap(hund_wrap),
    .sec_inc(sec_inc),
    .sec_wrap(sec_wrap),
    .min_inc(min_inc),
    .min_wrap(min_wrap),
    .hour_inc(hour_inc),
    .hour_wrap(hour_wrap),
    .am_pm_toggle(am_pm_toggle),
    
    .hund_cnt(hund_cnt),
    .sec_cnt(sec_cnt),
    .min_cnt(min_cnt),
    .hour_cnt(hour_cnt),
    .am_pm_out(am_pm_out)
    );
    
endmodule
