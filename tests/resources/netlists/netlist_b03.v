
module b03 ( clock, reset, request1, request2, request3, request4, grant_o );
  output [3:0] grant_o;
  input clock, reset, request1, request2, request3, request4;
  wire   ru1, fu1, ru2, fu2, ru3, fu3, ru4, fu4, n32, n34, n36, n38, n40, n42,
         n44, n46, n48, n50, n52, n54, n56, n58, n60, n62, n77, n78, n79, n80,
         n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94,
         n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105, n106,
         n107, n108, n109, n110, n111, n112;
  wire   [1:0] stato;
  wire   [2:0] coda0;
  wire   [2:0] coda1;
  wire   [2:0] coda2;
  wire   [2:0] coda3;
  wire   [3:0] grant;

  DFFARX1 \stato_reg[0]  ( .D(n109), .CLK(clock), .RSTB(n111), .Q(stato[0]), 
        .QN(n109) );
  DFFARX1 \stato_reg[1]  ( .D(stato[0]), .CLK(clock), .RSTB(n111), .Q(stato[1]) );
  DFFARX1 fu1_reg ( .D(n88), .CLK(clock), .RSTB(n111), .Q(fu1) );
  DFFARX1 fu2_reg ( .D(n87), .CLK(clock), .RSTB(n111), .Q(fu2) );
  DFFARX1 fu3_reg ( .D(n86), .CLK(clock), .RSTB(n111), .Q(fu3) );
  DFFARX1 fu4_reg ( .D(n85), .CLK(clock), .RSTB(n111), .Q(fu4), .QN(n108) );
  DFFARX1 \grant_reg[3]  ( .D(n84), .CLK(clock), .RSTB(n111), .Q(grant[3]) );
  DFFARX1 \grant_o_reg[3]  ( .D(n83), .CLK(clock), .RSTB(n111), .Q(grant_o[3])
         );
  DFFARX1 \grant_reg[2]  ( .D(n82), .CLK(clock), .RSTB(n111), .Q(grant[2]) );
  DFFARX1 \grant_o_reg[2]  ( .D(n81), .CLK(clock), .RSTB(n111), .Q(grant_o[2])
         );
  DFFARX1 \grant_reg[1]  ( .D(n80), .CLK(clock), .RSTB(n111), .Q(grant[1]) );
  DFFARX1 \grant_o_reg[1]  ( .D(n79), .CLK(clock), .RSTB(n111), .Q(grant_o[1])
         );
  DFFARX1 \grant_reg[0]  ( .D(n78), .CLK(clock), .RSTB(n112), .Q(grant[0]) );
  DFFARX1 \grant_o_reg[0]  ( .D(n77), .CLK(clock), .RSTB(n112), .Q(grant_o[0])
         );
  DFFARX1 ru1_reg ( .D(n62), .CLK(clock), .RSTB(n112), .Q(ru1) );
  DFFARX1 ru2_reg ( .D(n60), .CLK(clock), .RSTB(n112), .Q(ru2), .QN(n107) );
  DFFARX1 \coda0_reg[0]  ( .D(n58), .CLK(clock), .RSTB(n112), .Q(coda0[0]) );
  DFFARX1 \coda1_reg[0]  ( .D(n56), .CLK(clock), .RSTB(n112), .Q(coda1[0]) );
  DFFARX1 \coda2_reg[0]  ( .D(n54), .CLK(clock), .RSTB(n112), .Q(coda2[0]) );
  DFFARX1 \coda3_reg[0]  ( .D(n52), .CLK(clock), .RSTB(n112), .Q(coda3[0]) );
  DFFARX1 ru3_reg ( .D(n50), .CLK(clock), .RSTB(n112), .Q(ru3), .QN(n110) );
  DFFARX1 \coda0_reg[1]  ( .D(n48), .CLK(clock), .RSTB(n112), .Q(coda0[1]) );
  DFFARX1 \coda1_reg[1]  ( .D(n46), .CLK(clock), .RSTB(n112), .Q(coda1[1]) );
  DFFARX1 \coda2_reg[1]  ( .D(n44), .CLK(clock), .RSTB(n112), .Q(coda2[1]) );
  DFFARX1 \coda3_reg[1]  ( .D(n42), .CLK(clock), .RSTB(n112), .Q(coda3[1]) );
  DFFARX1 \coda0_reg[2]  ( .D(n40), .CLK(clock), .RSTB(n111), .Q(coda0[2]) );
  DFFARX1 \coda1_reg[2]  ( .D(n38), .CLK(clock), .RSTB(n112), .Q(coda1[2]) );
  DFFARX1 \coda2_reg[2]  ( .D(n36), .CLK(clock), .RSTB(n111), .Q(coda2[2]) );
  DFFARX1 \coda3_reg[2]  ( .D(n34), .CLK(clock), .RSTB(n112), .Q(coda3[2]) );
  DFFARX1 ru4_reg ( .D(n32), .CLK(clock), .RSTB(n111), .Q(ru4) );
  INVX0 U63 ( .INP(reset), .ZN(n111) );
  INVX0 U64 ( .INP(reset), .ZN(n112) );
  MUX21X1 U65 ( .IN1(fu1), .IN2(ru1), .S(stato[0]), .Q(n88) );
  MUX21X1 U66 ( .IN1(fu2), .IN2(ru2), .S(stato[0]), .Q(n87) );
  MUX21X1 U67 ( .IN1(fu3), .IN2(ru3), .S(stato[0]), .Q(n86) );
  MUX21X1 U68 ( .IN1(fu4), .IN2(ru4), .S(stato[0]), .Q(n85) );
  OR4X1 U69 ( .IN1(fu1), .IN2(fu2), .IN3(fu3), .IN4(fu4), .Q(n89) );
  NAND2X0 U70 ( .IN1(stato[1]), .IN2(n89), .QN(n98) );
  NOR3X0 U71 ( .IN1(coda0[0]), .IN2(coda0[1]), .IN3(n98), .QN(n90) );
  AO22X1 U72 ( .IN1(n90), .IN2(coda0[2]), .IN3(grant[3]), .IN4(n98), .Q(n84)
         );
  MUX21X1 U73 ( .IN1(grant_o[3]), .IN2(grant[3]), .S(stato[0]), .Q(n83) );
  NOR3X0 U74 ( .IN1(coda0[0]), .IN2(coda0[2]), .IN3(n98), .QN(n91) );
  AO22X1 U75 ( .IN1(n91), .IN2(coda0[1]), .IN3(grant[2]), .IN4(n98), .Q(n82)
         );
  MUX21X1 U76 ( .IN1(grant_o[2]), .IN2(grant[2]), .S(stato[0]), .Q(n81) );
  NOR3X0 U77 ( .IN1(coda0[1]), .IN2(coda0[2]), .IN3(n98), .QN(n92) );
  AO22X1 U78 ( .IN1(n92), .IN2(coda0[0]), .IN3(grant[1]), .IN4(n98), .Q(n80)
         );
  MUX21X1 U79 ( .IN1(grant_o[1]), .IN2(grant[1]), .S(stato[0]), .Q(n79) );
  AND3X1 U80 ( .IN1(coda0[0]), .IN2(coda0[1]), .IN3(coda0[2]), .Q(n93) );
  MUX21X1 U81 ( .IN1(n93), .IN2(grant[0]), .S(n98), .Q(n78) );
  MUX21X1 U82 ( .IN1(grant_o[0]), .IN2(grant[0]), .S(stato[0]), .Q(n77) );
  MUX21X1 U83 ( .IN1(request1), .IN2(ru1), .S(stato[0]), .Q(n62) );
  MUX21X1 U84 ( .IN1(request2), .IN2(ru2), .S(stato[0]), .Q(n60) );
  NAND2X0 U85 ( .IN1(ru4), .IN2(n108), .QN(n94) );
  MUX21X1 U86 ( .IN1(n94), .IN2(fu3), .S(ru3), .Q(n95) );
  MUX21X1 U87 ( .IN1(n95), .IN2(fu2), .S(ru2), .Q(n96) );
  MUX21X1 U88 ( .IN1(n96), .IN2(fu1), .S(ru1), .Q(n97) );
  NOR3X0 U89 ( .IN1(stato[1]), .IN2(n109), .IN3(n97), .QN(n106) );
  NOR2X0 U90 ( .IN1(stato[0]), .IN2(n98), .QN(n104) );
  NOR2X0 U91 ( .IN1(n106), .IN2(n104), .QN(n105) );
  INVX0 U92 ( .INP(n106), .ZN(n99) );
  NOR2X0 U93 ( .IN1(ru1), .IN2(n99), .QN(n102) );
  AO22X1 U94 ( .IN1(coda1[0]), .IN2(n104), .IN3(n102), .IN4(n107), .Q(n100) );
  AO21X1 U95 ( .IN1(n105), .IN2(coda0[0]), .IN3(n100), .Q(n58) );
  AO222X1 U96 ( .IN1(n106), .IN2(coda0[0]), .IN3(n105), .IN4(coda1[0]), .IN5(
        n104), .IN6(coda2[0]), .Q(n56) );
  AO222X1 U97 ( .IN1(n106), .IN2(coda1[0]), .IN3(n105), .IN4(coda2[0]), .IN5(
        n104), .IN6(coda3[0]), .Q(n54) );
  AO22X1 U98 ( .IN1(n106), .IN2(coda2[0]), .IN3(n105), .IN4(coda3[0]), .Q(n52)
         );
  MUX21X1 U99 ( .IN1(request3), .IN2(ru3), .S(stato[0]), .Q(n50) );
  AO22X1 U100 ( .IN1(n104), .IN2(coda1[1]), .IN3(n105), .IN4(coda0[1]), .Q(
        n101) );
  AO221X1 U101 ( .IN1(n102), .IN2(ru2), .IN3(n102), .IN4(n110), .IN5(n101), 
        .Q(n48) );
  AO222X1 U102 ( .IN1(n106), .IN2(coda0[1]), .IN3(n105), .IN4(coda1[1]), .IN5(
        n104), .IN6(coda2[1]), .Q(n46) );
  AO222X1 U103 ( .IN1(n106), .IN2(coda1[1]), .IN3(n105), .IN4(coda2[1]), .IN5(
        n104), .IN6(coda3[1]), .Q(n44) );
  AO22X1 U104 ( .IN1(n106), .IN2(coda2[1]), .IN3(n105), .IN4(coda3[1]), .Q(n42) );
  AO21X1 U105 ( .IN1(n107), .IN2(n110), .IN3(ru1), .Q(n103) );
  AO222X1 U106 ( .IN1(n103), .IN2(n106), .IN3(n105), .IN4(coda0[2]), .IN5(n104), .IN6(coda1[2]), .Q(n40) );
  AO222X1 U107 ( .IN1(n106), .IN2(coda0[2]), .IN3(n105), .IN4(coda1[2]), .IN5(
        n104), .IN6(coda2[2]), .Q(n38) );
  AO222X1 U108 ( .IN1(n106), .IN2(coda1[2]), .IN3(n105), .IN4(coda2[2]), .IN5(
        n104), .IN6(coda3[2]), .Q(n36) );
  AO22X1 U109 ( .IN1(n106), .IN2(coda2[2]), .IN3(n105), .IN4(coda3[2]), .Q(n34) );
  MUX21X1 U110 ( .IN1(request4), .IN2(ru4), .S(stato[0]), .Q(n32) );
endmodule

