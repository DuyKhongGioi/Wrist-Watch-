`timescale 1ns / 1ps

module tb_clock_gen_100();

    // --- Khai báo các tín hiệu nội bộ ---
    reg sysclk;
    reg reset;
    wire clk_100;

    // --- Gọi module cần test (Instantiate DUT) ---
    // QUAN TRỌNG: Ghi đè CLK_THRESH = 5 để mô phỏng chạy nhanh
    // Thay vì phải chờ 500,000 chu kỳ, giờ nó chỉ đếm đến 5
    clock_gen_100 #(
        .CLK_THRESH(19'd5) 
    ) uut (
        .sysclk(sysclk),
        .reset(reset),
        .clk_100(clk_100)
    );

    // --- Tạo xung nhịp hệ thống sysclk ---
    // Giả sử sysclk là 100MHz => Chu kỳ T = 10ns
    initial begin
        sysclk = 0;
        forever #5 sysclk = ~sysclk; 
    end

    // --- Kịch bản Test ---
    initial begin
        // 1. Khởi tạo trạng thái ban đầu và kích hoạt Reset
        reset = 1;
        
        // Giữ reset trong 20ns (2 chu kỳ clock) để hệ thống ổn định
        #20; 
        reset = 0;

        // 2. Cho phép mạch chạy tự do
        // Vì CLK_THRESH = 5:
        // - Trạng thái INC đếm từ 0->4 (mất 5 chu kỳ = 50ns), clk_100 = 1
        // - Trạng thái DEC đếm từ 4->0 (mất 5 chu kỳ = 50ns), clk_100 = 0
        // Tổng 1 chu kỳ của clk_100 là 100ns.
        // Chạy 500ns là đủ để quan sát 5 chu kỳ vạch sóng hoàn chỉnh.
        #500;

        // 3. Kết thúc mô phỏng
        $display("Simulation finished!");
        $finish;
    end

endmodule