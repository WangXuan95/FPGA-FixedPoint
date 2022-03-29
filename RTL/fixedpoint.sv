
//--------------------------------------------------------------------------------------------------------
// Modules : fxp_zoom, fxp_add, fxp_addsub, fxp_mul, fxp_mul_pipe, fxp_div, fxp_div_pipe, fxp_sqrt, fxp_sqrt_pipe, fxp2float, fxp2float_pipe, float2fxp, float2fxp_pipe
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: fixed-point library
//--------------------------------------------------------------------------------------------------------






//--------------------------------------------------------------------------------------------------------
// Module  : fxp_zoom
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: bit width conversion for fixed-point
//           combinational logic
//--------------------------------------------------------------------------------------------------------

module fxp_zoom #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WII+WIF-1:0] in,
    output wire [WOI+WOF-1:0] out,
    output reg                overflow
);

initial overflow = '0;

reg [WII+WOF-1:0] inr = '0;
reg [WII-1:0] ini = '0;
reg [WOI-1:0] outi = '0;
reg [WOF-1:0] outf = '0;

generate if(WOF<WIF) begin
    if(ROUND==0) begin
        always @ (*) inr = in[WII+WIF-1:WIF-WOF];
    end else if(WII+WOF>=2) begin
        always @ (*) begin
            inr = in[WII+WIF-1:WIF-WOF];
            if(in[WIF-WOF-1] & ~(~inr[WII+WOF-1] & (&inr[WII+WOF-2:0]))) inr++;
        end
    end else begin
        always @ (*) begin
            inr = in[WII+WIF-1:WIF-WOF];
            if(in[WIF-WOF-1] & inr[WII+WOF-1]) inr++;
        end
    end
end else if(WOF==WIF) begin
    always @ (*) inr[WII+WOF-1:WOF-WIF] = in;
end else begin
    always @ (*) begin
        inr[WII+WOF-1:WOF-WIF] = in;
        inr[WOF-WIF-1:0] = '0;
    end
end endgenerate


generate if(WOI<WII) begin
    always @ (*) begin
        {ini, outf} = inr;
        if         ( ~ini[WII-1] & |ini[WII-2:WOI-1] ) begin
            overflow = 1'b1;
            outi = '1;
            outi[WOI-1] = 1'b0;
            outf = '1;
        end else if(  ini[WII-1] & ~(&ini[WII-2:WOI-1]) ) begin
            overflow = 1'b1;
            outi = '0;
            outi[WOI-1] = 1'b1;
            outf = '0;
        end else begin
            overflow = 1'b0;
            outi = ini[WOI-1:0];
        end
    end
end else begin
    always @ (*) begin
        {ini, outf} = inr;
        overflow = 1'b0;
        outi = ini[WII-1] ? '1 : '0;
        outi[WII-1:0] = ini;
    end
end endgenerate

assign out = {outi, outf};

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_add
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: addition
//           combinational logic
//--------------------------------------------------------------------------------------------------------

module fxp_add # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WIIA+WIFA-1:0] ina,
    input  wire [WIIB+WIFB-1:0] inb,
    output wire [WOI +WOF -1:0] out,
    output wire                 overflow
);

localparam WII = WIIA>WIIB ? WIIA : WIIB;
localparam WIF = WIFA>WIFB ? WIFA : WIFB;
localparam WRI = WII + 1;
localparam WRF = WIF;

wire [WII+WIF-1:0] inaz, inbz;

wire signed [WRI+WRF-1:0] res = $signed(inaz) + $signed(inbz);

fxp_zoom # (
    .WII      ( WIIA     ),
    .WIF      ( WIFA     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROUND    ( 0        )
) ina_zoom (
    .in       ( ina      ),
    .out      ( inaz     ),
    .overflow (          )
);

fxp_zoom # (
    .WII      ( WIIB     ),
    .WIF      ( WIFB     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROUND    ( 0        )
) inb_zoom (
    .in       ( inb      ),
    .out      ( inbz     ),
    .overflow (          )
);

