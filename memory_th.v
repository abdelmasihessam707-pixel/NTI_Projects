`timescale 1ns / 1ps

module memory_th;

    parameter AWIDTH = 5;
    parameter DWIDTH = 8;

    reg                clk;
    reg                wr;
    reg                rd;
    reg  [AWIDTH-1:0]  addr;
    wire [DWIDTH-1:0]  data;

    reg  [DWIDTH-1:0]  data_driver;
    reg                drive_en;

    integer i;
    integer errors = 0;

    assign data = (drive_en) ? data_driver : 'bz;

    memory #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH)
    ) uut (
        .clk(clk),
        .wr(wr),
        .rd(rd),
        .addr(addr),
        .data(data)
    );

    always #5 clk = ~clk;

    initial begin
        clk         = 0;
        wr          = 0;
        rd          = 0;
        addr        = 0;
        data_driver = 0;
        drive_en    = 0;

        #10;

        for (i = 0; i < (1 << AWIDTH); i = i + 1) begin
            @(negedge clk);
            addr        = i;
            data_driver = i + 160;
            drive_en    = 1;
            wr          = 1;
            rd          = 0;
        end

        @(negedge clk);
        wr       = 0;
        drive_en = 0;

        #10;

        for (i = 0; i < (1 << AWIDTH); i = i + 1) begin
            @(negedge clk);
            addr = i;
            rd   = 1;
            #2;

        end

        @(negedge clk);
        rd = 0;
        #2;
        $finish;
    end

endmodule