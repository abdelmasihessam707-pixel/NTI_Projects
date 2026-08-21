`timescale 1ns / 1ps

module tb_digital_parking;

    reg        clk;
    reg        rst_n;
    reg        car_in;
    reg        car_out;
    reg  [3:0] spot_id;

    wire [9:0]  spots_resived;
    wire        is_full;
    wire [15:0] entry_time_out;
    wire [15:0] duration_out;
    wire [31:0] total_fee_out;

    integer k;
    reg [3:0] rand_spot;
    reg       rand_action; 
    integer   rand_delay;

    digital_parking #(
        .RATE_PER_UNIT(5) 
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .car_in(car_in),
        .car_out(car_out),
        .spot_id(spot_id),
        .spots_resived(spots_resived),
        .is_full(is_full),
        .entry_time_out(entry_time_out),
        .duration_out(duration_out),
        .total_fee_out(total_fee_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk     = 0;
        rst_n   = 0;
        car_in  = 0;
        car_out = 0;
        spot_id = 0;

        #15;
        rst_n = 1;
        #10;
        $display("--- STARTING SIMULATION ---");
        $display("==================================================");

        for (k = 0; k < 50; k = k + 1) begin
            
            rand_spot = {$random} % 10;

            rand_action = {$random} % 2;

            rand_delay = 10 + ({$random} % 40);

            spot_id = rand_spot;

            if (rand_action == 1) begin

                if (!spots_resived[rand_spot]) begin
                    car_in = 1'b1;
                    #10;
                    car_in = 1'b0;
                    #1;
                    $display("[ Time: %0t | Iteration %0d ] SUCCESS: Car ENTERED spot (%0d). Occupied map: %b", 
                             $time, k+1, rand_spot, spots_resived);
                end else begin
                    $display("[ Time: %0t | Iteration %0d ] BLOCKED: Spot (%0d) is ALREADY OCCUPIED.", 
                             $time, k+1, rand_spot);
                end
            end else begin
                if (spots_resived[rand_spot]) begin
                    car_out = 1'b1;
                    #10;
                    car_out = 1'b0;
                    #1;
                    $display("[ Time: %0t | Iteration %0d ] SUCCESS: Car EXITED spot (%0d)", $time, k+1, rand_spot);
                    $display("  Entry Time : %0d | Duration: %0d time units | Total Fee: %0d", 
                             entry_time_out, duration_out, total_fee_out);
                    $display(" Updated Occupied map: %b", spots_resived);
                end else begin
                    $display("[ Time: %0t | Iteration %0d ] IGNORED: Spot (%0d) is EMPTY, cannot exit.", 
                             $time, k+1, rand_spot);
                end
            end
            #(rand_delay);
        end
       $finish;
    end

endmodule