fxp_zoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( out            ),
    .overflow ( overflow       )
);

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_addsub
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: addition and subtraction
//           combinational logic
//--------------------------------------------------------------------------------------------------------

module fxp_addsub # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WIIA+WIFA-1:0] ina,
    input  wire [WIIB+WIFB-1:0] inb,
    input  wire                 sub, // 0=add, 1=sub
    output wire [WOI +WOF -1:0] out,
    output wire                 overflow
);

localparam WIIBE = WIIB + 1;
localparam   WII = WIIA>WIIBE ? WIIA : WIIBE;
localparam   WIF = WIFA>WIFB  ? WIFA : WIFB;
localparam   WRI = WII + 1;
localparam   WRF = WIF;

wire [WIIBE+WIFB-1:0] inbe;
wire [   WII+WIF-1:0] inaz, inbz;
wire [WIIBE+WIFB-1:0] inbv = sub ? (~inbe)+(WIIBE+WIFB)'(1) : inbe;
wire signed [WRI+WRF-1:0] res = $signed(inaz) + $signed(inbz);

fxp_zoom # (
    .WII      ( WIIB     ),
    .WIF      ( WIFB     ),
    .WOI      ( WIIBE    ),
    .WOF      ( WIFB     ),
    .ROUND    ( 0        )
) inb_extend (
    .in       ( inb      ),
    .out      ( inbe     ),
    .overflow (          )
);

fxp_zoom # (
    .WII      ( WIIA     ),
    .WIF      ( WIFA     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROUND    ( 0        )
) ina_zoom (
    .in       ( ina      ),
    .out      ( inaz     ),
    .overflow (          )
);

fxp_zoom # (
    .WII      ( WIIBE    ),
    .WIF      ( WIFB     ),
    .WOI      ( WII      ),
    .WOF      ( WIF      ),
    .ROUND    ( 0        )
) inb_zoom (
    .in       ( inbv     ),
    .out      ( inbz     ),
    .overflow (          )
);

fxp_zoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( out            ),
    .overflow ( overflow       )
);

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_mul
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: multiplication
//           combinational logic
//--------------------------------------------------------------------------------------------------------

module fxp_mul # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WIIA+WIFA-1:0] ina,
    input  wire [WIIB+WIFB-1:0] inb,
    output wire [WOI +WOF -1:0] out,
    output wire                 overflow
);

localparam WRI = WIIA + WIIB;
localparam WRF = WIFA + WIFB;

wire signed [WRI+WRF-1:0] res = $signed(ina) * $signed(inb);

fxp_zoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( out            ),
    .overflow ( overflow       )
);

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_mul_pipe
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: multiplication
//           pipeline stage = 2
//--------------------------------------------------------------------------------------------------------

module fxp_mul_pipe # (
    parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire                 rstn,
    input  wire                 clk,
    input  wire [WIIA+WIFA-1:0] ina,
    input  wire [WIIB+WIFB-1:0] inb,
    output reg  [WOI +WOF -1:0] out,
    output reg                  overflow
);

initial {out, overflow} = '0;

localparam WRI = WIIA + WIIB;
localparam WRF = WIFA + WIFB;

wire [WOI +WOF -1:0] outc;
wire                 overflowc;

reg signed [WRI+WRF-1:0] res = '0;

always @ (posedge clk or negedge rstn)
    if(~rstn)
        res <= '0;
    else
        res <= $signed(ina) * $signed(inb);

fxp_zoom # (
    .WII      ( WRI            ),
    .WIF      ( WRF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( $unsigned(res) ),
    .out      ( outc           ),
    .overflow ( overflowc      )
);

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        out      <= '0;
        overflow <= 1'b0;
    end else begin
        out      <= outc;
        overflow <= overflowc;
    end

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_div
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: division
//           combinational logic
//           not recommended due to the long critical path
//--------------------------------------------------------------------------------------------------------

