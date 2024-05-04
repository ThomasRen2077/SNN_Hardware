`timescale 1ns/1ps
module floating_point_multiplier_tb;

// Parameters
parameter CLOCK_PERIOD = 10; // Clock period in nanoseconds

// Inputs
reg [31:0] a_input;
reg [31:0] b_input;
reg clk = 0;

// Outputs
wire [31:0] result_output;

// Instantiate the module under test
floating_point_multiplier dut(
  	.clk(clk),
    .a(a_input),
    .b(b_input),
    .result(result_output)
);

// Clock generation
always #((CLOCK_PERIOD / 2)) clk = ~clk;

// Test stimulus
initial begin
    // Initialize inputs
    a_input = 32'h4048f5c3; 	// 3.14 in IEEE 754 format
    b_input = 32'h40A00000; 	// 5.0 in IEEE 754 format
  
    #50;
    a_input = 32'h4048f5c3; 	// 3.14 in IEEE 754 format
    b_input = 32'hc0a00000; 	// -5.0 in IEEE 754 format
    #50;
    a_input = 32'hc048f5c3; 	// -3.14 in IEEE 754 format
    b_input = 32'h40A00000; 	// 5.0 in IEEE 754 format
  
    #50;
    a_input = 32'hc048f5c3; 	// -3.14 in IEEE 754 format
    b_input = 32'hc0a00000; 	// -5.0 in IEEE 754 format

    #200;    
    $finish;
end
  
initial begin
  	$dumpfile("dump.vcd"); 
  	$dumpvars;
end

endmodule
