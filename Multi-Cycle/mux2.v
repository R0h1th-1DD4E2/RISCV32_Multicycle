module mux2(
    input      [31:0] d0, d1,
    input              sel,
    output [31:0] op
);

assign op=sel?d1:d0;

endmodule