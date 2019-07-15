module comb_FixedPointSqrt #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROOF = 1,
    parameter bit ROUND= 1
)(
    input  logic [WII+WIF-1:0] in,
    output logic [WOI+WOF-1:0] out,
    output logic upflow, downflow
);

localparam WTI = (WII%2==1) ? WII+1 : WII;
localparam WRI = WTI/2;

wire  sign = in[WII+WIF-1];
logic [WTI+WIF-1:0] inu;
logic [WTI+WIF-1:0] resu2, resu2tmp;
logic [WTI+WIF-1:0] resu;
wire  [WRI+WIF  :0] resushort = sign ? (~resu[WRI+WIF:0])+1 : resu[WRI+WIF:0];
always @ (*) begin
    inu = '0;
    inu[WII+WIF-1:0] = sign ? (~in)+1 : in;
end

always @ (*) begin
    {resu2,resu} = '0;
    for(int ii=WRI-1; ii>=-WIF; ii--) begin
        resu2tmp = resu2;
        if(ii>=0) resu2tmp += (resu<<( 1+ii));
        else      resu2tmp += (resu>>(-1-ii));
        if(2*ii+WIF>=0) resu2tmp += (1<<(2*ii+WIF));
        if(resu2tmp<=inu) begin
            resu[ii+WIF] = 1'b1;
            resu2 = resu2tmp;
        end
    end
end

comb_FixedPointZoom # (
    .WII      ( WRI+1          ),
    .WIF      ( WIF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROOF     ( ROOF           ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( resushort      ),
    .out      ( out            ),
    .upflow   ( upflow         ),
    .downflow ( downflow       )
);

endmodule
