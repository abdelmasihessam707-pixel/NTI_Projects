module fifo #(
    parameter DATA_WIDTH = 8,  
    parameter DEPTH      = 16 
)(
    input  wire                  clk,
    input  wire                  rst_n,   
    input  wire                  wr_en,  
    input  wire                  rd_en, 
    input  wire [DATA_WIDTH-1:0] din,

    output reg  [DATA_WIDTH-1:0] dout,
    output wire                  full,
    output wire                  empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0] count;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr      <= wr_ptr + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
            dout   <= 0;
        end else if (rd_en && !empty) begin
            dout   <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            case (wr_en && !full)
                1'b1: begin
                    case (rd_en && !empty)
                        1'b1: count <= count;        
                        1'b0: count <= count + 1'b1;
                    endcase
                end
                
                1'b0: begin
                    case (rd_en && !empty)
                        1'b1: count <= count - 1'b1;
                        1'b0: count <= count;       
                    endcase
                end
            endcase
        end
    end

endmodule