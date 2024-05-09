module SNN (

	input clk,
    input start_en,
	input reset
);

parameter CHANNELS = 32;

reg conv_start[CHANNELS-1 : 0], LIF_start[CHANNELS-1 : 0], mp_start[CHANNELS-1 : 0], fc_start[CHANNELS-1 : 0];

wire conv_done [CHANNELS-1 : 0];
wire LIF_done [CHANNELS-1 : 0];
wire mp_done [CHANNELS-1 : 0];
wire fc_done [CHANNELS-1 : 0];

reg start_en_prev[CHANNELS-1 : 0];
reg conv_done_prev[CHANNELS-1 : 0];
reg LIF_done_prev[CHANNELS-1 : 0];
reg mp_done_prev[CHANNELS-1 : 0];
reg fc_done_prev[CHANNELS-1 : 0];

wire [13:0] conv_src1_address[CHANNELS-1 : 0];
wire [15:0] conv_src1_readdata[CHANNELS-1 : 0];
wire [15:0] conv_src1_writedata[CHANNELS-1 : 0];
wire conv_src1_write[CHANNELS-1 : 0];

wire [13:0] conv_src2_address[CHANNELS-1 : 0];
wire [15:0] conv_src2_readdata[CHANNELS-1 : 0];
wire [15:0] conv_src2_writedata[CHANNELS-1 : 0];
wire conv_src2_write[CHANNELS-1 : 0];

wire [13:0] conv_dest_address[CHANNELS-1 : 0];
reg [15:0] conv_dest_readdata[CHANNELS-1 : 0];
wire [15:0] conv_dest_writedata[CHANNELS-1 : 0];
wire conv_dest_write[CHANNELS-1 : 0];

wire [13:0] LIF_src1_address[CHANNELS-1 : 0];
reg [15:0] LIF_src1_readdata[CHANNELS-1 : 0];
reg [15:0] LIF_src1_writedata[CHANNELS-1 : 0];
wire LIF_src1_write[CHANNELS-1 : 0];

wire [13:0] LIF_src2_address[CHANNELS-1 : 0];
wire [15:0] LIF_src2_readdata[CHANNELS-1 : 0];
wire [15:0] LIF_src2_writedata[CHANNELS-1 : 0];
wire LIF_src2_write[CHANNELS-1 : 0];

wire [13:0] LIF_dest_address[CHANNELS-1 : 0];
reg [15:0] LIF_dest_readdata[CHANNELS-1 : 0];
wire [15:0] LIF_dest_writedata[CHANNELS-1 : 0];
wire LIF_dest_write[CHANNELS-1 : 0];

wire [13:0] mp_src1_address[CHANNELS-1 : 0];
wire [15:0] mp_src1_readdata[CHANNELS-1 : 0];
wire [15:0] mp_src1_writedata[CHANNELS-1 : 0];
wire mp_src1_write[CHANNELS-1 : 0];

reg [13:0] mp_src2_address[CHANNELS-1 : 0];
reg [15:0] mp_src2_readdata[CHANNELS-1 : 0];
reg [15:0] mp_src2_writedata[CHANNELS-1 : 0];
reg mp_src2_write[CHANNELS-1 : 0];

wire [13:0] mp_dest_address[CHANNELS-1 : 0];
wire [15:0] mp_dest_readdata[CHANNELS-1 : 0];
wire [15:0] mp_dest_writedata[CHANNELS-1 : 0];
wire mp_dest_write[CHANNELS-1 : 0];

wire [13:0] fc_src1_address[CHANNELS-1 : 0];
wire [15:0] fc_src1_readdata[CHANNELS-1 : 0];
wire [15:0] fc_src1_writedata[CHANNELS-1 : 0];
wire fc_src1_write[CHANNELS-1 : 0];

wire [13:0] fc_src2_address[CHANNELS-1 : 0];
wire [15:0] fc_src2_readdata[CHANNELS-1 : 0];
wire [15:0] fc_src2_writedata[CHANNELS-1 : 0];
wire fc_src2_write[CHANNELS-1 : 0];

wire [13:0] fc_dest_address[CHANNELS-1 : 0];
wire [15:0] fc_dest_readdata[CHANNELS-1 : 0];
wire [15:0] fc_dest_writedata[CHANNELS-1 : 0];
wire fc_dest_write[CHANNELS-1 : 0];

reg LIF_sel[CHANNELS-1 : 0];
reg mp_sel[CHANNELS-1 : 0];
reg fc_sel[CHANNELS-1 : 0];

wire [15:0] conv_dest_ram_q[CHANNELS-1 : 0];
reg [15:0] conv_dest_ram_d[CHANNELS-1 : 0];
reg [13:0] conv_dest_ram_addr[CHANNELS-1 : 0];
reg conv_dest_ram_we[CHANNELS-1 : 0];

