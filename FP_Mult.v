module floating_point_multiplier(
  	input clk,
    input [31:0] a, 				// First operand in IEEE 754 format
    input [31:0] b, 				// Second operand in IEEE 754 format
    output reg [31:0] result 		// Product in IEEE 754 format
);

// Extracting sign, exponent, and mantissa from inputs
reg a_sign, b_sign;
reg [7:0] a_exponent, b_exponent;
reg [22:0] a_mantissa, b_mantissa;

// Intermediate signals for calculations
reg [47:0] product_intermediate;
reg [7:0] exponent_intermediate;
reg [22:0] mantissa_intermediate;

// Output signals
reg result_sign;
reg [7:0] result_exponent;
reg [22:0] result_mantissa;

// Assigning inputs to appropriate parts
assign {a_sign, a_exponent, a_mantissa} = {a[31], a[30:23], a[22:0]};
assign {b_sign, b_exponent, b_mantissa} = {b[31], b[30:23], b[22:0]};

// Multiplying mantissas
  always @(posedge clk) begin
    product_intermediate <= {1'b1, a_mantissa} * {1'b1, b_mantissa};
end

// Adding exponents
  always @(posedge clk) begin
    exponent_intermediate <= a_exponent + b_exponent - 127; // Bias is 127
end

// Handling overflow/underflow in exponent
always @(posedge clk) begin
    if (exponent_intermediate >= 255) begin 		// Maximum exponent value
        result_exponent <= 255;
        result_mantissa <= 23'b0;
    end else if (exponent_intermediate <= 0) begin 	// Minimum exponent value
        result_exponent <= 0;
        result_mantissa <= 23'b0;
    end else begin
        result_mantissa <= product_intermediate[45:23]; 
        if (product_intermediate[47] == 1) begin 
            result_exponent <= exponent_intermediate + 1; 
        end else begin
            result_exponent <= exponent_intermediate;
        end
    end
end

// Handling special cases such as zero and denormalized numbers
always @(posedge clk) begin
    if (a_exponent == 0 || b_exponent == 0) begin // One or both numbers are zero or denormalized
        result_sign <= 1'b0;
        result_exponent <= 0;
        result_mantissa <= 23'b0;
    end else begin
        result_sign <= a_sign ^ b_sign; // XOR operation for sign
    end
end

// Combining the result
always @* begin
    result = {result_sign, result_exponent, result_mantissa};
end

endmodule
