iverilog -g2005-sv -o target.vcd tb_pipe_Float32toFixedPoint.sv pipe_Float32toFixedPoint.sv
vvp -n target.vcd
del target.vcd