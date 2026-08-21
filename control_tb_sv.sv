`timescale 1ps / 1ps

module control_tb_sv;

    logic        clk;
    logic        rst;
    logic [2:0]  opcode;
    logic        zero;

    wire        sel;
    wire        rd;
    wire        ld_ir;
    wire        halt;
    wire        inc_pc;
    wire        ld_ac;
    wire        ld_pc;
    wire        wr;
    wire        is_alu_op;
    wire        data_e;
    wire [2:0]  phase;

    control uut (
        .sel(sel), .rd(rd), .ld_ir(ld_ir), .halt(halt),
        .inc_pc(inc_pc), .ld_ac(ld_ac), .ld_pc(ld_pc),
        .wr(wr), .is_alu_op(is_alu_op), .data_e(data_e),
        .phase(phase), .opcode(opcode), .zero(zero),
        .clk(clk), .rst(rst)
    );

    always #2500 clk = ~clk;

    typedef struct {
        bit [2:0] opcode;
        bit       zero;
    } input_trans;

    typedef struct {
        bit       sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, is_alu_op, data_e;
        bit [2:0] phase;
    } output_trans;


    // 1. GENERATOR
    task generator(output input_trans tr);
        tr.opcode = $urandom_range(0, 7);
        tr.zero   = $urandom_range(0, 1);
    endtask


    // 2. DRIVER

    task driver(input input_trans tr);
        opcode <= tr.opcode;
        zero   <= tr.zero;
    endtask


    // 3. MONITOR IN 

    task monitor_in(output input_trans tr);
        tr.opcode = opcode;
        tr.zero   = zero;
    endtask


    // 4. MONITOR OUT 

    task monitor_out(output output_trans tr);
        #1;
        tr.sel       = sel;
        tr.rd        = rd;
        tr.ld_ir     = ld_ir;
        tr.halt      = halt;
        tr.inc_pc    = inc_pc;
        tr.ld_ac     = ld_ac;
        tr.ld_pc     = ld_pc;
        tr.wr        = wr;
        tr.is_alu_op = is_alu_op;
        tr.data_e    = data_e;
        tr.phase     = phase;
    endtask


    // 5. PREDICTOR

    task predictor(input input_trans in_tr, output output_trans exp_tr);
        exp_tr.phase     = uut.current_state;
        exp_tr.is_alu_op = (in_tr.opcode >= 3'b010 && in_tr.opcode <= 3'b101);
        exp_tr.sel    = 1'b0; 
        exp_tr.rd     = 1'b0;
        exp_tr.ld_ir  = 1'b0;
        exp_tr.halt   = 1'b0;
        exp_tr.inc_pc = 1'b0;
        exp_tr.ld_ac  = 1'b0;
        exp_tr.ld_pc  = 1'b0;
        exp_tr.wr     = 1'b0;
        exp_tr.data_e = 1'b0;

        case (exp_tr.phase)
            3'b000: exp_tr.sel = 1'b1;
            3'b001: begin exp_tr.sel = 1'b1; exp_tr.rd = 1'b1; end
            3'b010: begin exp_tr.sel = 1'b1; exp_tr.rd = 1'b1; exp_tr.ld_ir = 1'b1; end
            3'b011: ;
            3'b100: begin exp_tr.sel = 1'b1; if (in_tr.opcode == 3'b000) exp_tr.halt = 1'b1; end
            3'b101: if (exp_tr.is_alu_op) exp_tr.rd = 1'b1;
            3'b110: begin
                if (exp_tr.is_alu_op) begin exp_tr.rd = 1'b1; exp_tr.ld_ac = 1'b1; end
                if (in_tr.opcode == 3'b001 && in_tr.zero) exp_tr.inc_pc = 1'b1;
                if (in_tr.opcode == 3'b111) exp_tr.ld_pc = 1'b1;
            end
            3'b111: begin
                exp_tr.inc_pc = 1'b1;
                if (exp_tr.is_alu_op) exp_tr.rd = 1'b1;
                if (in_tr.opcode == 3'b111) exp_tr.ld_pc = 1'b1;
                if (in_tr.opcode == 3'b110) begin exp_tr.wr = 1'b1; exp_tr.data_e = 1'b1; end
            end
        endcase
    endtask


    // 6. CHECKER 

    task check_result(input output_trans act_tr, input output_trans exp_tr, input input_trans in_tr);
        string status;

        if (act_tr === exp_tr) begin
            status = "PASS";
        end else begin
            status = "FAIL";
        end

        $display("#  %b  |  %b  |    %b    |  %b  %b  %b    %b    %b     %b     %b   %b   %b   |   %b   | [%s]",
                  in_tr.opcode, act_tr.phase, act_tr.is_alu_op,act_tr.sel, act_tr.rd, act_tr.ld_ir, act_tr.halt,
                 act_tr.inc_pc, act_tr.ld_ac, act_tr.ld_pc, act_tr.wr, act_tr.data_e,in_tr.zero, status);
    endtask

    initial begin
        input_trans  in_tr;
        output_trans act_tr, exp_tr;

        clk = 0;
        rst = 1;
        opcode = 0;
        zero = 0;

        #5000 rst = 0;

        $display("#  Opcode | Phase | is_alu_op | sel rd ld_ir halt inc_pc ld_ac ld_pc wr data_e | zero | Status");
        $display("#----------------------------------------------------------------------------------------------------");

        repeat (10) begin
            generator(in_tr);
            driver(in_tr);

            for (int j = 0; j < 8; j++) begin
                #5000;
                monitor_in(in_tr);
                monitor_out(act_tr);
                predictor(in_tr, exp_tr);
                check_result(act_tr, exp_tr, in_tr);
            end

            $display("#----------------------------------------------------------------------------------------------------");
        end

        $finish;
    end

endmodule