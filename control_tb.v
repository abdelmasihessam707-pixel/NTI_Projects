`timescale 1ns / 1ps

module control_tb;

    reg [2:0] opcode;
    reg       zero;
    reg       clk;
    reg       rst;

    wire sel;
    wire rd;
    wire ld_ir;
    wire halt;
    wire inc_pc;
    wire ld_ac;
    wire ld_pc;
    wire wr;
    wire is_alu_op;
    wire data_e;
    wire [2:0] phase;

    control uut (
        .sel(sel),
        .rd(rd),
        .ld_ir(ld_ir),
        .halt(halt),
        .inc_pc(inc_pc),
        .ld_ac(ld_ac),
        .ld_pc(ld_pc),
        .wr(wr),
        .is_alu_op(is_alu_op),
        .data_e(data_e),
        .phase(phase),
        .opcode(opcode),
        .zero(zero),
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    integer i, j;

    initial begin
        clk    = 0;
        rst    = 1;
        zero   = 0;
        opcode = 3'b000;

        #10 rst = 0;

        $display(" Time | Opcode | Phase | is_alu_op | sel rd ld_ir halt inc_pc ld_ac ld_pc wr data_e | zero ");
        $display("-------------------------------------------------------------------------------------------------------------------");

        $monitor("%4t |   %b  |  %b  |     %b     |  %b   %b    %b     %b     %b     %b     %b   %b    %b   |   %b",
                 $time, opcode, phase, is_alu_op, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e, zero);

        for (i = 0; i < 8; i = i + 1) begin
            opcode = i[2:0];

            for (j = 0; j < 8; j = j + 1) begin
                if (opcode == 3'b001 && phase == 3'b110) begin
                    zero = 1;
                end else begin
                    zero = 0;
                end

                #10;
            end
            
            $display("-------------------------------------------------------------------------------------------------------------------");
        end

        $display("Simulation Completed Successfully!");
        $finish;
    end

endmodule