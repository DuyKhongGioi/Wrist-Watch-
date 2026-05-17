`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2026 12:43:05 PM
// Design Name: 
// Module Name: clock_gen_100
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


module clock_gen_100 #(
    parameter [18:0] CLK_THRESH = 19'd500000)(
    input wire sysclk,
    input wire reset,
    
    output wire clk_100
    );
    
    wire [18:0] cnt_val;
    wire inc, dec;
    
    counter #(.CNT_WIDTH(19))
     cnt_inst(
    .clk(sysclk),
    .reset(reset),
    .load(1'b0),
    .in_val(19'd0),
    .inc(inc), 
    .dec(dec),
    .cnt(cnt_val)
    );
    
    localparam IDLE = 2'd0,
               INC  = 2'd1,
               DEC  = 2'd2;
               
    reg [1:0] state_reg, state_next;
    
    always @ (posedge sysclk) begin
        if (reset) begin
            state_reg <= IDLE;
        end else begin
            state_reg <= state_next;
        end
    end
    
    always @(*) begin
        case (state_reg) 
            IDLE: state_next = INC;
            INC: 
                if (cnt_val != CLK_THRESH - 19'd1) begin
                    state_next = INC;
                end else begin
                    state_next = DEC;
                end
            DEC:
                if (cnt_val != 19'd0) begin
                    state_next = DEC;
                end else begin
                    state_next = INC;
                end
            default: state_next = IDLE;
        endcase
    end
    
    assign clk_100 = (state_reg == INC);
    assign inc = state_reg == INC;
    assign dec = state_reg == DEC;
endmodule
