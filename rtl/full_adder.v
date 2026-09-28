`timescale 1ns / 1ps
// Report pp. 3-4, 23-24: 2 XOR, 2 AND, 1 OR.
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire p, g, pc;

    xor x1 (p, a, b);
    xor x2 (sum, p, cin);
    and a1 (g, a, b);
    and a2 (pc, p, cin);
    or  o1 (cout, g, pc);
endmodule
