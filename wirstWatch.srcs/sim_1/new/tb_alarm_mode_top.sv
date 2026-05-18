`timescale 1ns / 1ps

module tb_alarm_mode_top;

    // =========================================================
    // 1. KHAI BÁO TÍN HIỆU
    // =========================================================
    logic clk;
    logic reset;
    logic B2;
    logic B3;
    
    logic [5:0] real_sec;
    logic [5:0] real_min;
    logic [4:0] real_hour;
    logic [6:0] real_am_pm;
    
    logic [5:0] alarm_min;
    logic [4:0] alarm_hour;
    logic [6:0] alarm_am_pm;
    logic       alarm_ringing;
    logic       alarm_set;

    localparam logic [6:0] AM_VAL = 7'b0001000;
    localparam logic [6:0] PM_VAL = 7'b0011000;

    int error_count = 0;
    int test_count = 0;

    // =========================================================
    // 2. KHỞI TẠO DUT
    // =========================================================
    alarm_mode_top dut (.*); // Dùng wild-card connection cho gọn nếu tên port trùng khớp

    // =========================================================
    // 3. CLOCK GENERATION & WATCHDOG
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100Hz -> Chu kỳ giả lập 10ns
    end

    // Mất an toàn (Timeout): Nếu testbench chạy quá 200,000 ns mà chưa finish -> Kẹt
    initial begin
        #200000;
        $display("\n[FATAL ERROR] SIMULATION TIMEOUT! Kiem tra lai cac vong lap hoac RTL FSM bi ket.");
        $finish;
    end

    // =========================================================
    // 4. BACKGROUND MONITOR (CONCURRENT CHECKER)
    // =========================================================
    // SỬA Ở ĐÂY: Chuyển sang negedge để đợi mạch tổ hợp RTL ổn định
    always @(negedge clk) begin 
        if (!reset) begin
            logic expected_ring;
            expected_ring = (real_hour == alarm_hour) && 
                            (real_min == alarm_min) &&
                            (real_am_pm == alarm_am_pm) && 
                            (real_sec < 6'd49) && 
                            (alarm_set == 1'b1);
                            
            if (alarm_ringing !== expected_ring) begin
                $display("[MONITOR ERROR] Phat hien sai lech RINGING tai time %0t ns", $time);
                $display("  -> EXP_RING: %b | GOT_RING: %b", expected_ring, alarm_ringing);
                error_count++;
            end
        end
    end

    // =========================================================
    // 5. CÁC TASKS MÔ PHỎNG VÀ KIỂM TRA
    // =========================================================
    task wait_cycles(input int n);
        repeat(n) @(posedge clk);
    endtask

    task press_b2();
        B2 = 1; wait_cycles(1);
        B2 = 0; wait_cycles(2);
    endtask

    task press_b3();
        B3 = 1; wait_cycles(1);
        B3 = 0; wait_cycles(2);
    endtask

    // Task test bấm cả 2 nút cùng lúc
    task press_both();
        B2 = 1; B3 = 1; wait_cycles(1);
        B2 = 0; B3 = 0; wait_cycles(2);
    endtask

    task set_real_time(input logic [4:0] h, input logic [5:0] m, input logic [5:0] s, input logic [6:0] ap);
        real_hour = h; real_min = m; real_sec = s; real_am_pm = ap;
        wait_cycles(1);
    endtask

    task check_results(
        input logic [4:0] exp_hour, input logic [5:0] exp_min, 
        input logic [6:0] exp_am_pm, input logic exp_set, input string test_name
    );
        test_count++;
        // Không check exp_ring ở đây nữa vì đã có Background Monitor lo liệu
        if (alarm_hour === exp_hour && alarm_min === exp_min && 
            alarm_am_pm === exp_am_pm && alarm_set === exp_set) begin
            $display("[PASS] %-55s | H:%02d M:%02d AP:%b SET:%b", test_name, alarm_hour, alarm_min, alarm_am_pm, alarm_set);
        end else begin
            $display("[FAIL] %-55s", test_name);
            $display("       -> EXPECTED: H:%02d M:%02d AP:%b SET:%b", exp_hour, exp_min, exp_am_pm, exp_set);
            $display("       -> GOT     : H:%02d M:%02d AP:%b SET:%b", alarm_hour, alarm_min, alarm_am_pm, alarm_set);
            error_count++;
        end
    endtask

    // =========================================================
    // 6. MAIN TEST SCENARIOS
    // =========================================================
    initial begin
        // Reset hệ thống
        reset = 1; B2 = 0; B3 = 0;
        set_real_time(1, 0, 0, AM_VAL);
        
        $display("======================================================================");
        $display("   [SENIOR-LEVEL] BẮT ĐẦU CHẠY TESTBENCH CHI TIẾT CHO alarm_mode_top");
        $display("======================================================================");

        // --- SCENARIO 1: INIT ---
        $display("\n--- [SCENARIO 1] Kiem tra Reset ---");
        wait_cycles(2); reset = 0; wait_cycles(2);
        check_results(12, 0, AM_VAL, 0, "Gia tri sau Reset (12:00 AM, OFF)");

        // --- SCENARIO 2: STATE PERSISTENCE (Bền vững cờ Alarm) ---
        $display("\n--- [SCENARIO 2] Kiem tra do ben vung cua co Alarm Set ---");
        wait_cycles(1); 
        press_b3(); // Đang ở ALARM state -> Bật báo thức
        check_results(12, 0, AM_VAL, 1, "Bat bao thuc (alarm_set = 1)");
        
        press_b2(); // Chuyển sang SET_AHOURS
        check_results(12, 0, AM_VAL, 1, "Chuyen sang SET_AHOURS -> Bao thuc VAN PHAI BAT");
        
        press_b3(); // Đổi giờ thành 1
        check_results(1, 0, AM_VAL, 1, "Tang gio len 1 -> Bao thuc VAN PHAI BAT");

        // --- SCENARIO 3: AUTOMATED SWEEP (Quét vòng lặp Giờ) ---
        $display("\n--- [SCENARIO 3] Tu dong quet tang gio tu 1 đen 12 ---");
        for (int i = 2; i <= 12; i++) begin
            press_b3();
            check_results(i, 0, AM_VAL, 1, $sformatf("Quet gio: Tang len %0d", i));
        end
        // Tràn về 1
        press_b3();
        check_results(1, 0, AM_VAL, 1, "Quet gio: Rollover 12 -> 1 thanh cong");

        // --- SCENARIO 4: SIMULTANEOUS INPUTS (Bấm lộn xộn) ---
        $display("\n--- [SCENARIO 4] Bơm input khong hop le (Bam ca B2 & B3) ---");
        press_b2(); // Chuyển từ SET_AHOURS -> SET_AMINS
        press_both(); // Bấm cả 2 nút
        // Theo RTL FSM (if B2... else...), B2 có priority cao hơn do nằm trong lệnh `if`. 
        // Nên nó sẽ chuyển sang trạng thái tiếp theo (SET_AAM_PM) và KHÔNG tăng phút.
        check_results(1, 0, AM_VAL, 1, "Bam B2+B3 cung luc -> Ưu tien chuyen State (SET_AAM_PM)");

        // --- SCENARIO 5: BẬT TẮT CHUÔNG CHI TIẾT (Biên giới Giây) ---
        $display("\n--- [SCENARIO 5] Edge-Case giay thu 48, 49, 50 ---");
        press_b2(); // Quay ve ALARM state
        wait_cycles(2);
        
        // Setup báo thức là 1:00 AM. 
        set_real_time(1, 0, 48, AM_VAL);
        wait_cycles(2);
        $display("[INFO] real_sec = 48 -> Cho doi Background Monitor check...");

        set_real_time(1, 0, 49, AM_VAL);
        wait_cycles(2);
        $display("[INFO] real_sec = 49 -> Cho doi Background Monitor check...");

        set_real_time(1, 0, 50, AM_VAL);
        wait_cycles(2);
        $display("[INFO] real_sec = 50 -> Cho doi Background Monitor check...");

        // =========================================================
        // TỔNG KẾT BÁO CÁO
        // =========================================================
        $display("\n======================================================================");
        if (error_count == 0) begin
            $display("   [SUCCESS] XUAT SAC! 0 ERRORS TRONG TONG SO %0d CHECKS.", test_count);
            $display("             Background Monitor xac nhan khong co glitch o co Ringing.");
        end else begin
            $display("   [WARNING] FAILED WITH %0d ERRORS OUT OF %0d CHECKS.", error_count, test_count);
            $display("             Doc ky log tren de xem Background Monitor hoac Check Task failed cho nao.");
        end
        $display("======================================================================");
        
        $finish;
    end

endmodule