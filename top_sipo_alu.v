
// 1. Shift Register

module sipo_reg #(
    parameter WIDTH = 20
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             shift_en,
    input  wire             serial_in,
    output reg  [WIDTH-1:0] parallel_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            parallel_out <= 0; 
        end else if (shift_en) begin
            parallel_out <= {parallel_out[WIDTH-2:0], serial_in};
        end
    end

endmodule


// 2. ALU

module alu #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] in_a,
    input  wire [WIDTH-1:0] in_b,
    input  wire [2:0]       opcode,
    input  wire             alu_en,
    output reg  [WIDTH-1:0] alu_out,
    output wire             a_is_zero
);
    assign a_is_zero = (in_a == 0); 

    always @(*) begin
        if (!alu_en) begin
            alu_out = 0;
        end else begin
            case (opcode)
                3'b000:  alu_out = in_a + in_b;   
                3'b001:  alu_out = in_a - in_b;   
                3'b010:  alu_out = in_a & in_b;   
                3'b011:  alu_out = in_a ^ in_b;   
                3'b100:  alu_out = in_a | in_b;  
                3'b101:  alu_out = in_a;          
                default: alu_out = 0;             
            endcase
        end
    end

endmodule


module top_sipo_alu #(
    parameter SIPO_WIDTH = 20,
    parameter ALU_WIDTH  = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  shift_en,
    input  wire                  serial_in,
    output wire [ALU_WIDTH-1:0]  alu_out,
    output wire                  a_is_zero
);
    wire [SIPO_WIDTH-1:0] parallel_data;
    sipo_reg #(
        .WIDTH(SIPO_WIDTH)
    ) u_sipo (
        .clk         (clk),
        .rst_n       (rst_n),
        .shift_en    (shift_en),
        .serial_in   (serial_in),
        .parallel_out(parallel_data)
    );
    alu #(
        .WIDTH(ALU_WIDTH)
    ) u_alu (
        .in_a     (parallel_data[15:8]),
        .in_b     (parallel_data[7:0]),
        .opcode   (parallel_data[18:16]),
        .alu_en   (parallel_data[19]),
        .alu_out  (alu_out),
        .a_is_zero(a_is_zero)
    );

endmodule