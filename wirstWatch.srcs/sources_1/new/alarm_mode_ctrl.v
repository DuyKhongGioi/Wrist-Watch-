module alarm_mode_ctrl(
    input wire clk, 
    input wire reset,
    
    input wire B2, B3,
    
    output wire min_inc,
    output wire min_wrap,
    output wire hour_inc,
    output wire hour_wrap,
    output wire am_pm_toggle,
    
    output wire alarm_toggle, 
    
    input wire [5:0] alarm_min,
    input wire [4:0] alarm_hour
);
    
    reg [2:0] state_reg, state_next;
    localparam [2:0] IDLE       = 3'd0,
                     ALARM      = 3'd1,
                     SET_AHOURS = 3'd2,
                     SET_AMINS  = 3'd3,
                     SET_AAM_PM = 3'd4;
                     
    always @ (posedge clk or posedge reset) begin
        if (reset) state_reg <= IDLE;
        else       state_reg <= state_next;
    end
    
    always @ (*) begin
        case (state_reg)
            IDLE: state_next = ALARM;
            ALARM:      if (B2) state_next = SET_AHOURS; else state_next = ALARM;
            SET_AHOURS: if (B2) state_next = SET_AMINS;  else state_next = SET_AHOURS;
            SET_AMINS:  if (B2) state_next = SET_AAM_PM; else state_next = SET_AMINS;
            SET_AAM_PM: if (B2) state_next = ALARM;      else state_next = SET_AAM_PM;
            default: state_next = IDLE;
        endcase
    end
    
    // =========================================================
    // LOGIC ĐIỀU KHIỂN 
    // =========================================================
    
    // Bật/tắt cờ báo thức khi nhấn B3, VÀ KHÔNG nhấn B2
    assign alarm_toggle = (state_reg == ALARM) && B3 && !B2;
    
    // Xử lý các tầng đếm
    assign min_inc   = (state_reg == SET_AMINS) && B3 && !B2;
    assign min_wrap  = (alarm_min == 6'd59) && min_inc;
    
    assign hour_inc  = min_wrap || ((state_reg == SET_AHOURS) && B3 && !B2);
    assign hour_wrap = (alarm_hour == 5'd12) && hour_inc;

    assign am_pm_toggle = (state_reg == SET_AAM_PM) && B3 && !B2;
    
endmodule