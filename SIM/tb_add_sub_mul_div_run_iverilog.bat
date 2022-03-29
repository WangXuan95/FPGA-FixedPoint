del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_add_sub_mul_div.sv  ../RTL/fixedpoint.sv
vvp -n sim.out
del sim.out
pause