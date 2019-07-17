module comb_FixedPointZoom #(
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

logic [WII+WOF-1:0] inr;
logic [WII-1:0] ini;
logic [WOI-1:0] outi;
logic [WOF-1:0] outf;

generate if(WOF<WIF)
    always @ (*) begin
        inr = in[WII+WIF-1:WIF-WOF];
        if(ROUND & in[WIF-WOF-1]) inr++;
    end
else if(WOF==WIF)
    always @ (*) begin
        inr[WII+WOF-1:WOF-WIF] = in;
    end
else
    always @ (*) begin
        inr[WII+WOF-1:WOF-WIF] = in;
        inr[WOF-WIF-1:0] = '0;
    end
endgenerate

generate if(WOI<WII) begin
    always @ (*) begin
        {ini, outf} = inr;
        {upflow, downflow} = '0;
        outi = ini[WOI-1:0];
        if         ( ~ini[WII-1] & |ini[WII-2:WOI-1] ) begin
            upflow = 1;
            if(ROOF) begin
                outi[WOI-1] = 1'b0;
                for(int i=0;i<WOI-1;i++) outi[i] = 1'b1;
                outf = '1;
            end
        end else if(  ini[WII-1] & ~(&ini[WII-2:WOI-1]) ) begin
            downflow = 1;
            if(ROOF) begin
                outi[WOI-1] = 1'b1;
                for(int i=0;i<WOI-1;i++) outi[i] = 1'b0;
                outf = '0;
            end
        end
    end
end else begin
    always @ (*) begin
        {ini, outf} = inr;
        {upflow, downflow} = '0;
        outi[WII-1:0] = ini;
        for(int ii=WII; ii<WOI; ii++) outi[ii] = ini[WII-1];
    end
end endgenerate

assign out = {outi, outf};

endmodule
