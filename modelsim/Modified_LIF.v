// LIF
module LIFNeuron(
    input clk,
    input reset,
    input [15:0] input_current,             // Synaptic input current
    output reg fired                        // Output spike
);
    integer threshold = 16'h3C00;
    integer leak_factor = 16'h3800;
    integer delta_threshold = 16'h3C00;
    integer decay_factor = 16'h3B99;

    reg [15:0] membrane_potential;
    wire [15:0] leaked_membrane_potential;
    wire [15:0] cur_membrane_potential;
    wire [15:0] raised_threshold;
    wire [15:0] decay_threshold;
    reg [15:0] cur_threhsold;

    always @(posedge clk) begin
        if (reset) begin
            // Reset potential to 0 or reset_potential as needed
            membrane_potential <= 0;        
            fired <= 0;
            cur_threhsold <= threshold;
        end else begin
            // Update membrane potential with input current and leakage
            membrane_potential <= cur_membrane_potential;
            if (fired) begin
                membrane_potential <= 0;  
                fired <= 1;
                cur_threhsold <= decay_threshold;
            end else begin
                membrane_potential <= membrane_potential;
                fired <= fired;
                cur_threhsold <= cur_threhsold;
            end
        end
    end

    floatMult mul(
        .floatA(membrane_potential),
        .floatB(leak_factor),
        .product(leaked_membrane_potential)
    );

    floatAdd floatadd (
        .floatA(input_current),
        .floatB(leaked_membrane_potential),
        .sum(cur_membrane_potential)
	);

    float_compare comp(
        .a(cur_membrane_potential),
        .b(cur_threshold),
        .c(fired)
    );

    floatAdd floatadd (
        .floatA(cur_threhsold),
        .floatB(delta_threshold),
        .sum(raised_threshold)
	);

    floatMult mul(
        .floatA(raised_threshold),
        .floatB(decay_factor),
        .product(decay_threshold)
    );


    

	 
    
endmodule
