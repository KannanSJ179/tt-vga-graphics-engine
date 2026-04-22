SIM=iverilog
VVP=vvp

SRC=../src/project.v ../src/hvsync_generator.v testbench.v

all: sim

sim:
	$(SIM) -o sim.vvp $(SRC)
	$(VVP) sim.vvp

wave:
	gtkwave dump.vcd
