`timescale 1ns / 1ps

module top_sipo_alu_tb;
    parameter SIPO_WIDTH = 20;
    parameter ALU_WIDTH  = 8;

    reg                   clk;
    reg                   rst_n;
    reg                   shift_en;
    reg                   serial_in;

    wire [ALU_WIDTH-1:0]  alu_out;
    wire                  a_is_zero;

    top_sipo_alu #(
        .SIPO_WIDTH(SIPO_WIDTH),
        .ALU_WIDTH(ALU_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .shift_en(shift_en),
        .serial_in(serial_in),
        .alu_out(alu_out),
        .a_is_zero(a_is_zero)
    );

    always #5 clk = ~clk;

    task send_and_print(
        input        alu_en,
        input [2:0]  opcode,
        input [7:0]  in_a,
        input [7:0]  in_b,
        input [8*15:1] op_name  
    );
        integer i;
        reg [19:0] data;
        begin
            data = {alu_en, opcode, in_a, in_b};
            shift_en = 1'b1;
            for (i = 19; i >= 0; i = i - 1) begin
                serial_in = data[i];
                @(posedge clk);
            end
            shift_en = 1'b0;
           #1;

          //  $display("-------------------------------------------------------");
            //$display("[%0t ns] Op: %s | alu_en: %b | in_a: %0d | in_b: %0d", 
              //       $time, op_name, alu_en, in_a, in_b);
            
            if (!alu_en) begin
                $display(" ALU Disabled -> Output forced to 0");
            end else begin
                case (opcode)
                  3'b000: $display("       Equation: %0d + %0d = %0d", in_a, in_b, alu_out);
                  3'b001: $display("       Equation: %0d - %0d = %0d", in_a, in_b, alu_out);
                  3'b010: $display("       Equation: 8'b%0b & 8'b%0b = 8'b%0b ", in_a, in_b, alu_out);
                  3'b011: $display("       Equation: 8'b%0b ^ 8'b%0b = 8'b%0b ", in_a, in_b, alu_out);
                  3'b100: $display("       Equation: 8'b%0b | 8'b%0b = 8'b%0b ", in_a, in_b, alu_out);
                  3'b101: $display("       Equation: PASS A = %0d", alu_out);
                  default: $display("       Equation: Unknown Opcode");
                endcase
            end

            $display("       Result -> alu_out: %0d | a_is_zero: %b", alu_out, a_is_zero);
        end
    endtask

    initial begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        shift_en  = 1'b0;
        serial_in = 1'b0;
        serial_in = 1'b0;

        #20;
        rst_n = 1'b1;
        #10;

       // $display("\n================ STARTING ALU TESTS ================\n");

        // Test 1: ADD
        send_and_print(1'b1, 3'b000, 8'd15, 8'd10, "ADD");
        #20;

        // Test 2: SUB
        send_and_print(1'b1, 3'b001, 8'd50, 8'd20, "SUB");
        #20;

        // Test 3: Bitwise AND
        send_and_print(1'b1, 3'b010, 8'b1100_1100, 8'b1010_1010, "AND");
        #20;

        // Test 4: Disabled ALU & Check Zero Flag
        send_and_print(1'b0, 3'b000, 8'd0, 8'd25, "DISABLED/ZERO");
        #20;

      //  $display("=======================================================");
        $display(" DONE \n", $time);
        $finish;
    end

endmodule