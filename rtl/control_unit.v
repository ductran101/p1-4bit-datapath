`timescale 1ns / 1ps
// Gate diagrams p. 2; report pp. 16, 22-23.
// Four inverters and six AND gates decode the source opcode map.
module control_unit (
    input  wire [3:0] opcode,
    output wire       sub,
    output wire       arith,
    output wire       is_shl,
    output wire       is_shr,
    output wire       is_div,
    output wire       is_muldiv
);
    wire [3:0] op_n;

    not n0 (op_n[0], opcode[0]);
    not n1 (op_n[1], opcode[1]);
    not n2 (op_n[2], opcode[2]);
    not n3 (op_n[3], opcode[3]);

    and d_sub (sub,       op_n[3],   op_n[2],   op_n[1],   opcode[0]);
    and d_add (arith,     op_n[3],   op_n[2],   op_n[1]);
    and d_shl (is_shl,    op_n[3],   opcode[2], opcode[1], op_n[0]);
    and d_shr (is_shr,    op_n[3],   opcode[2], opcode[1], opcode[0]);
    and d_div (is_div,    opcode[3], op_n[2],   op_n[1],   opcode[0]);
    and d_md  (is_muldiv, opcode[3], op_n[2],   op_n[1]);
endmodule
