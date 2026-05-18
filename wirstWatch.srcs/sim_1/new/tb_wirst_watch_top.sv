`timescale 1ns / 1ps

module tb_wrist_watch_top;

    // =========================================================
    // 1. KHAI BÁO TÍN HIỆU
    // =========================================================
    logic sysclk_100mhz;
    logic pb_reset;
    logic pb_b1;
    logic pb_b2;
    logic pb_b3;
    
    logic [15:0] leds_out;
    logic [6:0] seg;
    logic [3:0] an;
    logic buzzer_ring;

    // =========================================================
    // 2. KHỞI TẠO DUT (Device Under Test)
    // =========================================================
    wristwatch dut (
        .sysclk_100mhz(sysclk_100mhz),
        .pb_reset(pb_reset),
        .pb_b1(pb_b1),
        .pb_b2(pb_b2),
        .pb_b3(pb_b3),
        .leds_out(leds_out),
        .seg(seg),
        .an(an),
        .buzzer_ring(buzzer_ring)
    );

    // =========================================================
    // 3. HACK THỜI GIAN MÔ PHỎNG (SIMULATION SPEED-UP)
    // =========================================================
    // Thay vì đếm 500,000 để tạo 100Hz, ta ép nó đếm 5 thôi.
    // Xung clk_100Hz bây giờ sẽ nhảy cực kỳ nhanh!
    defparam dut.u_input_processing.clk_gen_inst.CLK_THRESH = 19'd5;

    // =========================================================
    // 4. CLOCK & WATCHDOG
    // =========================================================
    initial begin
        sysclk_100mhz = 0;
        forever #5 sysclk_100mhz = ~sysclk_100mhz; // 100MHz (10ns period)
    end

    initial begin
        #500000; // Giới hạn mô phỏng an toàn
        $display("\n[FATAL] Timeout mô phỏng!");
        $finish;
    end

    // =========================================================
    // 5. TASKS BẤM NÚT ĐÃ ĐƯỢC TĂNG THỜI GIAN ĐÈ GIỮ (FIXED)
    // =========================================================
    task press_b1();
        pb_b1 = 1; #1000; // Đè giữ 1000ns để lọt qua Debouncer
        pb_b1 = 0; #1000; // Nhả nút và đợi ổn định
    endtask

    task press_b2();
        pb_b2 = 1; #1000; 
        pb_b2 = 0; #1000;
    endtask

    task press_b3();
        pb_b3 = 1; #1000; 
        pb_b3 = 0; #1000;
    endtask

    // =========================================================
    // 6. KỊCH BẢN TEST HỆ THỐNG
    // =========================================================
    initial begin
        // Khởi tạo
        pb_reset = 1; pb_b1 = 0; pb_b2 = 0; pb_b3 = 0;
        
        $display("=========================================================");
        $display("   [SYSTEM TEST] KIỂM TRA TOP-LEVEL WRISTWATCH");
        $display("   (Đã bật chế độ Tua nhanh thời gian bằng defparam)");
        $display("=========================================================");

        // --- BƯỚC 1: RESET HỆ THỐNG ---
        #50; pb_reset = 0; #100;
        $display("[INFO] Da hoan thanh Reset.");
        
        // --- BƯỚC 2: CHUYỂN SANG ALARM MODE & BẬT BÁO THỨC ---
        $display("[TEST 1] Chuyen Mode sang ALARM bang nut B1...");
        press_b1();
        
        $display("[TEST 2] Bam B3 de bat co Alarm (LED 15)...");
        press_b3();
        
        #50;
        if (leds_out[15] === 1'b1) 
            $display("  -> [PASS] LED 15 da SANG! Co Alarm da bat qua nut nhan vat ly.");
        else 
            $display("  -> [FAIL] LED 15 khong sang. Kiem tra lai mach Debouncer!");

        // --- BƯỚC 3: KIỂM TRA MẠCH HIỂN THỊ ĐA KÊNH 7-SEG ---
        $display("[TEST 3] Thu doc tin hieu mach quet LED 7 đoan (seg & an)...");
        // Chờ một chút để mạch quét refresh
        #2000;
        $display("  -> Hien tai an = %b, seg = %b", an, seg);
        
        // --- BƯỚC 4: TUA THỜI GIAN KIỂM TRA CHUÔNG ---
        $display("[TEST 4] Ve TIME MODE, tang gio bang B2/B3 đe test ring...");
        press_b1(); // Ve Time Mode
        press_b2(); // Vao Set Hours
        press_b3(); // Tang len 1 gio (chuong bao thuc mac đinh la 12:00)
        
        $display("  [INFO] Tu mo Waveform đe xem kieu quet LED an/seg va co Buzzer nhe!");
        
        #10000;
        $display("=========================================================");
        $display("   TESTBENCH HOAN THANH!");
        $display("=========================================================");
        $finish;
    end

endmodule