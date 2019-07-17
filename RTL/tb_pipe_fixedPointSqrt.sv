module test_pipe_FixedPointSqrt();

localparam WII = 9;
localparam WIF = 10;
localparam WOI = 9;
localparam WOF = 10;

logic clk=1'b0, rst=1'b1;

logic [WII+WIF-1:0] in = '0;
logic [WOI+WOF-1:0] osqrt;
logic upflow, downflow;

pipe_FixedPointSqrt # (
    .WII      ( WII      ),
    .WIF      ( WIF      ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROOF     ( 1        ),
    .ROUND    ( 1        )
) pipe_fdiv_i (
    .clk                  ,
    .rst                  ,
    .in       ( in       ),
    .out      ( osqrt    ),
    .upflow   ( upflow   ),
    .downflow ( downflow )
);

int cyclecnt = 0;
task automatic test(input [WII+WIF-1:0] _in);
#19 clk = 1'b1;
#1  in  = _in;
#19 clk = 1'b0;
#2  $display("    cycle %3d    sqrt %16f:    %16f =%16f^2",cyclecnt++,($signed(in)*1.0)/(1<<WIF), (($signed(osqrt)*1.0)/(1<<WOF))*(($signed(osqrt)*1.0)/(1<<WOF)), ($signed(osqrt)*1.0)/(1<<WOF) );
endtask

initial begin
#4  rst = 1'b0;
    test('hc36f0d77);
    test('h44696e31);
    test('hc427f97f);
    test('h00000000);
    test('h80000001);
    test('hffffffff);
    test('h442caab9);
    test('hc19d957c);
    test('h4341cd28);
    test('h43a2cd6b);
    test('h43a8506c);
    test('hc3be496f);
    test('hc3d3dcd6);
    test('h441e0fa9);
    test('hc43ea05f);
    test('hc4403f17);
    test('h438856d1);
    test('h441ce8c1);
    test('h446a45dc);
    test('hc3b9294f);
    test('hc38c9f55);
    test('hc33b70c2);
    test('h44008061);
    test('h43f1e935);
    test('h43ae7eac);
    test('hc269c397);
    test('hc3b43c04);
    test('hc325abbd);
    test('h4475736b);
    test('h434fbce6);
    test('h43fc4777);
    test('h444e0da0);
    test('hc46b581a);
    test('h44333fac);
    test('h42960ffd);
    test('h446b7203);
    test('hc469d2f9);
    test('hc47289aa);
    test('hc33c7a47);
    test('hc30ecc5b);
    test('h445c9965);
    test('h44763643);
    test('h441e5eed);
end

endmodule
