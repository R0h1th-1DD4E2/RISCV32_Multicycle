`timescale 1ns / 1ps

module tb_new;

  // Clock and Reset
  logic clk, reset;

  // DUT I/O
  logic [31:0] Mem_RdData;
  logic [31:0] Result, PC;
  logic        MemWrite;
  logic [31:0] Mem_WrAddr, Mem_WrData;

  // Simple instruction memory model
  logic [31:0] imem [0:255];

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
  );

  // Clock generation
  always #5 clk = ~clk;

  // Fetch logic (read-only)
  always_comb begin
    Mem_RdData = imem[PC[9:2]]; // Word-aligned 32-bit instructions
  end

  // Initial block
  initial begin
    // Load instructions from hex file
    $readmemh("myTest.hex", imem);

    // Reset sequence
    clk = 0;
    reset = 1;
    #20;
    reset = 0;

    // Run simulation for some time
    #1000;

    $display("Final PC = %0h, Result = %0h", PC, Result);
    $finish;
  end

endmodule
