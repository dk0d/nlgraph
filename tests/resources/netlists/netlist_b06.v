
module b06 ( cc_mux, eql, uscite, clock, enable_count, ackout, reset, cont_eql
 );
  output [2:1] cc_mux;
  output [2:1] uscite;
  input eql, clock, reset, cont_eql;
  output enable_count, ackout;
  wire   ackout, N35, N36, N37, N38, N39, N40, N41, N42, n23, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47,
         n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61,
         n62;
  wire   [2:0] state;
  assign enable_count = ackout;

  DFFARX1 \uscite_reg[2]  ( .D(N38), .CLK(clock), .RSTB(n23), .Q(uscite[2]) );
  DFFARX1 \uscite_reg[1]  ( .D(N37), .CLK(clock), .RSTB(n23), .Q(uscite[1]) );
  DFFARX1 \state_reg[2]  ( .D(N41), .CLK(clock), .RSTB(n23), .Q(state[2]), 
        .QN(n61) );
  DFFARX1 \state_reg[1]  ( .D(N40), .CLK(clock), .RSTB(n23), .Q(state[1]), 
        .QN(n60) );
  DFFARX1 \state_reg[0]  ( .D(N39), .CLK(clock), .RSTB(n23), .Q(state[0]), 
        .QN(n62) );
  DFFARX1 \cc_mux_reg[2]  ( .D(N36), .CLK(clock), .RSTB(n23), .Q(cc_mux[2]) );
  DFFARX1 \cc_mux_reg[1]  ( .D(N35), .CLK(clock), .RSTB(n23), .Q(cc_mux[1]) );
  DFFARX1 ackout_reg ( .D(N42), .CLK(clock), .RSTB(n23), .Q(ackout) );
  NOR2X0 U34 ( .IN1(state[0]), .IN2(state[1]), .QN(n50) );
  INVX0 U35 ( .INP(eql), .ZN(n52) );
  NOR2X0 U36 ( .IN1(n50), .IN2(n52), .QN(n57) );
  NOR2X0 U37 ( .IN1(state[0]), .IN2(n61), .QN(n53) );
  NOR2X0 U38 ( .IN1(state[2]), .IN2(n62), .QN(n47) );
  NOR2X0 U39 ( .IN1(n53), .IN2(n47), .QN(n59) );
  OA22X1 U40 ( .IN1(state[2]), .IN2(n57), .IN3(n59), .IN4(n60), .Q(n31) );
  NAND2X0 U41 ( .IN1(n52), .IN2(n60), .QN(n40) );
  NAND2X0 U42 ( .IN1(n31), .IN2(n40), .QN(N37) );
  NOR2X0 U43 ( .IN1(eql), .IN2(n60), .QN(n44) );
  INVX0 U44 ( .INP(n53), .ZN(n32) );
  NOR2X0 U45 ( .IN1(n44), .IN2(n32), .QN(n36) );
  AND3X1 U46 ( .IN1(eql), .IN2(state[2]), .IN3(n60), .Q(n38) );
  NOR2X0 U47 ( .IN1(n36), .IN2(n38), .QN(n34) );
  INVX0 U48 ( .INP(n40), .ZN(n54) );
  NAND2X0 U49 ( .IN1(n54), .IN2(n47), .QN(n33) );
  NAND2X0 U50 ( .IN1(n34), .IN2(n33), .QN(N41) );
  NOR2X0 U51 ( .IN1(state[1]), .IN2(n61), .QN(n35) );
  NOR2X0 U52 ( .IN1(n35), .IN2(n62), .QN(n37) );
  NOR2X0 U53 ( .IN1(n37), .IN2(n36), .QN(n39) );
  NOR2X0 U54 ( .IN1(n39), .IN2(n38), .QN(n42) );
  NAND2X0 U55 ( .IN1(n61), .IN2(n40), .QN(n41) );
  NAND2X0 U56 ( .IN1(n42), .IN2(n41), .QN(N35) );
  INVX0 U57 ( .INP(reset), .ZN(n23) );
  NOR2X0 U58 ( .IN1(state[0]), .IN2(state[2]), .QN(n46) );
  INVX0 U59 ( .INP(cont_eql), .ZN(n45) );
  NAND2X0 U60 ( .IN1(state[1]), .IN2(n59), .QN(n43) );
  AO222X1 U61 ( .IN1(n46), .IN2(n45), .IN3(n46), .IN4(n44), .IN5(n45), .IN6(
        n43), .Q(N42) );
  NOR2X0 U62 ( .IN1(state[0]), .IN2(n60), .QN(n48) );
  AO222X1 U63 ( .IN1(n48), .IN2(eql), .IN3(n48), .IN4(n61), .IN5(eql), .IN6(
        n47), .Q(n49) );
  AO21X1 U64 ( .IN1(n53), .IN2(n54), .IN3(n49), .Q(N40) );
  NOR2X0 U65 ( .IN1(n62), .IN2(n60), .QN(n55) );
  NOR2X0 U66 ( .IN1(n50), .IN2(n55), .QN(n51) );
  MUX21X1 U67 ( .IN1(n61), .IN2(n52), .S(n51), .Q(N39) );
  OA221X1 U68 ( .IN1(n54), .IN2(eql), .IN3(n54), .IN4(state[1]), .IN5(n53), 
        .Q(N38) );
  INVX0 U69 ( .INP(n55), .ZN(n56) );
  NAND2X0 U70 ( .IN1(n57), .IN2(n56), .QN(n58) );
  OAI21X1 U71 ( .IN1(state[1]), .IN2(n59), .IN3(n58), .QN(N36) );
endmodule

