
module b08 ( CLOCK, RESET, START, I, O );
  input [7:0] I;
  output [3:0] O;
  input CLOCK, RESET, START;
  wire   n65, n78, n80, n82, n84, n86, n88, n90, n92, n94, n95, n96, n97, n98,
         n99, n100, n101, n102, n103, n104, n105, n106, n107, n108, n109, n110,
         n111, n112, n113, n114, n115, n116, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153, n154, n155,
         n156, n157;
  wire   [1:0] STATO;
  wire   [2:0] MAR;
  wire   [7:0] IN_R;
  wire   [3:0] OUT_R;

  DFFARX1 \STATO_reg[1]  ( .D(n94), .CLK(CLOCK), .RSTB(n65), .Q(STATO[1]), 
        .QN(n155) );
  DFFARX1 \STATO_reg[0]  ( .D(n92), .CLK(CLOCK), .RSTB(n65), .Q(STATO[0]), 
        .QN(n153) );
  DFFARX1 \MAR_reg[0]  ( .D(n90), .CLK(CLOCK), .RSTB(n65), .Q(MAR[0]), .QN(
        n154) );
  DFFARX1 \MAR_reg[1]  ( .D(n88), .CLK(CLOCK), .RSTB(n65), .Q(MAR[1]), .QN(
        n151) );
  DFFARX1 \MAR_reg[2]  ( .D(n86), .CLK(CLOCK), .RSTB(n65), .Q(MAR[2]), .QN(
        n152) );
  DFFARX1 \OUT_R_reg[3]  ( .D(n84), .CLK(CLOCK), .RSTB(n65), .Q(OUT_R[3]) );
  DFFARX1 \OUT_R_reg[2]  ( .D(n82), .CLK(CLOCK), .RSTB(n65), .Q(OUT_R[2]) );
  DFFARX1 \OUT_R_reg[1]  ( .D(n80), .CLK(CLOCK), .RSTB(n65), .Q(OUT_R[1]) );
  DFFARX1 \OUT_R_reg[0]  ( .D(n78), .CLK(CLOCK), .RSTB(n65), .Q(OUT_R[0]) );
  DFFARX1 \IN_R_reg[7]  ( .D(n106), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[7]) );
  DFFARX1 \IN_R_reg[6]  ( .D(n105), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[6]), .QN(
        n156) );
  DFFARX1 \IN_R_reg[5]  ( .D(n104), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[5]) );
  DFFARX1 \IN_R_reg[4]  ( .D(n103), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[4]) );
  DFFARX1 \IN_R_reg[3]  ( .D(n102), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[3]) );
  DFFARX1 \IN_R_reg[2]  ( .D(n101), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[2]) );
  DFFARX1 \IN_R_reg[1]  ( .D(n100), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[1]), .QN(
        n157) );
  DFFARX1 \IN_R_reg[0]  ( .D(n99), .CLK(CLOCK), .RSTB(n65), .Q(IN_R[0]) );
  DFFARX1 \O_reg[3]  ( .D(n95), .CLK(CLOCK), .RSTB(n65), .Q(O[3]) );
  DFFARX1 \O_reg[2]  ( .D(n96), .CLK(CLOCK), .RSTB(n65), .Q(O[2]) );
  DFFARX1 \O_reg[1]  ( .D(n97), .CLK(CLOCK), .RSTB(n65), .Q(O[1]) );
  DFFARX1 \O_reg[0]  ( .D(n98), .CLK(CLOCK), .RSTB(n65), .Q(O[0]) );
  INVX0 U89 ( .INP(RESET), .ZN(n65) );
  NAND2X0 U90 ( .IN1(STATO[0]), .IN2(n155), .QN(n148) );
  MUX21X1 U91 ( .IN1(I[7]), .IN2(IN_R[7]), .S(n148), .Q(n106) );
  MUX21X1 U92 ( .IN1(I[6]), .IN2(IN_R[6]), .S(n148), .Q(n105) );
  MUX21X1 U93 ( .IN1(I[5]), .IN2(IN_R[5]), .S(n148), .Q(n104) );
  MUX21X1 U94 ( .IN1(I[4]), .IN2(IN_R[4]), .S(n148), .Q(n103) );
  MUX21X1 U95 ( .IN1(I[3]), .IN2(IN_R[3]), .S(n148), .Q(n102) );
  MUX21X1 U96 ( .IN1(I[2]), .IN2(IN_R[2]), .S(n148), .Q(n101) );
  MUX21X1 U97 ( .IN1(I[1]), .IN2(IN_R[1]), .S(n148), .Q(n100) );
  MUX21X1 U98 ( .IN1(I[0]), .IN2(IN_R[0]), .S(n148), .Q(n99) );
  NAND3X0 U99 ( .IN1(MAR[0]), .IN2(MAR[1]), .IN3(MAR[2]), .QN(n144) );
  INVX0 U100 ( .INP(n144), .ZN(n109) );
  NOR2X0 U101 ( .IN1(n155), .IN2(n153), .QN(n114) );
  INVX0 U102 ( .INP(START), .ZN(n107) );
  NAND3X0 U103 ( .IN1(n109), .IN2(n114), .IN3(n107), .QN(n108) );
  MUX21X1 U104 ( .IN1(OUT_R[0]), .IN2(O[0]), .S(n108), .Q(n98) );
  MUX21X1 U105 ( .IN1(OUT_R[1]), .IN2(O[1]), .S(n108), .Q(n97) );
  MUX21X1 U106 ( .IN1(OUT_R[2]), .IN2(O[2]), .S(n108), .Q(n96) );
  MUX21X1 U107 ( .IN1(OUT_R[3]), .IN2(O[3]), .S(n108), .Q(n95) );
  AND3X1 U108 ( .IN1(n109), .IN2(START), .IN3(n148), .Q(n110) );
  OA21X1 U109 ( .IN1(n155), .IN2(n144), .IN3(STATO[0]), .Q(n111) );
  AO221X1 U110 ( .IN1(STATO[1]), .IN2(n110), .IN3(STATO[1]), .IN4(n153), .IN5(
        n111), .Q(n94) );
  AO221X1 U111 ( .IN1(n153), .IN2(STATO[1]), .IN3(n153), .IN4(START), .IN5(
        n110), .Q(n92) );
  INVX0 U112 ( .INP(n111), .ZN(n113) );
  MUX21X1 U113 ( .IN1(n113), .IN2(n114), .S(n154), .Q(n90) );
  NOR2X0 U114 ( .IN1(MAR[0]), .IN2(n151), .QN(n150) );
  AO21X1 U115 ( .IN1(MAR[0]), .IN2(n151), .IN3(n150), .Q(n112) );
  AO22X1 U116 ( .IN1(MAR[1]), .IN2(n113), .IN3(n114), .IN4(n112), .Q(n88) );
  NAND2X0 U117 ( .IN1(n152), .IN2(MAR[0]), .QN(n123) );
  NOR2X0 U118 ( .IN1(n151), .IN2(n123), .QN(n116) );
  AO222X1 U119 ( .IN1(MAR[2]), .IN2(n114), .IN3(MAR[2]), .IN4(n113), .IN5(n114), .IN6(n116), .Q(n86) );
  AOI21X1 U120 ( .IN1(n154), .IN2(n152), .IN3(IN_R[7]), .QN(n135) );
  AO21X1 U121 ( .IN1(MAR[2]), .IN2(n157), .IN3(n135), .Q(n115) );
  OA21X1 U122 ( .IN1(IN_R[0]), .IN2(n115), .IN3(n150), .Q(n141) );
  INVX0 U123 ( .INP(n116), .ZN(n128) );
  NAND2X0 U125 ( .IN1(MAR[2]), .IN2(n151), .QN(n142) );
  OA221X1 U126 ( .IN1(1'b0), .IN2(STATO[1]), .IN3(IN_R[0]), .IN4(n142), .IN5(
        n153), .Q(n118) );
  OA221X1 U127 ( .IN1(n128), .IN2(IN_R[2]), .IN3(n128), .IN4(IN_R[4]), .IN5(
        n118), .Q(n122) );
  NAND3X0 U128 ( .IN1(IN_R[7]), .IN2(n151), .IN3(n152), .QN(n121) );
  NAND3X0 U129 ( .IN1(MAR[1]), .IN2(IN_R[4]), .IN3(n123), .QN(n120) );
  OR3X1 U130 ( .IN1(MAR[0]), .IN2(IN_R[3]), .IN3(n152), .Q(n119) );
  NAND4X0 U131 ( .IN1(n122), .IN2(n121), .IN3(n120), .IN4(n119), .QN(n140) );
  OR2X1 U132 ( .IN1(IN_R[5]), .IN2(n152), .Q(n125) );
  INVX0 U133 ( .INP(n123), .ZN(n126) );
  MUX21X1 U134 ( .IN1(n154), .IN2(n126), .S(n151), .Q(n124) );
  OA221X1 U135 ( .IN1(IN_R[2]), .IN2(IN_R[1]), .IN3(IN_R[2]), .IN4(n125), 
        .IN5(n124), .Q(n139) );
  OA22X1 U136 ( .IN1(IN_R[2]), .IN2(n142), .IN3(MAR[1]), .IN4(IN_R[0]), .Q(
        n131) );
  NOR2X0 U137 ( .IN1(MAR[1]), .IN2(n126), .QN(n127) );
  MUX21X1 U138 ( .IN1(IN_R[6]), .IN2(n156), .S(n127), .Q(n129) );
  NAND2X0 U139 ( .IN1(n129), .IN2(n128), .QN(n132) );
  NAND3X0 U140 ( .IN1(MAR[1]), .IN2(MAR[2]), .IN3(IN_R[7]), .QN(n130) );
  NAND3X0 U141 ( .IN1(n131), .IN2(n132), .IN3(n130), .QN(n137) );
  NAND2X0 U142 ( .IN1(IN_R[5]), .IN2(IN_R[3]), .QN(n134) );
  INVX0 U143 ( .INP(n132), .ZN(n133) );
  AO221X1 U144 ( .IN1(MAR[1]), .IN2(n135), .IN3(n151), .IN4(n134), .IN5(n133), 
        .Q(n136) );
  AO22X1 U145 ( .IN1(MAR[0]), .IN2(n137), .IN3(n152), .IN4(n136), .Q(n138) );
  NOR4X0 U146 ( .IN1(n141), .IN2(n140), .IN3(n139), .IN4(n138), .QN(n149) );
  OA21X1 U147 ( .IN1(MAR[2]), .IN2(n151), .IN3(n142), .Q(n145) );
  NAND2X0 U148 ( .IN1(MAR[0]), .IN2(n145), .QN(n143) );
  AO22X1 U149 ( .IN1(n149), .IN2(n143), .IN3(OUT_R[3]), .IN4(n148), .Q(n84) );
  OAI21X1 U150 ( .IN1(MAR[0]), .IN2(n145), .IN3(n144), .QN(n146) );
  AO22X1 U151 ( .IN1(n149), .IN2(n146), .IN3(OUT_R[2]), .IN4(n148), .Q(n82) );
  NAND2X0 U152 ( .IN1(MAR[0]), .IN2(MAR[2]), .QN(n147) );
  AO22X1 U153 ( .IN1(n149), .IN2(n147), .IN3(OUT_R[1]), .IN4(n148), .Q(n80) );
  AO22X1 U154 ( .IN1(n150), .IN2(n149), .IN3(OUT_R[0]), .IN4(n148), .Q(n78) );
endmodule

