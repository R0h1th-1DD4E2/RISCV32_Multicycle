// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,       // Instruction bit 30
    input [2:0]      funct3,     // Instruction bits 14-12
    input            funct7b5,   // Instruction bit 25
    input [1:0]      ALUOp,      // Control signal from main control unit
    output reg [3:0] ALUControl  // 4-bit control signal for the ALU
);

// Determine the ALU operation based on ALUOp and instruction fields
always @(*) begin
    case (ALUOp)
        // ALUOp indicates the instruction type
        2'b00: begin // Load/Store/Branch (address calculation)
            ALUControl = 4'b0000; // add
        end
        2'b01: begin // Typically used for SUB in some designs
            ALUControl = 4'b0001; // subtract
        end
        default: begin // ALUOp is 2'b10 or 2'b11 - R-type or I-type arithmetic/logical
            // Specific operation determined by funct3 and funct7/opb5
            case (funct3)
                3'b000: begin // ADD, SUB, ADDI
                    if (funct7b5 & opb5) begin
                        ALUControl = 4'b0001; // subtract (R-type SUB)
                    end else begin
                        ALUControl = 4'b0000; // add (R-type ADD, I-type ADDI)
                    end
                end
                3'b001: begin // SLL, SLLI
                        ALUControl = 4'b1001; // sll
                end
                3'b010: begin // SLT, SLTI
                    ALUControl = 4'b0101; // slt
                end
                3'b011: begin // SLTU, SLTIU
                    ALUControl = 4'b0110; // sltu
                end
                3'b100: begin // XOR, XORI
                    ALUControl = 4'b0100; // xor
                end
                3'b101: begin // SRLI, SRAI, SRL, SRA
                    case ({opb5, funct7b5})
                        2'b00: ALUControl = 4'b0111; // srli/srl
                        2'b01: ALUControl = 4'b1000; // srai/sra
                        2'b10: ALUControl = 4'b0111; // srl (example mapping)
                        2'b11: ALUControl = 4'b1000; // sra (example mapping)
                        default: ALUControl = 4'bxxxx; // Error/Default
                    endcase
                end
                3'b110: begin // OR, ORI
                    ALUControl = 4'b0011; // or
                end
                3'b111: begin // AND, ANDI
                    ALUControl = 4'b0010; // and
                end
                default: begin // Unrecognized funct3
                    ALUControl = 4'bxxxx; // Unknown operation
                end
            endcase
        end
    endcase
end

endmodule
