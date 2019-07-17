iverilog  -g2005-sv -o target.vcd tb_pipe_FixedPointSqrt.sv pipe_FixedPointSqrt.sv comb_FixedPointZoom.sv
vvp -n target.vcd
del target.vcd