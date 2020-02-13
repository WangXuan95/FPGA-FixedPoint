iverilog -g2012 -o target.vcd tb_float2fxp_pipe.sv fixedpoint.sv
vvp -n target.vcd
del target.vcd