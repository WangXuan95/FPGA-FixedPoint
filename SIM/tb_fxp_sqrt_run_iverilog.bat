del sim.out dump.vcd
iverilog  -g2005-sv  -o sim.out  tb_fxp_sqrt.sv  ../RTL/fixedpoint.sv
vvp -n sim.out
del sim.out
pause