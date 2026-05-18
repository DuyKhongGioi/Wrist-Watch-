module input_module(
    input wire sysclk,    // 100MHz
    input wire reset,
    
    // Tín hiệu vật lý thô từ người dùng
    input wire PB1,
    input wire PB2,
    input wire PB3,
    
    // Ngõ ra đã được xử lý cấp cho Wristwatch FSM
    output wire clk_100Hz,
    output wire B1,
    output wire B2,
    output wire B3
);

    // ==========================================
    // 1. TẠO XUNG 100HZ 
    // ==========================================
    wire clk_100_internal;
    
    clock_gen_100 #(
        .CLK_THRESH(19'd500000)
    ) clk_gen_inst (
        .sysclk(sysclk),
        .reset(reset),
        .clk_100(clk_100_internal)
    );
    
    assign clk_100Hz = clk_100_internal;

    // ==========================================
    // 2. KHỐI CHỐNG RUNG & TẠO XUNG ĐƠN
    // ==========================================
    
    button_processor btn1_inst (
        .clk(clk_100_internal), 
        .reset(reset),
        .pb_in(PB1),
        .pulse_out(B1)
    );

    button_processor btn2_inst (
        .clk(clk_100_internal),
        .reset(reset),
        .pb_in(PB2),
        .pulse_out(B2)
    );

    button_processor btn3_inst (
        .clk(clk_100_internal),
        .reset(reset),
        .pb_in(PB3),
        .pulse_out(B3)
    );

endmodule