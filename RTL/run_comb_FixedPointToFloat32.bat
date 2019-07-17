iverilog -g2005-sv -o target.vcd tb_comb_FixedPointToFloat32.sv comb_FixedPointToFloat32.sv
vvp -n target.vcd
del target.vcd