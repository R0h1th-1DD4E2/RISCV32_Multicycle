module Extend(
    input [31:7] instr,
    input [2:0]ImmSrc,
    output reg  [31:0]immext
);
    always@(*)
    begin
        case(ImmSrc)
        3'b000:   immext = {{20{instr[31]}}, instr[31:20]};
        // S−type (stores)
        3'b001:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        // B−type (branches)
        3'b010:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        // J−type (jal)
        3'b011:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        // U-type (e.g., lui, auipc)
        3'b100: immext = {instr[31:12], 12'b0};
        default: immext = 32'bx; // undefined
        endcase
    end
endmodule
// =========================================================================================
// | 31:25        | 24:20      | 19:15      | 14:12      | 11:7       | 6:0        | Format |
// |--------------|------------|------------|------------|------------|------------|--------|
// | funct7       | rs2        | rs1        | funct3     | rd         | op         | R-Type |
// | imm[11:0]    |            | rs1        | funct3     | rd         | op         | I-Type |
// | imm[11:5]    | rs2        | rs1        | funct3     | imm[4:0]   | op         | S-Type |
// | imm[12],10:5 | rs2        | rs1        | funct3     | imm[4:1],11| op         | B-Type |
// | imm[31:12]   |            |            |            | rd         | op         | U-Type |
// | imm[20,10:1, |            |            |            | rd         | op         | J-Type |
// | 11,19:12]    |            |            |            |            |            |        |
// | fs3          | funct2     | fs2        | fs1        | funct3     | fd         | R4-Type|
// =========================================================================================



