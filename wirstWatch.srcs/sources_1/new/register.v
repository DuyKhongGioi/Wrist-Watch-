`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2026 01:58:34 PM
// Design Name: 
// Module Name: register
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


module register #(
    parameter DATA_WIDTH = 1,
    parameter INIT_VAL   = 0)
    (
        input wire clk,
        input wire reset,
        input wire en,
        input wire [DATA_WIDTH - 1 : 0] din,
        output wire [DATA_WIDTH - 1 : 0] dout
    );
    
    reg [DATA_WIDTH - 1 : 0] dout_int;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            dout_int <= INIT_VAL;
        end else if (en) begin
            dout_int <= din;
        end
    end
    
    assign dout = dout_int;
endmodule
