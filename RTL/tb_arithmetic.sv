module test_arithmetic();

localparam WIIA = 10;
localparam WIFA = 11;
localparam WIIB = 8;
localparam WIFB = 12;
localparam WOI  = 9;
localparam WOF  = 10;

logic [WIIA+WIFA-1:0] ina='0;
logic [WIIB+WIFB-1:0] inb='0;
logic [WOI+WOF-1:0] oadd, osub, omul, odiv;
logic oadd_overflow, osub_overflow, omul_overflow, odiv_overflow;

comb_FixedPointAdd # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fadd_i (
    .ina      ( ina      ),
    .inb      ( inb      ),
    .out      ( oadd     ),
    .overflow ( oadd_overflow )
);

comb_FixedPointAddSub # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fsub_i (
    .ina      ( ina      ),
    .inb      ( inb      ),
    .sub      ( 1'b1     ),
    .out      ( osub     ),
    .overflow ( osub_overflow )
);

comb_FixedPointMul # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fmul_i (
    .ina      ( ina      ),
    .inb      ( inb      ),
    .out      ( omul     ),
    .overflow ( omul_overflow )
);

comb_FixedPointDiv # (
    .WIIA     ( WIIA     ),
    .WIFA     ( WIFA     ),
    .WIIB     ( WIIB     ),
    .WIFB     ( WIFB     ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) fdiv_i (
    .dividend ( ina      ),
    .divisor  ( inb      ),
    .out      ( odiv     ),
    .overflow ( odiv_overflow )
);

task automatic test(input [WIIA+WIFA-1:0] _ina, input [WIIB+WIFB-1:0] _inb);
    #1
    ina = _ina;
    inb = _inb;
    #1
    $display("    %16f +%16f   SW-result=%16f\n                                         HW-result=%16f   %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))+(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(oadd)*1.0)/(1<<WOF ),
                oadd_overflow ? "overflow!!" : ""
            );
    $display("    %16f -%16f   SW-result=%16f\n                                         HW-result=%16f   %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))-(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(osub)*1.0)/(1<<WOF ),
                osub_overflow ? "overflow!!" : ""
            );
    $display("    %16f *%16f   SW-result=%16f\n                                         HW-result=%16f   %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))*(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(omul)*1.0)/(1<<WOF ),
                omul_overflow ? "overflow!!" : ""
            );
    $display("    %16f /%16f   SW-result=%16f\n                                         HW-result=%16f   %s",
                ( $signed( ina)*1.0)/(1<<WIFA),
                ( $signed( inb)*1.0)/(1<<WIFB),
                (($signed( ina)*1.0)/(1<<WIFA))/(($signed(inb)*1.0)/(1<<WIFB)),
                ( $signed(odiv)*1.0)/(1<<WOF ),
                odiv_overflow ? "overflow!!" : ""
            );
endtask

initial begin
    test('h00000000, 'h00000000);
    test('hf6360551, 'h00000000);
    test('h00000000, 'h1d320443);
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
