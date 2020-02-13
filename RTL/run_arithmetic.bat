iverilog  -g2012 -o target.vcd tb_arithmetic.sv fixedpoint.sv
vvp -n target.vcd
del target.vcd