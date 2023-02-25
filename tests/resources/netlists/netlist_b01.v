
module b01 ( line1, line2, reset, outp, overflw, clock );
  input line1, line2, reset, clock;
  output outp, overflw;
  wire   N41, N42, N43, N44, N45, n18, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39;
  wire   [2:0] stato;

  DFFARX1 \stato_reg[2]  ( .D(N43), .CLK(clock), .RSTB(n18), .Q(stato[2]), 
        .QN(n39) );
  DFFARX1 \stato_reg[1]  ( .D(N42), .CLK(clock), .RSTB(n18), .Q(stato[1]), 
        .QN(n38) );
  DFFARX1 \stato_reg[0]  ( .D(N41), .CLK(clock), .RSTB(n18), .Q(stato[0]), 
        .QN(n37) );
  DFFARX1 overflw_reg ( .D(N45), .CLK(clock), .RSTB(n18), .Q(overflw) );
  DFFARX1 outp_reg ( .D(N44), .CLK(clock), .RSTB(n18), .Q(outp) );
  NAND2X0 U26 ( .IN1(line2), .IN2(line1), .QN(n34) );
  NAND3X0 U27 ( .IN1(n34), .IN2(stato[0]), .IN3(n38), .QN(n25) );
  NAND2X0 U28 ( .IN1(n37), .IN2(stato[1]), .QN(n27) );
  NOR2X0 U29 ( .IN1(line2), .IN2(line1), .QN(n31) );
  INVX0 U30 ( .INP(n31), .ZN(n28) );
  MUX21X1 U31 ( .IN1(stato[1]), .IN2(n37), .S(n28), .Q(n23) );
  OA222X1 U32 ( .IN1(n27), .IN2(stato[2]), .IN3(n27), .IN4(n34), .IN5(n39), 
        .IN6(n23), .Q(n24) );
  NAND2X0 U33 ( .IN1(n25), .IN2(n24), .QN(N42) );
  INVX0 U34 ( .INP(reset), .ZN(n18) );
  NOR3X0 U35 ( .IN1(n38), .IN2(n37), .IN3(stato[2]), .QN(N45) );
  NAND2X0 U36 ( .IN1(n34), .IN2(n28), .QN(n26) );
  NAND2X0 U37 ( .IN1(stato[2]), .IN2(n27), .QN(n30) );
  XOR2X1 U38 ( .IN1(n26), .IN2(n30), .Q(N44) );
  INVX0 U39 ( .INP(n27), .ZN(n35) );
  INVX0 U40 ( .INP(n34), .ZN(n36) );
  OA21X1 U41 ( .IN1(stato[0]), .IN2(n28), .IN3(n38), .Q(n29) );
  AO222X1 U42 ( .IN1(n39), .IN2(n35), .IN3(n39), .IN4(n36), .IN5(n29), .IN6(
        stato[2]), .Q(N43) );
  AO221X1 U43 ( .IN1(stato[0]), .IN2(n34), .IN3(n37), .IN4(n36), .IN5(stato[2]), .Q(n32) );
  OAI22X1 U44 ( .IN1(stato[1]), .IN2(n32), .IN3(n31), .IN4(n30), .QN(n33) );
  AO221X1 U45 ( .IN1(n36), .IN2(n35), .IN3(n34), .IN4(N45), .IN5(n33), .Q(N41)
         );
endmodule

