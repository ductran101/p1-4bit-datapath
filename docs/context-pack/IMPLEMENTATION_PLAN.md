# Recommended Implementation Plan

This order follows the instructor's stated modular workflow: build modules first, integrate at the end.

1. **full_adder.v**
   - implement gate primitives
   - unit-test truth table if desired

2. **adder_subtractor_4bit.v**
   - XOR B with SUB
   - instantiate four full adders
   - verify ADD/SUB, c3, c4

3. **logic_unit_4bit.v**
   - AND, OR, XOR, NOT

4. **shifter_4bit.v**
   - SHL/SHR wiring
   - shifted-out carry bits

5. **control_unit.v**
   - opcode decode

6. **result_mux.v**
   - select 8-bit output

7. **flag_unit.v**
   - C/Z/V/N logic

8. **muldiv_unit.v**
   - registers/state/counter
   - shared-adder interface
   - shift-and-add multiply
   - restoring shift-and-subtract divide
   - busy/done/div-by-zero

9. **alu_4bit.v**
   - instantiate everything
   - add the input muxes that give `muldiv_unit` ownership of the shared adder while busy

10. **alu_4bit_tb.v**
    - representative examples
    - exhaustive single-cycle verification
    - exhaustive MUL/DIV verification
    - latency checks

11. **TCL/Python support**
    - only as clearly labeled supporting automation because exact deliverables are not specified by the PDFs

12. **Vivado verification**
    - compile/elaborate
    - behavioral simulation Run All
    - confirm final PASS
    - open schematic if useful
    - synthesis/report utilization if requested

13. **GitHub documentation**
    - architecture
    - opcode table
    - how to run
    - verification result
