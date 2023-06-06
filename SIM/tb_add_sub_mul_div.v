
//--------------------------------------------------------------------------------------------------------
// Module  : tb_add_sub_mul_div
// Type    : simulation, top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: testbench for fxp_add, fxp_addsub, fxp_mul and fxp_div
//--------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module tb_add_sub_mul_div ();

initial $dumpvars(0, tb_add_sub_mul_div);


localparam WIIA = 10;
localparam WIFA = 11;
localparam WIIB = 8;
localparam WIFB = 12;
localparam WOI  = 15;
localparam WOF  = 14;

reg  [WIIA+WIFA-1:0] ina = 0;
reg  [WIIB+WIFB-1:0] inb = 0;
wire [  WOI+WOF-1:0] oadd , osub , omul , odiv;
wire                 oaddo, osubo, omulo, odivo;


fxp_add # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fxp_add_i (
    .ina      ( ina      ),
    .inb      ( inb      ),
    .out      ( oadd     ),
    .overflow ( oaddo    )
);


fxp_addsub # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fxp_addsub_i (
    .ina      ( ina      ),
    .inb      ( inb      ),
    .sub      ( 1'b1     ),
    .out      ( osub     ),
    .overflow ( osubo    )
);


fxp_mul # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fxp_mul_i (
    .ina      ( ina      ),
    .inb      ( inb      ),
    .out      ( omul     ),
    .overflow ( omulo    )
);


fxp_div # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fxp_div_i (
    .dividend ( ina      ),
    .divisor  ( inb      ),
    .out      ( odiv     ),
    .overflow ( odivo    )
);


task test;
    input [WIIA+WIFA-1:0] _ina;
    input [WIIB+WIFB-1:0] _inb;
begin
    #10000
    ina = _ina;
    inb = _inb;
    #10000
    $display("    %16f +%16f   SW-result=%16f\n                                         HW-result=%16f %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))+(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(oadd)*1.0)/(1<<WOF ),
                oaddo ? "(o)" : ""
            );
    $display("    %16f -%16f   SW-result=%16f\n                                         HW-result=%16f %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))-(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(osub)*1.0)/(1<<WOF ),
                osubo ? "(o)" : ""
            );
    $display("    %16f *%16f   SW-result=%16f\n                                         HW-result=%16f %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))*(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(omul)*1.0)/(1<<WOF ),
                omulo ? "(o)" : ""
            );
    $display("    %16f /%16f   SW-result=%16f\n                                         HW-result=%16f %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))/(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(odiv)*1.0)/(1<<WOF ),
                odivo ? "(o)" : ""
            );
end
endtask


initial begin
    test('ha09b63b3, 'h00000000);
    test('h00001551, 'h00000001);
    test('h00000000, 'h00000000);
    test('h00000000, 'h1d320443);
    test('ha09b63b3, 'h1d320473);
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
    test('ha2ad7ac4, 'h12345678);
    $finish;
end

endmodule
