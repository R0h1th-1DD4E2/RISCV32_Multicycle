module test_controller;
  // DUT signals
  logic [6:0] op;
  logic Zero;
  logic MemWrite, RegWrite, IRWrite, AdrSrc, PCUpdate,PCWrite;
  logic [1:0] ResultSrc, ALUSrcA, ALUSrcB, ImmSrc, Branch, ALUOp;
  logic clk, reset;
  
  // Signal to track if test passed
  logic test_passed;
  
  // State sequence tracking
  int state_sequence[$];
  string instruction_type;
  
  // Define state enum for readability
  typedef enum logic [3:0] {
    S0_FETCH  = 4'b0000,
    S1_DECODE = 4'b0001,
    S2_MEMADR = 4'b0010,
    S3_MEMREAD = 4'b0011,
    S4_MEMWB = 4'b0100,
    S5_MEMWRITE = 4'b0101,
    S6_EXECUTER = 4'b0110,
    S7_ALUWB = 4'b0111,
    S8_EXECUTEI = 4'b1000,
    S9_JAL = 4'b1001,
    S10_BEQ = 4'b1010
  } state_t;
  
  // Reference state sequences for each instruction type
  int LW_seq[$] = {S0_FETCH, S1_DECODE, S2_MEMADR, S3_MEMREAD, S4_MEMWB};
  int SW_seq[$] = {S0_FETCH, S1_DECODE, S2_MEMADR, S5_MEMWRITE};
  int RTYPE_seq[$] = {S0_FETCH, S1_DECODE, S6_EXECUTER, S7_ALUWB};
  int BEQ_seq[$] = {S0_FETCH, S1_DECODE, S10_BEQ};
  int ADDI_seq[$] = {S0_FETCH, S1_DECODE, S8_EXECUTEI, S7_ALUWB};
  int JAL_seq[$] = {S0_FETCH, S1_DECODE, S9_JAL, S7_ALUWB};
  
  // Reference outputs for each state
  // Using associative arrays with state as index
  logic MemWrite_exp[state_t];
  logic RegWrite_exp[state_t];
  logic IRWrite_exp[state_t];
  logic AdrSrc_exp[state_t];
  logic PCUpdate_exp[state_t];
  logic [1:0] ResultSrc_exp[state_t];
  logic [1:0] ALUSrcA_exp[state_t];
  logic [1:0] ALUSrcB_exp[state_t];
  logic [1:0] ImmSrc_exp[state_t];
  logic [1:0] Branch_exp[state_t];
  logic [1:0] ALUOp_exp[state_t];
  
  // Instantiate the DUT
  Controller dut (
    .op(op),
    .Zero(Zero),
    .MemWrite(MemWrite),
    .RegWrite(RegWrite),
    .IRWrite(IRWrite),
    .AdrSrc(AdrSrc),
    .PCUpdate(PCUpdate),
    .ResultSrc(ResultSrc),
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .ImmSrc(ImmSrc),
    .Branch(Branch),
    .ALUOp(ALUOp),
    .clk(clk),
    .reset(reset),
    .PCWrite(PCWrite)
  );
  
  // Clock generation
  always begin
    clk = 0; #5;
    clk = 1; #5;
  end
  
  // Generate stimulus and check responses
  initial begin
    // Initialize expected output values for each state
    initialize_expected_values();
    
    // Run test for each instruction type
    test_passed = 1'b1;
    
    // Reset the controller
    reset = 1'b1;
    @(posedge clk);
    reset = 1'b0;
    
    // Test LW instruction
    $display("\n----- Testing LW instruction -----");
    test_instruction(7'b0000011, "LW", LW_seq);
    
    // Test SW instruction
    $display("\n----- Testing SW instruction -----");
    test_instruction(7'b0100011, "SW", SW_seq);
    
    // Test R-type instruction
    $display("\n----- Testing R-type instruction -----");
    test_instruction(7'b0110011, "R-TYPE", RTYPE_seq);
    
    // Test BEQ instruction
    $display("\n----- Testing BEQ instruction -----");
    Zero = 1'b0; // First test with no branch taken
    test_instruction(7'b1100011, "BEQ (Zero=0)", BEQ_seq);
    
    // Test BEQ with branch taken
    $display("\n----- Testing BEQ instruction with branch taken -----");
    Zero = 1'b1; // Test with branch taken
    test_instruction(7'b1100011, "BEQ (Zero=1)", BEQ_seq);
    
    // Test ADDI instruction
    $display("\n----- Testing ADDI instruction -----");
    test_instruction(7'b0010011, "ADDI", ADDI_seq);
    
    // Test JAL instruction
    $display("\n----- Testing JAL instruction -----");
    test_instruction(7'b1101111, "JAL", JAL_seq);
    
    // Final test result
    if (test_passed)
      $display("\n*** All tests PASSED! ***");
    else
      $display("\n*** Some tests FAILED! ***");
    
    $finish;
  end
  
  // Task to initialize expected values for each state
  task initialize_expected_values();
    // S0_FETCH
    MemWrite_exp[S0_FETCH] = 1'b0;
    RegWrite_exp[S0_FETCH] = 1'b0;
    IRWrite_exp[S0_FETCH] = 1'b1;
    AdrSrc_exp[S0_FETCH] = 1'b0;
    PCUpdate_exp[S0_FETCH] = 1'b1;
    ResultSrc_exp[S0_FETCH] = 2'b10;
    ALUSrcA_exp[S0_FETCH] = 2'b00;
    ALUSrcB_exp[S0_FETCH] = 2'b10;
    ALUOp_exp[S0_FETCH] = 2'b00;
    Branch_exp[S0_FETCH] = 2'b00; // Default value
    ImmSrc_exp[S0_FETCH] = 2'b00; // Default value
    
    // S1_DECODE
    MemWrite_exp[S1_DECODE] = 1'b0;
    RegWrite_exp[S1_DECODE] = 1'b0;
    IRWrite_exp[S1_DECODE] = 1'b0;
    AdrSrc_exp[S1_DECODE] = 1'b0;
    PCUpdate_exp[S1_DECODE] = 1'b0;
    ResultSrc_exp[S1_DECODE] = 2'b00; // Default value
    ALUSrcA_exp[S1_DECODE] = 2'b01;   // From image
    ALUSrcB_exp[S1_DECODE] = 2'b01;   // From image
    ALUOp_exp[S1_DECODE] = 2'b00;     // From image
    Branch_exp[S1_DECODE] = 2'b00;    // Default value
    ImmSrc_exp[S1_DECODE] = 2'b00;    // Default value
    
    // S2_MEMADR
    MemWrite_exp[S2_MEMADR] = 1'b0;
    RegWrite_exp[S2_MEMADR] = 1'b0;
    IRWrite_exp[S2_MEMADR] = 1'b0;
    AdrSrc_exp[S2_MEMADR] = 1'b0;
    PCUpdate_exp[S2_MEMADR] = 1'b0;
    ResultSrc_exp[S2_MEMADR] = 2'b00; // Default value
    ALUSrcA_exp[S2_MEMADR] = 2'b10;   // From image
    ALUSrcB_exp[S2_MEMADR] = 2'b01;   // From image
    ALUOp_exp[S2_MEMADR] = 2'b00;     // From image
    Branch_exp[S2_MEMADR] = 2'b00;    // Default value
    ImmSrc_exp[S2_MEMADR] = 2'b00;    // From code
    
    // S3_MEMREAD
    MemWrite_exp[S3_MEMREAD] = 1'b0;
    RegWrite_exp[S3_MEMREAD] = 1'b0;
    IRWrite_exp[S3_MEMREAD] = 1'b0;
    AdrSrc_exp[S3_MEMREAD] = 1'b1;
    PCUpdate_exp[S3_MEMREAD] = 1'b0;
    ResultSrc_exp[S3_MEMREAD] = 2'b00; // From image
    ALUSrcA_exp[S3_MEMREAD] = 2'b00;   // Default value
    ALUSrcB_exp[S3_MEMREAD] = 2'b00;   // Default value
    ALUOp_exp[S3_MEMREAD] = 2'b00;     // Default value
    Branch_exp[S3_MEMREAD] = 2'b00;    // Default value
    ImmSrc_exp[S3_MEMREAD] = 2'b00;    // Default value
    
    // S4_MEMWB
    MemWrite_exp[S4_MEMWB] = 1'b0;
    RegWrite_exp[S4_MEMWB] = 1'b1;
    IRWrite_exp[S4_MEMWB] = 1'b0;
    AdrSrc_exp[S4_MEMWB] = 1'b0;
    PCUpdate_exp[S4_MEMWB] = 1'b0;
    ResultSrc_exp[S4_MEMWB] = 2'b01;   // From image
    ALUSrcA_exp[S4_MEMWB] = 2'b00;     // Default value
    ALUSrcB_exp[S4_MEMWB] = 2'b00;     // Default value
    ALUOp_exp[S4_MEMWB] = 2'b00;       // Default value
    Branch_exp[S4_MEMWB] = 2'b00;      // Default value
    ImmSrc_exp[S4_MEMWB] = 2'b00;      // Default value
    
    // S5_MEMWRITE
    MemWrite_exp[S5_MEMWRITE] = 1'b1;
    RegWrite_exp[S5_MEMWRITE] = 1'b0;
    IRWrite_exp[S5_MEMWRITE] = 1'b0;
    AdrSrc_exp[S5_MEMWRITE] = 1'b1;
    PCUpdate_exp[S5_MEMWRITE] = 1'b0;
    ResultSrc_exp[S5_MEMWRITE] = 2'b00; // From image
    ALUSrcA_exp[S5_MEMWRITE] = 2'b00;   // Default value
    ALUSrcB_exp[S5_MEMWRITE] = 2'b00;   // Default value
    ALUOp_exp[S5_MEMWRITE] = 2'b00;     // Default value
    Branch_exp[S5_MEMWRITE] = 2'b00;    // Default value
    ImmSrc_exp[S5_MEMWRITE] = 2'b00;    // Default value
    
    // S6_EXECUTER
    MemWrite_exp[S6_EXECUTER] = 1'b0;
    RegWrite_exp[S6_EXECUTER] = 1'b0;
    IRWrite_exp[S6_EXECUTER] = 1'b0;
    AdrSrc_exp[S6_EXECUTER] = 1'b0;
    PCUpdate_exp[S6_EXECUTER] = 1'b0;
    ResultSrc_exp[S6_EXECUTER] = 2'b00;  // Default value
    ALUSrcA_exp[S6_EXECUTER] = 2'b10;    // From image
    ALUSrcB_exp[S6_EXECUTER] = 2'b00;    // From image
    ALUOp_exp[S6_EXECUTER] = 2'b10;      // From image
    Branch_exp[S6_EXECUTER] = 2'b00;     // Default value
    ImmSrc_exp[S6_EXECUTER] = 2'b00;     // Default value
    
    // S7_ALUWB
    MemWrite_exp[S7_ALUWB] = 1'b0;
    RegWrite_exp[S7_ALUWB] = 1'b1;
    IRWrite_exp[S7_ALUWB] = 1'b0;
    AdrSrc_exp[S7_ALUWB] = 1'b0;
    PCUpdate_exp[S7_ALUWB] = 1'b0;
    ResultSrc_exp[S7_ALUWB] = 2'b00;     // From image
    ALUSrcA_exp[S7_ALUWB] = 2'b00;       // Default value
    ALUSrcB_exp[S7_ALUWB] = 2'b00;       // Default value
    ALUOp_exp[S7_ALUWB] = 2'b00;         // Default value
    Branch_exp[S7_ALUWB] = 2'b00;        // Default value
    ImmSrc_exp[S7_ALUWB] = 2'b00;        // Default value
    
    // S8_EXECUTEI
    MemWrite_exp[S8_EXECUTEI] = 1'b0;
    RegWrite_exp[S8_EXECUTEI] = 1'b0;
    IRWrite_exp[S8_EXECUTEI] = 1'b0;
    AdrSrc_exp[S8_EXECUTEI] = 1'b0;
    PCUpdate_exp[S8_EXECUTEI] = 1'b0;
    ResultSrc_exp[S8_EXECUTEI] = 2'b00;  // Default value
    ALUSrcA_exp[S8_EXECUTEI] = 2'b10;    // From image
    ALUSrcB_exp[S8_EXECUTEI] = 2'b01;    // From image
    ALUOp_exp[S8_EXECUTEI] = 2'b10;      // From image
    Branch_exp[S8_EXECUTEI] = 2'b00;     // Default value
    ImmSrc_exp[S8_EXECUTEI] = 2'b00;     // Default value
    
    // S9_JAL
    MemWrite_exp[S9_JAL] = 1'b0;
    RegWrite_exp[S9_JAL] = 1'b0;
    IRWrite_exp[S9_JAL] = 1'b0;
    AdrSrc_exp[S9_JAL] = 1'b0;
    PCUpdate_exp[S9_JAL] = 1'b1;
    ResultSrc_exp[S9_JAL] = 2'b00;       // From image
    ALUSrcA_exp[S9_JAL] = 2'b01;         // From image
    ALUSrcB_exp[S9_JAL] = 2'b10;         // From image
    ALUOp_exp[S9_JAL] = 2'b00;           // From image
    Branch_exp[S9_JAL] = 2'b00;          // Default value
    ImmSrc_exp[S9_JAL] = 2'b00;          // Default value
    
    // S10_BEQ
    MemWrite_exp[S10_BEQ] = 1'b0;
    RegWrite_exp[S10_BEQ] = 1'b0;
    IRWrite_exp[S10_BEQ] = 1'b0;
    AdrSrc_exp[S10_BEQ] = 1'b0;
    PCUpdate_exp[S10_BEQ] = 1'b0;
    ResultSrc_exp[S10_BEQ] = 2'b00;      // From image
    ALUSrcA_exp[S10_BEQ] = 2'b10;        // From image
    ALUSrcB_exp[S10_BEQ] = 2'b00;        // From image
    ALUOp_exp[S10_BEQ] = 2'b01;          // From image
    Branch_exp[S10_BEQ] = 2'b01;         // From code (assuming 2'b01 for branch=1)
    ImmSrc_exp[S10_BEQ] = 2'b00;         // Default value
  endtask
  
  // Task to test a specific instruction
   // Task to apply an instruction and verify state transitions and outputs
  task test_instruction(input logic [6:0] opcode, input string instr_name, input int expected_seq[$]);
    int i;
    state_sequence = {};

    // Apply opcode
    op = opcode;

    // Wait through all states in sequence
    for (i = 0; i < expected_seq.size(); i++) begin
      @(posedge clk);
      state_sequence.push_back(expected_seq[i]);

      // Check outputs against expected values
      if (MemWrite !== MemWrite_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: MemWrite = %b, expected = %b", instr_name, expected_seq[i], MemWrite, MemWrite_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (RegWrite !== RegWrite_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: RegWrite = %b, expected = %b", instr_name, expected_seq[i], RegWrite, RegWrite_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (IRWrite !== IRWrite_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: IRWrite = %b, expected = %b", instr_name, expected_seq[i], IRWrite, IRWrite_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (AdrSrc !== AdrSrc_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: AdrSrc = %b, expected = %b", instr_name, expected_seq[i], AdrSrc, AdrSrc_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (PCUpdate !== PCUpdate_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: PCUpdate = %b, expected = %b", instr_name, expected_seq[i], PCUpdate, PCUpdate_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (ResultSrc !== ResultSrc_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: ResultSrc = %b, expected = %b", instr_name, expected_seq[i], ResultSrc, ResultSrc_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (ALUSrcA !== ALUSrcA_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: ALUSrcA = %b, expected = %b", instr_name, expected_seq[i], ALUSrcA, ALUSrcA_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (ALUSrcB !== ALUSrcB_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: ALUSrcB = %b, expected = %b", instr_name, expected_seq[i], ALUSrcB, ALUSrcB_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (ALUOp !== ALUOp_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: ALUOp = %b, expected = %b", instr_name, expected_seq[i], ALUOp, ALUOp_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end

      if (Branch !== Branch_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: Branch = %b, expected = %b", instr_name, expected_seq[i], Branch, Branch_exp[expected_seq[i]]);
        test_passed = 1'b0; 
      end

      if (ImmSrc !== ImmSrc_exp[expected_seq[i]]) begin
        $display("ERROR in %s at state %0d: ImmSrc = %b, expected = %b", instr_name, expected_seq[i], ImmSrc, ImmSrc_exp[expected_seq[i]]);
        test_passed = 1'b0;
      end
    end
  endtask

  // Task to verify state sequence
  task verify_state_sequence(int exp_seq[$]);
    string state_names[$];
    string exp_state_names[$];
    
  // Convert actual sequence to state names for display
    foreach (state_sequence[i]) begin
      case(state_sequence[i])
        S0_FETCH: state_names.push_back("S0_FETCH");
        S1_DECODE: state_names.push_back("S1_DECODE");
        S2_MEMADR: state_names.push_back("S2_MEMADR");
        S3_MEMREAD: state_names.push_back("S3_MEMREAD");
        S4_MEMWB: state_names.push_back("S4_MEMWB");
        S5_MEMWRITE: state_names.push_back("S5_MEMWRITE");
        S6_EXECUTER: state_names.push_back("S6_EXECUTER");
        S7_ALUWB: state_names.push_back("S7_ALUWB");
        S8_EXECUTEI: state_names.push_back("S8_EXECUTEI");
        S9_JAL: state_names.push_back("S9_JAL");
        S10_BEQ: state_names.push_back("S10_BEQ");
        default: state_names.push_back("UNKNOWN");
      endcase
    end
    
    // Convert expected sequence to state names for display
    foreach (exp_seq[i]) begin
      case(exp_seq[i])
        S0_FETCH: exp_state_names.push_back("S0_FETCH");
        S1_DECODE: exp_state_names.push_back("S1_DECODE");
        S2_MEMADR: exp_state_names.push_back("S2_MEMADR");
        S3_MEMREAD: exp_state_names.push_back("S3_MEMREAD");
        S4_MEMWB: exp_state_names.push_back("S4_MEMWB");
        S5_MEMWRITE: exp_state_names.push_back("S5_MEMWRITE");
        S6_EXECUTER: exp_state_names.push_back("S6_EXECUTER");
        S7_ALUWB: exp_state_names.push_back("S7_ALUWB");
        S8_EXECUTEI: exp_state_names.push_back("S8_EXECUTEI");
        S9_JAL: exp_state_names.push_back("S9_JAL");
        S10_BEQ: exp_state_names.push_back("S10_BEQ");
        default: exp_state_names.push_back("UNKNOWN");
      endcase
    end
    
    // Check if sequences match
    if (state_sequence.size() != exp_seq.size() + 1) begin
      $display("ERROR: State sequence length mismatch for %s", instruction_type);
      $display("  Expected: %p", exp_state_names);
      $display("  Got:      %p", state_names);
      test_passed = 1'b0;
    end
    else begin
      // Check each state in sequence
      for (int i = 0; i < exp_seq.size(); i++) begin
        if (state_sequence[i] != exp_seq[i]) begin
          $display("ERROR: State sequence mismatch at position %0d for %s", i, instruction_type);
          $display("  Expected: %p", exp_state_names);
          $display("  Got:      %p", state_names);
          test_passed = 1'b0;
          break;
        end
      end
      
      // Check final state is FETCH
      if (state_sequence[exp_seq.size()] != S0_FETCH) begin
        $display("ERROR: Final state should be FETCH for %s", instruction_type);
        $display("  Expected: FETCH");
        $display("  Got:      %0d", state_sequence[exp_seq.size()]);
        test_passed = 1'b0;
      end
    
    
    if (test_passed)
      $display("State sequence for %s instruction passed.", instruction_type);
      end
  endtask
  
  // Monitor state transitions
  always @(posedge clk) begin
    if (!reset) begin 
      case(dut.present_state)
        S0_FETCH: $display("At time %0t: State = S0_FETCH", $time);
        S1_DECODE: $display("At time %0t: State = S1_DECODE", $time);
        S2_MEMADR: $display("At time %0t: State = S2_MEMADR", $time);
        S3_MEMREAD: $display("At time %0t: State = S3_MEMREAD", $time);
        S4_MEMWB: $display("At time %0t: State = S4_MEMWB", $time);
        S5_MEMWRITE: $display("At time %0t: State = S5_MEMWRITE", $time);
        S6_EXECUTER: $display("At time %0t: State = S6_EXECUTER", $time);
        S7_ALUWB: $display("At time %0t: State = S7_ALUWB", $time);
        S8_EXECUTEI: $display("At time %0t: State = S8_EXECUTEI", $time);
        S9_JAL: $display("At time %0t: State = S9_JAL", $time);
        S10_BEQ: $display("At time %0t: State = S10_BEQ", $time);
        default: $display("At time %0t: State = UNKNOWN", $time);
      endcase
    end
  end
  
endmodule
