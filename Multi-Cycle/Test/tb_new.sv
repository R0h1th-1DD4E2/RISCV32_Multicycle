`timescale 1ns / 1ps

module tb_new;
  // Clock and Reset
  logic clk, reset;
  
  // DUT I/O
  logic [31:0] Mem_RdData;
  logic [31:0] Result, PC;
  logic        MemWrite;
  logic [31:0] Mem_WrAddr, Mem_WrData;
  
  // Debug signals - only declared when DEBUG is defined
  `ifdef DEBUG
    logic [31:0] debug_InstrReg;
    logic [31:0] debug_RD1, debug_RD2;
    logic [31:0] debug_ImmExt;
    logic [31:0] debug_SrcA, debug_SrcB;
    logic [31:0] debug_ALUResult, debug_ALUOut;
    logic [31:0] debug_A, debug_WriteData;
    logic [31:0] debug_OldPC;
    logic [1:0]  debug_ALUOp;
    logic        debug_Branch;
    logic        debug_PCWrite_condition;
    logic        debug_Zero, debug_Negative, debug_Carry, debug_Overflow;
    logic [2:0]  debug_ALUControl;
    logic [1:0]  debug_ResultSrc, debug_ALUSrcA, debug_ALUSrcB;
  `endif
  
  // Simple instruction memory model
  logic [31:0] imem [0:8191];
  
  // Instantiate DUT
  CPU_rv32i dut (
    .clk(clk),
    .reset(reset),
    .Mem_RdData(Mem_RdData),
    .Result(Result),
    .PC(PC),
    .MemWrite(MemWrite),
    .Mem_WrAddr(Mem_WrAddr),
    .Mem_WrData(Mem_WrData)
    
    // DEBUG connections
    `ifdef DEBUG
        ,.debug_InstrReg(debug_InstrReg),
        .debug_RD1(debug_RD1),
        .debug_RD2(debug_RD2),
        .debug_ImmExt(debug_ImmExt),
        .debug_SrcA(debug_SrcA),
        .debug_SrcB(debug_SrcB),
        .debug_ALUResult(debug_ALUResult),
        .debug_ALUOut(debug_ALUOut),
        .debug_A(debug_A),
        .debug_WriteData(debug_WriteData),
        .debug_OldPC(debug_OldPC),
        .debug_ALUOp(debug_ALUOp),
        .debug_Branch(debug_Branch),
        .debug_PCWrite_condition(debug_PCWrite_condition),
        .debug_Zero(debug_Zero),
        .debug_Negative(debug_Negative),
        .debug_Carry(debug_Carry),
        .debug_Overflow(debug_Overflow),
        .debug_ALUControl(debug_ALUControl),
        .debug_ResultSrc(debug_ResultSrc),
        .debug_ALUSrcA(debug_ALUSrcA),
        .debug_ALUSrcB(debug_ALUSrcB)
    `endif
  );
  
  // Clock generation
  always #5 clk = ~clk;
  
  // Fetch logic (read-only)
  always_comb begin
    Mem_RdData = imem[Mem_WrAddr[9:2]]; // Word-aligned 32-bit instructions
  end
  
    always @(posedge clk) begin
        if (MemWrite)
            imem[Mem_WrAddr[9:2]] <= Mem_WrData;  // Word-aligned addressing
    end
  
  // Debug monitoring - only when DEBUG is defined
  `ifdef DEBUG
    // Monitor key debug signals
    always @(posedge clk) begin
      if (!reset) begin
        $display("Time: %0t | PC: %08h | Instr: %08h | ALUResult: %08h | Zero: %b", 
                 $time, PC, debug_InstrReg, debug_ALUResult, debug_Zero);
        
        // Display register file reads
        if (debug_RD1 !== 32'hxxxxxxxx || debug_RD2 !== 32'hxxxxxxxx) begin
          $display("  RegFile - RD1: %08h, RD2: %08h", debug_RD1, debug_RD2);
        end
        
        // Display ALU operation details
        if (debug_SrcA !== 32'hxxxxxxxx && debug_SrcB !== 32'hxxxxxxxx) begin
          $display("  ALU - SrcA: %08h, SrcB: %08h, Control: %b, Result: %08h", 
                   debug_SrcA, debug_SrcB, debug_ALUControl, debug_ALUResult);
        end
        
        // Display branch conditions
        if (debug_Branch) begin
          $display("  Branch - Condition: %b, PCWrite: %b", 
                   debug_PCWrite_condition, debug_PCWrite_condition);
        end
      end
    end
    
    // Task to display current CPU state
    task display_cpu_state;
      begin
        $display("\n=== CPU State at Time %0t ===", $time);
        $display("PC: %08h | OldPC: %08h", PC, debug_OldPC);
        $display("Instruction: %08h", debug_InstrReg);
        $display("RegFile RD1: %08h | RD2: %08h", debug_RD1, debug_RD2);
        $display("Immediate: %08h", debug_ImmExt);
        $display("ALU SrcA: %08h | SrcB: %08h", debug_SrcA, debug_SrcB);
        $display("ALU Result: %08h | ALU Out: %08h", debug_ALUResult, debug_ALUOut);
        $display("Flags - Z:%b N:%b C:%b V:%b", debug_Zero, debug_Negative, debug_Carry, debug_Overflow);
        $display("Control - ALUOp:%b Branch:%b", debug_ALUOp, debug_Branch);
        $display("Mux Controls - ResultSrc:%b ALUSrcA:%b ALUSrcB:%b", 
                 debug_ResultSrc, debug_ALUSrcA, debug_ALUSrcB);
        $display("===============================\n");
      end
    endtask
    
    // Call display_cpu_state at specific intervals or conditions
    always @(posedge clk) begin
      if (!reset && PC == 32'h00000010) begin // Example: display state at PC = 0x10
        display_cpu_state();
      end
    end
  `endif
  
  // Initial block
  initial begin
    // Load instructions from hex file
    $readmemh("program_asm.mem", imem);
    
    // Reset sequence
    clk = 0;
    reset = 1;
    #20;
    reset = 0;
    
    `ifdef DEBUG
      $display("DEBUG mode enabled - detailed monitoring active");
      // Display first few instructions loaded
      $display("First 4 instructions loaded:");
      for (int i = 0; i < 4; i++) begin
        $display("  imem[%0d] = %08h", i, imem[i]);
      end
    `else
      $display("Release mode - basic monitoring only");
    `endif
    
    // Run simulation for some time
    #1000;
    
    // Final status
    $display("\n=== Final Results ===");
    $display("Final PC = %08h, Result = %08h", PC, Result);
    
    `ifdef DEBUG
      display_cpu_state();
      $display("Memory Write Address: %08h", Mem_WrAddr);
      $display("Memory Write Data: %08h", Mem_WrData);
      $display("Memory Write Enable: %b", MemWrite);
    `endif
    
    #3800;
    
    // Write memory contents back to file
    $writememh("output_memory.hex", imem);
    
    `ifdef DEBUG
        display_cpu_state();
        $display("Memory contents written to output_memory.hex");
    `endif
    $finish;
  end
  
  // Optional: Dump waveforms when in debug mode
  `ifdef DEBUG
    initial begin
      $dumpfile("cpu_debug.vcd");
      $dumpvars(0, tb_new);
    end
  `endif
  
endmodule
