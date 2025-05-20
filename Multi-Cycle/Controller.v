module Controller(
   input [6:0] op,
   input Zero,clk,reset,
   input [2:0] funct3,
   input [5:0] funct7,
   output  MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
   output   [1:0] ResultSrc, ALUSrcA, ALUSrcB,  
   // Changed from [2:0] to [1:0]
   output  [2:0] ALUControl,
   output [2:0] ImmSrc,
	output PCWrite,Branch

);
// module Main_FSM (
//    input [6:0] op,
//    input Zero,clk,reset,
//    // input [2:0] funct3,
//    // input [5:0] funct7,
//    output reg MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
//    output reg  [1:0] ResultSrc, ALUSrcA, ALUSrcB,  Branch,
//    output reg [1:0] ALUOp ,// Changed from [2:0] to [1:0]
//    output reg [2:0]  ImmSrc,
// 	output PCWrite
// );
wire [1:0] ALUOp ;
Main_FSM Control_signals_gen(
   .op(op),
   .Zero(Zero),
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
   .ALUOp(ALUOp), // Changed from [2:0] to [1:0]
   //.ALUControl(ALUControl),
   .ImmSrc(ImmSrc)
);

assign PCWrite=(Zero&Branch)||PCUpdate;

alu_decoder alu_decoder(
   .opb5(op[5]),
   .funct3(funct3),
   .funct7b5(funct7[5]),
   .ALUOp(ALUOp),
   .ALUControl(ALUControl)
);

endmodule