`timescale 1ns / 1ps

module tb_datapath();

    // ==========================================
    // Parameters & Signals
    // ==========================================
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 20;
    parameter ALU_WIDTH  = 8;

    reg                    clk;
    reg                    rst_n;
    reg                    wr_en;
    reg  [ADDR_WIDTH-1:0]  addr;
    reg  [DATA_WIDTH-1:0]  din;

    wire [ALU_WIDTH-1:0]   alu_out;
    wire                   a_is_zero;

    // ==========================================
    // Module Instantiation (UUT)
    // ==========================================
    datapath_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_WIDTH(ALU_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .addr(addr),
        .din(din),
        .alu_out(alu_out),
        .a_is_zero(a_is_zero)
    );

    // ==========================================
    // Clock Generation (100MHz)
    // ==========================================
    always #5 clk = ~clk;

    // ==========================================
    // Variables for Random Test
    // ==========================================
    reg [2:0]       rand_op;
    reg [7:0]       rand_a;
    reg [7:0]       rand_b;
    reg [DATA_WIDTH-1:0] rand_vector;

    // ==========================================
    // Tasks
    // ==========================================

    // Task 1: توليد وتخزين متجه عشوائي
    task write_random_vector;
        input [ADDR_WIDTH-1:0] t_addr;
        begin
            // توليد مدخلات عشوائية
            rand_op = $urandom_range(0, 5); // اختيار عملية من 0 لـ 5 (ADD, SUB, AND, XOR, OR, OUT_A)
            rand_a  = $urandom_range(0, 255);
            rand_b  = $urandom_range(0, 255);
            
            // تجميع الـ 20-bit vector: {alu_en=1, opcode(3), in_a(8), in_b(8)}
            rand_vector = {1'b1, rand_op, rand_a, rand_b};

            @(posedge clk);
            wr_en = 1;
            addr  = t_addr;
            din   = rand_vector;
            
            $display("[RAM Write] Addr: %0d | Opcode: %0b | A: %0d | B: %0d", t_addr, rand_op, rand_a, rand_b);
            
            @(posedge clk);
            wr_en = 0;
        end
    endtask

    // Task 2: الانتظار وطباعة نتيجة المحاكاة
    task check_result;
        input integer vector_num;
        input integer wait_ns;
        begin
            #(wait_ns);
            $display("--------------------------------------------------");
            $display("[Time %0t ns] Vector %0d Executed:", $time, vector_num);
            $display("  => ALU Output = %d (Hex: 0x%0h)", alu_out, alu_out);
            $display("  => Zero Flag  = %b", a_is_zero);
        end
    endtask

    // ==========================================
    // Main Test Sequence
    // ==========================================
    integer i;

    initial begin
        // 1. التهيئة الأولية
        clk   = 0;
        rst_n = 0;
        wr_en = 0;
        addr  = 0;
        din   = 0;

        #10;

        $display("==================================================");
        $display("       GENERATING RANDOM TEST VECTORS             ");
        $display("==================================================");

        // 2. تعبئة أول 5 عناوين في الـ RAM ببيانات عشوائية أثناء الـ Reset
        for (i = 0; i < 5; i = i + 1) begin
            write_random_vector(i);
        end

        // إعادة ضبط العنوان للبدء من 0
        @(posedge clk);
        addr = 0;
        #10;

        // 3. تشغيل الدائرة
        rst_n = 1;

        $display("==================================================");
        $display("        DATAPATH SIMULATION STARTED               ");
        $display("==================================================");

        // 4. قراءة وفحص النتائج لكل المتجهات العشوائية
        check_result(0, 430); // أول عملية بتحتاج 220ns
        for (i = 1; i < 5; i = i + 1) begin
            check_result(i, 210);
        end

        $display("==================================================");
        $display("        SIMULATION COMPLETED SUCCESSFULLY          ");
        $display("==================================================");

        #50;
        $finish;
    end

endmodule