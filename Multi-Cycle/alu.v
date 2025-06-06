module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [2:0]  ALUControl,
    output reg [31:0] ALUResult,
    output Zero,
    output Negative,
    output Carry,
    output Overflow
);

    reg carry_temp;  // Extra bit for carry detection
    
    always @(*) begin
        carry_temp = 1'b0;
        
        case (ALUControl)
            3'b000: begin  // ADD
                 {carry_temp, ALUResult} = SrcA + SrcB;
            end
            
            3'b001: begin  // SUB 
                {carry_temp, ALUResult} = SrcA + (~SrcB) + 1;
            end
            
            3'b010: begin  // AND
                ALUResult = SrcA & SrcB;
                carry_temp = 1'b0;
            end
            
            3'b011: begin  // OR
                ALUResult = SrcA | SrcB;
                carry_temp = 1'b0;
            end
            
            3'b101: begin  // SLT (Set Less Than - Signed)
                {carry_temp, ALUResult} = SrcA + (~SrcB) + 1;  // Perform subtraction
                // Check if SrcA < SrcB (signed)
                if ((SrcA[31] ^ SrcB[31]) == 1'b1) 
                    ALUResult = SrcA[31] ? 32'b1 : 32'b0;  // Different signs
                else 
                    ALUResult = ALUResult[31] ? 32'b1 : 32'b0;  // Same signs, check result sign
            end
            
            default: begin
                ALUResult = 32'b0;
                carry_temp = 1'b0;
            end
        endcase
    end
    
    // Flag generation
    assign Zero = (ALUResult == 32'b0);
    assign Negative = ALUResult[31];
    assign Carry = carry_temp;
    assign Overflow = (ALUControl == 3'b000) ? 
                      ((SrcA[31] == SrcB[31]) && (SrcA[31] != ALUResult[31])) :  // ADD overflow
                      (ALUControl == 3'b001) ? 
                      ((SrcA[31] != SrcB[31]) && (SrcA[31] != ALUResult[31])) :  // SUB overflow
                      1'b0; 
                      // (+) - (-) = Positive huge number
                      // (-) - (+) = Negative huge number

endmodule