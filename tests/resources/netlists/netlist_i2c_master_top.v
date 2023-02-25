
module i2c_master_top ( clock, wb_rst_i, arst_i, wb_adr_i, wb_dat_i, 
        wb_dat_o, wb_we_i, wb_stb_i, wb_cyc_i, wb_ack_o, wb_inta_o, scl_pad_i, 
        scl_pad_o, scl_padoen_o, sda_pad_i, sda_pad_o, sda_padoen_o );
  input [2:0] wb_adr_i;
  input [7:0] wb_dat_i;
  output [7:0] wb_dat_o;
  input clock, wb_rst_i, arst_i, wb_we_i, wb_stb_i, wb_cyc_i, scl_pad_i,
         sda_pad_i;
  output wb_ack_o, wb_inta_o, scl_pad_o, scl_padoen_o, sda_pad_o, sda_padoen_o;
  wire   N20, sr_1, sr_0, N43, N44, N45, N46, N47, N48, N49, N50, done, i2c_al,
         irxack, N114, N115, N116, N117, N121, \byte_controller/N130 ,
         \byte_controller/N129 , \byte_controller/N128 ,
         \byte_controller/N127 , \byte_controller/N93 ,
         \byte_controller/shift , \byte_controller/ld ,
         \byte_controller/core_rxd , \byte_controller/core_txd ,
         \byte_controller/core_ack , \byte_controller/bit_controller/N497 ,
         \byte_controller/bit_controller/N85 ,
         \byte_controller/bit_controller/sda_chk ,
         \byte_controller/bit_controller/cmd_stop ,
         \byte_controller/bit_controller/N77 ,
         \byte_controller/bit_controller/N75 ,
         \byte_controller/bit_controller/N74 ,
         \byte_controller/bit_controller/sto_condition ,
         \byte_controller/bit_controller/sta_condition ,
         \byte_controller/bit_controller/N71 ,
         \byte_controller/bit_controller/N70 ,
         \byte_controller/bit_controller/N69 ,
         \byte_controller/bit_controller/N68 ,
         \byte_controller/bit_controller/sSDA ,
         \byte_controller/bit_controller/dSDA ,
         \byte_controller/bit_controller/dSCL ,
         \byte_controller/bit_controller/N65 ,
         \byte_controller/bit_controller/clk_en ,
         \byte_controller/bit_controller/sSCL ,
         \byte_controller/bit_controller/dscl_oen , n313, n314, n315, n316,
         n317, n318, n319, n320, n321, n322, n323, n324, n325, n326, n327,
         n328, n329, n330, n331, n332, n333, n334, n335, n336, n337, n338,
         n339, n340, n341, n342, n343, n344, n345, n346, n347, n348, n349,
         n350, n351, n352, n353, n354, n355, n356, n357, n358, n359, n360,
         n361, n362, n363, n364, n365, n366, n367, n368, n369, n370, n371,
         n372, n373, n374, n375, n376, n377, n378, n379, n380, n381, n382,
         n383, n384, n385, n386, n387, n388, n389, n390, n391, n392, n393,
         n394, n395, n396, n397, n398, n399, n400, n401, n402, n403, n404,
         n405, n406, n407, n408, n409, n410, n411, n412, n413, n414, n415,
         n416, n417, n418, n419, n420, n421, n422, n423, n424, n425, n426,
         n427, n428, n429, n430, n431, n432, n433, n434, n435, n436, n437,
         n438, n439, n440, n441, n442, n443, n444, n445, n446, n447, n448,
         n449, n450, n451, n452, n453, n454, n455, n456, n457, n458, n459,
         n460, n461, n462, n463, n464, n465, n466, n467, n468, n469, n470,
         n471, n472, n473, n474, n475, n476, n477, n478, n479, n480, n481,
         n482, n483, n484, n485, n486, n487, n488, n489, n490, n491, n492,
         n493, n494, n495, n496, n497, n498, n499, n500, n501, n502, n503,
         n504, n505, n506, n507, n508, n509, n510, n511, n512, n513, n514,
         n515, n516, n517, n518, n519, n520, n521, n522, n523, n524, n525,
         n526, n527, n528, n529, n530, n531, n532, n533, n534, n535, n536,
         n537, n538, n539, n540, n541, n542, n543, n544, n545, n546, n547,
         n548, n549, n550, n551, n552, n553, n554, n555, n556, n557, n558,
         n559, n560, n561, n562, n563, n564, n565, n566, n567, n568, n569,
         n570, n571, n572, n573, n574, n575, n576, n577, n578, n579, n580,
         n581, n582, n583, n584, n585, n586, n587, n588, n589, n590, n591,
         n592, n593, n594, n595, n596, n597, n598, n599, n600, n601, n602,
         n603, n604, n605, n606, n607, n608, n609, n610, n611, n612, n613,
         n614, n615, n616, n617, n618, n619, n620, n621, n622, n623, n624,
         n625, n626, n627, n628, n629, n630, n631, n632, n633, n634, n635,
         n636, n637, n638, n639, n640, n641, n642, n643, n644, n645, n646,
         n647, n648, n649, n650, n651, n652, n653, n654, n655, n656, n657,
         n658, n659, n660, n661, n662, n663, n664, n665, n666, n667, n668,
         n669, n670, n671, n672, n673, n674, n675, n676, n677, n678, n679,
         n680, n681, n682, n683, n684, n685, n686, n687, n688, n689, n690,
         n691, n692, n693, n694, n695, n696, n697, n698, n699, n700, n701,
         n702, n703, n704, n705, n706, n707;
  wire   [15:0] prer;
  wire   [7:0] ctr;
  wire   [7:0] rxr;
  wire   [7:5] sr;
  wire   [7:0] txr;
  wire   [7:0] cr;
  wire   [4:0] \byte_controller/c_state ;
  wire   [2:0] \byte_controller/dcnt ;
  wire   [3:0] \byte_controller/core_cmd ;
  wire   [16:0] \byte_controller/bit_controller/c_state ;
  wire   [15:0] \byte_controller/bit_controller/cnt ;
  assign sda_pad_o = 1'b0;
  assign scl_pad_o = 1'b0;

  DFFX1 wb_ack_o_reg ( .D(N20), .CLK(clock), .Q(wb_ack_o) );
  DFFX1 \byte_controller/bit_controller/dscl_oen_reg  ( .D(scl_padoen_o), 
        .CLK(clock), .Q(\byte_controller/bit_controller/dscl_oen ), .QN(
        n695) );
  DFFX1 \wb_dat_o_reg[1]  ( .D(N44), .CLK(clock), .Q(wb_dat_o[1]) );
  DFFX1 \wb_dat_o_reg[2]  ( .D(N45), .CLK(clock), .Q(wb_dat_o[2]) );
  DFFX1 \wb_dat_o_reg[3]  ( .D(N46), .CLK(clock), .Q(wb_dat_o[3]) );
  DFFX1 \wb_dat_o_reg[4]  ( .D(N47), .CLK(clock), .Q(wb_dat_o[4]) );
  DFFX1 \wb_dat_o_reg[5]  ( .D(N48), .CLK(clock), .Q(wb_dat_o[5]) );
  DFFX1 \wb_dat_o_reg[6]  ( .D(N49), .CLK(clock), .Q(wb_dat_o[6]) );
  DFFX1 \wb_dat_o_reg[0]  ( .D(N43), .CLK(clock), .Q(wb_dat_o[0]) );
  DFFX1 \wb_dat_o_reg[7]  ( .D(N50), .CLK(clock), .Q(wb_dat_o[7]) );
  DFFARX1 \ctr_reg[7]  ( .D(n409), .CLK(clock), .RSTB(arst_i), .Q(ctr[7])
         );
  DFFARX1 \ctr_reg[6]  ( .D(n408), .CLK(clock), .RSTB(arst_i), .Q(ctr[6])
         );
  DFFARX1 \ctr_reg[5]  ( .D(n407), .CLK(clock), .RSTB(arst_i), .Q(ctr[5])
         );
  DFFARX1 \ctr_reg[4]  ( .D(n406), .CLK(clock), .RSTB(arst_i), .Q(ctr[4])
         );
  DFFARX1 \ctr_reg[3]  ( .D(n405), .CLK(clock), .RSTB(arst_i), .Q(ctr[3])
         );
  DFFARX1 \ctr_reg[2]  ( .D(n404), .CLK(clock), .RSTB(arst_i), .Q(ctr[2])
         );
  DFFARX1 \ctr_reg[1]  ( .D(n403), .CLK(clock), .RSTB(arst_i), .Q(ctr[1])
         );
  DFFARX1 \ctr_reg[0]  ( .D(n402), .CLK(clock), .RSTB(arst_i), .Q(ctr[0])
         );
  DFFARX1 \txr_reg[7]  ( .D(n401), .CLK(clock), .RSTB(arst_i), .Q(txr[7])
         );
  DFFARX1 \txr_reg[6]  ( .D(n400), .CLK(clock), .RSTB(arst_i), .Q(txr[6])
         );
  DFFARX1 \txr_reg[5]  ( .D(n399), .CLK(clock), .RSTB(arst_i), .Q(txr[5])
         );
  DFFARX1 \txr_reg[4]  ( .D(n398), .CLK(clock), .RSTB(arst_i), .Q(txr[4])
         );
  DFFARX1 \txr_reg[3]  ( .D(n397), .CLK(clock), .RSTB(arst_i), .Q(txr[3])
         );
  DFFARX1 \txr_reg[2]  ( .D(n396), .CLK(clock), .RSTB(arst_i), .Q(txr[2])
         );
  DFFARX1 \txr_reg[1]  ( .D(n395), .CLK(clock), .RSTB(arst_i), .Q(txr[1])
         );
  DFFARX1 \txr_reg[0]  ( .D(n394), .CLK(clock), .RSTB(arst_i), .Q(txr[0])
         );
  DFFARX1 tip_reg ( .D(N116), .CLK(clock), .RSTB(arst_i), .Q(sr_1) );
  DFFARX1 \byte_controller/bit_controller/sto_condition_reg  ( .D(
        \byte_controller/bit_controller/N75 ), .CLK(clock), .RSTB(arst_i), 
        .Q(\byte_controller/bit_controller/sto_condition ) );
  DFFARX1 \byte_controller/bit_controller/sta_condition_reg  ( .D(
        \byte_controller/bit_controller/N74 ), .CLK(clock), .RSTB(arst_i), 
        .Q(\byte_controller/bit_controller/sta_condition ) );
  DFFARX1 \byte_controller/bit_controller/busy_reg  ( .D(
        \byte_controller/bit_controller/N77 ), .CLK(clock), .RSTB(arst_i), 
        .Q(sr[6]) );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[0]  ( .D(n334), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [0])
         );
  DFFARX1 \byte_controller/bit_controller/al_reg  ( .D(
        \byte_controller/bit_controller/N85 ), .CLK(clock), .RSTB(arst_i), 
        .Q(i2c_al) );
  DFFARX1 al_reg ( .D(N114), .CLK(clock), .RSTB(arst_i), .Q(sr[5]) );
  DFFARX1 \byte_controller/core_cmd_reg[3]  ( .D(n350), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/core_cmd [3]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[13]  ( .D(n364), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [13]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[2]  ( .D(n375), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [2]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[6]  ( .D(n371), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [6]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[4]  ( .D(n373), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [4]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[1]  ( .D(n376), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [1]), .QN(n692) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[3]  ( .D(n374), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [3]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[7]  ( .D(n370), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [7]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[8]  ( .D(n369), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [8]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[16]  ( .D(n361), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [16]), .QN(n696) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[10]  ( .D(n367), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [10]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[14]  ( .D(n363), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [14]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[15]  ( .D(n362), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [15]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[11]  ( .D(n366), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [11]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[12]  ( .D(n365), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [12]) );
  DFFARX1 \byte_controller/bit_controller/cmd_ack_reg  ( .D(
        \byte_controller/bit_controller/N497 ), .CLK(clock), .RSTB(arst_i), 
        .Q(\byte_controller/core_ack ), .QN(n702) );
  DFFARX1 \byte_controller/c_state_reg[2]  ( .D(n355), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/c_state [2]), .QN(n698) );
  DFFARX1 \byte_controller/shift_reg  ( .D(\byte_controller/N128 ), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/shift ) );
  DFFARX1 \byte_controller/c_state_reg[1]  ( .D(n356), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/c_state [1]), .QN(n690) );
  DFFARX1 \byte_controller/ld_reg  ( .D(\byte_controller/N129 ), .CLK(clock), .RSTB(arst_i), .Q(\byte_controller/ld ) );
  DFFARX1 \byte_controller/core_cmd_reg[1]  ( .D(n352), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/core_cmd [1]), .QN(n688) );
  DFFARX1 \byte_controller/core_cmd_reg[0]  ( .D(n353), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/core_cmd [0]), .QN(n689) );
  DFFARX1 \byte_controller/c_state_reg[3]  ( .D(n354), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/c_state [3]), .QN(n697) );
  DFFARX1 \byte_controller/cmd_ack_reg  ( .D(\byte_controller/N130 ), .CLK(
        clock), .RSTB(arst_i), .Q(done) );
  DFFARX1 irq_flag_reg ( .D(N117), .CLK(clock), .RSTB(arst_i), .Q(sr_0) );
  DFFARX1 wb_inta_o_reg ( .D(N121), .CLK(clock), .RSTB(arst_i), .Q(
        wb_inta_o) );
  DFFARX1 \byte_controller/ack_out_reg  ( .D(n357), .CLK(clock), .RSTB(
        arst_i), .Q(irxack) );
  DFFARX1 rxack_reg ( .D(N115), .CLK(clock), .RSTB(arst_i), .Q(sr[7]) );
  DFFARX1 \byte_controller/core_cmd_reg[2]  ( .D(n351), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/core_cmd [2]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[0]  ( .D(n377), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [0]), .QN(n699) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[5]  ( .D(n372), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [5]) );
  DFFARX1 \byte_controller/bit_controller/c_state_reg[9]  ( .D(n368), .CLK(
        clock), .RSTB(arst_i), .Q(
        \byte_controller/bit_controller/c_state [9]), .QN(n705) );
  DFFARX1 \byte_controller/core_txd_reg  ( .D(\byte_controller/N127 ), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/core_txd ) );
  DFFARX1 \byte_controller/bit_controller/sda_chk_reg  ( .D(n360), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/sda_chk )
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[15]  ( .D(n349), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [15])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[8]  ( .D(n342), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [8])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[11]  ( .D(n345), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [11])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[12]  ( .D(n346), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [12])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[13]  ( .D(n347), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [13])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[10]  ( .D(n344), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [10])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[14]  ( .D(n348), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [14]), 
        .QN(n707) );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[9]  ( .D(n343), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [9])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[3]  ( .D(n337), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [3])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[2]  ( .D(n336), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [2])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[4]  ( .D(n338), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [4])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[7]  ( .D(n341), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [7])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[5]  ( .D(n339), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [5])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[6]  ( .D(n340), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [6])
         );
  DFFARX1 \byte_controller/bit_controller/cnt_reg[1]  ( .D(n335), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cnt [1])
         );
  DFFASX1 \prer_reg[15]  ( .D(n393), .CLK(clock), .SETB(arst_i), .Q(
        prer[15]) );
  DFFASX1 \prer_reg[14]  ( .D(n392), .CLK(clock), .SETB(arst_i), .Q(
        prer[14]) );
  DFFASX1 \prer_reg[13]  ( .D(n391), .CLK(clock), .SETB(arst_i), .Q(
        prer[13]) );
  DFFASX1 \prer_reg[12]  ( .D(n390), .CLK(clock), .SETB(arst_i), .Q(
        prer[12]) );
  DFFASX1 \prer_reg[11]  ( .D(n389), .CLK(clock), .SETB(arst_i), .Q(
        prer[11]) );
  DFFASX1 \prer_reg[10]  ( .D(n388), .CLK(clock), .SETB(arst_i), .Q(
        prer[10]) );
  DFFASX1 \prer_reg[9]  ( .D(n387), .CLK(clock), .SETB(arst_i), .Q(prer[9])
         );
  DFFASX1 \prer_reg[8]  ( .D(n386), .CLK(clock), .SETB(arst_i), .Q(prer[8])
         );
  DFFASX1 \prer_reg[7]  ( .D(n385), .CLK(clock), .SETB(arst_i), .Q(prer[7])
         );
  DFFASX1 \prer_reg[6]  ( .D(n384), .CLK(clock), .SETB(arst_i), .Q(prer[6])
         );
  DFFASX1 \prer_reg[5]  ( .D(n383), .CLK(clock), .SETB(arst_i), .Q(prer[5])
         );
  DFFASX1 \prer_reg[4]  ( .D(n382), .CLK(clock), .SETB(arst_i), .Q(prer[4])
         );
  DFFASX1 \prer_reg[3]  ( .D(n381), .CLK(clock), .SETB(arst_i), .Q(prer[3])
         );
  DFFASX1 \prer_reg[2]  ( .D(n380), .CLK(clock), .SETB(arst_i), .Q(prer[2])
         );
  DFFASX1 \prer_reg[1]  ( .D(n379), .CLK(clock), .SETB(arst_i), .Q(prer[1])
         );
  DFFASX1 \prer_reg[0]  ( .D(n378), .CLK(clock), .SETB(arst_i), .Q(prer[0])
         );
  DFFASX1 \byte_controller/bit_controller/sSCL_reg  ( .D(
        \byte_controller/bit_controller/N68 ), .CLK(clock), .SETB(arst_i), 
        .Q(\byte_controller/bit_controller/sSCL ), .QN(n691) );
  DFFASX1 \byte_controller/bit_controller/dSCL_reg  ( .D(
        \byte_controller/bit_controller/N70 ), .CLK(clock), .SETB(arst_i), 
        .Q(\byte_controller/bit_controller/dSCL ) );
  DFFASX1 \byte_controller/bit_controller/sSDA_reg  ( .D(
        \byte_controller/bit_controller/N69 ), .CLK(clock), .SETB(arst_i), 
        .Q(\byte_controller/bit_controller/sSDA ), .QN(n694) );
  DFFASX1 \byte_controller/bit_controller/dSDA_reg  ( .D(
        \byte_controller/bit_controller/N71 ), .CLK(clock), .SETB(arst_i), 
        .Q(\byte_controller/bit_controller/dSDA ) );
  DFFASX1 \byte_controller/bit_controller/clk_en_reg  ( .D(
        \byte_controller/bit_controller/N65 ), .CLK(clock), .SETB(arst_i), 
        .Q(\byte_controller/bit_controller/clk_en ), .QN(n693) );
  DFFASX1 \byte_controller/bit_controller/sda_oen_reg  ( .D(n359), .CLK(
        clock), .SETB(arst_i), .Q(sda_padoen_o), .QN(n703) );
  DFFASX1 \byte_controller/bit_controller/scl_oen_reg  ( .D(n358), .CLK(
        clock), .SETB(arst_i), .Q(scl_padoen_o) );
  DFFARX1 \cr_reg[7]  ( .D(n333), .CLK(clock), .RSTB(arst_i), .Q(
        \byte_controller/N93 ), .QN(n701) );
  DFFARX1 \cr_reg[6]  ( .D(n332), .CLK(clock), .RSTB(arst_i), .Q(cr[6]) );
  DFFARX1 \cr_reg[5]  ( .D(n331), .CLK(clock), .RSTB(arst_i), .Q(cr[5]), 
        .QN(n700) );
  DFFARX1 \cr_reg[4]  ( .D(n330), .CLK(clock), .RSTB(arst_i), .Q(cr[4]), 
        .QN(n706) );
  DFFARX1 \cr_reg[3]  ( .D(n329), .CLK(clock), .RSTB(arst_i), .Q(cr[3]) );
  DFFARX1 \cr_reg[2]  ( .D(n328), .CLK(clock), .RSTB(arst_i), .Q(cr[2]) );
  DFFARX1 \cr_reg[1]  ( .D(n327), .CLK(clock), .RSTB(arst_i), .Q(cr[1]) );
  DFFARX1 \cr_reg[0]  ( .D(n326), .CLK(clock), .RSTB(arst_i), .Q(cr[0]) );
  DFFARX1 \byte_controller/bit_controller/cmd_stop_reg  ( .D(n325), .CLK(
        clock), .RSTB(arst_i), .Q(\byte_controller/bit_controller/cmd_stop ) );
  DFFARX1 \byte_controller/dcnt_reg[2]  ( .D(n324), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/dcnt [2]) );
  DFFARX1 \byte_controller/dcnt_reg[0]  ( .D(n323), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/dcnt [0]) );
  DFFARX1 \byte_controller/dcnt_reg[1]  ( .D(n322), .CLK(clock), .RSTB(
        arst_i), .Q(\byte_controller/dcnt [1]), .QN(n704) );
  DFFARX1 \byte_controller/sr_reg[0]  ( .D(n321), .CLK(clock), .RSTB(arst_i), .Q(rxr[0]) );
  DFFARX1 \byte_controller/sr_reg[1]  ( .D(n320), .CLK(clock), .RSTB(arst_i), .Q(rxr[1]) );
  DFFARX1 \byte_controller/sr_reg[2]  ( .D(n319), .CLK(clock), .RSTB(arst_i), .Q(rxr[2]) );
  DFFARX1 \byte_controller/sr_reg[3]  ( .D(n318), .CLK(clock), .RSTB(arst_i), .Q(rxr[3]) );
  DFFARX1 \byte_controller/sr_reg[4]  ( .D(n317), .CLK(clock), .RSTB(arst_i), .Q(rxr[4]) );
  DFFARX1 \byte_controller/sr_reg[5]  ( .D(n316), .CLK(clock), .RSTB(arst_i), .Q(rxr[5]) );
  DFFARX1 \byte_controller/sr_reg[6]  ( .D(n315), .CLK(clock), .RSTB(arst_i), .Q(rxr[6]) );
  DFFARX1 \byte_controller/sr_reg[7]  ( .D(n314), .CLK(clock), .RSTB(arst_i), .Q(rxr[7]) );
  DFFX1 \byte_controller/bit_controller/dout_reg  ( .D(n313), .CLK(clock), 
        .Q(\byte_controller/core_rxd ) );
  INVX0 U441 ( .INP(wb_rst_i), .ZN(n673) );
  NAND2X0 U442 ( .IN1(n673), .IN2(n691), .QN(
        \byte_controller/bit_controller/N70 ) );
  NOR3X0 U443 ( .IN1(cr[4]), .IN2(cr[5]), .IN3(cr[6]), .QN(n610) );
  NAND2X0 U444 ( .IN1(n697), .IN2(n690), .QN(n607) );
  NOR2X0 U445 ( .IN1(wb_rst_i), .IN2(i2c_al), .QN(n633) );
  NOR2X0 U446 ( .IN1(\byte_controller/core_cmd [0]), .IN2(
        \byte_controller/c_state [2]), .QN(n611) );
  NAND2X0 U447 ( .IN1(n688), .IN2(n611), .QN(n613) );
  INVX0 U448 ( .INP(n613), .ZN(n461) );
  NAND2X0 U449 ( .IN1(n633), .IN2(n461), .QN(n410) );
  NOR4X0 U450 ( .IN1(n610), .IN2(done), .IN3(n607), .IN4(n410), .QN(n605) );
  NAND2X0 U451 ( .IN1(n605), .IN2(n701), .QN(n636) );
  NOR2X0 U452 ( .IN1(cr[5]), .IN2(n636), .QN(n416) );
  NAND2X0 U453 ( .IN1(cr[4]), .IN2(n416), .QN(n626) );
  NOR2X0 U454 ( .IN1(n607), .IN2(n702), .QN(n417) );
  INVX0 U455 ( .INP(n417), .ZN(n603) );
  NOR3X0 U456 ( .IN1(\byte_controller/dcnt [0]), .IN2(
        \byte_controller/dcnt [1]), .IN3(\byte_controller/dcnt [2]), .QN(n465)
         );
  INVX0 U457 ( .INP(n465), .ZN(n630) );
  NOR4X0 U458 ( .IN1(\byte_controller/core_cmd [0]), .IN2(
        \byte_controller/core_cmd [1]), .IN3(n603), .IN4(n630), .QN(n628) );
  INVX0 U459 ( .INP(n633), .ZN(n623) );
  NOR2X0 U460 ( .IN1(n628), .IN2(n623), .QN(n413) );
  NAND4X0 U461 ( .IN1(\byte_controller/core_cmd [0]), .IN2(n417), .IN3(n700), 
        .IN4(n688), .QN(n411) );
  NAND2X0 U462 ( .IN1(n411), .IN2(n698), .QN(n412) );
  NAND2X0 U463 ( .IN1(n413), .IN2(n412), .QN(n414) );
  NAND2X0 U464 ( .IN1(n626), .IN2(n414), .QN(n355) );
  INVX0 U465 ( .INP(n605), .ZN(n415) );
  NAND3X0 U466 ( .IN1(n633), .IN2(n688), .IN3(n698), .QN(n608) );
  NOR2X0 U467 ( .IN1(n689), .IN2(n608), .QN(n595) );
  NAND2X0 U468 ( .IN1(n417), .IN2(n595), .QN(n635) );
  NAND2X0 U469 ( .IN1(n415), .IN2(n635), .QN(\byte_controller/N129 ) );
  NAND2X0 U470 ( .IN1(n416), .IN2(n706), .QN(n463) );
  NOR2X0 U471 ( .IN1(\byte_controller/c_state [1]), .IN2(n697), .QN(n471) );
  NAND4X0 U472 ( .IN1(cr[6]), .IN2(n611), .IN3(\byte_controller/core_ack ), 
        .IN4(n471), .QN(n419) );
  NAND2X0 U473 ( .IN1(n611), .IN2(n417), .QN(n462) );
  NAND2X0 U474 ( .IN1(\byte_controller/core_cmd [1]), .IN2(n462), .QN(n418) );
  AO21X1 U475 ( .IN1(n419), .IN2(n418), .IN3(n623), .Q(n420) );
  NAND2X0 U476 ( .IN1(n463), .IN2(n420), .QN(n352) );
  OR4X1 U477 ( .IN1(\byte_controller/bit_controller/cnt [3]), .IN2(
        \byte_controller/bit_controller/cnt [0]), .IN3(
        \byte_controller/bit_controller/cnt [1]), .IN4(
        \byte_controller/bit_controller/cnt [2]), .Q(n445) );
  OR3X1 U478 ( .IN1(\byte_controller/bit_controller/cnt [5]), .IN2(
        \byte_controller/bit_controller/cnt [4]), .IN3(n445), .Q(n444) );
  OR3X1 U479 ( .IN1(\byte_controller/bit_controller/cnt [7]), .IN2(
        \byte_controller/bit_controller/cnt [6]), .IN3(n444), .Q(n440) );
  OR3X1 U480 ( .IN1(\byte_controller/bit_controller/cnt [9]), .IN2(
        \byte_controller/bit_controller/cnt [8]), .IN3(n440), .Q(n433) );
  OR3X1 U481 ( .IN1(\byte_controller/bit_controller/cnt [11]), .IN2(
        \byte_controller/bit_controller/cnt [10]), .IN3(n433), .Q(n643) );
  NOR3X0 U482 ( .IN1(\byte_controller/bit_controller/cnt [13]), .IN2(
        \byte_controller/bit_controller/cnt [12]), .IN3(n643), .QN(n428) );
  NAND2X0 U483 ( .IN1(n428), .IN2(n707), .QN(n641) );
  OA21X1 U484 ( .IN1(\byte_controller/bit_controller/cnt [15]), .IN2(n641), 
        .IN3(ctr[7]), .Q(n422) );
  NAND2X0 U485 ( .IN1(n673), .IN2(n422), .QN(n659) );
  INVX0 U486 ( .INP(n659), .ZN(n666) );
  NOR3X0 U487 ( .IN1(ctr[7]), .IN2(\byte_controller/bit_controller/N70 ), 
        .IN3(n695), .QN(n665) );
  AO21X1 U488 ( .IN1(n666), .IN2(n433), .IN3(n665), .Q(n647) );
  OA221X1 U489 ( .IN1(n647), .IN2(\byte_controller/bit_controller/cnt [10]), 
        .IN3(n647), .IN4(n666), .IN5(\byte_controller/bit_controller/cnt [11]), 
        .Q(n421) );
  NOR2X0 U490 ( .IN1(n643), .IN2(n659), .QN(n645) );
  NOR2X0 U491 ( .IN1(n421), .IN2(n645), .QN(n424) );
  AO21X1 U492 ( .IN1(\byte_controller/bit_controller/dscl_oen ), .IN2(n691), 
        .IN3(n422), .Q(n449) );
  NOR2X0 U493 ( .IN1(wb_rst_i), .IN2(n449), .QN(n668) );
  NAND2X0 U494 ( .IN1(n668), .IN2(prer[11]), .QN(n423) );
  NAND2X0 U495 ( .IN1(n424), .IN2(n423), .QN(n345) );
  AO221X1 U496 ( .IN1(n666), .IN2(\byte_controller/bit_controller/cnt [12]), 
        .IN3(n666), .IN4(n643), .IN5(n665), .Q(n425) );
  AOI22X1 U497 ( .IN1(\byte_controller/bit_controller/cnt [13]), .IN2(n425), 
        .IN3(n668), .IN4(prer[13]), .QN(n426) );
  NAND2X0 U498 ( .IN1(n428), .IN2(n666), .QN(n430) );
  NAND2X0 U499 ( .IN1(n426), .IN2(n430), .QN(n347) );
  NAND2X0 U500 ( .IN1(prer[14]), .IN2(n668), .QN(n432) );
  INVX0 U501 ( .INP(n665), .ZN(n427) );
  OA21X1 U502 ( .IN1(n428), .IN2(n659), .IN3(n427), .Q(n429) );
  MUX21X1 U503 ( .IN1(n430), .IN2(n429), .S(
        \byte_controller/bit_controller/cnt [14]), .Q(n431) );
  NAND2X0 U504 ( .IN1(n432), .IN2(n431), .QN(n348) );
  AO21X1 U505 ( .IN1(n666), .IN2(n440), .IN3(n665), .Q(n650) );
  OA221X1 U506 ( .IN1(n650), .IN2(\byte_controller/bit_controller/cnt [8]), 
        .IN3(n650), .IN4(n666), .IN5(\byte_controller/bit_controller/cnt [9]), 
        .Q(n434) );
  NOR2X0 U507 ( .IN1(n433), .IN2(n659), .QN(n648) );
  NOR2X0 U508 ( .IN1(n434), .IN2(n648), .QN(n436) );
  NAND2X0 U509 ( .IN1(n668), .IN2(prer[9]), .QN(n435) );
  NAND2X0 U510 ( .IN1(n436), .IN2(n435), .QN(n343) );
  AO221X1 U511 ( .IN1(n666), .IN2(\byte_controller/bit_controller/cnt [0]), 
        .IN3(n666), .IN4(\byte_controller/bit_controller/cnt [1]), .IN5(n665), 
        .Q(n660) );
  OA221X1 U512 ( .IN1(n660), .IN2(\byte_controller/bit_controller/cnt [2]), 
        .IN3(n660), .IN4(n666), .IN5(\byte_controller/bit_controller/cnt [3]), 
        .Q(n437) );
  NOR2X0 U513 ( .IN1(n445), .IN2(n659), .QN(n657) );
  NOR2X0 U514 ( .IN1(n437), .IN2(n657), .QN(n439) );
  NAND2X0 U515 ( .IN1(n668), .IN2(prer[3]), .QN(n438) );
  NAND2X0 U516 ( .IN1(n439), .IN2(n438), .QN(n337) );
  NOR2X0 U517 ( .IN1(n440), .IN2(n659), .QN(n651) );
  AO21X1 U518 ( .IN1(n666), .IN2(n444), .IN3(n665), .Q(n653) );
  OA221X1 U519 ( .IN1(n653), .IN2(\byte_controller/bit_controller/cnt [6]), 
        .IN3(n653), .IN4(n666), .IN5(\byte_controller/bit_controller/cnt [7]), 
        .Q(n441) );
  NOR2X0 U520 ( .IN1(n651), .IN2(n441), .QN(n443) );
  NAND2X0 U521 ( .IN1(n668), .IN2(prer[7]), .QN(n442) );
  NAND2X0 U522 ( .IN1(n443), .IN2(n442), .QN(n341) );
  NOR2X0 U523 ( .IN1(n444), .IN2(n659), .QN(n654) );
  AO21X1 U524 ( .IN1(n666), .IN2(n445), .IN3(n665), .Q(n656) );
  OA221X1 U525 ( .IN1(n656), .IN2(\byte_controller/bit_controller/cnt [4]), 
        .IN3(n656), .IN4(n666), .IN5(\byte_controller/bit_controller/cnt [5]), 
        .Q(n446) );
  NOR2X0 U526 ( .IN1(n654), .IN2(n446), .QN(n448) );
  NAND2X0 U527 ( .IN1(n668), .IN2(prer[5]), .QN(n447) );
  NAND2X0 U528 ( .IN1(n448), .IN2(n447), .QN(n339) );
  NAND2X0 U529 ( .IN1(n673), .IN2(n449), .QN(
        \byte_controller/bit_controller/N65 ) );
  NOR3X0 U530 ( .IN1(wb_rst_i), .IN2(\byte_controller/ld ), .IN3(
        \byte_controller/shift ), .QN(n686) );
  AO21X1 U531 ( .IN1(\byte_controller/dcnt [0]), .IN2(n673), .IN3(n686), .Q(
        n682) );
  NOR2X0 U532 ( .IN1(\byte_controller/dcnt [1]), .IN2(n682), .QN(n451) );
  NAND2X0 U533 ( .IN1(\byte_controller/dcnt [2]), .IN2(n673), .QN(n450) );
  NOR2X0 U534 ( .IN1(n451), .IN2(n450), .QN(n452) );
  AND2X1 U535 ( .IN1(\byte_controller/ld ), .IN2(n673), .Q(n685) );
  NOR2X0 U536 ( .IN1(n452), .IN2(n685), .QN(n454) );
  NOR2X0 U537 ( .IN1(wb_rst_i), .IN2(n686), .QN(n455) );
  NAND2X0 U538 ( .IN1(n465), .IN2(n455), .QN(n453) );
  NAND2X0 U539 ( .IN1(n454), .IN2(n453), .QN(n324) );
  INVX0 U540 ( .INP(n455), .ZN(n683) );
  NOR2X0 U541 ( .IN1(\byte_controller/dcnt [0]), .IN2(n683), .QN(n681) );
  NOR2X0 U542 ( .IN1(n685), .IN2(n681), .QN(n457) );
  NAND2X0 U543 ( .IN1(\byte_controller/dcnt [0]), .IN2(n686), .QN(n456) );
  NAND2X0 U544 ( .IN1(n457), .IN2(n456), .QN(n323) );
  NAND2X0 U545 ( .IN1(wb_stb_i), .IN2(wb_cyc_i), .QN(n458) );
  NOR2X0 U546 ( .IN1(wb_ack_o), .IN2(n458), .QN(N20) );
  NOR2X0 U547 ( .IN1(i2c_al), .IN2(done), .QN(n671) );
  INVX0 U548 ( .INP(n671), .ZN(n459) );
  NOR2X0 U549 ( .IN1(n459), .IN2(sr_0), .QN(n460) );
  NOR3X0 U550 ( .IN1(n460), .IN2(wb_rst_i), .IN3(cr[0]), .QN(N117) );
  OA221X1 U551 ( .IN1(i2c_al), .IN2(sr[5]), .IN3(i2c_al), .IN4(n701), .IN5(
        n673), .Q(N114) );
  NAND2X0 U552 ( .IN1(n461), .IN2(\byte_controller/core_ack ), .QN(n615) );
  INVX0 U553 ( .INP(n615), .ZN(n469) );
  NAND2X0 U554 ( .IN1(n469), .IN2(n690), .QN(n600) );
  NOR2X0 U555 ( .IN1(n697), .IN2(n600), .QN(n594) );
  INVX0 U556 ( .INP(n594), .ZN(n593) );
  OA22X1 U557 ( .IN1(cr[6]), .IN2(n593), .IN3(n688), .IN4(n462), .Q(n464) );
  OAI21X1 U558 ( .IN1(n464), .IN2(n623), .IN3(n463), .QN(
        \byte_controller/N130 ) );
  NAND3X0 U559 ( .IN1(\byte_controller/c_state [2]), .IN2(n689), .IN3(n688), 
        .QN(n599) );
  NOR3X0 U560 ( .IN1(n465), .IN2(n603), .IN3(n599), .QN(n622) );
  AND3X1 U561 ( .IN1(\byte_controller/c_state [1]), .IN2(n469), .IN3(n697), 
        .Q(n629) );
  OA21X1 U562 ( .IN1(n622), .IN2(n629), .IN3(n633), .Q(\byte_controller/N128 )
         );
  NAND2X0 U563 ( .IN1(\byte_controller/core_ack ), .IN2(n697), .QN(n466) );
  AO221X1 U564 ( .IN1(\byte_controller/c_state [1]), .IN2(n466), .IN3(n690), 
        .IN4(n697), .IN5(n613), .Q(n467) );
  AO22X1 U565 ( .IN1(n629), .IN2(cr[3]), .IN3(rxr[7]), .IN4(n467), .Q(n472) );
  NOR2X0 U566 ( .IN1(\byte_controller/core_cmd [0]), .IN2(n608), .QN(n468) );
  AO22X1 U567 ( .IN1(n633), .IN2(n469), .IN3(cr[3]), .IN4(n468), .Q(n470) );
  AO22X1 U568 ( .IN1(n633), .IN2(n472), .IN3(n471), .IN4(n470), .Q(
        \byte_controller/N127 ) );
  NOR2X0 U569 ( .IN1(wb_rst_i), .IN2(\byte_controller/bit_controller/sSDA ), 
        .QN(n476) );
  INVX0 U570 ( .INP(n476), .ZN(\byte_controller/bit_controller/N71 ) );
  NOR2X0 U571 ( .IN1(n703), .IN2(\byte_controller/bit_controller/N71 ), .QN(
        n474) );
  NOR2X0 U572 ( .IN1(wb_rst_i), .IN2(\byte_controller/bit_controller/cmd_stop ), .QN(n473) );
  AO22X1 U573 ( .IN1(\byte_controller/bit_controller/sda_chk ), .IN2(n474), 
        .IN3(\byte_controller/bit_controller/sto_condition ), .IN4(n473), .Q(
        \byte_controller/bit_controller/N85 ) );
  NOR2X0 U574 ( .IN1(sr[6]), .IN2(
        \byte_controller/bit_controller/sta_condition ), .QN(n475) );
  NOR3X0 U575 ( .IN1(n475), .IN2(wb_rst_i), .IN3(
        \byte_controller/bit_controller/sto_condition ), .QN(
        \byte_controller/bit_controller/N77 ) );
  NOR4X0 U576 ( .IN1(wb_rst_i), .IN2(\byte_controller/bit_controller/dSDA ), 
        .IN3(n691), .IN4(n694), .QN(\byte_controller/bit_controller/N75 ) );
  AND3X1 U577 ( .IN1(\byte_controller/bit_controller/sSCL ), .IN2(n476), .IN3(
        \byte_controller/bit_controller/dSDA ), .Q(
        \byte_controller/bit_controller/N74 ) );
  OR2X1 U578 ( .IN1(wb_rst_i), .IN2(sda_pad_i), .Q(
        \byte_controller/bit_controller/N69 ) );
  OR2X1 U579 ( .IN1(wb_rst_i), .IN2(scl_pad_i), .Q(
        \byte_controller/bit_controller/N68 ) );
  NOR2X0 U580 ( .IN1(\byte_controller/bit_controller/c_state [13]), .IN2(
        \byte_controller/bit_controller/c_state [9]), .QN(n536) );
  NAND4X0 U581 ( .IN1(n633), .IN2(n536), .IN3(
        \byte_controller/bit_controller/clk_en ), .IN4(n699), .QN(n483) );
  OR4X1 U582 ( .IN1(\byte_controller/bit_controller/c_state [1]), .IN2(
        \byte_controller/bit_controller/c_state [3]), .IN3(
        \byte_controller/bit_controller/c_state [2]), .IN4(
        \byte_controller/bit_controller/c_state [6]), .Q(n560) );
  OR2X1 U583 ( .IN1(\byte_controller/bit_controller/c_state [7]), .IN2(n560), 
        .Q(n587) );
  NOR2X0 U584 ( .IN1(\byte_controller/bit_controller/c_state [10]), .IN2(n587), 
        .QN(n478) );
  NAND2X0 U585 ( .IN1(\byte_controller/bit_controller/c_state [8]), .IN2(
        \byte_controller/bit_controller/c_state [4]), .QN(n477) );
  NAND2X0 U586 ( .IN1(n478), .IN2(n477), .QN(n482) );
  NOR2X0 U587 ( .IN1(\byte_controller/bit_controller/c_state [16]), .IN2(
        \byte_controller/bit_controller/c_state [12]), .QN(n535) );
  NOR2X0 U588 ( .IN1(\byte_controller/bit_controller/c_state [8]), .IN2(
        \byte_controller/bit_controller/c_state [4]), .QN(n480) );
  INVX0 U589 ( .INP(n535), .ZN(n574) );
  NAND2X0 U590 ( .IN1(\byte_controller/bit_controller/c_state [16]), .IN2(
        \byte_controller/bit_controller/c_state [12]), .QN(n537) );
  NAND2X0 U591 ( .IN1(n480), .IN2(n537), .QN(n479) );
  NOR2X0 U592 ( .IN1(\byte_controller/bit_controller/c_state [14]), .IN2(
        \byte_controller/bit_controller/c_state [15]), .QN(n578) );
  INVX0 U593 ( .INP(n578), .ZN(n573) );
  OR2X1 U594 ( .IN1(n573), .IN2(\byte_controller/bit_controller/c_state [11]), 
        .Q(n539) );
  AO221X1 U595 ( .IN1(n535), .IN2(n480), .IN3(n574), .IN4(n479), .IN5(n539), 
        .Q(n481) );
  NOR4X0 U596 ( .IN1(\byte_controller/bit_controller/c_state [5]), .IN2(n483), 
        .IN3(n482), .IN4(n481), .QN(\byte_controller/bit_controller/N497 ) );
  AND3X1 U597 ( .IN1(sr_0), .IN2(ctr[6]), .IN3(n673), .Q(N121) );
  INVX0 U598 ( .INP(wb_adr_i[2]), .ZN(n488) );
  INVX0 U599 ( .INP(wb_adr_i[0]), .ZN(n484) );
  NAND2X0 U600 ( .IN1(wb_adr_i[1]), .IN2(n484), .QN(n485) );
  NOR2X0 U601 ( .IN1(n488), .IN2(n485), .QN(n515) );
  NAND3X0 U602 ( .IN1(wb_adr_i[1]), .IN2(wb_adr_i[0]), .IN3(n488), .QN(n526)
         );
  INVX0 U603 ( .INP(n526), .ZN(n514) );
  AOI22X1 U604 ( .IN1(cr[0]), .IN2(n515), .IN3(rxr[0]), .IN4(n514), .QN(n492)
         );
  INVX0 U605 ( .INP(wb_adr_i[1]), .ZN(n486) );
  AND3X1 U606 ( .IN1(n484), .IN2(n486), .IN3(n488), .Q(n532) );
  NOR2X0 U607 ( .IN1(wb_adr_i[2]), .IN2(n485), .QN(n521) );
  AOI22X1 U608 ( .IN1(prer[0]), .IN2(n532), .IN3(n521), .IN4(ctr[0]), .QN(n491) );
  NAND2X0 U609 ( .IN1(wb_adr_i[0]), .IN2(n486), .QN(n487) );
  NOR2X0 U610 ( .IN1(wb_adr_i[2]), .IN2(n487), .QN(n529) );
  NOR3X0 U611 ( .IN1(wb_adr_i[0]), .IN2(wb_adr_i[1]), .IN3(n488), .QN(n669) );
  AOI22X1 U612 ( .IN1(prer[8]), .IN2(n529), .IN3(n669), .IN4(sr_0), .QN(n490)
         );
  NOR2X0 U613 ( .IN1(n488), .IN2(n487), .QN(n516) );
  NAND2X0 U614 ( .IN1(txr[0]), .IN2(n516), .QN(n489) );
  NAND4X0 U615 ( .IN1(n492), .IN2(n491), .IN3(n490), .IN4(n489), .QN(N43) );
  AOI22X1 U616 ( .IN1(cr[1]), .IN2(n515), .IN3(n514), .IN4(rxr[1]), .QN(n496)
         );
  AOI22X1 U617 ( .IN1(prer[1]), .IN2(n532), .IN3(n521), .IN4(ctr[1]), .QN(n495) );
  AOI22X1 U618 ( .IN1(prer[9]), .IN2(n529), .IN3(n669), .IN4(sr_1), .QN(n494)
         );
  NAND2X0 U619 ( .IN1(n516), .IN2(txr[1]), .QN(n493) );
  NAND4X0 U620 ( .IN1(n496), .IN2(n495), .IN3(n494), .IN4(n493), .QN(N44) );
  AO22X1 U621 ( .IN1(prer[2]), .IN2(n532), .IN3(cr[2]), .IN4(n515), .Q(n499)
         );
  AO22X1 U622 ( .IN1(n514), .IN2(rxr[2]), .IN3(n521), .IN4(ctr[2]), .Q(n498)
         );
  AO22X1 U623 ( .IN1(prer[10]), .IN2(n529), .IN3(n516), .IN4(txr[2]), .Q(n497)
         );
  OR3X1 U624 ( .IN1(n499), .IN2(n498), .IN3(n497), .Q(N45) );
  AO22X1 U625 ( .IN1(prer[3]), .IN2(n532), .IN3(cr[3]), .IN4(n515), .Q(n502)
         );
  AO22X1 U626 ( .IN1(n514), .IN2(rxr[3]), .IN3(n521), .IN4(ctr[3]), .Q(n501)
         );
  AO22X1 U627 ( .IN1(prer[11]), .IN2(n529), .IN3(n516), .IN4(txr[3]), .Q(n500)
         );
  OR3X1 U628 ( .IN1(n502), .IN2(n501), .IN3(n500), .Q(N46) );
  AO22X1 U629 ( .IN1(prer[4]), .IN2(n532), .IN3(cr[4]), .IN4(n515), .Q(n505)
         );
  AO22X1 U630 ( .IN1(n514), .IN2(rxr[4]), .IN3(n521), .IN4(ctr[4]), .Q(n504)
         );
  AO22X1 U631 ( .IN1(prer[12]), .IN2(n529), .IN3(n516), .IN4(txr[4]), .Q(n503)
         );
  OR3X1 U632 ( .IN1(n505), .IN2(n504), .IN3(n503), .Q(N47) );
  AOI22X1 U633 ( .IN1(cr[5]), .IN2(n515), .IN3(n514), .IN4(rxr[5]), .QN(n509)
         );
  AOI22X1 U634 ( .IN1(prer[5]), .IN2(n532), .IN3(n521), .IN4(ctr[5]), .QN(n508) );
  AOI22X1 U635 ( .IN1(prer[13]), .IN2(n529), .IN3(n669), .IN4(sr[5]), .QN(n507) );
  NAND2X0 U636 ( .IN1(n516), .IN2(txr[5]), .QN(n506) );
  NAND4X0 U637 ( .IN1(n509), .IN2(n508), .IN3(n507), .IN4(n506), .QN(N48) );
  AOI22X1 U638 ( .IN1(cr[6]), .IN2(n515), .IN3(n514), .IN4(rxr[6]), .QN(n513)
         );
  AOI22X1 U639 ( .IN1(prer[6]), .IN2(n532), .IN3(n521), .IN4(ctr[6]), .QN(n512) );
  AOI22X1 U640 ( .IN1(prer[14]), .IN2(n529), .IN3(n669), .IN4(sr[6]), .QN(n511) );
  NAND2X0 U641 ( .IN1(n516), .IN2(txr[6]), .QN(n510) );
  NAND4X0 U642 ( .IN1(n513), .IN2(n512), .IN3(n511), .IN4(n510), .QN(N49) );
  AOI22X1 U643 ( .IN1(\byte_controller/N93 ), .IN2(n515), .IN3(rxr[7]), .IN4(
        n514), .QN(n520) );
  AOI22X1 U644 ( .IN1(ctr[7]), .IN2(n521), .IN3(prer[7]), .IN4(n532), .QN(n519) );
  AOI22X1 U645 ( .IN1(prer[15]), .IN2(n529), .IN3(n669), .IN4(sr[7]), .QN(n518) );
  NAND2X0 U646 ( .IN1(n516), .IN2(txr[7]), .QN(n517) );
  NAND4X0 U647 ( .IN1(n520), .IN2(n519), .IN3(n518), .IN4(n517), .QN(N50) );
  NAND3X0 U648 ( .IN1(wb_stb_i), .IN2(wb_cyc_i), .IN3(wb_we_i), .QN(n670) );
  INVX0 U649 ( .INP(n521), .ZN(n522) );
  OA21X1 U650 ( .IN1(n670), .IN2(n522), .IN3(n673), .Q(n523) );
  INVX0 U651 ( .INP(n670), .ZN(n677) );
  NAND2X0 U652 ( .IN1(n677), .IN2(n673), .QN(n525) );
  NOR2X0 U653 ( .IN1(n525), .IN2(n522), .QN(n524) );
  AO22X1 U654 ( .IN1(ctr[7]), .IN2(n523), .IN3(wb_dat_i[7]), .IN4(n524), .Q(
        n409) );
  AO22X1 U655 ( .IN1(wb_dat_i[6]), .IN2(n524), .IN3(ctr[6]), .IN4(n523), .Q(
        n408) );
  AO22X1 U656 ( .IN1(wb_dat_i[5]), .IN2(n524), .IN3(ctr[5]), .IN4(n523), .Q(
        n407) );
  AO22X1 U657 ( .IN1(wb_dat_i[4]), .IN2(n524), .IN3(ctr[4]), .IN4(n523), .Q(
        n406) );
  AO22X1 U658 ( .IN1(wb_dat_i[3]), .IN2(n524), .IN3(ctr[3]), .IN4(n523), .Q(
        n405) );
  AO22X1 U659 ( .IN1(wb_dat_i[2]), .IN2(n524), .IN3(ctr[2]), .IN4(n523), .Q(
        n404) );
  AO22X1 U660 ( .IN1(wb_dat_i[1]), .IN2(n524), .IN3(ctr[1]), .IN4(n523), .Q(
        n403) );
  AO22X1 U661 ( .IN1(wb_dat_i[0]), .IN2(n524), .IN3(ctr[0]), .IN4(n523), .Q(
        n402) );
  NOR2X0 U662 ( .IN1(n525), .IN2(n526), .QN(n528) );
  OA21X1 U663 ( .IN1(n670), .IN2(n526), .IN3(n673), .Q(n527) );
  AO22X1 U664 ( .IN1(wb_dat_i[7]), .IN2(n528), .IN3(txr[7]), .IN4(n527), .Q(
        n401) );
  AO22X1 U665 ( .IN1(wb_dat_i[6]), .IN2(n528), .IN3(txr[6]), .IN4(n527), .Q(
        n400) );
  AO22X1 U666 ( .IN1(wb_dat_i[5]), .IN2(n528), .IN3(txr[5]), .IN4(n527), .Q(
        n399) );
  AO22X1 U667 ( .IN1(wb_dat_i[4]), .IN2(n528), .IN3(txr[4]), .IN4(n527), .Q(
        n398) );
  AO22X1 U668 ( .IN1(wb_dat_i[3]), .IN2(n528), .IN3(txr[3]), .IN4(n527), .Q(
        n397) );
  AO22X1 U669 ( .IN1(wb_dat_i[2]), .IN2(n528), .IN3(txr[2]), .IN4(n527), .Q(
        n396) );
  AO22X1 U670 ( .IN1(wb_dat_i[1]), .IN2(n528), .IN3(txr[1]), .IN4(n527), .Q(
        n395) );
  AO22X1 U671 ( .IN1(wb_dat_i[0]), .IN2(n528), .IN3(txr[0]), .IN4(n527), .Q(
        n394) );
  NAND2X0 U672 ( .IN1(n677), .IN2(n529), .QN(n530) );
  INVX0 U673 ( .INP(n530), .ZN(n531) );
  AO221X1 U674 ( .IN1(n531), .IN2(wb_dat_i[7]), .IN3(n530), .IN4(prer[15]), 
        .IN5(wb_rst_i), .Q(n393) );
  AO221X1 U675 ( .IN1(n531), .IN2(wb_dat_i[6]), .IN3(n530), .IN4(prer[14]), 
        .IN5(wb_rst_i), .Q(n392) );
  AO221X1 U676 ( .IN1(n531), .IN2(wb_dat_i[5]), .IN3(n530), .IN4(prer[13]), 
        .IN5(wb_rst_i), .Q(n391) );
  AO221X1 U677 ( .IN1(n531), .IN2(wb_dat_i[4]), .IN3(n530), .IN4(prer[12]), 
        .IN5(wb_rst_i), .Q(n390) );
  AO221X1 U678 ( .IN1(n531), .IN2(wb_dat_i[3]), .IN3(n530), .IN4(prer[11]), 
        .IN5(wb_rst_i), .Q(n389) );
  AO221X1 U679 ( .IN1(n531), .IN2(wb_dat_i[2]), .IN3(n530), .IN4(prer[10]), 
        .IN5(wb_rst_i), .Q(n388) );
  AO221X1 U680 ( .IN1(n531), .IN2(wb_dat_i[1]), .IN3(n530), .IN4(prer[9]), 
        .IN5(wb_rst_i), .Q(n387) );
  AO221X1 U681 ( .IN1(n531), .IN2(wb_dat_i[0]), .IN3(n530), .IN4(prer[8]), 
        .IN5(wb_rst_i), .Q(n386) );
  NAND2X0 U682 ( .IN1(n677), .IN2(n532), .QN(n533) );
  INVX0 U683 ( .INP(n533), .ZN(n534) );
  AO221X1 U684 ( .IN1(n534), .IN2(wb_dat_i[7]), .IN3(n533), .IN4(prer[7]), 
        .IN5(wb_rst_i), .Q(n385) );
  AO221X1 U685 ( .IN1(n534), .IN2(wb_dat_i[6]), .IN3(n533), .IN4(prer[6]), 
        .IN5(wb_rst_i), .Q(n384) );
  AO221X1 U686 ( .IN1(n534), .IN2(wb_dat_i[5]), .IN3(n533), .IN4(prer[5]), 
        .IN5(wb_rst_i), .Q(n383) );
  AO221X1 U687 ( .IN1(n534), .IN2(wb_dat_i[4]), .IN3(n533), .IN4(prer[4]), 
        .IN5(wb_rst_i), .Q(n382) );
  AO221X1 U688 ( .IN1(n534), .IN2(wb_dat_i[3]), .IN3(n533), .IN4(prer[3]), 
        .IN5(wb_rst_i), .Q(n381) );
  AO221X1 U689 ( .IN1(n534), .IN2(wb_dat_i[2]), .IN3(n533), .IN4(prer[2]), 
        .IN5(wb_rst_i), .Q(n380) );
  AO221X1 U690 ( .IN1(n534), .IN2(wb_dat_i[1]), .IN3(n533), .IN4(prer[1]), 
        .IN5(wb_rst_i), .Q(n379) );
  AO221X1 U691 ( .IN1(n534), .IN2(wb_dat_i[0]), .IN3(n533), .IN4(prer[0]), 
        .IN5(wb_rst_i), .Q(n378) );
  OR2X1 U692 ( .IN1(\byte_controller/bit_controller/c_state [5]), .IN2(
        \byte_controller/bit_controller/c_state [4]), .Q(n583) );
  NAND2X0 U693 ( .IN1(n536), .IN2(n535), .QN(n580) );
  OR2X1 U694 ( .IN1(\byte_controller/bit_controller/c_state [7]), .IN2(n580), 
        .Q(n543) );
  OR4X1 U695 ( .IN1(\byte_controller/bit_controller/c_state [11]), .IN2(
        \byte_controller/bit_controller/c_state [8]), .IN3(
        \byte_controller/bit_controller/c_state [10]), .IN4(n573), .Q(n588) );
  NOR2X0 U696 ( .IN1(n543), .IN2(n588), .QN(n561) );
  INVX0 U697 ( .INP(n561), .ZN(n545) );
  OR2X1 U698 ( .IN1(n545), .IN2(n560), .Q(n565) );
  NOR3X0 U699 ( .IN1(n583), .IN2(n565), .IN3(n693), .QN(n592) );
  NOR2X0 U700 ( .IN1(n592), .IN2(n623), .QN(n563) );
  NAND2X0 U701 ( .IN1(n705), .IN2(n537), .QN(n538) );
  AO222X1 U702 ( .IN1(\byte_controller/bit_controller/c_state [13]), .IN2(n574), .IN3(\byte_controller/bit_controller/c_state [13]), .IN4(
        \byte_controller/bit_controller/c_state [9]), .IN5(n574), .IN6(n538), 
        .Q(n541) );
  AO21X1 U703 ( .IN1(\byte_controller/bit_controller/c_state [8]), .IN2(
        \byte_controller/bit_controller/c_state [10]), .IN3(n539), .Q(n540) );
  OA22X1 U704 ( .IN1(n541), .IN2(n588), .IN3(n580), .IN4(n540), .Q(n542) );
  OA22X1 U705 ( .IN1(\byte_controller/bit_controller/c_state [7]), .IN2(n542), 
        .IN3(n588), .IN4(n580), .Q(n552) );
  OA221X1 U706 ( .IN1(\byte_controller/bit_controller/c_state [11]), .IN2(
        \byte_controller/bit_controller/c_state [14]), .IN3(
        \byte_controller/bit_controller/c_state [11]), .IN4(
        \byte_controller/bit_controller/c_state [15]), .IN5(n573), .Q(n544) );
  OR4X1 U707 ( .IN1(\byte_controller/bit_controller/c_state [10]), .IN2(
        \byte_controller/bit_controller/c_state [8]), .IN3(n544), .IN4(n543), 
        .Q(n551) );
  AO222X1 U708 ( .IN1(\byte_controller/bit_controller/c_state [3]), .IN2(
        \byte_controller/bit_controller/c_state [2]), .IN3(
        \byte_controller/bit_controller/c_state [3]), .IN4(
        \byte_controller/bit_controller/c_state [6]), .IN5(
        \byte_controller/bit_controller/c_state [2]), .IN6(
        \byte_controller/bit_controller/c_state [6]), .Q(n546) );
  NOR2X0 U709 ( .IN1(n546), .IN2(n545), .QN(n549) );
  OR3X1 U710 ( .IN1(\byte_controller/bit_controller/c_state [3]), .IN2(
        \byte_controller/bit_controller/c_state [2]), .IN3(
        \byte_controller/bit_controller/c_state [6]), .Q(n547) );
  NAND2X0 U711 ( .IN1(n547), .IN2(\byte_controller/bit_controller/c_state [1]), 
        .QN(n548) );
  NAND2X0 U712 ( .IN1(n549), .IN2(n548), .QN(n550) );
  OA221X1 U713 ( .IN1(n560), .IN2(n552), .IN3(n560), .IN4(n551), .IN5(n550), 
        .Q(n554) );
  NAND2X0 U714 ( .IN1(\byte_controller/bit_controller/clk_en ), .IN2(n699), 
        .QN(n553) );
  NOR2X0 U715 ( .IN1(n554), .IN2(n553), .QN(n557) );
  AO21X1 U716 ( .IN1(\byte_controller/bit_controller/c_state [5]), .IN2(
        \byte_controller/bit_controller/c_state [4]), .IN3(n565), .Q(n555) );
  NAND2X0 U717 ( .IN1(n555), .IN2(n583), .QN(n556) );
  NAND2X0 U718 ( .IN1(n557), .IN2(n556), .QN(n558) );
  NAND2X0 U719 ( .IN1(n563), .IN2(n558), .QN(n589) );
  NAND2X0 U720 ( .IN1(n633), .IN2(n589), .QN(n559) );
  NOR4X0 U721 ( .IN1(\byte_controller/bit_controller/c_state [5]), .IN2(
        \byte_controller/bit_controller/c_state [4]), .IN3(
        \byte_controller/bit_controller/c_state [0]), .IN4(n559), .QN(n567) );
  INVX0 U722 ( .INP(n567), .ZN(n564) );
  NOR2X0 U723 ( .IN1(n560), .IN2(n564), .QN(n572) );
  NAND3X0 U724 ( .IN1(n561), .IN2(n572), .IN3(n688), .QN(n568) );
  NOR2X0 U725 ( .IN1(\byte_controller/core_cmd [3]), .IN2(n568), .QN(n570) );
  NOR2X0 U726 ( .IN1(\byte_controller/core_cmd [2]), .IN2(n689), .QN(n562) );
  AO22X1 U727 ( .IN1(\byte_controller/bit_controller/c_state [0]), .IN2(n563), 
        .IN3(n570), .IN4(n562), .Q(n377) );
  OR2X1 U728 ( .IN1(n563), .IN2(n699), .Q(n585) );
  OAI22X1 U729 ( .IN1(n692), .IN2(n589), .IN3(n623), .IN4(n585), .QN(n376) );
  INVX0 U730 ( .INP(n589), .ZN(n591) );
  AO22X1 U731 ( .IN1(\byte_controller/bit_controller/c_state [1]), .IN2(n567), 
        .IN3(\byte_controller/bit_controller/c_state [2]), .IN4(n591), .Q(n375) );
  AO22X1 U732 ( .IN1(\byte_controller/bit_controller/c_state [3]), .IN2(n591), 
        .IN3(\byte_controller/bit_controller/c_state [2]), .IN4(n567), .Q(n374) );
  AO22X1 U733 ( .IN1(\byte_controller/bit_controller/c_state [3]), .IN2(n567), 
        .IN3(\byte_controller/bit_controller/c_state [4]), .IN4(n591), .Q(n373) );
  NOR4X0 U734 ( .IN1(\byte_controller/core_cmd [0]), .IN2(
        \byte_controller/core_cmd [2]), .IN3(\byte_controller/core_cmd [3]), 
        .IN4(n688), .QN(n680) );
  NOR2X0 U735 ( .IN1(n565), .IN2(n564), .QN(n566) );
  AO22X1 U736 ( .IN1(\byte_controller/bit_controller/c_state [5]), .IN2(n591), 
        .IN3(n680), .IN4(n566), .Q(n372) );
  OA221X1 U737 ( .IN1(\byte_controller/bit_controller/c_state [6]), .IN2(n589), 
        .IN3(n591), .IN4(\byte_controller/bit_controller/c_state [5]), .IN5(
        n633), .Q(n371) );
  AO22X1 U738 ( .IN1(\byte_controller/bit_controller/c_state [7]), .IN2(n591), 
        .IN3(\byte_controller/bit_controller/c_state [6]), .IN4(n567), .Q(n370) );
  AO22X1 U739 ( .IN1(\byte_controller/bit_controller/c_state [7]), .IN2(n572), 
        .IN3(\byte_controller/bit_controller/c_state [8]), .IN4(n591), .Q(n369) );
  NOR3X0 U740 ( .IN1(\byte_controller/core_cmd [0]), .IN2(
        \byte_controller/core_cmd [2]), .IN3(n568), .QN(n569) );
  AO22X1 U741 ( .IN1(\byte_controller/core_cmd [3]), .IN2(n569), .IN3(
        \byte_controller/bit_controller/c_state [9]), .IN4(n591), .Q(n368) );
  AO22X1 U742 ( .IN1(\byte_controller/bit_controller/c_state [9]), .IN2(n572), 
        .IN3(\byte_controller/bit_controller/c_state [10]), .IN4(n591), .Q(
        n367) );
  AO22X1 U743 ( .IN1(\byte_controller/bit_controller/c_state [11]), .IN2(n591), 
        .IN3(\byte_controller/bit_controller/c_state [10]), .IN4(n572), .Q(
        n366) );
  AO22X1 U744 ( .IN1(\byte_controller/bit_controller/c_state [12]), .IN2(n591), 
        .IN3(\byte_controller/bit_controller/c_state [11]), .IN4(n572), .Q(
        n365) );
  AND3X1 U745 ( .IN1(\byte_controller/core_cmd [2]), .IN2(n570), .IN3(n689), 
        .Q(n571) );
  AO21X1 U746 ( .IN1(n591), .IN2(\byte_controller/bit_controller/c_state [13]), 
        .IN3(n571), .Q(n364) );
  AO22X1 U747 ( .IN1(\byte_controller/bit_controller/c_state [13]), .IN2(n572), 
        .IN3(\byte_controller/bit_controller/c_state [14]), .IN4(n591), .Q(
        n363) );
  AO22X1 U748 ( .IN1(\byte_controller/bit_controller/c_state [14]), .IN2(n572), 
        .IN3(\byte_controller/bit_controller/c_state [15]), .IN4(n591), .Q(
        n362) );
  AO22X1 U749 ( .IN1(\byte_controller/bit_controller/c_state [16]), .IN2(n591), 
        .IN3(\byte_controller/bit_controller/c_state [15]), .IN4(n572), .Q(
        n361) );
  AO22X1 U750 ( .IN1(\byte_controller/bit_controller/sda_chk ), .IN2(n591), 
        .IN3(n572), .IN4(n573), .Q(n360) );
  OA21X1 U751 ( .IN1(\byte_controller/bit_controller/c_state [13]), .IN2(n573), 
        .IN3(\byte_controller/core_txd ), .Q(n577) );
  OA21X1 U752 ( .IN1(\byte_controller/core_txd ), .IN2(n696), .IN3(n574), .Q(
        n576) );
  OR3X1 U753 ( .IN1(\byte_controller/bit_controller/c_state [11]), .IN2(
        \byte_controller/bit_controller/c_state [8]), .IN3(
        \byte_controller/bit_controller/c_state [10]), .Q(n575) );
  NOR4X0 U754 ( .IN1(\byte_controller/bit_controller/c_state [9]), .IN2(n577), 
        .IN3(n576), .IN4(n575), .QN(n581) );
  NAND2X0 U755 ( .IN1(n578), .IN2(sda_padoen_o), .QN(n579) );
  OA22X1 U756 ( .IN1(n591), .IN2(n581), .IN3(n580), .IN4(n579), .Q(n582) );
  OA22X1 U757 ( .IN1(n591), .IN2(n692), .IN3(n582), .IN4(n587), .Q(n584) );
  OA22X1 U758 ( .IN1(n584), .IN2(n583), .IN3(n589), .IN4(n703), .Q(n586) );
  NAND3X0 U759 ( .IN1(n633), .IN2(n586), .IN3(n585), .QN(n359) );
  AO221X1 U760 ( .IN1(n589), .IN2(n588), .IN3(n589), .IN4(n587), .IN5(n623), 
        .Q(n590) );
  AO221X1 U761 ( .IN1(scl_padoen_o), .IN2(n592), .IN3(scl_padoen_o), .IN4(n591), .IN5(n590), .Q(n358) );
  OA221X1 U763 ( .IN1(n594), .IN2(irxack), .IN3(n593), .IN4(
        \byte_controller/core_rxd ), .IN5(n633), .Q(n357) );
  AND2X1 U764 ( .IN1(irxack), .IN2(n673), .Q(N115) );
  NAND3X0 U765 ( .IN1(cr[5]), .IN2(n605), .IN3(n701), .QN(n598) );
  NOR3X0 U766 ( .IN1(\byte_controller/c_state [3]), .IN2(n615), .IN3(n630), 
        .QN(n620) );
  OR3X1 U767 ( .IN1(n620), .IN2(n690), .IN3(n623), .Q(n597) );
  NAND4X0 U768 ( .IN1(cr[5]), .IN2(\byte_controller/core_ack ), .IN3(n595), 
        .IN4(n697), .QN(n596) );
  NAND3X0 U769 ( .IN1(n598), .IN2(n597), .IN3(n596), .QN(n356) );
  AO221X1 U770 ( .IN1(\byte_controller/c_state [1]), .IN2(n613), .IN3(n690), 
        .IN4(n599), .IN5(n702), .Q(n601) );
  NAND2X0 U771 ( .IN1(\byte_controller/c_state [3]), .IN2(n600), .QN(n616) );
  OA21X1 U772 ( .IN1(n630), .IN2(n601), .IN3(n616), .Q(n602) );
  NOR2X0 U773 ( .IN1(n623), .IN2(n602), .QN(n354) );
  NAND2X0 U774 ( .IN1(n688), .IN2(n698), .QN(n604) );
  OA21X1 U775 ( .IN1(n604), .IN2(n603), .IN3(n633), .Q(n606) );
  AO22X1 U776 ( .IN1(\byte_controller/core_cmd [0]), .IN2(n606), .IN3(
        \byte_controller/N93 ), .IN4(n605), .Q(n353) );
  INVX0 U777 ( .INP(n607), .ZN(n612) );
  INVX0 U778 ( .INP(n608), .ZN(n609) );
  AND3X1 U779 ( .IN1(n610), .IN2(n612), .IN3(n609), .Q(n634) );
  NAND2X0 U780 ( .IN1(n634), .IN2(\byte_controller/core_cmd [2]), .QN(n627) );
  OA22X1 U781 ( .IN1(n611), .IN2(n688), .IN3(n689), .IN4(n698), .Q(n619) );
  NAND2X0 U782 ( .IN1(n612), .IN2(done), .QN(n614) );
  MUX21X1 U783 ( .IN1(n614), .IN2(\byte_controller/core_ack ), .S(n613), .Q(
        n618) );
  NAND2X0 U784 ( .IN1(\byte_controller/c_state [1]), .IN2(n615), .QN(n617) );
  NAND4X0 U785 ( .IN1(n619), .IN2(n618), .IN3(n617), .IN4(n616), .QN(n631) );
  AO22X1 U786 ( .IN1(\byte_controller/core_cmd [2]), .IN2(n631), .IN3(
        \byte_controller/c_state [1]), .IN4(n620), .Q(n621) );
  NOR2X0 U787 ( .IN1(n622), .IN2(n621), .QN(n624) );
  OA22X1 U788 ( .IN1(cr[5]), .IN2(n635), .IN3(n624), .IN4(n623), .Q(n625) );
  NAND3X0 U789 ( .IN1(n627), .IN2(n626), .IN3(n625), .QN(n351) );
  AO222X1 U790 ( .IN1(n631), .IN2(\byte_controller/core_cmd [3]), .IN3(n630), 
        .IN4(n629), .IN5(n628), .IN6(\byte_controller/c_state [2]), .Q(n632)
         );
  NAND2X0 U791 ( .IN1(n633), .IN2(n632), .QN(n639) );
  NAND3X0 U792 ( .IN1(\byte_controller/core_cmd [3]), .IN2(n634), .IN3(n689), 
        .QN(n638) );
  AO21X1 U793 ( .IN1(n636), .IN2(n635), .IN3(n700), .Q(n637) );
  NAND3X0 U794 ( .IN1(n639), .IN2(n638), .IN3(n637), .QN(n350) );
  NOR2X0 U795 ( .IN1(cr[4]), .IN2(cr[5]), .QN(n640) );
  NOR2X0 U796 ( .IN1(wb_rst_i), .IN2(n640), .QN(N116) );
  AO21X1 U797 ( .IN1(n666), .IN2(n641), .IN3(n665), .Q(n642) );
  AO22X1 U798 ( .IN1(\byte_controller/bit_controller/cnt [15]), .IN2(n642), 
        .IN3(n668), .IN4(prer[15]), .Q(n349) );
  AO21X1 U799 ( .IN1(n666), .IN2(n643), .IN3(n665), .Q(n644) );
  MUX21X1 U800 ( .IN1(n645), .IN2(n644), .S(
        \byte_controller/bit_controller/cnt [12]), .Q(n646) );
  AO21X1 U801 ( .IN1(n668), .IN2(prer[12]), .IN3(n646), .Q(n346) );
  MUX21X1 U802 ( .IN1(n648), .IN2(n647), .S(
        \byte_controller/bit_controller/cnt [10]), .Q(n649) );
  AO21X1 U803 ( .IN1(n668), .IN2(prer[10]), .IN3(n649), .Q(n344) );
  MUX21X1 U804 ( .IN1(n651), .IN2(n650), .S(
        \byte_controller/bit_controller/cnt [8]), .Q(n652) );
  AO21X1 U805 ( .IN1(n668), .IN2(prer[8]), .IN3(n652), .Q(n342) );
  MUX21X1 U806 ( .IN1(n654), .IN2(n653), .S(
        \byte_controller/bit_controller/cnt [6]), .Q(n655) );
  AO21X1 U807 ( .IN1(n668), .IN2(prer[6]), .IN3(n655), .Q(n340) );
  MUX21X1 U808 ( .IN1(n657), .IN2(n656), .S(
        \byte_controller/bit_controller/cnt [4]), .Q(n658) );
  AO21X1 U809 ( .IN1(n668), .IN2(prer[4]), .IN3(n658), .Q(n338) );
  NOR3X0 U810 ( .IN1(\byte_controller/bit_controller/cnt [0]), .IN2(
        \byte_controller/bit_controller/cnt [1]), .IN3(n659), .QN(n664) );
  MUX21X1 U811 ( .IN1(n664), .IN2(n660), .S(
        \byte_controller/bit_controller/cnt [2]), .Q(n661) );
  AO21X1 U812 ( .IN1(n668), .IN2(prer[2]), .IN3(n661), .Q(n336) );
  AO21X1 U813 ( .IN1(\byte_controller/bit_controller/cnt [0]), .IN2(n666), 
        .IN3(n665), .Q(n662) );
  AO22X1 U814 ( .IN1(\byte_controller/bit_controller/cnt [1]), .IN2(n662), 
        .IN3(n668), .IN4(prer[1]), .Q(n663) );
  OR2X1 U815 ( .IN1(n664), .IN2(n663), .Q(n335) );
  MUX21X1 U816 ( .IN1(n666), .IN2(n665), .S(
        \byte_controller/bit_controller/cnt [0]), .Q(n667) );
  AO21X1 U817 ( .IN1(n668), .IN2(prer[0]), .IN3(n667), .Q(n334) );
  NAND2X0 U818 ( .IN1(ctr[7]), .IN2(n669), .QN(n676) );
  NOR2X0 U819 ( .IN1(n670), .IN2(n676), .QN(n672) );
  NOR2X0 U820 ( .IN1(wb_rst_i), .IN2(n672), .QN(n675) );
  OA21X1 U821 ( .IN1(n677), .IN2(n671), .IN3(n675), .Q(n674) );
  AND2X1 U822 ( .IN1(n673), .IN2(n672), .Q(n679) );
  AO22X1 U823 ( .IN1(\byte_controller/N93 ), .IN2(n674), .IN3(n679), .IN4(
        wb_dat_i[7]), .Q(n333) );
  AO22X1 U824 ( .IN1(cr[6]), .IN2(n674), .IN3(n679), .IN4(wb_dat_i[6]), .Q(
        n332) );
  AO22X1 U825 ( .IN1(cr[5]), .IN2(n674), .IN3(n679), .IN4(wb_dat_i[5]), .Q(
        n331) );
  AO22X1 U826 ( .IN1(cr[4]), .IN2(n674), .IN3(n679), .IN4(wb_dat_i[4]), .Q(
        n330) );
  AO22X1 U827 ( .IN1(cr[3]), .IN2(n675), .IN3(n679), .IN4(wb_dat_i[3]), .Q(
        n329) );
  AND3X1 U828 ( .IN1(n677), .IN2(n673), .IN3(n676), .Q(n678) );
  AO22X1 U829 ( .IN1(n679), .IN2(wb_dat_i[2]), .IN3(n678), .IN4(cr[2]), .Q(
        n328) );
  AO22X1 U830 ( .IN1(n679), .IN2(wb_dat_i[1]), .IN3(n678), .IN4(cr[1]), .Q(
        n327) );
  AO22X1 U831 ( .IN1(n679), .IN2(wb_dat_i[0]), .IN3(n678), .IN4(cr[0]), .Q(
        n326) );
  OA221X1 U832 ( .IN1(\byte_controller/bit_controller/clk_en ), .IN2(
        \byte_controller/bit_controller/cmd_stop ), .IN3(n693), .IN4(n680), 
        .IN5(n673), .Q(n325) );
  AO221X1 U833 ( .IN1(\byte_controller/dcnt [1]), .IN2(n682), .IN3(n704), 
        .IN4(n681), .IN5(n685), .Q(n322) );
  NOR2X0 U834 ( .IN1(\byte_controller/ld ), .IN2(n683), .QN(n684) );
  AO222X1 U835 ( .IN1(\byte_controller/core_rxd ), .IN2(n684), .IN3(rxr[0]), 
        .IN4(n686), .IN5(n685), .IN6(txr[0]), .Q(n321) );
  AO222X1 U836 ( .IN1(rxr[0]), .IN2(n684), .IN3(rxr[1]), .IN4(n686), .IN5(n685), .IN6(txr[1]), .Q(n320) );
  AO222X1 U837 ( .IN1(rxr[1]), .IN2(n684), .IN3(rxr[2]), .IN4(n686), .IN5(n685), .IN6(txr[2]), .Q(n319) );
  AO222X1 U838 ( .IN1(rxr[2]), .IN2(n684), .IN3(rxr[3]), .IN4(n686), .IN5(n685), .IN6(txr[3]), .Q(n318) );
  AO222X1 U839 ( .IN1(rxr[3]), .IN2(n684), .IN3(rxr[4]), .IN4(n686), .IN5(n685), .IN6(txr[4]), .Q(n317) );
  AO222X1 U840 ( .IN1(rxr[4]), .IN2(n684), .IN3(rxr[5]), .IN4(n686), .IN5(n685), .IN6(txr[5]), .Q(n316) );
  AO222X1 U841 ( .IN1(rxr[5]), .IN2(n684), .IN3(rxr[6]), .IN4(n686), .IN5(n685), .IN6(txr[6]), .Q(n315) );
  AO222X1 U842 ( .IN1(rxr[7]), .IN2(n686), .IN3(txr[7]), .IN4(n685), .IN5(
        rxr[6]), .IN6(n684), .Q(n314) );
  NOR2X0 U843 ( .IN1(\byte_controller/bit_controller/dSCL ), .IN2(n691), .QN(
        n687) );
  MUX21X1 U844 ( .IN1(\byte_controller/core_rxd ), .IN2(
        \byte_controller/bit_controller/sSDA ), .S(n687), .Q(n313) );
endmodule

