// --------------------------------------------------------------------------------------------------------
// - NOTE: pipeline stage count = [WII/2] + WIF + 2, [] means upper int
// -       which means out(result) will appear [WII/2] + WIF + 2 cycles after signals appear on the input
// --------------------------------------------------------------------------------------------------------

module pipe_FixedPointSqrt #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  logic clk, rst,
    input  logic [WII+WIF-1:0] in,
    output logic [WOI+WOF-1:0] out,
    output logic overflow
);

localparam WTI = (WII%2==1) ? WII+1 : WII;
localparam WRI = WTI/2;

int jj;
logic sign [WRI+WIF+1];
logic [WTI+WIF-1:0] inu  [WRI+WIF+1];
logic [WTI+WIF-1:0] resu2tmp;
logic [WTI+WIF-1:0] resu2 [WRI+WIF+1];
logic [WTI+WIF-1:0] resu  [WRI+WIF+1];

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        for(int ii=0; ii<=WRI+WIF; ii++) begin
            sign[ii] <= '0;
            inu[ii] <= '0;
            resu2[ii] <= '0;
            resu[ii] <= '0;
        end
    end else begin
        sign[0] <= in[WII+WIF-1];
        inu[0] <= '0;
        inu[0][WII+WIF-1:0] <= in[WII+WIF-1] ? (~in)+1 : in;
        resu2[0] <= '0;
        resu[0] <= '0;
        for(int ii=WRI-1; ii>=-WIF; ii--) begin
            jj = WRI-1-ii;
            sign[jj+1] <= sign[jj];
            inu [jj+1] <= inu [jj];
            resu[jj+1] <= resu[jj];
            resu2[jj+1]<= resu2[jj];
            resu2tmp = resu2[jj];
            if(ii>=0) resu2tmp += (resu[jj]<<( 1+ii));
            else      resu2tmp += (resu[jj]>>(-1-ii));
            if(2*ii+WIF>=0) resu2tmp += (1<<(2*ii+WIF));
            if(resu2tmp<=inu[jj] && inu[jj]!=0) begin
                resu[jj+1][ii+WIF] <= 1'b1;
                resu2[jj+1] <= resu2tmp;
            end
        end
    end
end

wire  [WRI+WIF  :0] resushort = sign[WRI+WIF] ? (~resu[WRI+WIF][WRI+WIF:0])+1 : resu[WRI+WIF][WRI+WIF:0];
logic [WOI+WOF-1:0] outl;
logic overflowl;

comb_FixedPointZoom # (
    .WII      ( WRI+1          ),
    .WIF      ( WIF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( resushort      ),
    .out      ( outl           ),
    .overflow ( overflowl      )
);

always @ (posedge clk or posedge rst)
    if(rst)
        {overflow,out} = '0;
    else
        {overflow,out} = {overflowl,outl};

endmodule
