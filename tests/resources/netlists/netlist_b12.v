/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : O-2018.06-SP5-1
// Date      : Tue Nov 19 15:28:50 2019
/////////////////////////////////////////////////////////////


module b12 ( clock, reset, start, k, nloss, nl, speaker );
  input [3:0] k;
  output [3:0] nl;
  input clock, reset, start;
  output nloss, speaker;
  wire   N106, N107, N108, N109, N110, play, N196, N197, N198, N203,
         \memory[31][1] , \memory[31][0] , \memory[30][1] , \memory[30][0] ,
         \memory[29][1] , \memory[29][0] , \memory[28][1] , \memory[28][0] ,
         \memory[27][1] , \memory[27][0] , \memory[26][1] , \memory[26][0] ,
         \memory[25][1] , \memory[25][0] , \memory[24][1] , \memory[24][0] ,
         \memory[23][1] , \memory[23][0] , \memory[22][1] , \memory[22][0] ,
         \memory[21][1] , \memory[21][0] , \memory[20][1] , \memory[20][0] ,
         \memory[19][1] , \memory[19][0] , \memory[18][1] , \memory[18][0] ,
         \memory[17][1] , \memory[17][0] , \memory[16][1] , \memory[16][0] ,
         \memory[15][1] , \memory[15][0] , \memory[14][1] , \memory[14][0] ,
         \memory[13][1] , \memory[13][0] , \memory[12][1] , \memory[12][0] ,
         \memory[11][1] , \memory[11][0] , \memory[10][1] , \memory[10][0] ,
         \memory[9][1] , \memory[9][0] , \memory[8][1] , \memory[8][0] ,
         \memory[7][1] , \memory[7][0] , \memory[6][1] , \memory[6][0] ,
         \memory[5][1] , \memory[5][0] , \memory[4][1] , \memory[4][0] ,
         \memory[3][1] , \memory[3][0] , \memory[2][1] , \memory[2][0] ,
         \memory[1][1] , \memory[1][0] , \memory[0][1] , \memory[0][0] , N204,
         N205, wr, N885, N886, N887, N888, N889, n35, n37, n38, n40, n46, n47,
         n87, n88, n97, n98, n99, n100, n118, n119, n120, n121, n122, n353,
         n354, n355, n356, n357, n358, n359, n360, n361, n362, n363, n364,
         n365, n366, n367, n368, n369, n370, n371, n372, n373, n374, n375,
         n376, n377, n378, n379, n380, n381, n382, n383, n384, n385, n386,
         n387, n388, n389, n390, n391, n392, n393, n394, n395, n396, n397,
         n398, n399, n400, n401, n402, n403, n404, n405, n406, n407, n408,
         n409, n410, n411, n412, n413, n414, n415, n416, n417, n418, n419,
         n420, n421, n422, n423, n424, n425, n426, n427, n428, n429, n430,
         n431, n432, n433, n434, n435, n436, n437, n438, n439, n440, n441,
         n442, n443, n444, n445, n446, n447, n448, n449, n450, n451, n452,
         n453, n454, n455, n456, n457, n458, n459, n460, n461, n462, n463,
         n464, n465, n466, n467, n468, n469, n470, n471, n472, n473, n474,
         n475, n476, n477, n478, n479, n480, n481, n482, n483, n484, n485,
         n486, n487, n488, n489, n490, n491, n492, n493, n494, n495, n496,
         n497, n498, n499, n500, n501, n502, n503, n504, n505, n506, n507,
         n508, n509, n510, n511, n512, n513, n514, n515, n516, n517, n518,
         n519, n520, n521, n522, n523, n524, n525, n526, n527, n528, n529,
         n530, n531, n532, n533, n534, n535, n536, n537, n538, n539, n540,
         n541, n542, n543, n544, n545, n546, n547, n548, n549, n550, n551,
         n552, n553, n554, n555, n556, n557, n558, n559, n560, n561, n562,
         n563, n564, n565, n566, n567, n568, n569, n570, n571, n572, n573,
         n574, n575, n576, n577, n578, n579, n580, n581, n582, n583, n584,
         n585, n586, n587, n588, n589, n590, n591, n592, n593, n594, n595,
         n596, n597, n598, n599, n600, n601, n602, n603, n604, n605, n606,
         n607, n608, n609, n610, n611, n612, n613, n614, n615, n616, n617,
         n618, n619, n620, n621, n622, n623, n624, n625, n626, n627, n628,
         n629, n630, n631, n632, n633, n634, n635, n636, n637, n638, n639,
         n640, n641, n642, n643, n644, n645, n646, n647, n648, n649, n650,
         n651, n652, n653, n654, n655, n656, n657, n658, n659, n660, n661,
         n662, n663, n664, n665, n666, n667, n668, n669, n670, n671, n672,
         n673, n674, n675, n676, n677, n678, n679, n680, n681, n682, n683,
         n684, n685, n686, n687, n688, n689, n690, n691, n692, n693, n694,
         n695, n696, n697, n698, n699, n700, n701, n702, n703, n704, n705,
         n706, n707, n708, n709, n710, n711, n712, n713, n714, n715, n716,
         n717, n718, n719, n720, n721, n722, n723, n724, n725, n726, n727,
         n728, n729, n730, n731, n732, n733, n734, n735, n736, n737, n738,
         n739, n740, n741, n742, n743, n744, n745, n746, n747, n748, n749,
         n750, n751, n752, n753, n754, n755, n756, n757, n758, n759, n760,
         n761, n762, n763, n764, n765, n766, n767, n768, n769, n770, n771,
         n772, n773, n774, n775, n776, n777, n778, n779, n780, n781, n782,
         n783, n784, n785, n786, n787, n788, n789, n790, n791, n792, n793,
         n794, n795, n796, n797, n798, n799, n800, n801, n802, n803, n804,
         n805, n806, n807, n808, n809, n810, n811, n812, n813, n814, n815,
         n816, n817, n818, n819, n820, n821, n822, n823, n824, n825, n826,
         n827, n828, n829, n830, n831, n832, n833, n834, n835, n836;
  wire   [2:0] sound;
  wire   [1:0] num;
  wire   [4:0] scan;
  wire   [5:0] timebase;

  DFFARX1 \count_reg[0]  ( .D(n40), .CLK(clock), .RSTB(n489), .QN(n40) );
  DFFARX1 \num_reg[1]  ( .D(N203), .CLK(clock), .RSTB(n488), .Q(num[1]) );
  DFFARX1 \count_reg[1]  ( .D(N203), .CLK(clock), .RSTB(n489), .QN(n831) );
  DFFARX1 \num_reg[0]  ( .D(n40), .CLK(clock), .RSTB(n487), .Q(num[0]) );
  DFFARX1 \data_out_reg[1]  ( .D(N204), .CLK(clock), .RSTB(n488), .Q(n471), 
        .QN(n46) );
  DFFARX1 \data_out_reg[0]  ( .D(N205), .CLK(clock), .RSTB(n488), .Q(n462), 
        .QN(n47) );
  DFFARX1 \gamma_reg[0]  ( .D(N885), .CLK(clock), .RSTB(n487), .Q(n480), .QN(
        n122) );
  DFFARX1 \gamma_reg[1]  ( .D(N886), .CLK(clock), .RSTB(n489), .QN(n121) );
  DFFARX1 \gamma_reg[2]  ( .D(N887), .CLK(clock), .RSTB(n487), .Q(n468), .QN(
        n120) );
  DFFARX1 \gamma_reg[3]  ( .D(N888), .CLK(clock), .RSTB(n836), .Q(n465), .QN(
        n119) );
  DFFARX1 \timebase_reg[5]  ( .D(n353), .CLK(clock), .RSTB(n836), .Q(
        timebase[5]) );
  DFFARX1 \count_reg2[5]  ( .D(n459), .CLK(clock), .RSTB(n488), .Q(n461) );
  DFFARX1 \gamma_reg[4]  ( .D(N889), .CLK(clock), .RSTB(n488), .Q(n477), .QN(
        n118) );
  DFFARX1 \data_in_reg[0]  ( .D(n456), .CLK(clock), .RSTB(n487), .Q(n469) );
  DFFARX1 \data_in_reg[1]  ( .D(n455), .CLK(clock), .RSTB(n487), .Q(n470) );
  DFFARX1 \ind_reg[0]  ( .D(n364), .CLK(clock), .RSTB(n487), .Q(n464), .QN(n88) );
  DFFARX1 \ind_reg[1]  ( .D(n363), .CLK(clock), .RSTB(n488), .Q(n476), .QN(n87) );
  DFFARX1 nloss_reg ( .D(n458), .CLK(clock), .RSTB(n488), .Q(nloss) );
  DFFARX1 wr_reg ( .D(n457), .CLK(clock), .RSTB(n836), .Q(wr) );
  DFFARX1 \max_reg[1]  ( .D(n444), .CLK(clock), .RSTB(n488), .Q(n463), .QN(
        n834) );
  DFFARX1 \timebase_reg[4]  ( .D(n354), .CLK(clock), .RSTB(n489), .Q(
        timebase[4]) );
  DFFARX1 \timebase_reg[3]  ( .D(n355), .CLK(clock), .RSTB(n487), .Q(
        timebase[3]) );
  DFFARX1 \timebase_reg[2]  ( .D(n356), .CLK(clock), .RSTB(n489), .Q(
        timebase[2]) );
  DFFARX1 \timebase_reg[1]  ( .D(n357), .CLK(clock), .RSTB(n487), .Q(
        timebase[1]) );
  DFFARX1 \timebase_reg[0]  ( .D(n358), .CLK(clock), .RSTB(n487), .Q(
        timebase[0]) );
  DFFARX1 \max_reg[0]  ( .D(n443), .CLK(clock), .RSTB(n489), .Q(n473), .QN(
        n833) );
  DFFARX1 \max_reg[2]  ( .D(n442), .CLK(clock), .RSTB(n487), .Q(n460) );
  DFFARX1 \max_reg[3]  ( .D(n441), .CLK(clock), .RSTB(n836), .Q(n467), .QN(
        n835) );
  DFFARX1 \max_reg[4]  ( .D(n440), .CLK(clock), .RSTB(n489), .Q(n474), .QN(
        n832) );
  DFFARX1 \scan_reg[1]  ( .D(n449), .CLK(clock), .RSTB(n487), .Q(scan[1]), 
        .QN(n479) );
  DFFARX1 \scan_reg[0]  ( .D(n448), .CLK(clock), .RSTB(n488), .Q(scan[0]), 
        .QN(n472) );
  DFFARX1 \scan_reg[2]  ( .D(n447), .CLK(clock), .RSTB(n487), .Q(scan[2]) );
  DFFARX1 \address_reg[2]  ( .D(n437), .CLK(clock), .RSTB(n488), .Q(N108), 
        .QN(n827) );
  DFFARX1 \scan_reg[3]  ( .D(n446), .CLK(clock), .RSTB(n836), .Q(scan[3]), 
        .QN(n475) );
  DFFARX1 \address_reg[3]  ( .D(n436), .CLK(clock), .RSTB(n489), .Q(N109), 
        .QN(n98) );
  DFFARX1 \scan_reg[4]  ( .D(n445), .CLK(clock), .RSTB(n489), .Q(scan[4]) );
  DFFARX1 \address_reg[4]  ( .D(n435), .CLK(clock), .RSTB(n836), .Q(N110), 
        .QN(n97) );
  DFFARX1 \address_reg[0]  ( .D(n439), .CLK(clock), .RSTB(n487), .Q(N106), 
        .QN(n100) );
  DFFARX1 \address_reg[1]  ( .D(n438), .CLK(clock), .RSTB(n489), .Q(N107), 
        .QN(n99) );
  DFFARX1 \memory_reg[24][0]  ( .D(n386), .CLK(clock), .RSTB(n489), .Q(
        \memory[24][0] ) );
  DFFARX1 \memory_reg[24][1]  ( .D(n385), .CLK(clock), .RSTB(n836), .Q(
        \memory[24][1] ) );
  DFFARX1 \memory_reg[16][0]  ( .D(n402), .CLK(clock), .RSTB(n489), .Q(
        \memory[16][0] ) );
  DFFARX1 \memory_reg[16][1]  ( .D(n401), .CLK(clock), .RSTB(n836), .Q(
        \memory[16][1] ) );
  DFFARX1 \memory_reg[8][0]  ( .D(n418), .CLK(clock), .RSTB(n489), .Q(
        \memory[8][0] ) );
  DFFARX1 \memory_reg[8][1]  ( .D(n417), .CLK(clock), .RSTB(n836), .Q(
        \memory[8][1] ) );
  DFFARX1 \memory_reg[0][0]  ( .D(n434), .CLK(clock), .RSTB(n489), .Q(
        \memory[0][0] ) );
  DFFARX1 \memory_reg[0][1]  ( .D(n433), .CLK(clock), .RSTB(n489), .Q(
        \memory[0][1] ) );
  DFFARX1 \memory_reg[25][0]  ( .D(n384), .CLK(clock), .RSTB(n487), .Q(
        \memory[25][0] ) );
  DFFARX1 \memory_reg[25][1]  ( .D(n383), .CLK(clock), .RSTB(n488), .Q(
        \memory[25][1] ) );
  DFFARX1 \memory_reg[17][0]  ( .D(n400), .CLK(clock), .RSTB(n487), .Q(
        \memory[17][0] ) );
  DFFARX1 \memory_reg[17][1]  ( .D(n399), .CLK(clock), .RSTB(n488), .Q(
        \memory[17][1] ) );
  DFFARX1 \memory_reg[9][0]  ( .D(n416), .CLK(clock), .RSTB(n487), .Q(
        \memory[9][0] ) );
  DFFARX1 \memory_reg[9][1]  ( .D(n415), .CLK(clock), .RSTB(n488), .Q(
        \memory[9][1] ) );
  DFFARX1 \memory_reg[1][0]  ( .D(n432), .CLK(clock), .RSTB(n836), .Q(
        \memory[1][0] ) );
  DFFARX1 \memory_reg[1][1]  ( .D(n431), .CLK(clock), .RSTB(n487), .Q(
        \memory[1][1] ) );
  DFFARX1 \memory_reg[30][0]  ( .D(n374), .CLK(clock), .RSTB(n489), .Q(
        \memory[30][0] ) );
  DFFARX1 \memory_reg[30][1]  ( .D(n373), .CLK(clock), .RSTB(n836), .Q(
        \memory[30][1] ) );
  DFFARX1 \memory_reg[22][0]  ( .D(n390), .CLK(clock), .RSTB(n489), .Q(
        \memory[22][0] ) );
  DFFARX1 \memory_reg[22][1]  ( .D(n389), .CLK(clock), .RSTB(n836), .Q(
        \memory[22][1] ) );
  DFFARX1 \memory_reg[14][0]  ( .D(n406), .CLK(clock), .RSTB(n489), .Q(
        \memory[14][0] ) );
  DFFARX1 \memory_reg[14][1]  ( .D(n405), .CLK(clock), .RSTB(n836), .Q(
        \memory[14][1] ) );
  DFFARX1 \memory_reg[6][0]  ( .D(n422), .CLK(clock), .RSTB(n836), .Q(
        \memory[6][0] ) );
  DFFARX1 \memory_reg[6][1]  ( .D(n421), .CLK(clock), .RSTB(n487), .Q(
        \memory[6][1] ) );
  DFFARX1 \memory_reg[31][0]  ( .D(n372), .CLK(clock), .RSTB(n487), .Q(
        \memory[31][0] ) );
  DFFARX1 \memory_reg[31][1]  ( .D(n371), .CLK(clock), .RSTB(n488), .Q(
        \memory[31][1] ) );
  DFFARX1 \memory_reg[23][0]  ( .D(n388), .CLK(clock), .RSTB(n487), .Q(
        \memory[23][0] ) );
  DFFARX1 \memory_reg[23][1]  ( .D(n387), .CLK(clock), .RSTB(n488), .Q(
        \memory[23][1] ) );
  DFFARX1 \memory_reg[15][0]  ( .D(n404), .CLK(clock), .RSTB(n487), .Q(
        \memory[15][0] ) );
  DFFARX1 \memory_reg[15][1]  ( .D(n403), .CLK(clock), .RSTB(n488), .Q(
        \memory[15][1] ) );
  DFFARX1 \memory_reg[7][0]  ( .D(n420), .CLK(clock), .RSTB(n488), .Q(
        \memory[7][0] ) );
  DFFARX1 \memory_reg[7][1]  ( .D(n419), .CLK(clock), .RSTB(n489), .Q(
        \memory[7][1] ) );
  DFFARX1 \memory_reg[26][0]  ( .D(n382), .CLK(clock), .RSTB(n489), .Q(
        \memory[26][0] ) );
  DFFARX1 \memory_reg[26][1]  ( .D(n381), .CLK(clock), .RSTB(n836), .Q(
        \memory[26][1] ) );
  DFFARX1 \memory_reg[18][0]  ( .D(n398), .CLK(clock), .RSTB(n489), .Q(
        \memory[18][0] ) );
  DFFARX1 \memory_reg[18][1]  ( .D(n397), .CLK(clock), .RSTB(n836), .Q(
        \memory[18][1] ) );
  DFFARX1 \memory_reg[10][0]  ( .D(n414), .CLK(clock), .RSTB(n489), .Q(
        \memory[10][0] ) );
  DFFARX1 \memory_reg[10][1]  ( .D(n413), .CLK(clock), .RSTB(n836), .Q(
        \memory[10][1] ) );
  DFFARX1 \memory_reg[2][0]  ( .D(n430), .CLK(clock), .RSTB(n489), .Q(
        \memory[2][0] ) );
  DFFARX1 \memory_reg[2][1]  ( .D(n429), .CLK(clock), .RSTB(n489), .Q(
        \memory[2][1] ) );
  DFFARX1 \memory_reg[27][0]  ( .D(n380), .CLK(clock), .RSTB(n487), .Q(
        \memory[27][0] ) );
  DFFARX1 \memory_reg[27][1]  ( .D(n379), .CLK(clock), .RSTB(n488), .Q(
        \memory[27][1] ) );
  DFFARX1 \memory_reg[19][0]  ( .D(n396), .CLK(clock), .RSTB(n487), .Q(
        \memory[19][0] ) );
  DFFARX1 \memory_reg[19][1]  ( .D(n395), .CLK(clock), .RSTB(n488), .Q(
        \memory[19][1] ) );
  DFFARX1 \memory_reg[11][0]  ( .D(n412), .CLK(clock), .RSTB(n487), .Q(
        \memory[11][0] ) );
  DFFARX1 \memory_reg[11][1]  ( .D(n411), .CLK(clock), .RSTB(n488), .Q(
        \memory[11][1] ) );
  DFFARX1 \memory_reg[3][0]  ( .D(n428), .CLK(clock), .RSTB(n488), .Q(
        \memory[3][0] ) );
  DFFARX1 \memory_reg[3][1]  ( .D(n427), .CLK(clock), .RSTB(n489), .Q(
        \memory[3][1] ) );
  DFFARX1 \memory_reg[28][0]  ( .D(n378), .CLK(clock), .RSTB(n489), .Q(
        \memory[28][0] ) );
  DFFARX1 \memory_reg[28][1]  ( .D(n377), .CLK(clock), .RSTB(n836), .Q(
        \memory[28][1] ) );
  DFFARX1 \memory_reg[20][0]  ( .D(n394), .CLK(clock), .RSTB(n489), .Q(
        \memory[20][0] ) );
  DFFARX1 \memory_reg[20][1]  ( .D(n393), .CLK(clock), .RSTB(n836), .Q(
        \memory[20][1] ) );
  DFFARX1 \memory_reg[12][0]  ( .D(n410), .CLK(clock), .RSTB(n489), .Q(
        \memory[12][0] ) );
  DFFARX1 \memory_reg[12][1]  ( .D(n409), .CLK(clock), .RSTB(n836), .Q(
        \memory[12][1] ) );
  DFFARX1 \memory_reg[4][0]  ( .D(n426), .CLK(clock), .RSTB(n836), .Q(
        \memory[4][0] ) );
  DFFARX1 \memory_reg[4][1]  ( .D(n425), .CLK(clock), .RSTB(n487), .Q(
        \memory[4][1] ) );
  DFFARX1 \memory_reg[29][0]  ( .D(n376), .CLK(clock), .RSTB(n487), .Q(
        \memory[29][0] ) );
  DFFARX1 \memory_reg[29][1]  ( .D(n375), .CLK(clock), .RSTB(n488), .Q(
        \memory[29][1] ) );
  DFFARX1 \memory_reg[21][0]  ( .D(n392), .CLK(clock), .RSTB(n487), .Q(
        \memory[21][0] ) );
  DFFARX1 \memory_reg[21][1]  ( .D(n391), .CLK(clock), .RSTB(n488), .Q(
        \memory[21][1] ) );
  DFFARX1 \memory_reg[13][0]  ( .D(n408), .CLK(clock), .RSTB(n487), .Q(
        \memory[13][0] ) );
  DFFARX1 \memory_reg[13][1]  ( .D(n407), .CLK(clock), .RSTB(n488), .Q(
        \memory[13][1] ) );
  DFFARX1 \memory_reg[5][0]  ( .D(n424), .CLK(clock), .RSTB(n488), .Q(
        \memory[5][0] ) );
  DFFARX1 \memory_reg[5][1]  ( .D(n423), .CLK(clock), .RSTB(n489), .Q(
        \memory[5][1] ) );
  DFFARX1 \nl_reg[3]  ( .D(n359), .CLK(clock), .RSTB(n489), .Q(nl[3]) );
  DFFARX1 \nl_reg[2]  ( .D(n360), .CLK(clock), .RSTB(n487), .Q(nl[2]) );
  DFFARX1 \nl_reg[1]  ( .D(n361), .CLK(clock), .RSTB(n488), .Q(nl[1]) );
  DFFARX1 \nl_reg[0]  ( .D(n362), .CLK(clock), .RSTB(n488), .Q(nl[0]) );
  DFFARX1 \count_reg2[0]  ( .D(n454), .CLK(clock), .RSTB(n488), .Q(n482), .QN(
        n828) );
  DFFARX1 \count_reg2[4]  ( .D(n453), .CLK(clock), .RSTB(n488), .Q(n478) );
  DFFARX1 \count_reg2[2]  ( .D(n451), .CLK(clock), .RSTB(n488), .Q(n484), .QN(
        n829) );
  DFFARX1 \count_reg2[1]  ( .D(n450), .CLK(clock), .RSTB(n836), .Q(n483), .QN(
        n830) );
  DFFARX1 \sound_reg[0]  ( .D(n369), .CLK(clock), .RSTB(n487), .Q(sound[0]), 
        .QN(n486) );
  DFFARX1 \sound_reg[2]  ( .D(n368), .CLK(clock), .RSTB(n836), .Q(sound[2]) );
  DFFARX1 \sound_reg[1]  ( .D(n367), .CLK(clock), .RSTB(n836), .Q(sound[1]) );
  DFFARX1 play_reg ( .D(n370), .CLK(clock), .RSTB(n489), .Q(play), .QN(n481)
         );
  DFFARX1 \counter_reg[0]  ( .D(N196), .CLK(clock), .RSTB(n836), .Q(n485), 
        .QN(n38) );
  DFFARX1 \counter_reg[1]  ( .D(N197), .CLK(clock), .RSTB(n489), .QN(n37) );
  DFFARX1 \counter_reg[2]  ( .D(N198), .CLK(clock), .RSTB(n488), .QN(n35) );
  DFFARX1 s_reg ( .D(n366), .CLK(clock), .RSTB(n487), .Q(n826) );
  DFFARX1 speaker_reg ( .D(n365), .CLK(clock), .RSTB(n836), .Q(speaker), .QN(
        n825) );
  DFFARX1 \count_reg2[3]  ( .D(n452), .CLK(clock), .RSTB(n836), .Q(n466) );
  INVX2 U427 ( .INP(reset), .ZN(n487) );
  INVX2 U428 ( .INP(reset), .ZN(n488) );
  INVX2 U429 ( .INP(reset), .ZN(n489) );
  NOR2X0 U430 ( .IN1(n99), .IN2(N106), .QN(n526) );
  NOR2X0 U431 ( .IN1(n99), .IN2(n100), .QN(n525) );
  NOR2X0 U432 ( .IN1(n100), .IN2(N107), .QN(n523) );
  NOR2X0 U433 ( .IN1(N106), .IN2(N107), .QN(n522) );
  AO22X1 U434 ( .IN1(\memory[9][0] ), .IN2(n523), .IN3(\memory[8][0] ), .IN4(
        n522), .Q(n490) );
  AO221X1 U435 ( .IN1(\memory[10][0] ), .IN2(n526), .IN3(\memory[11][0] ), 
        .IN4(n525), .IN5(n490), .Q(n498) );
  NOR2X0 U436 ( .IN1(n98), .IN2(N108), .QN(n534) );
  AO22X1 U437 ( .IN1(\memory[13][0] ), .IN2(n523), .IN3(\memory[12][0] ), 
        .IN4(n522), .Q(n491) );
  AO221X1 U438 ( .IN1(\memory[14][0] ), .IN2(n526), .IN3(\memory[15][0] ), 
        .IN4(n525), .IN5(n491), .Q(n497) );
  NOR2X0 U439 ( .IN1(n98), .IN2(n827), .QN(n532) );
  AO22X1 U440 ( .IN1(\memory[5][0] ), .IN2(n523), .IN3(\memory[4][0] ), .IN4(
        n522), .Q(n492) );
  AO221X1 U441 ( .IN1(\memory[6][0] ), .IN2(n526), .IN3(\memory[7][0] ), .IN4(
        n525), .IN5(n492), .Q(n495) );
  NOR2X0 U442 ( .IN1(n827), .IN2(N109), .QN(n529) );
  AO22X1 U443 ( .IN1(\memory[1][0] ), .IN2(n523), .IN3(\memory[0][0] ), .IN4(
        n522), .Q(n493) );
  AO221X1 U444 ( .IN1(\memory[2][0] ), .IN2(n526), .IN3(\memory[3][0] ), .IN4(
        n525), .IN5(n493), .Q(n494) );
  NOR2X0 U445 ( .IN1(N108), .IN2(N109), .QN(n527) );
  AO22X1 U446 ( .IN1(n495), .IN2(n529), .IN3(n494), .IN4(n527), .Q(n496) );
  AO221X1 U447 ( .IN1(n498), .IN2(n534), .IN3(n497), .IN4(n532), .IN5(n496), 
        .Q(n509) );
  AO22X1 U448 ( .IN1(\memory[25][0] ), .IN2(n523), .IN3(\memory[24][0] ), 
        .IN4(n522), .Q(n499) );
  AO221X1 U449 ( .IN1(\memory[26][0] ), .IN2(n526), .IN3(\memory[27][0] ), 
        .IN4(n525), .IN5(n499), .Q(n507) );
  AO22X1 U450 ( .IN1(\memory[29][0] ), .IN2(n523), .IN3(\memory[28][0] ), 
        .IN4(n522), .Q(n500) );
  AO221X1 U451 ( .IN1(\memory[30][0] ), .IN2(n526), .IN3(\memory[31][0] ), 
        .IN4(n525), .IN5(n500), .Q(n506) );
  AO22X1 U452 ( .IN1(\memory[21][0] ), .IN2(n523), .IN3(\memory[20][0] ), 
        .IN4(n522), .Q(n501) );
  AO221X1 U453 ( .IN1(\memory[22][0] ), .IN2(n526), .IN3(\memory[23][0] ), 
        .IN4(n525), .IN5(n501), .Q(n504) );
  AO22X1 U454 ( .IN1(\memory[17][0] ), .IN2(n523), .IN3(\memory[16][0] ), 
        .IN4(n522), .Q(n502) );
  AO221X1 U455 ( .IN1(\memory[18][0] ), .IN2(n526), .IN3(\memory[19][0] ), 
        .IN4(n525), .IN5(n502), .Q(n503) );
  AO22X1 U456 ( .IN1(n504), .IN2(n529), .IN3(n503), .IN4(n527), .Q(n505) );
  AO221X1 U457 ( .IN1(n507), .IN2(n534), .IN3(n506), .IN4(n532), .IN5(n505), 
        .Q(n508) );
  AO22X1 U458 ( .IN1(n509), .IN2(n97), .IN3(n508), .IN4(N110), .Q(N205) );
  AO22X1 U459 ( .IN1(\memory[9][1] ), .IN2(n523), .IN3(\memory[8][1] ), .IN4(
        n522), .Q(n510) );
  AO221X1 U460 ( .IN1(\memory[10][1] ), .IN2(n526), .IN3(\memory[11][1] ), 
        .IN4(n525), .IN5(n510), .Q(n518) );
  AO22X1 U461 ( .IN1(\memory[13][1] ), .IN2(n523), .IN3(\memory[12][1] ), 
        .IN4(n522), .Q(n511) );
  AO221X1 U462 ( .IN1(\memory[14][1] ), .IN2(n526), .IN3(\memory[15][1] ), 
        .IN4(n525), .IN5(n511), .Q(n517) );
  AO22X1 U463 ( .IN1(\memory[5][1] ), .IN2(n523), .IN3(\memory[4][1] ), .IN4(
        n522), .Q(n512) );
  AO221X1 U464 ( .IN1(\memory[6][1] ), .IN2(n526), .IN3(\memory[7][1] ), .IN4(
        n525), .IN5(n512), .Q(n515) );
  AO22X1 U465 ( .IN1(\memory[1][1] ), .IN2(n523), .IN3(\memory[0][1] ), .IN4(
        n522), .Q(n513) );
  AO221X1 U466 ( .IN1(\memory[2][1] ), .IN2(n526), .IN3(\memory[3][1] ), .IN4(
        n525), .IN5(n513), .Q(n514) );
  AO22X1 U467 ( .IN1(n529), .IN2(n515), .IN3(n527), .IN4(n514), .Q(n516) );
  AO221X1 U468 ( .IN1(n534), .IN2(n518), .IN3(n532), .IN4(n517), .IN5(n516), 
        .Q(n537) );
  AO22X1 U469 ( .IN1(\memory[25][1] ), .IN2(n523), .IN3(\memory[24][1] ), 
        .IN4(n522), .Q(n519) );
  AO221X1 U470 ( .IN1(\memory[26][1] ), .IN2(n526), .IN3(\memory[27][1] ), 
        .IN4(n525), .IN5(n519), .Q(n535) );
  AO22X1 U471 ( .IN1(\memory[29][1] ), .IN2(n523), .IN3(\memory[28][1] ), 
        .IN4(n522), .Q(n520) );
  AO221X1 U472 ( .IN1(\memory[30][1] ), .IN2(n526), .IN3(\memory[31][1] ), 
        .IN4(n525), .IN5(n520), .Q(n533) );
  AO22X1 U473 ( .IN1(\memory[21][1] ), .IN2(n523), .IN3(\memory[20][1] ), 
        .IN4(n522), .Q(n521) );
  AO221X1 U474 ( .IN1(\memory[22][1] ), .IN2(n526), .IN3(\memory[23][1] ), 
        .IN4(n525), .IN5(n521), .Q(n530) );
  AO22X1 U475 ( .IN1(\memory[17][1] ), .IN2(n523), .IN3(\memory[16][1] ), 
        .IN4(n522), .Q(n524) );
  AO221X1 U476 ( .IN1(\memory[18][1] ), .IN2(n526), .IN3(\memory[19][1] ), 
        .IN4(n525), .IN5(n524), .Q(n528) );
  AO22X1 U477 ( .IN1(n530), .IN2(n529), .IN3(n528), .IN4(n527), .Q(n531) );
  AO221X1 U478 ( .IN1(n535), .IN2(n534), .IN3(n533), .IN4(n532), .IN5(n531), 
        .Q(n536) );
  AO22X1 U479 ( .IN1(n537), .IN2(n97), .IN3(N110), .IN4(n536), .Q(N204) );
  INVX0 U480 ( .INP(reset), .ZN(n836) );
  MUX21X1 U481 ( .IN1(n461), .IN2(n538), .S(n539), .Q(n459) );
  AO221X1 U482 ( .IN1(n540), .IN2(n541), .IN3(timebase[5]), .IN4(n542), .IN5(
        n543), .Q(n538) );
  MUX21X1 U483 ( .IN1(n544), .IN2(nloss), .S(n545), .Q(n458) );
  NOR2X0 U484 ( .IN1(n546), .IN2(n547), .QN(n545) );
  OA21X1 U485 ( .IN1(n548), .IN2(n549), .IN3(n544), .Q(n546) );
  NAND2X0 U486 ( .IN1(n550), .IN2(n551), .QN(n457) );
  NAND3X0 U487 ( .IN1(n552), .IN2(n553), .IN3(wr), .QN(n551) );
  INVX0 U488 ( .INP(n547), .ZN(n552) );
  MUX21X1 U489 ( .IN1(num[0]), .IN2(n469), .S(n550), .Q(n456) );
  MUX21X1 U490 ( .IN1(num[1]), .IN2(n470), .S(n550), .Q(n455) );
  MUX21X1 U491 ( .IN1(n482), .IN2(n554), .S(n539), .Q(n454) );
  AO221X1 U492 ( .IN1(n555), .IN2(n541), .IN3(timebase[0]), .IN4(n542), .IN5(
        n543), .Q(n554) );
  AO222X1 U493 ( .IN1(n556), .IN2(timebase[4]), .IN3(n557), .IN4(n558), .IN5(
        n559), .IN6(n478), .Q(n453) );
  MUX21X1 U494 ( .IN1(n466), .IN2(n560), .S(n539), .Q(n452) );
  AO22X1 U495 ( .IN1(timebase[3]), .IN2(n542), .IN3(n561), .IN4(n562), .Q(n560) );
  NAND3X0 U496 ( .IN1(n563), .IN2(n564), .IN3(n565), .QN(n561) );
  AO222X1 U497 ( .IN1(n556), .IN2(timebase[2]), .IN3(n557), .IN4(n566), .IN5(
        n559), .IN6(n484), .Q(n451) );
  AO222X1 U498 ( .IN1(n556), .IN2(timebase[1]), .IN3(n557), .IN4(n567), .IN5(
        n559), .IN6(n483), .Q(n450) );
  INVX0 U499 ( .INP(n539), .ZN(n559) );
  AND2X1 U500 ( .IN1(n541), .IN2(n539), .Q(n557) );
  NAND3X0 U501 ( .IN1(n568), .IN2(n569), .IN3(n563), .QN(n541) );
  NOR4X0 U502 ( .IN1(n570), .IN2(n571), .IN3(n572), .IN4(n573), .QN(n563) );
  OAI22X1 U503 ( .IN1(n574), .IN2(n548), .IN3(n575), .IN4(n576), .QN(n573) );
  NAND2X0 U504 ( .IN1(n577), .IN2(n578), .QN(n568) );
  AND2X1 U505 ( .IN1(n542), .IN2(n539), .Q(n556) );
  NAND4X0 U506 ( .IN1(n579), .IN2(n569), .IN3(n580), .IN4(n581), .QN(n539) );
  NOR3X0 U507 ( .IN1(n577), .IN2(n582), .IN3(n583), .QN(n581) );
  NAND2X0 U508 ( .IN1(n584), .IN2(n578), .QN(n580) );
  NAND3X0 U509 ( .IN1(n575), .IN2(n585), .IN3(n586), .QN(n584) );
  AO221X1 U510 ( .IN1(n548), .IN2(n587), .IN3(n544), .IN4(n576), .IN5(n588), 
        .Q(n542) );
  NAND2X0 U511 ( .IN1(n574), .IN2(n589), .QN(n587) );
  MUX21X1 U512 ( .IN1(n590), .IN2(n591), .S(n479), .Q(n449) );
  NOR2X0 U513 ( .IN1(n472), .IN2(n592), .QN(n591) );
  MUX21X1 U514 ( .IN1(n593), .IN2(n594), .S(n472), .Q(n448) );
  MUX21X1 U515 ( .IN1(n595), .IN2(n596), .S(scan[2]), .Q(n447) );
  AO21X1 U516 ( .IN1(n594), .IN2(n479), .IN3(n590), .Q(n596) );
  AO21X1 U517 ( .IN1(n594), .IN2(n472), .IN3(n593), .Q(n590) );
  AND3X1 U518 ( .IN1(n594), .IN2(scan[1]), .IN3(scan[0]), .Q(n595) );
  MUX21X1 U519 ( .IN1(n597), .IN2(n598), .S(n475), .Q(n446) );
  NOR2X0 U520 ( .IN1(n592), .IN2(n599), .QN(n598) );
  MUX21X1 U521 ( .IN1(n600), .IN2(n601), .S(scan[4]), .Q(n445) );
  AO21X1 U522 ( .IN1(n594), .IN2(n475), .IN3(n597), .Q(n601) );
  AO21X1 U523 ( .IN1(n594), .IN2(n599), .IN3(n593), .Q(n597) );
  INVX0 U524 ( .INP(n602), .ZN(n593) );
  INVX0 U525 ( .INP(n592), .ZN(n594) );
  NOR3X0 U526 ( .IN1(n592), .IN2(n475), .IN3(n599), .QN(n600) );
  NAND3X0 U527 ( .IN1(scan[2]), .IN2(scan[1]), .IN3(scan[0]), .QN(n599) );
  NAND2X0 U528 ( .IN1(n603), .IN2(n602), .QN(n592) );
  AO21X1 U529 ( .IN1(n548), .IN2(n604), .IN3(n605), .Q(n602) );
  AO21X1 U530 ( .IN1(n606), .IN2(n607), .IN3(n570), .Q(n604) );
  AO21X1 U531 ( .IN1(n570), .IN2(n607), .IN3(n606), .Q(n603) );
  MUX21X1 U532 ( .IN1(n608), .IN2(n609), .S(n463), .Q(n444) );
  NOR2X0 U533 ( .IN1(n833), .IN2(n610), .QN(n608) );
  MUX21X1 U534 ( .IN1(n611), .IN2(n612), .S(n473), .Q(n443) );
  MUX21X1 U535 ( .IN1(n613), .IN2(n614), .S(n460), .Q(n442) );
  AO21X1 U536 ( .IN1(n611), .IN2(n834), .IN3(n609), .Q(n614) );
  AO21X1 U537 ( .IN1(n611), .IN2(n833), .IN3(n612), .Q(n609) );
  NOR3X0 U538 ( .IN1(n834), .IN2(n833), .IN3(n610), .QN(n613) );
  MUX21X1 U539 ( .IN1(n615), .IN2(n616), .S(n467), .Q(n441) );
  NOR2X0 U540 ( .IN1(n617), .IN2(n610), .QN(n615) );
  MUX21X1 U541 ( .IN1(n618), .IN2(n619), .S(n474), .Q(n440) );
  AO21X1 U542 ( .IN1(n611), .IN2(n835), .IN3(n616), .Q(n619) );
  AO21X1 U543 ( .IN1(n611), .IN2(n617), .IN3(n612), .Q(n616) );
  NOR3X0 U544 ( .IN1(n617), .IN2(n835), .IN3(n610), .QN(n618) );
  INVX0 U545 ( .INP(n611), .ZN(n610) );
  NOR2X0 U546 ( .IN1(n565), .IN2(n612), .QN(n611) );
  OA21X1 U547 ( .IN1(n578), .IN2(n620), .IN3(n621), .Q(n612) );
  NOR3X0 U548 ( .IN1(n572), .IN2(n544), .IN3(n622), .QN(n620) );
  AO222X1 U549 ( .IN1(scan[0]), .IN2(n623), .IN3(n624), .IN4(N106), .IN5(n625), 
        .IN6(n473), .Q(n439) );
  AO222X1 U550 ( .IN1(scan[1]), .IN2(n623), .IN3(n624), .IN4(N107), .IN5(n625), 
        .IN6(n463), .Q(n438) );
  AO222X1 U551 ( .IN1(scan[2]), .IN2(n623), .IN3(n624), .IN4(N108), .IN5(n625), 
        .IN6(n460), .Q(n437) );
  AO222X1 U552 ( .IN1(scan[3]), .IN2(n623), .IN3(n624), .IN4(N109), .IN5(n625), 
        .IN6(n467), .Q(n436) );
  AO222X1 U553 ( .IN1(scan[4]), .IN2(n623), .IN3(n624), .IN4(N110), .IN5(n625), 
        .IN6(n474), .Q(n435) );
  NOR2X0 U554 ( .IN1(n625), .IN2(n623), .QN(n624) );
  INVX0 U555 ( .INP(n626), .ZN(n625) );
  NAND2X0 U556 ( .IN1(n579), .IN2(n553), .QN(n623) );
  MUX21X1 U557 ( .IN1(\memory[0][0] ), .IN2(n469), .S(n627), .Q(n434) );
  MUX21X1 U558 ( .IN1(\memory[0][1] ), .IN2(n470), .S(n627), .Q(n433) );
  AND2X1 U559 ( .IN1(n628), .IN2(n629), .Q(n627) );
  MUX21X1 U560 ( .IN1(\memory[1][0] ), .IN2(n469), .S(n630), .Q(n432) );
  MUX21X1 U561 ( .IN1(\memory[1][1] ), .IN2(n470), .S(n630), .Q(n431) );
  AND2X1 U562 ( .IN1(n631), .IN2(n629), .Q(n630) );
  MUX21X1 U563 ( .IN1(\memory[2][0] ), .IN2(n469), .S(n632), .Q(n430) );
  MUX21X1 U564 ( .IN1(\memory[2][1] ), .IN2(n470), .S(n632), .Q(n429) );
  AND2X1 U565 ( .IN1(n633), .IN2(n629), .Q(n632) );
  MUX21X1 U566 ( .IN1(\memory[3][0] ), .IN2(n469), .S(n634), .Q(n428) );
  MUX21X1 U567 ( .IN1(\memory[3][1] ), .IN2(n470), .S(n634), .Q(n427) );
  AND2X1 U568 ( .IN1(n635), .IN2(n629), .Q(n634) );
  MUX21X1 U569 ( .IN1(\memory[4][0] ), .IN2(n469), .S(n636), .Q(n426) );
  MUX21X1 U570 ( .IN1(\memory[4][1] ), .IN2(n470), .S(n636), .Q(n425) );
  AND2X1 U571 ( .IN1(n637), .IN2(n629), .Q(n636) );
  MUX21X1 U572 ( .IN1(\memory[5][0] ), .IN2(n469), .S(n638), .Q(n424) );
  MUX21X1 U573 ( .IN1(\memory[5][1] ), .IN2(n470), .S(n638), .Q(n423) );
  AND2X1 U574 ( .IN1(n639), .IN2(n629), .Q(n638) );
  MUX21X1 U575 ( .IN1(\memory[6][0] ), .IN2(n469), .S(n640), .Q(n422) );
  MUX21X1 U576 ( .IN1(\memory[6][1] ), .IN2(n470), .S(n640), .Q(n421) );
  AND2X1 U577 ( .IN1(n641), .IN2(n629), .Q(n640) );
  MUX21X1 U578 ( .IN1(\memory[7][0] ), .IN2(n469), .S(n642), .Q(n420) );
  MUX21X1 U579 ( .IN1(\memory[7][1] ), .IN2(n470), .S(n642), .Q(n419) );
  AND2X1 U580 ( .IN1(n643), .IN2(n629), .Q(n642) );
  AND3X1 U581 ( .IN1(n97), .IN2(wr), .IN3(n98), .Q(n629) );
  MUX21X1 U582 ( .IN1(\memory[8][0] ), .IN2(n469), .S(n644), .Q(n418) );
  MUX21X1 U583 ( .IN1(\memory[8][1] ), .IN2(n470), .S(n644), .Q(n417) );
  AND2X1 U584 ( .IN1(n645), .IN2(n628), .Q(n644) );
  MUX21X1 U585 ( .IN1(\memory[9][0] ), .IN2(n469), .S(n646), .Q(n416) );
  MUX21X1 U586 ( .IN1(\memory[9][1] ), .IN2(n470), .S(n646), .Q(n415) );
  AND2X1 U587 ( .IN1(n645), .IN2(n631), .Q(n646) );
  MUX21X1 U588 ( .IN1(\memory[10][0] ), .IN2(n469), .S(n647), .Q(n414) );
  MUX21X1 U589 ( .IN1(\memory[10][1] ), .IN2(n470), .S(n647), .Q(n413) );
  AND2X1 U590 ( .IN1(n645), .IN2(n633), .Q(n647) );
  MUX21X1 U591 ( .IN1(\memory[11][0] ), .IN2(n469), .S(n648), .Q(n412) );
  MUX21X1 U592 ( .IN1(\memory[11][1] ), .IN2(n470), .S(n648), .Q(n411) );
  AND2X1 U593 ( .IN1(n645), .IN2(n635), .Q(n648) );
  MUX21X1 U594 ( .IN1(\memory[12][0] ), .IN2(n469), .S(n649), .Q(n410) );
  MUX21X1 U595 ( .IN1(\memory[12][1] ), .IN2(n470), .S(n649), .Q(n409) );
  AND2X1 U596 ( .IN1(n645), .IN2(n637), .Q(n649) );
  MUX21X1 U597 ( .IN1(\memory[13][0] ), .IN2(n469), .S(n650), .Q(n408) );
  MUX21X1 U598 ( .IN1(\memory[13][1] ), .IN2(n470), .S(n650), .Q(n407) );
  AND2X1 U599 ( .IN1(n645), .IN2(n639), .Q(n650) );
  MUX21X1 U600 ( .IN1(\memory[14][0] ), .IN2(n469), .S(n651), .Q(n406) );
  MUX21X1 U601 ( .IN1(\memory[14][1] ), .IN2(n470), .S(n651), .Q(n405) );
  AND2X1 U602 ( .IN1(n645), .IN2(n641), .Q(n651) );
  MUX21X1 U603 ( .IN1(\memory[15][0] ), .IN2(n469), .S(n652), .Q(n404) );
  MUX21X1 U604 ( .IN1(\memory[15][1] ), .IN2(n470), .S(n652), .Q(n403) );
  AND2X1 U605 ( .IN1(n645), .IN2(n643), .Q(n652) );
  AND3X1 U606 ( .IN1(wr), .IN2(N109), .IN3(n97), .Q(n645) );
  MUX21X1 U607 ( .IN1(\memory[16][0] ), .IN2(n469), .S(n653), .Q(n402) );
  MUX21X1 U608 ( .IN1(\memory[16][1] ), .IN2(n470), .S(n653), .Q(n401) );
  AND2X1 U609 ( .IN1(n654), .IN2(n628), .Q(n653) );
  MUX21X1 U610 ( .IN1(\memory[17][0] ), .IN2(n469), .S(n655), .Q(n400) );
  MUX21X1 U611 ( .IN1(\memory[17][1] ), .IN2(n470), .S(n655), .Q(n399) );
  AND2X1 U612 ( .IN1(n654), .IN2(n631), .Q(n655) );
  MUX21X1 U613 ( .IN1(\memory[18][0] ), .IN2(n469), .S(n656), .Q(n398) );
  MUX21X1 U614 ( .IN1(\memory[18][1] ), .IN2(n470), .S(n656), .Q(n397) );
  AND2X1 U615 ( .IN1(n654), .IN2(n633), .Q(n656) );
  MUX21X1 U616 ( .IN1(\memory[19][0] ), .IN2(n469), .S(n657), .Q(n396) );
  MUX21X1 U617 ( .IN1(\memory[19][1] ), .IN2(n470), .S(n657), .Q(n395) );
  AND2X1 U618 ( .IN1(n654), .IN2(n635), .Q(n657) );
  MUX21X1 U619 ( .IN1(\memory[20][0] ), .IN2(n469), .S(n658), .Q(n394) );
  MUX21X1 U620 ( .IN1(\memory[20][1] ), .IN2(n470), .S(n658), .Q(n393) );
  AND2X1 U621 ( .IN1(n654), .IN2(n637), .Q(n658) );
  MUX21X1 U622 ( .IN1(\memory[21][0] ), .IN2(n469), .S(n659), .Q(n392) );
  MUX21X1 U623 ( .IN1(\memory[21][1] ), .IN2(n470), .S(n659), .Q(n391) );
  AND2X1 U624 ( .IN1(n654), .IN2(n639), .Q(n659) );
  MUX21X1 U625 ( .IN1(\memory[22][0] ), .IN2(n469), .S(n660), .Q(n390) );
  MUX21X1 U626 ( .IN1(\memory[22][1] ), .IN2(n470), .S(n660), .Q(n389) );
  AND2X1 U627 ( .IN1(n654), .IN2(n641), .Q(n660) );
  MUX21X1 U628 ( .IN1(\memory[23][0] ), .IN2(n469), .S(n661), .Q(n388) );
  MUX21X1 U629 ( .IN1(\memory[23][1] ), .IN2(n470), .S(n661), .Q(n387) );
  AND2X1 U630 ( .IN1(n654), .IN2(n643), .Q(n661) );
  AND3X1 U631 ( .IN1(wr), .IN2(N110), .IN3(n98), .Q(n654) );
  MUX21X1 U632 ( .IN1(\memory[24][0] ), .IN2(n469), .S(n662), .Q(n386) );
  MUX21X1 U633 ( .IN1(\memory[24][1] ), .IN2(n470), .S(n662), .Q(n385) );
  AND2X1 U634 ( .IN1(n663), .IN2(n628), .Q(n662) );
  AND3X1 U635 ( .IN1(n99), .IN2(n100), .IN3(n827), .Q(n628) );
  MUX21X1 U636 ( .IN1(\memory[25][0] ), .IN2(n469), .S(n664), .Q(n384) );
  MUX21X1 U637 ( .IN1(\memory[25][1] ), .IN2(n470), .S(n664), .Q(n383) );
  AND2X1 U638 ( .IN1(n663), .IN2(n631), .Q(n664) );
  AND3X1 U639 ( .IN1(n99), .IN2(N106), .IN3(n827), .Q(n631) );
  MUX21X1 U640 ( .IN1(\memory[26][0] ), .IN2(n469), .S(n665), .Q(n382) );
  MUX21X1 U641 ( .IN1(\memory[26][1] ), .IN2(n470), .S(n665), .Q(n381) );
  AND2X1 U642 ( .IN1(n663), .IN2(n633), .Q(n665) );
  AND3X1 U643 ( .IN1(n100), .IN2(N107), .IN3(n827), .Q(n633) );
  MUX21X1 U644 ( .IN1(\memory[27][0] ), .IN2(n469), .S(n666), .Q(n380) );
  MUX21X1 U645 ( .IN1(\memory[27][1] ), .IN2(n470), .S(n666), .Q(n379) );
  AND2X1 U646 ( .IN1(n663), .IN2(n635), .Q(n666) );
  AND3X1 U647 ( .IN1(N106), .IN2(N107), .IN3(n827), .Q(n635) );
  MUX21X1 U648 ( .IN1(\memory[28][0] ), .IN2(n469), .S(n667), .Q(n378) );
  MUX21X1 U649 ( .IN1(\memory[28][1] ), .IN2(n470), .S(n667), .Q(n377) );
  AND2X1 U650 ( .IN1(n663), .IN2(n637), .Q(n667) );
  AND3X1 U651 ( .IN1(n100), .IN2(N108), .IN3(n99), .Q(n637) );
  MUX21X1 U652 ( .IN1(\memory[29][0] ), .IN2(n469), .S(n668), .Q(n376) );
  MUX21X1 U653 ( .IN1(\memory[29][1] ), .IN2(n470), .S(n668), .Q(n375) );
  AND2X1 U654 ( .IN1(n663), .IN2(n639), .Q(n668) );
  AND3X1 U655 ( .IN1(N106), .IN2(N108), .IN3(n99), .Q(n639) );
  MUX21X1 U656 ( .IN1(\memory[30][0] ), .IN2(n469), .S(n669), .Q(n374) );
  MUX21X1 U657 ( .IN1(\memory[30][1] ), .IN2(n470), .S(n669), .Q(n373) );
  AND2X1 U658 ( .IN1(n663), .IN2(n641), .Q(n669) );
  AND3X1 U659 ( .IN1(N107), .IN2(N108), .IN3(n100), .Q(n641) );
  MUX21X1 U660 ( .IN1(\memory[31][0] ), .IN2(n469), .S(n670), .Q(n372) );
  MUX21X1 U661 ( .IN1(\memory[31][1] ), .IN2(n470), .S(n670), .Q(n371) );
  AND2X1 U662 ( .IN1(n663), .IN2(n643), .Q(n670) );
  AND3X1 U663 ( .IN1(N107), .IN2(N108), .IN3(N106), .Q(n643) );
  AND3X1 U664 ( .IN1(N110), .IN2(N109), .IN3(wr), .Q(n663) );
  MUX21X1 U665 ( .IN1(n671), .IN2(play), .S(n672), .Q(n370) );
  NOR2X0 U666 ( .IN1(n673), .IN2(n674), .QN(n672) );
  OR3X1 U667 ( .IN1(n588), .IN2(n544), .IN3(n675), .Q(n671) );
  MUX21X1 U668 ( .IN1(sound[0]), .IN2(n676), .S(n673), .Q(n369) );
  AO221X1 U669 ( .IN1(n677), .IN2(n544), .IN3(n588), .IN4(n462), .IN5(n678), 
        .Q(n676) );
  MUX21X1 U670 ( .IN1(sound[2]), .IN2(n675), .S(n673), .Q(n368) );
  NAND2X0 U671 ( .IN1(n565), .IN2(n679), .QN(n675) );
  MUX21X1 U672 ( .IN1(sound[1]), .IN2(n680), .S(n673), .Q(n367) );
  NAND3X0 U673 ( .IN1(n681), .IN2(n682), .IN3(n683), .QN(n673) );
  INVX0 U674 ( .INP(n684), .ZN(n683) );
  AO21X1 U675 ( .IN1(n685), .IN2(n686), .IN3(n578), .Q(n681) );
  AO22X1 U676 ( .IN1(n544), .IN2(n687), .IN3(n588), .IN4(n471), .Q(n680) );
  XOR2X1 U677 ( .IN1(n826), .IN2(n688), .Q(n366) );
  NOR2X0 U678 ( .IN1(n689), .IN2(n481), .QN(n688) );
  NOR2X0 U679 ( .IN1(n481), .IN2(n690), .QN(n365) );
  MUX21X1 U680 ( .IN1(n826), .IN2(n825), .S(n689), .Q(n690) );
  OA22X1 U681 ( .IN1(n691), .IN2(n692), .IN3(n693), .IN4(n694), .Q(n689) );
  MUX21X1 U682 ( .IN1(n677), .IN2(n464), .S(n682), .Q(n364) );
  NOR2X0 U683 ( .IN1(k[0]), .IN2(n695), .QN(n677) );
  NOR2X0 U684 ( .IN1(n696), .IN2(k[1]), .QN(n695) );
  MUX21X1 U685 ( .IN1(n687), .IN2(n476), .S(n682), .Q(n363) );
  NAND2X0 U686 ( .IN1(n697), .IN2(n576), .QN(n682) );
  NAND3X0 U687 ( .IN1(n696), .IN2(n698), .IN3(n687), .QN(n576) );
  MUX21X1 U688 ( .IN1(n699), .IN2(nl[0]), .S(n700), .Q(n362) );
  AND3X1 U689 ( .IN1(n701), .IN2(n702), .IN3(n703), .Q(n700) );
  NAND3X0 U690 ( .IN1(n47), .IN2(n684), .IN3(n46), .QN(n702) );
  NAND3X0 U691 ( .IN1(n87), .IN2(n704), .IN3(n88), .QN(n701) );
  MUX21X1 U692 ( .IN1(n699), .IN2(nl[1]), .S(n705), .Q(n361) );
  AND3X1 U693 ( .IN1(n706), .IN2(n707), .IN3(n703), .Q(n705) );
  NAND3X0 U694 ( .IN1(n684), .IN2(n462), .IN3(n46), .QN(n707) );
  NAND3X0 U695 ( .IN1(n704), .IN2(n464), .IN3(n87), .QN(n706) );
  MUX21X1 U696 ( .IN1(n699), .IN2(nl[2]), .S(n708), .Q(n360) );
  AND3X1 U697 ( .IN1(n709), .IN2(n710), .IN3(n703), .Q(n708) );
  NAND3X0 U698 ( .IN1(n684), .IN2(n471), .IN3(n47), .QN(n710) );
  NAND3X0 U699 ( .IN1(n704), .IN2(n476), .IN3(n88), .QN(n709) );
  MUX21X1 U700 ( .IN1(n699), .IN2(nl[3]), .S(n711), .Q(n359) );
  AND3X1 U701 ( .IN1(n712), .IN2(n713), .IN3(n703), .Q(n711) );
  AOI21X1 U702 ( .IN1(n714), .IN2(n548), .IN3(n674), .QN(n703) );
  AO21X1 U703 ( .IN1(n548), .IN2(n715), .IN3(n547), .Q(n674) );
  NAND4X0 U704 ( .IN1(n574), .IN2(n589), .IN3(n716), .IN4(n717), .QN(n715) );
  NAND3X0 U705 ( .IN1(n471), .IN2(n462), .IN3(n684), .QN(n713) );
  AO21X1 U706 ( .IN1(n548), .IN2(n718), .IN3(n588), .Q(n684) );
  NAND2X0 U707 ( .IN1(n719), .IN2(n720), .QN(n718) );
  NAND3X0 U708 ( .IN1(n476), .IN2(n464), .IN3(n704), .QN(n712) );
  OR4X1 U709 ( .IN1(n678), .IN2(n588), .IN3(n721), .IN4(n704), .Q(n699) );
  INVX0 U710 ( .INP(n716), .ZN(n721) );
  NAND2X0 U711 ( .IN1(n722), .IN2(n720), .QN(n678) );
  AO221X1 U712 ( .IN1(n723), .IN2(n555), .IN3(n621), .IN4(timebase[0]), .IN5(
        n547), .Q(n358) );
  INVX0 U713 ( .INP(n724), .ZN(n555) );
  AO22X1 U714 ( .IN1(n621), .IN2(timebase[1]), .IN3(n723), .IN4(n567), .Q(n357) );
  AO21X1 U715 ( .IN1(n725), .IN2(n724), .IN3(n726), .Q(n567) );
  AO22X1 U716 ( .IN1(n621), .IN2(timebase[2]), .IN3(n723), .IN4(n566), .Q(n356) );
  AO21X1 U717 ( .IN1(n727), .IN2(n728), .IN3(n729), .Q(n566) );
  AO22X1 U718 ( .IN1(n621), .IN2(timebase[3]), .IN3(n723), .IN4(n562), .Q(n355) );
  AO21X1 U719 ( .IN1(n730), .IN2(n731), .IN3(n732), .Q(n562) );
  AO22X1 U720 ( .IN1(n621), .IN2(timebase[4]), .IN3(n723), .IN4(n558), .Q(n354) );
  XNOR2X1 U721 ( .IN1(n733), .IN2(n732), .Q(n558) );
  AO221X1 U722 ( .IN1(n723), .IN2(n540), .IN3(n621), .IN4(timebase[5]), .IN5(
        n547), .Q(n353) );
  XOR2X1 U723 ( .IN1(n734), .IN2(n735), .Q(n540) );
  AOI21X1 U724 ( .IN1(n736), .IN2(timebase[5]), .IN3(n461), .QN(n735) );
  NAND2X0 U725 ( .IN1(n733), .IN2(n732), .QN(n734) );
  NOR2X0 U726 ( .IN1(n731), .IN2(n730), .QN(n732) );
  AO21X1 U727 ( .IN1(timebase[3]), .IN2(n736), .IN3(n466), .Q(n730) );
  INVX0 U728 ( .INP(n729), .ZN(n731) );
  NOR2X0 U729 ( .IN1(n728), .IN2(n727), .QN(n729) );
  INVX0 U730 ( .INP(n726), .ZN(n727) );
  NOR2X0 U731 ( .IN1(n724), .IN2(n725), .QN(n726) );
  AO21X1 U732 ( .IN1(timebase[1]), .IN2(n736), .IN3(n483), .Q(n725) );
  AO21X1 U733 ( .IN1(timebase[0]), .IN2(n736), .IN3(n482), .Q(n724) );
  AO21X1 U734 ( .IN1(timebase[2]), .IN2(n736), .IN3(n484), .Q(n728) );
  AOI21X1 U735 ( .IN1(timebase[4]), .IN2(n736), .IN3(n478), .QN(n733) );
  NOR2X0 U736 ( .IN1(n737), .IN2(n621), .QN(n723) );
  NAND4X0 U737 ( .IN1(n564), .IN2(n738), .IN3(n739), .IN4(n740), .QN(N889) );
  OAI21X1 U738 ( .IN1(n583), .IN2(n544), .IN3(n548), .QN(n738) );
  NAND2X0 U739 ( .IN1(n589), .IN2(n686), .QN(n583) );
  OR3X1 U740 ( .IN1(n607), .IN2(n741), .IN3(n737), .Q(n686) );
  INVX0 U741 ( .INP(n577), .ZN(n564) );
  NAND3X0 U742 ( .IN1(n716), .IN2(n717), .IN3(n679), .QN(n577) );
  NAND4X0 U743 ( .IN1(n742), .IN2(n685), .IN3(n743), .IN4(n744), .QN(N888) );
  NOR4X0 U744 ( .IN1(n745), .IN2(n697), .IN3(n571), .IN4(n704), .QN(n744) );
  NAND2X0 U745 ( .IN1(n716), .IN2(n579), .QN(n745) );
  OA22X1 U746 ( .IN1(n746), .IN2(n737), .IN3(n747), .IN4(n748), .Q(n743) );
  NAND3X0 U747 ( .IN1(n548), .IN2(n749), .IN3(n570), .QN(n742) );
  NAND4X0 U748 ( .IN1(n750), .IN2(n751), .IN3(n752), .IN4(n753), .QN(N887) );
  NOR4X0 U749 ( .IN1(n704), .IN2(n754), .IN3(n755), .IN4(n756), .QN(n753) );
  INVX0 U750 ( .INP(n553), .ZN(n756) );
  NAND2X0 U751 ( .IN1(n757), .IN2(n758), .QN(n553) );
  NOR2X0 U752 ( .IN1(n759), .IN2(n747), .QN(n704) );
  NOR2X0 U753 ( .IN1(n760), .IN2(n758), .QN(n747) );
  AOI21X1 U754 ( .IN1(n549), .IN2(n697), .IN3(n582), .QN(n752) );
  NAND3X0 U755 ( .IN1(n761), .IN2(n719), .IN3(n574), .QN(n582) );
  INVX0 U756 ( .INP(n588), .ZN(n761) );
  AO21X1 U757 ( .IN1(n758), .IN2(n762), .IN3(n763), .Q(n588) );
  NAND2X0 U758 ( .IN1(n764), .IN2(n765), .QN(n549) );
  MUX21X1 U759 ( .IN1(n47), .IN2(n766), .S(n767), .Q(n765) );
  NAND2X0 U760 ( .IN1(n47), .IN2(k[1]), .QN(n766) );
  MUX21X1 U761 ( .IN1(n46), .IN2(n768), .S(n687), .Q(n764) );
  OA21X1 U762 ( .IN1(n769), .IN2(n471), .IN3(n770), .Q(n768) );
  MUX21X1 U763 ( .IN1(n47), .IN2(n771), .S(n696), .Q(n770) );
  NAND2X0 U764 ( .IN1(k[3]), .IN2(n47), .QN(n771) );
  NOR2X0 U765 ( .IN1(k[2]), .IN2(k[3]), .QN(n769) );
  INVX0 U766 ( .INP(n772), .ZN(n751) );
  NAND4X0 U767 ( .IN1(n773), .IN2(n626), .IN3(n774), .IN4(n775), .QN(N886) );
  NOR4X0 U768 ( .IN1(n776), .IN2(n754), .IN3(n763), .IN4(n697), .QN(n775) );
  NOR2X0 U769 ( .IN1(n575), .IN2(n548), .QN(n697) );
  AND3X1 U770 ( .IN1(n777), .IN2(n118), .IN3(n778), .Q(n763) );
  NAND2X0 U771 ( .IN1(n779), .IN2(n720), .QN(n776) );
  OA221X1 U772 ( .IN1(n748), .IN2(n780), .IN3(n578), .IN4(n719), .IN5(n621), 
        .Q(n774) );
  NOR2X0 U773 ( .IN1(n547), .IN2(n736), .QN(n621) );
  AND2X1 U774 ( .IN1(n746), .IN2(n606), .Q(n736) );
  AND3X1 U775 ( .IN1(n749), .IN2(n741), .IN3(n548), .Q(n746) );
  OR3X1 U776 ( .IN1(n835), .IN2(n832), .IN3(n617), .Q(n741) );
  NAND3X0 U777 ( .IN1(n463), .IN2(n473), .IN3(n460), .QN(n617) );
  NAND2X0 U778 ( .IN1(n781), .IN2(n782), .QN(n547) );
  NAND4X0 U779 ( .IN1(n758), .IN2(n119), .IN3(n121), .IN4(n118), .QN(n782) );
  NAND2X0 U780 ( .IN1(n783), .IN2(n749), .QN(n719) );
  OA21X1 U781 ( .IN1(n780), .IN2(n739), .IN3(n550), .Q(n626) );
  INVX0 U782 ( .INP(n758), .ZN(n780) );
  NAND4X0 U783 ( .IN1(n773), .IN2(n750), .IN3(n784), .IN4(n785), .QN(N885) );
  NOR4X0 U784 ( .IN1(n543), .IN2(n605), .IN3(n622), .IN4(n786), .QN(n785) );
  NOR2X0 U785 ( .IN1(n575), .IN2(n787), .QN(n786) );
  MUX21X1 U786 ( .IN1(n788), .IN2(n789), .S(n471), .Q(n787) );
  NAND2X0 U787 ( .IN1(n790), .IN2(n687), .QN(n789) );
  NOR2X0 U788 ( .IN1(k[0]), .IN2(k[1]), .QN(n687) );
  MUX21X1 U789 ( .IN1(n47), .IN2(n791), .S(n696), .Q(n790) );
  INVX0 U790 ( .INP(k[2]), .ZN(n696) );
  NOR2X0 U791 ( .IN1(n47), .IN2(n698), .QN(n791) );
  INVX0 U792 ( .INP(k[3]), .ZN(n698) );
  MUX21X1 U793 ( .IN1(n767), .IN2(n792), .S(n462), .Q(n788) );
  NAND2X0 U794 ( .IN1(k[1]), .IN2(n767), .QN(n792) );
  INVX0 U795 ( .INP(k[0]), .ZN(n767) );
  NOR2X0 U796 ( .IN1(n722), .IN2(n749), .QN(n622) );
  INVX0 U797 ( .INP(n607), .ZN(n749) );
  INVX0 U798 ( .INP(n550), .ZN(n605) );
  NAND2X0 U799 ( .IN1(n757), .IN2(n793), .QN(n550) );
  INVX0 U800 ( .INP(n579), .ZN(n543) );
  NAND2X0 U801 ( .IN1(n793), .IN2(n794), .QN(n579) );
  MUX21X1 U802 ( .IN1(n795), .IN2(n679), .S(n578), .Q(n784) );
  NOR2X0 U803 ( .IN1(n755), .IN2(n714), .QN(n679) );
  INVX0 U804 ( .INP(n685), .ZN(n714) );
  NAND2X0 U805 ( .IN1(n758), .IN2(n796), .QN(n685) );
  NOR2X0 U806 ( .IN1(n468), .IN2(n122), .QN(n758) );
  INVX0 U807 ( .INP(n720), .ZN(n755) );
  NAND2X0 U808 ( .IN1(n762), .IN2(n777), .QN(n720) );
  NOR4X0 U809 ( .IN1(n544), .IN2(n797), .IN3(n572), .IN4(n798), .QN(n795) );
  INVX0 U810 ( .INP(n574), .ZN(n798) );
  OA221X1 U811 ( .IN1(n799), .IN2(n739), .IN3(n799), .IN4(n748), .IN5(n779), 
        .Q(n574) );
  NAND2X0 U812 ( .IN1(n757), .IN2(n760), .QN(n779) );
  INVX0 U813 ( .INP(n586), .ZN(n572) );
  NAND2X0 U814 ( .IN1(n793), .IN2(n800), .QN(n586) );
  NAND2X0 U815 ( .IN1(n716), .IN2(n717), .QN(n797) );
  INVX0 U816 ( .INP(n754), .ZN(n717) );
  NOR2X0 U817 ( .IN1(n740), .IN2(n799), .QN(n754) );
  INVX0 U818 ( .INP(n760), .ZN(n799) );
  NAND2X0 U819 ( .IN1(n793), .IN2(n796), .QN(n716) );
  AND4X1 U820 ( .IN1(n121), .IN2(n477), .IN3(n465), .IN4(n781), .Q(n796) );
  INVX0 U821 ( .INP(n575), .ZN(n544) );
  NAND2X0 U822 ( .IN1(n801), .IN2(n793), .QN(n575) );
  AND2X1 U823 ( .IN1(n569), .IN2(n802), .Q(n750) );
  NAND3X0 U824 ( .IN1(n778), .IN2(n118), .IN3(n760), .QN(n802) );
  OR2X1 U825 ( .IN1(n565), .IN2(n548), .Q(n569) );
  NOR2X0 U826 ( .IN1(n783), .IN2(n606), .QN(n565) );
  INVX0 U827 ( .INP(n737), .ZN(n606) );
  NAND2X0 U828 ( .IN1(n777), .IN2(n794), .QN(n737) );
  INVX0 U829 ( .INP(n748), .ZN(n794) );
  NAND4X0 U830 ( .IN1(n121), .IN2(n118), .IN3(n465), .IN4(n781), .QN(n748) );
  INVX0 U831 ( .INP(n722), .ZN(n783) );
  NAND2X0 U832 ( .IN1(n800), .IN2(n777), .QN(n722) );
  INVX0 U833 ( .INP(n739), .ZN(n800) );
  NAND2X0 U834 ( .IN1(n778), .IN2(n477), .QN(n739) );
  AND3X1 U835 ( .IN1(n121), .IN2(n781), .IN3(n119), .Q(n778) );
  INVX0 U836 ( .INP(start), .ZN(n781) );
  AOI221X1 U837 ( .IN1(n570), .IN2(n607), .IN3(n801), .IN4(n760), .IN5(n803), 
        .QN(n773) );
  AO21X1 U838 ( .IN1(n793), .IN2(n762), .IN3(n772), .Q(n803) );
  AO21X1 U839 ( .IN1(n570), .IN2(n578), .IN3(n571), .Q(n772) );
  NOR2X0 U840 ( .IN1(n589), .IN2(n548), .QN(n571) );
  INVX0 U841 ( .INP(n578), .ZN(n548) );
  NAND2X0 U842 ( .IN1(n801), .IN2(n777), .QN(n589) );
  NAND4X0 U843 ( .IN1(n829), .IN2(n830), .IN3(n828), .IN4(n804), .QN(n578) );
  NOR3X0 U844 ( .IN1(n461), .IN2(n466), .IN3(n478), .QN(n804) );
  INVX0 U845 ( .INP(n740), .ZN(n762) );
  NAND3X0 U846 ( .IN1(n119), .IN2(n477), .IN3(n805), .QN(n740) );
  NOR2X0 U847 ( .IN1(n468), .IN2(n480), .QN(n793) );
  NOR2X0 U848 ( .IN1(n480), .IN2(n120), .QN(n760) );
  INVX0 U849 ( .INP(n759), .ZN(n801) );
  NAND3X0 U850 ( .IN1(n118), .IN2(n465), .IN3(n805), .QN(n759) );
  NAND4X0 U851 ( .IN1(n806), .IN2(n807), .IN3(n808), .IN4(n809), .QN(n607) );
  XNOR2X1 U852 ( .IN1(scan[2]), .IN2(n460), .Q(n809) );
  NOR2X0 U853 ( .IN1(n810), .IN2(n811), .QN(n808) );
  XNOR2X1 U854 ( .IN1(scan[3]), .IN2(n835), .Q(n811) );
  XNOR2X1 U855 ( .IN1(n834), .IN2(scan[1]), .Q(n810) );
  XNOR2X1 U856 ( .IN1(n472), .IN2(n833), .Q(n807) );
  XNOR2X1 U857 ( .IN1(scan[4]), .IN2(n474), .Q(n806) );
  INVX0 U858 ( .INP(n585), .ZN(n570) );
  NAND2X0 U859 ( .IN1(n757), .IN2(n777), .QN(n585) );
  NOR2X0 U860 ( .IN1(n120), .IN2(n122), .QN(n777) );
  AND3X1 U861 ( .IN1(n119), .IN2(n118), .IN3(n805), .Q(n757) );
  NOR2X0 U862 ( .IN1(n121), .IN2(start), .QN(n805) );
  XOR2X1 U863 ( .IN1(n831), .IN2(n40), .Q(N203) );
  NOR2X0 U864 ( .IN1(n812), .IN2(n813), .QN(N198) );
  OA21X1 U865 ( .IN1(n38), .IN2(n37), .IN3(n35), .Q(n812) );
  MUX21X1 U866 ( .IN1(N196), .IN2(n814), .S(n37), .Q(N197) );
  NOR2X0 U867 ( .IN1(n38), .IN2(n813), .QN(n814) );
  NOR2X0 U868 ( .IN1(n485), .IN2(n813), .QN(N196) );
  NAND2X0 U869 ( .IN1(play), .IN2(n815), .QN(n813) );
  AO22X1 U870 ( .IN1(n692), .IN2(n816), .IN3(n694), .IN4(n817), .Q(n815) );
  INVX0 U871 ( .INP(n693), .ZN(n817) );
  OA21X1 U872 ( .IN1(sound[0]), .IN2(sound[1]), .IN3(n818), .Q(n693) );
  INVX0 U873 ( .INP(n819), .ZN(n818) );
  OA21X1 U874 ( .IN1(sound[2]), .IN2(n35), .IN3(n820), .Q(n694) );
  OR4X1 U875 ( .IN1(n821), .IN2(n819), .IN3(n37), .IN4(n38), .Q(n820) );
  NOR3X0 U876 ( .IN1(sound[1]), .IN2(sound[2]), .IN3(n486), .QN(n819) );
  AND2X1 U877 ( .IN1(n35), .IN2(sound[2]), .Q(n821) );
  INVX0 U878 ( .INP(n691), .ZN(n816) );
  MUX21X1 U879 ( .IN1(n822), .IN2(sound[2]), .S(sound[1]), .Q(n691) );
  NAND2X0 U880 ( .IN1(sound[2]), .IN2(sound[0]), .QN(n822) );
  OA22X1 U881 ( .IN1(n35), .IN2(n823), .IN3(sound[1]), .IN4(n824), .Q(n692) );
  AND2X1 U882 ( .IN1(n35), .IN2(n37), .Q(n824) );
  OA21X1 U883 ( .IN1(sound[0]), .IN2(n38), .IN3(n37), .Q(n823) );
endmodule