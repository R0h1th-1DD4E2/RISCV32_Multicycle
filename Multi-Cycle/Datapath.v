module Datapath(
    input clk,reset,
    input MemWrite, RegWrite, IRWrite, AdrSrc,PCWrite,
    input  [1:0] ResultSrc, ALUSrcA, ALUSrcB, 
    input [2:0] ImmSrc,
    input [2:0] ALUControl,
    output [31:0] PC,
    output Zero,
    output [31:0] Mem_WrAddr,Mem_WrData,Result
);

// Wire declarations
//wire PCWrite;
wire [31:0] PCNext, OldPC, Adr;
wire [31:0] Instr, InstrReg, ReadData, Data;
wire [31:0] RD1, RD2, A, WriteData;
wire [31:0] ImmExt;
wire [31:0] SrcA, SrcB;
wire [31:0] ALUResult, ALUOut;
//wire [2:0] ALUControl;

// Module instantiations
ff_en pcreg(.clk(clk), .en(PCWrite), .d(Result), .q(PC));
ff_en pcnextreg(.clk(clk), .en(IRWrite), .d(PC), .q(OldPC));

mux2 pc_mux(.d0(PC), .d1(Result), .sel(AdrSrc), .op(Adr));

Instr_Data_mem memory(.clk(clk), .MemWrite(MemWrite), .A(PC), .WD(WriteData), 
.Instr(Instr), .RD(ReadData));

ff_en instreg(.clk(clk), .en(IRWrite), .d(Instr), .q(InstrReg));
ff readData(.clk(clk), .reset(reset), .d(ReadData), .q(Data));

Register regfile(.clk(clk), .WE3(RegWrite), .A1(InstrReg[19:15]), .A2(InstrReg[24:20]), .A3(InstrReg[11:7]),
.WD3(Result), .RD1(RD1), .RD2(RD2));

Extend ext(.instr(InstrReg[31:7]), .ImmSrc(ImmSrc), .immext(ImmExt));

ff regfile_A(.clk(clk), .reset(reset), .d(RD1), .q(A));
ff regfile_Write_data(.clk(clk), .reset(reset), .d(RD2), .q(WriteData));

mux4 ALUSrcA_mux_3(.d0(PC), .d1(OldPC), .d2(A), .d3(2'b11), .sel(ALUSrcA), .op(SrcA));

mux4 ALUSrcB_mux(.d0(WriteData), .d1(ImmExt), .d2(31'd4), .d3(32'b11), .sel(ALUSrcB), .op(SrcB));

alu ALU(.SrcA(SrcA), .SrcB(SrcB), .ALUControl(ALUControl), .Zero(Zero), .ALUResult(ALUResult));

ff alu_result(.clk(clk), .reset(reset), .d(ALUResult), .q(ALUOut));

mux4 ResultSrc_mux(.d0(ALUOut), .d1(ReadData), .d2(PC), .d3(2'b11), .sel(ResultSrc), .op(Result));

assign Mem_WrAddr = ALUOut;
assign Mem_WrData = WriteData;

endmodule
// module Extend(
//     input [31:7] instr,
//     input [2:0]ImmSrc,
//     output reg  [31:0]immext
// );