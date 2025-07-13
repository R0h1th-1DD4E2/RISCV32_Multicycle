`timescale 1ns / 1ps

module Top(
    input clk,reset_n,
    output [31:0] PC_count, Result_out
    );
    
    wire [31:0] Mem_WrData, Mem_RdData, Mem_WrAddr;
    wire MemWrite;
    CPU_rv32i core(
                .clk(clk), .reset(~reset_n),
                .Mem_RdData(Mem_RdData),
                .Result(Result_out),
                .PC(PC_count),
                .MemWrite(MemWrite),
                .Mem_WrAddr(Mem_WrAddr), 
                .Mem_WrData(Mem_WrData)
    
);
    
    Instr_Data_mem memory(
                .clk(clk),
                .MemWrite(MemWrite),     // write enable for data memory
                .A(Mem_WrAddr),            // address
                .WD(Mem_WrData),           // write data
                .RD(Mem_RdData)           // read data
    );
    
endmodule
