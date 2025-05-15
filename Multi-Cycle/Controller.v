module controller (
    input [6:0] op,
    input Zero,
    // input [2:0] funct3,
    // input [5:0] funct7,
    output reg MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,
    output reg  [1:0] ResultSrc, ALUSrcA, ALUSrcB, ImmSrc, Branch,
    output reg [1:0] ALUOp // Changed from [2:0] to [1:0]
    //output reg [2:0] ALUControl
);

parameter [3:0]S0_fetch=3'b000, // Note: Parameter width is for state variables, not ALUOp
        S1_decode=3'b001,
        S2_MemAdr=3'b010,
        S3_MemRead=3'b011,
        S4_MemWB=3'b100,
        S5_MemWrite=3'b101,
        S6_ExecuteR=3'b110,
        S7_ALUWB=3'b111,
        S8_ExecuteI=3'b1000,
        S9_JAL=3'b1001,
        S10_BEQ=3'b1010;
reg [3:0] present_state, next_state;
//MemWrite,RegWrite, IRWrite, AdrSrc, PCUpdate,ResultSrc, ALUSrcA, ALUSrcB, ImmSrc, Branch,ALUOp,ALUControl
always@(*)
begin
    // Default values for outputs to avoid latches, if necessary
    // For example:
    // MemWrite = 1'b0; RegWrite = 1'b0; ... ALUOp = 2'bxx;
    case(present_state)
       S0_fetch:
       begin
        IRWrite=1'b1;
        AdrSrc=1'b0;
        PCUpdate=1'b1;
        ResultSrc=2'b10;
        ALUSrcA=2'b00;
        ALUSrcB=2'b10;
        ALUOp=2'b00;
        MemWrite=1'b0;
        RegWrite=1'b0;
       end

       S1_decode:
       begin
          ALUSrc=2'b01;
          ALUSrcB=2'b01 ;
          ALUOp=2'b00;
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end

       S2_MemAdr:
       begin
          ALUSrcA=2'b10;
          ALUSrcB=2'b01;
          ImmSrc=2'b00;
          ALUOp=2'b00; // Changed from 3'b000
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end

       S3_MemRead:
       begin
          AdrSrc=1'b1;
          ResultSrc=2'b00;
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          PCUpdate=1'b0;
       end

       S4_MemWB:
       begin
          ResultSrc=2'b01;
          RegWrite=1'b1;
          MemWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end
     
       S5_MemWrite:
       begin
          ResultSrc=2'b00;
          AdrSrc=1'b1;
          MemWrite=1'b1;
          RegWrite=1'b0;
          IRWrite=1'b0;
          PCUpdate=1'b0;
       end

       S6_ExecuteR:
       begin
          ALUSrcA=2'b10;
          ALUSrcB=2'b00;
          ALUOp=2'b10; // Changed from 3'b010
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end

       S7_ALUWB:
       begin
          ResultSrc=2'b00;
          RegWrite=1'b1;
          MemWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end

       S8_ExecuteI:
       begin
          ALUSrcA=2'b10;
          ALUSrcB=2'b01;
          ALUOp=2'b10; // Changed from 3'b010
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end

       S9_JAL:
       begin
          ALUSrcA=2'b01;
          ALUSrcB=2'b10;
          ALUOp=2'b00; // Changed from 3'b000
          ResultSrc=2'b00;
          PCUpdate=1'b1;
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
       end

       S10_BEQ:
       begin
          ALUSrcA=2'b10;
          ALUSrcB=2'b00;
          ALUOp=2'b01; // Changed from 3'b001
          Branch=1'b1;
          ResultSrc=2'b00;
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0;
          AdrSrc=1'b0;
          PCUpdate=1'b0;
       end

       // It's good practice to have a default case
       default: 
       begin
          MemWrite=1'b0;
          RegWrite=1'b0;
          IRWrite=1'b0; // Or appropriate default
          AdrSrc=1'b0;
          PCUpdate=1'b0; // Or appropriate default
          ResultSrc=2'b00;
          ALUSrcA=2'b00;
          ALUSrcB=2'b00;
          ImmSrc=2'b00;
          Branch=1'b0;
          ALUOp=2'b00; // Or 2'bxx
          // ALUControl = ...
       end
    endcase
end

always@(*)
begin
    case(present_state)
        S0_fetch: next_state=S1_decode;
        S1_decode: begin
            case(op)
                7'b0000011: next_state=S2_MemAdr; // lw
                7'b0100011: next_state=S5_MemWrite; // sw
                7'b0110011: next_state=S6_ExecuteR; // R-type
                7'b1100011: next_state=S10_BEQ; // beq
                7'b0010011: next_state=S8_ExecuteI; // addi
                7'b1101111: next_state=S9_JAL; // jal
                default: next_state=S1_decode; // Stay in decode for undefined opcodes
            endcase
        end

        S2_MemAdr: 
        begin
            case(op)
                7'b0000011: next_state=S3_MemRead; // lw
                7'b0100011: next_state=S5_MemWrite; // sw
                default: next_state=S1_decode; // Stay in decode for undefined opcodes
            endcase
        end
         
        S3_MemRead: next_state=S4_MemWB;
        S4_MemWB: next_state=S0_fetch;
        S5_MemWrite: next_state=S0_fetch;
        S6_ExecuteR: next_state=S7_ALUWB;
        S7_ALUWB: next_state=S0_fetch;
        S8_ExecuteI: next_state=S7_ALUWB;
        S9_JAL: next_state=S7_ALUWB;
        S10_BEQ: next_state= S0_fetch;

        default: next_state = S0_fetch; // Default to fetch state for safety
    endcase
end

always@(posedge clk)
begin
    if (reset) begin
        present_state <= S0_fetch; // Reset to initial state
    end else begin
        present_state <= next_state;
    end
end

assign PCWrite=(Zero&Branch)||PCUpdate;
endmodule