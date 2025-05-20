module Instr_Data_mem(
    input        clk,
    input        MemWrite,     // write enable for data memory
    input [31:0] A,            // address
    input [31:0] WD,           // write data
    output [31:0] Instr,       // fetched instruction
    output [31:0] RD           // read data
);
    parameter MEM_SIZE = 64;

    // unified memory for both instructions and data
    reg [31:0] ram [0:MEM_SIZE-1];

    // instruction fetch (combinational)
    assign Instr = ram[A[31:2]];

    // data read (combinational)
    assign RD = ram[A[31:2] % MEM_SIZE];

    // data write (synchronous)
    always @(posedge clk) begin
        if (MemWrite)
            ram[A[31:2] % MEM_SIZE] <= WD;
    end

    // initialize instruction memory from file
    initial 
    begin
         $readmemh("rv32i_book.hex", ram);
    end

endmodule
