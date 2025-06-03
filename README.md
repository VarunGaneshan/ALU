# ALU

## Running tests in Questa sim
```
vlog -sv +acc +cover -l alu_coverage.log test_bench.v #Compile
vsim -novopt -suppress 12110 -coverage alu_top_tb -c -do "add wave * coverage save -onexit -directive -codeAll alu.ucdb; run -all; exit" #Simulation with coverage
vcover report -html alu.ucdb -htmldir covReport -details #Coverage Report
```