module fxp_div #(
	parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WIIA+WIFA-1:0] dividend,
    input  wire [WIIB+WIFB-1:0] divisor,
    output reg  [WOI +WOF -1:0] out,
    output reg                  overflow
);

initial {out, overflow} = '0;

localparam WRI = WOI+WIIB > WIIA ? WOI+WIIB : WIIA;
localparam WRF = WOF+WIFB > WIFA ? WOF+WIFB : WIFA;

reg                  sign = 1'b0;
reg  [WIIA+WIFA-1:0] udividend = '0;
reg  [WIIB+WIFB-1:0]  udivisor = '0;
reg  [ WRI+ WRF-1:0] acc='0, acct='0;
wire [ WRI+ WRF-1:0] divd, divr;

always @ (*) begin  // convert dividend and divisor to positive number
    sign      = dividend[WIIA+WIFA-1] ^ divisor[WIIB+WIFB-1];
    udividend = dividend[WIIA+WIFA-1] ? (~dividend)+(WIIA+WIFA)'(1) : dividend;
    udivisor  =  divisor[WIIB+WIFB-1] ? (~ divisor)+(WIIB+WIFB)'(1) : divisor ;
end

fxp_zoom # (
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

fxp_zoom # (
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

always @ (*) begin
    acc = '0;
    for(int shamt=WOI-1; shamt>=-WOF; shamt--) begin
        if(shamt>=0)
            acct = acc + (divr<<shamt);
        else
            acct = acc + (divr>>(-shamt));
        if( acct <= divd ) begin
            acc = acct;
            out[WOF+shamt] = 1'b1;
        end else
            out[WOF+shamt] = 1'b0;
    end
    
    if(ROUND && ~(&out)) begin
        acct = acc+(divr>>(WOF));
        if(acct-divd<divd-acc)
            out++;
    end
    
    overflow = 1'b0;
    if(sign) begin
        if(out[WOI+WOF-1]) begin
            if(|out[WOI+WOF-2:0]) overflow = 1'b1;
            out[WOI+WOF-1] = 1'b1;
            out[WOI+WOF-2:0] = '0;
        end else begin
            out = (~out) + (WOI+WOF)'(1);
        end
    end else begin
        if(out[WOI+WOF-1]) begin
            overflow = 1'b1;
            out[WOI+WOF-1] = 1'b0;
            out[WOI+WOF-2:0] = '1;
        end
    end
end

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_div_pipe
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: division
//           pipeline stage = WOI+WOF+3
//--------------------------------------------------------------------------------------------------------

module fxp_div_pipe #(
	parameter WIIA = 8,
    parameter WIFA = 8,
    parameter WIIB = 8,
    parameter WIFB = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire                 rstn,
    input  wire                 clk,
    input  wire [WIIA+WIFA-1:0] dividend,
    input  wire [WIIB+WIFB-1:0] divisor,
    output reg  [WOI +WOF -1:0] out,
    output reg                  overflow
);

initial {out, overflow} = '0;

localparam WRI = WOI+WIIB > WIIA ? WOI+WIIB : WIIA;
localparam WRF = WOF+WIFB > WIFA ? WOF+WIFB : WIFA;

wire [WRI+WRF-1:0]  divd, divr;
reg  [WOI+WOF-1:0] roundedres = '0;
reg                rsign = 1'b0;
reg                 sign [WOI+WOF+1];
reg  [WRI+WRF-1:0]  acc  [WOI+WOF+1];
reg  [WRI+WRF-1:0] divdp [WOI+WOF+1];
reg  [WRI+WRF-1:0] divrp [WOI+WOF+1];
reg  [WOI+WOF-1:0]  res  [WOI+WOF+1];

// initialize all regs
initial for(int ii=0; ii<=WOI+WOF; ii++) begin
            res  [ii] = '0;
            divrp[ii] = '0;
            divdp[ii] = '0;
            acc  [ii] = '0;
            sign [ii] = 1'b0;
        end

