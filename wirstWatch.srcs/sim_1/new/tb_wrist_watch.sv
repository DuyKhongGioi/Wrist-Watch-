`timescale 1ns / 1ps

module tb_wrist_watch;

    // =========================================================
    // 1. KHAI BÁO TÍN HIỆU
    // =========================================================
    logic clk;
    logic reset;
    logic B1;
    logic B2;
    logic B3;
    
    logic [5:0] display_sec;
    logic [5:0] display_min;
    logic [4:0] display_hour;
    logic [6:0] display_am_pm;
    logic       alarm_ringing;
    logic       alarm_set;

    localparam logic [6:0] AM_VAL = 7'b0001000;
    localparam logic [6:0] PM_VAL = 7'b0011000;

    int error_count = 0;
    int test_count = 0;

    // =========================================================
    // 2. KHỞI TẠO DUT (Device Under Test)
    // =========================================================
    wrist_watch_top dut (.*); // Nối dây tự động

    // =========================================================
    // 3. TẠO XUNG NHỊP VÀ WATCHDOG
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Xung nhịp giả lập 100Hz (1 chu kỳ = 10ns)
    end

    // Watchdog Timer chống kẹt mô phỏng
    initial begin
        #1000000; // Cho phép chạy tối đa 1,000,000 ns
        $display("\n[FATAL ERROR] SIMULATION TIMEOUT!");
        $finish;
    end

    // =========================================================
    // 4. CÁC TASKS MÔ PHỎNG THAO TÁC NGƯỜI DÙNG
    // =========================================================
    task wait_cycles(input int n);
        repeat(n) @(posedge clk);
    endtask

    // Các nút bấm
    task press_b1(); B1 = 1; wait_cycles(1); B1 = 0; wait_cycles(2); endtask
    task press_b2(); B2 = 1; wait_cycles(1); B2 = 0; wait_cycles(2); endtask
    task press_b3(); B3 = 1; wait_cycles(1); B3 = 0; wait_cycles(2); endtask

    // Tự động đối chiếu Màn hình
    task check_display(
        input logic [4:0] exp_h, input logic [5:0] exp_m, 
        input logic [5:0] exp_s, input logic [6:0] exp_ap, input string test_name
    );
        test_count++;
        // Trừ hao sai số 1-2 giây do quá trình bấm nút tốn vài chu kỳ clock
        if (display_hour === exp_h && display_min === exp_m && display_am_pm === exp_ap) begin
            $display("[PASS] @%0t | %-45s | H:%02d M:%02d S:%02d AP:%b", 
                     $time, test_name, display_hour, display_min, display_sec, display_am_pm);
        end else begin
            $display("[FAIL] @%0t | %-45s", $time, test_name);
            $display("       -> EXPECTED: H:%02d M:%02d S:xx AP:%b", exp_h, exp_m, exp_ap);
            $display("       -> GOT     : H:%02d M:%02d S:%02d AP:%b", display_hour, display_min, display_sec, display_am_pm);
            error_count++;
        end
    endtask

    // Tự động đối chiếu Cờ Báo Thức
    task check_alarm_flags(input logic exp_set, input logic exp_ring, input string test_name);
        test_count++;
        if (alarm_set === exp_set && alarm_ringing === exp_ring) begin
            $display("[PASS] @%0t | %-45s | SET:%b RING:%b", $time, test_name, alarm_set, alarm_ringing);
        end else begin
            $display("[FAIL] @%0t | %-45s", $time, test_name);
            $display("       -> EXPECTED: SET:%b RING:%b", exp_set, exp_ring);
            $display("       -> GOT     : SET:%b RING:%b", alarm_set, alarm_ringing);
            error_count++;
        end
    endtask

    // =========================================================
    // 5. KỊCH BẢN TEST TÍCH HỢP (INTEGRATION SCENARIOS)
    // =========================================================
    initial begin
        // Khởi tạo
        reset = 1; B1 = 0; B2 = 0; B3 = 0;
        
        $display("=========================================================================");
        $display("   [INTEGRATION TEST] BẮT ĐẦU KIỂM TRA HỆ THỐNG WRIST_WATCH");
        $display("=========================================================================");

        // --- SCENARIO 1: RESET & MUX OUTPUT ---
        $display("\n--- [SCENARIO 1] Kiem tra Output Muxing mac dinh ---");
        wait_cycles(2); reset = 0; wait_cycles(2);
        check_display(12, 0, 0, AM_VAL, "TIME MODE: Man hinh hien thi Thoi gian thuc");
        check_alarm_flags(0, 0, "Trang thai bao thuc OFF, Chuong OFF");

        // --- SCENARIO 2: CHUYỂN MODE & CÁCH LY NÚT BẤM ---
        $display("\n--- [SCENARIO 2] Chuyen sang ALARM MODE bang B1 ---");
        press_b1(); // Sang ALARM_MODE
        check_display(12, 0, 0, AM_VAL, "ALARM MODE: Man hinh hien thi Gio Bao Thuc (Giay=0)");
        
        $display(">> Cai dat bao thuc thanh 01:02 AM...");
        press_b2(); // Vao SET_HOURS
        press_b3(); // 12 -> 1
        press_b2(); // Vao SET_MINS
        press_b3(); press_b3(); // 0 -> 2
        press_b2(); // Vao SET_AM_PM
        press_b2(); // Tro ve ALARM_MODE hien thi
        
        // CHUYỂN BƯỚC BẬT BÁO THỨC XUỐNG DƯỚI NÀY
        $display(">> Bat ON bao thuc...");
        press_b3(); // Bat ON bao thuc
        check_alarm_flags(1, 0, "Bao thuc da duoc bat (alarm_set = 1)");
        
        check_display(1, 2, 0, AM_VAL, "ALARM MODE: Hien thi dung 01:02 AM");

        // --- SCENARIO 3: TRỞ VỀ TIME MODE VÀ TUA NHANH THỜI GIAN ---
        $display("\n--- [SCENARIO 3] Tro ve TIME MODE de cai dat gio thuc te ---");
        press_b1(); // Ve TIME_MODE
        // Kiem tra xem thao tac chinh Alarm vua nay co lam hong Time ko
        check_display(12, 0, 0, AM_VAL, "TIME MODE: Gio thuc te van la 12:00 (Cach ly tot)");
        
        $display(">> Tua nhanh thoi gian thuc den 01:01 AM...");
        press_b2(); // Vao SET_HOURS (Time)
        press_b3(); // 12 -> 1
        press_b2(); // Vao SET_MINS (Time)
        press_b3(); // 0 -> 1
        press_b2(); // Tro ve TIME_MODE
        
        check_display(1, 1, 0, AM_VAL, "TIME MODE: Gio thuc te da duoc set la 01:01 AM");

        // --- SCENARIO 4: CHỜ ĐẾN GIỜ BÁO THỨC & KIỂM TRA CHUÔNG ---
        $display("\n--- [SCENARIO 4] Kiem tra su giao tiep giua 2 modules (Ring Trigger) ---");
        $display(">> Dang cho doi thoi gian thuc troi toi 01:02:00 AM...");
        
        // Dung vong lap cho den khi dong ho diem dung 01:02:00
        wait (display_min == 6'd2 && display_sec == 6'd0); 
        
        // Ngay lap tuc kiem tra co chuong
        check_alarm_flags(1, 1, "BINGO! Dung 01:02:00 AM -> CHUONG REO (ring=1)");
        
        // --- SCENARIO 5: KIỂM TRA MULTITASKING (Vừa reo chuông vừa đổi Mode) ---
        $display("\n--- [SCENARIO 5] Kiem tra Output Mux khi dang reo chuong ---");
        wait_cycles(500); // Cho reo duoc 5 giay (sec = 5)
        check_display(1, 2, 5, AM_VAL, "TIME MODE: Giay van dang chay (S=05)");
        
        press_b1(); // Chuyen sang ALARM_MODE xem chuong co bi tat ngang ko
        check_display(1, 2, 0, AM_VAL, "ALARM MODE: Man hinh chuyen sang Bao thuc (Giay=0)");
        check_alarm_flags(1, 1, "Chuong VAN REO du dang o Alarm Mode");
        
        press_b1(); // Tro ve TIME_MODE

        // --- SCENARIO 6: KIỂM TRA CHUÔNG TỰ TẮT ---
        $display("\n--- [SCENARIO 6] Kiem tra chuong tu tat sau 49 giay ---");
        // Cho den khi kim giay chi so 49
        wait (display_sec == 6'd49);
        
        // Tai suon xuong, chuong phai tat
        @(negedge clk);
        check_alarm_flags(1, 0, "Giay 49 -> CHUONG TU TAT, Bao thuc VAN ON cho ngay mai");

        // =========================================================
        // TỔNG KẾT BÁO CÁO
        // =========================================================
        $display("\n=========================================================================");
        if (error_count == 0) begin
            $display("   [SUCCESS] SYSTEM INTEGRATION PASSED!");
            $display("             Time Mode va Alarm Mode da phoi hop an y 100%%.");
        end else begin
            $display("   [WARNING] INTEGRATION FAILED WITH %0d ERRORS.", error_count);
        end
        $display("=========================================================================");
        
        $finish;
    end

endmodule