iverilog -g2012 -o target.vcd tb_fxp2float_pipe.sv fixedpoint.sv
vvp -n target.vcd
del target.vcd