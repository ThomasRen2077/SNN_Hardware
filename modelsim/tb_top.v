`timescale 1ns / 1ps

module SNN_tb;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period in ns

    // Inputs
    reg clk;
    reg reset;
    reg start_en;

    // Instantiate the unit under test (UUT)
    SNN uut (
        .clk(clk),
        .reset(reset),
        .start_en(start_en)
    );

    // Clock generation
    always #((CLK_PERIOD)/2) clk = ~clk;

    // Reset assertion
    initial begin
        clk = 0;
        reset = 1;
        start_en = 0;
        #20;
        reset = 0;
        #20;
        
        start_en = 1;
        #100;
        start_en = 0;
        #100;
        $stop;
    end

endmodule
