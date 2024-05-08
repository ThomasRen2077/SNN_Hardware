module ram( 
    output reg [15:0] q,
    input [15:0] d,
    input [13:0] address,
    input we, clk
);

    reg [15:0] mem [16834:0] ;
	
    integer i;
    initial begin
        for (i = 0; i <= 16834; i = i + 1) begin
            mem[i] <= $random; 
        end
    end

    always @ (posedge clk) begin
        if (we) begin
            mem[address] <= d;
        end
        q <= mem[address]; 
    end
endmodule