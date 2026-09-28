`timescale 1ns / 1ps
// Report pp. 4, 24: logical one-bit shifts are pure wiring.
module shifter_4bit (
    input  wire [3:0] a,
    output wire [3:0] shl,
    output wire [3:0] shr,
    output wire       shl_out_bit,
    output wire       shr_out_bit
);
    assign shl         = {a[2:0], 1'b0};
    assign shr         = {1'b0, a[3:1]};
    assign shl_out_bit = a[3];
    assign shr_out_bit = a[0];
endmodule
