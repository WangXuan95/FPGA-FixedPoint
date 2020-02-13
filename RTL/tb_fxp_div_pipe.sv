module tb_fxp_div_pipe();

localparam WIIA = 8;
localparam WIFA = 8;
localparam WIIB = 8;
localparam WIFB = 8;
localparam WOI  = 8;
localparam WOF  = 8;

logic clk=1'b0, rst=1'b1;

logic [WIIA+WIFA-1:0] ina = '0;
logic [WIIB+WIFB-1:0] inb = '0;
logic [ WOI+ WOF-1:0] odiv;
logic overflow;

fxp_div_pipe # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) pipe_fdiv_i (
    .clk                  ,
    .rst                  ,
    .dividend ( ina      ),
    .divisor  ( inb      ),
    .out      ( odiv     ),
    .overflow ( overflow )
);

int cyclecnt = 0;
task automatic test(input [WIIA+WIFA-1:0] _ina, input [WIIB+WIFB-1:0] _inb);
#19 clk = 1'b1;
#1  ina = _ina;
    inb = _inb;
#19 clk = 1'b0;
#1  $display("    cycle %3d        input: %12f /%12f =%12f         output:%12f    %s", 
                    cyclecnt++,
                    ( $signed( ina)*1.0)/(1<<WIFA),
                    ( $signed( inb)*1.0)/(1<<WIFB),
                    (($signed( ina)*1.0)/(1<<WIFA))/(($signed(inb)*1.0)/(1<<WIFB)),
                    ( $signed(odiv)*1.0)/(1<<WOF ),
                    overflow ? "overflow!!" : ""
                );
endtask

initial begin
#4  rst = 1'b0;
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
end

endmodule
