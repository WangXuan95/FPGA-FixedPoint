module comb_FixedPointAdd # (
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

localparam WII = WIIA>WIIB ? WIIA : WIIB;
localparam WIF = WIFA>WIFB ? WIFA : WIFB;
localparam WRI = WII + 1;
localparam WRF = WIF;

wire [WII+WIF-1:0] inaz, inbz;
wire signed [WRI+WRF-1:0] res = $signed(inaz) + $signed(inbz);

comb_FixedPointZoom # (
    .WII      ( WIIA     ),
    .WIF      ( WIFA     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROOF     ( 0        ),
    .ROUND    ( 0        )
) ina_zoom (
    .in       ( ina      ),
    .out      ( inaz     ),
    .upflow   (          ),
    .downflow (          )
);

comb_FixedPointZoom # (
    .WII      ( WIIB     ),
    .WIF      ( WIFB     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROOF     ( 0        ),
    .ROUND    ( 0        )
) inb_zoom (
    .in       ( inb      ),
    .out      ( inbz     ),
    .upflow   (          ),
    .downflow (          )
);

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
