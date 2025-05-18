module mux4(
    input     [31:0] d0, d1, d2,d3,
    input      [1:0]  sel,
    output reg [31:0] op
)
    always @(*) begin
        case (sel)
            2'b00: op = d0;
            2'b01: op = d1;
            2'b10: op = d2;
            2'b11: op = d3;// we don't use this case in the code for 3x1 mux
            default: op = 32'h00000000; // Default case to avoid latches
        endcase
    end