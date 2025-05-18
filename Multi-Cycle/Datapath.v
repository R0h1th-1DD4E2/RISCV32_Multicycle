module datapath(
    input clk,reset,
    input MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
    input  [1:0] ResultSrc, ALUSrcA, ALUSrcB, Branch,
    input [2:0] ImmSrc,
    input [1:0] ALUOp,
    output [31:0] PC,
    output Zero, // Changed from [2:0] to [1:0]
    //input [2:0] ALUControl

);
// module mux2 #(parameter WIDTH = 8) (
//     input       [WIDTH-1:0] d0, d1,
//     input       sel,
//     output      [WIDTH-1:0] y
// );
// module Controller (
//     input clk,reset, 
//     input [6:0] op,
//     input Zero,
//     // input [2:0] funct3,
//     // input [5:0] funct7,
//     output PCWrite,
//     input MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
//     input  [1:0] ResultSrc, ALUSrcA, ALUSrcB, ImmSrc, Branch,
//     input [1:0] ALUOp // Changed from [2:0] to [1:0]
//     //input [2:0] ALUControl
// );
// module Instr_Data_mem(
//     input        clk,
//     input        MemWrite,     // write enable for data memory
//     input [31:0] A,            // address
//     input [31:0] WD,           // write data
//     output [31:0] Instr,       // fetched instruction
//     output [31:0] RD           // read data
// );
// module Register(
//     input clk,WE3,
//     input [3:0] A1,A2,A3,
//     input [31:0] WD3,
//     output [31:0] RD1,RD2
// );

ff_en pcreg(.clk(clk),.en(PCWrite),.d(PCNext),.q(PC));
ff_en pcnextreg(.clk(clk),.en(IRWrite),.d(PC),.q(OldPC));

mux2 pc_mux(.d0(PC), .d1(PC), .sel(AdrSrc), .op(Adr));

Instr_Data_mem memory(.clk(clk), .MemWrite(MemWrite), .A(PC), .WD(WriteData), 
.Instr(Instr), .RD(ReadData));

ff_en instreg(.clk(clk), .en(IRWrite), .d(Instr), .q(InstrReg));
ff readData(.clk(clk), .reset(reset), .d(ReadData), .q(Data));

Register regfile(.clk(clk),.WE3(RegWrite),.(A1(InstrReg[19:15]), .A2(InstrReg[24:20]), .A3(InstrReg[11:7]),
.WD3(Result), .RD1(RD1), .RD2(RD2));

Extend ext(.in(InstrReg[31:7]), .ImmSrc(ImmSrc).out(ImmExt));

ff regfile_A(.clk(clk), .reset(reset), .d(RD1), .q(A));
ff regfile_Write_data(.clk(clk), .reset(reset), .d(RD2), .q(WriteData));

mux4 ALUSrcA_mux_3(.d0(PC), .d1(OldPC), .d2(A), .d3(2'b11), .sel(ALUSrcA), .op(SrcA));//here remember we never use the 4th input d3,ALUSrcA never be equal to 2'b11

mux4 ALUSrcB_mux(.d0(WriteData), .d1(ImmExt), .d2(31'd4), .d3(32'b0), .sel(ALUSrcB), .op(SrcB));//here remember we never use the 4th input d3,ALUSrcB never be equal to 2'b11

alu ALU(.A(SrcA), .B(SrcB), .ALUControl(ALUControl), .Zero(Zero), .Result(ALUResult));

ff alu_result(.clk(clk), .reset(reset), .d(ALUResult), .q(ALUOut));

mux4 ResultSrc_mux(.d0(ALUOut), .d1(ReadData), .d2(PC), .d3(2'b11), .sel(ResultSrc), .op(Result));//here remember we never use the 4th input d3,ResultSrc never be equal to 2'b11









mux4 SrcAmux()

