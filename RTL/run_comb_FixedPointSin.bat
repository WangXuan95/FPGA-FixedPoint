iverilog -g2005-sv -o target.vcd tb_comb_FixedPointSin.sv comb_FixedPointSin.sv comb_FixedPointZoom.sv
vvp -n target.vcd
del target.vcd