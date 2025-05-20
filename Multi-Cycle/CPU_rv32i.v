module CPU_rv32i(
    input clk, reset,
    input [31:0] instr,
    input ReadData,

    output [31:0] Result,
    output [31:0] PC,
    output MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData
);

// module t1c_riscv_cpu (
//     input         clk, reset
//     input         Ext_MemWrite,
//     input  [31:0] Ext_WriteData, Ext_DataAdr,
//     output        MemWrite,
//     output [31:0] WriteData, DataAdr, ReadData,
//     output [31:0] PC, Result
// );


// module Controller(
//    input [6:0] op,
//    input Zero,clk,reset,
//    input [2:0] funct3,
//    input [5:0] funct7,
//    output  MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
//    output   [1:0] ResultSrc, ALUSrcA, ALUSrcB,  
//    // Changed from [2:0] to [1:0]
//    output  [2:0] ALUControl,
//    output [2:0] ImmSrc,
// 	output PCWrite,Branch

Controller Control_unit(
    .op(instr[6:0]),
    .Zero(Zero),
    .clk(clk),
    .reset(reset),
    .MemWrite(MW),
    .RegWrite(RegWrite),
    .IRWrite(IRWrite),
    .AdrSrc(AdrSrc),
    .PCUpdate(PCWrite),
    .ResultSrc(ResultSrc),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .Branch(Branch),
    .funct3(instr[14:12]),
    .funct7(instr[31:25]),
   // .ALUOp(ALUOp), // Changed from [2:0] to [1:0]
   .ALUControl(ALUControl),
    .ImmSrc(ImmSrc)
);

// module Datapath(
//     input clk,reset,
//     input MemWrite, RegWrite, IRWrite, AdrSrc,PCWrite,
//     input  [1:0] ResultSrc, ALUSrcA, ALUSrcB, 
//     input [2:0] ImmSrc,
//     input [2:0] ALUControl,
//     output [31:0] PC,
//     output Zero,
//     output [31:0] Mem_WrAddr,Mem_WrData
// );
Datapath datapath(
    .clk(clk),
    .reset(reset),
    .MemWrite(MW),
    .RegWrite(RegWrite),
    .IRWrite(IRWrite),
    .AdrSrc(AdrSrc),
    .PCWrite(PCWrite),
    .ResultSrc(ResultSrc),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl),
    .PC(PC),
    .Zero(Zero),
    .Mem_WrAddr(Mem_WrAddr),
    .Mem_WrData(Mem_WrData),
    .Result(Result)
);
assign MemWrite = MW;
endmodule