// convert dividend and divisor to positive number
wire [WIIA+WIFA-1:0] udividend = dividend[WIIA+WIFA-1] ? (~dividend)+(WIIA+WIFA)'(1) : dividend;
wire [WIIB+WIFB-1:0]  udivisor =  divisor[WIIB+WIFB-1] ? (~ divisor)+(WIIB+WIFB)'(1) : divisor ;

fxp_zoom # (
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

fxp_zoom # (
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

// 1st pipeline stage: convert dividend and divisor to positive number
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
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

// from 2nd to WOI+WOF+1 pipeline stages: calculate division
reg [WRI+ WRF-1:0] tmp = 0;
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        tmp = 0;
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

// next pipeline stage: process round
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        roundedres <= '0;
        rsign      <= 1'b0;
    end else begin
        if( ROUND && ~(&res[WOI+WOF]) && (acc[WOI+WOF]+(divrp[WOI+WOF]>>(WOF))-divdp[WOI+WOF]) < (divdp[WOI+WOF]-acc[WOI+WOF]) )
            roundedres <= res[WOI+WOF] + (WOI+WOF)'(1);
        else
            roundedres <= res[WOI+WOF];
        rsign      <= sign[WOI+WOF];
    end

// the last pipeline stage: process roof and output
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        overflow <= 1'b0;
        out <= '0;
    end else begin
        overflow <= 1'b0;
        if(rsign) begin
            if(roundedres[WOI+WOF-1]) begin
                if(|roundedres[WOI+WOF-2:0]) overflow <= 1'b1;
                out[WOI+WOF-1] <= 1'b1;
                out[WOI+WOF-2:0] <= '0;
            end else
                out <= (~roundedres)+(WOI+WOF)'(1);
        end else begin
            if(roundedres[WOI+WOF-1]) begin
                overflow <= 1'b1;
                out[WOI+WOF-1] <= 1'b0;
                out[WOI+WOF-2:0] <= '1;
            end else
                out <= roundedres;
        end
    end

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_sqrt
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: square root
//           combinational logic
//           not recommended due to the long critical path
//--------------------------------------------------------------------------------------------------------

module fxp_sqrt #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire [WII+WIF-1:0] in,
    output wire [WOI+WOF-1:0] out,
    output wire               overflow
);

localparam WTI = (WII%2==1) ? WII+1 : WII;
localparam WRI = WTI/2;

wire  sign = in[WII+WIF-1];
reg  [WTI+WIF-1:0] inu = '0;
reg  [WTI+WIF-1:0] resu2 = '0, resu2tmp = '0;
reg  [WTI+WIF-1:0] resu = '0;
wire [WRI+WIF  :0] resushort = sign ? (~resu[WRI+WIF:0])+(WRI+WIF+1)'(1) : resu[WRI+WIF:0];

always @ (*) begin
    inu = '0;
    inu[WII+WIF-1:0] = sign ? (~in)+(WII+WIF)'(1) : in;
end

always @ (*) begin
    {resu2,resu} = '0;
    for(int ii=WRI-1; ii>=-WIF; ii--) begin
        resu2tmp = resu2;
        if(ii>=0) resu2tmp += (resu<<( 1+ii));
        else      resu2tmp += (resu>>(-1-ii));
        if(2*ii+WIF>=0) resu2tmp += ( (WTI+WIF)'(1) << (2*ii+WIF) );
        if(resu2tmp<=inu && inu!=0) begin
            resu[ii+WIF] = 1'b1;
            resu2 = resu2tmp;
        end
    end
end

fxp_zoom # (
    .WII      ( WRI+1          ),
    .WIF      ( WIF            ),
    .WOI      ( WOI            ),
    .WOF      ( WOF            ),
    .ROUND    ( ROUND          )
) res_zoom (
    .in       ( resushort      ),
    .out      ( out            ),
    .overflow ( overflow       )
);

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp_sqrt_pipe
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: square root
//           pipeline stage = [WII/2]+WIF+2, [] means upper int
//--------------------------------------------------------------------------------------------------------

