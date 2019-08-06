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
    parameter bit ROUND= 1
)(
    input  logic clk, rst,
    input  logic [WIIA+WIFA-1:0] ina,
    input  logic [WIIB+WIFB-1:0] inb,
    output logic [WOI +WOF -1:0] out,
    output logic overflow
);
localparam WRI = WIIA + WIIB;
localparam WRF = WIFA + WIFB;

logic [WOI +WOF -1:0] outc;
logic overflowc;
logic signed [WRI+WRF-1:0] res = '0;

initial {out, overflow} = '0;

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
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( outc           ),
    .overflow ( overflowc      )
);

always @ (posedge clk or posedge rst)
    if(rst) begin
        out      <= '0;
        overflow <= 1'b0;
    end else begin
        out      <= outc;
        overflow <= overflowc;
    end

endmodule
