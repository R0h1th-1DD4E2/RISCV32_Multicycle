module Datapath (
    input         clk, reset,
    input         RegWrite, IRWrite, AdrSrc, PCWrite,
    input  [1:0]  ResultSrc, ALUSrcA, ALUSrcB, 
    input  [2:0]  ImmSrc,
    input  [2:0]  ALUControl,
    input  [31:0] Mem_RdData,
    output [31:0] PC,
    output        Zero,
    output        Negative,
    output        Carry,
    output        Overflow,
    output        func7b5,
    output [2:0]  func3,
    output [6:0]  op,
    output [31:0] Mem_WrAddr, Mem_WrData, Result
    
    //DEBUG
    `ifdef DEBUG
        ,output [31:0] debug_InstrReg,
        output [31:0] debug_RD1, debug_RD2,
        output [31:0] debug_ImmExt,
        output [31:0] debug_SrcA, debug_SrcB,
        output [31:0] debug_ALUResult, debug_ALUOut,
        output [31:0] debug_A, debug_WriteData,
        output [31:0] debug_OldPC
    `endif
);

// Internal wire declarations
wire [31:0] OldPC, Adr;
wire [31:0] InstrReg, Data; // ReadData, Removed so that Memory is outside CPU
wire [31:0] RD1, RD2, A, WriteData;
wire [31:0] ImmExt;
wire [31:0] SrcA, SrcB;
wire [31:0] ALUResult, ALUOut;

// PC and OldPC registers
ff_en pcreg       (.clk(clk), .en(PCWrite), .d(Result), .q(PC));
ff_en pcnextreg   (.clk(clk), .en(IRWrite), .d(PC),     .q(OldPC));

// Address MUX for memory access
mux2 pc_mux       (.d0(PC), .d1(Result), .sel(AdrSrc), .op(Adr));

// Memory block
//Instr_Data_mem memory (
//    .clk(clk), .MemWrite(MemWrite),
//    .A(PC), .WD(WriteData),
//    .RD(ReadData)
//);

// Instruction Register
ff_en instreg     (.clk(clk), .en(IRWrite), .d(Mem_RdData), .q(InstrReg));
ff    readData    (.clk(clk), .reset(reset), .d(Mem_RdData), .q(Data));

// Register File
Register regfile (
    .clk(clk), .WE3(RegWrite),
    .A1(InstrReg[19:15]), .A2(InstrReg[24:20]), .A3(InstrReg[11:7]),
    .WD3(Result), .RD1(RD1), .RD2(RD2)
);

// Immediate Generator
Extend ext (
    .instr(InstrReg[31:7]), .ImmSrc(ImmSrc), .immext(ImmExt)
);

// Registering operands
ff regfile_A            (.clk(clk), .reset(reset), .d(RD1),      .q(A));
ff regfile_Write_data   (.clk(clk), .reset(reset), .d(RD2),      .q(WriteData));

// ALU input MUXes
mux4 ALUSrcA_mux_3      (.d0(PC), .d1(OldPC), .d2(A),         .d3(32'b11), .sel(ALUSrcA), .op(SrcA));
mux4 ALUSrcB_mux        (.d0(WriteData), .d1(ImmExt), .d2(32'd4), .d3(32'b11), .sel(ALUSrcB), .op(SrcB));

// ALU
alu ALU (
    .SrcA(SrcA), .SrcB(SrcB),
    .ALUControl(ALUControl),
    .Zero(Zero), .Negative(Negative),
    .Carry(Carry), .Overflow(Overflow), 
    .ALUResult(ALUResult)
);

// ALU result register
ff alu_result           (.clk(clk), .reset(reset), .d(ALUResult), .q(ALUOut));

// Result multiplexer
mux4 ResultSrc_mux      (.d0(ALUOut), .d1(Data), .d2(ALUResult), .d3(32'b0),
                         .sel(ResultSrc), .op(Result));

// Assign memory interface outputs
assign Mem_WrAddr = Adr;
assign Mem_WrData = WriteData;
assign func7b5 = InstrReg[30];
assign func3 = InstrReg[14:12];
assign op = InstrReg[6:0];

`ifdef DEBUG
    assign debug_InstrReg = InstrReg;
    assign debug_RD1 = RD1;
    assign debug_RD2 = RD2;
    assign debug_ImmExt = ImmExt;
    assign debug_SrcA = SrcA;
    assign debug_SrcB = SrcB;
    assign debug_ALUResult = ALUResult;
    assign debug_ALUOut = ALUOut;
    assign debug_A = A;
    assign debug_WriteData = WriteData;
    assign debug_OldPC = OldPC;
`endif

endmodule
