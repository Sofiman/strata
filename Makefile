# Source: https://blog.peramid.es/posts/2024-10-19-fpga.html

CONSTRAINT_FILE := rv32i.cst
ifdef DOT
  YOSYS_SHOW := show -format dot -prefix netlist -colors 1 -width;
else
  YOSYS_SHOW := ""
endif

%.synth.json: %.v $(filter-out $(wildcard *_tb.v),$(wildcard *.v))
	yosys -p "read_verilog $^; ${YOSYS_SHOW} synth_gowin -top $* -json $@ -family gw2a"

%.pnr.json: %.synth.json $(CONSTRAINT_FILE)
	nextpnr-himbaechel --json $< --write $@ --freq 100 --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=$(CONSTRAINT_FILE)

%.fs: %.pnr.json
	gowin_pack -d GW2A-18C -o $@ $<

%.png: %.pnr.json
	gowin_pack -d GW2A-18C --png $@ $<


# --- Flashing

%.prog_sram: %.fs
	openFPGALoader -b tangnano20k $*.fs

%.prog_flash: %.fs
	openFPGALoader -b tangnano20k -f $*.fs


# --- Simulation

VCD_OUTPUT ?= $*_tb.vcd
%_tb.out: %_tb.v $(filter-out $(wildcard *_tb.v),$(wildcard *.v))
	iverilog -o $@ -D VCD_OUTPUT=\"$(VCD_OUTPUT)\" $(IVERILOG_FLAGS) $^

%_tb.vcd: %_tb.out
	@./$<

%_tb.wave: %_tb.vcd
	surfer $@

# --- Tests

%.test: testprograms/%/test.v testprograms/%/rom.hex
	$(MAKE) -B VCD_OUTPUT=testprograms/$*/result.vcd IVERILOG_FLAGS="-D TEST_SCRIPT=\\\"testprograms/$*/test.v\\\" -D ROM_FILE=\\\"testprograms/$*/rom.hex\\\"" rv32i_tb.vcd

test: $(addsuffix .test,$(notdir $(wildcard testprograms/*)))

clean:
	$(RM) *.pnr.json *.synth.json *.vcd *.out *.fs

.PHONY: %.test test clean
