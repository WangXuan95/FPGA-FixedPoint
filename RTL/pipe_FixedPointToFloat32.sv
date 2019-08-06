// --------------------------------------------------------------------------------------------------------
// - NOTE: pipeline stage count = WII + WIF + 2
// -       which means out(result) will appear WII+WIF+2 cycles after signals appear on the input
// --------------------------------------------------------------------------------------------------------

module pipe_FixedPointToFloat32 #(
    parameter WII = 8,
    parameter WIF = 8
)(
    input  logic clk, rst,
    input  logic [WII+WIF-1:0] in,
    output logic [31:0] out
);

logic              sign [WII+WIF+1];
logic        [9:0] exp  [WII+WIF+1];
logic [WII+WIF-1:0] inu [WII+WIF+1];

logic [23:0] vall;
logic [23:0] valo;
logic [ 7:0] expo;
logic signo;

assign out = {signo, expo, valo[22:0]};

initial
    for(int ii=WII+WIF; ii>=0; ii--) begin
        sign[ii] = '0;
        exp[ii]  = '0;
        inu[ii]  = '0;
    end

always @ (posedge clk or posedge rst)
    if(rst) begin
        for(int ii=WII+WIF; ii>=0; ii--) begin
            sign[ii] <= '0;
            exp[ii]  <= '0;
            inu[ii]  <= '0;
        end
    end else begin
        sign[WII+WIF] <= in[WII+WIF-1];
        exp [WII+WIF] <= WII+127-1;
        inu[WII+WIF]  <= in[WII+WIF-1] ? (~in)+1 : in;
        for(int ii=WII+WIF-1; ii>=0; ii--) begin
            sign[ii] <= sign[ii+1];
            if(inu[ii+1][WII+WIF-1]) begin
                exp[ii] <= exp[ii+1];
                inu[ii] <= inu[ii+1];
            end else begin
                if(exp[ii+1]!=0)
                    exp[ii] <= exp[ii+1] - 1;
                else
                    exp[ii] <= exp[ii+1];
                inu[ii] <=(inu[ii+1] << 1);
            end
        end
    end
    
generate if(23>WII+WIF-1) begin
    always @ (*) begin
        vall = '0;
        vall[23:23-(WII+WIF-1)] = inu[0];
    end
end else begin
    assign vall = inu[0][WII+WIF-1:WII+WIF-1-23];
end endgenerate

initial {signo, expo, valo} = '0;

always @ (posedge clk or posedge rst)
    if(rst) begin
        {signo, expo, valo} = '0;
    end else begin
        signo = sign[0];
        if(exp[0]>=10'd255) begin
            expo = 8'd255;
            valo = '1;
        end else if(exp[0]==10'd0 || ~vall[23]) begin
            expo = 8'd0;
            valo = '0;
        end else begin
            expo = exp[0][7:0];
            valo = vall;
        end
    end
    
endmodule
