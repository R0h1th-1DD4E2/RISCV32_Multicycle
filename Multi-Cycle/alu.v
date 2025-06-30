module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0]  ALUControl, // Changed to 4 bits
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
            4'b0000: begin  // ADD
                {carry_temp, ALUResult} = SrcA + SrcB;
            end
            
            4'b0001: begin  // SUB 
                {carry_temp, ALUResult} = SrcA + (~SrcB) + 1;
            end
            
            4'b0010: begin  // AND
                ALUResult = SrcA & SrcB;
                carry_temp = 1'b0;
            end
            
            4'b0011: begin  // OR
                ALUResult = SrcA | SrcB;
                carry_temp = 1'b0;
            end
            
            4'b0100: begin  // XOR
                ALUResult = SrcA ^ SrcB;
                carry_temp = 1'b0;
            end
            4'b0101: begin  // SLT (Set Less Than - Signed)
                {carry_temp, ALUResult} = SrcA + (~SrcB) + 1;  // Perform subtraction
                // Check if SrcA < SrcB (signed)
                if ((SrcA[31] ^ SrcB[31]) == 1'b1) 
                    ALUResult = SrcA[31] ? 32'b1 : 32'b0;  // Different signs
                else 
                    ALUResult = ALUResult[31] ? 32'b1 : 32'b0;  // Same signs, check result sign
            end
            4'b0110: begin  // SLTU (Set Less Than - Unsigned)
                if (SrcA < SrcB) 
                    ALUResult = 32'b1;  // SrcA is less than SrcB
                else 
                    ALUResult = 32'b0;  // SrcA is not less than SrcB
                carry_temp = 1'b0;
            end
            4'b0111: begin  // srl (Shift Right Logical)
                ALUResult = SrcA >> SrcB[4:0];  // Shift right by lower 5 bits of SrcB
                carry_temp = SrcA[0];  // Capture the least significant bit before shift
            end
            4'b1000: begin  // SRA (Shift Right Arithmetic)
                ALUResult = $signed(SrcA) >>> SrcB[4:0];  // Sign-extended right shift
                carry_temp = SrcA[0];                    // Capture LSB before shift
            end

            4'b1001: begin  // sll (Shift Left Logical)
                ALUResult = SrcA << SrcB[4:0];  // Shift left by lower 5 bits of SrcB
                carry_temp = SrcA[31];  // Capture the most significant bit before shift
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
    assign Overflow = (ALUControl == 4'b0000) ? 
                    ((SrcA[31] == SrcB[31]) && (SrcA[31] != ALUResult[31])) :  // ADD overflow
                    (ALUControl == 4'b0001) ? 
                    ((SrcA[31] != SrcB[31]) && (SrcA[31] != ALUResult[31])) :  // SUB overflow
                    1'b0; 

endmodule
