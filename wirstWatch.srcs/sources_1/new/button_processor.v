module button_processor(
    input wire clk,       // Xung nhịp 100Hz
    input wire reset,
    input wire pb_in,     // Nút bấm vật lý (Raw)
    output wire pulse_out // Xung đơn rộng 1 chu kỳ clock
);

    // --- Tầng 1: Synchronizer (Đưa tín hiệu vào vùng clock an toàn) ---
    reg sync_0, sync_1;
    always @(posedge clk) begin
        if (reset) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= pb_in;
            sync_1 <= sync_0;
        end
    end

    // --- Tầng 2: Debouncer (Chờ ổn định 20ms) ---
    reg [1:0] debounce_cnt;
    reg pb_stable;
    
    always @(posedge clk) begin
        if (reset) begin
            debounce_cnt <= 2'd0;
            pb_stable <= 1'b0;
        end else begin
            if (sync_1 != pb_stable) begin
                debounce_cnt <= debounce_cnt + 1'b1;
                // Nếu khác biệt giữ nguyên trong 2 chu kỳ (2 x 10ms = 20ms)
                if (debounce_cnt == 2'd2) begin
                    pb_stable <= sync_1;
                    debounce_cnt <= 2'd0;
                end
            end else begin
                debounce_cnt <= 2'd0; // Reset đếm nếu nhiễu
            end
        end
    end

    // --- Tầng 3: Edge Detector (Phát hiện sườn lên tạo xung đơn) ---
    reg pb_stable_d; // Lưu trạng thái chu kỳ trước
    
    always @(posedge clk) begin
        if (reset) begin
            pb_stable_d <= 1'b0;
        end else begin
            pb_stable_d <= pb_stable;
        end
    end

    // Xung được tạo ra khi: Hiện tại Đang Bấm (1) VÀ Trước đó Chưa Bấm (0)
    assign pulse_out = pb_stable & ~pb_stable_d;

endmodule