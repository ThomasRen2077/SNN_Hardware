

module DE1_SoC_Computer (

	input clk;
	input reset
);


wire [15:0] sram_readdata ;
wire [15:0] sram_writedata ;
wire [11:0] sram_address; 
wire sram_write ;
wire sram_clken = 1'b1;
wire sram_chipselect = 1'b1;

wire [15:0] sram_readdata_0;
wire [15:0] sram_writedata_0;
wire [11:0] sram_address_0; 
wire sram_write_0 ;
wire sram_clken_0 = 1'b1;
wire sram_chipselect_0 = 1'b1;

wire [15:0] sram_readdata_1;
wire [15:0] sram_writedata_1;
wire [11:0] sram_address_1; 
wire sram_write_1;
wire sram_clken_1 = 1'b1;
wire sram_chipselect_1 = 1'b1;

wire [5:0] src1_row_size, src1_col_size, src2_row_size, src2_col_size;

reg reset;
wire fc_start, conv_start, mp_start; //connect to a button
wire conv_done, fc_done, mp_done;
wire conv_we, conv_we_0, conv_we_1, mp_we_0, mp_we_1, mp_we, fc_we; //write enable

wire [11:0] conv_address_0, conv_address_1, conv_address;
wire [11:0] fc_address_0, fc_address_1, fc_address;
wire [11:0] mp_address, mp_address_0, mp_address_1;
wire [7:0] final_result;

wire [15:0] conv_writedata_0, conv_writedata_1, conv_writedata, fc_writedata, fc_writedata_0, fc_writedata_1, mp_writedata;
//wire fc_write, fc_write_0, fc_write_1, conv_write, conv_write_0, conv_write_1;

// the write data
assign sram_writedata = (fc_start) ? fc_writedata :
                        (conv_start) ? conv_writedata :
								(mp_start) ? mp_writedata :
                        16'd0;
								
assign sram_writedata_0 = (fc_start) ? fc_writedata_0 :
                        (conv_start) ? conv_writedata_0 :
                        16'd0;
								
assign sram_writedata_1 = (fc_start) ? fc_writedata_1 :
                        (conv_start) ? conv_writedata_1 :
                        16'd0;								
// the addresss configuration
assign sram_address_0 = (fc_start) ? fc_address_0 :
                        (conv_start) ? conv_address_0 :
                        12'd0;	
								
assign sram_address_1 = (fc_start) ? fc_address_1 :
                        (conv_start) ? conv_address_1 :
                        12'd0;

assign sram_address = (fc_start) ? fc_address :
                        (conv_start) ? conv_address :
								(mp_start) ? mp_address :
                        12'd0;
// the write enable								
assign sram_write = (fc_start) ? fc_we :
                        (conv_start) ? conv_we :
								(mp_start) ? mp_we :
                        1'd0;
								
assign sram_write_0 = (mp_start) ? mp_we_0 :
                        (conv_start) ? conv_we_0 :
								(mp_start) ? mp_we_0 :
                        1'd0;
								
assign sram_write_1 = (mp_start) ? mp_we_1 :
                        (conv_start) ? conv_we_1 :
                        1'd0;										
/*
Current issue:
	1. there is no 'reset'
	2. the 'start_address' are all 'zeros', should be changed
*/

					
conv_unit conv_layer(
    .clk(clk),
    .reset(reset),
    .start(conv_start),
    .done(conv_done),
    .src1_start_address(12'd0),
    .src2_start_address(12'd0),
	 
    .src1_address(conv_address_0),
    .src1_readdata(sram_readdata_0),
    .src1_writedata(conv_writedata_0),
    .src1_write_en(conv_we_0),
	 
    .src2_address(conv_address_1),
    .src2_readdata(sram_readdata_1),
    .src2_writedata(conv_writedata_1),
    .src2_write_en(conv_we_1),
    .src1_row_size(src1_row_size),
    .src1_col_size(src1_col_size),
    .src2_row_size(src2_row_size),
    .src2_col_size(src2_col_size),
	 
    .dest_start_address(12'd0),
    .dest_address(conv_address),
    .dest_writedata(conv_writedata),
    .dest_readdata(sram_readdata),
    .dest_write_en(conv_we)
);

assign mp_start = conv_done;

max_pooling pooling_layer(
    .clk(clk),
    .reset(reset),
    .start(mp_start),
    .done(mp_done),
    .src1_start_address(12'd0),
    
	 .src1_address(mp_address_0),
    .src1_readdata(sram_readdata_0),
    .src1_write_en(mp_we_0),
    .src1_row_size(src1_row_size),
    .src1_col_size(src1_col_size),
    .src2_row_size(src2_row_size),
    .src2_col_size(src2_col_size),
	 
    .dest_start_address(12'd0),
    .dest_address(mp_address),
    .dest_writedata(mp_writedata),
    .dest_write_en(mp_we)
);

assign fc_start = mp_done;

matrix_fc fc(
			.clk(clk),
			.reset(reset),
			.start(fc_start),
			.done(fc_done),
			.src1_start_address(12'd0),
			.src2_start_address(12'd27),
			.src1_address(fc_address_0),
			.src1_data(sram_readdata_0),
			.src2_address(fc_address_1),
			.src2_data(sram_readdata_1),

			.final_result(final_result)
);	

ram ram_dest(
    .q(sram_readdata),
    .d(sram_writedata),
    .address(sram_address),
    .we(sram_write),
    .clk(sram_clken)
);

ram ram_src1(
    .q(sram_readdata_0),
    .d(sram_writedata_0),
    .address(sram_address_0),
    .we(sram_write_0),
    .clk(sram_clken_0)
);

ram ram_src2(
    .q(sram_readdata_1),
    .d(sram_writedata_1),
    .address(sram_address_1),
    .we(sram_write_1),
    .clk(sram_clken_1)
);

			
endmodule // end top level








