// --------------------------------------------------------------------------------------------------------
// - NOTE: pipeline stage count = WOI+WOF+3
// -       which means out(result) will appear WOI+WOF+3 cycles after signals appear on the input
// --------------------------------------------------------------------------------------------------------

module pipe_FixedPointDiv #(
	parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  logic clk, rst,
    input  logic [WIIA+WIFA-1:0] dividend,
    input  logic [WIIB+WIFB-1:0] divisor,
    output logic [WOI +WOF -1:0] out,
    output logic overflow
);

localparam WRI = WOI+WIIB > WIIA ? WOI+WIIB : WIIA;
localparam WRF = WOF+WIFB > WIFA ? WOF+WIFB : WIFA;

initial overflow = 1'b0;
initial out = '0;

logic [WOI+WOF-1:0] roundedres='0;
logic rsign = 1'b0;

logic [WRI+WRF-1:0]  divd, divr;
logic sign [WOI+WOF+1];
logic [WRI+WRF-1:0]  acc  [WOI+WOF+1];
logic [WRI+WRF-1:0] divdp [WOI+WOF+1];
logic [WRI+WRF-1:0] divrp [WOI+WOF+1];
logic [WOI+WOF-1:0]  res  [WOI+WOF+1];

// initialize all regs
initial for(int ii=0; ii<=WOI+WOF; ii++) begin
    res  [ii] <= '0;
    divrp[ii] <= '0;
    divdp[ii] <= '0;
    acc  [ii] <= '0;
    sign [ii] <= 1'b0;
end

// convert dividend and divisor to positive number
wire [WIIA+WIFA-1:0] udividend = dividend[WIIA+WIFA-1] ? (~dividend)+1 : dividend;
wire [WIIB+WIFB-1:0]  udivisor =  divisor[WIIB+WIFB-1] ? (~ divisor)+1 : divisor ;

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

// ---------------------------------------------------------------------------------
// 1st pipeline stage: convert dividend and divisor to positive number
// ---------------------------------------------------------------------------------
always @ (posedge clk or posedge rst)
    if(rst) begin
        res[0]   <= '0;
        acc[0]   <= '0;
        divdp[0] <= '0;
        divrp[0] <= '0;
        sign [0] <= 1'b0;
    end else begin
        res[0]   <= '0;
        acc[0]   <= '0;
        divdp[0] <= divd;
        divrp[0] <= divr;
        sign [0] <= dividend[WIIA+WIFA-1] ^ divisor[WIIB+WIFB-1];
    end
    
// ---------------------------------------------------------------------------------
// from 2nd to WOI+WOF+1 pipeline stages: calculate division
// ---------------------------------------------------------------------------------
logic [ WRI+ WRF-1:0] tmp;
always @ (posedge clk or posedge rst)
    if(rst) begin
        for(int ii=0; ii<WOI+WOF; ii++) begin
            res  [ii+1] <= '0;
            divrp[ii+1] <= '0;
            divdp[ii+1] <= '0;
            acc  [ii+1] <= '0;
            sign [ii+1] <= 1'b0;
        end
    end else begin
        for(int ii=0; ii<WOI+WOF; ii++) begin
            res  [ii+1] <= res[ii];
            divdp[ii+1] <= divdp[ii];
            divrp[ii+1] <= divrp[ii];
            sign [ii+1] <= sign [ii];
            if(ii<WOI)
                tmp = acc[ii] + (divrp[ii]<<(WOI-1-ii));
            else
                tmp = acc[ii] + (divrp[ii]>>(1+ii-WOI));
            if( tmp < divdp[ii] ) begin
                acc[ii+1] <= tmp;
                res[ii+1][WOF+WOI-1-ii] <= 1'b1;
            end else begin
                acc[ii+1] <= acc[ii];
                res[ii+1][WOF+WOI-1-ii] <= 1'b0;
            end
        end
    end


// ---------------------------------------------------------------------------------
// next pipeline stage: process round
// ---------------------------------------------------------------------------------
always @ (posedge clk or posedge rst)
    if(rst) begin
        roundedres <= '0;
        rsign      <= 1'b0;
    end else begin
        if( ROUND && ~(&res[WOI+WOF]) && (acc[WOI+WOF]+(divrp[WOI+WOF]>>(WOF))-divdp[WOI+WOF]) < (divdp[WOI+WOF]-acc[WOI+WOF]) )
            roundedres <= res[WOI+WOF] + 1;
        else
            roundedres <= res[WOI+WOF];
        rsign      <= sign[WOI+WOF];
    end


// ---------------------------------------------------------------------------------
// the last pipeline stage: process roof and output
// ---------------------------------------------------------------------------------
always @ (posedge clk or posedge rst)
    if(rst) begin
        overflow = 1'b0;
        out = '0;
    end else begin
        overflow = 1'b0;
        out = roundedres;
        if(rsign) begin
            if(out[WOI+WOF-1]) begin
                if(|out[WOI+WOF-2:0]) overflow = 1'b1;
                out[WOI+WOF-1] = 1'b1;
                out[WOI+WOF-2:0] = '0;
            end else
                out = (~out)+1;
        end else begin
            if(out[WOI+WOF-1]) begin
                overflow = 1'b1;
                out[WOI+WOF-1] = 1'b0;
                out[WOI+WOF-2:0] = '1;
            end
        end
    end

endmodule
