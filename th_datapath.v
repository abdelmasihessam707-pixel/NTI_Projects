`timescale 1ns / 1ps

module th_datapath();

    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 20;
    parameter ALU_WIDTH  = 8;

    reg                   clk;
    reg                   rst_n;
    reg                   start_read;
    reg                   wr_en;
    reg  [ADDR_WIDTH-1:0] addr;
    reg  [DATA_WIDTH-1:0] din;

    wire [ALU_WIDTH-1:0]  alu_out;
    wire                  a_is_zero;
    wire                  busy;

    datapath_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ALU_WIDTH(ALU_WIDTH)
    ) uut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start_read(start_read),
        .wr_en     (wr_en),
        .addr      (addr),
        .din       (din),
        .alu_out   (alu_out),
        .a_is_zero (a_is_zero),
        .busy      (busy)
    );

    always #5 clk = ~clk;

    task read_vector(input [7:0] rd_addr, input [8*25:1] test_name);
        begin
            addr = rd_addr;
            start_read = 1'b1;
            @(posedge clk);
            start_read = 1'b0;
            wait(busy == 1'b1);
            wait(busy == 1'b0);
            #1;

            $display("[Time %0t ns] %s => Output = %0d | Zero Flag = %b", 
                     $time, test_name, alu_out, a_is_zero);
        end
    endtask

    initial begin

        clk        = 0;
        rst_n      = 0;
        start_read = 0;
        wr_en      = 0;
        addr       = 0;
        din        = 0;

        #20;
        rst_n = 1;
        #10;

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
        #20;

        // 2. Read & Execute Phase
        read_vector(8'd0, "Vector 0 (ADD 10+20)   ");
        #20;
        read_vector(8'd1, "Vector 1 (SUB 50-15)   ");
        #20;
        read_vector(8'd2, "Vector 2 (AND 255&15)  ");
        #20;
        read_vector(8'd3, "Vector 3 (Zero Flag)   ");

      

        #50;
        $finish;
    end

endmodule