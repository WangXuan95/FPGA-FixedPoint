module comb_Float32toFixedPoint #(
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter bit ROOF = 1,
    parameter bit ROUND= 1
)(
    input  logic [31:0] float,
    output logic [WOI+WOF-1:0] out,
    output logic upflow, downflow
);

logic overflow, round, sign;
logic [ 7:0] exp;
int expi;
logic [23:0] val;

always @ (*) begin
    {round, overflow, upflow, downflow} = '0;
    {sign, exp, val[22:0]} = float;
    val[23] = 1'b1;
    out = '0;
    if( &exp )
        overflow = 1'b1;
    else if( float[30:0]!=0 ) begin
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
            downflow = 1;
            if(ROOF) begin
                out[WOI+WOF-1]   = 1'b1;
                out[WOI+WOF-2:0] = '0;
            end
        end else begin
            upflow = 1;
            if(ROOF) begin
                out[WOI+WOF-1]   = 1'b0;
                out[WOI+WOF-2:0] = '1;
            end
        end
    end else begin
        if(sign)
            out = (~out) + 1;
    end
end

endmodule
