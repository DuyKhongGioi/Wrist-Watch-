`timescale 1ns / 1ps

module tb_time_mode_top;

    // =========================================================
    // 1. Khai báo tín hiệu (Signals Declaration)
    // =========================================================
    logic clk;
    logic reset;
    logic B2;
    logic B3;
    
    logic [5:0] sec_cnt;
    logic [5:0] min_cnt;
    logic [4:0] hour_cnt;
    logic [6:0] am_pm_out;

    // =========================================================
    // 2. Định nghĩa hằng số cho AM/PM
    // =========================================================
    localparam logic [6:0] PM_VAL = 7'b0011000;
    localparam logic [6:0] AM_VAL = 7'b0001000;

    // Biến theo dõi kết quả test
    int error_count = 0;
    int test_count = 0;

    // =========================================================
    // 3. Khởi tạo DUT (Device Under Test)
    // =========================================================
    time_mode_top dut (
        .clk(clk),
        .reset(reset),
        .B2(B2),
        .B3(B3),
        .sec_cnt(sec_cnt),
        .min_cnt(min_cnt),
        .hour_cnt(hour_cnt),
        .am_pm_out(am_pm_out)
    );

    // =========================================================
    // 4. Tạo xung nhịp (Clock Generation) - 100Hz
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // =========================================================
    // 5. Khai báo các TASKS mô phỏng hành vi & kiểm tra
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

    task check_results(
        input logic [5:0] exp_sec,
        input logic [5:0] exp_min,
        input logic [4:0] exp_hour,
        input logic [6:0] exp_am_pm,
        input string test_name
    );
        test_count++;
        if (sec_cnt === exp_sec && min_cnt === exp_min && hour_cnt === exp_hour && am_pm_out === exp_am_pm) begin
            $display("[PASS] @%0t | %-45s | S:%02d M:%02d H:%02d AP:%b", $time, test_name, sec_cnt, min_cnt, hour_cnt, am_pm_out);
        end else begin
            $display("[FAIL] @%0t | %-45s", $time, test_name);
            $display("       -> EXPECTED: S:%02d M:%02d H:%02d AP:%b", exp_sec, exp_min, exp_hour, exp_am_pm);
            $display("       -> GOT     : S:%02d M:%02d H:%02d AP:%b", sec_cnt, min_cnt, hour_cnt, am_pm_out);
            error_count++;
        end
    endtask

    // =========================================================
    // 6. KỊCH BẢN TEST (Test Scenarios)
    // =========================================================
    initial begin
        reset = 0; B2 = 0; B3 = 0;
        
        $display("=========================================================================");
        $display("   BẮT ĐẦU CHẠY TESTBENCH CHO time_mode_top (Updated for 12-Hour Init)");
        $display("=========================================================================");

        // ---------------------------------------------------------
        // SCENARIO 1: KHỞI TẠO VÀ RESET
        // ---------------------------------------------------------
        $display("\n--- [SCENARIO 1] Kiểm tra Reset ---");
        reset = 1; wait_cycles(2);
        reset = 0; wait_cycles(2);
        // Đã cập nhật: Sau reset Giờ phải là 12, AM/PM phải là AM
        check_results(0, 0, 12, AM_VAL, "Gia tri mac dinh sau khi Reset (12:00:00 AM)");

        // ---------------------------------------------------------
        // SCENARIO 2: CHẠY BÌNH THƯỜNG
        // ---------------------------------------------------------
        $display("\n--- [SCENARIO 2] Kiem tra chay thoi gian thuc ---");
        wait_cycles(100); 
        check_results(1, 0, 12, AM_VAL, "Giay tang len 1 sau 100 cycles");

        wait_cycles(5900);
        check_results(0, 1, 12, AM_VAL, "Rollover: 59 giay -> 0 giay, tang 1 phut");

        // ---------------------------------------------------------
        // SCENARIO 3: SỰ CÁCH LY TRẠNG THÁI (SET_HOURS)
        // ---------------------------------------------------------
        $display("\n--- [SCENARIO 3] Chuyen qua SET_HOURS va kiem tra State Isolation ---");
        press_b2(); // Chuyển từ TIME -> SET_HOURS
        
        // Đang là 12 giờ. Bấm B3 một lần sẽ vòng về 1. (Không lật AM/PM)
        press_b3();
        check_results(0, 1, 1, AM_VAL, "SET_HOURS: Bam B3 wrap 12 -> 1 gio. Phut, Giay giu nguyen");

        // ---------------------------------------------------------
        // SCENARIO 4: TRÀN BỘ ĐẾM GIỜ VÀ AM/PM TOGGLE
        // ---------------------------------------------------------
        $display("\n--- [SCENARIO 4] Wrap-around ranh gioi Gio & AM/PM ---");
        // Giờ đang là 1. Ta bấm thêm 10 lần nữa để lên 11
        repeat(10) press_b3();
        check_results(0, 1, 11, AM_VAL, "SET_HOURS: Tang len 11 gio");
        
        // Bấm thêm 1 lần để lên 12 -> Lật sang PM
        press_b3();
        check_results(0, 1, 12, PM_VAL, "SET_HOURS: Gio len 12, AM/PM Toggle sang PM");

        // Bấm thêm 1 lần nữa để kiểm tra tràn 12 -> 1
        press_b3();
        check_results(0, 1, 1, PM_VAL, "SET_HOURS: Gio tran tu 12 ve 1. AM/PM giu nguyen PM");

        // ---------------------------------------------------------
        // SCENARIO 5: SỰ CÁCH LY TRONG SET_MINS VÀ NATURAL WRAP FIX
        // ---------------------------------------------------------
        $display("\n--- [SCENARIO 5] Chuyen qua SET_MINS, kiem tra phut tran khong anh huong gio ---");
        press_b2(); // Chuyển từ SET_HOURS -> SET_MINS
        
        // Phút đang là 1. Bấm B3 58 lần để lên 59.
        repeat(58) press_b3();
        check_results(0, 59, 1, PM_VAL, "SET_MINS: Tang phut len 59");

        // Bấm lần nữa để tràn phút 59 -> 0. Giờ KHÔNG ĐƯỢC TĂNG.
        press_b3();
        check_results(0, 0, 1, PM_VAL, "SET_MINS: Rollover phut 59->0. GIO KHONG BI TANG THEO");

        // ---------------------------------------------------------
        // SCENARIO 6: TRỞ VỀ CHẾ ĐỘ THỜI GIAN THỰC
        // ---------------------------------------------------------
        $display("\n--- [SCENARIO 6] Tro ve TIME mode (Resume counting) ---");
        press_b2(); // Chuyển từ SET_MINS -> TIME
        wait_cycles(100); // Chờ 1 giây
        check_results(1, 0, 1, PM_VAL, "TIME MODE: Bo dem thoi gian tiep tuc chay dung");

        // =========================================================
        // 7. TỔNG KẾT BÁO CÁO
        // =========================================================
        $display("=========================================================================");
        if (error_count == 0) begin
            $display("   [SUCCESS] ALL %0d TESTS PASSED SUON SE! RTL CUA BAN RAT XIN!", test_count);
        end else begin
            $display("   [WARNING] FAILED WITH %0d ERRORS OUT OF %0d TESTS.", error_count, test_count);
        end
        $display("=========================================================================");
        
        $finish;
    end

endmodule