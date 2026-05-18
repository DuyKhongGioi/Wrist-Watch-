module alarm_mode_dtp(
    input wire clk,
    input wire reset,
    
    input wire min_inc,
    input wire min_wrap,
    input wire hour_inc,
    input wire hour_wrap,
    input wire am_pm_toggle,
    
    input wire [5:0] real_min,
    input wire [4:0] real_hour,
    input wire [6:0] real_am_pm,
    input wire [5:0] real_sec,
    
    input wire alarm_toggle,
    
    output wire [5:0] alarm_min,
    output wire [4:0] alarm_hour,
    output wire [6:0] alarm_am_pm,
    
    output wire ring,
    output wire alarm_set
);
    
    wire [6:0] am_pm_next;
    assign am_pm_next = (alarm_am_pm == 7'b0011000) ? 7'b0001000 : 7'b0011000;
    
    
    assign ring = (real_hour == alarm_hour) && 
                  (real_min  == alarm_min)  &&
                  (real_am_pm == alarm_am_pm) && 
                  (real_sec < 6'd49) && 
                  (alarm_set == 1'b1);
    
   
    wire alarm_set_next;
    assign alarm_set_next = ~alarm_set; 
    
    counter #(
        .CNT_WIDTH(6),
        .INIT_VAL(6'd0)
    ) minute_counter (
        .clk(clk),
        .reset(reset),
        .load(min_wrap),
        .in_val(6'd0),
        .inc(min_inc), 
        .dec(1'b0),
        .cnt(alarm_min)   
    );
    
    counter #(
        .CNT_WIDTH(5),
        .INIT_VAL(5'd12)
    ) hour_counter (
        .clk(clk),
        .reset(reset),
        .load(hour_wrap),
        .in_val(5'd1),      
        .inc(hour_inc), 
        .dec(1'b0),
        .cnt(alarm_hour)  
    );
    
    register #(
        .DATA_WIDTH(7),
        .INIT_VAL(7'b0001000)
    ) am_pm_inst (
        .clk(clk),
        .reset(reset),
        .en(am_pm_toggle),
        .din(am_pm_next),   
        .dout(alarm_am_pm)
    );
    
   
    register #(
        .DATA_WIDTH(1),
        .INIT_VAL(1'b0)
    ) alarm_indicator_inst (
        .clk(clk),
        .reset(reset),
        .en(alarm_toggle),
        .din(alarm_set_next),   
        .dout(alarm_set)
    );
    
endmodule