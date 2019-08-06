module test_comb_FixedPointSin();

localparam WII  = 4;
localparam WIF  = 12;
localparam WOI  = 2;
localparam WOF  = 12;

logic [WII+WIF-1:0] in;
logic [WOI+WOF-1:0] osin;
logic overflow;

comb_FixedPointSin #(
    .WII        ( WII      ),
    .WIF        ( WIF      ),
    .WOI        ( WOI      ),
    .WOF        ( WOF      ),
    .ROUND      ( 1        )
) sqrt_i (
    .in         ( in       ),
    .out        ( osin     ),
    .i_overflow ( overflow )
);

task automatic test_sin(input [WII+WIF-1:0] _in);
    in = _in;
#2  $display("    sin %16f =%16f   %s",($signed(in)*1.0)/(1<<WIF), ($signed(osin)*1.0)/(1<<WOF) , overflow ? "input overflow!!" : "");
endtask

initial begin
    test_sin('h133d);
    test_sin('h1061);
    test_sin('h19a6);
    test_sin('h06cd);
    test_sin('h0bbf);
    test_sin('h13c2);
    test_sin('h128d);
    test_sin('h1485);
    test_sin('h036a);
    test_sin('h0798);
    test_sin('h14a1);
    test_sin('h11e4);
    test_sin('h081b);
    test_sin('h0a18);
    test_sin('h042e);
    test_sin('h04e5);
    test_sin('h1059);
    test_sin('hd296);
    test_sin('hf3db);
    test_sin('h0ef8);
    test_sin('h13e7);
    test_sin('h0f75);
    test_sin('h11cd);
    test_sin('hf3ac);
    test_sin('h14b1);
    test_sin('h05e9);
    test_sin('h10d1);
    test_sin('h0bb2);
    test_sin('h0a02);
    test_sin('h1987);
    test_sin('h1556);
    test_sin('h0204);
    test_sin('hc31f);
    test_sin('h178e);
    test_sin('he118);
    test_sin('h17f3);
    test_sin('hc1a0);
    test_sin('h0205);
    test_sin('h0632);
    test_sin('h109f);
    test_sin('h04a7);
    test_sin('h0419);
    test_sin('h03a0);
    test_sin('h172d);
    test_sin('hf04c);
    test_sin('h0b3b);
    test_sin('h1aab);
    test_sin('h11fb);
    test_sin('h0c32);
    test_sin('h045d);
    test_sin('h645d);
end

endmodule
