module comb_Float32toFixedPoint #(
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROUND= 1
)(
    input  logic [31:0] in,
    output logic [WOI+WOF-1:0] out,
    output logic overflow
);

logic round, sign;
logic [ 7:0] exp;
int expi;
logic [23:0] val;

always @ (*) begin
    {round, overflow} = '0;
    {sign, exp, val[22:0]} = in;
    val[23] = 1'b1;
    out = '0;
    if( &exp )
        overflow = 1'b1;
    else if( in[30:0]!=0 ) begin
        expi = exp-127+WOF;
        for(int ii=23; ii>=0; ii--) begin
            if(val[ii]) begin
                if(expi>=WOI+WOF-1)
                    overflow = 1'b1;
                else if(expi>=0)
                    out[expi] = 1'b1;
                else if(ROUND && expi==-1)
                    round=1;
            end
            expi--;
        end
        if(round) out++;
    end
    if(overflow) begin
        if(sign) begin
            out[WOI+WOF-1]   = 1'b1;
            out[WOI+WOF-2:0] = '0;
        end else begin
            out[WOI+WOF-1]   = 1'b0;
            out[WOI+WOF-2:0] = '1;
        end
    end else begin
        if(sign)
            out = (~out) + 1;
    end
end

endmodule
