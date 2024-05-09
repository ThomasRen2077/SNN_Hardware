`timescale 1ns/1ns

module LIF_tb();
    parameter DATA_WIDTH = 16;

    reg clk_50, clk_25, reset;
	wire fired;
    reg [15:0] input_current, threshold;

    //Initialize clocks and index
	initial begin
		clk_50 = 1'b0;
		clk_25 = 1'b0;
        input_current = 16'h3c00; // input current = 1
    end
	
	//Toggle the clocks
	always begin
		#10
		clk_50  = !clk_50;
	end
	
	always begin
		#20
		clk_25  = !clk_25;
	end
	
	//Intialize and drive signals
	initial begin
		reset  = 1'b0;
		#10 
		reset  = 1'b1;
		#30
		reset  = 1'b0;
	end

    // always @(posedge clk_50) begin
    //     a <= a + 16'h0400;
    //     b <= b + 16'h0400;
    // end

    Modified_LIFNeuron LIFNeuron1s(
		.clk(clk_50), 
        .reset(reset), 
        .input_current(input_current),             // Synaptic input current
        .fired(fired)                        // Output spike
    );


endmodule