module fxp_sqrt_pipe #(
    parameter WII  = 8,
    parameter WIF  = 8,
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire               rstn,
    input  wire               clk,
    input  wire [WII+WIF-1:0] in,
    output reg  [WOI+WOF-1:0] out,
    output reg                overflow
);

initial {overflow,out} = '0;

localparam WTI = (WII%2==1) ? WII+1 : WII;
localparam WRI = WTI/2;

reg               sign [WRI+WIF+1];
reg [WTI+WIF-1:0] inu  [WRI+WIF+1];
reg [WTI+WIF-1:0] resu2 [WRI+WIF+1];
reg [WTI+WIF-1:0] resu  [WRI+WIF+1];

initial for(int ii=0; ii<=WRI+WIF; ii++) begin
            sign[ii] = '0;
            inu[ii]  = '0;
            resu2[ii]= '0;
            resu[ii] = '0;
        end

int jj = 0;
reg [WTI+WIF-1:0] resu2tmp = '0;

always @ (posedge clk or negedge rstn) begin
    if(~rstn) begin
        for(int ii=0; ii<=WRI+WIF; ii++) begin
            sign[ii] <= '0;
            inu[ii]  <= '0;
            resu2[ii]<= '0;
            resu[ii] <= '0;
        end
    end else begin
        sign[0] <= in[WII+WIF-1];
        inu[0] <= '0;
        inu[0][WII+WIF-1:0] <= in[WII+WIF-1] ? (~in)+(WII+WIF)'(1) : in;
        resu2[0] <= '0;
        resu[0] <= '0;
        for(int ii=WRI-1; ii>=-WIF; ii--) begin
            jj = WRI-1-ii;
            sign[jj+1] <= sign[jj];
            inu [jj+1] <= inu [jj];
            resu[jj+1] <= resu[jj];
            resu2[jj+1]<= resu2[jj];
            resu2tmp = resu2[jj];
            if(ii>=0)
                resu2tmp += (resu[jj]<<( 1+ii));
            else
                resu2tmp += (resu[jj]>>(-1-ii));
            if(2*ii+WIF>=0)
                resu2tmp += ( (WTI+WIF)'(1) << (2*ii+WIF) );
            if(resu2tmp<=inu[jj] && inu[jj]!=0) begin
                resu[jj+1][ii+WIF] <= 1'b1;
                resu2[jj+1] <= resu2tmp;
            end
        end
    end
end

wire [WRI+WIF  :0] resushort = sign[WRI+WIF] ? (~resu[WRI+WIF][WRI+WIF:0])+(WRI+WIF+1)'(1) : resu[WRI+WIF][WRI+WIF:0];
wire [WOI+WOF-1:0] outl;
wire               overflowl;

fxp_zoom # (
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

always @ (posedge clk or negedge rstn)
    if(~rstn)
        {overflow,out} <= '0;
    else
        {overflow,out} <= {overflowl,outl};

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : fxp2float
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: convert fixed-point to float-point (IEEE754 single precision)
//           combinational logic
//           not recommended due to the long critical path
//--------------------------------------------------------------------------------------------------------

module fxp2float #(
    parameter WII = 8,
    parameter WIF = 8
)(
    input  wire [WII+WIF-1:0] in,
    output wire        [31:0] out
);

reg              flag = '0;
reg signed [9:0] expz = '0, ii = '0;
reg       [ 7:0] expt = '0;
reg       [22:0] tail = '0;

wire  sign = in[WII+WIF-1];
wire  [WII+WIF-1:0] inu = sign ? (~in)+(WII+WIF)'(1) : in;

