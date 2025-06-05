module CPU_rv32i (
    input         clk, reset,
    input  [31:0] Mem_RdData,
    output [31:0] Result,
    output [31:0] PC,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData
);

// Internal wire
wire MW, Zero;
wire RegWrite, IRWrite, AdrSrc, PCWrite, func7b5;
wire [1:0] ResultSrc, ALUSrcA, ALUSrcB;
wire [2:0] ImmSrc, func3;
wire [2:0] ALUControl;
wire [6:0] op;


// Controller instantiation
Controller Control_unit (
    .op(op),
    .funct3(func3),
    .funct7b5(func7b5),
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
    .ALUControl(ALUControl),
    .ImmSrc(ImmSrc)
);

// Datapath instantiation
Datapath datapath (
    .clk(clk),
    .reset(reset),
    .RegWrite(RegWrite),
    .IRWrite(IRWrite),
    .AdrSrc(AdrSrc),
    .PCWrite(PCWrite),
    .ResultSrc(ResultSrc),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .ImmSrc(ImmSrc),
    .ALUControl(ALUControl),
    .Mem_RdData(Mem_RdData),
    .PC(PC),
    .Zero(Zero),
    .func7b5(func7b5),
    .func3(func3),
    .op(op),
    .Mem_WrAddr(Mem_WrAddr),
    .Mem_WrData(Mem_WrData),
    .Result(Result)
);

// Output assignment
assign MemWrite = MW;

endmodule
