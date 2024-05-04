`timescale 1ns / 1ps

module FloatingPointAdder_tb;

    reg [31:0] a, b;
  	reg clk = 0;
    wire [31:0] result;
    
    // Instantiate the FloatingPointAdder module
    FloatingPointAdder adder(
        .a(a),
        .b(b),
        .result(result)
    );
    
    // Generate clock signal
	always #5 clk = ~clk;
  
    // Apply inputs and monitor outputs
    initial begin
        // Apply inputs
        #10
        a = 32'h40733333;
        b = 32'h40c66666;

        #10
        a = 32'hc0000000;
        b = 32'hc1000000;
      
        #10
        a = 32'h40d9999a;
        b = 32'hc0733333;

      
        #10
        a = 32'hc0f9999a;
        b = 32'h40333333;


                               
        // End simulation
        #20;
        $finish;
    end
  
  initial begin
    	$dumpfile("dump.vcd"); 
    	$dumpvars;
  end

endmodule