always @ (*) begin
    tail = '0;
    flag = 1'b0;
    ii = 10'd22;
    expz = '0;
    
    for(int jj=(10)'(WII+WIF-1); jj>=0; jj--) begin
        if(flag && ii>=0) begin
            tail[ii] = inu[jj];
            ii--;
        end
        if(inu[jj]) begin
            if(~flag) expz = (10)'(jj+127-WIF);
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







//--------------------------------------------------------------------------------------------------------
// Module  : fxp2float_pipe
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: convert fixed-point to float-point (IEEE754 single precision)
//           pipeline stage = WII+WIF+2
//--------------------------------------------------------------------------------------------------------

module fxp2float_pipe #(
    parameter WII = 8,
    parameter WIF = 8
)(
    input  wire               rstn,
    input  wire               clk,
    input  wire [WII+WIF-1:0] in,
    output wire        [31:0] out
);

reg              sign [WII+WIF+1];
reg         [9:0] exp [WII+WIF+1];
reg [WII+WIF-1:0] inu [WII+WIF+1];

reg [23:0] vall = '0;
reg [23:0] valo = '0;
reg [ 7:0] expo = '0;
reg       signo = '0;

assign out = {signo, expo, valo[22:0]};

initial for(int ii=WII+WIF; ii>=0; ii--) begin
            sign[ii] = '0;
            exp[ii]  = '0;
            inu[ii]  = '0;
        end

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        for(int ii=WII+WIF; ii>=0; ii--) begin
            sign[ii] <= '0;
            exp[ii]  <= '0;
            inu[ii]  <= '0;
        end
    end else begin
        sign[WII+WIF] <= in[WII+WIF-1];
        exp [WII+WIF] <= (10)'(WII+127-1);
        inu[WII+WIF]  <= in[WII+WIF-1] ? (~in)+(WII+WIF)'(1) : in;
        for(int ii=WII+WIF-1; ii>=0; ii--) begin
            sign[ii] <= sign[ii+1];
            if(inu[ii+1][WII+WIF-1]) begin
                exp[ii] <= exp[ii+1];
                inu[ii] <= inu[ii+1];
            end else begin
                if(exp[ii+1]!=0)
                    exp[ii] <= exp[ii+1] - 10'd1;
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
    always @ (*) vall = inu[0][WII+WIF-1:WII+WIF-1-23];
end endgenerate

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        {signo, expo, valo} <= '0;
    end else begin
        signo <= sign[0];
        if(exp[0]>=10'd255) begin
            expo <= 8'd255;
            valo <= '1;
        end else if(exp[0]==10'd0 || ~vall[23]) begin
            expo <= 8'd0;
            valo <= '0;
        end else begin
            expo <= exp[0][7:0];
            valo <= vall;
        end
    end
    
endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : float2fxp
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: convert float-point (IEEE754 single precision) to fixed-point
//           combinational logic
//           not recommended due to the long critical path
//--------------------------------------------------------------------------------------------------------

module float2fxp #(
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire        [31:0] in,
    output reg  [WOI+WOF-1:0] out,
    output reg                overflow
);

initial {out, overflow} = '0;

reg        round = '0;
reg        sign = '0;
reg [ 7:0] exp2 = '0;
reg [23:0] val = '0;
reg signed [31:0] expi = '0;

always @ (*) begin
    {round, overflow} = '0;
    {sign, exp2, val[22:0]} = in;
    val[23] = 1'b1;
    out = '0;
    expi = exp2-127+WOF;
    if( &exp2 )
        overflow = 1'b1;
    else if( in[30:0]!=0 ) begin
        for(int ii=23; ii>=0; ii--) begin
            if(val[ii]) begin
                if(expi>=WOI+WOF-1)
                    overflow = 1'b1;
                else if(expi>=0)
                    out[expi] = 1'b1;
                else if(ROUND && expi==-1)
                    round=1'b1;
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
            out = (~out) + (WOI+WOF)'(1);
    end
end

endmodule







//--------------------------------------------------------------------------------------------------------
// Module  : float2fxp_pipe
// Type    : synthesizable
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: convert float-point (IEEE754 single precision) to fixed-point
//           pipeline stage = WOI+WOF+4
//--------------------------------------------------------------------------------------------------------

module float2fxp_pipe #(
    parameter WOI  = 8,
    parameter WOF  = 8,
    parameter ROUND= 1
)(
    input  wire               rstn,
    input  wire               clk,
    input  wire        [31:0] in,
    output reg  [WOI+WOF-1:0] out,
    output reg                overflow
);

