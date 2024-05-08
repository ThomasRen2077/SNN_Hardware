// fully connected layer
module matrix_fc(
	input clk,
	input reset,
	input start,
	output reg done,
	input wire [11:0] src1_start_address, //vector
	input wire [11:0] src2_start_address, //matrix
	output reg [11:0] src1_address,
	input wire [15:0] src1_data,

	output reg [11:0] src2_address,
	input wire [15:0] src2_data,


	output reg dest_write_en,
	output reg [7:0] final_result
);
	 reg [3:0] state = 4'd0;
	 reg [15:0] sum_out, weight;
	 wire [15:0] multiplex_out;
    reg [7:0] count;

	 signed_mult mult1(.out(multiplex_out), .a(src1_data), .b(src2_data));

	 always @(posedge clk) begin
		if(state == 4'd0 && start == 1'd1) begin
			src1_address <= src1_start_address;
			src2_address <= src2_start_address;
			//dest_address <= dest_start_address;
			count <= 8'd0;
			final_result <=8'd0;
			state <= 4'd1;
			weight <= 16'd0;
		end

		if(state == 4'd1) begin
			sum_out <= 0;
			state <= 4'd2;
		end

		if(state == 4'd2)begin
			src1_address <= src1_address + 12'd1;
			src2_address <= src2_address + 12'd1;
			//signed_mult mult2(.out(multiplex_out), .a(src1_data), .b(src2_data));
			sum_out <= multiplex_out + sum_out;
			
			state <= (src1_address == 12'd506)? 4'd3:4'd2;
		end
		if (state == 4'd3)begin
			weight <= (sum_out >= weight) ? sum_out : weight;
			final_result <= (sum_out >= weight) ? count : final_result;
			count <= count + 8'd1;
			//dest_write_en <= 1'd0;
			src1_address <= src1_start_address;
            state <= (src2_address == 12'd5069) ? 4'd4:4'd1;
		end
		if (state == 4'd4)begin
			 done <= 1'd1;
		end	 
	end
endmodule


