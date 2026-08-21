`timescale 1ns / 1ps

module register_tb;

    parameter WIDTH = 8;

    reg                 clk;
    reg                 rst;
    reg                 load;
    reg  [WIDTH-1:0]     data_in;
    wire [WIDTH-1:0]     data_out;

    register #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        data_in = 0;

        $monitor("At time %0t ns: rst=%b load=%b data_in=%0d data_out=%0d", 
                  $time, rst, load, data_in, data_out);

        #2 rst = 1;
        #3 rst = 0;

        #10;
        load = 1;
        data_in = 165;

        #10;
        load = 0;
        data_in = 255;

        #10;
        load = 1;
        data_in = 60;

        #4; 
        rst = 1;
        
        #5;
        rst = 0;

        #20;
        $finish;
    end

endmodule