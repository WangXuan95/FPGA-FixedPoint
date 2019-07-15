// --------------------------------------------------------------------------------------------------------
// - NOTE: pipeline stage count = 2
// -       which means out(result) will appear 2 cycles after signals appear on the input
// --------------------------------------------------------------------------------------------------------

module pipe_FixedPointMul # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROOF = 1,
    parameter bit ROUND= 1
)(
    input  logic clk, rst,
    input  logic [WIIA+WIFA-1:0] ina,
    input  logic [WIIB+WIFB-1:0] inb,
    output logic [WOI +WOF -1:0] out,
    output logic upflow, downflow
);
localparam WRI = WIIA + WIIB;
localparam WRF = WIFA + WIFB;

logic [WOI +WOF -1:0] outc;
logic upflowc, downflowc;
logic signed [WRI+WRF-1:0] res = '0;

initial {out, upflow, downflow} = '0;

always @ (posedge clk or posedge rst)
    if(rst)
        res <= '0;
    else
        res <= $signed(ina) * $signed(inb);

comb_FixedPointZoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROOF     ( ROOF           ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( outc           ),
    .upflow   ( upflowc        ),
    .downflow ( downflowc      )
);

always @ (posedge clk or posedge rst)
    if(rst) begin
        out      <= '0;
        upflow   <= 1'b0;
        downflow <= 1'b0;
    end else begin
        out      <= outc;
        upflow   <= upflowc;
        downflow <= downflowc;
    end

endmodule
