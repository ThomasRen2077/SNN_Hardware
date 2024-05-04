module LIFNeuron(
    input clk,
    input reset,
    input [15:0] input_current,             // Synaptic input current
    input [15:0] leak_factor,               // Factor for potential decay
    input [15:0] threshold,                 // Firing threshold
    input [15:0] reset_potential,           // Reset potential after firing
    output reg fired,                       // Output spike
    output reg [15:0] membrane_potential    // Membrane potential
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset potential to 0 or reset_potential as needed
            membrane_potential <= 0;        
            fired <= 0;
        end else begin
            // Update membrane potential with input current and leakage
            membrane_potential <= (membrane_potential + input_current - (membrane_potential * leak_factor >> 16));
            if (membrane_potential >= threshold) begin
                fired <= 1'b1;
                membrane_potential <= reset_potential;  
            end else begin
                fired <= 1'b0;
            end
        end
    end
    
endmodule
