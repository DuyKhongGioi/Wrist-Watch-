module alarm_mode_top(
     input wire clk,            // LUÔN LUÔN CẤP CLK 100Hz
     input wire reset,
     input wire B2, B3,
     
    // Để alarm so sánh giờ reo chuông, nó cần biết thời gian thực tế hiện tại
     input wire [5:0] real_sec, 
     input wire [5:0] real_min,
     input wire [4:0] real_hour,
     input wire [6:0] real_am_pm,
     
     output wire [5:0] alarm_min,
     output wire [4:0] alarm_hour,
     output wire [6:0] alarm_am_pm,
     output wire alarm_ringing, 
     output wire alarm_set
    );
    
    // =========================================================
    // KHAI BÁO DÂY NỐI NỘI BỘ 
    // =========================================================
    wire min_inc;
    wire min_wrap;
    wire hour_inc;
    wire hour_wrap;
    wire am_pm_toggle;
    wire alarm_toggle;

    // =========================================================
    // KHỞI TẠO VÀ KẾT NỐI CONTROL PATH
    // =========================================================
    alarm_mode_ctrl controller (
        .clk(clk),
        .reset(reset),
        
        .B2(B2),
        .B3(B3),
        
        .min_inc(min_inc),
        .min_wrap(min_wrap),
        .hour_inc(hour_inc),
        .hour_wrap(hour_wrap),
        .am_pm_toggle(am_pm_toggle),
        .alarm_toggle(alarm_toggle),
        
        // Feed back từ datapath để FSM biết ranh giới tràn
        .alarm_min(alarm_min),
        .alarm_hour(alarm_hour)
    );

    // =========================================================
    // KHỞI TẠO VÀ KẾT NỐI DATA PATH
    // =========================================================
    alarm_mode_dtp datapath (
        .clk(clk),
        .reset(reset),
        
        // Nhận tín hiệu điều khiển từ Controller
        .min_inc(min_inc),
        .min_wrap(min_wrap),
        .hour_inc(hour_inc),
        .hour_wrap(hour_wrap),
        .am_pm_toggle(am_pm_toggle),
        .alarm_toggle(alarm_toggle),
        
        // Nhận thời gian thực để so sánh chuông
        .real_sec(real_sec),
        .real_min(real_min),
        .real_hour(real_hour),
        .real_am_pm(real_am_pm),
        
        // Xuất thời gian báo thức
        .alarm_min(alarm_min),
        .alarm_hour(alarm_hour),
        .alarm_am_pm(alarm_am_pm),
        
        // Trạng thái chuông và cài đặt
        .ring(alarm_ringing),
        .alarm_set(alarm_set)
    );
    
endmodule