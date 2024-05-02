`timescale 1ns / 1ps

module tb_LIFNeuron();
    reg clk;
    reg reset;
    reg [15:0] input_current;
    reg [15:0] leak_factor;
    reg [15:0] threshold;
    reg [15:0] reset_potential;
    wire fired;
    wire [15:0] membrane_potential;

    // Instantiate the LIFNeuron module
    LIFNeuron lif_neuron (
        .clk(clk),
        .reset(reset),
        .input_current(input_current),
        .leak_factor(leak_factor),
        .threshold(threshold),
        .reset_potential(reset_potential),
        .fired(fired),
        .membrane_potential(membrane_potential)
    );

    // Clock with a period of 20 ns
    always #10 clk = ~clk;  

    initial begin
        clk = 0;
        reset = 1;
        input_current = 0;
        leak_factor = 3277;             // About 0.05 in fixed-point 16-bit (0.05 * 65536)
        threshold = 30000;              // Firing threshold
        reset_potential = 5000;         // Reset potential after firing
        
        #20 reset = 0;                  // Release reset after 20 ns

        #100 input_current = 0;         // No input should result in no firing
        #100;                           // Wait 100 ns to observe behavior

        input_current = 10000;          // Set input current to cause integration up to firing
        #1000;                          // Run long enough to see multiple firing cycles

        $finish;                        // End simulation
    end

    // Monitor changes and print
    initial begin
        $monitor("Time = %t, Reset = %b, Input Current = %d, Membrane Potential = %d, Fired = %b",$time, reset, input_current, membrane_potential, fired);
    end
  
  	initial begin
      $dumpfile("dump.vcd"); 
      $dumpvars; 
    end
    
endmodule
