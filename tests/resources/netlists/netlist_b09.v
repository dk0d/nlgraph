
module b09 ( reset, clock, x, y );
  input reset, clock, x;
  output y;
  wire   N43, N44, N45, N46, N47, N48, N49, N50, N51, N52, N53, n61, n63, n65,
         n67, n69, n71, n73, n75, n77, n79, n81, n83, n85, n87, n89, n91, n93,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130;
  wire   [1:0] stato;
  wire   [8:0] d_in;
  wire   [7:0] d_out;
  wire   [7:0] old;

  DFFARX1 y_reg ( .D(n93), .CLK(clock), .RSTB(n130), .Q(y) );
  DFFARX1 \d_out_reg[7]  ( .D(n91), .CLK(clock), .RSTB(n130), .Q(d_out[7]) );
  DFFARX1 \d_out_reg[6]  ( .D(n89), .CLK(clock), .RSTB(n130), .Q(d_out[6]) );
  DFFARX1 \d_out_reg[5]  ( .D(n87), .CLK(clock), .RSTB(n130), .Q(d_out[5]) );
  DFFARX1 \d_out_reg[4]  ( .D(n85), .CLK(clock), .RSTB(n130), .Q(d_out[4]) );
  DFFARX1 \d_out_reg[3]  ( .D(n83), .CLK(clock), .RSTB(n130), .Q(d_out[3]) );
  DFFARX1 \d_out_reg[2]  ( .D(n81), .CLK(clock), .RSTB(n130), .Q(d_out[2]) );
  DFFARX1 \d_out_reg[1]  ( .D(n79), .CLK(clock), .RSTB(n130), .Q(d_out[1]) );
  DFFARX1 \d_out_reg[0]  ( .D(n77), .CLK(clock), .RSTB(n130), .Q(d_out[0]) );
  DFFARX1 \old_reg[7]  ( .D(n75), .CLK(clock), .RSTB(n130), .Q(old[7]) );
  DFFARX1 \old_reg[6]  ( .D(n73), .CLK(clock), .RSTB(n130), .Q(old[6]) );
  DFFARX1 \old_reg[5]  ( .D(n71), .CLK(clock), .RSTB(n130), .Q(old[5]) );
  DFFARX1 \old_reg[4]  ( .D(n69), .CLK(clock), .RSTB(n130), .Q(old[4]) );
  DFFARX1 \old_reg[3]  ( .D(n67), .CLK(clock), .RSTB(n130), .Q(old[3]) );
  DFFARX1 \old_reg[2]  ( .D(n65), .CLK(clock), .RSTB(n130), .Q(old[2]) );
  DFFARX1 \old_reg[1]  ( .D(n63), .CLK(clock), .RSTB(n130), .Q(old[1]) );
  DFFARX1 \old_reg[0]  ( .D(n61), .CLK(clock), .RSTB(n130), .Q(old[0]) );
  DFFARX1 \stato_reg[1]  ( .D(N44), .CLK(clock), .RSTB(n130), .Q(stato[1]), 
        .QN(n122) );
  DFFARX1 \stato_reg[0]  ( .D(N43), .CLK(clock), .RSTB(n130), .Q(stato[0]), 
        .QN(n121) );
  DFFARX1 \d_in_reg[8]  ( .D(N53), .CLK(clock), .RSTB(n130), .Q(d_in[8]), .QN(
        n120) );
  DFFARX1 \d_in_reg[7]  ( .D(N52), .CLK(clock), .RSTB(n130), .Q(d_in[7]), .QN(
        n123) );
  DFFARX1 \d_in_reg[6]  ( .D(N51), .CLK(clock), .RSTB(n130), .Q(d_in[6]), .QN(
        n124) );
  DFFARX1 \d_in_reg[5]  ( .D(N50), .CLK(clock), .RSTB(n130), .Q(d_in[5]), .QN(
        n125) );
  DFFARX1 \d_in_reg[4]  ( .D(N49), .CLK(clock), .RSTB(n130), .Q(d_in[4]), .QN(
        n126) );
  DFFARX1 \d_in_reg[3]  ( .D(N48), .CLK(clock), .RSTB(n130), .Q(d_in[3]), .QN(
        n127) );
  DFFARX1 \d_in_reg[2]  ( .D(N47), .CLK(clock), .RSTB(n130), .Q(d_in[2]), .QN(
        n128) );
  DFFARX1 \d_in_reg[1]  ( .D(N46), .CLK(clock), .RSTB(n130), .Q(d_in[1]), .QN(
        n129) );
  DFFARX1 \d_in_reg[0]  ( .D(N45), .CLK(clock), .RSTB(n130), .Q(d_in[0]), .QN(
        n119) );
  INVX0 U79 ( .INP(reset), .ZN(n130) );
  NOR3X0 U80 ( .IN1(n122), .IN2(stato[0]), .IN3(d_in[0]), .QN(n107) );
  AOI22X1 U81 ( .IN1(stato[0]), .IN2(n122), .IN3(n107), .IN4(d_out[0]), .QN(
        n103) );
  NOR2X0 U82 ( .IN1(n121), .IN2(n119), .QN(n116) );
  MUX21X1 U83 ( .IN1(d_in[5]), .IN2(n125), .S(old[4]), .Q(n102) );
  MUX21X1 U84 ( .IN1(d_in[6]), .IN2(n124), .S(old[5]), .Q(n101) );
  OAI22X1 U85 ( .IN1(old[6]), .IN2(n123), .IN3(n120), .IN4(old[7]), .QN(n94)
         );
  AO221X1 U86 ( .IN1(n123), .IN2(old[6]), .IN3(n120), .IN4(old[7]), .IN5(n94), 
        .Q(n100) );
  MUX21X1 U87 ( .IN1(n126), .IN2(d_in[4]), .S(old[3]), .Q(n98) );
  MUX21X1 U88 ( .IN1(n127), .IN2(d_in[3]), .S(old[2]), .Q(n97) );
  MUX21X1 U89 ( .IN1(n128), .IN2(d_in[2]), .S(old[1]), .Q(n96) );
  MUX21X1 U90 ( .IN1(n129), .IN2(d_in[1]), .S(old[0]), .Q(n95) );
  NAND4X0 U91 ( .IN1(n98), .IN2(n97), .IN3(n96), .IN4(n95), .QN(n99) );
  OR4X1 U92 ( .IN1(n102), .IN2(n101), .IN3(n100), .IN4(n99), .Q(n112) );
  NAND2X0 U93 ( .IN1(n116), .IN2(n112), .QN(n106) );
  NAND2X0 U94 ( .IN1(n103), .IN2(n106), .QN(n105) );
  NAND2X0 U95 ( .IN1(stato[0]), .IN2(n119), .QN(n111) );
  NOR2X0 U96 ( .IN1(stato[1]), .IN2(n111), .QN(n104) );
  MUX21X1 U97 ( .IN1(n105), .IN2(y), .S(n104), .Q(n93) );
  OA221X1 U98 ( .IN1(d_in[0]), .IN2(stato[0]), .IN3(n119), .IN4(stato[1]), 
        .IN5(n106), .Q(n108) );
  NOR2X0 U99 ( .IN1(n108), .IN2(n121), .QN(n109) );
  AO22X1 U100 ( .IN1(d_in[8]), .IN2(n109), .IN3(n108), .IN4(d_out[7]), .Q(n91)
         );
  AO222X1 U101 ( .IN1(d_in[7]), .IN2(n109), .IN3(n108), .IN4(d_out[6]), .IN5(
        n107), .IN6(d_out[7]), .Q(n89) );
  AO222X1 U102 ( .IN1(d_in[6]), .IN2(n109), .IN3(n108), .IN4(d_out[5]), .IN5(
        d_out[6]), .IN6(n107), .Q(n87) );
  AO222X1 U103 ( .IN1(d_in[5]), .IN2(n109), .IN3(n108), .IN4(d_out[4]), .IN5(
        d_out[5]), .IN6(n107), .Q(n85) );
  AO222X1 U104 ( .IN1(d_in[4]), .IN2(n109), .IN3(n108), .IN4(d_out[3]), .IN5(
        d_out[4]), .IN6(n107), .Q(n83) );
  AO222X1 U105 ( .IN1(d_in[3]), .IN2(n109), .IN3(n108), .IN4(d_out[2]), .IN5(
        d_out[3]), .IN6(n107), .Q(n81) );
  AO222X1 U106 ( .IN1(d_in[2]), .IN2(n109), .IN3(n108), .IN4(d_out[1]), .IN5(
        d_out[2]), .IN6(n107), .Q(n79) );
  AO222X1 U107 ( .IN1(d_in[1]), .IN2(n109), .IN3(n108), .IN4(d_out[0]), .IN5(
        d_out[1]), .IN6(n107), .Q(n77) );
  NAND2X0 U108 ( .IN1(stato[1]), .IN2(n121), .QN(n110) );
  NAND2X0 U109 ( .IN1(n111), .IN2(n110), .QN(n114) );
  AO22X1 U110 ( .IN1(d_in[8]), .IN2(n116), .IN3(old[7]), .IN4(n114), .Q(n75)
         );
  AO22X1 U111 ( .IN1(old[6]), .IN2(n114), .IN3(d_in[7]), .IN4(n116), .Q(n73)
         );
  AO22X1 U112 ( .IN1(old[5]), .IN2(n114), .IN3(d_in[6]), .IN4(n116), .Q(n71)
         );
  AO22X1 U113 ( .IN1(old[4]), .IN2(n114), .IN3(d_in[5]), .IN4(n116), .Q(n69)
         );
  AO22X1 U114 ( .IN1(old[3]), .IN2(n114), .IN3(d_in[4]), .IN4(n116), .Q(n67)
         );
  AO22X1 U115 ( .IN1(old[2]), .IN2(n114), .IN3(d_in[3]), .IN4(n116), .Q(n65)
         );
  AO22X1 U116 ( .IN1(old[1]), .IN2(n114), .IN3(d_in[2]), .IN4(n116), .Q(n63)
         );
  AO22X1 U117 ( .IN1(old[0]), .IN2(n114), .IN3(d_in[1]), .IN4(n116), .Q(n61)
         );
  NOR2X0 U118 ( .IN1(n112), .IN2(n122), .QN(n118) );
  INVX0 U119 ( .INP(n118), .ZN(n113) );
  AO22X1 U120 ( .IN1(n116), .IN2(n113), .IN3(x), .IN4(n114), .Q(N53) );
  INVX0 U121 ( .INP(n114), .ZN(n115) );
  NOR2X0 U122 ( .IN1(n115), .IN2(n120), .QN(N52) );
  NOR2X0 U123 ( .IN1(n115), .IN2(n123), .QN(N51) );
  NOR2X0 U124 ( .IN1(n115), .IN2(n124), .QN(N50) );
  NOR2X0 U125 ( .IN1(n115), .IN2(n125), .QN(N49) );
  NOR2X0 U126 ( .IN1(n115), .IN2(n126), .QN(N48) );
  NOR2X0 U127 ( .IN1(n115), .IN2(n127), .QN(N47) );
  NOR2X0 U128 ( .IN1(n115), .IN2(n128), .QN(N46) );
  NOR2X0 U129 ( .IN1(n115), .IN2(n129), .QN(N45) );
  OR2X1 U130 ( .IN1(n116), .IN2(stato[1]), .Q(N44) );
  NAND2X0 U131 ( .IN1(stato[1]), .IN2(n119), .QN(n117) );
  AO222X1 U132 ( .IN1(stato[0]), .IN2(n118), .IN3(stato[0]), .IN4(n119), .IN5(
        n121), .IN6(n117), .Q(N43) );
endmodule

