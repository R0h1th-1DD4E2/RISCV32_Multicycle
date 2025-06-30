module Register(
    input clk,WE3,
    input [4:0] A1,A2,A3,
    input [31:0] WD3,
    output [31:0] RD1,RD2
);

reg [31:0] reg_arr [0:31];
integer i;
initial 
begin
    for(i=0;i<32;i=i+1)
    reg_arr[i]=0;
end

always@(posedge clk)
begin 
    if(WE3)
    reg_arr[A3]<=WD3;
end

assign RD1 = ( A1 != 0 ) ? reg_arr[A1] : 0;
assign RD2 = ( A2 != 0 ) ? reg_arr[A2] : 0;
endmodule

// Port	Direction	Purpose
// A1	Input	Address of source register 1 (rs1, bits [19:15])
// A2	Input	Address of source register 2 (rs2, bits [24:20])
// A3	Input	Address of destination register (rd, bits [11:7])
// RD1	Output	Data from register at A1
// RD2	Output	Data from register at A2
// WD3	Input	Data to write to register A3
// WE3(Wr_en)	Input	Write enable — write WD3 into A3 on rising clock edge if set
