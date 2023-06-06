del sim.out dump.vcd
iverilog  -g2001  -o sim.out  tb_convert_fxp_float.v  ../RTL/fixedpoint.v
vvp -n sim.out
del sim.out
pause