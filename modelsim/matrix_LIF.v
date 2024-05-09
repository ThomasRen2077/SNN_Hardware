module matrix_LIF(
    input clk,
    input reset,
    input start,
    output reg done,
    input wire [13:0] src1_start_address,
    input wire [13:0] src2_start_address,
    output reg [13:0] src1_address,
    input wire signed [15:0] src1_readdata,
    output wire src1_write_en,
    input wire [9:0] src1_row_size,
    input wire [9:0] src1_col_size,
    input wire [5:0] src2_row_size,
    input wire [5:0] src2_col_size,
    input wire [13:0] dest_start_address,
    output reg [13:0] dest_address,
    output reg signed [15:0] dest_writedata,
    output reg dest_write_en,
    input [15:0] thre
);
    reg [9:0] row_count;
    reg [9:0] col_count;
   
    assign src1_write_en = 0;
   // assign src2_write_en = 0;
    reg [1:0] state = 2'd2;
    wire LIF_fired;

    wire signed [15:0] src1_readdata1;
    wire comp_res2, comp_res1;

    always @(posedge clk) begin
    if(reset) begin
        state <= 2'd2;
        row_count<=0;
        col_count<=0;
        src1_address<=src1_start_address;
      //  src2_address<=src2_start_address;
        dest_address<=dest_start_address;
        done<=1;
    end
    else begin
        case (state)
            2'd0: begin
                src1_address<=src1_start_address;
            //    src2_address<=src2_start_address;
                dest_address<=dest_start_address-1;
                state<=2'd1;
            end
            2'd1: begin
                if(row_count < src1_row_size-1) begin
                    src1_address <= src1_address + 1;
                //    src2_address <= src2_address + 1;
                    row_count <= row_count+1;
                    dest_address <= dest_address + 1;
                //  dest_data <= src1_data + src2_data;
                    dest_writedata <= LIF_fired;
                    dest_write_en <= 1;
                end
                else if (col_count < src1_col_size-1) begin
                    src1_address <= src1_address + 1;
                //    src2_address <= src2_address + 1;
                    col_count <= col_count+1;
                    row_count <= 0;
                    dest_address <= dest_address + 1;
                //  dest_data <= src1_data + src2_data;
                    dest_writedata <= LIF_fired;
                end
                else begin
                    dest_address<=dest_address + 1;
                //  dest_data <= src1_data + src2_data;
                    dest_writedata <= LIF_fired;
                    state <= 2'd2;
                end
            end
            2'd2: begin
                if(start == 1) begin
                    state <= 2'd0;
                    done <= 0;
                end
                else begin
                    dest_write_en <= 0;
                    row_count<=0;
                    col_count<=0;
                    src1_address<=src1_start_address;
                //  src2_address<=src2_start_address;
                    dest_address<=dest_start_address;
                    done<=1;
                end
            end
            default: begin
                row_count<=0;
                col_count<=0;
                src1_address<=src1_start_address;
            //    src2_address<=src2_start_address;
                dest_address<=dest_start_address;
                done<=1;
            end
        endcase
    end
    end

    assign src1_readdata1 = (comp_res1) ? 16'h3C00 : ((comp_res2) ? src1_readdata : 16'hBC00);

    Modified_LIFNeuron LIF(
        .clk(clk),
        .reset(reset),
        .input_current(src1_readdata1),
        // .threshold(thre),
        .fired(LIF_fired)
    );

    float_compare comp1(
        .a(src1_readdata),
        .b(16'h3C00),
        .c(comp_res1)
    );

    float_compare comp2(
        .a(src1_readdata),
        .b(16'hBC00),
        .c(comp_res2)
    );



endmodule


