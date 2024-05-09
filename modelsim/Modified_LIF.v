// LIF
module Modified_LIFNeuron(
    input clk,
    input reset,
    input [15:0] input_current,             // Synaptic input current
    output reg fired                        // Output spike
);
    integer threshold = 16'h3C00; // 1
    integer leak_factor = 16'h3800; //0.5
    integer delta_threshold = 16'h3800; //0.5
    integer decay_factor = 16'h3B99; //0.95

    reg [15:0] membrane_potential;
    wire fired_wire;
    wire [15:0] leaked_membrane_potential;
    wire [15:0] next_membrane_potential;
    wire [15:0] raised_threshold;
    wire [15:0] decay_threshold;
    reg [15:0] cur_threshold;

    always @(posedge clk) begin
        if (reset) begin
            // Reset potential to 0 or reset_potential as needed
            membrane_potential <= 0;        
            fired <= 0;
            cur_threshold <= threshold;
        end else begin
            // Update membrane potential with input current and leakage
            membrane_potential <= next_membrane_potential;
            if (fired_wire) begin
                membrane_potential <= 0;  
                fired <= 1;
                cur_threshold <= decay_threshold;
            end else begin
                membrane_potential <= next_membrane_potential;
                fired <= 0;
                cur_threshold <= cur_threshold;
            end
        end
    end

    floatMult mul(
        .floatA(membrane_potential),
        .floatB(leak_factor),
        .product(leaked_membrane_potential)
    );

    floatAdd floatadd_1 (
        .floatA(input_current),
        .floatB(leaked_membrane_potential),
        .sum(next_membrane_potential)
	);

    float_compare comp(
        .a(membrane_potential),
        .b(cur_threshold),
        .c(fired_wire)
    );

    floatAdd floatadd_2 (
        .floatA(cur_threshold),
        .floatB(delta_threshold),
        .sum(raised_threshold)
	);

    floatMult mul_2(
        .floatA(raised_threshold),
        .floatB(decay_factor),
        .product(decay_threshold)
    );


    

	 
    
endmodule
