module comb_FixedPointToFloat32 #(
    parameter WII = 8,
    parameter WIF = 8
)(
    input  logic [WII+WIF-1:0] in,
    output logic [31:0] out
);

logic flag;
logic signed [9:0] expz, ii, jj;
logic [ 7:0] expt;
logic [22:0] tail;
wire  sign = in[WII+WIF-1];
wire  [WII+WIF-1:0] inu = sign ? (~in)+1 : in;

always @ (*) begin
    tail = '0;
    flag = 1'b0;
    ii = 22;
    expz = '0;
    for(jj=WII+WIF-1; jj>=0; jj--) begin
        if(flag && ii>=0)
            tail[ii--] = inu[jj];
        if(inu[jj]) begin
            if(~flag) expz = jj - WIF + 127;
            flag = 1'b1;
        end
    end

    if(expz<$signed(10'd255))
        expt = (inu==0) ? '0 : expz[7:0];
    else begin
        expt = 8'd254;
        tail = '1;
    end
end

assign out = {sign, expt, tail};

endmodule
