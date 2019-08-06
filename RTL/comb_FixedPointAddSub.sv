module comb_FixedPointAddSub # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  logic [WIIA+WIFA-1:0] ina,
    input  logic [WIIB+WIFB-1:0] inb,
    input  logic sub, // 0=add, 1=sub
    output logic [WOI +WOF -1:0] out,
    output logic overflow
);
localparam WIIBE = WIIB + 1;
localparam   WII = WIIA>WIIBE ? WIIA : WIIBE;
localparam   WIF = WIFA>WIFB  ? WIFA : WIFB;
localparam   WRI = WII + 1;
localparam   WRF = WIF;

wire [WIIBE+WIFB-1:0] inbe;
wire [WII+WIF-1:0] inaz, inbz;
wire [WIIBE+WIFB-1:0] inbv = sub ? ((~inbe)+1) : inbe;
wire signed [WRI+WRF-1:0] res = $signed(inaz) + $signed(inbz);

comb_FixedPointZoom # (
    .WII      ( WIIB     ),
    .WIF      ( WIFB     ),
    .WOI      ( WIIBE    ),
    .WOF      ( WIFB     ),
    .ROUND    ( 0        )
) inb_extend (
    .in       ( inb      ),
    .out      ( inbe     ),
    .overflow (          )
);

assign inbv = sub ? ((~inbe)+1) : inbe;

comb_FixedPointZoom # (
    .WII      ( WIIA     ),
    .WIF      ( WIFA     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROUND    ( 0        )
) ina_zoom (
    .in       ( ina      ),
    .out      ( inaz     ),
    .overflow (          )
);

comb_FixedPointZoom # (
    .WII      ( WIIBE    ),
    .WIF      ( WIFB     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROUND    ( 0        )
) inb_zoom (
    .in       ( inbv     ),
    .out      ( inbz     ),
    .overflow (          )
);

comb_FixedPointZoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( out            ),
    .overflow ( overflow       )
);

endmodule
