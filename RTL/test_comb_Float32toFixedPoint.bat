iverilog -g2005-sv -o target.vcd test_comb_Float32toFixedPoint.sv comb_Float32toFixedPoint.sv
vvp -n target.vcd
del target.vcd