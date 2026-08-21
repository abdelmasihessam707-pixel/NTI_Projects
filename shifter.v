module shifter (
    input  wire clk,
    input  wire load,     
    input  wire [7:0] data_in,  
    output wire [7:0]  s_out
);

    reg [7:0] shift_reg;

    assign s_out  = shift_reg;

    always @(posedge clk) begin
        if (load)
            shift_reg <= data_in;        
        else
            shift_reg <= shift_reg >> 1; 
    end

endmodule
