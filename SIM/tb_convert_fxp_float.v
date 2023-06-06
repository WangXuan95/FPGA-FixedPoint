
//--------------------------------------------------------------------------------------------------------
// Module  : tb_convert_fxp_float
// Type    : simulation, top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: testbench for fxp2float, fxp2float_pipe, float2fxp and float2fxp_pipe
//           1. use fxp2float and fxp2float_pipe to convert fixed-point to float-point
//           2. use float2fxp and float2fxp_pipe to convert float-point back to fixed-point
//--------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module tb_convert_fxp_float ();

initial $dumpvars(0, tb_convert_fxp_float);


localparam WII  = 16;
localparam WIF  = 16;

localparam WOI  = 15;
localparam WOF  = 18;


reg rstn = 1'b0;
reg clk  = 1'b1;
always #(10000) clk = ~clk;   // 50MHz
initial begin repeat(4) @(posedge clk); rstn<=1'b1; end


reg  [WII+WIF-1:0] fxp1 = 0;
wire        [31:0] float2;
wire        [31:0] float3;
wire [WOI+WOF-1:0] fxp4;
wire               overflow4;
wire [WOI+WOF-1:0] fxp5;
wire               overflow5;


fxp2float #(
    .WII      ( WII       ),
    .WIF      ( WIF       )
) fxp2float_i (
    .in       ( fxp1      ),
    .out      ( float2    )
);


fxp2float_pipe #(
    .WII      ( WII       ),
    .WIF      ( WIF       )
) fxp2float_pipe_i (
    .rstn     ( rstn      ),
    .clk      ( clk       ),
    .in       ( fxp1      ),
    .out      ( float3    )
);


float2fxp #(
    .WOI      ( WOI       ),
    .WOF      ( WOF       ),
    .ROUND    ( 1         )
) float2fxp_i (
    .in       ( float2    ),
    .out      ( fxp4      ),
    .overflow ( overflow4 )
);


float2fxp_pipe #(
    .WOI      ( WOI       ),
    .WOF      ( WOF       ),
    .ROUND    ( 1         )
) float2fxp_pipe_i (
    .rstn     ( rstn      ),
    .clk      ( clk       ),
    .in       ( float2    ),
    .out      ( fxp5      ),
    .overflow ( overflow5 )
);


reg        [31:0] cyclecnt = 0;
always @ (posedge clk)
    if(rstn) begin
        cyclecnt <= cyclecnt + 1;
        $display("cycle%3d    fxp1=%16f    float2=0x%08x    float3=0x%08x    fxp4=%16f %s    fxp5=%16f %s" , cyclecnt,
            ($signed(fxp1)*1.0)/(1<<WIF)  ,
            float2                        ,
            float3                        ,
            ($signed(fxp4)*1.0)/(1<<WOF)  ,
            overflow4 ? "(o)" : "   "     ,
            ($signed(fxp5)*1.0)/(1<<WOF)  ,
            overflow5 ? "(o)" : "   " 
        );
    end


initial begin
    while(~rstn) @ (posedge clk);
    @ (posedge clk) fxp1 <= 'h00201551;
    @ (posedge clk) fxp1 <= 'h00300010;
    @ (posedge clk) fxp1 <= 'h009b63b3;
    @ (posedge clk) fxp1 <= 'h0bb51e68;
    @ (posedge clk) fxp1 <= 'h0e56e35e;
    @ (posedge clk) fxp1 <= 'h0432d234;
    @ (posedge clk) fxp1 <= 'h0bb004db;
    @ (posedge clk) fxp1 <= 'h09ad79bc;
    @ (posedge clk) fxp1 <= 'h16de4b61;
    @ (posedge clk) fxp1 <= 'h166f2bff;
    @ (posedge clk) fxp1 <= 'h1a164399;
    @ (posedge clk) fxp1 <= 'h18d9b80a;
    @ (posedge clk) fxp1 <= 'h16ba294f;
    @ (posedge clk) fxp1 <= 'hf6360551;
    @ (posedge clk) fxp1 <= 'ha34728f2;
    @ (posedge clk) fxp1 <= 'h16b53c9c;
    @ (posedge clk) fxp1 <= 'hb6b62e8e;
    @ (posedge clk) fxp1 <= 'h170edf8b;
    @ (posedge clk) fxp1 <= 'h1e546855;
    @ (posedge clk) fxp1 <= 'h180a9d44;
    @ (posedge clk) fxp1 <= 'hf6c772c2;
    @ (posedge clk) fxp1 <= 'ha2ad7ac4;
    @ (posedge clk) fxp1 <= 'h00001551;
    @ (posedge clk) fxp1 <= 'h00000010;
    @ (posedge clk) fxp1 <= 'ha09b63b3;
    @ (posedge clk) fxp1 <= 'h8bb51e68;
    @ (posedge clk) fxp1 <= 'h6e56e35e;
    @ (posedge clk) fxp1 <= 'h9432d234;
    @ (posedge clk) fxp1 <= 'h2bb004db;
    @ (posedge clk) fxp1 <= 'h39ad79bc;
    @ (posedge clk) fxp1 <= 'h76de4b61;
    @ (posedge clk) fxp1 <= 'h666f2bff;
    @ (posedge clk) fxp1 <= 'h7a164399;
    @ (posedge clk) fxp1 <= 'h68d9b80a;
    @ (posedge clk) fxp1 <= 'hb6ba294f;
    @ (posedge clk) fxp1 <= 'hf6360551;
    @ (posedge clk) fxp1 <= 'ha34728f2;
    @ (posedge clk) fxp1 <= 'h66b53c9c;
    @ (posedge clk) fxp1 <= 'hb6b62e8e;
    @ (posedge clk) fxp1 <= 'hd70edf8b;
    @ (posedge clk) fxp1 <= 'h6e546855;
    @ (posedge clk) fxp1 <= 'h680a9d44;
    @ (posedge clk) fxp1 <= 'hf6c772c2;
    @ (posedge clk) fxp1 <= 'ha2ad7ac4;
repeat(WII+WIF+WOI+WOF+8)
    @ (posedge clk) fxp1 <= 'h00000000;
    $finish;
end

endmodule
