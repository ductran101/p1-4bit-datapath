# Supporting local simulation workflow; not an exact source-document deliverable.
IVERILOG ?= iverilog
VVP ?= vvp
PYTHON ?= python3

RTL := rtl/full_adder.v rtl/adder_subtractor_4bit.v rtl/logic_unit_4bit.v \
       rtl/shifter_4bit.v rtl/control_unit.v rtl/muldiv_unit.v \
       rtl/result_mux.v rtl/flag_unit.v rtl/alu_4bit.v
TB := tb/alu_4bit_tb.v

.PHONY: sim check-sim
sim: build/alu_4bit_tb.vvp
	$(VVP) $< > build/sim.log 2>&1 || { cat build/sim.log; exit 1; }
	cat build/sim.log
	$(PYTHON) scripts/check_sim.py build/sim.log

build/alu_4bit_tb.vvp: $(RTL) $(TB) | build
	$(IVERILOG) -g2012 -Wall -s alu_4bit_tb -o $@ $(RTL) $(TB)

build:
	mkdir -p $@

check-sim:
	$(PYTHON) scripts/check_sim.py build/sim.log
