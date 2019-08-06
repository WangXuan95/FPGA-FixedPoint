module comb_FixedPointDiv #(
	parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  logic [WIIA+WIFA-1:0] dividend,
    input  logic [WIIB+WIFB-1:0] divisor,
    output logic [WOI +WOF -1:0] out,
    output logic overflow
);

localparam WRI = WOI+WIIB > WIIA ? WOI+WIIB : WIIA;
localparam WRF = WOF+WIFB > WIFA ? WOF+WIFB : WIFA;

logic sign = 1'b0;
logic [WIIA+WIFA-1:0] udividend = '0;
logic [WIIB+WIFB-1:0]  udivisor = '0;
logic [ WRI+ WRF-1:0] acc, acct, divd, divr;

always @ (*) begin  // convert dividend and divisor to positive number
    sign      = dividend[WIIA+WIFA-1] ^ divisor[WIIB+WIFB-1];
    udividend = dividend[WIIA+WIFA-1] ? (~dividend)+1 : dividend;
    udivisor  =  divisor[WIIB+WIFB-1] ? (~ divisor)+1 : divisor ;
end

comb_FixedPointZoom # (
    .WII      ( WIIA      ),
    .WIF      ( WIFA      ),
    .WOI      ( WRI       ),
    .WOF      ( WRF       ),
    .ROUND    ( 0         )
) dividend_zoom (
    .in       ( udividend ),
    .out      ( divd      ),
    .overflow (           )
);

comb_FixedPointZoom # (
    .WII      ( WIIB      ),
    .WIF      ( WIFB      ),
    .WOI      ( WRI       ),
    .WOF      ( WRF       ),
    .ROUND    ( 0         )
)  divisor_zoom (
    .in       ( udivisor  ),
    .out      ( divr      ),
    .overflow (           )
);

always @ (*) begin
    acc = '0;
    for(int shamt=WOI-1; shamt>=-WOF; shamt--) begin
        if(shamt>=0)
            acct = acc + (divr<<shamt);
        else
            acct = acc + (divr>>(-shamt));
        if( acct <= divd ) begin
            acc = acct;
            out[WOF+shamt] = 1'b1;
        end else
            out[WOF+shamt] = 1'b0;
    end
    
    if(ROUND && ~(&out)) begin
        acct = acc+(divr>>(WOF));
        if(acct-divd<divd-acc)
            out++;
    end
    
    overflow = 1'b0;
    if(sign) begin
        if(out[WOI+WOF-1]) begin
            if(|out[WOI+WOF-2:0]) overflow = 1'b1;
            out[WOI+WOF-1] = 1'b1;
            out[WOI+WOF-2:0] = '0;
        end else begin
            out = (~out)+1;
        end
    end else begin
        if(out[WOI+WOF-1]) begin
            overflow = 1'b1;
            out[WOI+WOF-1] = 1'b0;
            out[WOI+WOF-2:0] = '1;
        end
    end
end

endmodule
