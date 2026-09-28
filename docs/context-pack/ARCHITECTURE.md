# Architecture Summary

## Top-level datapath described by the PDF

```text
                     opcode[3:0]
                          |
                    +-------------+
                    | control_unit|
                    +------+------+ 
                           |
 a[3:0] -------------------+--------------------+
 b[3:0] -------------------+---------------+    |
                           v               v    v
                 +----------------+   +---------+  +---------+
                 | shared ADD/SUB |   |  LOGIC  |  | SHIFTER |
                 +--------+-------+   +---------+  +---------+
                          ^
                          | borrowed while busy
                    +-----+------+
                    | muldiv_unit|
                    +-----+------+
                          |
              all candidate results
                          v
                    +-----------+
                    | result_mux|
                    +-----+-----+
                          |
                    result[7:0]
                          |
                    +-----------+
                    | flag_unit |
                    +-----------+
```

## Opcodes

| Opcode | Operation | Timing | Result form |
|---|---|---|---|
| 0000 | ADD | single-cycle | `{0000, a+b}` |
| 0001 | SUB | single-cycle | `{0000, a-b}` |
| 0010 | AND | single-cycle | `{0000, a&b}` |
| 0011 | OR | single-cycle | `{0000, a|b}` |
| 0100 | XOR | single-cycle | `{0000, a^b}` |
| 0101 | NOT | single-cycle | `{0000, ~a}` |
| 0110 | SHL | single-cycle | `{0000, a<<1}` |
| 0111 | SHR | single-cycle | `{0000, a>>1}` |
| 1000 | MUL | load + 4 steps | 8-bit product |
| 1001 | DIV | load + 4 steps | `{remainder, quotient}` |
| 1010–1111 | unused | n/a | `00000000` |

## Module responsibilities

### `full_adder.v`
1-bit full adder from primitive gates.

### `adder_subtractor_4bit.v`
Four ripple-connected full adders. Uses XOR on B and `sub` as initial carry for two's-complement subtraction.

### `logic_unit_4bit.v`
Computes bitwise AND, OR, XOR and NOT in parallel.

### `shifter_4bit.v`
Pure wiring for logical left/right shift by one and exposes shifted-out carry bits.

### `control_unit.v`
Decodes opcode into control signals.

### `muldiv_unit.v`
Only clocked submodule. Holds `acc`, `q`, `m`, counter and IDLE/RUN state. Reuses top-level shared adder/subtractor.

### `result_mux.v`
Selects one 8-bit result by opcode.

### `flag_unit.v`
Generates carry, zero, overflow, negative.

### `alu_4bit.v`
Top-level integration. Instantiates submodules and contains the muxing needed to hand the shared adder to `muldiv_unit` while busy.

### `alu_4bit_tb.v`
Simulation-only self-checking testbench.
