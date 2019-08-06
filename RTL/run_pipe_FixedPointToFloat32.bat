iverilog -g2005-sv -o target.vcd tb_pipe_FixedPointToFloat32.sv pipe_FixedPointToFloat32.sv
vvp -n target.vcd
del target.vcd