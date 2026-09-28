`timescale 1ns / 1ps
// Report pp. 3-4, 23: A - B = A + (~B) + 1; C4 = no borrow.
module adder_subtractor_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       sub,
    output wire [3:0] sum,
    output wire       c3,
    output wire       c4
);
    wire [3:0] b_x;
    wire [4:0] c;

    assign c[0] = sub;
    xor xb0 (b_x[0], b[0], sub);
    xor xb1 (b_x[1], b[1], sub);
    xor xb2 (b_x[2], b[2], sub);
    xor xb3 (b_x[3], b[3], sub);

    full_adder fa0 (.a(a[0]), .b(b_x[0]), .cin(c[0]), .sum(sum[0]), .cout(c[1]));
    full_adder fa1 (.a(a[1]), .b(b_x[1]), .cin(c[1]), .sum(sum[1]), .cout(c[2]));
    full_adder fa2 (.a(a[2]), .b(b_x[2]), .cin(c[2]), .sum(sum[2]), .cout(c[3]));
    full_adder fa3 (.a(a[3]), .b(b_x[3]), .cin(c[3]), .sum(sum[3]), .cout(c[4]));

    assign c3 = c[3];
    assign c4 = c[4];
endmodule
