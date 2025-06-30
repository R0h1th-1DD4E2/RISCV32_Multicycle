module Main_FSM (
    input        clk,
    input        reset,
    input [6:0]  op,

    output reg        MemWrite,
    output reg        RegWrite,
    output reg        IRWrite,
    output reg        AdrSrc,
    output reg        PCUpdate,
    output reg [1:0]  ResultSrc,
    output reg [1:0]  ALUSrcA,
    output reg [1:0]  ALUSrcB,
    output reg        Branch,
    output reg [1:0]  ALUOp,
    output reg [2:0]  ImmSrc   // Changed to 2 bits
);


parameter [3:0] 
    S0_fetch     = 4'b0000,
    S1_decode    = 4'b0001,
    S2_MemAdr    = 4'b0010,
    S3_MemRead   = 4'b0011,
    S4_MemWB     = 4'b0100,
    S5_MemWrite  = 4'b0101,
    S6_ExecuteR  = 4'b0110,
    S7_ALUWB     = 4'b0111,
    S8_ExecuteI  = 4'b1000,
    S9_JAL       = 4'b1001,
    S10_BRANCH   = 4'b1010;


reg [3:0] present_state, next_state;


always @(*) begin
    case (present_state)
        S0_fetch: begin
            IRWrite    = 1'b1;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b1;
            ResultSrc  = 2'b10;
            ALUSrcA    = 2'b00;
            ALUSrcB    = 2'b10;
            ALUOp      = 2'b00;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            Branch     = 1'b0;
            ImmSrc     = 3'b010;          
        end

        S1_decode: begin
            ALUSrcA    = 2'b01;
            ALUSrcB    = 2'b01;
            ALUOp      = 2'b00;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            Branch     = 1'b0;
            // ImmSrc     = (op == 7'h6f) ? 3'b011 : 3'b000;
            case(op)
                7'h03 : ImmSrc = 3'b000;    // load I type
                7'h63 : ImmSrc = 3'b010;    // B type
                7'h6F : ImmSrc = 3'b011;    // J type
                default : ImmSrc = 3'b000;
            endcase
            ResultSrc  = 2'b00;
        end

        S2_MemAdr: begin
            ALUSrcA    = 2'b10;
            ALUSrcB    = 2'b01;
            ImmSrc     = op[5] ? 3'b001 : 3'b000;
            ALUOp      = 2'b00;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            Branch     = 1'b0;
            ResultSrc  = 2'b00;
        end

        S3_MemRead: begin
            AdrSrc     = 1'b1;
            ResultSrc  = 2'b00;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            PCUpdate   = 1'b0;
            ALUOp      = 2'b00;
            ALUSrcA    = 2'b10;
            Branch     = 1'b0;
            ImmSrc     = 3'b000;
            ALUSrcB    = 2'b01;
        end

        S4_MemWB: begin
            ResultSrc  = 2'b01;
            RegWrite   = 1'b1;
            MemWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            ALUOp      = 2'b00;
            ALUSrcA    = 2'b10;
            Branch     = 1'b0;
            ImmSrc     = 3'b000;
            ALUSrcB    = 2'b01;
        end

        S5_MemWrite: begin
            ResultSrc  = 2'b00;
            AdrSrc     = 1'b1;
            MemWrite   = 1'b1;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            PCUpdate   = 1'b0;
            ALUOp      = 2'b00;
            ALUSrcA    = 2'b00;
            Branch     = 1'b0;
            ImmSrc     = 3'b001;
            ALUSrcB    = 2'b00;
        end

        S6_ExecuteR: begin
            ALUSrcA    = 2'b10;
            ALUSrcB    = 2'b00;
            ALUOp      = 2'b10;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            Branch     = 1'b0;
            ImmSrc     = 3'b000;
            ResultSrc  = 2'b00;
        end

        S7_ALUWB: begin
            ResultSrc  = 2'b00;
            RegWrite   = 1'b1;
            MemWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            ALUOp      = 2'b00;
            ALUSrcA    = 2'b00;
            Branch     = 1'b0;
            ImmSrc     = 3'b000;
            ALUSrcB    = 2'b00;
        end

        S8_ExecuteI: begin
            ALUSrcA    = 2'b10;
            ALUSrcB    = 2'b01;
            ALUOp      = 2'b10;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            Branch     = 1'b0;
            ImmSrc     = 3'b000;
            ResultSrc  = 2'b00;
        end

        S9_JAL: begin
            ALUSrcA    = 2'b01;
            ALUSrcB    = 2'b10;
            ALUOp      = 2'b00;
            ResultSrc  = 2'b00;
            PCUpdate   = 1'b1;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            Branch     = 1'b0;
            ImmSrc     = 3'b011;
        end

        S10_BRANCH: begin
            ALUSrcA    = 2'b10;
            ALUSrcB    = 2'b00;
            ALUOp      = 2'b01;
            Branch     = 1'b1;
            ResultSrc  = 2'b00;
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            ImmSrc     = 3'b010;
        end

        default: begin
            MemWrite   = 1'b0;
            RegWrite   = 1'b0;
            IRWrite    = 1'b0;
            AdrSrc     = 1'b0;
            PCUpdate   = 1'b0;
            ResultSrc  = 2'b00;
            ALUSrcA    = 2'b00;
            ALUSrcB    = 2'b00;
            ImmSrc     = 3'b000;
            Branch     = 1'b0;
            ALUOp      = 2'b00;
        end
    endcase
end


always @(*) begin
    case (present_state)
        S0_fetch: 
            next_state = S1_decode;

        S1_decode: begin
            case (op)
                7'b0000011, 7'b0100011, 7'b1100111: next_state = S2_MemAdr;    // lw or sw or jalr
                7'b0110011: next_state = S6_ExecuteR;  // R-type
                7'b1100011: next_state = S10_BRANCH;      // beq
                7'b0010011: next_state = S8_ExecuteI;  // addi
                7'b1101111: next_state = S9_JAL;       // jal
                default:    next_state = S1_decode;    // Stay in decode for undefined opcodes
            endcase
        end

        S2_MemAdr: begin
            case (op)
                7'b0000011: next_state = S3_MemRead;   // lw
                7'b0100011: next_state = S5_MemWrite;  // sw
                7'b1100111: next_state = S9_JAL;       // jalr
                default:    next_state = S1_decode;    // Stay in decode for undefined opcodes
            endcase
        end

        S3_MemRead:    next_state = S4_MemWB;
        S4_MemWB:      next_state = S0_fetch;
        S5_MemWrite:   next_state = S0_fetch;
        S6_ExecuteR:   next_state = S7_ALUWB;
        S7_ALUWB:      next_state = S0_fetch;
        S8_ExecuteI:   next_state = S7_ALUWB;
        S9_JAL:        next_state = S7_ALUWB;
        S10_BRANCH:       next_state = S0_fetch;

        default:       next_state = S0_fetch;   // Default to fetch state for safety
    endcase
end

always @(posedge clk) begin
    if (reset) begin
        present_state <= S0_fetch;  // Reset to initial state
    end else begin
        present_state <= next_state;
    end
end

endmodule
