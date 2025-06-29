module CPU_rv32i (
    input         clk, reset,
    input  [31:0] Mem_RdData,
    output [31:0] Result,
    output [31:0] PC,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData
    
    // DEBUG
    `ifdef DEBUG
        ,output [31:0] debug_InstrReg,
        output [31:0] debug_RD1, debug_RD2,
        output [31:0] debug_ImmExt,
        output [31:0] debug_SrcA, debug_SrcB,
        output [31:0] debug_ALUResult, debug_ALUOut,
        output [31:0] debug_A, debug_WriteData,
        output [31:0] debug_OldPC,
        output [1:0]  debug_ALUOp,
        output        debug_Branch,
        output        debug_PCWrite_condition,
        output        debug_Zero, debug_Negative, debug_Carry, debug_Overflow,
        output [3:0]  debug_ALUControl,
        output [1:0]  debug_ResultSrc, debug_ALUSrcA, debug_ALUSrcB
    `endif
);

// Internal wire
wire MW, Zero;
wire Negative, Carry;
wire Overflow;
wire RegWrite, IRWrite, AdrSrc, PCWrite, func7b5;
wire [1:0] ResultSrc, ALUSrcA, ALUSrcB;
wire [2:0] ImmSrc, func3;
wire [3:0] ALUControl;
wire [6:0] op;

// Debug wires
`ifdef DEBUG
    wire [31:0] debug_InstrReg_int;
    wire [31:0] debug_RD1_int, debug_RD2_int;
    wire [31:0] debug_ImmExt_int;
    wire [31:0] debug_SrcA_int, debug_SrcB_int;
    wire [31:0] debug_ALUResult_int, debug_ALUOut_int;
    wire [31:0] debug_A_int, debug_WriteData_int;
    wire [31:0] debug_OldPC_int;
    wire [1:0]  debug_ALUOp_int;
    wire        debug_Branch_int;
    wire        debug_PCWrite_condition_int;
`endif

// Controller instantiation
Controller Control_unit (
    .op(op),
    .funct3(func3),
    .funct7b5(func7b5),
    .Zero(Zero),
    .Negative(Negative),
    .Carry(Carry), 
    .Overflow(Overflow), 
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
    .ALUControl(ALUControl),
    .ImmSrc(ImmSrc)
    
    `ifdef DEBUG
        ,.debug_ALUOp(debug_ALUOp_int),
        .debug_Branch(debug_Branch_int),
        .debug_PCWrite(debug_PCWrite_condition_int)
    `endif
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
    .Negative(Negative),
    .Carry(Carry), 
    .Overflow(Overflow), 
    .func7b5(func7b5),
    .func3(func3),
    .op(op),
    .Mem_WrAddr(Mem_WrAddr),
    .Mem_WrData(Mem_WrData),
    .Result(Result)
    
    `ifdef DEBUG
        ,.debug_InstrReg(debug_InstrReg_int),
        .debug_RD1(debug_RD1_int),
        .debug_RD2(debug_RD2_int),
        .debug_ImmExt(debug_ImmExt_int),
        .debug_SrcA(debug_SrcA_int),
        .debug_SrcB(debug_SrcB_int),
        .debug_ALUResult(debug_ALUResult_int),
        .debug_ALUOut(debug_ALUOut_int),
        .debug_A(debug_A_int),
        .debug_WriteData(debug_WriteData_int),
        .debug_OldPC(debug_OldPC_int)
    `endif
);

// Output assignment
assign MemWrite = MW;


`ifdef DEBUG
    assign debug_InstrReg = debug_InstrReg_int;
    assign debug_RD1 = debug_RD1_int;
    assign debug_RD2 = debug_RD2_int;
    assign debug_ImmExt = debug_ImmExt_int;
    assign debug_SrcA = debug_SrcA_int;
    assign debug_SrcB = debug_SrcB_int;
    assign debug_ALUResult = debug_ALUResult_int;
    assign debug_ALUOut = debug_ALUOut_int;
    assign debug_A = debug_A_int;
    assign debug_WriteData = debug_WriteData_int;
    assign debug_OldPC = debug_OldPC_int;
    assign debug_ALUOp = debug_ALUOp_int;
    assign debug_Branch = debug_Branch_int;
    assign debug_PCWrite_condition = debug_PCWrite_condition_int;
    
    assign debug_Zero = Zero;
    assign debug_Negative = Negative;
    assign debug_Carry = Carry;
    assign debug_Overflow = Overflow;
    assign debug_ALUControl = ALUControl;
    assign debug_ResultSrc = ResultSrc;
    assign debug_ALUSrcA = ALUSrcA;
    assign debug_ALUSrcB = ALUSrcB;
`endif

endmodule
