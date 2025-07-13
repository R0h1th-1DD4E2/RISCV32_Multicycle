module Instr_Data_mem(
    input        clk,
    input        MemWrite,     // write enable for data memory
    input [31:0] A,            // address
    input [31:0] WD,           // write data
    output [31:0] RD           // read data
);
    parameter MEM_SIZE = 64;

    // unified memory for both instructions and data
    reg [31:0] ram [0:MEM_SIZE-1];

    // data read 
    assign RD = ram[A[31:2] % MEM_SIZE]; // % MEM_SIZE to avoid address above 64

    // data write (synchronous)
    always @(posedge clk) begin
        if (MemWrite)
            ram[A[31:2] % MEM_SIZE] <= WD;
    end

    // initialize instruction memory from file
    initial 
    begin
         $readmemh("program_asm.mem", ram);
    end

endmodule