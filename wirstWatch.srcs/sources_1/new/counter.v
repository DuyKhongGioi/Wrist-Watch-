`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2026 12:50:06 PM
// Design Name: 
// Module Name: counter
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


module counter #(
    parameter CNT_WIDTH = 1,
    parameter INIT_VAL  = 0)
    (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [CNT_WIDTH - 1 : 0] in_val,
    input wire inc, dec,
    output wire [CNT_WIDTH - 1 : 0] cnt
    );
    
    reg [CNT_WIDTH-1:0] cnt_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt_reg <= INIT_VAL;
        end else if (load) begin
            cnt_reg <= in_val;
        end else if (inc && !dec) begin
            cnt_reg <= cnt_reg + 1'b1;
        end else if (dec && !inc) begin
            cnt_reg <= cnt_reg - 1'b1;
        end
    end
    
    assign cnt = cnt_reg;
endmodule
