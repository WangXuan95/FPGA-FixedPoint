iverilog  -g2005-sv -o target.vcd test_arithmetic.sv comb_FixedPointAdd.sv comb_FixedPointAddSub.sv comb_FixedPointMul.sv comb_FixedPointDiv.sv comb_FixedPointZoom.sv
vvp -n target.vcd
del target.vcd