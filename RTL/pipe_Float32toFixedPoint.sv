// --------------------------------------------------------------------------------------------------------
// - NOTE: pipeline stage count = WOI + WOF + 3
// -       which means out(result) will appear WOI+WOF+3 cycles after signals appear on the input
// --------------------------------------------------------------------------------------------------------

module pipe_Float32toFixedPoint #(
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  logic clk, rst,
    input  logic [31:0] in,
    output logic [WOI+WOF-1:0] out,
    output logic overflow
);
// ------------------------------------------------------------------------------------
// input comb logic
// ------------------------------------------------------------------------------------
logic sign;
logic [ 7:0] exp;
logic [23:0] val;

assign {sign,exp,val[22:0]} = in;
assign val[23] = |exp;

// ------------------------------------------------------------------------------------
// pipeline stage1
// ------------------------------------------------------------------------------------
logic signinit=1'b0, roundinit=1'b0;
logic signed [31:0] expinit = '0;
logic [WOI+WOF-1:0] outinit = '0;

generate if(WOI+WOF-1>=23) begin
    always @ (posedge clk or posedge rst)
        if(rst) begin
            outinit = '0;
            roundinit = 1'b0;
        end else begin
            outinit = '0;
            outinit[WOI+WOF-1:WOI+WOF-1-23] = val;
            roundinit = 1'b0;
        end
end else begin
    always @ (posedge clk or posedge rst)
        if(rst) begin
            outinit = '0;
            roundinit = 1'b0;
        end else begin
            outinit = val[23:23-(WOI+WOF-1)];
            roundinit = ( ROUND && val[23-(WOI+WOF-1)-1] );
        end
end endgenerate

always @ (posedge clk or posedge rst)
    if(rst) begin
        signinit = 1'b0;
        expinit  = 0;
    end else begin
        signinit = sign;
        expinit  = exp - (WOI-1) - 127;
        if(exp==8'd255 || expinit>0 )
            expinit = 0;
    end
        
// ------------------------------------------------------------------------------------
// next pipeline stages
// ------------------------------------------------------------------------------------
logic signs [WOI+WOF+1];
logic rounds[WOI+WOF+1];
logic [31:0] exps[WOI+WOF+1];
logic [WOI+WOF-1:0] outs[WOI+WOF+1];

always @ (posedge clk or posedge rst)
    if(rst) begin
        for(int ii=0; ii<WOI+WOF+1; ii++) begin
            signs[ii]  = '0;
            rounds[ii] = '0;
            exps[ii]   = '0;
            outs[ii]   = '0;
        end
    end else begin
        signs[WOI+WOF] = signinit;
        rounds[WOI+WOF] = roundinit;
        exps[WOI+WOF] = expinit;
        outs[WOI+WOF] = outinit;
        for(int ii=0; ii<WOI+WOF; ii++) begin
            signs[ii] = signs[ii+1];
            if(exps[ii+1]!=0) begin
                {outs[ii], rounds[ii]} = {       1'b0,   outs[ii+1] };
                exps[ii] = exps[ii+1] + 1;
            end else begin
                {outs[ii], rounds[ii]} = { outs[ii+1], rounds[ii+1] };
                exps[ii] = exps[ii+1];
            end
        end
    end
    
// ------------------------------------------------------------------------------------
// last 2nd pipeline stage
// ------------------------------------------------------------------------------------
logic signl = 1'b0;
logic [WOI+WOF-1:0] outl = '0;
always @ (posedge clk or posedge rst)
    if(rst) begin
        outl = '0;
        signl = 1'b0;
    end else begin
        outl = outs[0];
        if(ROUND & rounds[0] & ~(&outl))
            outl++;
        if(signs[0]) begin
            signl = (outl!=0);
            outl  = (~outl) + 1;
        end else
            signl = 1'b0;
    end

// ------------------------------------------------------------------------------------
// last 1st pipeline stage: overflow control
// ------------------------------------------------------------------------------------
initial out = '0;
initial overflow = 1'b0;
always @ (posedge clk)
    if(rst) begin
        out = '0;
        overflow = 1'b0;
    end else begin
        out = outl;
        overflow = 1'b0;
        if(signl) begin
            if(~outl[WOI+WOF-1]) begin
                out[WOI+WOF-1] = 1'b1;
                out[WOI+WOF-2:0] = '0;
                overflow = 1'b1;
            end
        end else begin
            if(outl[WOI+WOF-1]) begin
                out[WOI+WOF-1] = 1'b0;
                out[WOI+WOF-2:0] = '1;
                overflow = 1'b1;
            end
        end
    end

endmodule
