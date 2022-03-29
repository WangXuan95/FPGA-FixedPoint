del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_convert_fxp_float.sv  ../RTL/fixedpoint.sv
vvp -n sim.out
del sim.out
pause