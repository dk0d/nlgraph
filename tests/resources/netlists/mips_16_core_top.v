/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : Q-2019.12-SP2
// Date      : Fri May  1 02:58:42 2020
/////////////////////////////////////////////////////////////


module mips_16_core_top ( clk, rst, pc );
  output [7:0] pc;
  input clk, rst;
  wire   \IF_stage_inst/N29 , \IF_stage_inst/N28 , \IF_stage_inst/N27 ,
         \IF_stage_inst/N26 , \IF_stage_inst/N25 , \IF_stage_inst/N24 ,
         \IF_stage_inst/N23 , \DP_OP_10J1_122_1563/n8 ,
         \DP_OP_10J1_122_1563/n1 , n19, n20, n21, n22, n23, n24, n25, n26;
  assign pc[0] = \DP_OP_10J1_122_1563/n8 ;
  assign pc[7] = \DP_OP_10J1_122_1563/n1 ;

  DFFARX1 \IF_stage_inst/pc_reg[0]  ( .D(n25), .CLK(clk), .RSTB(n26), .Q(
        \DP_OP_10J1_122_1563/n8 ), .QN(n25) );
  DFFARX1 \IF_stage_inst/pc_reg[1]  ( .D(\IF_stage_inst/N23 ), .CLK(clk), 
        .RSTB(n26), .Q(pc[1]) );
  DFFARX1 \IF_stage_inst/pc_reg[2]  ( .D(\IF_stage_inst/N24 ), .CLK(clk), 
        .RSTB(n26), .Q(pc[2]) );
  DFFARX1 \IF_stage_inst/pc_reg[3]  ( .D(\IF_stage_inst/N25 ), .CLK(clk), 
        .RSTB(n26), .Q(pc[3]) );
  DFFARX1 \IF_stage_inst/pc_reg[4]  ( .D(\IF_stage_inst/N26 ), .CLK(clk), 
        .RSTB(n26), .Q(pc[4]) );
  DFFARX1 \IF_stage_inst/pc_reg[5]  ( .D(\IF_stage_inst/N27 ), .CLK(clk), 
        .RSTB(n26), .Q(pc[5]) );
  DFFARX1 \IF_stage_inst/pc_reg[6]  ( .D(\IF_stage_inst/N28 ), .CLK(clk), 
        .RSTB(n26), .Q(pc[6]) );
  DFFARX1 \IF_stage_inst/pc_reg[7]  ( .D(\IF_stage_inst/N29 ), .CLK(clk), 
        .RSTB(n26), .Q(\DP_OP_10J1_122_1563/n1 ) );
  INVX0 U4 ( .INP(rst), .ZN(n26) );
  AND2X1 U5 ( .IN1(\DP_OP_10J1_122_1563/n8 ), .IN2(pc[1]), .Q(n22) );
  AND2X1 U6 ( .IN1(n22), .IN2(pc[2]), .Q(n20) );
  AND2X1 U7 ( .IN1(n20), .IN2(pc[3]), .Q(n19) );
  AND2X1 U8 ( .IN1(n19), .IN2(pc[4]), .Q(n21) );
  XOR2X1 U9 ( .IN1(n21), .IN2(pc[5]), .Q(\IF_stage_inst/N27 ) );
  XOR2X1 U10 ( .IN1(pc[4]), .IN2(n19), .Q(\IF_stage_inst/N26 ) );
  XOR2X1 U11 ( .IN1(pc[3]), .IN2(n20), .Q(\IF_stage_inst/N25 ) );
  AND2X1 U12 ( .IN1(pc[5]), .IN2(n21), .Q(n23) );
  XOR2X1 U13 ( .IN1(n23), .IN2(pc[6]), .Q(\IF_stage_inst/N28 ) );
  XOR2X1 U14 ( .IN1(pc[2]), .IN2(n22), .Q(\IF_stage_inst/N24 ) );
  XOR2X1 U15 ( .IN1(pc[1]), .IN2(\DP_OP_10J1_122_1563/n8 ), .Q(
        \IF_stage_inst/N23 ) );
  AND2X1 U16 ( .IN1(pc[6]), .IN2(n23), .Q(n24) );
  XOR2X1 U17 ( .IN1(n24), .IN2(\DP_OP_10J1_122_1563/n1 ), .Q(
        \IF_stage_inst/N29 ) );
endmodule

