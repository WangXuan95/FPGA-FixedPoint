
//--------------------------------------------------------------------------------------------------------
// Module  : tb_fxp_sqrt
// Type    : simulation, top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: testbench for fxp_sqrt and fxp_sqrt_pipe
//--------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module tb_fxp_sqrt();

initial $dumpvars(0, tb_fxp_sqrt);


localparam WII = 10;
localparam WIF = 10;
localparam WOI = 6;
localparam WOF = 12;


reg rstn = 1'b0;
reg clk  = 1'b1;
always #(10000) clk = ~clk;   // 50MHz
initial begin repeat(4) @(posedge clk); rstn<=1'b1; end


reg  [WII+WIF-1:0] ival = 0;
wire [WOI+WOF-1:0] oval1;
wire               overflow1;
wire [WOI+WOF-1:0] oval2;
wire               overflow2;


fxp_sqrt #(
    .WII      ( WII       ),
    .WIF      ( WIF       ),
    .WOI      ( WOI       ),
    .WOF      ( WOF       ),
    .ROUND    ( 1         )
) fxp_sqrt_i (
    .in       ( ival      ),
    .out      ( oval1     ),
    .overflow ( overflow1 )
);


fxp_sqrt_pipe # (
    .WII      ( WII       ),
    .WIF      ( WIF       ),
    .WOI      ( WOI       ),
    .WOF      ( WOF       ),
    .ROUND    ( 1         )
) fxp_sqrt_pipe_i (
    .rstn     ( rstn      ),
    .clk      ( clk       ),
    .in       ( ival      ),
    .out      ( oval2     ),
    .overflow ( overflow2 )
);


reg        [31:0] cyclecnt = 0;
always @ (posedge clk)
    if(rstn) begin
        cyclecnt <= cyclecnt + 1;
        $display("cycle%3d    ival=%12f   oval1=%12f %s   oval1^2=%12f   oval2=%12f %s   oval2^2=%12f" , cyclecnt,
            (($signed( ival)*1.0)/(1<<WIF))                                   ,
            (($signed(oval1)*1.0)/(1<<WOF))                                   ,
            overflow1 ? "(o)" : "   "                                         ,
            (($signed(oval1)*1.0)/(1<<WOF)) * (($signed(oval1)*1.0)/(1<<WOF)) ,
            (($signed(oval2)*1.0)/(1<<WOF))                                   ,
            overflow2 ? "(o)" : "   "                                         ,
            (($signed(oval2)*1.0)/(1<<WOF)) * (($signed(oval2)*1.0)/(1<<WOF)) 
        );
    end


initial begin
    while(~rstn) @ (posedge clk);
    @ (posedge clk) ival <= 'hf0d77;
    @ (posedge clk) ival <= 'h96e31;
    @ (posedge clk) ival <= 'h7f97f;
    @ (posedge clk) ival <= 'hfffff;
    @ (posedge clk) ival <= 'hcaab9;
    @ (posedge clk) ival <= 'hd957c;
    @ (posedge clk) ival <= 'h1cd28;
    @ (posedge clk) ival <= 'h2cd6b;
    @ (posedge clk) ival <= 'h8506c;
    @ (posedge clk) ival <= 'he496f;
    @ (posedge clk) ival <= 'h3dcd6;
    @ (posedge clk) ival <= 'h00000;
    @ (posedge clk) ival <= 'h80000;
    @ (posedge clk) ival <= 'he0fa9;
    @ (posedge clk) ival <= 'hea05f;
    @ (posedge clk) ival <= 'h03f17;
    @ (posedge clk) ival <= 'h856d1;
    @ (posedge clk) ival <= 'hce8c1;
    @ (posedge clk) ival <= 'ha45dc;
    @ (posedge clk) ival <= 'h0094f;
    @ (posedge clk) ival <= 'hc9f55;
    @ (posedge clk) ival <= 'hb70c2;
    @ (posedge clk) ival <= 'h08061;
    @ (posedge clk) ival <= 'h1e935;
    @ (posedge clk) ival <= 'he7eac;
    @ (posedge clk) ival <= 'h9c397;
    @ (posedge clk) ival <= 'h43c04;
    @ (posedge clk) ival <= 'h5abbd;
    @ (posedge clk) ival <= 'h5736b;
    @ (posedge clk) ival <= 'hfbce6;
    @ (posedge clk) ival <= 'hc4777;
    @ (posedge clk) ival <= 'he0da0;
    @ (posedge clk) ival <= 'hb581a;
    @ (posedge clk) ival <= 'h03fac;
    @ (posedge clk) ival <= 'h60ffd;
    @ (posedge clk) ival <= 'h07203;
    @ (posedge clk) ival <= 'h9d2f9;
    @ (posedge clk) ival <= 'h289aa;
    @ (posedge clk) ival <= 'h07a47;
    @ (posedge clk) ival <= 'hecc5b;
    @ (posedge clk) ival <= 'hc9965;
    @ (posedge clk) ival <= 'h03643;
    @ (posedge clk) ival <= 'he5eed;
repeat(WOI+WOF+8)
    @ (posedge clk) ival <= 'h00000;
    $finish;
end

endmodule
