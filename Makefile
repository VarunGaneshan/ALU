# Makefile for ALU Verilog Simulation Project

LIB = work       

.PHONY: clean

# Clean up everything
clean:
	rm -rf $(LIB) vsim.wlf transcript *.log *.ucdb *.dat *.dbs *.bak *.sv wave.do

