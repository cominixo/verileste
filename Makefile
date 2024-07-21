
default: all


all: 
	sv2v rtl/*.sv -w synth/ --top fpga

	yosys -p "read_verilog -sv ip/gowin_rpll.v synth/*.v" -p "synth_gowin -json verileste_synth.json"

#	rm synth/*