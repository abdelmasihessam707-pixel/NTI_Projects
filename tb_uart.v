`timescale 1ns / 1ps

module tb_uart;

    parameter CLK_FREQ  = 50_000_000; 
    parameter BAUD_RATE = 115200;     
    localparam CLK_PERIOD = 1000000000 / CLK_FREQ; 
    localparam BIT_PERIOD = 1000000000 / BAUD_RATE;

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx;
    wire       tx_busy;
    wire       rx;
    wire [7:0] rx_data;
    wire       rx_valid;

    assign rx = tx;

    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy),
        .rx(rx),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    always #(CLK_PERIOD / 2) clk = ~clk;
    task send_byte(input [7:0] data_in);
        begin

            wait(!tx_busy);
            @(posedge clk);
            tx_data  <= data_in;
            tx_start <= 1'b1;
            @(posedge clk);
            tx_start <= 1'b0;
            
            $display("Sending Byte: 0x%d (%c)", data_in, data_in);
        end
    endtask

    always @(posedge clk) begin
        if (rx_valid) begin
            $display(" Received Byte: 0x%d (%c)", , rx_data, rx_data);
            if (rx_data === tx_data) begin
                $display("[PASS] Data matched successfully!\n");
            end else begin
                $display("[ERROR] Mismatch! Expected: 0x%d, Got: 0x%d\n", tx_data, rx_data);
            end
        end
    end
    
    initial begin
        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        #(CLK_PERIOD * 10);
        rst_n = 1;
        #(CLK_PERIOD * 10);


        $display("       Starting UART Simulation         ");

        send_byte(77); 
        #(BIT_PERIOD * 11); 

        send_byte(85); 
        #(BIT_PERIOD * 11);

        send_byte(165); 
        #(BIT_PERIOD * 11);

        send_byte(90); 
        #(BIT_PERIOD * 11);

        $display("    Simulation Finished   ");

        $finish;
    end

endmodule