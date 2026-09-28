`timescale 1ns / 1ps
// Report pp. 4, 24: all four bitwise operations work in parallel.
module logic_unit_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] and_out,
    output wire [3:0] or_out,
    output wire [3:0] xor_out,
    output wire [3:0] not_out
);
    assign and_out = a & b;
    assign or_out  = a | b;
    assign xor_out = a ^ b;
    assign not_out = ~a;
endmodule
