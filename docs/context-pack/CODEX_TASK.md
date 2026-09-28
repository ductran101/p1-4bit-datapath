# Codex Task — FPTU VLSI OJT P1

You are implementing **P1 — Digital Logic Foundation & Scripting** for an FPTU VLSI OJT project.

## 1. Read the sources first
Inspect all files in `sources/` before changing or generating code.

The OJT execution plan defines the P1 goal as:
- **Build a 4-bit CPU Datapath from gate-level. Python & TCL scripting.**
- P1 spans Week 1–2, Day 1–Day 10.
- P1 pass criterion: **Gate-level design compiles and simulates correctly**.
- Assessment: **GitHub repo reviewed by mentor**.

The two PDF documents provide a detailed implementation specification for a **4-bit ALU with shift-based multiply and divide**.

## 2. Scope rule — important
Implement the detailed ALU specification exactly as supported by the PDFs.

Do **not** invent a full CPU architecture (PC, instruction memory, register file, etc.) unless a source document explicitly requires it or the user later provides a specification.

Treat the ALU as the currently specified datapath component of P1.

## 3. Required ALU behavior
Inputs:
- `clk`
- `rst` — asynchronous, active high
- `start` — one-clock pulse to begin MUL/DIV
- `a[3:0]`
- `b[3:0]`
- `opcode[3:0]`

Outputs:
- `result[7:0]`
- `carry`
- `zero`
- `overflow`
- `negative`
- `div_by_zero`
- `busy`
- `done`

Opcode map:
- `0000` ADD
- `0001` SUB
- `0010` AND
- `0011` OR
- `0100` XOR
- `0101` NOT A
- `0110` SHL
- `0111` SHR
- `1000` MUL
- `1001` DIV
- `1010`–`1111` unused -> result 0

Single-cycle operations: ADD, SUB, AND, OR, XOR, NOT, SHL, SHR.

Multi-cycle operations: MUL and DIV.

## 4. Required Verilog module hierarchy
Create/maintain the following nine design files and one testbench:

1. `full_adder.v`
2. `adder_subtractor_4bit.v`
3. `logic_unit_4bit.v`
4. `shifter_4bit.v`
5. `control_unit.v`
6. `muldiv_unit.v`
7. `result_mux.v`
8. `flag_unit.v`
9. `alu_4bit.v` — top level
10. `alu_4bit_tb.v` — simulation only

Hierarchy:

```text
alu_4bit_tb.v
    -> alu_4bit.v
       -> control_unit.v
       -> adder_subtractor_4bit.v
          -> full_adder.v x4
       -> logic_unit_4bit.v
       -> shifter_4bit.v
       -> muldiv_unit.v
       -> result_mux.v
       -> flag_unit.v
```

## 5. Gate-level / structural requirements
Preserve the source architecture.

### Full adder
Implement from basic gates:
- `p = a XOR b`
- `g = a AND b`
- `sum = p XOR cin`
- `cout = g OR (p AND cin)`

This is 2 XOR + 2 AND + 1 OR.

### 4-bit add/sub
Use four chained `full_adder` instances as a ripple-carry adder.
- SUB uses `A - B = A + (~B) + 1`.
- XOR each B bit with `sub`.
- `C0 = sub`.
- Expose `c3` (carry into MSB) and `c4` (carry out) for flags.

Do not replace this structural adder with a single behavioral `a + b` implementation.

### Logic
Compute AND, OR, XOR, NOT in parallel.

### Shift
Logical one-bit shifts:
- SHL: `{a[2:0], 1'b0}`, shifted-out carry bit = `a[3]`.
- SHR: `{1'b0, a[3:1]}`, shifted-out carry bit = `a[0]`.

### Control
Decode opcode into at least:
- `sub`
- `arith`
- `is_shl`
- `is_shr`
- `is_div`
- `is_muldiv`

### Result mux
Select the correct result by opcode.
- 4-bit results are zero-extended to 8 bits.
- MUL result = `{product_high, product_low}`.
- DIV result = `{remainder, quotient}`.

## 6. MUL/DIV hardware-sharing requirement
MUL/DIV must reuse the ALU's one shared 4-bit adder/subtractor while `busy = 1`.

