// LIF
module LIFNeuron(
    input clk,
    input reset,
    input [15:0] input_current,             // Synaptic input current
    // input [15:0] leak_factor,               // Factor for potential decay
    input [15:0] threshold,                 // Firing threshold
    // input [15:0] reset_potential,           // Reset potential after firing
    output reg fired                        // Output spike
    // output reg [15:0] membrane_potential    // Membrane potential
);
    parameter leak_factor = 16'h3800;
    wire signed [15:0] mulResult;
    wire signed [15:0] sum_plus_product;
    wire comp_result;
    reg [15:0] membrane_potential;

    always @(posedge clk) begin
        if (reset) begin
            // Reset potential to 0 or reset_potential as needed
            membrane_potential <= 0;        
            fired <= 0;
        end else begin
            // Update membrane potential with input current and leakage
            // membrane_potential <= (membrane_potential + input_current - (membrane_potential * leak_factor >> 16));
            membrane_potential <= sum_plus_product;
            if (comp_result) begin
                membrane_potential <= 0;  
            end else begin
                membrane_potential <= membrane_potential;
            end
        end
    end

    always @(*) begin
        if(reset) begin
            fired = 1'b0;  
        end
        else begin
            if(comp_result) begin
                fired = 1'b1;
            end
            else begin
                fired = 1'b0;
            end
        end
    end

    floatMult mul(
        .floatA(membrane_potential),
        .floatB(leak_factor),
        .product(mulResult)
    );

    floatAdd floatadd (
        .floatA(input_current),
        .floatB(mulResult),
        .sum(sum_plus_product)
	);

    float_compare comp(
        .a(sum_plus_product),
        .b(threshold),
        .c()
    );
	 
    
endmodule
