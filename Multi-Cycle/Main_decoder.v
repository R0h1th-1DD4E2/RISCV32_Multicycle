module main_decoder (
    input  [6:0] op,                // RISC-V 7-bit opcode
    output       RegWrite, Jump,    // Standard signals
    output       ALUSrc, Branch,    // ALU control
    output       MemWrite,          // Memory write
    output       MemtoReg,          // Writeback: 0=ALU, 1=Memory
    output [1:0] ALUOp,             // ALU operation
    output       IorD               // 0=PC (fetch), 1=ALU (load/store)
);

//-----------------Control Bit Mapping-----------------//
// {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, ALUOp[1:0], Jump, IorD}
reg [8:0] controls;

//-----------------RISC-V Opcodes-----------------//
localparam  LOAD   = 7'b0000011,
            STORE  = 7'b0100011,
            BRANCH = 7'b1100011,
            JAL    = 7'b1101111,
            OP_IMM = 7'b0010011,
            OP     = 7'b0110011;

//-----------------Control Logic-----------------//
always @(*) begin
    case (op)
        // Format: RegWrite_ALUSrc_MemWrite_MemtoReg_Branch_ALUOp_Jump_IorD
        LOAD:   controls = 9'b1_1_0_1_0_00_0_1; // lw: ALU=addr, writeback=Mem
        STORE:  controls = 9'b0_1_1_0_0_00_0_1; // sw: ALU=addr, no writeback
        OP_IMM: controls = 9'b1_1_0_0_0_10_0_0; // addi: ALU=imm, no memory
        OP:     controls = 9'b1_0_0_0_0_10_0_0;  // add: ALU=reg, no memory
        BRANCH: controls = 9'b0_0_0_0_1_01_0_0;  // beq: ALU=reg, compare
        JAL:    controls = 9'b1_0_0_0_0_00_1_0;  // jal: PC=JTA, write PC+4
        default:controls = 9'bx_x_x_x_x_xx_x_x;   // Undefined
    endcase
end

//-----------------Output Assignments-----------------//
assign {RegWrite, ALUSrc, MemWrite, MemtoReg, Branch, ALUOp, Jump, IorD} = controls;

endmodule