initial {out, overflow} = '0;

// input comb
wire        sign;
wire [ 7:0] exp;
wire [23:0] val;

assign {sign,exp,val[22:0]} = in;
assign val[23] = |exp;

// pipeline stage1
reg signinit=1'b0, roundinit=1'b0;
reg signed [31:0] expinit = '0;
reg [WOI+WOF-1:0] outinit = '0;

generate if(WOI+WOF-1>=23) begin
    always @ (posedge clk or negedge rstn)
        if(~rstn) begin
            outinit <= '0;
            roundinit <= 1'b0;
        end else begin
            outinit <= '0;
            outinit[WOI+WOF-1:WOI+WOF-1-23] <= val;
            roundinit <= 1'b0;
        end
end else begin
    always @ (posedge clk or negedge rstn)
        if(~rstn) begin
            outinit <= '0;
            roundinit <= 1'b0;
        end else begin
            outinit <= val[23:23-(WOI+WOF-1)];
            roundinit <= ( ROUND && val[23-(WOI+WOF-1)-1] );
        end
end endgenerate

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        signinit <= 1'b0;
        expinit  <= 0;
    end else begin
        signinit <= sign;
        if( exp==8'd255 || {24'd0,exp}>WOI+126 )
            expinit <= 0;
        else
            expinit <= {24'd0,exp} - (WOI-1) - 127;
    end

// next pipeline stages
reg              signs [WOI+WOF+1];
reg             rounds [WOI+WOF+1];
reg [31:0]        exps [WOI+WOF+1];
reg [WOI+WOF-1:0] outs [WOI+WOF+1];

always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        for(int ii=0; ii<WOI+WOF+1; ii++) begin
            signs[ii]  <= '0;
            rounds[ii] <= '0;
            exps[ii]   <= '0;
            outs[ii]   <= '0;
        end
    end else begin
        for(int ii=0; ii<WOI+WOF; ii++) begin
            signs[ii] <= signs[ii+1];
            if(exps[ii+1]!=0) begin
                {outs[ii], rounds[ii]} <= {       1'b0,   outs[ii+1] };
                exps[ii] <= exps[ii+1] + 1;
            end else begin
                {outs[ii], rounds[ii]} <= { outs[ii+1], rounds[ii+1] };
                exps[ii] <= exps[ii+1];
            end
        end
        signs[WOI+WOF] <= signinit;
        rounds[WOI+WOF] <= roundinit;
        exps[WOI+WOF] <= expinit;
        outs[WOI+WOF] <= outinit;
    end

// last 2nd pipeline stage
reg               signl = 1'b0;
reg [WOI+WOF-1:0] outt = '0;
reg [WOI+WOF-1:0] outl = '0;
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        outt = '0;
        outl <= '0;
        signl <= 1'b0;
    end else begin
        outt = outs[0];
        if(ROUND & rounds[0] & ~(&outt))
            outt++;
        if(signs[0]) begin
            signl <= (outt!=0);
            outt  = (~outt) + (WOI+WOF)'(1);
        end else
            signl <= 1'b0;
        outl <= outt;
    end

// last 1st pipeline stage: overflow control
always @ (posedge clk or negedge rstn)
    if(~rstn) begin
        out <= '0;
        overflow <= 1'b0;
    end else begin
        out <= outl;
        overflow <= 1'b0;
        if(signl) begin
            if(~outl[WOI+WOF-1]) begin
                out[WOI+WOF-1] <= 1'b1;
                out[WOI+WOF-2:0] <= '0;
                overflow <= 1'b1;
            end
        end else begin
            if(outl[WOI+WOF-1]) begin
                out[WOI+WOF-1] <= 1'b0;
                out[WOI+WOF-2:0] <= '1;
                overflow <= 1'b1;
            end
        end
    end

endmodule
