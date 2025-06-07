module ff(
    input clk, reset,
    input [31:0] d,
    output reg [31:0] q
);
    
    always @(posedge clk or posedge reset ) begin
        if (reset == 1)
            q <= 0;
        else
            q <= d;
        
    end
endmodule
	 