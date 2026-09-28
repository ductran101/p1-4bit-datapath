# Source-Grounded Requirements

## A. OJT execution-plan requirements
From `FPTU_VLSI_OJT_Execution_Plan.xlsx`:

- Project: **P1 — Digital Logic Foundation & Scripting**
- Schedule: **Week 1–2, Day 1–Day 10**
- Goal: **Build a 4-bit CPU Datapath from gate-level. Python & TCL scripting.**
- Weekly P1 project-implementation allocation:
  - Week 1: 19.1 hours
  - Week 2: 18.8 hours
- P1 milestone: **D10 (End Week 2)**
- Pass criterion: **Gate-level design compiles and simulates correctly**
- Assessment: **GitHub repo reviewed by mentor**
- General certification rubric in the plan:
  - Technical Implementation 40%
  - Verification Coverage 25%
  - Documentation Quality 20%
  - Presentation 15%

## B. Detailed ALU specification from the PDFs
The 29-page report defines:
- 4-bit inputs `a` and `b`
- 4-bit opcode
- 8-bit result
- 10 operations
- status flags
- 9 Verilog design files + 1 testbench
- gate-level/structural building blocks
- shared adder for ADD/SUB and MUL/DIV
- shift-based sequential MUL/DIV
- exhaustive verification
- Vivado simulation workflow

## C. What is NOT currently specified
The current sources do **not** clearly specify that P1 must include:
- Program Counter
- instruction register
- instruction memory
- data memory
- register file
- accumulator register
- branch/jump logic
- a full fetch/decode/execute CPU cycle

Therefore those blocks must not be invented as mandatory requirements.

The phrase **4-bit CPU Datapath** in the Excel is broader than the detailed **4-bit ALU** PDF. This remains an open scope question for the mentor unless another document defines the missing CPU blocks.