`muldiv_unit` contains state/registers and drives the shared adder through signals such as:
- `add_a`
- `add_b`
- `add_sub`

It reads back:
- `add_sum`
- `add_c4`

### MUL — shift-and-add
Registers:
- `acc`
- `q`
- `m`
- carry/state/counter as needed

On start:
- `acc = 0`
- `q = b` (multiplier)
- `m = a` (multiplicand)

Repeat 4 steps:
- if `q[0] == 1`, add `m` to `acc` using the shared adder
- shift `{carry, acc, q}` right by one

After 4 steps:
- product = `{acc, q}`

### DIV — restoring shift-and-subtract
On start:
- `acc = 0`
- `q = a` (dividend)
- `m = b` (divisor)

Repeat 4 steps:
- shift `{acc, q}` left by one
- try `acc - m` using shared adder
- if subtraction fits/no borrow, keep difference and set quotient bit 1
- otherwise restore/keep accumulator and quotient bit 0

After 4 steps:
- quotient = `q`
- remainder = `acc`

Divide by zero behavior from the source:
- `div_by_zero = 1`
- quotient = `1111`
- remainder = `a`

Protocol:
- pulse `start` for one clock
- `busy` is asserted during the four computation steps
- `done` is asserted after the final step
- source verification treats the operation as 5 clocks from start to done (1 load + 4 work steps)
- result remains held until the next start

## 7. Flags
Implement source-defined behavior:
- `carry`: ADD carry out; SUB uses 1 = no borrow; SHL/SHR uses shifted-out bit; otherwise 0
- `overflow`: ADD/SUB signed overflow = `c3 XOR c4`, only when arithmetic selected
- `zero`: NOR of all eight result bits
- `negative`: `result[3]` for 4-bit operations; 0 for MUL/DIV (unsigned)
- `div_by_zero`: latched/indicated for DIV by zero as specified

## 8. Verification requirement
Create a self-checking testbench matching the report intent.

It should:
1. Print representative examples.
2. Exhaustively verify the single-cycle side over all `a,b` pairs and relevant/unused opcodes.
3. Exhaustively verify MUL and DIV over all 256 `a,b` pairs each.
4. Check MUL product.
5. Check DIV quotient and remainder.
6. Check divide-by-zero behavior.
7. Check MUL/DIV latency from `start` to `done`.
8. Report a final PASS/FAIL summary.

The source report's reference result is:
- 3,584 single-cycle checks
- 512 MUL/DIV checks
- total 4,096 cases
- 0 errors

Aim to reproduce that behavior.

## 9. Vivado workflow
Keep the design compatible with Vivado RTL projects.
- 9 Verilog files -> Design Sources
- `alu_4bit_tb.v` -> Simulation Sources
- design top = `alu_4bit`
- simulation top = `alu_4bit_tb`
- Run Behavioral Simulation -> Run All
- test duration is approximately 35 us in the report

Also keep the code synthesizable except the testbench.

## 10. Python & TCL scripting
The execution-plan spreadsheet explicitly requires **Python & TCL scripting**, but the supplied ALU PDFs do not specify exact script deliverables.

Therefore:
- Do not claim a source requirement that does not exist.
- Add clearly labeled auxiliary scripts only if useful.
- Recommended minimal interpretation:
  - a TCL script that creates/configures a Vivado project, adds sources, sets tops, and launches simulation or synthesis;
  - a Python script that parses simulation output and returns pass/fail or summarizes verification results.
- Mark these as **implementation choices / inferred support tooling**, not as exact PDF requirements.

## 11. Repository/documentation expectation
Prepare the result as a mentor-reviewable GitHub repository:
- clean folder structure
- README with architecture, opcode table, ports, flags, simulation instructions
- source files separated from testbench/scripts/docs
- verification result documented
- no generated Vivado cache/build files committed unless intentionally needed

## 12. Quality rules
- Keep module names and behavior aligned with the sources.
- Prefer structural/gate-level implementation where the source explicitly shows gates/instances.
- Do not simplify away the shared-adder architecture for MUL/DIV.
- Do not silently broaden the project into a complete CPU.
- If a requirement is ambiguous, document it in `OPEN_QUESTIONS.md` rather than guessing.
- After implementation, compile and simulate; fix all errors before declaring completion.
