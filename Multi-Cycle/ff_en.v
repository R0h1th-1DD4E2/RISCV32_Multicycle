module ff_en(
        input clk,en,reset,
        input [31:0] d,
        output reg [31:0] q
    );
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 0;
        else if (en) 
            q <= d;
        else 
            q <= q;    
    end
endmodule