wire [15:0] LIF_dest_ram_q[CHANNELS-1 : 0];
reg [15:0] LIF_dest_ram_d[CHANNELS-1 : 0];
reg [13:0] LIF_dest_ram_addr[CHANNELS-1 : 0];
reg LIF_dest_ram_we[CHANNELS-1 : 0];

// wire conv_done[i], fc_done, mp_done;
// wire conv_we, conv_we[i], conv_we_1, mp_we_0, mp_we_1, mp_we, fc_we; //write enable

// wire [11:0] conv_address[i], conv_address_1, conv_address;
// wire [11:0] fc_address_0, fc_address_1, fc_address;
// wire [11:0] mp_address, mp_address_0, mp_address_1;
// wire [7:0] final_result;

// wire [15:0] conv_writedata[i], conv_writedata_1, conv_writedata, fc_writedata, fc_writedata_0, fc_writedata_1, mp_writedata;

genvar i;
generate
    for (i = 0; i < 32; i = i + 1) begin
        always @ (posedge clk) begin
            if(reset) begin
                start_en_prev[i] <= 1'b0;
                conv_done_prev[i] <= 1'b0;
                LIF_done_prev[i] <= 1'b0;
                mp_done_prev[i] <= 1'b0;
                fc_done_prev[i] <= 1'b0;
            end
            else begin
                start_en_prev[i] <= start_en;
                conv_done_prev[i] <= conv_done[i];
                LIF_done_prev[i] <= LIF_done[i];
                mp_done_prev[i] <= mp_done[i];
                fc_done_prev[i] <= 1'b0;
            end
        end

        always @ (posedge clk) begin
            if(reset) begin
                conv_start[i] <= 1'b0;
            end
            else begin
                if(start_en&&~start_en_prev[i]) begin
                    conv_start[i] <= 1'b1;
                end
                else begin
                    conv_start[i] <= 1'b0;
                end
            end
        end

        always @ (posedge clk) begin
            if(reset) begin
                LIF_start[i] <= 1'b0;
            end
            else begin
                if(conv_done[i]&&~conv_done_prev[i]) begin
                    LIF_start[i] <= 1'b1;
                end
                else begin
                    LIF_start[i] <= 1'b0;
                end
            end
        end

        always @ (posedge clk) begin
            if(reset) begin
                mp_start[i] <= 1'b0;
            end
            else begin
                if(LIF_done[i]&&~LIF_done_prev[i]) begin
                    mp_start[i] <= 1'b1;
                end
                else begin
                    mp_start[i] <= 1'b0;
                end
            end
        end

        always @ (posedge clk) begin
            if(reset) begin
                fc_start[i] <= 1'b0;
            end
            else begin
                if(mp_done[i]&&~mp_done_prev[i]) begin
                    fc_start[i] <= 1'b1;
                end
                else begin
                    fc_start[i] <= 1'b0;
                end
            end
        end
    
        matrix_conv conv_layer(
            .clk(clk),
            .reset(reset),
            .start(conv_start[i]),
            .done(conv_done[i]),
            .src1_start_address(14'd0),
            .src2_start_address(14'd0),
            
            .src1_address(conv_src1_address[i]),
            .src1_readdata(conv_src1_readdata[i]),
            .src1_writedata(conv_src1_writedata[i]),
            .src1_write_en(conv_src1_write[i]),
            
            .src2_address(conv_src2_address[i]),
            .src2_readdata(conv_src2_readdata[i]),
            .src2_writedata(conv_src2_writedata[i]),
            .src2_write_en(conv_src2_write[i]),

            .src1_row_size(10'd32),
            .src1_col_size(10'd32),
            .src2_row_size(6'd3),
            .src2_col_size(6'd3),
            
            .dest_start_address(14'd0),
            .dest_address(conv_dest_address[i]),
            .dest_writedata(conv_dest_writedata[i]),
            .dest_readdata(conv_dest_readdata[i]),
            .dest_write_en(conv_dest_write[i])
        );

        ram conv_src1_ram(
            .q(conv_src1_readdata[i]),
            .d(conv_src1_writedata[i]),
            .address(conv_src1_address[i]),
            .we(conv_src1_write[i]),
            .clk(clk)
        );

        ram conv_src2_ram(
            .q(conv_src2_readdata[i]),
            .d(conv_src2_writedata[i]),
            .address(conv_src2_address[i]),
            .we(conv_src2_write[i]),
            .clk(clk)
        );

        always @(*) begin
            if(reset) begin
                LIF_sel[i] = 0;
            end
            else begin
                if(conv_done[i]) begin
                    LIF_sel[i] = 0;
                end
                else begin
                    LIF_sel[i] = 1;
                end
            end
        end

        always @(*) begin
            if(LIF_sel[i]) begin
                conv_dest_readdata[i] = conv_dest_ram_q[i];   
                conv_dest_ram_d[i] = conv_dest_writedata[i];   
                conv_dest_ram_addr[i] = conv_dest_address[i]; 
                conv_dest_ram_we[i] = conv_dest_write[i];   
            end
            else begin
                LIF_src1_readdata[i] = conv_dest_ram_q[i];   
                conv_dest_ram_d[i]= LIF_src1_writedata[i]; 
                conv_dest_ram_addr[i] = LIF_src1_address[i];
                conv_dest_ram_we[i]=LIF_src1_write[i];    
            end
        end

        ram conv_dest_ram(
            .q(conv_dest_ram_q[i]),
            .d(conv_dest_ram_d[i]),
            .address(conv_dest_ram_addr[i]),
            .we(conv_dest_ram_we[i]),
            .clk(clk)
        );

        matrix_LIF LIF_layer(
            .clk(clk),
            .reset(reset),
            .start(LIF_start[i]),
            .done(LIF_done[i]),
            .src1_start_address(14'd0),
            .src2_start_address(14'd0),
            
            .src1_address(LIF_src1_address[i]),
            .src1_readdata(LIF_src1_readdata[i]),
            .src1_write_en(LIF_src1_write[i]),

            .src1_row_size(10'd30),
            .src1_col_size(10'd30),
            .src2_row_size(9'd30),
            .src2_col_size(9'd30),
            
            .dest_start_address(14'd0),
            .dest_address(LIF_dest_address[i]),
            .dest_writedata(LIF_dest_writedata[i]),
            .dest_write_en(LIF_dest_write[i])
        );

        always @(*) begin
            if(reset) begin
                mp_sel[i] = 0;
            end
            else begin
                if(LIF_done[i]) begin
                    mp_sel[i] = 0;
                end
                else begin
                    mp_sel[i] = 1;
                end
            end
        end

        always @(*) begin
            if(mp_sel[i]) begin
                LIF_dest_readdata[i]= LIF_dest_ram_q[i] ;   
                LIF_dest_ram_d[i] = LIF_dest_writedata[i];     
                LIF_dest_ram_addr[i] = LIF_dest_address[i];  
                LIF_dest_ram_we[i] = LIF_dest_write[i];   
            end
            else begin
                mp_src2_readdata[i]=LIF_dest_ram_q[i]; 
                mp_src2_writedata[i]=LIF_dest_ram_d[i]; 
                mp_src2_address[i]=LIF_dest_ram_addr[i];
                mp_src2_write[i]=LIF_dest_ram_we[i];
            end
        end

        ram lif_dest_ram(
            .q(LIF_dest_ram_q[i]),
            .d(LIF_dest_ram_d[i]),
            .address(LIF_dest_ram_addr[i]),
            .we(LIF_dest_ram_we[i]),
            .clk(clk)
        );

        matrix_maxpool pooling_layer(
            .clk(clk),
            .reset(reset),
            .start(mp_start[i]),
            .done(mp_done[i]),
            .src1_start_address(12'd0),
            
            .src1_address(mp_src1_address[i]),
            .src1_readdata(mp_src1_readdata[i]),
            .src1_write_en(mp_src1_write[i]),
            .src1_row_size(9'd30),
            .src1_col_size(9'd30),
            .src2_row_size(5'd2),
            .src2_col_size(5'd2),
            
            .dest_start_address(12'd0),
            .dest_address(mp_dest_address[i]),
            .dest_writedata(mp_dest_writedata[i]),
            .dest_write_en(mp_dest_write[i])
        );


        matrix_fc matrix_fc_instance(
            .clk(clk),
            .reset(reset),
            .start(fc_start[i]),
            .done(fc_done[i]),
            .src1_start_address(14'd0),
            .src2_start_address(14'd0),
            .src1_address(fc_src1_address[i]),
            .src1_readdata(fc_src1_readdata[i]),
            .src1_write_en(fc_src1_write[i]),
            .src2_address(fc_src2_address[i]),
            .src2_readdata(fc_src2_readdata[i]),
            .src2_write_en(fc_src2_write[i]),
            .src1_row_size(13'd7200),
            .src1_col_size(13'd10),
            .src2_row_size(13'd1),
            .src2_col_size(13'd7200),
            .dest_start_address(14'd0),
            .dest_address(fc_dest_address[i]),
            .dest_writedata(fc_dest_writedata[i]),
            .dest_write_en(fc_dest_write[i])
        );

        ram fc_src1_ram(
            .q(fc_src1_readdata[i]),
            .d(fc_src1_writedata[i]),
            .address(fc_src1_address[i]),
            .we(fc_src1_write[i]),
            .clk(clk)
        );

        ram fc_dest_ram(
            .q(fc_dest_readdata[i]),
            .d(fc_dest_writedata[i]),
            .address(fc_dest_address[i]),
            .we(fc_dest_write[i]),
            .clk(clk)
        );

    end

endgenerate					
			
endmodule // end top level








