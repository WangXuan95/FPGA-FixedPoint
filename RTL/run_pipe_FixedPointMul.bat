iverilog  -g2005-sv -o target.vcd tb_pipe_fixedPointMul.sv pipe_fixedPointMul.sv comb_FixedPointZoom.sv
vvp -n target.vcd
del target.vcd