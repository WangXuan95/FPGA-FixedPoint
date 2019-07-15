iverilog  -g2005-sv -o target.vcd test_pipe_FixedPointDiv.sv pipe_FixedPointDiv.sv comb_FixedPointZoom.sv
vvp -n target.vcd
del target.vcd