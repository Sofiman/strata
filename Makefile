# Source: https://blog.peramid.es/posts/2024-10-19-fpga.html

CONSTRAINT_FILE := rv32i.cst

%.synth.json: %.v $(filter-out $(wildcard *_tb.v),$(wildcard *.v))
	yosys -p "read_verilog $^; synth_gowin -top $* -json $@ -family gw2a"

%.pnr.json: %.synth.json $(CONSTRAINT_FILE)
	nextpnr-himbaechel --json $< --write $@ --freq 300 --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=$(CONSTRAINT_FILE) 

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

%_tb.out: %_tb.v %.v
	iverilog -o $@ -D VCD_OUTPUT=$*_tb $*_tb.v $*.v

%_tb.vcd: %_tb.out
	./$<
	surfer $*_tb.vcd

clean:
	$(RM) *.pnr.json *.synth.json *.vcd *.out *.fs
