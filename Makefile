# Makefile for ALU Verilog Simulation Project

# Absolute tool paths for Questa/ModelSim
VLIB = /mnt/c/questasim64_10.7c/win64/vlib.exe
VLOG = /mnt/c/questasim64_10.7c/win64/vlog.exe
VSIM = /mnt/c/questasim64_10.7c/win64/vsim.exe

SRC = alu_opA.v alu_opB.v alu_two_op.v alu_top.v defines.v
TB  = tb.v
LIB = work
TOP = tb         # <-- Change to your testbench module name if not 'tb'

.PHONY: all run clean wave

all: $(LIB)
	$(VLOG) -work $(LIB) -novopt -suppress 12110 +define+MUL_OP $(SRC) $(TB)

# Command to run simulation in CLI mode
run: all
	$(VSIM) -c -do "run -all; exit" $(LIB).$(TOP)

# Optional: Run in GUI with waveform (creates .do for add wave *)
wave: all
	echo 'add wave *; run -all' > wave.do
	$(VSIM) -novopt -suppress 12110 $(LIB).$(TOP) -do wave.do

# Create work library
$(LIB):
	$(VLIB) $(LIB)

# Clean up everything
clean:
	rm -rf $(LIB) vsim.wlf transcript *.log *.ucdb *.dat *.dbs *.bak *.sv wave.do

