module digital_parking #(
    parameter RATE_PER_UNIT = 5  
)(
    input  wire        clk,            
    input  wire        rst_n,          

    input  wire        car_in,         
    input  wire        car_out,        
    input  wire [3:0]  spot_id,        

    output reg  [9:0]  spots_resived, 
    output wire        is_full,        
    output reg  [15:0] entry_time_out,
    output reg  [15:0] duration_out,   
    output reg  [31:0] total_fee_out   
);
    reg [15:0] global_timer;
    
    reg [15:0] entry_time [0:9];
    
    integer i;
    
    assign is_full = &spots_resived;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            global_timer <= 16'd0;
        end else begin
            global_timer <= global_timer + 1'b1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spots_resived <= 10'b0;
            entry_time_out <= 16'd0;
            duration_out   <= 16'd0;
            total_fee_out  <= 32'd0;
            
            for (i = 0; i < 10; i = i + 1) begin
                entry_time[i] <= 16'd0;
            end
        end else begin

            if (spot_id < 4'd10) begin
                
                entry_time_out <= entry_time[spot_id];

                if (car_in && !spots_resived[spot_id]) begin
                    spots_resived[spot_id] <= 1'b1;
                    entry_time[spot_id]     <= global_timer;
                end 
                
                else if (car_out && spots_resived[spot_id]) begin
                    duration_out           <= global_timer - entry_time[spot_id];
                    total_fee_out          <= (global_timer - entry_time[spot_id]) * RATE_PER_UNIT;
                    spots_resived[spot_id] <= 1'b0; // Free up the spot
                end
            end
        end
    end

endmodule