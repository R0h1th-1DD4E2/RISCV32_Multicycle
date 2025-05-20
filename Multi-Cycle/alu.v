module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0]  ALUControl,
    output reg [31:0] ALUResult,
    output Zero
    );

    always@(SrcA,SrcB,ALUControl)
    case (ALUControl)
        3'b000:  ALUResult <= SrcA + SrcB;       // ADD
        3'b001:  ALUResult <= SrcA + ~SrcB + 1;  // SUB
        3'b010:  ALUResult <= SrcA & SrcB;       // AND
        3'b011:  ALUResult <= SrcA | SrcB;       // OR
        3'b101:  begin                           // SLT
                     if (SrcA[31] != SrcB[31]) ALUResult <= SrcA[31] ? 0 : 1;
                     else ALUResult <= SrcA < SrcB ? 1 : 0;
                 end
        default: ALUResult = 0;
    endcase

assign Zero = (ALUResult == 0) ? 1'b1 : 1'b0;
 
endmodule
