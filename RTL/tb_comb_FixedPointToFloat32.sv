module test_comb_FixedPointToFloat32();

localparam WII  = 16;
localparam WIF  = 16;

logic [WII+WIF-1:0] in_fixed;
logic [31:0] out_float;
logic overflow;

comb_FixedPointToFloat32 #(
    .WII      ( WII       ),
    .WIF      ( WIF       )
) fixed2float (
    .in       ( in_fixed  ),
    .out      ( out_float )
);

task automatic test_fixed2float(input [WII+WIF-1:0] _infixed);
    in_fixed = _infixed;
#2  $display("    fixed=%16f     float=0x%08x   %s", ($signed(in_fixed)*1.0)/(1<<WIF), out_float, overflow?"overflow!!":"");
endtask

initial begin
    test_fixed2float('hc36f0d77);
    test_fixed2float('h44696e31);
    test_fixed2float('hc427f97f);
    test_fixed2float('h00000000);
    test_fixed2float('h80000001);
    test_fixed2float('hffffffff);
    test_fixed2float('h442caab9);
    test_fixed2float('hc19d957c);
    test_fixed2float('h4341cd28);
    test_fixed2float('h43a2cd6b);
    test_fixed2float('h43a8506c);
    test_fixed2float('hc3be496f);
    test_fixed2float('hc3d3dcd6);
    test_fixed2float('h441e0fa9);
    test_fixed2float('hc43ea05f);
    test_fixed2float('hc4403f17);
    test_fixed2float('h438856d1);
    test_fixed2float('h441ce8c1);
    test_fixed2float('h446a45dc);
    test_fixed2float('hc3b9294f);
    test_fixed2float('hc38c9f55);
    test_fixed2float('hc33b70c2);
    test_fixed2float('h44008061);
    test_fixed2float('h43f1e935);
    test_fixed2float('h43ae7eac);
    test_fixed2float('hc269c397);
    test_fixed2float('hc3b43c04);
    test_fixed2float('hc325abbd);
    test_fixed2float('h4475736b);
    test_fixed2float('h434fbce6);
    test_fixed2float('h43fc4777);
    test_fixed2float('h444e0da0);
    test_fixed2float('hc46b581a);
    test_fixed2float('h44333fac);
    test_fixed2float('h42960ffd);
    test_fixed2float('h446b7203);
    test_fixed2float('hc469d2f9);
    test_fixed2float('hc47289aa);
    test_fixed2float('hc33c7a47);
    test_fixed2float('hc30ecc5b);
    test_fixed2float('h445c9965);
    test_fixed2float('h44763643);
    test_fixed2float('h441e5eed);
end

endmodule
