
module comb_FixedPointSin #( //Cordic
    parameter WII  = 4,
    parameter WIF  = 8,
    parameter WOI  = 2,
    parameter WOF  = 12,
    parameter bit ROUND= 1
)(
    input  logic [WII+WIF-1:0] in,
    output logic [WOI+WOF-1:0] out,
    output logic i_overflow
);

localparam N_ITER = 8;
localparam WRI = 4;
localparam WRF = WOF>WIF ? WOF : WIF;
logic [WRI+WRF-1:0] xinit, target, halfpi, x, y, z, xt;
wire  [WRI+WRF-1:0] atan_table [N_ITER];
logic  overflowc, overflowl;

assign i_overflow = overflowc | overflowl;

comb_FixedPointZoom # (WRI,WRF,WOI,WOF,ROUND) out_zoom ( y, out   , overflowc );
comb_FixedPointZoom # (WII,WIF,WRI,WRF,    1)  in_zoom (in, target,           );

comb_FixedPointZoom # (4,28,WRI,WRF,1)    pi_zoom (32'h1921fb54, halfpi      ,);
comb_FixedPointZoom # (4,28,WRI,WRF,1) xinit_zoom (32'h09b75555, xinit       ,);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom0 (32'h0c90fdaa,atan_table[0],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom1 (32'h076b19c1,atan_table[1],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom2 (32'h03eb6ebf,atan_table[2],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom3 (32'h01fd5ba9,atan_table[3],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom4 (32'h00ffaadd,atan_table[4],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom5 (32'h007ff556,atan_table[5],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom6 (32'h003ffeaa,atan_table[6],);
comb_FixedPointZoom # (4,28,WRI,WRF,1) atan_zoom7 (32'h001fffd5,atan_table[7],);

always @ (*) begin
    y = '0;
    overflowl = 1'b0;
    if( target[WRI+WRF-1] )
        overflowl = 1'b1;
    else if( target>halfpi ) begin
        overflowl = 1'b1;
        y[WRF] = 1'b1;
    end else begin
        x = xinit;
        z = '0;
        for(int ii=0; ii<N_ITER; ii++) begin
            xt = (x>>ii);
            if(target > z) begin
                x -= (y>>ii);
                y += xt;
                z += atan_table[ii];
            end else begin
                x += (y>>ii);
                y -= xt;
                z -= atan_table[ii];
            end
        end
    end
end

endmodule
