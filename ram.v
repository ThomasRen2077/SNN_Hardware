module ram( 
    output reg [15:0] q,
    input [15:0] d,
    input [11:0] address,
    input we, clk
);

    reg [15:0] mem [4096:0] ;
	 
    always @ (posedge clk) begin
        if (we) begin
            mem[address] <= d;
        end
        q <= mem[address]; 
    end
endmodule