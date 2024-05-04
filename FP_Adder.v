module FloatingPointAdder(
    input [31:0] a, // First floating-point operand
    input [31:0] b, // Second floating-point operand
    output reg [31:0] result, // Result of addition
);

    // Extracting components of operand 'a'
    reg [30:23] exp_a;
    reg [22:0]  mant_a;
    reg sign_a;

    // Extracting components of operand 'b'
    reg [30:23] exp_b;
    reg [22:0] mant_b;
    reg sign_b;

    // Extracting the sign, exponent, and mantissa of 'a'
    assign sign_a = a[31];
    assign exp_a = a[30:23];
    assign mant_a = a[22:0];

    // Extracting the sign, exponent, and mantissa of 'b'
    assign sign_b = b[31];
    assign exp_b = b[30:23];
    assign mant_b = b[22:0];

    // Adding or subtracting the exponents based on the difference
    reg [30:23] sum_exp;
    always @* begin
        if (exp_a > exp_b) begin
            sum_exp = exp_a;
        end else begin
            sum_exp = exp_b;
        end
    end

    // Aligning mantissas based on the difference in exponents
    reg [23:0] mant_a_shifted;
    reg [23:0] mant_b_shifted;
    always @* begin
      if (exp_a > exp_b) begin
        mant_a_shifted = {1'b1, mant_a};
        mant_b_shifted = {1'b0, mant_b} >> (exp_a - exp_b);
      end else begin
        mant_a_shifted = {1'b0, mant_a} >> (exp_b - exp_a);
        mant_b_shifted = {1'b1, mant_b};
      end
    end

    // Adding or subtracting mantissas based on the sign of operands
    reg [24:0] sum_mant;
    reg result_sign;
    always @* begin
      if (sign_a == sign_b) begin 
        sum_mant = mant_a_shifted + mant_b_shifted;
        result_sign = sign_a;
      end else begin 
        if (mant_a_shifted > mant_b_shifted) begin
          sum_mant = mant_a_shifted - mant_b_shifted;
          result_sign = sign_a;
        end else begin
          sum_mant = mant_b_shifted - mant_a_shifted;
          result_sign = sign_b;
        end
      end
    end

    // Normalizing the result if necessary
    always @* begin
        if (sum_mant[24]) begin
          result = {result_sign, sum_exp + 1, sum_mant[23:1]};
        end else begin
          result = {result_sign, sum_exp, sum_mant[22:0]}; 
        end
    end

endmodule
