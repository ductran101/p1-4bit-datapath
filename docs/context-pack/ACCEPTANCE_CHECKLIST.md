# P1 Acceptance Checklist

## Source requirements
- [ ] P1 scope and terminology documented.
- [ ] Any ambiguity between "CPU Datapath" and detailed "ALU" specification is explicitly noted.

## RTL / gate-level implementation
- [ ] `full_adder.v` uses gate-level structure.
- [ ] `adder_subtractor_4bit.v` chains 4 full adders.
- [ ] ADD and SUB both reuse the same adder.
- [ ] Logic operations implemented.
- [ ] SHL/SHR implemented with correct shifted-out bits.
- [ ] Control decoder maps opcodes correctly.
- [ ] MUL/DIV reuse the same shared adder/subtractor.
- [ ] Result mux behavior matches opcode table.
- [ ] Flags match the source definitions.
- [ ] Unused opcodes return zero.

## Multi-cycle behavior
- [ ] MUL uses 4 shift/add work steps.
- [ ] DIV uses 4 shift/subtract work steps.
- [ ] `busy` asserted during operation.
- [ ] `done` asserted at completion.
- [ ] Start-to-done verification expects 5 clocks (load + 4 steps).
- [ ] Divide-by-zero behavior matches source.

## Verification
- [ ] Testbench compiles.
- [ ] Single-cycle operations checked exhaustively.
- [ ] MUL checked for all 256 input pairs.
- [ ] DIV checked for all 256 input pairs.
- [ ] Divide by zero checked.
- [ ] Final simulation has 0 errors.
- [ ] Target reference: 3584 + 512 = 4096 checks.

## OJT milestone
- [ ] Gate-level design compiles correctly.
- [ ] Gate-level design simulates correctly.
- [ ] GitHub repository is clean and mentor-reviewable.
- [ ] README/documentation included.
- [ ] Python/TCL scripting requirement addressed and clearly labeled where inferred.
