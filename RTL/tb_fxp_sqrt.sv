module tb_fxp_sqrt();

localparam WII  = 13;
localparam WIF  = 13;
localparam WOI  = 7;
localparam WOF  = 13;

logic [WII+WIF-1:0] in;
logic [WOI+WOF-1:0] osqrt;
logic overflow;

fxp_sqrt #(
    .WII      ( WII      ),
    .WIF      ( WIF      ),
    .WOI      ( WOI      ),
    .WOF      ( WOF      ),
    .ROUND    ( 1        )
) sqrt_i (
    .in       ( in       ),
    .out      ( osqrt    ),
    .overflow ( overflow )
);

task automatic test_sqrt(input [WII+WIF-1:0] _in);
    in = _in;
#2  $display("    sqrt %16f:    %16f =%16f^2   %s",($signed(in)*1.0)/(1<<WIF), (($signed(osqrt)*1.0)/(1<<WOF))*(($signed(osqrt)*1.0)/(1<<WOF)), ($signed(osqrt)*1.0)/(1<<WOF) ,overflow?"overflow!!":"" );
endtask

initial begin
    test_sqrt('hc36f0d77);  // -239.052599
    test_sqrt('h44696e31);  // 933.721728
    test_sqrt('hc427f97f);  // -671.898360
    test_sqrt('h00000000);  // 0.0
    test_sqrt('h80000000);  // 0.0
    test_sqrt('h7f800000);  // 
    test_sqrt('h7fc00000);  // 
    test_sqrt('h442caab9);  // 690.667541
    test_sqrt('hc19d957c);  // -19.697991
    test_sqrt('h4341cd28);  // 193.801397
    test_sqrt('h43a2cd6b);  // 325.604832
    test_sqrt('h43a8506c);  // 336.628307
    test_sqrt('hc3be496f);  // -380.573709
    test_sqrt('hc3d3dcd6);  // -423.725281
    test_sqrt('h441e0fa9);  // 632.244716
    test_sqrt('hc43ea05f);  // -762.505776
    test_sqrt('hc4403f17);  // -768.985802
    test_sqrt('h438856d1);  // 272.678250
    test_sqrt('h441ce8c1);  // 627.636768
    test_sqrt('h446a45dc);  // 937.091570
    test_sqrt('hc3b9294f);  // -370.322729
    test_sqrt('hc38c9f55);  // -281.244768
    test_sqrt('hc33b70c2);  // -187.440467
    test_sqrt('h44008061);  // 514.005925
    test_sqrt('h43f1e935);  // 483.821939
    test_sqrt('h43ae7eac);  // 348.989613
    test_sqrt('hc269c397);  // -58.441005
    test_sqrt('hc3b43c04);  // -360.468865
    test_sqrt('hc325abbd);  // -165.670860
    test_sqrt('h4475736b);  // 981.803388
    test_sqrt('h434fbce6);  // 207.737885
    test_sqrt('h43fc4777);  // 504.558318
    test_sqrt('h444e0da0);  // 824.212891
    test_sqrt('hc46b581a);  // -941.376568
    test_sqrt('h44333fac);  // 716.994871
    test_sqrt('h42960ffd);  // 75.031231
    test_sqrt('h446b7203);  // 941.781404
    test_sqrt('hc469d2f9);  // -935.296475
    test_sqrt('hc47289aa);  // -970.150994
    test_sqrt('hc33c7a47);  // -188.477643
    test_sqrt('hc30ecc5b);  // -142.798263
    test_sqrt('h445c9965);  // 882.396800
    test_sqrt('h44763643);  // 984.847861
    test_sqrt('h441e5eed);  // 633.483205
    test_sqrt('hc4654e45);  // -917.222981
    test_sqrt('h43e4f4ec);  // 457.913453
    test_sqrt('hc41b1ef4);  // -620.483642
    test_sqrt('h428fa6a7);  // 71.825490
    test_sqrt('hc38f8033);  // -287.001547
    test_sqrt('hc438be16);  // -738.970063
    test_sqrt('hc319949d);  // -153.580521
    test_sqrt('h442ea8ae);  // 698.635645
    test_sqrt('h43737c6c);  // 243.486026
    test_sqrt('h4444eacc);  // 787.668696
    test_sqrt('hc42a01ca);  // -680.027936
    test_sqrt('hc341b808);  // -193.718874
    test_sqrt('h4403ce28);  // 527.221168
    test_sqrt('hc45cf01a);  // -883.751614
    test_sqrt('h4453381e);  // 844.876811
    test_sqrt('hc44b0395);  // -812.055953
    test_sqrt('h43840a3f);  // 264.080044
    test_sqrt('h4437fb19);  // 735.923409
    test_sqrt('hc43e681d);  // -761.626744
    test_sqrt('hc40790c8);  // -542.262203
    test_sqrt('hc2cdff5d);  // -102.998757
    test_sqrt('hc3d96277);  // -434.769252
    test_sqrt('hc4718f03);  // -966.234547
    test_sqrt('hc2362fbd);  // -45.546620
    test_sqrt('hc412c1fb);  // -587.030965
    test_sqrt('hc306c74d);  // -134.778523
    test_sqrt('hc1eb725d);  // -29.430842
    test_sqrt('hc3e64bb5);  // -460.591455
    test_sqrt('h43422239);  // 194.133678
    test_sqrt('h43192d18);  // 153.176152
    test_sqrt('h4366b748);  // 230.715939
    test_sqrt('h446b56c8);  // 941.355937
    test_sqrt('hc3376ef5);  // -183.433424
    test_sqrt('hc457ffdc);  // -863.997777
    test_sqrt('h423cf1d0);  // 47.236146
    test_sqrt('h4419e668);  // 615.600075
    test_sqrt('h43232aee);  // 163.167699
    test_sqrt('h42ceebce);  // 103.460559
    test_sqrt('h4423b49f);  // 654.822224
    test_sqrt('hc352e314);  // -210.887030
    test_sqrt('hc4246f4f);  // -657.739192
    test_sqrt('h4322c8bb);  // 162.784105
    test_sqrt('hc45c44a1);  // -881.072344
    test_sqrt('hc4351563);  // -724.334182
    test_sqrt('hc44cd52a);  // -819.330677
    test_sqrt('hc430525e);  // -705.286991
    test_sqrt('h434b24df);  // 203.144033
    test_sqrt('h4471b8a6);  // 966.885115
    test_sqrt('hc3e60006);  // -460.000173
    test_sqrt('h441bf7e5);  // 623.873382
    test_sqrt('hc1cf549a);  // -25.916309
    test_sqrt('h44442a5c);  // 784.661893
    test_sqrt('h407e7564);  // 3.975915
    test_sqrt('h44446d20);  // 785.705098
    test_sqrt('h43d92570);  // 434.292482
    test_sqrt('h441c5c11);  // 625.438539
    test_sqrt('hc4418026);  // -774.002304
    test_sqrt('hc3eac4fb);  // -469.538902
    test_sqrt('h4432ebe8);  // 715.686013
    test_sqrt('h4424625a);  // 657.536747
end

endmodule
