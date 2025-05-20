module ff(
    input clk, reset,
    input [31:0] d,
    output reg [31:0] q
);
    always @(posedge clk) begin
        if (reset==0) 
            q <= d;
            else
            q <= q;
        
    end
	 endmodule
	 