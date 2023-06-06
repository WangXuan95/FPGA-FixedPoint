del sim.out dump.vcd
iverilog  -g2001  -o sim.out  tb_add_sub_mul_div.v  ../RTL/fixedpoint.v
vvp -n sim.out
del sim.out
pause