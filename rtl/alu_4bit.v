`timescale 1ns / 1ps
// Report pp. 11-15, 21-22: integration of the nine design modules.
module alu_4bit (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [3:0] opcode,
    output wire [7:0] result,
    output wire       carry,
    output wire       zero,
    output wire       overflow,
    output wire       negative,
    output wire       div_by_zero,
    output wire       busy,
    output wire       done
);
    wire sub, arith, is_shl, is_shr, is_div, is_muldiv;
    wire [3:0] md_add_a, md_add_b;
    wire       md_add_sub;
    wire [3:0] add_in_a, add_in_b;
    wire       add_sub;
    wire [3:0] sum;
    wire       c3, c4;
    wire [3:0] and_out, or_out, xor_out, not_out;
    wire [3:0] shl, shr;
    wire       shl_out_bit, shr_out_bit;
    wire [3:0] md_hi, md_lo;
    wire       md_dbz;

    control_unit u_ctrl (
        .opcode(opcode), .sub(sub), .arith(arith),
        .is_shl(is_shl), .is_shr(is_shr),
        .is_div(is_div), .is_muldiv(is_muldiv)
    );

    // One physical four-bit adder: MUL/DIV own its inputs while busy.
    assign add_in_a = busy ? md_add_a   : a;
    assign add_in_b = busy ? md_add_b   : b;
    assign add_sub  = busy ? md_add_sub : sub;

    adder_subtractor_4bit u_addsub (
        .a(add_in_a), .b(add_in_b), .sub(add_sub),
        .sum(sum), .c3(c3), .c4(c4)
    );
    logic_unit_4bit u_logic (
        .a(a), .b(b), .and_out(and_out), .or_out(or_out),
        .xor_out(xor_out), .not_out(not_out)
    );
    shifter_4bit u_shift (
        .a(a), .shl(shl), .shr(shr),
        .shl_out_bit(shl_out_bit), .shr_out_bit(shr_out_bit)
    );
    muldiv_unit u_muldiv (
        .clk(clk), .rst(rst), .start(start & is_muldiv), .is_div(is_div),
        .a(a), .b(b),
        .add_a(md_add_a), .add_b(md_add_b), .add_sub(md_add_sub),
        .add_sum(sum), .add_c4(c4), .hi(md_hi), .lo(md_lo),
        .busy(busy), .done(done), .div_by_zero(md_dbz)
    );

    assign div_by_zero = is_div & md_dbz;

    result_mux u_mux (
        .opcode(opcode), .sum(sum),
        .and_out(and_out), .or_out(or_out),
        .xor_out(xor_out), .not_out(not_out),
        .shl(shl), .shr(shr), .md_hi(md_hi), .md_lo(md_lo),
        .result(result)
    );
    flag_unit u_flags (
        .result(result), .arith(arith), .is_shl(is_shl), .is_shr(is_shr),
        .is_muldiv(is_muldiv), .c3(c3), .c4(c4),
        .shl_out_bit(shl_out_bit), .shr_out_bit(shr_out_bit),
        .carry(carry), .zero(zero), .overflow(overflow), .negative(negative)
    );
endmodule
