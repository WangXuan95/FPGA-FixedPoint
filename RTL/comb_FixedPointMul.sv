module comb_FixedPointMul # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROOF = 1,
    parameter bit ROUND= 1
)(
    input  logic [WIIA+WIFA-1:0] ina,
    input  logic [WIIB+WIFB-1:0] inb,
    output logic [WOI +WOF -1:0] out,
    output logic upflow, downflow
);

localparam WRI = WIIA + WIIB;
localparam WRF = WIFA + WIFB;

wire signed [WRI+WRF-1:0] res = $signed(ina) * $signed(inb);

comb_FixedPointZoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROOF     ( ROOF           ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( out            ),
    .upflow   ( upflow         ),
    .downflow ( downflow       )
);

endmodule
