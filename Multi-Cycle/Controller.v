module Controller(
    input  [6:0] op,
    input        Zero, clk, reset,
    input        Negative, Carry, Overflow,
    input  [2:0] funct3,
    input        funct7b5,
    output       MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
    output [1:0] ResultSrc, ALUSrcA, ALUSrcB,  
    output [2:0] ALUControl,
    output [2:0] ImmSrc,
    output reg   PCWrite
);

wire [1:0] ALUOp ;

Main_FSM Control_signals_gen(
   .op(op),
   .clk(clk),
   .reset(reset),
   .MemWrite(MemWrite),
   .RegWrite(RegWrite),
   .IRWrite(IRWrite),
   .AdrSrc(AdrSrc),
   .PCUpdate(PCUpdate),
   .ResultSrc(ResultSrc),
   .ALUSrcA(ALUSrcA),
   .ALUSrcB(ALUSrcB),
   .Branch(Branch),
   .ALUOp(ALUOp),
   .ImmSrc(ImmSrc)
);

// assign PCWrite=(Zero&Branch)||PCUpdate;
always @(*) begin
    case(funct3)
        3'b000: PCWrite = (Zero && Branch) || PCUpdate;                     // BEQ
        3'b001: PCWrite = (!Zero && Branch) || PCUpdate;                    // BNE
        3'b100: PCWrite = ((Negative ^ Overflow) && Branch) || PCUpdate;    // BLT
        3'b101: PCWrite = (!(Negative ^ Overflow) && Branch) || PCUpdate;   // BGE 
        3'b110: PCWrite = (!Carry && Branch) || PCUpdate;                   // BLTU 
        3'b111: PCWrite = (Carry && Branch) || PCUpdate;                    // BGEU
        default: PCWrite = PCUpdate;
    endcase
end

alu_decoder alu_decoder(
   .opb5(op[5]),
   .funct3(funct3),
   .funct7b5(funct7b5),
   .ALUOp(ALUOp),
   .ALUControl(ALUControl)
);

endmodule