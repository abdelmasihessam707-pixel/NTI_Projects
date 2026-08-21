
module th_datapath();

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

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst_n = 0;
        wr_en = 0;
        addr  = 0;
        din   = 0;

        #20;
        rst_n = 1;

        @(posedge clk);
        wr_en = 1; addr = 8'd0; din = {1'b1, 3'b000, 8'd10, 8'd20};

        @(posedge clk);
        addr = 8'd1; din = {1'b1, 3'b001, 8'd50, 8'd15};

        @(posedge clk);
        addr = 8'd2; din = {1'b1, 3'b010, 8'b11111111, 8'b00001111};

        @(posedge clk);
        addr = 8'd3; din = {1'b1, 3'b000, 8'b00000000, 8'b00000101};

        @(posedge clk);
        wr_en = 0;

        addr = 8'd0;
        #410;
        $display("[Time %0t ns] Vector 0 (ADD 10+20)  => Output ", $time, alu_out, a_is_zero);

        addr = 8'd1;
        #430;
        $display("[Time %0t ns] Vector 1 (SUB 50-15)  => Output", $time, alu_out, a_is_zero);

        addr = 8'd2;
        #450;
        $display("[Time %0t ns] Vector 2 (AND 255&15) => Output =", $time, alu_out, a_is_zero);

        addr = 8'd3;
        #470;
        $display("[Time %0t ns] Vector 3 (Zero Flag)  => Output ", $time, alu_out, a_is_zero);

        #50;
        $finish;
    end

endmodule