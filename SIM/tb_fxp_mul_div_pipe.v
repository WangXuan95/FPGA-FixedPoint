
//--------------------------------------------------------------------------------------------------------
// Module  : tb_fxp_mul_div_pipe
// Type    : simulation, top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: testbench for fxp_mul_pipe and fxp_div_pipe
//--------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module tb_fxp_mul_div_pipe ();

initial $dumpvars(0, tb_fxp_mul_div_pipe);


localparam WIIA = 12;
localparam WIFA = 20;
localparam WIIB = 14;
localparam WIFB = 18;
localparam WOI  = 24;
localparam WOF  = 17;


reg rstn = 1'b0;
reg clk  = 1'b1;
always #(10000) clk = ~clk;   // 50MHz
initial begin repeat(4) @(posedge clk); rstn<=1'b1; end


reg  [WIIA+WIFA-1:0] ina = 0;
reg  [WIIB+WIFB-1:0] inb = 0;
wire [ WOI+ WOF-1:0] omul;
wire                 omulo;
wire [ WOI+ WOF-1:0] odiv;
wire                 odivo;


fxp_mul_pipe # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fxp_mul_pipe_i (
    .rstn     ( rstn     ),
    .clk      ( clk      ),
    .ina      ( ina      ),
    .inb      ( inb      ),
    .out      ( omul     ),
    .overflow ( omulo    )
);


fxp_div_pipe # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fxp_div_pipe_i (
    .rstn     ( rstn     ),
    .clk      ( clk      ),
    .dividend ( ina      ),
    .divisor  ( inb      ),
    .out      ( odiv     ),
    .overflow ( odivo    )
);


task test;
    input [WIIA+WIFA-1:0] _ina;
    input [WIIB+WIFB-1:0] _inb;
begin
    @ (posedge clk);
    ina <= _ina;
    inb <= _inb;
end
endtask


reg        [31:0] cyclecnt = 0;
always @ (posedge clk)
    if(rstn) begin
        cyclecnt <= cyclecnt + 1;
        $display("cycle%3d   a=%16f   b=%16f   a*b=%16f   omul:%16f %s   a/b=%16f   odiv:%16f %s" , cyclecnt,
            (($signed( ina)*1.0)/(1<<WIFA))                                  ,
            (($signed( inb)*1.0)/(1<<WIFB))                                  ,
            (($signed( ina)*1.0)/(1<<WIFA)) * (($signed(inb)*1.0)/(1<<WIFB)) ,
            (($signed(omul)*1.0)/(1<<WOF ))                                  ,
            omulo ? "(o)" : "   "                                            ,
            (($signed( ina)*1.0)/(1<<WIFA)) / (($signed(inb)*1.0)/(1<<WIFB)) ,
            (($signed(odiv)*1.0)/(1<<WOF ))                                  ,
            odivo ? "(o)" : "   "                                            ,
        );
    end


initial begin
    while(~rstn) @ (posedge clk);
    test('ha09b63b3, 'h1d320443);
    test('h8bb51e68, 'h761cf80d);
    test('h1d322443, 'h00000010);
    test('h6e56e35e, 'h4b45ead0);
    test('h9432d234, 'h1b86880c);
    test('h8bb55e68, 'h00000062);
    test('h2bb004db, 'hbd814b70);
    test('h39ad79bc, 'h6815ad29);
    test('h8bb5ce68, 'h00000042);
    test('h76de4b61, 'hc9809a37);
    test('h8bb5ce68, 'h00000000);
    test('h666f2bff, 'h43b2df79);
    test('h8bb5de68, 'h0000ffff);
    test('h00000000, 'h1d320443);
    test('h8bb5dece, 'h0000fffe);
    test('h00000000, 'h00000000);
    test('h7a164399, 'h1b35e411);
    test('h68d9b80a, 'h45cddeea);
    test('hb6ba294f, 'h4995af1b);
    test('hf6360551, 'h270bdea8);
    test('ha34728f2, 'hd4657725);
    test('h66b53c9c, 'h2211eeff);
    test('hb6b62e8e, 'hc70b04d5);
    test('hd70edf8b, 'h7181eff3);
    test('h6e546855, 'hf8ecca82);
    test('h680a9d44, 'hc699cee3);
    test('hf6c772c2, 'h34ccc642);
    test('ha2ad7ac4, 'h2b77d220);
    test('ha09b63b3, 'h1d320443);
    test('h8bb51e68, 'h761cf80d);
    test('h6e56e35e, 'h4b45ead0);
    test('h9432d234, 'h1b86880c);
    test('h2bb004db, 'hbd814b70);
    test('h39ad79bc, 'h6815ad29);
    test('h76de4b61, 'hc9809a37);
    test('h666f2bff, 'h43b2df79);
    test('h7a164399, 'h1b35e411);
    test('h68d9b80a, 'h45cddeea);
    test('hb6ba294f, 'h4995af1b);
    test('hf6360551, 'h270bdea8);
    test('ha34728f2, 'hd4657725);
    test('h66b53c9c, 'h2211eeff);
    test('hb6b62e8e, 'hc70b04d5);
    test('hd70edf8b, 'h7181eff3);
    test('h6e546855, 'hf8ecca82);
    test('h680a9d44, 'hc699cee3);
    test('hf6c772c2, 'h34ccc642);
    test('ha2ad7ac4, 'h2b77d220);
repeat(WOI+WOF+8)
    test('h00000000, 'h00000000);
    $finish;
end

endmodule
