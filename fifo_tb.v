`timescale 1ns / 1ps

module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;

    reg                  clk;
    reg                  rst_n;
    reg                  wr_en;
    reg                  rd_en;
    reg [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;
    wire                  full;
    wire                  empty;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    always #5 clk = ~clk;

    reg rand_op;
    integer i;
    integer change_count;

    initial begin

        clk          = 0;
        rst_n        = 0;
        wr_en        = 0;
        rd_en        = 0;
        din          = 0;
        change_count = 0;

        #15 rst_n = 1;
        $display("=== Start Test ===");

        for (i = 0; i < 100; i = i + 1) begin
            @(posedge clk);

            rand_op = $urandom % 2; 
            din     = $urandom_range(0, 255);
             #5
            case (rand_op)
                1'b0: begin 
                    wr_en = 1'b1;
                    rd_en = 1'b0;
                    change_count = change_count + 1;
                    if (!full)
                        $display("[Change #%0d] [WRITE] Data = %d", change_count, din);
                    else
                        $display("[Change #%0d] [WRITE IGNORED] FIFO Full!", change_count);
                end

                1'b1: begin 
                    wr_en = 1'b0;
                    rd_en = 1'b1;
                    change_count = change_count + 1;
                    if (!empty)
                        $display("[Change #%0d] [READ] Data = %d", change_count, dout);
                    else
                        $display("[Change #%0d] [READ IGNORED] FIFO Empty!", change_count);
                end
            endcase
        end

        @(posedge clk);
        wr_en = 0;
        rd_en = 0;
        
        #20;
        $display("=== DONE ===");
        $finish;
    end

endmodule
