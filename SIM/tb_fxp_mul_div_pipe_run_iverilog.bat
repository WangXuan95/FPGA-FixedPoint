del sim.out dump.vcd
iverilog  -g2001  -o sim.out  tb_fxp_mul_div_pipe.v  ../RTL/fixedpoint.v
vvp -n sim.out
del sim.out
pause