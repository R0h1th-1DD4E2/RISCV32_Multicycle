module ff_en(
        input clk,en,
        input [31:0] d,
        output reg [31:0] q
    );
    always @(posedge clk) begin
        if (en) begin
            q <= d;
        end
        else begin
            q <= q;
        end
    end