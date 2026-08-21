module control (
    output reg        sel,
    output reg        rd,
    output reg        ld_ir,
    output reg        halt,
    output reg        inc_pc,
    output reg        ld_ac,
    output reg        ld_pc,
    output reg        wr,
    output reg        is_alu_op,
    output reg        data_e,
    output reg [2:0]  phase,
    input      [2:0]  opcode,
    input             zero,
    input             clk,
    input             rst
);

    localparam INST_ADDR  = 3'b000;
    localparam INST_FETCH = 3'b001;
    localparam INST_LOAD  = 3'b010;
    localparam IDLE       = 3'b011;
    localparam OP_ADDR    = 3'b100;
    localparam OP_FETCH   = 3'b101;
    localparam ALU_OP     = 3'b110;
    localparam STORE      = 3'b111;

    localparam HLT = 3'b000;
    localparam SKZ = 3'b001;
    localparam ADD = 3'b010;
    localparam AND = 3'b011;
    localparam XOR = 3'b100;
    localparam LDA = 3'b101;
    localparam STO = 3'b110;
    localparam JMP = 3'b111;

    reg [2:0] current_state, next_state;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= INST_ADDR;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        phase = current_state;

        case (opcode)
            ADD, AND, XOR, LDA: is_alu_op = 1'b1;
            default:            is_alu_op = 1'b0;
        endcase

        sel    = 1'b0;
        rd     = 1'b0;
        ld_ir  = 1'b0;
        halt   = 1'b0;
        inc_pc = 1'b0;
        ld_ac  = 1'b0;
        ld_pc  = 1'b0;
        wr     = 1'b0;
        data_e = 1'b0;

        case (current_state)
            INST_ADDR: begin
                sel        = 1'b1;
                next_state = INST_FETCH;
            end

            INST_FETCH: begin
                sel        = 1'b1;
                rd         = 1'b1;
                next_state = INST_LOAD;
            end

            INST_LOAD: begin
                sel        = 1'b1;
                rd         = 1'b1;
                ld_ir      = 1'b1;
                next_state = IDLE;
            end

            IDLE: begin
                next_state = OP_ADDR;
            end

            OP_ADDR: begin
                sel = 1'b1;
                if (opcode == HLT) begin
                    halt = 1'b1;
                end
                next_state = OP_FETCH;
            end

            OP_FETCH: begin
                if (is_alu_op) begin
                    rd = 1'b1;
                end
                next_state = ALU_OP;
            end

            ALU_OP: begin
                if (is_alu_op) begin
                    rd    = 1'b1;
                    ld_ac = 1'b1;
                end

                if (opcode == SKZ && zero) begin
                    inc_pc = 1'b1;
                end

                if (opcode == JMP) begin
                    ld_pc = 1'b1;
                end

                next_state = STORE;
            end

            STORE: begin
                inc_pc = 1'b1;

                if (is_alu_op) begin
                    rd = 1'b1;
                end

                if (opcode == JMP) begin
                    ld_pc = 1'b1;
                end

                if (opcode == STO) begin
                    wr     = 1'b1;
                    data_e = 1'b1;
                end

                next_state = INST_ADDR;
            end

            default: begin
                next_state = INST_ADDR;
            end
        endcase
    end

endmodule