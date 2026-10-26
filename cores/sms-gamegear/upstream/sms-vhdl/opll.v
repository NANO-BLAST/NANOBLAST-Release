module linear_table_mul_Brtl
  (input  [5:0] i0,
   input  [9:0] i1,
   output [9:0] o);
  wire [16:0] w_mul;
  wire [6:0] n4083;
  wire [16:0] n4084;
  wire [16:0] n4085;
  wire [16:0] n4086;
  wire [9:0] n4087;
  assign o = n4087; //(module output)
  /*# work/sms-vhdl/compat/lineartable.vhd:50:12 */
  assign w_mul = n4086; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:53:21 */
  assign n4083 = {1'b0, i0};
  /*# work/sms-vhdl/compat/lineartable.vhd:53:27 */
  assign n4084 = {{10{n4083[6]}}, n4083}; // sext
  /*# work/sms-vhdl/compat/lineartable.vhd:53:27 */
  assign n4085 = {{7{i1[9]}}, i1}; // sext
  /*# work/sms-vhdl/compat/lineartable.vhd:53:27 */
  assign n4086 = $signed(n4084) * $signed(n4085); // smul
  /*# work/sms-vhdl/compat/lineartable.vhd:54:21 */
  assign n4087 = w_mul[15:6]; // extract
endmodule

module interpolate_mul_Brtl
  (input  [8:0] i0,
   input  [11:0] i1,
   output [13:0] o);
  wire [21:0] w_mul;
  wire [9:0] n4076;
  wire [21:0] n4077;
  wire [21:0] n4078;
  wire [21:0] n4079;
  wire [13:0] n4080;
  assign o = n4080; //(module output)
  /*# work/sms-vhdl/compat/sinetable.vhd:50:12 */
  assign w_mul = n4079; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:53:21 */
  assign n4076 = {1'b0, i0};
  /*# work/sms-vhdl/compat/sinetable.vhd:53:27 */
  assign n4077 = {{12{n4076[9]}}, n4076}; // sext
  /*# work/sms-vhdl/compat/sinetable.vhd:53:27 */
  assign n4078 = {{10{i1[11]}}, i1}; // sext
  /*# work/sms-vhdl/compat/sinetable.vhd:53:27 */
  assign n4079 = $signed(n4077) * $signed(n4078); // smul
  /*# work/sms-vhdl/compat/sinetable.vhd:54:21 */
  assign n4080 = w_mul[20:7]; // extract
endmodule

module attack_table_mul_Brtl
  (input  [7:0] i0,
   input  [7:0] i1,
   output [13:0] o);
  wire [16:0] w_mul;
  wire [8:0] n4069;
  wire [16:0] n4070;
  wire [16:0] n4071;
  wire [16:0] n4072;
  wire [13:0] n4073;
  assign o = n4073; //(module output)
  /*# work/sms-vhdl/compat/attacktable.vhd:51:12 */
  assign w_mul = n4072; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:54:21 */
  assign n4069 = {1'b0, i0};
  /*# work/sms-vhdl/compat/attacktable.vhd:54:27 */
  assign n4070 = {{8{n4069[8]}}, n4069}; // sext
  /*# work/sms-vhdl/compat/attacktable.vhd:54:27 */
  assign n4071 = {{9{i1[7]}}, i1}; // sext
  /*# work/sms-vhdl/compat/attacktable.vhd:54:27 */
  assign n4072 = $signed(n4070) * $signed(n4071); // smul
  /*# work/sms-vhdl/compat/attacktable.vhd:55:21 */
  assign n4073 = w_mul[15:2]; // extract
endmodule

module voicerom_Brtl_c4ea21bb365bbeeaf5f2c654883e56d11e43c44e
  (input  clk,
   input  [5:0] addr,
   output \data[am] ,
   output \data[pm] ,
   output \data[eg] ,
   output \data[kr] ,
   output [3:0] \data[ml] ,
   output [1:0] \data[kl] ,
   output [5:0] \data[tl] ,
   output \data[wf] ,
   output [2:0] \data[fb] ,
   output [3:0] \data[ar] ,
   output [3:0] \data[dr] ,
   output [3:0] \data[sl] ,
   output [3:0] \data[rr] );
  wire n4021;
  wire n4022;
  wire n4023;
  wire n4024;
  wire [3:0] n4025;
  wire [1:0] n4026;
  wire [5:0] n4027;
  wire n4028;
  wire [2:0] n4029;
  wire [3:0] n4030;
  wire [3:0] n4031;
  wire [3:0] n4032;
  wire [3:0] n4033;
  wire n4047;
  wire n4048;
  wire n4049;
  wire n4050;
  wire [3:0] n4051;
  wire [1:0] n4052;
  wire [5:0] n4053;
  wire n4054;
  wire [2:0] n4055;
  wire [3:0] n4056;
  wire [3:0] n4057;
  wire [3:0] n4058;
  wire [3:0] n4059;
  wire [35:0] n4060;
  reg [35:0] n4063;
  wire [35:0] n4066; // mem_rd
  assign \data[am]  = n4021; //(module output)
  assign \data[pm]  = n4022; //(module output)
  assign \data[eg]  = n4023; //(module output)
  assign \data[kr]  = n4024; //(module output)
  assign \data[ml]  = n4025; //(module output)
  assign \data[kl]  = n4026; //(module output)
  assign \data[tl]  = n4027; //(module output)
  assign \data[wf]  = n4028; //(module output)
  assign \data[fb]  = n4029; //(module output)
  assign \data[ar]  = n4030; //(module output)
  assign \data[dr]  = n4031; //(module output)
  assign \data[sl]  = n4032; //(module output)
  assign \data[rr]  = n4033; //(module output)
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4021 = n4063[0]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4022 = n4063[1]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4023 = n4063[2]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4024 = n4063[3]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4025 = n4063[7:4]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4026 = n4063[9:8]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4027 = n4063[15:10]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4028 = n4063[16]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4029 = n4063[19:17]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4030 = n4063[23:20]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4031 = n4063[27:24]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4032 = n4063[31:28]; // extract
  /*# work/sms-vhdl/compat/voicerom.vhd:38:8 */
  assign n4033 = n4063[35:32]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:19 */
  assign n4047 = n4066[35]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:37 */
  assign n4048 = n4066[34]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:55 */
  assign n4049 = n4066[33]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:73 */
  assign n4050 = n4066[32]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:19 */
  assign n4051 = n4066[31:28]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:47 */
  assign n4052 = n4066[27:26]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:75 */
  assign n4053 = n4066[25:20]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:179:19 */
  assign n4054 = n4066[19]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:179:37 */
  assign n4055 = n4066[18:16]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:19 */
  assign n4056 = n4066[15:12]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:47 */
  assign n4057 = n4066[11:8]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:74 */
  assign n4058 = n4066[7:4]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:100 */
  assign n4059 = n4066[3:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:176:12 */
  assign n4060 = {n4059, n4058, n4057, n4056, n4055, n4054, n4053, n4052, n4051, n4050, n4049, n4048, n4047};
  /*# work/sms-vhdl/compat/voicerom.vhd:187:5 */
  always @(posedge clk)
    n4063 <= n4060;
  /*# work/sms-vhdl/compat/voicerom.vhd:189:40 */
  reg [35:0] n4064[37:0] ; // memory
  initial begin
    n4064[37] = 36'b000000010000000000001010101001010101;
    n4064[36] = 36'b000001010000000000001111100001011001;
    n4064[35] = 36'b000000010000000000001101100001001000;
    n4064[34] = 36'b000000010000000000001100100010100111;
    n4064[33] = 36'b000000010000000000001111100001101101;
    n4064[32] = 36'b000000010001100011111101111101101010;
    n4064[31] = 36'b010000010000000000001110010000010011;
    n4064[30] = 36'b011000011000100100111111000101000000;
    n4064[29] = 36'b000000010000000000001001010100000010;
    n4064[28] = 36'b000000010101010100111100100100000011;
    n4064[27] = 36'b010100000000000000001111010101000010;
    n4064[26] = 36'b011000010000110001011100001000100000;
    n4064[25] = 36'b110000010000000000001111100000010010;
    n4064[24] = 36'b000101110010010001111111100000100010;
    n4064[23] = 36'b000000010000000010001110010000000100;
    n4064[22] = 36'b000100111000001100011111101000010000;
    n4064[21] = 36'b011000010000000010001111011100000111;
    n4064[20] = 36'b010000010000101110001000010101110001;
    n4064[19] = 36'b011000010000000000000110010100010111;
    n4064[18] = 36'b011000010001101101100110010000010000;
    n4064[17] = 36'b001000010000000010000111001000000111;
    n4064[16] = 36'b001000110010110101001010001000000000;
    n4064[15] = 36'b011000010000000000001000000100000111;
    n4064[14] = 36'b001000010001110101111000001000010000;
    n4064[13] = 36'b001000100000000000000111000100011000;
    n4064[12] = 36'b001100010001011001011110000000000000;
    n4064[11] = 36'b001000010000000000000111011000101000;
    n4064[10] = 36'b001100100001111001101110000000000000;
    n4064[9] = 36'b011000010000000000000110010000100111;
    n4064[8] = 36'b001100010000111001111010100001110000;
    n4064[7] = 36'b000000010000000000001100010000100011;
    n4064[6] = 36'b000100111001100100001111001000010001;
    n4064[5] = 36'b010000010000000000001111011100010011;
    n4064[4] = 36'b000100110001101011011101100000100011;
    n4064[3] = 36'b011000010000000010000111100000010111;
    n4064[2] = 36'b011100010001111001111101000000000000;
    n4064[1] = 36'b000000000000000000000000000000000000;
    n4064[0] = 36'b000000000000000000000000000000000000;
    end
  assign n4066 = n4064[addr];
  /*# work/sms-vhdl/compat/voicerom.vhd:189:40 */
endmodule

module lineartable_Brtl
  (input  clk,
   input  reset,
   input  [13:0] addr,
   output \data[sign] ,
   output [8:0] \data[value] );
  wire n3954;
  wire [8:0] n3955;
  wire ff_sign;
  wire [5:0] ff_weight;
  wire [8:0] ff_data0;
  wire [8:0] ff_data1;
  wire [6:0] w_addr1;
  wire [9:0] w_sub;
  wire [9:0] w_mul;
  wire [9:0] w_inter;
  wire [6:0] n3956;
  wire [6:0] n3958;
  wire [6:0] n3959;
  wire n3961;
  wire [6:0] n3962;
  wire [6:0] n3967;
  wire n3985;
  wire [5:0] n3986;
  wire [9:0] n3991;
  wire [9:0] n3993;
  wire [9:0] n3994;
  wire [9:0] u_linear_table_mul_n3995;
  wire [9:0] n3999;
  wire [9:0] n4000;
  wire [8:0] n4004;
  wire [9:0] n4005;
  reg [9:0] n4009;
  reg n4010;
  reg [5:0] n4011;
  reg [8:0] n4017; // mem_rd
  reg [8:0] n4019; // mem_rd
  assign \data[sign]  = n3954; //(module output)
  assign \data[value]  = n3955; //(module output)
  /*# work/sms-vhdl/compat/lineartable.vhd:63:8 */
  assign n3954 = n4009[0]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:63:8 */
  assign n3955 = n4009[9:1]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:118:12 */
  assign ff_sign = n4010; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:119:12 */
  assign ff_weight = n4011; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:120:12 */
  assign ff_data0 = n4019; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:121:12 */
  assign ff_data1 = n4017; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:123:12 */
  assign w_addr1 = n3962; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:125:12 */
  assign w_sub = n3994; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:126:12 */
  assign w_mul = u_linear_table_mul_n3995; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:127:12 */
  assign w_inter = n4000; // (signal)
  /*# work/sms-vhdl/compat/lineartable.vhd:129:21 */
  assign n3956 = addr[12:6]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:129:37 */
  assign n3958 = n3956 + 7'b0000001;
  /*# work/sms-vhdl/compat/lineartable.vhd:129:52 */
  assign n3959 = addr[12:6]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:129:68 */
  assign n3961 = n3959 != 7'b1111111;
  /*# work/sms-vhdl/compat/lineartable.vhd:129:42 */
  assign n3962 = n3961 ? n3958 : 7'b1111111;
  /*# work/sms-vhdl/compat/lineartable.vhd:136:57 */
  assign n3967 = addr[12:6]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:144:32 */
  assign n3985 = addr[13]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:145:32 */
  assign n3986 = addr[5:0]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:151:22 */
  assign n3991 = {1'b0, ff_data1};
  /*# work/sms-vhdl/compat/lineartable.vhd:151:41 */
  assign n3993 = {1'b0, ff_data0};
  /*# work/sms-vhdl/compat/lineartable.vhd:151:34 */
  assign n3994 = n3991 - n3993;
  /*# work/sms-vhdl/compat/lineartable.vhd:153:5 */
  linear_table_mul_Brtl u_linear_table_mul (
    .i0(ff_weight),
    .i1(w_sub),
    .o(u_linear_table_mul_n3995));
  /*# work/sms-vhdl/compat/lineartable.vhd:160:21 */
  assign n3999 = {1'b0, ff_data0};
  /*# work/sms-vhdl/compat/lineartable.vhd:160:33 */
  assign n4000 = n3999 + w_mul;
  /*# work/sms-vhdl/compat/lineartable.vhd:167:35 */
  assign n4004 = w_inter[8:0]; // extract
  /*# work/sms-vhdl/compat/lineartable.vhd:165:21 */
  assign n4005 = {n4004, ff_sign};
  /*# work/sms-vhdl/compat/lineartable.vhd:164:9 */
  always @(posedge clk)
    n4009 <= n4005;
  /*# work/sms-vhdl/compat/lineartable.vhd:143:9 */
  always @(posedge clk)
    n4010 <= n3985;
  /*# work/sms-vhdl/compat/lineartable.vhd:143:9 */
  always @(posedge clk)
    n4011 <= n3986;
  /*# work/sms-vhdl/compat/lineartable.vhd:136:39 */
  reg [8:0] n4014[127:0] ; // memory
  initial begin
    n4014[127] = 9'b000000000;
    n4014[126] = 9'b000000010;
    n4014[125] = 9'b000000010;
    n4014[124] = 9'b000000010;
    n4014[123] = 9'b000000010;
    n4014[122] = 9'b000000010;
    n4014[121] = 9'b000000010;
    n4014[120] = 9'b000000010;
    n4014[119] = 9'b000000011;
    n4014[118] = 9'b000000011;
    n4014[117] = 9'b000000011;
    n4014[116] = 9'b000000011;
    n4014[115] = 9'b000000011;
    n4014[114] = 9'b000000011;
    n4014[113] = 9'b000000011;
    n4014[112] = 9'b000000100;
    n4014[111] = 9'b000000100;
    n4014[110] = 9'b000000100;
    n4014[109] = 9'b000000100;
    n4014[108] = 9'b000000100;
    n4014[107] = 9'b000000101;
    n4014[106] = 9'b000000101;
    n4014[105] = 9'b000000101;
    n4014[104] = 9'b000000101;
    n4014[103] = 9'b000000101;
    n4014[102] = 9'b000000110;
    n4014[101] = 9'b000000110;
    n4014[100] = 9'b000000110;
    n4014[99] = 9'b000000111;
    n4014[98] = 9'b000000111;
    n4014[97] = 9'b000000111;
    n4014[96] = 9'b000001000;
    n4014[95] = 9'b000001000;
    n4014[94] = 9'b000001000;
    n4014[93] = 9'b000001001;
    n4014[92] = 9'b000001001;
    n4014[91] = 9'b000001010;
    n4014[90] = 9'b000001010;
    n4014[89] = 9'b000001010;
    n4014[88] = 9'b000001011;
    n4014[87] = 9'b000001011;
    n4014[86] = 9'b000001100;
    n4014[85] = 9'b000001101;
    n4014[84] = 9'b000001101;
    n4014[83] = 9'b000001110;
    n4014[82] = 9'b000001110;
    n4014[81] = 9'b000001111;
    n4014[80] = 9'b000010000;
    n4014[79] = 9'b000010000;
    n4014[78] = 9'b000010001;
    n4014[77] = 9'b000010010;
    n4014[76] = 9'b000010011;
    n4014[75] = 9'b000010100;
    n4014[74] = 9'b000010100;
    n4014[73] = 9'b000010101;
    n4014[72] = 9'b000010110;
    n4014[71] = 9'b000010111;
    n4014[70] = 9'b000011000;
    n4014[69] = 9'b000011001;
    n4014[68] = 9'b000011011;
    n4014[67] = 9'b000011100;
    n4014[66] = 9'b000011101;
    n4014[65] = 9'b000011110;
    n4014[64] = 9'b000100000;
    n4014[63] = 9'b000100001;
    n4014[62] = 9'b000100011;
    n4014[61] = 9'b000100100;
    n4014[60] = 9'b000100110;
    n4014[59] = 9'b000101000;
    n4014[58] = 9'b000101001;
    n4014[57] = 9'b000101011;
    n4014[56] = 9'b000101101;
    n4014[55] = 9'b000101111;
    n4014[54] = 9'b000110001;
    n4014[53] = 9'b000110011;
    n4014[52] = 9'b000110110;
    n4014[51] = 9'b000111000;
    n4014[50] = 9'b000111011;
    n4014[49] = 9'b000111101;
    n4014[48] = 9'b001000000;
    n4014[47] = 9'b001000011;
    n4014[46] = 9'b001000110;
    n4014[45] = 9'b001001001;
    n4014[44] = 9'b001001100;
    n4014[43] = 9'b001001111;
    n4014[42] = 9'b001010011;
    n4014[41] = 9'b001010111;
    n4014[40] = 9'b001011010;
    n4014[39] = 9'b001011110;
    n4014[38] = 9'b001100011;
    n4014[37] = 9'b001100111;
    n4014[36] = 9'b001101011;
    n4014[35] = 9'b001110000;
    n4014[34] = 9'b001110101;
    n4014[33] = 9'b001111010;
    n4014[32] = 9'b010000000;
    n4014[31] = 9'b010000110;
    n4014[30] = 9'b010001011;
    n4014[29] = 9'b010010010;
    n4014[28] = 9'b010011000;
    n4014[27] = 9'b010011111;
    n4014[26] = 9'b010100110;
    n4014[25] = 9'b010101101;
    n4014[24] = 9'b010110101;
    n4014[23] = 9'b010111101;
    n4014[22] = 9'b011000101;
    n4014[21] = 9'b011001110;
    n4014[20] = 9'b011010111;
    n4014[19] = 9'b011100000;
    n4014[18] = 9'b011101010;
    n4014[17] = 9'b011110101;
    n4014[16] = 9'b100000000;
    n4014[15] = 9'b100001011;
    n4014[14] = 9'b100010111;
    n4014[13] = 9'b100100011;
    n4014[12] = 9'b100110000;
    n4014[11] = 9'b100111101;
    n4014[10] = 9'b101001011;
    n4014[9] = 9'b101011010;
    n4014[8] = 9'b101101001;
    n4014[7] = 9'b101111001;
    n4014[6] = 9'b110001010;
    n4014[5] = 9'b110011011;
    n4014[4] = 9'b110101101;
    n4014[3] = 9'b111000000;
    n4014[2] = 9'b111010100;
    n4014[1] = 9'b111101001;
    n4014[0] = 9'b111111111;
    end
  always @(posedge clk)
    if (1'b1)
      n4017 <= n4014[w_addr1];
  always @(posedge clk)
    if (1'b1)
      n4019 <= n4014[n3967];
  /*# work/sms-vhdl/compat/lineartable.vhd:137:39 */
  /*# work/sms-vhdl/compat/lineartable.vhd:137:37 */
endmodule

module outputmemory_Brtl
  (input  clk,
   input  reset,
   input  wr,
   input  [4:0] addr,
   input  \wdata[sign] ,
   input  [8:0] \wdata[value] ,
   output \rdata[sign] ,
   output [8:0] \rdata[value] ,
   input  [4:0] addr2,
   output \rdata2[sign] ,
   output [8:0] \rdata2[value] );
  wire [9:0] n3689;
  wire n3691;
  wire [8:0] n3692;
  wire n3694;
  wire [8:0] n3695;
  (* ramstyle="logic" *) wire [189:0] data_array;
  reg [4:0] n3696_init_ch;
  wire [31:0] n3700;
  wire n3702;
  wire [4:0] n3704;
  wire [31:0] n3708;
  wire [31:0] n3710;
  wire [4:0] n3711;
  wire [4:0] n3714;
  wire n3721;
  wire [8:0] n3722;
  wire [9:0] n3723;
  wire [189:0] n3725;
  wire [189:0] n3726;
  wire [4:0] n3731;
  wire n3738;
  wire [8:0] n3739;
  wire [9:0] n3740;
  wire [4:0] n3744;
  wire n3751;
  wire [8:0] n3752;
  wire [9:0] n3753;
  wire n3764;
  wire [9:0] n3765;
  reg [9:0] n3766;
  wire n3767;
  wire [9:0] n3768;
  reg [9:0] n3769;
  wire n3770;
  wire [189:0] n3771;
  reg [189:0] n3772;
  wire [4:0] n3773;
  reg [4:0] n3774;
  wire n3775;
  wire n3776;
  wire n3777;
  wire n3778;
  wire n3779;
  wire n3780;
  wire n3781;
  wire n3782;
  wire n3783;
  wire n3784;
  wire n3785;
  wire n3786;
  wire n3787;
  wire n3788;
  wire n3789;
  wire n3790;
  wire n3791;
  wire n3792;
  wire n3793;
  wire n3794;
  wire n3795;
  wire n3796;
  wire n3797;
  wire n3798;
  wire n3799;
  wire n3800;
  wire n3801;
  wire n3802;
  wire n3803;
  wire n3804;
  wire n3805;
  wire n3806;
  wire n3807;
  wire n3808;
  wire n3809;
  wire n3810;
  wire n3811;
  wire n3812;
  wire n3813;
  wire n3814;
  wire n3815;
  wire n3816;
  wire n3817;
  wire n3818;
  wire n3819;
  wire n3820;
  wire n3821;
  wire [9:0] n3822;
  wire [9:0] n3823;
  wire [9:0] n3824;
  wire [9:0] n3825;
  wire [9:0] n3826;
  wire [9:0] n3827;
  wire [9:0] n3828;
  wire [9:0] n3829;
  wire [9:0] n3830;
  wire [9:0] n3831;
  wire [9:0] n3832;
  wire [9:0] n3833;
  wire [9:0] n3834;
  wire [9:0] n3835;
  wire [9:0] n3836;
  wire [9:0] n3837;
  wire [9:0] n3838;
  wire [9:0] n3839;
  wire [9:0] n3840;
  wire [9:0] n3841;
  wire [9:0] n3842;
  wire [9:0] n3843;
  wire [9:0] n3844;
  wire [9:0] n3845;
  wire [9:0] n3846;
  wire [9:0] n3847;
  wire [9:0] n3848;
  wire [9:0] n3849;
  wire [9:0] n3850;
  wire [9:0] n3851;
  wire [9:0] n3852;
  wire [9:0] n3853;
  wire [9:0] n3854;
  wire [9:0] n3855;
  wire [9:0] n3856;
  wire [9:0] n3857;
  wire [9:0] n3858;
  wire [9:0] n3859;
  wire [189:0] n3860;
  wire n3861;
  wire n3862;
  wire n3863;
  wire n3864;
  wire n3865;
  wire n3866;
  wire n3867;
  wire n3868;
  wire n3869;
  wire n3870;
  wire n3871;
  wire n3872;
  wire n3873;
  wire n3874;
  wire n3875;
  wire n3876;
  wire n3877;
  wire n3878;
  wire n3879;
  wire n3880;
  wire n3881;
  wire n3882;
  wire n3883;
  wire n3884;
  wire n3885;
  wire n3886;
  wire n3887;
  wire n3888;
  wire n3889;
  wire n3890;
  wire n3891;
  wire n3892;
  wire n3893;
  wire n3894;
  wire n3895;
  wire n3896;
  wire n3897;
  wire n3898;
  wire n3899;
  wire n3900;
  wire n3901;
  wire n3902;
  wire n3903;
  wire n3904;
  wire n3905;
  wire n3906;
  wire n3907;
  wire [9:0] n3908;
  wire [9:0] n3909;
  wire [9:0] n3910;
  wire [9:0] n3911;
  wire [9:0] n3912;
  wire [9:0] n3913;
  wire [9:0] n3914;
  wire [9:0] n3915;
  wire [9:0] n3916;
  wire [9:0] n3917;
  wire [9:0] n3918;
  wire [9:0] n3919;
  wire [9:0] n3920;
  wire [9:0] n3921;
  wire [9:0] n3922;
  wire [9:0] n3923;
  wire [9:0] n3924;
  wire [9:0] n3925;
  wire [9:0] n3926;
  wire [9:0] n3927;
  wire [9:0] n3928;
  wire [9:0] n3929;
  wire [9:0] n3930;
  wire [9:0] n3931;
  wire [9:0] n3932;
  wire [9:0] n3933;
  wire [9:0] n3934;
  wire [9:0] n3935;
  wire [9:0] n3936;
  wire [9:0] n3937;
  wire [9:0] n3938;
  wire [9:0] n3939;
  wire [9:0] n3940;
  wire [9:0] n3941;
  wire [9:0] n3942;
  wire [9:0] n3943;
  wire [9:0] n3944;
  wire [9:0] n3945;
  wire [189:0] n3946;
  wire [319:0] n3948;
  wire [9:0] n3949;
  wire [319:0] n3951;
  wire [9:0] n3952;
  assign \rdata[sign]  = n3691; //(module output)
  assign \rdata[value]  = n3692; //(module output)
  assign \rdata2[sign]  = n3694; //(module output)
  assign \rdata2[value]  = n3695; //(module output)
  /*# work/sms-vhdl/compat/outputmemory.vhd:36:8 */
  assign n3689 = {\wdata[value] , \wdata[sign] };
  /*# work/sms-vhdl/compat/outputmemory.vhd:36:8 */
  assign n3691 = n3766[0]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:36:8 */
  assign n3692 = n3766[9:1]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:36:8 */
  assign n3694 = n3769[0]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:36:8 */
  assign n3695 = n3769[9:1]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:51:10 */
  assign data_array = n3772; // (signal)
  /*# work/sms-vhdl/compat/outputmemory.vhd:59:14 */
  always @*
    n3696_init_ch = n3774; // (isignal)
  initial
    n3696_init_ch = 5'b00000;
  /*# work/sms-vhdl/compat/outputmemory.vhd:69:18 */
  assign n3700 = {27'b0, n3696_init_ch};  // uext
  /*# work/sms-vhdl/compat/outputmemory.vhd:69:18 */
  assign n3702 = n3700 != 32'b00000000000000000000000000010010;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:20 */
  assign n3704 = 5'b10010 - n3696_init_ch;
  /*# work/sms-vhdl/compat/outputmemory.vhd:72:28 */
  assign n3708 = {27'b0, n3696_init_ch};  // uext
  /*# work/sms-vhdl/compat/outputmemory.vhd:72:28 */
  assign n3710 = n3708 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/outputmemory.vhd:72:9 */
  assign n3711 = n3710[4:0];  // trunc
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:20 */
  assign n3714 = 5'b10010 - addr;
  /*# work/sms-vhdl/compat/vm2413.vhd:186:15 */
  assign n3721 = n3689[0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:186:25 */
  assign n3722 = n3689[9:1]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:186:20 */
  assign n3723 = {n3721, n3722};
  /*# work/sms-vhdl/compat/outputmemory.vhd:74:7 */
  assign n3725 = wr ? n3946 : data_array;
  /*# work/sms-vhdl/compat/outputmemory.vhd:69:7 */
  assign n3726 = n3702 ? n3860 : n3725;
  /*# work/sms-vhdl/compat/outputmemory.vhd:80:42 */
  assign n3731 = 5'b10010 - addr;
  /*# work/sms-vhdl/compat/vm2413.vhd:191:25 */
  assign n3738 = n3949[9]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:191:47 */
  assign n3739 = n3949[8:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:191:12 */
  assign n3740 = {n3739, n3738};
  /*# work/sms-vhdl/compat/outputmemory.vhd:81:43 */
  assign n3744 = 5'b10010 - addr2;
  /*# work/sms-vhdl/compat/vm2413.vhd:191:25 */
  assign n3751 = n3952[9]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:191:47 */
  assign n3752 = n3952[8:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:191:12 */
  assign n3753 = {n3752, n3751};
  /*# work/sms-vhdl/compat/outputmemory.vhd:42:3 */
  assign n3764 = ~reset;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  assign n3765 = n3764 ? n3740 : n3766;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  always @(posedge clk)
    n3766 <= n3765;
  /*# work/sms-vhdl/compat/outputmemory.vhd:44:3 */
  assign n3767 = ~reset;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  assign n3768 = n3767 ? n3753 : n3769;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  always @(posedge clk)
    n3769 <= n3768;
  /*# work/sms-vhdl/compat/outputmemory.vhd:51:10 */
  assign n3770 = ~reset;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  assign n3771 = n3770 ? n3726 : data_array;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  always @(posedge clk)
    n3772 <= n3771;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  assign n3773 = n3702 ? n3711 : n3696_init_ch;
  /*# work/sms-vhdl/compat/outputmemory.vhd:67:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3774 <= 5'b00000;
    else
      n3774 <= n3773;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3775 = n3704[4]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3776 = ~n3775;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3777 = n3704[3]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3778 = ~n3777;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3779 = n3776 & n3778;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3780 = n3776 & n3777;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3781 = n3775 & n3778;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3782 = n3704[2]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3783 = ~n3782;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3784 = n3779 & n3783;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3785 = n3779 & n3782;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3786 = n3780 & n3783;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3787 = n3780 & n3782;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3788 = n3781 & n3783;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3789 = n3704[1]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3790 = ~n3789;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3791 = n3784 & n3790;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3792 = n3784 & n3789;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3793 = n3785 & n3790;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3794 = n3785 & n3789;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3795 = n3786 & n3790;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3796 = n3786 & n3789;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3797 = n3787 & n3790;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3798 = n3787 & n3789;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3799 = n3788 & n3790;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3800 = n3788 & n3789;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3801 = n3704[0]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3802 = ~n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3803 = n3791 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3804 = n3791 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3805 = n3792 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3806 = n3792 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3807 = n3793 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3808 = n3793 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3809 = n3794 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3810 = n3794 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3811 = n3795 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3812 = n3795 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3813 = n3796 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3814 = n3796 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3815 = n3797 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3816 = n3797 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3817 = n3798 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3818 = n3798 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3819 = n3799 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3820 = n3799 & n3801;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3821 = n3800 & n3802;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3822 = data_array[9:0]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3823 = n3803 ? 10'b0000000000 : n3822;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3824 = data_array[19:10]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3825 = n3804 ? 10'b0000000000 : n3824;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3826 = data_array[29:20]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3827 = n3805 ? 10'b0000000000 : n3826;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3828 = data_array[39:30]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3829 = n3806 ? 10'b0000000000 : n3828;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3830 = data_array[49:40]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3831 = n3807 ? 10'b0000000000 : n3830;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3832 = data_array[59:50]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3833 = n3808 ? 10'b0000000000 : n3832;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3834 = data_array[69:60]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3835 = n3809 ? 10'b0000000000 : n3834;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3836 = data_array[79:70]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3837 = n3810 ? 10'b0000000000 : n3836;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3838 = data_array[89:80]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3839 = n3811 ? 10'b0000000000 : n3838;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3840 = data_array[99:90]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3841 = n3812 ? 10'b0000000000 : n3840;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3842 = data_array[109:100]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3843 = n3813 ? 10'b0000000000 : n3842;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3844 = data_array[119:110]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3845 = n3814 ? 10'b0000000000 : n3844;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3846 = data_array[129:120]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3847 = n3815 ? 10'b0000000000 : n3846;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3848 = data_array[139:130]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3849 = n3816 ? 10'b0000000000 : n3848;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3850 = data_array[149:140]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3851 = n3817 ? 10'b0000000000 : n3850;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3852 = data_array[159:150]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3853 = n3818 ? 10'b0000000000 : n3852;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3854 = data_array[169:160]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3855 = n3819 ? 10'b0000000000 : n3854;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3856 = data_array[179:170]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3857 = n3820 ? 10'b0000000000 : n3856;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3858 = data_array[189:180]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3859 = n3821 ? 10'b0000000000 : n3858;
  /*# work/sms-vhdl/compat/outputmemory.vhd:71:9 */
  assign n3860 = {n3859, n3857, n3855, n3853, n3851, n3849, n3847, n3845, n3843, n3841, n3839, n3837, n3835, n3833, n3831, n3829, n3827, n3825, n3823};
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3861 = n3714[4]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3862 = ~n3861;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3863 = n3714[3]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3864 = ~n3863;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3865 = n3862 & n3864;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3866 = n3862 & n3863;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3867 = n3861 & n3864;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3868 = n3714[2]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3869 = ~n3868;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3870 = n3865 & n3869;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3871 = n3865 & n3868;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3872 = n3866 & n3869;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3873 = n3866 & n3868;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3874 = n3867 & n3869;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3875 = n3714[1]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3876 = ~n3875;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3877 = n3870 & n3876;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3878 = n3870 & n3875;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3879 = n3871 & n3876;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3880 = n3871 & n3875;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3881 = n3872 & n3876;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3882 = n3872 & n3875;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3883 = n3873 & n3876;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3884 = n3873 & n3875;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3885 = n3874 & n3876;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3886 = n3874 & n3875;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3887 = n3714[0]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3888 = ~n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3889 = n3877 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3890 = n3877 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3891 = n3878 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3892 = n3878 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3893 = n3879 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3894 = n3879 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3895 = n3880 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3896 = n3880 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3897 = n3881 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3898 = n3881 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3899 = n3882 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3900 = n3882 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3901 = n3883 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3902 = n3883 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3903 = n3884 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3904 = n3884 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3905 = n3885 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3906 = n3885 & n3887;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3907 = n3886 & n3888;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3908 = data_array[9:0]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3909 = n3889 ? n3723 : n3908;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3910 = data_array[19:10]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3911 = n3890 ? n3723 : n3910;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3912 = data_array[29:20]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3913 = n3891 ? n3723 : n3912;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3914 = data_array[39:30]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3915 = n3892 ? n3723 : n3914;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3916 = data_array[49:40]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3917 = n3893 ? n3723 : n3916;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3918 = data_array[59:50]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3919 = n3894 ? n3723 : n3918;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3920 = data_array[69:60]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3921 = n3895 ? n3723 : n3920;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3922 = data_array[79:70]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3923 = n3896 ? n3723 : n3922;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3924 = data_array[89:80]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3925 = n3897 ? n3723 : n3924;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3926 = data_array[99:90]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3927 = n3898 ? n3723 : n3926;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3928 = data_array[109:100]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3929 = n3899 ? n3723 : n3928;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3930 = data_array[119:110]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3931 = n3900 ? n3723 : n3930;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3932 = data_array[129:120]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3933 = n3901 ? n3723 : n3932;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3934 = data_array[139:130]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3935 = n3902 ? n3723 : n3934;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3936 = data_array[149:140]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3937 = n3903 ? n3723 : n3936;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3938 = data_array[159:150]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3939 = n3904 ? n3723 : n3938;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3940 = data_array[169:160]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3941 = n3905 ? n3723 : n3940;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3942 = data_array[179:170]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3943 = n3906 ? n3723 : n3942;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3944 = data_array[189:180]; // extract
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3945 = n3907 ? n3723 : n3944;
  /*# work/sms-vhdl/compat/outputmemory.vhd:76:9 */
  assign n3946 = {n3945, n3943, n3941, n3939, n3937, n3935, n3933, n3931, n3929, n3927, n3925, n3923, n3921, n3919, n3917, n3915, n3913, n3911, n3909};
  /*# work/sms-vhdl/compat/outputmemory.vhd:80:42 */
  assign n3948 = {130'bX, data_array};
  /*# work/sms-vhdl/compat/outputmemory.vhd:80:42 */
  assign n3949 = n3948[n3731 * 10 +: 10]; //(Bmux)
  /*# work/sms-vhdl/compat/outputmemory.vhd:81:43 */
  assign n3951 = {130'bX, data_array};
  /*# work/sms-vhdl/compat/outputmemory.vhd:81:43 */
  assign n3952 = n3951[n3744 * 10 +: 10]; //(Bmux)
endmodule

module feedbackmemory_Brtl
  (input  clk,
   input  reset,
   input  wr,
   input  [3:0] waddr,
   input  \wdata[sign] ,
   input  [8:0] \wdata[value] ,
   input  [3:0] raddr,
   output \rdata[sign] ,
   output [8:0] \rdata[value] );
  wire [9:0] n3535;
  wire n3537;
  wire [8:0] n3538;
  (* ramstyle="logic" *) wire [89:0] data_array;
  reg [3:0] n3539_init_ch;
  wire [31:0] n3543;
  wire n3545;
  wire [3:0] n3547;
  wire [31:0] n3551;
  wire [31:0] n3553;
  wire [3:0] n3554;
  wire [3:0] n3556;
  wire n3563;
  wire [8:0] n3564;
  wire [9:0] n3565;
  wire [89:0] n3567;
  wire [89:0] n3568;
  wire [3:0] n3572;
  wire n3579;
  wire [8:0] n3580;
  wire [9:0] n3581;
  wire n3590;
  wire [9:0] n3591;
  reg [9:0] n3592;
  wire n3593;
  wire [89:0] n3594;
  reg [89:0] n3595;
  wire [3:0] n3596;
  reg [3:0] n3597;
  wire n3598;
  wire n3599;
  wire n3600;
  wire n3601;
  wire n3602;
  wire n3603;
  wire n3604;
  wire n3605;
  wire n3606;
  wire n3607;
  wire n3608;
  wire n3609;
  wire n3610;
  wire n3611;
  wire n3612;
  wire n3613;
  wire n3614;
  wire n3615;
  wire n3616;
  wire n3617;
  wire n3618;
  wire n3619;
  wire n3620;
  wire n3621;
  wire n3622;
  wire [9:0] n3623;
  wire [9:0] n3624;
  wire [9:0] n3625;
  wire [9:0] n3626;
  wire [9:0] n3627;
  wire [9:0] n3628;
  wire [9:0] n3629;
  wire [9:0] n3630;
  wire [9:0] n3631;
  wire [9:0] n3632;
  wire [9:0] n3633;
  wire [9:0] n3634;
  wire [9:0] n3635;
  wire [9:0] n3636;
  wire [9:0] n3637;
  wire [9:0] n3638;
  wire [9:0] n3639;
  wire [9:0] n3640;
  wire [89:0] n3641;
  wire n3642;
  wire n3643;
  wire n3644;
  wire n3645;
  wire n3646;
  wire n3647;
  wire n3648;
  wire n3649;
  wire n3650;
  wire n3651;
  wire n3652;
  wire n3653;
  wire n3654;
  wire n3655;
  wire n3656;
  wire n3657;
  wire n3658;
  wire n3659;
  wire n3660;
  wire n3661;
  wire n3662;
  wire n3663;
  wire n3664;
  wire n3665;
  wire n3666;
  wire [9:0] n3667;
  wire [9:0] n3668;
  wire [9:0] n3669;
  wire [9:0] n3670;
  wire [9:0] n3671;
  wire [9:0] n3672;
  wire [9:0] n3673;
  wire [9:0] n3674;
  wire [9:0] n3675;
  wire [9:0] n3676;
  wire [9:0] n3677;
  wire [9:0] n3678;
  wire [9:0] n3679;
  wire [9:0] n3680;
  wire [9:0] n3681;
  wire [9:0] n3682;
  wire [9:0] n3683;
  wire [9:0] n3684;
  wire [89:0] n3685;
  wire [159:0] n3687;
  wire [9:0] n3688;
  assign \rdata[sign]  = n3537; //(module output)
  assign \rdata[value]  = n3538; //(module output)
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:41:8 */
  assign n3535 = {\wdata[value] , \wdata[sign] };
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:41:8 */
  assign n3537 = n3592[0]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:41:8 */
  assign n3538 = n3592[9:1]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:55:10 */
  assign data_array = n3595; // (signal)
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:63:14 */
  always @*
    n3539_init_ch = n3597; // (isignal)
  initial
    n3539_init_ch = 4'b0000;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:73:18 */
  assign n3543 = {28'b0, n3539_init_ch};  // uext
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:73:18 */
  assign n3545 = n3543 != 32'b00000000000000000000000000001001;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:20 */
  assign n3547 = 4'b1000 - n3539_init_ch;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:76:28 */
  assign n3551 = {28'b0, n3539_init_ch};  // uext
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:76:28 */
  assign n3553 = n3551 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:76:9 */
  assign n3554 = n3553[3:0];  // trunc
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:20 */
  assign n3556 = 4'b1000 - waddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:186:15 */
  assign n3563 = n3535[0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:186:25 */
  assign n3564 = n3535[9:1]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:186:20 */
  assign n3565 = {n3563, n3564};
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:78:7 */
  assign n3567 = wr ? n3685 : data_array;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:73:7 */
  assign n3568 = n3545 ? n3641 : n3567;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:84:42 */
  assign n3572 = 4'b1000 - raddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:191:25 */
  assign n3579 = n3688[9]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:191:47 */
  assign n3580 = n3688[8:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:191:12 */
  assign n3581 = {n3580, n3579};
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:48:3 */
  assign n3590 = ~reset;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:71:5 */
  assign n3591 = n3590 ? n3581 : n3592;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:71:5 */
  always @(posedge clk)
    n3592 <= n3591;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:55:10 */
  assign n3593 = ~reset;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:71:5 */
  assign n3594 = n3593 ? n3568 : data_array;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:71:5 */
  always @(posedge clk)
    n3595 <= n3594;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:71:5 */
  assign n3596 = n3545 ? n3554 : n3539_init_ch;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:71:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3597 <= 4'b0000;
    else
      n3597 <= n3596;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3598 = n3547[3]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3599 = ~n3598;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3600 = n3547[2]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3601 = ~n3600;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3602 = n3599 & n3601;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3603 = n3599 & n3600;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3604 = n3598 & n3601;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3605 = n3547[1]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3606 = ~n3605;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3607 = n3602 & n3606;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3608 = n3602 & n3605;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3609 = n3603 & n3606;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3610 = n3603 & n3605;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3611 = n3604 & n3606;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3612 = n3547[0]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3613 = ~n3612;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3614 = n3607 & n3613;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3615 = n3607 & n3612;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3616 = n3608 & n3613;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3617 = n3608 & n3612;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3618 = n3609 & n3613;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3619 = n3609 & n3612;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3620 = n3610 & n3613;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3621 = n3610 & n3612;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3622 = n3611 & n3613;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3623 = data_array[9:0]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3624 = n3614 ? 10'b0000000000 : n3623;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3625 = data_array[19:10]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3626 = n3615 ? 10'b0000000000 : n3625;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3627 = data_array[29:20]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3628 = n3616 ? 10'b0000000000 : n3627;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3629 = data_array[39:30]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3630 = n3617 ? 10'b0000000000 : n3629;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3631 = data_array[49:40]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3632 = n3618 ? 10'b0000000000 : n3631;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3633 = data_array[59:50]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3634 = n3619 ? 10'b0000000000 : n3633;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3635 = data_array[69:60]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3636 = n3620 ? 10'b0000000000 : n3635;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3637 = data_array[79:70]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3638 = n3621 ? 10'b0000000000 : n3637;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3639 = data_array[89:80]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3640 = n3622 ? 10'b0000000000 : n3639;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:75:9 */
  assign n3641 = {n3640, n3638, n3636, n3634, n3632, n3630, n3628, n3626, n3624};
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3642 = n3556[3]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3643 = ~n3642;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3644 = n3556[2]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3645 = ~n3644;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3646 = n3643 & n3645;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3647 = n3643 & n3644;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3648 = n3642 & n3645;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3649 = n3556[1]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3650 = ~n3649;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3651 = n3646 & n3650;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3652 = n3646 & n3649;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3653 = n3647 & n3650;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3654 = n3647 & n3649;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3655 = n3648 & n3650;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3656 = n3556[0]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3657 = ~n3656;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3658 = n3651 & n3657;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3659 = n3651 & n3656;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3660 = n3652 & n3657;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3661 = n3652 & n3656;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3662 = n3653 & n3657;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3663 = n3653 & n3656;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3664 = n3654 & n3657;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3665 = n3654 & n3656;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3666 = n3655 & n3657;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3667 = data_array[9:0]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3668 = n3658 ? n3565 : n3667;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3669 = data_array[19:10]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3670 = n3659 ? n3565 : n3669;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3671 = data_array[29:20]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3672 = n3660 ? n3565 : n3671;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3673 = data_array[39:30]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3674 = n3661 ? n3565 : n3673;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3675 = data_array[49:40]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3676 = n3662 ? n3565 : n3675;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3677 = data_array[59:50]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3678 = n3663 ? n3565 : n3677;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3679 = data_array[69:60]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3680 = n3664 ? n3565 : n3679;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3681 = data_array[79:70]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3682 = n3665 ? n3565 : n3681;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3683 = data_array[89:80]; // extract
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3684 = n3666 ? n3565 : n3683;
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:80:9 */
  assign n3685 = {n3684, n3682, n3680, n3678, n3676, n3674, n3672, n3670, n3668};
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:84:42 */
  assign n3687 = {70'bX, data_array};
  /*# work/sms-vhdl/compat/feedbackmemory.vhd:84:42 */
  assign n3688 = n3687[n3572 * 10 +: 10]; //(Bmux)
endmodule

module sinetable_Brtl
  (input  clk,
   input  clkena,
   input  wf,
   input  [17:0] addr,
   output [13:0] data);
  wire [10:0] ff_data0;
  wire [10:0] ff_data1;
  wire [13:0] w_wf;
  wire [6:0] w_xor;
  wire [6:0] w_addr0;
  wire [6:0] w_addr1;
  wire [6:0] w_xaddr;
  wire ff_sign;
  wire ff_wf;
  wire [8:0] ff_weight;
  wire [11:0] w_sub;
  wire [13:0] w_mul;
  wire [13:0] w_inter;
  wire [13:0] ff_data;
  wire n3444;
  wire n3445;
  wire n3446;
  wire n3447;
  wire n3448;
  wire n3449;
  wire n3450;
  wire [6:0] n3451;
  wire [6:0] n3452;
  wire [6:0] n3453;
  wire [6:0] n3455;
  wire [6:0] n3456;
  wire n3458;
  wire [6:0] n3459;
  wire [6:0] n3460;
  wire [6:0] n3462;
  wire [6:0] n3463;
  wire n3486;
  wire n3487;
  wire n3488;
  wire [8:0] n3489;
  wire [11:0] n3498;
  wire [11:0] n3500;
  wire [11:0] n3501;
  wire [13:0] u_interpolate_mul_n3502;
  wire [12:0] n3506;
  wire [13:0] n3507;
  wire [13:0] n3508;
  wire [13:0] n3509;
  wire [12:0] n3513;
  wire [13:0] n3514;
  wire [13:0] n3515;
  wire n3523;
  reg n3524;
  wire n3525;
  reg n3526;
  wire [8:0] n3527;
  reg [8:0] n3528;
  wire [13:0] n3529;
  reg [13:0] n3530;
  reg [10:0] n3533; // mem_rd
  reg [10:0] n3534; // mem_rd
  assign data = ff_data; //(module output)
  /*# work/sms-vhdl/compat/sinetable.vhd:119:12 */
  assign ff_data0 = n3534; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:120:12 */
  assign ff_data1 = n3533; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:121:12 */
  assign w_wf = n3509; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:122:12 */
  assign w_xor = n3451; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:123:12 */
  assign w_addr0 = w_xaddr; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:124:12 */
  assign w_addr1 = n3459; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:125:12 */
  assign w_xaddr = n3453; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:126:12 */
  assign ff_sign = n3524; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:127:12 */
  assign ff_wf = n3526; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:128:12 */
  assign ff_weight = n3528; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:129:12 */
  assign w_sub = n3501; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:130:12 */
  assign w_mul = u_interpolate_mul_n3502; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:131:12 */
  assign w_inter = n3508; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:132:12 */
  assign ff_data = n3530; // (signal)
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3444 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3445 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3446 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3447 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3448 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3449 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:31 */
  assign n3450 = addr[16]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:135:16 */
  assign n3451 = {n3444, n3445, n3446, n3447, n3448, n3449, n3450};
  /*# work/sms-vhdl/compat/sinetable.vhd:136:20 */
  assign n3452 = addr[15:9]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:136:36 */
  assign n3453 = n3452 ^ w_xor;
  /*# work/sms-vhdl/compat/sinetable.vhd:138:26 */
  assign n3455 = 7'b1111111 ^ w_xor;
  /*# work/sms-vhdl/compat/sinetable.vhd:138:45 */
  assign n3456 = addr[15:9]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:138:61 */
  assign n3458 = n3456 == 7'b1111111;
  /*# work/sms-vhdl/compat/sinetable.vhd:138:36 */
  assign n3459 = n3458 ? n3455 : n3463;
  /*# work/sms-vhdl/compat/sinetable.vhd:139:21 */
  assign n3460 = addr[15:9]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:139:37 */
  assign n3462 = n3460 + 7'b0000001;
  /*# work/sms-vhdl/compat/sinetable.vhd:139:42 */
  assign n3463 = n3462 ^ w_xor;
  /*# work/sms-vhdl/compat/sinetable.vhd:157:36 */
  assign n3486 = addr[17]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:158:43 */
  assign n3487 = addr[17]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:158:35 */
  assign n3488 = wf & n3487;
  /*# work/sms-vhdl/compat/sinetable.vhd:159:36 */
  assign n3489 = addr[8:0]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:166:21 */
  assign n3498 = {1'b0, ff_data1};
  /*# work/sms-vhdl/compat/sinetable.vhd:166:40 */
  assign n3500 = {1'b0, ff_data0};
  /*# work/sms-vhdl/compat/sinetable.vhd:166:33 */
  assign n3501 = n3498 - n3500;
  /*# work/sms-vhdl/compat/sinetable.vhd:168:5 */
  interpolate_mul_Brtl u_interpolate_mul (
    .i0(ff_weight),
    .i1(w_sub),
    .o(u_interpolate_mul_n3502));
  /*# work/sms-vhdl/compat/sinetable.vhd:176:26 */
  assign n3506 = {ff_data0, 2'b00};
  /*# work/sms-vhdl/compat/sinetable.vhd:176:34 */
  assign n3507 = {1'b0, n3506};  // uext
  /*# work/sms-vhdl/compat/sinetable.vhd:176:34 */
  assign n3508 = n3507 + w_mul;
  /*# work/sms-vhdl/compat/sinetable.vhd:177:16 */
  assign n3509 = {ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf, ff_wf};
  /*# work/sms-vhdl/compat/sinetable.vhd:184:46 */
  assign n3513 = w_inter[12:0]; // extract
  /*# work/sms-vhdl/compat/sinetable.vhd:184:37 */
  assign n3514 = {ff_sign, n3513};
  /*# work/sms-vhdl/compat/sinetable.vhd:184:61 */
  assign n3515 = n3514 | w_wf;
  /*# work/sms-vhdl/compat/sinetable.vhd:155:9 */
  assign n3523 = clkena ? n3486 : ff_sign;
  /*# work/sms-vhdl/compat/sinetable.vhd:155:9 */
  always @(posedge clk)
    n3524 <= n3523;
  /*# work/sms-vhdl/compat/sinetable.vhd:155:9 */
  assign n3525 = clkena ? n3488 : ff_wf;
  /*# work/sms-vhdl/compat/sinetable.vhd:155:9 */
  always @(posedge clk)
    n3526 <= n3525;
  /*# work/sms-vhdl/compat/sinetable.vhd:155:9 */
  assign n3527 = clkena ? n3489 : ff_weight;
  /*# work/sms-vhdl/compat/sinetable.vhd:155:9 */
  always @(posedge clk)
    n3528 <= n3527;
  /*# work/sms-vhdl/compat/sinetable.vhd:181:9 */
  assign n3529 = clkena ? n3515 : ff_data;
  /*# work/sms-vhdl/compat/sinetable.vhd:181:9 */
  always @(posedge clk)
    n3530 <= n3529;
  /*# work/sms-vhdl/compat/sinetable.vhd:146:39 */
  reg [10:0] n3531[127:0] ; // memory
  initial begin
    n3531[127] = 11'b00000000000;
    n3531[126] = 11'b00000000000;
    n3531[125] = 11'b00000000000;
    n3531[124] = 11'b00000000000;
    n3531[123] = 11'b00000000000;
    n3531[122] = 11'b00000000000;
    n3531[121] = 11'b00000000001;
    n3531[120] = 11'b00000000001;
    n3531[119] = 11'b00000000010;
    n3531[118] = 11'b00000000010;
    n3531[117] = 11'b00000000011;
    n3531[116] = 11'b00000000011;
    n3531[115] = 11'b00000000100;
    n3531[114] = 11'b00000000101;
    n3531[113] = 11'b00000000110;
    n3531[112] = 11'b00000000111;
    n3531[111] = 11'b00000001000;
    n3531[110] = 11'b00000001001;
    n3531[109] = 11'b00000001010;
    n3531[108] = 11'b00000001011;
    n3531[107] = 11'b00000001100;
    n3531[106] = 11'b00000001101;
    n3531[105] = 11'b00000001110;
    n3531[104] = 11'b00000010000;
    n3531[103] = 11'b00000010001;
    n3531[102] = 11'b00000010011;
    n3531[101] = 11'b00000010100;
    n3531[100] = 11'b00000010110;
    n3531[99] = 11'b00000010111;
    n3531[98] = 11'b00000011001;
    n3531[97] = 11'b00000011011;
    n3531[96] = 11'b00000011101;
    n3531[95] = 11'b00000011110;
    n3531[94] = 11'b00000100000;
    n3531[93] = 11'b00000100010;
    n3531[92] = 11'b00000100101;
    n3531[91] = 11'b00000100111;
    n3531[90] = 11'b00000101001;
    n3531[89] = 11'b00000101011;
    n3531[88] = 11'b00000101110;
    n3531[87] = 11'b00000110000;
    n3531[86] = 11'b00000110011;
    n3531[85] = 11'b00000110101;
    n3531[84] = 11'b00000111000;
    n3531[83] = 11'b00000111011;
    n3531[82] = 11'b00000111101;
    n3531[81] = 11'b00001000000;
    n3531[80] = 11'b00001000011;
    n3531[79] = 11'b00001000110;
    n3531[78] = 11'b00001001001;
    n3531[77] = 11'b00001001101;
    n3531[76] = 11'b00001010000;
    n3531[75] = 11'b00001010011;
    n3531[74] = 11'b00001010111;
    n3531[73] = 11'b00001011010;
    n3531[72] = 11'b00001011110;
    n3531[71] = 11'b00001100010;
    n3531[70] = 11'b00001100110;
    n3531[69] = 11'b00001101010;
    n3531[68] = 11'b00001101110;
    n3531[67] = 11'b00001110010;
    n3531[66] = 11'b00001110110;
    n3531[65] = 11'b00001111010;
    n3531[64] = 11'b00001111111;
    n3531[63] = 11'b00010000011;
    n3531[62] = 11'b00010001000;
    n3531[61] = 11'b00010001101;
    n3531[60] = 11'b00010010010;
    n3531[59] = 11'b00010010111;
    n3531[58] = 11'b00010011100;
    n3531[57] = 11'b00010100001;
    n3531[56] = 11'b00010100111;
    n3531[55] = 11'b00010101100;
    n3531[54] = 11'b00010110010;
    n3531[53] = 11'b00010111000;
    n3531[52] = 11'b00010111110;
    n3531[51] = 11'b00011000100;
    n3531[50] = 11'b00011001010;
    n3531[49] = 11'b00011010001;
    n3531[48] = 11'b00011010111;
    n3531[47] = 11'b00011011110;
    n3531[46] = 11'b00011100101;
    n3531[45] = 11'b00011101100;
    n3531[44] = 11'b00011110100;
    n3531[43] = 11'b00011111011;
    n3531[42] = 11'b00100000011;
    n3531[41] = 11'b00100001011;
    n3531[40] = 11'b00100010100;
    n3531[39] = 11'b00100011100;
    n3531[38] = 11'b00100100101;
    n3531[37] = 11'b00100101110;
    n3531[36] = 11'b00100111000;
    n3531[35] = 11'b00101000001;
    n3531[34] = 11'b00101001011;
    n3531[33] = 11'b00101010110;
    n3531[32] = 11'b00101100000;
    n3531[31] = 11'b00101101011;
    n3531[30] = 11'b00101110111;
    n3531[29] = 11'b00110000011;
    n3531[28] = 11'b00110001111;
    n3531[27] = 11'b00110011100;
    n3531[26] = 11'b00110101001;
    n3531[25] = 11'b00110110111;
    n3531[24] = 11'b00111000110;
    n3531[23] = 11'b00111010101;
    n3531[22] = 11'b00111100101;
    n3531[21] = 11'b00111110110;
    n3531[20] = 11'b01000000111;
    n3531[19] = 11'b01000011010;
    n3531[18] = 11'b01000101101;
    n3531[17] = 11'b01001000010;
    n3531[16] = 11'b01001011000;
    n3531[15] = 11'b01001101111;
    n3531[14] = 11'b01010001000;
    n3531[13] = 11'b01010100011;
    n3531[12] = 11'b01011000000;
    n3531[11] = 11'b01011100000;
    n3531[10] = 11'b01100000011;
    n3531[9] = 11'b01100101001;
    n3531[8] = 11'b01101010101;
    n3531[7] = 11'b01110000101;
    n3531[6] = 11'b01110111110;
    n3531[5] = 11'b10000000001;
    n3531[4] = 11'b10001010011;
    n3531[3] = 11'b10010111100;
    n3531[2] = 11'b10101010001;
    n3531[1] = 11'b11001010000;
    n3531[0] = 11'b11111111111;
    end
  always @(posedge clk)
    if (clkena)
      n3533 <= n3531[w_addr1];
  always @(posedge clk)
    if (clkena)
      n3534 <= n3531[w_addr0];
  /*# work/sms-vhdl/compat/sinetable.vhd:144:9 */
  /*# work/sms-vhdl/compat/sinetable.vhd:144:9 */
endmodule

module phasememory_Brtl
  (input  clk,
   input  reset,
   input  [4:0] slot,
   input  memwr,
   output [17:0] memout,
   input  [17:0] memin);
  (* ramstyle="logic" *) wire [323:0] phase_array;
  reg [4:0] n3231_init_slot;
  wire [31:0] n3235;
  wire n3237;
  wire [4:0] n3239;
  wire [31:0] n3243;
  wire [31:0] n3245;
  wire [4:0] n3246;
  wire [4:0] n3249;
  wire [323:0] n3252;
  wire [323:0] n3253;
  wire [4:0] n3257;
  wire n3268;
  wire [17:0] n3269;
  reg [17:0] n3270;
  wire n3271;
  wire [323:0] n3272;
  reg [323:0] n3273;
  wire [4:0] n3274;
  reg [4:0] n3275;
  wire n3276;
  wire n3277;
  wire n3278;
  wire n3279;
  wire n3280;
  wire n3281;
  wire n3282;
  wire n3283;
  wire n3284;
  wire n3285;
  wire n3286;
  wire n3287;
  wire n3288;
  wire n3289;
  wire n3290;
  wire n3291;
  wire n3292;
  wire n3293;
  wire n3294;
  wire n3295;
  wire n3296;
  wire n3297;
  wire n3298;
  wire n3299;
  wire n3300;
  wire n3301;
  wire n3302;
  wire n3303;
  wire n3304;
  wire n3305;
  wire n3306;
  wire n3307;
  wire n3308;
  wire n3309;
  wire n3310;
  wire n3311;
  wire n3312;
  wire n3313;
  wire n3314;
  wire n3315;
  wire n3316;
  wire n3317;
  wire n3318;
  wire n3319;
  wire n3320;
  wire [17:0] n3321;
  wire [17:0] n3322;
  wire [17:0] n3323;
  wire [17:0] n3324;
  wire [17:0] n3325;
  wire [17:0] n3326;
  wire [17:0] n3327;
  wire [17:0] n3328;
  wire [17:0] n3329;
  wire [17:0] n3330;
  wire [17:0] n3331;
  wire [17:0] n3332;
  wire [17:0] n3333;
  wire [17:0] n3334;
  wire [17:0] n3335;
  wire [17:0] n3336;
  wire [17:0] n3337;
  wire [17:0] n3338;
  wire [17:0] n3339;
  wire [17:0] n3340;
  wire [17:0] n3341;
  wire [17:0] n3342;
  wire [17:0] n3343;
  wire [17:0] n3344;
  wire [17:0] n3345;
  wire [17:0] n3346;
  wire [17:0] n3347;
  wire [17:0] n3348;
  wire [17:0] n3349;
  wire [17:0] n3350;
  wire [17:0] n3351;
  wire [17:0] n3352;
  wire [17:0] n3353;
  wire [17:0] n3354;
  wire [17:0] n3355;
  wire [17:0] n3356;
  wire [323:0] n3357;
  wire n3358;
  wire n3359;
  wire n3360;
  wire n3361;
  wire n3362;
  wire n3363;
  wire n3364;
  wire n3365;
  wire n3366;
  wire n3367;
  wire n3368;
  wire n3369;
  wire n3370;
  wire n3371;
  wire n3372;
  wire n3373;
  wire n3374;
  wire n3375;
  wire n3376;
  wire n3377;
  wire n3378;
  wire n3379;
  wire n3380;
  wire n3381;
  wire n3382;
  wire n3383;
  wire n3384;
  wire n3385;
  wire n3386;
  wire n3387;
  wire n3388;
  wire n3389;
  wire n3390;
  wire n3391;
  wire n3392;
  wire n3393;
  wire n3394;
  wire n3395;
  wire n3396;
  wire n3397;
  wire n3398;
  wire n3399;
  wire n3400;
  wire n3401;
  wire n3402;
  wire [17:0] n3403;
  wire [17:0] n3404;
  wire [17:0] n3405;
  wire [17:0] n3406;
  wire [17:0] n3407;
  wire [17:0] n3408;
  wire [17:0] n3409;
  wire [17:0] n3410;
  wire [17:0] n3411;
  wire [17:0] n3412;
  wire [17:0] n3413;
  wire [17:0] n3414;
  wire [17:0] n3415;
  wire [17:0] n3416;
  wire [17:0] n3417;
  wire [17:0] n3418;
  wire [17:0] n3419;
  wire [17:0] n3420;
  wire [17:0] n3421;
  wire [17:0] n3422;
  wire [17:0] n3423;
  wire [17:0] n3424;
  wire [17:0] n3425;
  wire [17:0] n3426;
  wire [17:0] n3427;
  wire [17:0] n3428;
  wire [17:0] n3429;
  wire [17:0] n3430;
  wire [17:0] n3431;
  wire [17:0] n3432;
  wire [17:0] n3433;
  wire [17:0] n3434;
  wire [17:0] n3435;
  wire [17:0] n3436;
  wire [17:0] n3437;
  wire [17:0] n3438;
  wire [323:0] n3439;
  wire [575:0] n3441;
  wire [17:0] n3442;
  assign memout = n3270; //(module output)
  /*# work/sms-vhdl/compat/phasememory.vhd:50:10 */
  assign phase_array = n3273; // (signal)
  /*# work/sms-vhdl/compat/phasememory.vhd:58:14 */
  always @*
    n3231_init_slot = n3275; // (isignal)
  initial
    n3231_init_slot = 5'b00000;
  /*# work/sms-vhdl/compat/phasememory.vhd:68:19 */
  assign n3235 = {27'b0, n3231_init_slot};  // uext
  /*# work/sms-vhdl/compat/phasememory.vhd:68:19 */
  assign n3237 = n3235 != 32'b00000000000000000000000000010010;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:20 */
  assign n3239 = 5'b10001 - n3231_init_slot;
  /*# work/sms-vhdl/compat/phasememory.vhd:71:31 */
  assign n3243 = {27'b0, n3231_init_slot};  // uext
  /*# work/sms-vhdl/compat/phasememory.vhd:71:31 */
  assign n3245 = n3243 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/phasememory.vhd:71:8 */
  assign n3246 = n3245[4:0];  // trunc
  /*# work/sms-vhdl/compat/phasememory.vhd:75:22 */
  assign n3249 = 5'b10001 - slot;
  /*# work/sms-vhdl/compat/phasememory.vhd:73:6 */
  assign n3252 = memwr ? n3439 : phase_array;
  /*# work/sms-vhdl/compat/phasememory.vhd:68:6 */
  assign n3253 = n3237 ? n3357 : n3252;
  /*# work/sms-vhdl/compat/phasememory.vhd:79:28 */
  assign n3257 = 5'b10001 - slot;
  /*# work/sms-vhdl/compat/phasememory.vhd:42:5 */
  assign n3268 = ~reset;
  /*# work/sms-vhdl/compat/phasememory.vhd:66:4 */
  assign n3269 = n3268 ? n3442 : n3270;
  /*# work/sms-vhdl/compat/phasememory.vhd:66:4 */
  always @(posedge clk)
    n3270 <= n3269;
  /*# work/sms-vhdl/compat/phasememory.vhd:50:10 */
  assign n3271 = ~reset;
  /*# work/sms-vhdl/compat/phasememory.vhd:66:4 */
  assign n3272 = n3271 ? n3253 : phase_array;
  /*# work/sms-vhdl/compat/phasememory.vhd:66:4 */
  always @(posedge clk)
    n3273 <= n3272;
  /*# work/sms-vhdl/compat/phasememory.vhd:66:4 */
  assign n3274 = n3237 ? n3246 : n3231_init_slot;
  /*# work/sms-vhdl/compat/phasememory.vhd:66:4 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3275 <= 5'b00000;
    else
      n3275 <= n3274;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3276 = n3239[4]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3277 = ~n3276;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3278 = n3239[3]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3279 = ~n3278;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3280 = n3277 & n3279;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3281 = n3277 & n3278;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3282 = n3276 & n3279;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3283 = n3239[2]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3284 = ~n3283;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3285 = n3280 & n3284;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3286 = n3280 & n3283;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3287 = n3281 & n3284;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3288 = n3281 & n3283;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3289 = n3282 & n3284;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3290 = n3239[1]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3291 = ~n3290;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3292 = n3285 & n3291;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3293 = n3285 & n3290;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3294 = n3286 & n3291;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3295 = n3286 & n3290;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3296 = n3287 & n3291;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3297 = n3287 & n3290;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3298 = n3288 & n3291;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3299 = n3288 & n3290;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3300 = n3289 & n3291;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3301 = n3239[0]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3302 = ~n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3303 = n3292 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3304 = n3292 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3305 = n3293 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3306 = n3293 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3307 = n3294 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3308 = n3294 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3309 = n3295 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3310 = n3295 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3311 = n3296 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3312 = n3296 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3313 = n3297 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3314 = n3297 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3315 = n3298 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3316 = n3298 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3317 = n3299 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3318 = n3299 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3319 = n3300 & n3302;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3320 = n3300 & n3301;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3321 = phase_array[17:0]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3322 = n3303 ? 18'b000000000000000000 : n3321;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3323 = phase_array[35:18]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3324 = n3304 ? 18'b000000000000000000 : n3323;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3325 = phase_array[53:36]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3326 = n3305 ? 18'b000000000000000000 : n3325;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3327 = phase_array[71:54]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3328 = n3306 ? 18'b000000000000000000 : n3327;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3329 = phase_array[89:72]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3330 = n3307 ? 18'b000000000000000000 : n3329;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3331 = phase_array[107:90]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3332 = n3308 ? 18'b000000000000000000 : n3331;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3333 = phase_array[125:108]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3334 = n3309 ? 18'b000000000000000000 : n3333;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3335 = phase_array[143:126]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3336 = n3310 ? 18'b000000000000000000 : n3335;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3337 = phase_array[161:144]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3338 = n3311 ? 18'b000000000000000000 : n3337;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3339 = phase_array[179:162]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3340 = n3312 ? 18'b000000000000000000 : n3339;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3341 = phase_array[197:180]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3342 = n3313 ? 18'b000000000000000000 : n3341;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3343 = phase_array[215:198]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3344 = n3314 ? 18'b000000000000000000 : n3343;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3345 = phase_array[233:216]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3346 = n3315 ? 18'b000000000000000000 : n3345;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3347 = phase_array[251:234]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3348 = n3316 ? 18'b000000000000000000 : n3347;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3349 = phase_array[269:252]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3350 = n3317 ? 18'b000000000000000000 : n3349;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3351 = phase_array[287:270]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3352 = n3318 ? 18'b000000000000000000 : n3351;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3353 = phase_array[305:288]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3354 = n3319 ? 18'b000000000000000000 : n3353;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3355 = phase_array[323:306]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3356 = n3320 ? 18'b000000000000000000 : n3355;
  /*# work/sms-vhdl/compat/phasememory.vhd:70:8 */
  assign n3357 = {n3356, n3354, n3352, n3350, n3348, n3346, n3344, n3342, n3340, n3338, n3336, n3334, n3332, n3330, n3328, n3326, n3324, n3322};
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3358 = n3249[4]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3359 = ~n3358;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3360 = n3249[3]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3361 = ~n3360;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3362 = n3359 & n3361;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3363 = n3359 & n3360;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3364 = n3358 & n3361;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3365 = n3249[2]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3366 = ~n3365;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3367 = n3362 & n3366;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3368 = n3362 & n3365;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3369 = n3363 & n3366;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3370 = n3363 & n3365;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3371 = n3364 & n3366;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3372 = n3249[1]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3373 = ~n3372;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3374 = n3367 & n3373;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3375 = n3367 & n3372;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3376 = n3368 & n3373;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3377 = n3368 & n3372;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3378 = n3369 & n3373;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3379 = n3369 & n3372;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3380 = n3370 & n3373;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3381 = n3370 & n3372;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3382 = n3371 & n3373;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3383 = n3249[0]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3384 = ~n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3385 = n3374 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3386 = n3374 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3387 = n3375 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3388 = n3375 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3389 = n3376 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3390 = n3376 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3391 = n3377 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3392 = n3377 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3393 = n3378 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3394 = n3378 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3395 = n3379 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3396 = n3379 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3397 = n3380 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3398 = n3380 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3399 = n3381 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3400 = n3381 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3401 = n3382 & n3384;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3402 = n3382 & n3383;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3403 = phase_array[17:0]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3404 = n3385 ? memin : n3403;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3405 = phase_array[35:18]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3406 = n3386 ? memin : n3405;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3407 = phase_array[53:36]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3408 = n3387 ? memin : n3407;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3409 = phase_array[71:54]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3410 = n3388 ? memin : n3409;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3411 = phase_array[89:72]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3412 = n3389 ? memin : n3411;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3413 = phase_array[107:90]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3414 = n3390 ? memin : n3413;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3415 = phase_array[125:108]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3416 = n3391 ? memin : n3415;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3417 = phase_array[143:126]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3418 = n3392 ? memin : n3417;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3419 = phase_array[161:144]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3420 = n3393 ? memin : n3419;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3421 = phase_array[179:162]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3422 = n3394 ? memin : n3421;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3423 = phase_array[197:180]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3424 = n3395 ? memin : n3423;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3425 = phase_array[215:198]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3426 = n3396 ? memin : n3425;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3427 = phase_array[233:216]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3428 = n3397 ? memin : n3427;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3429 = phase_array[251:234]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3430 = n3398 ? memin : n3429;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3431 = phase_array[269:252]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3432 = n3399 ? memin : n3431;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3433 = phase_array[287:270]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3434 = n3400 ? memin : n3433;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3435 = phase_array[305:288]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3436 = n3401 ? memin : n3435;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3437 = phase_array[323:306]; // extract
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3438 = n3402 ? memin : n3437;
  /*# work/sms-vhdl/compat/phasememory.vhd:75:10 */
  assign n3439 = {n3438, n3436, n3434, n3432, n3430, n3428, n3426, n3424, n3422, n3420, n3418, n3416, n3414, n3412, n3410, n3408, n3406, n3404};
  /*# work/sms-vhdl/compat/phasememory.vhd:79:28 */
  assign n3441 = {252'bX, phase_array};
  /*# work/sms-vhdl/compat/phasememory.vhd:79:28 */
  assign n3442 = n3441[n3257 * 18 +: 18]; //(Bmux)
endmodule

module envelopememory_Brtl
  (input  clk,
   input  reset,
   input  [4:0] waddr,
   input  wr,
   input  [1:0] \wdata[state] ,
   input  [22:0] \wdata[phase] ,
   input  [4:0] raddr,
   output [1:0] \rdata[state] ,
   output [22:0] \rdata[phase] );
  wire [24:0] n2998;
  wire [1:0] n3000;
  wire [22:0] n3001;
  wire [449:0] egdata_set;
  reg [4:0] n3002_init_slot;
  wire [31:0] n3006;
  wire n3008;
  wire [4:0] n3010;
  wire [31:0] n3014;
  wire [31:0] n3016;
  wire [4:0] n3017;
  wire [4:0] n3020;
  wire [1:0] n3027;
  wire [22:0] n3028;
  wire [24:0] n3029;
  wire [449:0] n3031;
  wire [449:0] n3032;
  wire [4:0] n3037;
  wire [1:0] n3044;
  wire [22:0] n3045;
  wire [24:0] n3046;
  wire n3055;
  wire [24:0] n3056;
  reg [24:0] n3057;
  wire n3058;
  wire [449:0] n3059;
  reg [449:0] n3060;
  wire [4:0] n3061;
  reg [4:0] n3062;
  wire n3063;
  wire n3064;
  wire n3065;
  wire n3066;
  wire n3067;
  wire n3068;
  wire n3069;
  wire n3070;
  wire n3071;
  wire n3072;
  wire n3073;
  wire n3074;
  wire n3075;
  wire n3076;
  wire n3077;
  wire n3078;
  wire n3079;
  wire n3080;
  wire n3081;
  wire n3082;
  wire n3083;
  wire n3084;
  wire n3085;
  wire n3086;
  wire n3087;
  wire n3088;
  wire n3089;
  wire n3090;
  wire n3091;
  wire n3092;
  wire n3093;
  wire n3094;
  wire n3095;
  wire n3096;
  wire n3097;
  wire n3098;
  wire n3099;
  wire n3100;
  wire n3101;
  wire n3102;
  wire n3103;
  wire n3104;
  wire n3105;
  wire n3106;
  wire n3107;
  wire [24:0] n3108;
  wire [24:0] n3109;
  wire [24:0] n3110;
  wire [24:0] n3111;
  wire [24:0] n3112;
  wire [24:0] n3113;
  wire [24:0] n3114;
  wire [24:0] n3115;
  wire [24:0] n3116;
  wire [24:0] n3117;
  wire [24:0] n3118;
  wire [24:0] n3119;
  wire [24:0] n3120;
  wire [24:0] n3121;
  wire [24:0] n3122;
  wire [24:0] n3123;
  wire [24:0] n3124;
  wire [24:0] n3125;
  wire [24:0] n3126;
  wire [24:0] n3127;
  wire [24:0] n3128;
  wire [24:0] n3129;
  wire [24:0] n3130;
  wire [24:0] n3131;
  wire [24:0] n3132;
  wire [24:0] n3133;
  wire [24:0] n3134;
  wire [24:0] n3135;
  wire [24:0] n3136;
  wire [24:0] n3137;
  wire [24:0] n3138;
  wire [24:0] n3139;
  wire [24:0] n3140;
  wire [24:0] n3141;
  wire [24:0] n3142;
  wire [24:0] n3143;
  wire [449:0] n3144;
  wire n3145;
  wire n3146;
  wire n3147;
  wire n3148;
  wire n3149;
  wire n3150;
  wire n3151;
  wire n3152;
  wire n3153;
  wire n3154;
  wire n3155;
  wire n3156;
  wire n3157;
  wire n3158;
  wire n3159;
  wire n3160;
  wire n3161;
  wire n3162;
  wire n3163;
  wire n3164;
  wire n3165;
  wire n3166;
  wire n3167;
  wire n3168;
  wire n3169;
  wire n3170;
  wire n3171;
  wire n3172;
  wire n3173;
  wire n3174;
  wire n3175;
  wire n3176;
  wire n3177;
  wire n3178;
  wire n3179;
  wire n3180;
  wire n3181;
  wire n3182;
  wire n3183;
  wire n3184;
  wire n3185;
  wire n3186;
  wire n3187;
  wire n3188;
  wire n3189;
  wire [24:0] n3190;
  wire [24:0] n3191;
  wire [24:0] n3192;
  wire [24:0] n3193;
  wire [24:0] n3194;
  wire [24:0] n3195;
  wire [24:0] n3196;
  wire [24:0] n3197;
  wire [24:0] n3198;
  wire [24:0] n3199;
  wire [24:0] n3200;
  wire [24:0] n3201;
  wire [24:0] n3202;
  wire [24:0] n3203;
  wire [24:0] n3204;
  wire [24:0] n3205;
  wire [24:0] n3206;
  wire [24:0] n3207;
  wire [24:0] n3208;
  wire [24:0] n3209;
  wire [24:0] n3210;
  wire [24:0] n3211;
  wire [24:0] n3212;
  wire [24:0] n3213;
  wire [24:0] n3214;
  wire [24:0] n3215;
  wire [24:0] n3216;
  wire [24:0] n3217;
  wire [24:0] n3218;
  wire [24:0] n3219;
  wire [24:0] n3220;
  wire [24:0] n3221;
  wire [24:0] n3222;
  wire [24:0] n3223;
  wire [24:0] n3224;
  wire [24:0] n3225;
  wire [449:0] n3226;
  wire [799:0] n3228;
  wire [24:0] n3229;
  assign \rdata[state]  = n3000; //(module output)
  assign \rdata[phase]  = n3001; //(module output)
  /*# work/sms-vhdl/compat/envelopememory.vhd:36:8 */
  assign n2998 = {\wdata[phase] , \wdata[state] };
  /*# work/sms-vhdl/compat/envelopememory.vhd:36:8 */
  assign n3000 = n3057[1:0]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:36:8 */
  assign n3001 = n3057[24:2]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:51:10 */
  assign egdata_set = n3060; // (signal)
  /*# work/sms-vhdl/compat/envelopememory.vhd:57:14 */
  always @*
    n3002_init_slot = n3062; // (isignal)
  initial
    n3002_init_slot = 5'b00000;
  /*# work/sms-vhdl/compat/envelopememory.vhd:67:19 */
  assign n3006 = {27'b0, n3002_init_slot};  // uext
  /*# work/sms-vhdl/compat/envelopememory.vhd:67:19 */
  assign n3008 = n3006 != 32'b00000000000000000000000000010010;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:19 */
  assign n3010 = 5'b10001 - n3002_init_slot;
  /*# work/sms-vhdl/compat/envelopememory.vhd:69:31 */
  assign n3014 = {27'b0, n3002_init_slot};  // uext
  /*# work/sms-vhdl/compat/envelopememory.vhd:69:31 */
  assign n3016 = n3014 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/envelopememory.vhd:69:8 */
  assign n3017 = n3016[4:0];  // trunc
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:19 */
  assign n3020 = 5'b10001 - waddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:206:17 */
  assign n3027 = n2998[1:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:206:30 */
  assign n3028 = n2998[24:2]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:206:23 */
  assign n3029 = {n3027, n3028};
  /*# work/sms-vhdl/compat/envelopememory.vhd:70:6 */
  assign n3031 = wr ? n3226 : egdata_set;
  /*# work/sms-vhdl/compat/envelopememory.vhd:67:6 */
  assign n3032 = n3008 ? n3144 : n3031;
  /*# work/sms-vhdl/compat/envelopememory.vhd:73:38 */
  assign n3037 = 5'b10001 - raddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:211:26 */
  assign n3044 = n3229[24:23]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:212:26 */
  assign n3045 = n3229[22:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:211:12 */
  assign n3046 = {n3045, n3044};
  /*# work/sms-vhdl/compat/envelopememory.vhd:44:3 */
  assign n3055 = ~reset;
  /*# work/sms-vhdl/compat/envelopememory.vhd:65:4 */
  assign n3056 = n3055 ? n3046 : n3057;
  /*# work/sms-vhdl/compat/envelopememory.vhd:65:4 */
  always @(posedge clk)
    n3057 <= n3056;
  /*# work/sms-vhdl/compat/envelopememory.vhd:51:10 */
  assign n3058 = ~reset;
  /*# work/sms-vhdl/compat/envelopememory.vhd:65:4 */
  assign n3059 = n3058 ? n3032 : egdata_set;
  /*# work/sms-vhdl/compat/envelopememory.vhd:65:4 */
  always @(posedge clk)
    n3060 <= n3059;
  /*# work/sms-vhdl/compat/envelopememory.vhd:65:4 */
  assign n3061 = n3008 ? n3017 : n3002_init_slot;
  /*# work/sms-vhdl/compat/envelopememory.vhd:65:4 */
  always @(posedge clk or posedge reset)
    if (reset)
      n3062 <= 5'b00000;
    else
      n3062 <= n3061;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3063 = n3010[4]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3064 = ~n3063;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3065 = n3010[3]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3066 = ~n3065;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3067 = n3064 & n3066;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3068 = n3064 & n3065;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3069 = n3063 & n3066;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3070 = n3010[2]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3071 = ~n3070;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3072 = n3067 & n3071;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3073 = n3067 & n3070;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3074 = n3068 & n3071;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3075 = n3068 & n3070;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3076 = n3069 & n3071;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3077 = n3010[1]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3078 = ~n3077;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3079 = n3072 & n3078;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3080 = n3072 & n3077;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3081 = n3073 & n3078;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3082 = n3073 & n3077;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3083 = n3074 & n3078;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3084 = n3074 & n3077;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3085 = n3075 & n3078;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3086 = n3075 & n3077;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3087 = n3076 & n3078;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3088 = n3010[0]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3089 = ~n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3090 = n3079 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3091 = n3079 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3092 = n3080 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3093 = n3080 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3094 = n3081 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3095 = n3081 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3096 = n3082 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3097 = n3082 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3098 = n3083 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3099 = n3083 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3100 = n3084 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3101 = n3084 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3102 = n3085 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3103 = n3085 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3104 = n3086 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3105 = n3086 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3106 = n3087 & n3089;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3107 = n3087 & n3088;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3108 = egdata_set[24:0]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3109 = n3090 ? 25'b1111111111111111111111111 : n3108;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3110 = egdata_set[49:25]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3111 = n3091 ? 25'b1111111111111111111111111 : n3110;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3112 = egdata_set[74:50]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3113 = n3092 ? 25'b1111111111111111111111111 : n3112;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3114 = egdata_set[99:75]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3115 = n3093 ? 25'b1111111111111111111111111 : n3114;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3116 = egdata_set[124:100]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3117 = n3094 ? 25'b1111111111111111111111111 : n3116;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3118 = egdata_set[149:125]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3119 = n3095 ? 25'b1111111111111111111111111 : n3118;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3120 = egdata_set[174:150]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3121 = n3096 ? 25'b1111111111111111111111111 : n3120;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3122 = egdata_set[199:175]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3123 = n3097 ? 25'b1111111111111111111111111 : n3122;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3124 = egdata_set[224:200]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3125 = n3098 ? 25'b1111111111111111111111111 : n3124;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3126 = egdata_set[249:225]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3127 = n3099 ? 25'b1111111111111111111111111 : n3126;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3128 = egdata_set[274:250]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3129 = n3100 ? 25'b1111111111111111111111111 : n3128;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3130 = egdata_set[299:275]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3131 = n3101 ? 25'b1111111111111111111111111 : n3130;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3132 = egdata_set[324:300]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3133 = n3102 ? 25'b1111111111111111111111111 : n3132;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3134 = egdata_set[349:325]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3135 = n3103 ? 25'b1111111111111111111111111 : n3134;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3136 = egdata_set[374:350]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3137 = n3104 ? 25'b1111111111111111111111111 : n3136;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3138 = egdata_set[399:375]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3139 = n3105 ? 25'b1111111111111111111111111 : n3138;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3140 = egdata_set[424:400]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3141 = n3106 ? 25'b1111111111111111111111111 : n3140;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3142 = egdata_set[449:425]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3143 = n3107 ? 25'b1111111111111111111111111 : n3142;
  /*# work/sms-vhdl/compat/envelopememory.vhd:68:8 */
  assign n3144 = {n3143, n3141, n3139, n3137, n3135, n3133, n3131, n3129, n3127, n3125, n3123, n3121, n3119, n3117, n3115, n3113, n3111, n3109};
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3145 = n3020[4]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3146 = ~n3145;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3147 = n3020[3]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3148 = ~n3147;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3149 = n3146 & n3148;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3150 = n3146 & n3147;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3151 = n3145 & n3148;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3152 = n3020[2]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3153 = ~n3152;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3154 = n3149 & n3153;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3155 = n3149 & n3152;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3156 = n3150 & n3153;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3157 = n3150 & n3152;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3158 = n3151 & n3153;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3159 = n3020[1]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3160 = ~n3159;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3161 = n3154 & n3160;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3162 = n3154 & n3159;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3163 = n3155 & n3160;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3164 = n3155 & n3159;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3165 = n3156 & n3160;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3166 = n3156 & n3159;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3167 = n3157 & n3160;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3168 = n3157 & n3159;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3169 = n3158 & n3160;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3170 = n3020[0]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3171 = ~n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3172 = n3161 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3173 = n3161 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3174 = n3162 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3175 = n3162 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3176 = n3163 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3177 = n3163 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3178 = n3164 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3179 = n3164 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3180 = n3165 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3181 = n3165 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3182 = n3166 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3183 = n3166 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3184 = n3167 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3185 = n3167 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3186 = n3168 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3187 = n3168 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3188 = n3169 & n3171;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3189 = n3169 & n3170;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3190 = egdata_set[24:0]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3191 = n3172 ? n3029 : n3190;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3192 = egdata_set[49:25]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3193 = n3173 ? n3029 : n3192;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3194 = egdata_set[74:50]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3195 = n3174 ? n3029 : n3194;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3196 = egdata_set[99:75]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3197 = n3175 ? n3029 : n3196;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3198 = egdata_set[124:100]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3199 = n3176 ? n3029 : n3198;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3200 = egdata_set[149:125]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3201 = n3177 ? n3029 : n3200;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3202 = egdata_set[174:150]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3203 = n3178 ? n3029 : n3202;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3204 = egdata_set[199:175]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3205 = n3179 ? n3029 : n3204;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3206 = egdata_set[224:200]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3207 = n3180 ? n3029 : n3206;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3208 = egdata_set[249:225]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3209 = n3181 ? n3029 : n3208;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3210 = egdata_set[274:250]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3211 = n3182 ? n3029 : n3210;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3212 = egdata_set[299:275]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3213 = n3183 ? n3029 : n3212;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3214 = egdata_set[324:300]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3215 = n3184 ? n3029 : n3214;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3216 = egdata_set[349:325]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3217 = n3185 ? n3029 : n3216;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3218 = egdata_set[374:350]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3219 = n3186 ? n3029 : n3218;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3220 = egdata_set[399:375]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3221 = n3187 ? n3029 : n3220;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3222 = egdata_set[424:400]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3223 = n3188 ? n3029 : n3222;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3224 = egdata_set[449:425]; // extract
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3225 = n3189 ? n3029 : n3224;
  /*# work/sms-vhdl/compat/envelopememory.vhd:71:8 */
  assign n3226 = {n3225, n3223, n3221, n3219, n3217, n3215, n3213, n3211, n3209, n3207, n3205, n3203, n3201, n3199, n3197, n3195, n3193, n3191};
  /*# work/sms-vhdl/compat/envelopememory.vhd:73:38 */
  assign n3228 = {350'bX, egdata_set};
  /*# work/sms-vhdl/compat/envelopememory.vhd:73:38 */
  assign n3229 = n3228[n3037 * 25 +: 25]; //(Bmux)
endmodule

module attacktable_Brtl
  (input  clk,
   input  clkena,
   input  [21:0] addr,
   output [12:0] data);
  wire [7:0] ff_w;
  wire [6:0] ff_d1;
  wire [6:0] ff_d2;
  wire [6:0] w_addr1;
  wire [6:0] w_addr2;
  wire [7:0] w_sub;
  wire [13:0] w_mul;
  wire [13:0] w_inter;
  wire [6:0] n2932;
  wire [6:0] n2934;
  wire n2936;
  wire [6:0] n2937;
  wire [6:0] n2939;
  wire [7:0] n2962;
  wire [7:0] n2967;
  wire [7:0] n2969;
  wire [7:0] n2970;
  wire [13:0] u_attack_table_mul_n2971;
  wire [7:0] n2975;
  wire [13:0] n2977;
  wire [13:0] n2978;
  wire [12:0] n2982;
  wire [12:0] n2986;
  reg [12:0] n2987;
  wire [7:0] n2988;
  reg [7:0] n2989;
  reg [6:0] n2996; // mem_rd
  reg [6:0] n2997; // mem_rd
  assign data = n2987; //(module output)
  /*# work/sms-vhdl/compat/attacktable.vhd:103:12 */
  assign ff_w = n2989; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:104:12 */
  assign ff_d1 = n2997; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:105:12 */
  assign ff_d2 = n2996; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:107:12 */
  assign w_addr1 = n2932; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:108:12 */
  assign w_addr2 = n2937; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:109:12 */
  assign w_sub = n2970; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:110:12 */
  assign w_mul = u_attack_table_mul_n2971; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:111:12 */
  assign w_inter = n2978; // (signal)
  /*# work/sms-vhdl/compat/attacktable.vhd:114:20 */
  assign n2932 = addr[21:15]; // extract
  /*# work/sms-vhdl/compat/attacktable.vhd:115:42 */
  assign n2934 = addr[21:15]; // extract
  /*# work/sms-vhdl/compat/attacktable.vhd:115:59 */
  assign n2936 = n2934 == 7'b1111111;
  /*# work/sms-vhdl/compat/attacktable.vhd:115:32 */
  assign n2937 = n2936 ? 7'b1111111 : n2939;
  /*# work/sms-vhdl/compat/attacktable.vhd:116:24 */
  assign n2939 = w_addr1 + 7'b0000001;
  /*# work/sms-vhdl/compat/attacktable.vhd:132:29 */
  assign n2962 = addr[14:7]; // extract
  /*# work/sms-vhdl/compat/attacktable.vhd:139:21 */
  assign n2967 = {1'b0, ff_d2};
  /*# work/sms-vhdl/compat/attacktable.vhd:139:37 */
  assign n2969 = {1'b0, ff_d1};
  /*# work/sms-vhdl/compat/attacktable.vhd:139:30 */
  assign n2970 = n2967 - n2969;
  /*# work/sms-vhdl/compat/attacktable.vhd:141:5 */
  attack_table_mul_Brtl u_attack_table_mul (
    .i0(ff_w),
    .i1(w_sub),
    .o(u_attack_table_mul_n2971));
  /*# work/sms-vhdl/compat/attacktable.vhd:148:21 */
  assign n2975 = {1'b0, ff_d1};
  /*# work/sms-vhdl/compat/attacktable.vhd:148:29 */
  assign n2977 = {n2975, 6'b000000};
  /*# work/sms-vhdl/compat/attacktable.vhd:148:41 */
  assign n2978 = n2977 + w_mul;
  /*# work/sms-vhdl/compat/attacktable.vhd:154:31 */
  assign n2982 = w_inter[12:0]; // extract
  /*# work/sms-vhdl/compat/attacktable.vhd:152:9 */
  assign n2986 = clkena ? n2982 : n2987;
  /*# work/sms-vhdl/compat/attacktable.vhd:152:9 */
  always @(posedge clk)
    n2987 <= n2986;
  /*# work/sms-vhdl/compat/attacktable.vhd:130:9 */
  assign n2988 = clkena ? n2962 : ff_w;
  /*# work/sms-vhdl/compat/attacktable.vhd:130:9 */
  always @(posedge clk)
    n2989 <= n2988;
  /*# work/sms-vhdl/compat/attacktable.vhd:122:37 */
  reg [6:0] n2994[127:0] ; // memory
  initial begin
    n2994[127] = 7'b1111111;
    n2994[126] = 7'b1110101;
    n2994[125] = 7'b1101100;
    n2994[124] = 7'b1100010;
    n2994[123] = 7'b1011010;
    n2994[122] = 7'b1010100;
    n2994[121] = 7'b1010000;
    n2994[120] = 7'b1001011;
    n2994[119] = 7'b1001000;
    n2994[118] = 7'b1000101;
    n2994[117] = 7'b1000010;
    n2994[116] = 7'b1000000;
    n2994[115] = 7'b0111101;
    n2994[114] = 7'b0111011;
    n2994[113] = 7'b0111001;
    n2994[112] = 7'b0111000;
    n2994[111] = 7'b0110110;
    n2994[110] = 7'b0110100;
    n2994[109] = 7'b0110011;
    n2994[108] = 7'b0110001;
    n2994[107] = 7'b0110000;
    n2994[106] = 7'b0101111;
    n2994[105] = 7'b0101101;
    n2994[104] = 7'b0101100;
    n2994[103] = 7'b0101011;
    n2994[102] = 7'b0101010;
    n2994[101] = 7'b0101001;
    n2994[100] = 7'b0101000;
    n2994[99] = 7'b0100111;
    n2994[98] = 7'b0100110;
    n2994[97] = 7'b0100101;
    n2994[96] = 7'b0100100;
    n2994[95] = 7'b0100100;
    n2994[94] = 7'b0100011;
    n2994[93] = 7'b0100010;
    n2994[92] = 7'b0100001;
    n2994[91] = 7'b0100001;
    n2994[90] = 7'b0100000;
    n2994[89] = 7'b0011111;
    n2994[88] = 7'b0011110;
    n2994[87] = 7'b0011110;
    n2994[86] = 7'b0011101;
    n2994[85] = 7'b0011101;
    n2994[84] = 7'b0011100;
    n2994[83] = 7'b0011011;
    n2994[82] = 7'b0011011;
    n2994[81] = 7'b0011010;
    n2994[80] = 7'b0011010;
    n2994[79] = 7'b0011001;
    n2994[78] = 7'b0011000;
    n2994[77] = 7'b0011000;
    n2994[76] = 7'b0010111;
    n2994[75] = 7'b0010111;
    n2994[74] = 7'b0010110;
    n2994[73] = 7'b0010110;
    n2994[72] = 7'b0010101;
    n2994[71] = 7'b0010101;
    n2994[70] = 7'b0010101;
    n2994[69] = 7'b0010100;
    n2994[68] = 7'b0010100;
    n2994[67] = 7'b0010011;
    n2994[66] = 7'b0010011;
    n2994[65] = 7'b0010010;
    n2994[64] = 7'b0010010;
    n2994[63] = 7'b0010001;
    n2994[62] = 7'b0010001;
    n2994[61] = 7'b0010001;
    n2994[60] = 7'b0010000;
    n2994[59] = 7'b0010000;
    n2994[58] = 7'b0001111;
    n2994[57] = 7'b0001111;
    n2994[56] = 7'b0001111;
    n2994[55] = 7'b0001110;
    n2994[54] = 7'b0001110;
    n2994[53] = 7'b0001110;
    n2994[52] = 7'b0001101;
    n2994[51] = 7'b0001101;
    n2994[50] = 7'b0001101;
    n2994[49] = 7'b0001100;
    n2994[48] = 7'b0001100;
    n2994[47] = 7'b0001100;
    n2994[46] = 7'b0001011;
    n2994[45] = 7'b0001011;
    n2994[44] = 7'b0001011;
    n2994[43] = 7'b0001010;
    n2994[42] = 7'b0001010;
    n2994[41] = 7'b0001010;
    n2994[40] = 7'b0001001;
    n2994[39] = 7'b0001001;
    n2994[38] = 7'b0001001;
    n2994[37] = 7'b0001001;
    n2994[36] = 7'b0001000;
    n2994[35] = 7'b0001000;
    n2994[34] = 7'b0001000;
    n2994[33] = 7'b0000111;
    n2994[32] = 7'b0000111;
    n2994[31] = 7'b0000111;
    n2994[30] = 7'b0000111;
    n2994[29] = 7'b0000110;
    n2994[28] = 7'b0000110;
    n2994[27] = 7'b0000110;
    n2994[26] = 7'b0000110;
    n2994[25] = 7'b0000101;
    n2994[24] = 7'b0000101;
    n2994[23] = 7'b0000101;
    n2994[22] = 7'b0000100;
    n2994[21] = 7'b0000100;
    n2994[20] = 7'b0000100;
    n2994[19] = 7'b0000100;
    n2994[18] = 7'b0000100;
    n2994[17] = 7'b0000011;
    n2994[16] = 7'b0000011;
    n2994[15] = 7'b0000011;
    n2994[14] = 7'b0000011;
    n2994[13] = 7'b0000010;
    n2994[12] = 7'b0000010;
    n2994[11] = 7'b0000010;
    n2994[10] = 7'b0000010;
    n2994[9] = 7'b0000001;
    n2994[8] = 7'b0000001;
    n2994[7] = 7'b0000001;
    n2994[6] = 7'b0000001;
    n2994[5] = 7'b0000001;
    n2994[4] = 7'b0000000;
    n2994[3] = 7'b0000000;
    n2994[2] = 7'b0000000;
    n2994[1] = 7'b0000000;
    n2994[0] = 7'b0000000;
    end
  always @(posedge clk)
    if (clkena)
      n2996 <= n2994[w_addr2];
  always @(posedge clk)
    if (clkena)
      n2997 <= n2994[w_addr1];
  /*# work/sms-vhdl/compat/attacktable.vhd:120:9 */
  /*# work/sms-vhdl/compat/attacktable.vhd:120:9 */
endmodule

module voicememory_Brtl
  (input  clk,
   input  reset,
   input  \idata[am] ,
   input  \idata[pm] ,
   input  \idata[eg] ,
   input  \idata[kr] ,
   input  [3:0] \idata[ml] ,
   input  [1:0] \idata[kl] ,
   input  [5:0] \idata[tl] ,
   input  \idata[wf] ,
   input  [2:0] \idata[fb] ,
   input  [3:0] \idata[ar] ,
   input  [3:0] \idata[dr] ,
   input  [3:0] \idata[sl] ,
   input  [3:0] \idata[rr] ,
   input  wr,
   input  [5:0] rwaddr,
   input  [5:0] roaddr,
   output \odata[am] ,
   output \odata[pm] ,
   output \odata[eg] ,
   output \odata[kr] ,
   output [3:0] \odata[ml] ,
   output [1:0] \odata[kl] ,
   output [5:0] \odata[tl] ,
   output \odata[wf] ,
   output [2:0] \odata[fb] ,
   output [3:0] \odata[ar] ,
   output [3:0] \odata[dr] ,
   output [3:0] \odata[sl] ,
   output [3:0] \odata[rr] ,
   output \rodata[am] ,
   output \rodata[pm] ,
   output \rodata[eg] ,
   output \rodata[kr] ,
   output [3:0] \rodata[ml] ,
   output [1:0] \rodata[kl] ,
   output [5:0] \rodata[tl] ,
   output \rodata[wf] ,
   output [2:0] \rodata[fb] ,
   output [3:0] \rodata[ar] ,
   output [3:0] \rodata[dr] ,
   output [3:0] \rodata[sl] ,
   output [3:0] \rodata[rr] );
  wire [35:0] n2388;
  wire n2390;
  wire n2391;
  wire n2392;
  wire n2393;
  wire [3:0] n2394;
  wire [1:0] n2395;
  wire [5:0] n2396;
  wire n2397;
  wire [2:0] n2398;
  wire [3:0] n2399;
  wire [3:0] n2400;
  wire [3:0] n2401;
  wire [3:0] n2402;
  wire n2404;
  wire n2405;
  wire n2406;
  wire n2407;
  wire [3:0] n2408;
  wire [1:0] n2409;
  wire [5:0] n2410;
  wire n2411;
  wire [2:0] n2412;
  wire [3:0] n2413;
  wire [3:0] n2414;
  wire [3:0] n2415;
  wire [3:0] n2416;
  wire [1367:0] voices;
  wire [5:0] rom_addr;
  wire [35:0] rom_data;
  wire [1:0] rstate;
  wire [35:0] rom2413_n2417;
  wire \rom2413.data[am] ;
  wire \rom2413.data[pm] ;
  wire \rom2413.data[eg] ;
  wire \rom2413.data[kr] ;
  wire [3:0] \rom2413.data[ml] ;
  wire [1:0] \rom2413.data[kl] ;
  wire [5:0] \rom2413.data[tl] ;
  wire \rom2413.data[wf] ;
  wire [2:0] \rom2413.data[fb] ;
  wire [3:0] \rom2413.data[ar] ;
  wire [3:0] \rom2413.data[dr] ;
  wire [3:0] \rom2413.data[sl] ;
  wire [3:0] \rom2413.data[rr] ;
  wire [35:0] n2418;
  reg [5:0] n2421_init_id;
  wire [31:0] n2425;
  wire n2427;
  wire n2429;
  wire n2431;
  wire [5:0] n2433;
  wire n2440;
  wire n2441;
  wire [1:0] n2442;
  wire n2443;
  wire [2:0] n2444;
  wire n2445;
  wire [3:0] n2446;
  wire [3:0] n2447;
  wire [7:0] n2448;
  wire [1:0] n2449;
  wire [9:0] n2450;
  wire [5:0] n2451;
  wire [15:0] n2452;
  wire n2453;
  wire [16:0] n2454;
  wire [2:0] n2455;
  wire [19:0] n2456;
  wire [3:0] n2457;
  wire [23:0] n2458;
  wire [3:0] n2459;
  wire [27:0] n2460;
  wire [3:0] n2461;
  wire [31:0] n2462;
  wire [3:0] n2463;
  wire [35:0] n2464;
  wire [31:0] n2466;
  wire [31:0] n2468;
  wire [5:0] n2469;
  wire n2471;
  wire [2:0] n2472;
  reg [1367:0] n2473;
  reg [5:0] n2474;
  reg [1:0] n2478;
  reg [5:0] n2479;
  wire [5:0] n2481;
  wire n2488;
  wire n2489;
  wire [1:0] n2490;
  wire n2491;
  wire [2:0] n2492;
  wire n2493;
  wire [3:0] n2494;
  wire [3:0] n2495;
  wire [7:0] n2496;
  wire [1:0] n2497;
  wire [9:0] n2498;
  wire [5:0] n2499;
  wire [15:0] n2500;
  wire n2501;
  wire [16:0] n2502;
  wire [2:0] n2503;
  wire [19:0] n2504;
  wire [3:0] n2505;
  wire [23:0] n2506;
  wire [3:0] n2507;
  wire [27:0] n2508;
  wire [3:0] n2509;
  wire [31:0] n2510;
  wire [3:0] n2511;
  wire [35:0] n2512;
  wire [1367:0] n2514;
  wire [1367:0] n2515;
  wire [5:0] n2521;
  wire n2528;
  wire n2529;
  wire n2530;
  wire n2531;
  wire [3:0] n2532;
  wire [1:0] n2533;
  wire [5:0] n2534;
  wire n2535;
  wire [2:0] n2536;
  wire [3:0] n2537;
  wire [3:0] n2538;
  wire [3:0] n2539;
  wire [3:0] n2540;
  wire [35:0] n2541;
  wire [5:0] n2544;
  wire n2551;
  wire n2552;
  wire n2553;
  wire n2554;
  wire [3:0] n2555;
  wire [1:0] n2556;
  wire [5:0] n2557;
  wire n2558;
  wire [2:0] n2559;
  wire [3:0] n2560;
  wire [3:0] n2561;
  wire [3:0] n2562;
  wire [3:0] n2563;
  wire [35:0] n2564;
  wire n2580;
  wire [35:0] n2581;
  reg [35:0] n2582;
  wire n2583;
  wire [35:0] n2584;
  reg [35:0] n2585;
  wire n2586;
  wire [1367:0] n2587;
  reg [1367:0] n2588;
  wire n2589;
  wire n2590;
  wire [5:0] n2591;
  reg [5:0] n2592;
  wire [1:0] n2593;
  reg [1:0] n2594;
  wire [5:0] n2595;
  reg [5:0] n2596;
  wire n2597;
  wire n2598;
  wire n2599;
  wire n2600;
  wire n2601;
  wire n2602;
  wire n2603;
  wire n2604;
  wire n2605;
  wire n2606;
  wire n2607;
  wire n2608;
  wire n2609;
  wire n2610;
  wire n2611;
  wire n2612;
  wire n2613;
  wire n2614;
  wire n2615;
  wire n2616;
  wire n2617;
  wire n2618;
  wire n2619;
  wire n2620;
  wire n2621;
  wire n2622;
  wire n2623;
  wire n2624;
  wire n2625;
  wire n2626;
  wire n2627;
  wire n2628;
  wire n2629;
  wire n2630;
  wire n2631;
  wire n2632;
  wire n2633;
  wire n2634;
  wire n2635;
  wire n2636;
  wire n2637;
  wire n2638;
  wire n2639;
  wire n2640;
  wire n2641;
  wire n2642;
  wire n2643;
  wire n2644;
  wire n2645;
  wire n2646;
  wire n2647;
  wire n2648;
  wire n2649;
  wire n2650;
  wire n2651;
  wire n2652;
  wire n2653;
  wire n2654;
  wire n2655;
  wire n2656;
  wire n2657;
  wire n2658;
  wire n2659;
  wire n2660;
  wire n2661;
  wire n2662;
  wire n2663;
  wire n2664;
  wire n2665;
  wire n2666;
  wire n2667;
  wire n2668;
  wire n2669;
  wire n2670;
  wire n2671;
  wire n2672;
  wire n2673;
  wire n2674;
  wire n2675;
  wire n2676;
  wire n2677;
  wire n2678;
  wire n2679;
  wire n2680;
  wire n2681;
  wire n2682;
  wire n2683;
  wire [35:0] n2684;
  wire [35:0] n2685;
  wire [35:0] n2686;
  wire [35:0] n2687;
  wire [35:0] n2688;
  wire [35:0] n2689;
  wire [35:0] n2690;
  wire [35:0] n2691;
  wire [35:0] n2692;
  wire [35:0] n2693;
  wire [35:0] n2694;
  wire [35:0] n2695;
  wire [35:0] n2696;
  wire [35:0] n2697;
  wire [35:0] n2698;
  wire [35:0] n2699;
  wire [35:0] n2700;
  wire [35:0] n2701;
  wire [35:0] n2702;
  wire [35:0] n2703;
  wire [35:0] n2704;
  wire [35:0] n2705;
  wire [35:0] n2706;
  wire [35:0] n2707;
  wire [35:0] n2708;
  wire [35:0] n2709;
  wire [35:0] n2710;
  wire [35:0] n2711;
  wire [35:0] n2712;
  wire [35:0] n2713;
  wire [35:0] n2714;
  wire [35:0] n2715;
  wire [35:0] n2716;
  wire [35:0] n2717;
  wire [35:0] n2718;
  wire [35:0] n2719;
  wire [35:0] n2720;
  wire [35:0] n2721;
  wire [35:0] n2722;
  wire [35:0] n2723;
  wire [35:0] n2724;
  wire [35:0] n2725;
  wire [35:0] n2726;
  wire [35:0] n2727;
  wire [35:0] n2728;
  wire [35:0] n2729;
  wire [35:0] n2730;
  wire [35:0] n2731;
  wire [35:0] n2732;
  wire [35:0] n2733;
  wire [35:0] n2734;
  wire [35:0] n2735;
  wire [35:0] n2736;
  wire [35:0] n2737;
  wire [35:0] n2738;
  wire [35:0] n2739;
  wire [35:0] n2740;
  wire [35:0] n2741;
  wire [35:0] n2742;
  wire [35:0] n2743;
  wire [35:0] n2744;
  wire [35:0] n2745;
  wire [35:0] n2746;
  wire [35:0] n2747;
  wire [35:0] n2748;
  wire [35:0] n2749;
  wire [35:0] n2750;
  wire [35:0] n2751;
  wire [35:0] n2752;
  wire [35:0] n2753;
  wire [35:0] n2754;
  wire [35:0] n2755;
  wire [35:0] n2756;
  wire [35:0] n2757;
  wire [35:0] n2758;
  wire [35:0] n2759;
  wire [1367:0] n2760;
  wire n2761;
  wire n2762;
  wire n2763;
  wire n2764;
  wire n2765;
  wire n2766;
  wire n2767;
  wire n2768;
  wire n2769;
  wire n2770;
  wire n2771;
  wire n2772;
  wire n2773;
  wire n2774;
  wire n2775;
  wire n2776;
  wire n2777;
  wire n2778;
  wire n2779;
  wire n2780;
  wire n2781;
  wire n2782;
  wire n2783;
  wire n2784;
  wire n2785;
  wire n2786;
  wire n2787;
  wire n2788;
  wire n2789;
  wire n2790;
  wire n2791;
  wire n2792;
  wire n2793;
  wire n2794;
  wire n2795;
  wire n2796;
  wire n2797;
  wire n2798;
  wire n2799;
  wire n2800;
  wire n2801;
  wire n2802;
  wire n2803;
  wire n2804;
  wire n2805;
  wire n2806;
  wire n2807;
  wire n2808;
  wire n2809;
  wire n2810;
  wire n2811;
  wire n2812;
  wire n2813;
  wire n2814;
  wire n2815;
  wire n2816;
  wire n2817;
  wire n2818;
  wire n2819;
  wire n2820;
  wire n2821;
  wire n2822;
  wire n2823;
  wire n2824;
  wire n2825;
  wire n2826;
  wire n2827;
  wire n2828;
  wire n2829;
  wire n2830;
  wire n2831;
  wire n2832;
  wire n2833;
  wire n2834;
  wire n2835;
  wire n2836;
  wire n2837;
  wire n2838;
  wire n2839;
  wire n2840;
  wire n2841;
  wire n2842;
  wire n2843;
  wire n2844;
  wire n2845;
  wire n2846;
  wire n2847;
  wire [35:0] n2848;
  wire [35:0] n2849;
  wire [35:0] n2850;
  wire [35:0] n2851;
  wire [35:0] n2852;
  wire [35:0] n2853;
  wire [35:0] n2854;
  wire [35:0] n2855;
  wire [35:0] n2856;
  wire [35:0] n2857;
  wire [35:0] n2858;
  wire [35:0] n2859;
  wire [35:0] n2860;
  wire [35:0] n2861;
  wire [35:0] n2862;
  wire [35:0] n2863;
  wire [35:0] n2864;
  wire [35:0] n2865;
  wire [35:0] n2866;
  wire [35:0] n2867;
  wire [35:0] n2868;
  wire [35:0] n2869;
  wire [35:0] n2870;
  wire [35:0] n2871;
  wire [35:0] n2872;
  wire [35:0] n2873;
  wire [35:0] n2874;
  wire [35:0] n2875;
  wire [35:0] n2876;
  wire [35:0] n2877;
  wire [35:0] n2878;
  wire [35:0] n2879;
  wire [35:0] n2880;
  wire [35:0] n2881;
  wire [35:0] n2882;
  wire [35:0] n2883;
  wire [35:0] n2884;
  wire [35:0] n2885;
  wire [35:0] n2886;
  wire [35:0] n2887;
  wire [35:0] n2888;
  wire [35:0] n2889;
  wire [35:0] n2890;
  wire [35:0] n2891;
  wire [35:0] n2892;
  wire [35:0] n2893;
  wire [35:0] n2894;
  wire [35:0] n2895;
  wire [35:0] n2896;
  wire [35:0] n2897;
  wire [35:0] n2898;
  wire [35:0] n2899;
  wire [35:0] n2900;
  wire [35:0] n2901;
  wire [35:0] n2902;
  wire [35:0] n2903;
  wire [35:0] n2904;
  wire [35:0] n2905;
  wire [35:0] n2906;
  wire [35:0] n2907;
  wire [35:0] n2908;
  wire [35:0] n2909;
  wire [35:0] n2910;
  wire [35:0] n2911;
  wire [35:0] n2912;
  wire [35:0] n2913;
  wire [35:0] n2914;
  wire [35:0] n2915;
  wire [35:0] n2916;
  wire [35:0] n2917;
  wire [35:0] n2918;
  wire [35:0] n2919;
  wire [35:0] n2920;
  wire [35:0] n2921;
  wire [35:0] n2922;
  wire [35:0] n2923;
  wire [1367:0] n2924;
  wire [2303:0] n2926;
  wire [35:0] n2927;
  wire [2303:0] n2929;
  wire [35:0] n2930;
  assign \odata[am]  = n2390; //(module output)
  assign \odata[pm]  = n2391; //(module output)
  assign \odata[eg]  = n2392; //(module output)
  assign \odata[kr]  = n2393; //(module output)
  assign \odata[ml]  = n2394; //(module output)
  assign \odata[kl]  = n2395; //(module output)
  assign \odata[tl]  = n2396; //(module output)
  assign \odata[wf]  = n2397; //(module output)
  assign \odata[fb]  = n2398; //(module output)
  assign \odata[ar]  = n2399; //(module output)
  assign \odata[dr]  = n2400; //(module output)
  assign \odata[sl]  = n2401; //(module output)
  assign \odata[rr]  = n2402; //(module output)
  assign \rodata[am]  = n2404; //(module output)
  assign \rodata[pm]  = n2405; //(module output)
  assign \rodata[eg]  = n2406; //(module output)
  assign \rodata[kr]  = n2407; //(module output)
  assign \rodata[ml]  = n2408; //(module output)
  assign \rodata[kl]  = n2409; //(module output)
  assign \rodata[tl]  = n2410; //(module output)
  assign \rodata[wf]  = n2411; //(module output)
  assign \rodata[fb]  = n2412; //(module output)
  assign \rodata[ar]  = n2413; //(module output)
  assign \rodata[dr]  = n2414; //(module output)
  assign \rodata[sl]  = n2415; //(module output)
  assign \rodata[rr]  = n2416; //(module output)
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2388 = {\idata[rr] , \idata[sl] , \idata[dr] , \idata[ar] , \idata[fb] , \idata[wf] , \idata[tl] , \idata[kl] , \idata[ml] , \idata[kr] , \idata[eg] , \idata[pm] , \idata[am] };
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2390 = n2582[0]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2391 = n2582[1]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2392 = n2582[2]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2393 = n2582[3]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2394 = n2582[7:4]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2395 = n2582[9:8]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2396 = n2582[15:10]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2397 = n2582[16]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2398 = n2582[19:17]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2399 = n2582[23:20]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2400 = n2582[27:24]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2401 = n2582[31:28]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2402 = n2582[35:32]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2404 = n2585[0]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2405 = n2585[1]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2406 = n2585[2]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2407 = n2585[3]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2408 = n2585[7:4]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2409 = n2585[9:8]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2410 = n2585[15:10]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2411 = n2585[16]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2412 = n2585[19:17]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2413 = n2585[23:20]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2414 = n2585[27:24]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2415 = n2585[31:28]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:36:8 */
  assign n2416 = n2585[35:32]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:55:10 */
  assign voices = n2588; // (signal)
  /*# work/sms-vhdl/compat/voicememory.vhd:64:10 */
  assign rom_addr = n2592; // (signal)
  /*# work/sms-vhdl/compat/voicememory.vhd:65:10 */
  assign rom_data = rom2413_n2417; // (signal)
  /*# work/sms-vhdl/compat/voicememory.vhd:66:10 */
  assign rstate = n2594; // (signal)
  /*# work/sms-vhdl/compat/voicememory.vhd:70:46 */
  assign rom2413_n2417 = n2418; // (signal)
  /*# work/sms-vhdl/compat/voicememory.vhd:70:3 */
  voicerom_Brtl_c4ea21bb365bbeeaf5f2c654883e56d11e43c44e rom2413 (
    .clk(clk),
    .addr(rom_addr),
    .\data[am] (\rom2413.data[am] ),
    .\data[pm] (\rom2413.data[pm] ),
    .\data[eg] (\rom2413.data[eg] ),
    .\data[kr] (\rom2413.data[kr] ),
    .\data[ml] (\rom2413.data[ml] ),
    .\data[kl] (\rom2413.data[kl] ),
    .\data[tl] (\rom2413.data[tl] ),
    .\data[wf] (\rom2413.data[wf] ),
    .\data[fb] (\rom2413.data[fb] ),
    .\data[ar] (\rom2413.data[ar] ),
    .\data[dr] (\rom2413.data[dr] ),
    .\data[sl] (\rom2413.data[sl] ),
    .\data[rr] (\rom2413.data[rr] ));
  /*# work/sms-vhdl/compat/voicememory.vhd:70:3 */
  assign n2418 = {\rom2413.data[rr] , \rom2413.data[sl] , \rom2413.data[dr] , \rom2413.data[ar] , \rom2413.data[fb] , \rom2413.data[wf] , \rom2413.data[tl] , \rom2413.data[kl] , \rom2413.data[ml] , \rom2413.data[kr] , \rom2413.data[eg] , \rom2413.data[pm] , \rom2413.data[am] };
  /*# work/sms-vhdl/compat/voicememory.vhd:74:14 */
  always @*
    n2421_init_id = n2596; // (isignal)
  initial
    n2421_init_id = 6'b000000;
  /*# work/sms-vhdl/compat/voicememory.vhd:85:18 */
  assign n2425 = {26'b0, n2421_init_id};  // uext
  /*# work/sms-vhdl/compat/voicememory.vhd:85:18 */
  assign n2427 = n2425 != 32'b00000000000000000000000000100110;
  /*# work/sms-vhdl/compat/voicememory.vhd:88:9 */
  assign n2429 = rstate == 2'b00;
  /*# work/sms-vhdl/compat/voicememory.vhd:91:9 */
  assign n2431 = rstate == 2'b01;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:18 */
  assign n2433 = 6'b100101 - n2421_init_id;
  /*# work/sms-vhdl/compat/vm2413.vhd:169:17 */
  assign n2440 = rom_data[0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:27 */
  assign n2441 = rom_data[1]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:20 */
  assign n2442 = {n2440, n2441};
  /*# work/sms-vhdl/compat/vm2413.vhd:169:37 */
  assign n2443 = rom_data[2]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:30 */
  assign n2444 = {n2442, n2443};
  /*# work/sms-vhdl/compat/vm2413.vhd:169:47 */
  assign n2445 = rom_data[3]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:40 */
  assign n2446 = {n2444, n2445};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:17 */
  assign n2447 = rom_data[7:4]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:50 */
  assign n2448 = {n2446, n2447};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:27 */
  assign n2449 = rom_data[9:8]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:20 */
  assign n2450 = {n2448, n2449};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:37 */
  assign n2451 = rom_data[15:10]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:30 */
  assign n2452 = {n2450, n2451};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:47 */
  assign n2453 = rom_data[16]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:40 */
  assign n2454 = {n2452, n2453};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:57 */
  assign n2455 = rom_data[19:17]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:50 */
  assign n2456 = {n2454, n2455};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:17 */
  assign n2457 = rom_data[23:20]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:60 */
  assign n2458 = {n2456, n2457};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:27 */
  assign n2459 = rom_data[27:24]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:171:20 */
  assign n2460 = {n2458, n2459};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:37 */
  assign n2461 = rom_data[31:28]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:171:30 */
  assign n2462 = {n2460, n2461};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:47 */
  assign n2463 = rom_data[35:32]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:171:40 */
  assign n2464 = {n2462, n2463};
  /*# work/sms-vhdl/compat/voicememory.vhd:96:30 */
  assign n2466 = {26'b0, n2421_init_id};  // uext
  /*# work/sms-vhdl/compat/voicememory.vhd:96:30 */
  assign n2468 = n2466 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/voicememory.vhd:96:11 */
  assign n2469 = n2468[5:0];  // trunc
  /*# work/sms-vhdl/compat/voicememory.vhd:93:9 */
  assign n2471 = rstate == 2'b10;
  /*# work/sms-vhdl/compat/voicememory.vhd:87:9 */
  assign n2472 = {n2471, n2431, n2429};
  /*# work/sms-vhdl/compat/voicememory.vhd:87:9 */
  always @*
    case (n2472)
      3'b100: n2473 = n2760;
      3'b010: n2473 = voices;
      3'b001: n2473 = voices;
      default: n2473 = voices;
    endcase
  /*# work/sms-vhdl/compat/voicememory.vhd:87:9 */
  always @*
    case (n2472)
      3'b100: n2474 = rom_addr;
      3'b010: n2474 = rom_addr;
      3'b001: n2474 = n2421_init_id;
      default: n2474 = rom_addr;
    endcase
  /*# work/sms-vhdl/compat/voicememory.vhd:87:9 */
  always @*
    case (n2472)
      3'b100: n2478 = 2'b00;
      3'b010: n2478 = 2'b10;
      3'b001: n2478 = 2'b01;
      default: n2478 = rstate;
    endcase
  /*# work/sms-vhdl/compat/voicememory.vhd:87:9 */
  always @*
    case (n2472)
      3'b100: n2479 = n2469;
      3'b010: n2479 = n2421_init_id;
      3'b001: n2479 = n2421_init_id;
      default: n2479 = n2421_init_id;
    endcase
  /*# work/sms-vhdl/compat/voicememory.vhd:101:16 */
  assign n2481 = 6'b100101 - rwaddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:169:17 */
  assign n2488 = n2388[0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:27 */
  assign n2489 = n2388[1]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:20 */
  assign n2490 = {n2488, n2489};
  /*# work/sms-vhdl/compat/vm2413.vhd:169:37 */
  assign n2491 = n2388[2]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:30 */
  assign n2492 = {n2490, n2491};
  /*# work/sms-vhdl/compat/vm2413.vhd:169:47 */
  assign n2493 = n2388[3]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:40 */
  assign n2494 = {n2492, n2493};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:17 */
  assign n2495 = n2388[7:4]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:169:50 */
  assign n2496 = {n2494, n2495};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:27 */
  assign n2497 = n2388[9:8]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:20 */
  assign n2498 = {n2496, n2497};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:37 */
  assign n2499 = n2388[15:10]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:30 */
  assign n2500 = {n2498, n2499};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:47 */
  assign n2501 = n2388[16]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:40 */
  assign n2502 = {n2500, n2501};
  /*# work/sms-vhdl/compat/vm2413.vhd:170:57 */
  assign n2503 = n2388[19:17]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:50 */
  assign n2504 = {n2502, n2503};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:17 */
  assign n2505 = n2388[23:20]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:170:60 */
  assign n2506 = {n2504, n2505};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:27 */
  assign n2507 = n2388[27:24]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:171:20 */
  assign n2508 = {n2506, n2507};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:37 */
  assign n2509 = n2388[31:28]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:171:30 */
  assign n2510 = {n2508, n2509};
  /*# work/sms-vhdl/compat/vm2413.vhd:171:47 */
  assign n2511 = n2388[35:32]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:171:40 */
  assign n2512 = {n2510, n2511};
  /*# work/sms-vhdl/compat/voicememory.vhd:100:7 */
  assign n2514 = wr ? n2924 : voices;
  /*# work/sms-vhdl/compat/voicememory.vhd:85:7 */
  assign n2515 = n2427 ? n2473 : n2514;
  /*# work/sms-vhdl/compat/voicememory.vhd:104:34 */
  assign n2521 = 6'b100101 - rwaddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:177:19 */
  assign n2528 = n2927[35]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:37 */
  assign n2529 = n2927[34]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:55 */
  assign n2530 = n2927[33]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:73 */
  assign n2531 = n2927[32]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:19 */
  assign n2532 = n2927[31:28]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:47 */
  assign n2533 = n2927[27:26]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:75 */
  assign n2534 = n2927[25:20]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:179:19 */
  assign n2535 = n2927[19]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:179:37 */
  assign n2536 = n2927[18:16]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:19 */
  assign n2537 = n2927[15:12]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:47 */
  assign n2538 = n2927[11:8]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:74 */
  assign n2539 = n2927[7:4]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:100 */
  assign n2540 = n2927[3:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:176:12 */
  assign n2541 = {n2540, n2539, n2538, n2537, n2536, n2535, n2534, n2533, n2532, n2531, n2530, n2529, n2528};
  /*# work/sms-vhdl/compat/voicememory.vhd:105:35 */
  assign n2544 = 6'b100101 - roaddr;
  /*# work/sms-vhdl/compat/vm2413.vhd:177:19 */
  assign n2551 = n2930[35]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:37 */
  assign n2552 = n2930[34]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:55 */
  assign n2553 = n2930[33]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:177:73 */
  assign n2554 = n2930[32]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:19 */
  assign n2555 = n2930[31:28]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:47 */
  assign n2556 = n2930[27:26]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:178:75 */
  assign n2557 = n2930[25:20]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:179:19 */
  assign n2558 = n2930[19]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:179:37 */
  assign n2559 = n2930[18:16]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:19 */
  assign n2560 = n2930[15:12]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:47 */
  assign n2561 = n2930[11:8]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:74 */
  assign n2562 = n2930[7:4]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:180:100 */
  assign n2563 = n2930[3:0]; // extract
  /*# work/sms-vhdl/compat/vm2413.vhd:176:12 */
  assign n2564 = {n2563, n2562, n2561, n2560, n2559, n2558, n2557, n2556, n2555, n2554, n2553, n2552, n2551};
  /*# work/sms-vhdl/compat/voicememory.vhd:45:5 */
  assign n2580 = ~reset;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  assign n2581 = n2580 ? n2541 : n2582;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  always @(posedge clk)
    n2582 <= n2581;
  /*# work/sms-vhdl/compat/voicememory.vhd:46:5 */
  assign n2583 = ~reset;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  assign n2584 = n2583 ? n2564 : n2585;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  always @(posedge clk)
    n2585 <= n2584;
  /*# work/sms-vhdl/compat/voicememory.vhd:55:10 */
  assign n2586 = ~reset;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  assign n2587 = n2586 ? n2515 : voices;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  always @(posedge clk)
    n2588 <= n2587;
  /*# work/sms-vhdl/compat/voicememory.vhd:64:10 */
  assign n2589 = ~reset;
  /*# work/sms-vhdl/compat/voicememory.vhd:64:10 */
  assign n2590 = n2427 & n2589;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  assign n2591 = n2590 ? n2474 : rom_addr;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  always @(posedge clk)
    n2592 <= n2591;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  assign n2593 = n2427 ? n2478 : rstate;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2594 <= 2'b00;
    else
      n2594 <= n2593;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  assign n2595 = n2427 ? n2479 : n2421_init_id;
  /*# work/sms-vhdl/compat/voicememory.vhd:83:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2596 <= 6'b000000;
    else
      n2596 <= n2595;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2597 = n2433[5]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2598 = ~n2597;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2599 = n2433[4]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2600 = ~n2599;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2601 = n2598 & n2600;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2602 = n2598 & n2599;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2603 = n2597 & n2600;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2604 = n2433[3]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2605 = ~n2604;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2606 = n2601 & n2605;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2607 = n2601 & n2604;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2608 = n2602 & n2605;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2609 = n2602 & n2604;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2610 = n2603 & n2605;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2611 = n2433[2]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2612 = ~n2611;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2613 = n2606 & n2612;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2614 = n2606 & n2611;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2615 = n2607 & n2612;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2616 = n2607 & n2611;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2617 = n2608 & n2612;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2618 = n2608 & n2611;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2619 = n2609 & n2612;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2620 = n2609 & n2611;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2621 = n2610 & n2612;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2622 = n2610 & n2611;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2623 = n2433[1]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2624 = ~n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2625 = n2613 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2626 = n2613 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2627 = n2614 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2628 = n2614 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2629 = n2615 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2630 = n2615 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2631 = n2616 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2632 = n2616 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2633 = n2617 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2634 = n2617 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2635 = n2618 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2636 = n2618 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2637 = n2619 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2638 = n2619 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2639 = n2620 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2640 = n2620 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2641 = n2621 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2642 = n2621 & n2623;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2643 = n2622 & n2624;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2644 = n2433[0]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2645 = ~n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2646 = n2625 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2647 = n2625 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2648 = n2626 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2649 = n2626 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2650 = n2627 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2651 = n2627 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2652 = n2628 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2653 = n2628 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2654 = n2629 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2655 = n2629 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2656 = n2630 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2657 = n2630 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2658 = n2631 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2659 = n2631 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2660 = n2632 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2661 = n2632 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2662 = n2633 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2663 = n2633 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2664 = n2634 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2665 = n2634 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2666 = n2635 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2667 = n2635 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2668 = n2636 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2669 = n2636 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2670 = n2637 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2671 = n2637 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2672 = n2638 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2673 = n2638 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2674 = n2639 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2675 = n2639 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2676 = n2640 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2677 = n2640 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2678 = n2641 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2679 = n2641 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2680 = n2642 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2681 = n2642 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2682 = n2643 & n2645;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2683 = n2643 & n2644;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2684 = voices[35:0]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2685 = n2646 ? n2464 : n2684;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2686 = voices[71:36]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2687 = n2647 ? n2464 : n2686;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2688 = voices[107:72]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2689 = n2648 ? n2464 : n2688;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2690 = voices[143:108]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2691 = n2649 ? n2464 : n2690;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2692 = voices[179:144]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2693 = n2650 ? n2464 : n2692;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2694 = voices[215:180]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2695 = n2651 ? n2464 : n2694;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2696 = voices[251:216]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2697 = n2652 ? n2464 : n2696;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2698 = voices[287:252]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2699 = n2653 ? n2464 : n2698;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2700 = voices[323:288]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2701 = n2654 ? n2464 : n2700;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2702 = voices[359:324]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2703 = n2655 ? n2464 : n2702;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2704 = voices[395:360]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2705 = n2656 ? n2464 : n2704;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2706 = voices[431:396]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2707 = n2657 ? n2464 : n2706;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2708 = voices[467:432]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2709 = n2658 ? n2464 : n2708;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2710 = voices[503:468]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2711 = n2659 ? n2464 : n2710;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2712 = voices[539:504]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2713 = n2660 ? n2464 : n2712;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2714 = voices[575:540]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2715 = n2661 ? n2464 : n2714;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2716 = voices[611:576]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2717 = n2662 ? n2464 : n2716;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2718 = voices[647:612]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2719 = n2663 ? n2464 : n2718;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2720 = voices[683:648]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2721 = n2664 ? n2464 : n2720;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2722 = voices[719:684]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2723 = n2665 ? n2464 : n2722;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2724 = voices[755:720]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2725 = n2666 ? n2464 : n2724;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2726 = voices[791:756]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2727 = n2667 ? n2464 : n2726;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2728 = voices[827:792]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2729 = n2668 ? n2464 : n2728;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2730 = voices[863:828]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2731 = n2669 ? n2464 : n2730;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2732 = voices[899:864]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2733 = n2670 ? n2464 : n2732;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2734 = voices[935:900]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2735 = n2671 ? n2464 : n2734;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2736 = voices[971:936]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2737 = n2672 ? n2464 : n2736;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2738 = voices[1007:972]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2739 = n2673 ? n2464 : n2738;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2740 = voices[1043:1008]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2741 = n2674 ? n2464 : n2740;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2742 = voices[1079:1044]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2743 = n2675 ? n2464 : n2742;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2744 = voices[1115:1080]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2745 = n2676 ? n2464 : n2744;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2746 = voices[1151:1116]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2747 = n2677 ? n2464 : n2746;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2748 = voices[1187:1152]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2749 = n2678 ? n2464 : n2748;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2750 = voices[1223:1188]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2751 = n2679 ? n2464 : n2750;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2752 = voices[1259:1224]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2753 = n2680 ? n2464 : n2752;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2754 = voices[1295:1260]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2755 = n2681 ? n2464 : n2754;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2756 = voices[1331:1296]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2757 = n2682 ? n2464 : n2756;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2758 = voices[1367:1332]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2759 = n2683 ? n2464 : n2758;
  /*# work/sms-vhdl/compat/voicememory.vhd:94:11 */
  assign n2760 = {n2759, n2757, n2755, n2753, n2751, n2749, n2747, n2745, n2743, n2741, n2739, n2737, n2735, n2733, n2731, n2729, n2727, n2725, n2723, n2721, n2719, n2717, n2715, n2713, n2711, n2709, n2707, n2705, n2703, n2701, n2699, n2697, n2695, n2693, n2691, n2689, n2687, n2685};
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2761 = n2481[5]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2762 = ~n2761;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2763 = n2481[4]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2764 = ~n2763;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2765 = n2762 & n2764;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2766 = n2762 & n2763;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2767 = n2761 & n2764;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2768 = n2481[3]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2769 = ~n2768;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2770 = n2765 & n2769;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2771 = n2765 & n2768;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2772 = n2766 & n2769;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2773 = n2766 & n2768;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2774 = n2767 & n2769;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2775 = n2481[2]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2776 = ~n2775;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2777 = n2770 & n2776;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2778 = n2770 & n2775;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2779 = n2771 & n2776;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2780 = n2771 & n2775;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2781 = n2772 & n2776;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2782 = n2772 & n2775;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2783 = n2773 & n2776;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2784 = n2773 & n2775;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2785 = n2774 & n2776;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2786 = n2774 & n2775;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2787 = n2481[1]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2788 = ~n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2789 = n2777 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2790 = n2777 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2791 = n2778 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2792 = n2778 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2793 = n2779 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2794 = n2779 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2795 = n2780 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2796 = n2780 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2797 = n2781 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2798 = n2781 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2799 = n2782 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2800 = n2782 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2801 = n2783 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2802 = n2783 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2803 = n2784 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2804 = n2784 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2805 = n2785 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2806 = n2785 & n2787;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2807 = n2786 & n2788;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2808 = n2481[0]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2809 = ~n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2810 = n2789 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2811 = n2789 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2812 = n2790 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2813 = n2790 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2814 = n2791 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2815 = n2791 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2816 = n2792 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2817 = n2792 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2818 = n2793 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2819 = n2793 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2820 = n2794 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2821 = n2794 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2822 = n2795 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2823 = n2795 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2824 = n2796 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2825 = n2796 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2826 = n2797 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2827 = n2797 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2828 = n2798 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2829 = n2798 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2830 = n2799 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2831 = n2799 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2832 = n2800 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2833 = n2800 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2834 = n2801 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2835 = n2801 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2836 = n2802 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2837 = n2802 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2838 = n2803 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2839 = n2803 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2840 = n2804 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2841 = n2804 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2842 = n2805 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2843 = n2805 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2844 = n2806 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2845 = n2806 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2846 = n2807 & n2809;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2847 = n2807 & n2808;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2848 = voices[35:0]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2849 = n2810 ? n2512 : n2848;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2850 = voices[71:36]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2851 = n2811 ? n2512 : n2850;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2852 = voices[107:72]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2853 = n2812 ? n2512 : n2852;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2854 = voices[143:108]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2855 = n2813 ? n2512 : n2854;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2856 = voices[179:144]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2857 = n2814 ? n2512 : n2856;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2858 = voices[215:180]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2859 = n2815 ? n2512 : n2858;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2860 = voices[251:216]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2861 = n2816 ? n2512 : n2860;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2862 = voices[287:252]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2863 = n2817 ? n2512 : n2862;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2864 = voices[323:288]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2865 = n2818 ? n2512 : n2864;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2866 = voices[359:324]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2867 = n2819 ? n2512 : n2866;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2868 = voices[395:360]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2869 = n2820 ? n2512 : n2868;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2870 = voices[431:396]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2871 = n2821 ? n2512 : n2870;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2872 = voices[467:432]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2873 = n2822 ? n2512 : n2872;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2874 = voices[503:468]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2875 = n2823 ? n2512 : n2874;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2876 = voices[539:504]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2877 = n2824 ? n2512 : n2876;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2878 = voices[575:540]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2879 = n2825 ? n2512 : n2878;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2880 = voices[611:576]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2881 = n2826 ? n2512 : n2880;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2882 = voices[647:612]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2883 = n2827 ? n2512 : n2882;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2884 = voices[683:648]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2885 = n2828 ? n2512 : n2884;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2886 = voices[719:684]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2887 = n2829 ? n2512 : n2886;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2888 = voices[755:720]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2889 = n2830 ? n2512 : n2888;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2890 = voices[791:756]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2891 = n2831 ? n2512 : n2890;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2892 = voices[827:792]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2893 = n2832 ? n2512 : n2892;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2894 = voices[863:828]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2895 = n2833 ? n2512 : n2894;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2896 = voices[899:864]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2897 = n2834 ? n2512 : n2896;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2898 = voices[935:900]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2899 = n2835 ? n2512 : n2898;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2900 = voices[971:936]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2901 = n2836 ? n2512 : n2900;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2902 = voices[1007:972]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2903 = n2837 ? n2512 : n2902;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2904 = voices[1043:1008]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2905 = n2838 ? n2512 : n2904;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2906 = voices[1079:1044]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2907 = n2839 ? n2512 : n2906;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2908 = voices[1115:1080]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2909 = n2840 ? n2512 : n2908;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2910 = voices[1151:1116]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2911 = n2841 ? n2512 : n2910;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2912 = voices[1187:1152]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2913 = n2842 ? n2512 : n2912;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2914 = voices[1223:1188]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2915 = n2843 ? n2512 : n2914;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2916 = voices[1259:1224]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2917 = n2844 ? n2512 : n2916;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2918 = voices[1295:1260]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2919 = n2845 ? n2512 : n2918;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2920 = voices[1331:1296]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2921 = n2846 ? n2512 : n2920;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2922 = voices[1367:1332]; // extract
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2923 = n2847 ? n2512 : n2922;
  /*# work/sms-vhdl/compat/voicememory.vhd:101:9 */
  assign n2924 = {n2923, n2921, n2919, n2917, n2915, n2913, n2911, n2909, n2907, n2905, n2903, n2901, n2899, n2897, n2895, n2893, n2891, n2889, n2887, n2885, n2883, n2881, n2879, n2877, n2875, n2873, n2871, n2869, n2867, n2865, n2863, n2861, n2859, n2857, n2855, n2853, n2851, n2849};
  /*# work/sms-vhdl/compat/voicememory.vhd:104:34 */
  assign n2926 = {936'bX, voices};
  /*# work/sms-vhdl/compat/voicememory.vhd:104:34 */
  assign n2927 = n2926[n2521 * 36 +: 36]; //(Bmux)
  /*# work/sms-vhdl/compat/voicememory.vhd:105:35 */
  assign n2929 = {936'bX, voices};
  /*# work/sms-vhdl/compat/voicememory.vhd:105:35 */
  assign n2930 = n2929[n2544 * 36 +: 36]; //(Bmux)
endmodule

module registermemory_Brtl
  (input  clk,
   input  reset,
   input  [3:0] addr,
   input  wr,
   input  [23:0] idata,
   output [23:0] odata);
  (* ramstyle="logic" *) wire [215:0] regs_array;
  reg [3:0] n2252_init_state;
  wire [31:0] n2256;
  wire n2258;
  wire [3:0] n2260;
  wire [31:0] n2264;
  wire [31:0] n2266;
  wire [3:0] n2267;
  wire [3:0] n2270;
  wire [215:0] n2273;
  wire [215:0] n2274;
  wire [3:0] n2278;
  wire n2289;
  wire [23:0] n2290;
  reg [23:0] n2291;
  wire n2292;
  wire [215:0] n2293;
  reg [215:0] n2294;
  wire [3:0] n2295;
  reg [3:0] n2296;
  wire n2297;
  wire n2298;
  wire n2299;
  wire n2300;
  wire n2301;
  wire n2302;
  wire n2303;
  wire n2304;
  wire n2305;
  wire n2306;
  wire n2307;
  wire n2308;
  wire n2309;
  wire n2310;
  wire n2311;
  wire n2312;
  wire n2313;
  wire n2314;
  wire n2315;
  wire n2316;
  wire n2317;
  wire n2318;
  wire n2319;
  wire n2320;
  wire n2321;
  wire [23:0] n2322;
  wire [23:0] n2323;
  wire [23:0] n2324;
  wire [23:0] n2325;
  wire [23:0] n2326;
  wire [23:0] n2327;
  wire [23:0] n2328;
  wire [23:0] n2329;
  wire [23:0] n2330;
  wire [23:0] n2331;
  wire [23:0] n2332;
  wire [23:0] n2333;
  wire [23:0] n2334;
  wire [23:0] n2335;
  wire [23:0] n2336;
  wire [23:0] n2337;
  wire [23:0] n2338;
  wire [23:0] n2339;
  wire [215:0] n2340;
  wire n2341;
  wire n2342;
  wire n2343;
  wire n2344;
  wire n2345;
  wire n2346;
  wire n2347;
  wire n2348;
  wire n2349;
  wire n2350;
  wire n2351;
  wire n2352;
  wire n2353;
  wire n2354;
  wire n2355;
  wire n2356;
  wire n2357;
  wire n2358;
  wire n2359;
  wire n2360;
  wire n2361;
  wire n2362;
  wire n2363;
  wire n2364;
  wire n2365;
  wire [23:0] n2366;
  wire [23:0] n2367;
  wire [23:0] n2368;
  wire [23:0] n2369;
  wire [23:0] n2370;
  wire [23:0] n2371;
  wire [23:0] n2372;
  wire [23:0] n2373;
  wire [23:0] n2374;
  wire [23:0] n2375;
  wire [23:0] n2376;
  wire [23:0] n2377;
  wire [23:0] n2378;
  wire [23:0] n2379;
  wire [23:0] n2380;
  wire [23:0] n2381;
  wire [23:0] n2382;
  wire [23:0] n2383;
  wire [215:0] n2384;
  wire [383:0] n2386;
  wire [23:0] n2387;
  assign odata = n2291; //(module output)
  /*# work/sms-vhdl/compat/registermemory.vhd:54:12 */
  assign regs_array = n2294; // (signal)
  /*# work/sms-vhdl/compat/registermemory.vhd:60:18 */
  always @*
    n2252_init_state = n2296; // (isignal)
  initial
    n2252_init_state = 4'b0000;
  /*# work/sms-vhdl/compat/registermemory.vhd:65:28 */
  assign n2256 = {28'b0, n2252_init_state};  // uext
  /*# work/sms-vhdl/compat/registermemory.vhd:65:28 */
  assign n2258 = n2256 != 32'b00000000000000000000000000001001;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:29 */
  assign n2260 = 4'b1000 - n2252_init_state;
  /*# work/sms-vhdl/compat/registermemory.vhd:68:42 */
  assign n2264 = {28'b0, n2252_init_state};  // uext
  /*# work/sms-vhdl/compat/registermemory.vhd:68:42 */
  assign n2266 = n2264 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/registermemory.vhd:68:17 */
  assign n2267 = n2266[3:0];  // trunc
  /*# work/sms-vhdl/compat/registermemory.vhd:71:29 */
  assign n2270 = 4'b1000 - addr;
  /*# work/sms-vhdl/compat/registermemory.vhd:69:13 */
  assign n2273 = wr ? n2384 : regs_array;
  /*# work/sms-vhdl/compat/registermemory.vhd:65:13 */
  assign n2274 = n2258 ? n2340 : n2273;
  /*# work/sms-vhdl/compat/registermemory.vhd:74:34 */
  assign n2278 = 4'b1000 - addr;
  /*# work/sms-vhdl/compat/registermemory.vhd:47:9 */
  assign n2289 = ~reset;
  /*# work/sms-vhdl/compat/registermemory.vhd:64:9 */
  assign n2290 = n2289 ? n2387 : n2291;
  /*# work/sms-vhdl/compat/registermemory.vhd:64:9 */
  always @(posedge clk)
    n2291 <= n2290;
  /*# work/sms-vhdl/compat/registermemory.vhd:54:12 */
  assign n2292 = ~reset;
  /*# work/sms-vhdl/compat/registermemory.vhd:64:9 */
  assign n2293 = n2292 ? n2274 : regs_array;
  /*# work/sms-vhdl/compat/registermemory.vhd:64:9 */
  always @(posedge clk)
    n2294 <= n2293;
  /*# work/sms-vhdl/compat/registermemory.vhd:64:9 */
  assign n2295 = n2258 ? n2267 : n2252_init_state;
  /*# work/sms-vhdl/compat/registermemory.vhd:64:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2296 <= 4'b0000;
    else
      n2296 <= n2295;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2297 = n2260[3]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2298 = ~n2297;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2299 = n2260[2]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2300 = ~n2299;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2301 = n2298 & n2300;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2302 = n2298 & n2299;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2303 = n2297 & n2300;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2304 = n2260[1]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2305 = ~n2304;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2306 = n2301 & n2305;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2307 = n2301 & n2304;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2308 = n2302 & n2305;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2309 = n2302 & n2304;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2310 = n2303 & n2305;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2311 = n2260[0]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2312 = ~n2311;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2313 = n2306 & n2312;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2314 = n2306 & n2311;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2315 = n2307 & n2312;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2316 = n2307 & n2311;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2317 = n2308 & n2312;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2318 = n2308 & n2311;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2319 = n2309 & n2312;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2320 = n2309 & n2311;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2321 = n2310 & n2312;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2322 = regs_array[23:0]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2323 = n2313 ? 24'b000000000000000000000000 : n2322;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2324 = regs_array[47:24]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2325 = n2314 ? 24'b000000000000000000000000 : n2324;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2326 = regs_array[71:48]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2327 = n2315 ? 24'b000000000000000000000000 : n2326;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2328 = regs_array[95:72]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2329 = n2316 ? 24'b000000000000000000000000 : n2328;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2330 = regs_array[119:96]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2331 = n2317 ? 24'b000000000000000000000000 : n2330;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2332 = regs_array[143:120]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2333 = n2318 ? 24'b000000000000000000000000 : n2332;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2334 = regs_array[167:144]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2335 = n2319 ? 24'b000000000000000000000000 : n2334;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2336 = regs_array[191:168]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2337 = n2320 ? 24'b000000000000000000000000 : n2336;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2338 = regs_array[215:192]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2339 = n2321 ? 24'b000000000000000000000000 : n2338;
  /*# work/sms-vhdl/compat/registermemory.vhd:67:17 */
  assign n2340 = {n2339, n2337, n2335, n2333, n2331, n2329, n2327, n2325, n2323};
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2341 = n2270[3]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2342 = ~n2341;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2343 = n2270[2]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2344 = ~n2343;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2345 = n2342 & n2344;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2346 = n2342 & n2343;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2347 = n2341 & n2344;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2348 = n2270[1]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2349 = ~n2348;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2350 = n2345 & n2349;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2351 = n2345 & n2348;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2352 = n2346 & n2349;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2353 = n2346 & n2348;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2354 = n2347 & n2349;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2355 = n2270[0]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2356 = ~n2355;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2357 = n2350 & n2356;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2358 = n2350 & n2355;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2359 = n2351 & n2356;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2360 = n2351 & n2355;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2361 = n2352 & n2356;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2362 = n2352 & n2355;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2363 = n2353 & n2356;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2364 = n2353 & n2355;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2365 = n2354 & n2356;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2366 = regs_array[23:0]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2367 = n2357 ? idata : n2366;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2368 = regs_array[47:24]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2369 = n2358 ? idata : n2368;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2370 = regs_array[71:48]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2371 = n2359 ? idata : n2370;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2372 = regs_array[95:72]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2373 = n2360 ? idata : n2372;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2374 = regs_array[119:96]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2375 = n2361 ? idata : n2374;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2376 = regs_array[143:120]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2377 = n2362 ? idata : n2376;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2378 = regs_array[167:144]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2379 = n2363 ? idata : n2378;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2380 = regs_array[191:168]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2381 = n2364 ? idata : n2380;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2382 = regs_array[215:192]; // extract
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2383 = n2365 ? idata : n2382;
  /*# work/sms-vhdl/compat/registermemory.vhd:71:17 */
  assign n2384 = {n2383, n2381, n2379, n2377, n2375, n2373, n2371, n2369, n2367};
  /*# work/sms-vhdl/compat/registermemory.vhd:74:34 */
  assign n2386 = {168'bX, regs_array};
  /*# work/sms-vhdl/compat/registermemory.vhd:74:34 */
  assign n2387 = n2386[n2278 * 24 +: 24]; //(Bmux)
endmodule

module temporalmixer_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   output [4:0] maddr,
   input  \mdata[sign] ,
   input  [8:0] \mdata[value] ,
   output [13:0] mixout);
  wire [9:0] n2049;
  wire mute;
  wire [13:0] mix;
  wire [31:0] n2054;
  wire n2056;
  wire n2057;
  wire n2059;
  wire n2061;
  wire n2063;
  wire n2065;
  wire n2067;
  wire n2069;
  wire n2071;
  wire n2073;
  wire n2075;
  wire n2077;
  wire n2079;
  wire n2081;
  wire n2083;
  wire n2085;
  wire n2087;
  wire n2089;
  wire n2091;
  wire n2093;
  wire [17:0] n2094;
  reg [4:0] n2104;
  reg n2124;
  wire n2126;
  wire n2128;
  wire n2130;
  wire n2132;
  wire n2134;
  wire n2136;
  wire n2138;
  wire n2140;
  wire n2142;
  wire n2144;
  wire n2146;
  wire n2148;
  wire n2150;
  wire n2152;
  wire n2154;
  wire n2156;
  wire n2158;
  wire n2160;
  wire [17:0] n2161;
  reg [4:0] n2178;
  reg n2198;
  wire [4:0] n2199;
  wire n2200;
  wire [31:0] n2201;
  wire n2203;
  wire n2205;
  wire n2206;
  wire n2207;
  wire n2208;
  wire [8:0] n2209;
  wire [13:0] n2210;
  wire [13:0] n2211;
  wire [8:0] n2212;
  wire [13:0] n2213;
  wire [13:0] n2214;
  wire [13:0] n2215;
  wire [13:0] n2216;
  wire [13:0] n2217;
  wire [13:0] n2219;
  wire n2220;
  wire [13:0] n2221;
  wire [13:0] n2223;
  wire [13:0] n2225;
  wire n2226;
  wire n2228;
  wire [4:0] n2243;
  reg [4:0] n2244;
  wire [13:0] n2245;
  reg [13:0] n2246;
  wire n2247;
  reg n2248;
  wire [13:0] n2249;
  reg [13:0] n2250;
  assign maddr = n2244; //(module output)
  assign mixout = n2246; //(module output)
  /*# work/sms-vhdl/compat/temporalmixer.vhd:37:8 */
  assign n2049 = {\mdata[value] , \mdata[sign] };
  /*# work/sms-vhdl/compat/temporalmixer.vhd:57:10 */
  assign mute = n2248; // (signal)
  /*# work/sms-vhdl/compat/temporalmixer.vhd:58:10 */
  assign mix = n2250; // (signal)
  /*# work/sms-vhdl/compat/temporalmixer.vhd:74:16 */
  assign n2054 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/temporalmixer.vhd:74:16 */
  assign n2056 = n2054 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:76:19 */
  assign n2057 = ~rhythm;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:79:13 */
  assign n2059 = slot == 5'b00000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:80:13 */
  assign n2061 = slot == 5'b00001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:81:13 */
  assign n2063 = slot == 5'b00010;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:82:13 */
  assign n2065 = slot == 5'b00011;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:83:13 */
  assign n2067 = slot == 5'b00100;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:84:13 */
  assign n2069 = slot == 5'b00101;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:85:13 */
  assign n2071 = slot == 5'b00110;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:86:13 */
  assign n2073 = slot == 5'b00111;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:87:13 */
  assign n2075 = slot == 5'b01000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:88:13 */
  assign n2077 = slot == 5'b01001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:89:13 */
  assign n2079 = slot == 5'b01010;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:90:13 */
  assign n2081 = slot == 5'b01011;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:91:13 */
  assign n2083 = slot == 5'b01100;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:92:13 */
  assign n2085 = slot == 5'b01101;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:93:13 */
  assign n2087 = slot == 5'b01110;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:94:13 */
  assign n2089 = slot == 5'b01111;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:95:13 */
  assign n2091 = slot == 5'b10000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:96:13 */
  assign n2093 = slot == 5'b10001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:78:11 */
  assign n2094 = {n2093, n2091, n2089, n2087, n2085, n2083, n2081, n2079, n2077, n2075, n2073, n2071, n2069, n2067, n2065, n2063, n2061, n2059};
  /*# work/sms-vhdl/compat/temporalmixer.vhd:78:11 */
  always @*
    case (n2094)
      18'b100000000000000000: n2104 = n2244;
      18'b010000000000000000: n2104 = n2244;
      18'b001000000000000000: n2104 = n2244;
      18'b000100000000000000: n2104 = 5'b10001;
      18'b000010000000000000: n2104 = 5'b01111;
      18'b000001000000000000: n2104 = 5'b01101;
      18'b000000100000000000: n2104 = n2244;
      18'b000000010000000000: n2104 = n2244;
      18'b000000001000000000: n2104 = n2244;
      18'b000000000100000000: n2104 = 5'b01011;
      18'b000000000010000000: n2104 = 5'b01001;
      18'b000000000001000000: n2104 = 5'b00111;
      18'b000000000000100000: n2104 = n2244;
      18'b000000000000010000: n2104 = n2244;
      18'b000000000000001000: n2104 = n2244;
      18'b000000000000000100: n2104 = 5'b00101;
      18'b000000000000000010: n2104 = 5'b00011;
      18'b000000000000000001: n2104 = 5'b00001;
      default: n2104 = n2244;
    endcase
  /*# work/sms-vhdl/compat/temporalmixer.vhd:78:11 */
  always @*
    case (n2094)
      18'b100000000000000000: n2124 = 1'b1;
      18'b010000000000000000: n2124 = 1'b1;
      18'b001000000000000000: n2124 = 1'b1;
      18'b000100000000000000: n2124 = 1'b0;
      18'b000010000000000000: n2124 = 1'b0;
      18'b000001000000000000: n2124 = 1'b0;
      18'b000000100000000000: n2124 = 1'b1;
      18'b000000010000000000: n2124 = 1'b1;
      18'b000000001000000000: n2124 = 1'b1;
      18'b000000000100000000: n2124 = 1'b0;
      18'b000000000010000000: n2124 = 1'b0;
      18'b000000000001000000: n2124 = 1'b0;
      18'b000000000000100000: n2124 = 1'b1;
      18'b000000000000010000: n2124 = 1'b1;
      18'b000000000000001000: n2124 = 1'b1;
      18'b000000000000000100: n2124 = 1'b0;
      18'b000000000000000010: n2124 = 1'b0;
      18'b000000000000000001: n2124 = 1'b0;
      default: n2124 = 1'b1;
    endcase
  /*# work/sms-vhdl/compat/temporalmixer.vhd:103:13 */
  assign n2126 = slot == 5'b00000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:104:13 */
  assign n2128 = slot == 5'b00001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:105:13 */
  assign n2130 = slot == 5'b00010;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:106:13 */
  assign n2132 = slot == 5'b00011;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:107:13 */
  assign n2134 = slot == 5'b00100;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:108:13 */
  assign n2136 = slot == 5'b00101;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:109:13 */
  assign n2138 = slot == 5'b00110;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:110:13 */
  assign n2140 = slot == 5'b00111;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:111:13 */
  assign n2142 = slot == 5'b01000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:112:13 */
  assign n2144 = slot == 5'b01001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:113:13 */
  assign n2146 = slot == 5'b01010;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:114:13 */
  assign n2148 = slot == 5'b01011;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:115:13 */
  assign n2150 = slot == 5'b01100;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:116:13 */
  assign n2152 = slot == 5'b01101;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:117:13 */
  assign n2154 = slot == 5'b01110;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:118:13 */
  assign n2156 = slot == 5'b01111;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:119:13 */
  assign n2158 = slot == 5'b10000;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:120:13 */
  assign n2160 = slot == 5'b10001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:102:11 */
  assign n2161 = {n2160, n2158, n2156, n2154, n2152, n2150, n2148, n2146, n2144, n2142, n2140, n2138, n2136, n2134, n2132, n2130, n2128, n2126};
  /*# work/sms-vhdl/compat/temporalmixer.vhd:102:11 */
  always @*
    case (n2161)
      18'b100000000000000000: n2178 = n2244;
      18'b010000000000000000: n2178 = 5'b01101;
      18'b001000000000000000: n2178 = 5'b10000;
      18'b000100000000000000: n2178 = 5'b01110;
      18'b000010000000000000: n2178 = 5'b10001;
      18'b000001000000000000: n2178 = 5'b01111;
      18'b000000100000000000: n2178 = 5'b01101;
      18'b000000010000000000: n2178 = 5'b10000;
      18'b000000001000000000: n2178 = 5'b01110;
      18'b000000000100000000: n2178 = 5'b01011;
      18'b000000000010000000: n2178 = 5'b01001;
      18'b000000000001000000: n2178 = 5'b00111;
      18'b000000000000100000: n2178 = n2244;
      18'b000000000000010000: n2178 = 5'b10001;
      18'b000000000000001000: n2178 = 5'b01111;
      18'b000000000000000100: n2178 = 5'b00101;
      18'b000000000000000010: n2178 = 5'b00011;
      18'b000000000000000001: n2178 = 5'b00001;
      default: n2178 = n2244;
    endcase
  /*# work/sms-vhdl/compat/temporalmixer.vhd:102:11 */
  always @*
    case (n2161)
      18'b100000000000000000: n2198 = 1'b1;
      18'b010000000000000000: n2198 = 1'b0;
      18'b001000000000000000: n2198 = 1'b0;
      18'b000100000000000000: n2198 = 1'b0;
      18'b000010000000000000: n2198 = 1'b0;
      18'b000001000000000000: n2198 = 1'b0;
      18'b000000100000000000: n2198 = 1'b0;
      18'b000000010000000000: n2198 = 1'b0;
      18'b000000001000000000: n2198 = 1'b0;
      18'b000000000100000000: n2198 = 1'b0;
      18'b000000000010000000: n2198 = 1'b0;
      18'b000000000001000000: n2198 = 1'b0;
      18'b000000000000100000: n2198 = 1'b1;
      18'b000000000000010000: n2198 = 1'b0;
      18'b000000000000001000: n2198 = 1'b0;
      18'b000000000000000100: n2198 = 1'b0;
      18'b000000000000000010: n2198 = 1'b0;
      18'b000000000000000001: n2198 = 1'b0;
      default: n2198 = 1'b1;
    endcase
  /*# work/sms-vhdl/compat/temporalmixer.vhd:76:9 */
  assign n2199 = n2057 ? n2104 : n2178;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:76:9 */
  assign n2200 = n2057 ? n2124 : n2198;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:127:34 */
  assign n2201 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/temporalmixer.vhd:127:34 */
  assign n2203 = n2201 == 32'b00000000000000000000000000000010;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:128:41 */
  assign n2205 = slot == 5'b10001;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:132:49 */
  assign n2206 = ~mute;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:133:59 */
  assign n2207 = n2049[0]; // extract
  /*# work/sms-vhdl/compat/temporalmixer.vhd:133:64 */
  assign n2208 = ~n2207;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:134:76 */
  assign n2209 = n2049[9:1]; // extract
  /*# work/sms-vhdl/compat/temporalmixer.vhd:134:68 */
  assign n2210 = {5'b0, n2209};  // uext
  /*# work/sms-vhdl/compat/temporalmixer.vhd:134:68 */
  assign n2211 = mix + n2210;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:136:76 */
  assign n2212 = n2049[9:1]; // extract
  /*# work/sms-vhdl/compat/temporalmixer.vhd:136:68 */
  assign n2213 = {5'b0, n2212};  // uext
  /*# work/sms-vhdl/compat/temporalmixer.vhd:136:68 */
  assign n2214 = mix - n2213;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:133:50 */
  assign n2215 = n2208 ? n2211 : n2214;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:132:41 */
  assign n2216 = n2206 ? n2215 : mix;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:127:25 */
  assign n2217 = n2220 ? mix : n2246;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:128:33 */
  assign n2219 = n2205 ? 14'b00000000000000 : n2216;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:127:25 */
  assign n2220 = n2205 & n2203;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:127:25 */
  assign n2221 = n2203 ? n2219 : mix;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:74:7 */
  assign n2223 = n2056 ? n2246 : n2217;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:74:7 */
  assign n2225 = n2056 ? mix : n2221;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:33 */
  assign n2226 = n2056 & clkena;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:33 */
  assign n2228 = n2056 & clkena;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  assign n2243 = n2226 ? n2199 : n2244;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2244 <= 5'b00000;
    else
      n2244 <= n2243;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  assign n2245 = clkena ? n2223 : n2246;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2246 <= 14'b00000000000000;
    else
      n2246 <= n2245;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  assign n2247 = n2228 ? n2200 : mute;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2248 <= 1'b1;
    else
      n2248 <= n2247;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  assign n2249 = clkena ? n2225 : mix;
  /*# work/sms-vhdl/compat/temporalmixer.vhd:72:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2250 <= 14'b00000000000000;
    else
      n2250 <= n2249;
endmodule

module outputgenerator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  [13:0] opout,
   input  [3:0] faddr,
   output \fdata[sign] ,
   output [8:0] \fdata[value] ,
   input  [4:0] maddr,
   output \mdata[sign] ,
   output [8:0] \mdata[value] );
  wire n1884;
  wire [8:0] n1885;
  wire n1887;
  wire [8:0] n1888;
  wire fb_wr;
  wire mo_wr;
  wire [3:0] fb_addr;
  wire [4:0] mo_addr;
  wire [9:0] li_data;
  wire [9:0] fb_wdata;
  wire [9:0] mo_wdata;
  wire [9:0] mo_rdata;
  wire [9:0] fmem_n1889;
  wire \fmem.rdata[sign] ;
  wire [8:0] \fmem.rdata[value] ;
  wire n1890;
  wire [8:0] n1891;
  wire [9:0] n1892;
  wire [9:0] mmem_n1895;
  wire [9:0] mmem_n1896;
  wire \mmem.rdata[sign] ;
  wire [8:0] \mmem.rdata[value] ;
  wire \mmem.rdata2[sign] ;
  wire [8:0] \mmem.rdata2[value] ;
  wire n1897;
  wire [8:0] n1898;
  wire [9:0] n1899;
  wire [9:0] n1901;
  wire [9:0] ltbl_n1905;
  wire \ltbl.data[sign] ;
  wire [8:0] \ltbl.data[value] ;
  wire [9:0] n1906;
  wire [31:0] n1912;
  wire n1914;
  wire [31:0] n1915;
  wire n1917;
  wire [31:0] n1918;
  wire n1920;
  wire [31:0] n1921;
  wire n1923;
  wire n1924;
  wire n1925;
  wire [31:0] n1926;
  wire [31:0] n1928;
  wire [3:0] n1929;
  wire n1937;
  wire n1938;
  wire [8:0] n1939;
  wire [10:0] n1941;
  wire [8:0] n1942;
  wire [10:0] n1944;
  wire [10:0] n1945;
  wire [10:0] n1948;
  wire [10:0] n1949;
  wire n1951;
  wire n1952;
  wire [8:0] n1953;
  wire [10:0] n1955;
  wire [8:0] n1956;
  wire [10:0] n1958;
  wire [10:0] n1959;
  wire [10:0] n1962;
  wire [10:0] n1963;
  wire [10:0] n1965;
  wire n1966;
  wire n1967;
  wire [8:0] n1968;
  wire [9:0] n1970;
  wire [10:0] n1973;
  wire [10:0] n1974;
  wire [8:0] n1975;
  wire [9:0] n1977;
  wire [9:0] n1978;
  wire n1981;
  wire [3:0] n1982;
  wire [9:0] n1983;
  wire n1984;
  wire n1986;
  wire n1987;
  wire n1988;
  wire [9:0] n1989;
  wire n1990;
  wire n1991;
  wire [3:0] n1992;
  wire [9:0] n1993;
  wire [9:0] n1994;
  wire n1995;
  wire n1996;
  wire [3:0] n1997;
  wire [9:0] n1998;
  wire [9:0] n1999;
  wire n2001;
  wire n2003;
  wire [3:0] n2004;
  wire [9:0] n2005;
  wire [9:0] n2006;
  wire n2028;
  reg n2029;
  wire n2030;
  reg n2031;
  wire n2032;
  wire n2033;
  wire [3:0] n2034;
  reg [3:0] n2035;
  wire n2036;
  wire n2037;
  wire [4:0] n2038;
  reg [4:0] n2039;
  wire n2040;
  wire n2041;
  wire [9:0] n2042;
  reg [9:0] n2043;
  wire n2044;
  wire n2045;
  wire [9:0] n2046;
  reg [9:0] n2047;
  assign \fdata[sign]  = n1884; //(module output)
  assign \fdata[value]  = n1885; //(module output)
  assign \mdata[sign]  = n1887; //(module output)
  assign \mdata[value]  = n1888; //(module output)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:36:8 */
  assign n1884 = fmem_n1889[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:36:8 */
  assign n1885 = fmem_n1889[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:36:8 */
  assign n1887 = mmem_n1896[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:36:8 */
  assign n1888 = mmem_n1896[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:119:12 */
  assign fb_wr = n2029; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:119:19 */
  assign mo_wr = n2031; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:120:12 */
  assign fb_addr = n2035; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:121:12 */
  assign mo_addr = n2039; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:12 */
  assign li_data = ltbl_n1905; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:21 */
  assign fb_wdata = n2043; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:31 */
  assign mo_wdata = n2047; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:41 */
  assign mo_rdata = mmem_n1895; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:132:20 */
  assign fmem_n1889 = n1892; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:125:5 */
  feedbackmemory_Brtl fmem (
    .clk(clk),
    .reset(reset),
    .wr(fb_wr),
    .waddr(fb_addr),
    .\wdata[sign] (n1890),
    .\wdata[value] (n1891),
    .raddr(faddr),
    .\rdata[sign] (\fmem.rdata[sign] ),
    .\rdata[value] (\fmem.rdata[value] ));
  /*# work/sms-vhdl/compat/outputgenerator.vhd:125:5 */
  assign n1890 = fb_wdata[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:125:5 */
  assign n1891 = fb_wdata[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:125:5 */
  assign n1892 = {\fmem.rdata[value] , \fmem.rdata[sign] };
  /*# work/sms-vhdl/compat/outputgenerator.vhd:141:20 */
  assign mmem_n1895 = n1899; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:143:20 */
  assign mmem_n1896 = n1901; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:135:5 */
  outputmemory_Brtl mmem (
    .clk(clk),
    .reset(reset),
    .wr(mo_wr),
    .addr(mo_addr),
    .\wdata[sign] (n1897),
    .\wdata[value] (n1898),
    .addr2(maddr),
    .\rdata[sign] (\mmem.rdata[sign] ),
    .\rdata[value] (\mmem.rdata[value] ),
    .\rdata2[sign] (\mmem.rdata2[sign] ),
    .\rdata2[value] (\mmem.rdata2[value] ));
  /*# work/sms-vhdl/compat/outputgenerator.vhd:135:5 */
  assign n1897 = mo_wdata[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:135:5 */
  assign n1898 = mo_wdata[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:135:5 */
  assign n1899 = {\mmem.rdata[value] , \mmem.rdata[sign] };
  /*# work/sms-vhdl/compat/outputgenerator.vhd:135:5 */
  assign n1901 = {\mmem.rdata2[value] , \mmem.rdata2[sign] };
  /*# work/sms-vhdl/compat/outputgenerator.vhd:150:20 */
  assign ltbl_n1905 = n1906; // (signal)
  /*# work/sms-vhdl/compat/outputgenerator.vhd:146:5 */
  lineartable_Brtl ltbl (
    .clk(clk),
    .reset(reset),
    .addr(opout),
    .\data[sign] (\ltbl.data[sign] ),
    .\data[value] (\ltbl.data[value] ));
  /*# work/sms-vhdl/compat/outputgenerator.vhd:146:5 */
  assign n1906 = {\ltbl.data[value] , \ltbl.data[sign] };
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:27 */
  assign n1912 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:27 */
  assign n1914 = n1912 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:30 */
  assign n1915 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:30 */
  assign n1917 = n1915 == 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:30 */
  assign n1918 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:30 */
  assign n1920 = n1918 == 32'b00000000000000000000000000000010;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:30 */
  assign n1921 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:30 */
  assign n1923 = n1921 == 32'b00000000000000000000000000000011;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:172:29 */
  assign n1924 = slot[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:172:33 */
  assign n1925 = ~n1924;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:174:36 */
  assign n1926 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/outputgenerator.vhd:174:54 */
  assign n1928 = $signed(n1926) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/outputgenerator.vhd:174:36 */
  assign n1929 = n1928[3:0];  // trunc
  /*# work/sms-vhdl/compat/outputgenerator.vhd:96:15 */
  assign n1937 = mo_rdata[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:96:20 */
  assign n1938 = ~n1937;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:97:28 */
  assign n1939 = mo_rdata[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:97:24 */
  assign n1941 = {2'b00, n1939};
  /*# work/sms-vhdl/compat/outputgenerator.vhd:99:34 */
  assign n1942 = mo_rdata[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:99:30 */
  assign n1944 = {2'b00, n1942};
  /*# work/sms-vhdl/compat/outputgenerator.vhd:99:19 */
  assign n1945 = ~n1944;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:99:42 */
  assign n1948 = n1945 + 11'b00000000001;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:96:9 */
  assign n1949 = n1938 ? n1941 : n1948;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:101:15 */
  assign n1951 = li_data[0]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:101:20 */
  assign n1952 = ~n1951;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:102:28 */
  assign n1953 = li_data[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:102:24 */
  assign n1955 = {2'b00, n1953};
  /*# work/sms-vhdl/compat/outputgenerator.vhd:104:34 */
  assign n1956 = li_data[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:104:30 */
  assign n1958 = {2'b00, n1956};
  /*# work/sms-vhdl/compat/outputgenerator.vhd:104:19 */
  assign n1959 = ~n1958;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:104:42 */
  assign n1962 = n1959 + 11'b00000000001;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:101:9 */
  assign n1963 = n1952 ? n1955 : n1962;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:107:18 */
  assign n1965 = n1949 + n1963;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:110:14 */
  assign n1966 = n1965[10]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:110:24 */
  assign n1967 = ~n1966;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:111:46 */
  assign n1968 = n1965[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:111:20 */
  assign n1970 = {n1968, 1'b0};
  /*# work/sms-vhdl/compat/outputgenerator.vhd:113:28 */
  assign n1973 = n1965 - 11'b00000000001;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:113:19 */
  assign n1974 = ~n1973;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:114:46 */
  assign n1975 = n1974[9:1]; // extract
  /*# work/sms-vhdl/compat/outputgenerator.vhd:114:20 */
  assign n1977 = {n1975, 1'b1};
  /*# work/sms-vhdl/compat/outputgenerator.vhd:110:9 */
  assign n1978 = n1967 ? n1970 : n1977;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1981 = n1984 ? 1'b1 : fb_wr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1982 = n1987 ? n1929 : fb_addr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1983 = n1988 ? n1978 : fb_wdata;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1984 = n1925 & n1923;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1986 = n1923 ? 1'b1 : mo_wr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1987 = n1925 & n1923;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1988 = n1925 & n1923;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:170:17 */
  assign n1989 = n1923 ? li_data : mo_wdata;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:17 */
  assign n1990 = n1920 ? fb_wr : n1981;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:17 */
  assign n1991 = n1920 ? mo_wr : n1986;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:17 */
  assign n1992 = n1920 ? fb_addr : n1982;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:17 */
  assign n1993 = n1920 ? fb_wdata : n1983;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:168:17 */
  assign n1994 = n1920 ? mo_wdata : n1989;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:17 */
  assign n1995 = n1917 ? fb_wr : n1990;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:17 */
  assign n1996 = n1917 ? mo_wr : n1991;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:17 */
  assign n1997 = n1917 ? fb_addr : n1992;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:17 */
  assign n1998 = n1917 ? fb_wdata : n1993;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:166:17 */
  assign n1999 = n1917 ? mo_wdata : n1994;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:17 */
  assign n2001 = n1914 ? 1'b0 : n1995;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:17 */
  assign n2003 = n1914 ? 1'b0 : n1996;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:17 */
  assign n2004 = n1914 ? fb_addr : n1997;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:17 */
  assign n2005 = n1914 ? fb_wdata : n1998;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:162:17 */
  assign n2006 = n1914 ? mo_wdata : n1999;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  assign n2028 = clkena ? n2001 : fb_wr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2029 <= 1'b0;
    else
      n2029 <= n2028;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  assign n2030 = clkena ? n2003 : mo_wr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n2031 <= 1'b0;
    else
      n2031 <= n2030;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:120:12 */
  assign n2032 = ~reset;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:120:12 */
  assign n2033 = clkena & n2032;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  assign n2034 = n2033 ? n2004 : fb_addr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  always @(posedge clk)
    n2035 <= n2034;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:121:12 */
  assign n2036 = ~reset;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:121:12 */
  assign n2037 = clkena & n2036;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  assign n2038 = n2037 ? slot : mo_addr;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  always @(posedge clk)
    n2039 <= n2038;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:21 */
  assign n2040 = ~reset;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:21 */
  assign n2041 = clkena & n2040;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  assign n2042 = n2041 ? n2005 : fb_wdata;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  always @(posedge clk)
    n2043 <= n2042;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:31 */
  assign n2044 = ~reset;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:122:31 */
  assign n2045 = clkena & n2044;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  assign n2046 = n2045 ? n2006 : mo_wdata;
  /*# work/sms-vhdl/compat/outputgenerator.vhd:158:9 */
  always @(posedge clk)
    n2047 <= n2046;
endmodule

module operator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  wf,
   input  [2:0] fb,
   input  noise,
   input  [17:0] pgout,
   input  [12:0] egout,
   output [3:0] faddr,
   input  \fdata[sign] ,
   input  [8:0] \fdata[value] ,
   output [13:0] opout);
  wire [9:0] n1732;
  wire [17:0] addr;
  wire [13:0] data;
  wire w_is_carrier;
  wire [19:0] w_modula_m;
  wire [19:0] w_modula_c;
  wire [19:0] w_modula;
  wire [12:0] ff_egout;
  wire [13:0] u_sine_table_n1734;
  wire n1737;
  wire n1740;
  wire [19:0] n1741;
  wire [8:0] n1742;
  wire [9:0] n1744;
  wire [10:0] n1746;
  wire [19:0] n1748;
  wire [2:0] n1750;
  wire [19:0] n1751;
  wire [8:0] n1752;
  wire [10:0] n1754;
  wire [19:0] n1756;
  wire [19:0] n1757;
  wire n1763;
  wire [31:0] n1764;
  wire n1766;
  wire [31:0] n1767;
  wire n1769;
  wire n1770;
  wire n1771;
  wire n1772;
  wire [8:0] n1774;
  wire [17:0] n1776;
  wire [31:0] n1777;
  wire n1779;
  wire n1780;
  wire n1781;
  wire n1782;
  wire [8:0] n1784;
  wire [17:0] n1786;
  wire [31:0] n1787;
  wire n1789;
  wire n1790;
  wire n1791;
  wire n1792;
  wire [17:0] n1793;
  wire [17:0] n1794;
  wire [17:0] n1795;
  wire [17:0] n1796;
  wire [17:0] n1797;
  wire [17:0] n1798;
  wire [17:0] n1799;
  wire [17:0] n1800;
  wire n1802;
  wire n1804;
  wire n1805;
  wire [31:0] n1806;
  wire [31:0] n1808;
  wire n1810;
  wire [31:0] n1811;
  wire [31:0] n1813;
  wire [31:0] n1815;
  wire [3:0] n1816;
  wire [3:0] n1818;
  wire [3:0] n1819;
  wire n1821;
  wire [13:0] n1823;
  wire [12:0] n1824;
  wire [13:0] n1826;
  wire [13:0] n1827;
  wire n1829;
  wire n1830;
  wire [12:0] n1831;
  wire [12:0] n1832;
  wire [13:0] n1833;
  wire n1834;
  wire [13:0] n1836;
  wire [13:0] n1837;
  wire [13:0] n1838;
  wire n1840;
  wire [13:0] n1841;
  wire [12:0] n1842;
  wire [3:0] n1844;
  wire [13:0] n1845;
  wire [12:0] n1846;
  wire [3:0] n1848;
  wire [13:0] n1849;
  wire [12:0] n1851;
  wire n1855;
  wire n1871;
  wire n1872;
  wire [3:0] n1873;
  reg [3:0] n1874;
  wire [13:0] n1875;
  reg [13:0] n1876;
  wire n1877;
  wire n1878;
  wire [17:0] n1879;
  reg [17:0] n1880;
  wire [12:0] n1881;
  reg [12:0] n1882;
  assign faddr = n1874; //(module output)
  assign opout = n1876; //(module output)
  /*# work/sms-vhdl/compat/operator.vhd:41:8 */
  assign n1732 = {\fdata[value] , \fdata[sign] };
  /*# work/sms-vhdl/compat/operator.vhd:77:12 */
  assign addr = n1880; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:78:12 */
  assign data = u_sine_table_n1734; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:79:12 */
  assign w_is_carrier = n1737; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:80:12 */
  assign w_modula_m = n1741; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:81:12 */
  assign w_modula_c = n1756; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:82:12 */
  assign w_modula = n1757; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:83:12 */
  assign ff_egout = n1882; // (signal)
  /*# work/sms-vhdl/compat/operator.vhd:94:5 */
  sinetable_Brtl u_sine_table (
    .clk(clk),
    .clkena(clkena),
    .wf(wf),
    .addr(addr),
    .data(u_sine_table_n1734));
  /*# work/sms-vhdl/compat/operator.vhd:103:29 */
  assign n1737 = slot[0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:104:50 */
  assign n1740 = fb == 3'b000;
  /*# work/sms-vhdl/compat/operator.vhd:104:41 */
  assign n1741 = n1740 ? 20'b00000000000000000000 : n1751;
  /*# work/sms-vhdl/compat/operator.vhd:105:42 */
  assign n1742 = n1732[9:1]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:105:34 */
  assign n1744 = {1'b0, n1742};
  /*# work/sms-vhdl/compat/operator.vhd:105:48 */
  assign n1746 = {n1744, 1'b0};
  /*# work/sms-vhdl/compat/operator.vhd:105:54 */
  assign n1748 = {n1746, 9'b000000000};
  /*# work/sms-vhdl/compat/operator.vhd:105:75 */
  assign n1750 = 3'b111 ^ fb;
  /*# work/sms-vhdl/compat/operator.vhd:105:25 */
  assign n1751 = n1748 >> n1750;
  /*# work/sms-vhdl/compat/operator.vhd:106:31 */
  assign n1752 = n1732[9:1]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:106:37 */
  assign n1754 = {n1752, 2'b00};
  /*# work/sms-vhdl/compat/operator.vhd:106:44 */
  assign n1756 = {n1754, 9'b000000000};
  /*# work/sms-vhdl/compat/operator.vhd:107:37 */
  assign n1757 = w_is_carrier ? w_modula_c : w_modula_m;
  /*# work/sms-vhdl/compat/operator.vhd:118:27 */
  assign n1763 = stage == 2'b00;
  /*# work/sms-vhdl/compat/operator.vhd:120:52 */
  assign n1764 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/operator.vhd:120:52 */
  assign n1766 = n1764 == 32'b00000000000000000000000000001110;
  /*# work/sms-vhdl/compat/operator.vhd:120:65 */
  assign n1767 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/operator.vhd:120:65 */
  assign n1769 = n1767 == 32'b00000000000000000000000000010001;
  /*# work/sms-vhdl/compat/operator.vhd:120:57 */
  assign n1770 = n1766 | n1769;
  /*# work/sms-vhdl/compat/operator.vhd:120:41 */
  assign n1771 = n1770 & rhythm;
  /*# work/sms-vhdl/compat/operator.vhd:121:34 */
  assign n1772 = ~noise;
  /*# work/sms-vhdl/compat/operator.vhd:121:45 */
  assign n1774 = {n1772, 8'b01111111};
  /*# work/sms-vhdl/compat/operator.vhd:121:58 */
  assign n1776 = {n1774, 9'b000000000};
  /*# work/sms-vhdl/compat/operator.vhd:122:50 */
  assign n1777 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/operator.vhd:122:50 */
  assign n1779 = n1777 == 32'b00000000000000000000000000001111;
  /*# work/sms-vhdl/compat/operator.vhd:122:41 */
  assign n1780 = n1779 & rhythm;
  /*# work/sms-vhdl/compat/operator.vhd:123:43 */
  assign n1781 = pgout[17]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:123:34 */
  assign n1782 = ~n1781;
  /*# work/sms-vhdl/compat/operator.vhd:123:57 */
  assign n1784 = {n1782, 8'b01111111};
  /*# work/sms-vhdl/compat/operator.vhd:123:70 */
  assign n1786 = {n1784, 9'b000000000};
  /*# work/sms-vhdl/compat/operator.vhd:124:50 */
  assign n1787 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/operator.vhd:124:50 */
  assign n1789 = n1787 == 32'b00000000000000000000000000010000;
  /*# work/sms-vhdl/compat/operator.vhd:124:41 */
  assign n1790 = n1789 & rhythm;
  /*# work/sms-vhdl/compat/operator.vhd:127:35 */
  assign n1791 = n1732[0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:127:40 */
  assign n1792 = ~n1791;
  /*# work/sms-vhdl/compat/operator.vhd:128:53 */
  assign n1793 = w_modula[17:0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:128:43 */
  assign n1794 = pgout + n1793;
  /*# work/sms-vhdl/compat/operator.vhd:130:53 */
  assign n1795 = w_modula[17:0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:130:43 */
  assign n1796 = pgout - n1795;
  /*# work/sms-vhdl/compat/operator.vhd:127:25 */
  assign n1797 = n1792 ? n1794 : n1796;
  /*# work/sms-vhdl/compat/operator.vhd:124:21 */
  assign n1798 = n1790 ? pgout : n1797;
  /*# work/sms-vhdl/compat/operator.vhd:122:21 */
  assign n1799 = n1780 ? n1786 : n1798;
  /*# work/sms-vhdl/compat/operator.vhd:120:21 */
  assign n1800 = n1771 ? n1776 : n1799;
  /*# work/sms-vhdl/compat/operator.vhd:134:30 */
  assign n1802 = stage == 2'b01;
  /*# work/sms-vhdl/compat/operator.vhd:136:30 */
  assign n1804 = stage == 2'b10;
  /*# work/sms-vhdl/compat/operator.vhd:140:29 */
  assign n1805 = slot[0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:141:29 */
  assign n1806 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/operator.vhd:141:47 */
  assign n1808 = $signed(n1806) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/operator.vhd:141:50 */
  assign n1810 = n1808 == 32'b00000000000000000000000000001000;
  /*# work/sms-vhdl/compat/operator.vhd:144:38 */
  assign n1811 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/operator.vhd:144:56 */
  assign n1813 = $signed(n1811) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/operator.vhd:144:59 */
  assign n1815 = n1813 + 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/operator.vhd:144:38 */
  assign n1816 = n1815[3:0];  // trunc
  /*# work/sms-vhdl/compat/operator.vhd:141:25 */
  assign n1818 = n1810 ? 4'b0000 : n1816;
  /*# work/sms-vhdl/compat/operator.vhd:136:17 */
  assign n1819 = n1840 ? n1818 : n1874;
  /*# work/sms-vhdl/compat/operator.vhd:147:30 */
  assign n1821 = stage == 2'b11;
  /*# work/sms-vhdl/compat/operator.vhd:149:32 */
  assign n1823 = {1'b0, ff_egout};
  /*# work/sms-vhdl/compat/operator.vhd:149:57 */
  assign n1824 = data[12:0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:149:51 */
  assign n1826 = {1'b0, n1824};
  /*# work/sms-vhdl/compat/operator.vhd:149:45 */
  assign n1827 = n1823 + n1826;
  /*# work/sms-vhdl/compat/operator.vhd:149:75 */
  assign n1829 = $unsigned(n1827) < $unsigned(14'b10000000000000);
  /*# work/sms-vhdl/compat/operator.vhd:150:42 */
  assign n1830 = data[13]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:150:65 */
  assign n1831 = data[12:0]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:150:59 */
  assign n1832 = ff_egout + n1831;
  /*# work/sms-vhdl/compat/operator.vhd:150:47 */
  assign n1833 = {n1830, n1832};
  /*# work/sms-vhdl/compat/operator.vhd:152:42 */
  assign n1834 = data[13]; // extract
  /*# work/sms-vhdl/compat/operator.vhd:152:47 */
  assign n1836 = {n1834, 13'b1111111111111};
  /*# work/sms-vhdl/compat/operator.vhd:149:21 */
  assign n1837 = n1829 ? n1833 : n1836;
  /*# work/sms-vhdl/compat/operator.vhd:147:17 */
  assign n1838 = n1821 ? n1837 : n1876;
  /*# work/sms-vhdl/compat/operator.vhd:136:17 */
  assign n1840 = n1805 & n1804;
  /*# work/sms-vhdl/compat/operator.vhd:136:17 */
  assign n1841 = n1804 ? n1876 : n1838;
  /*# work/sms-vhdl/compat/operator.vhd:136:17 */
  assign n1842 = n1804 ? egout : ff_egout;
  /*# work/sms-vhdl/compat/operator.vhd:134:17 */
  assign n1844 = n1802 ? n1874 : n1819;
  /*# work/sms-vhdl/compat/operator.vhd:134:17 */
  assign n1845 = n1802 ? n1876 : n1841;
  /*# work/sms-vhdl/compat/operator.vhd:134:17 */
  assign n1846 = n1802 ? ff_egout : n1842;
  /*# work/sms-vhdl/compat/operator.vhd:118:17 */
  assign n1848 = n1763 ? n1874 : n1844;
  /*# work/sms-vhdl/compat/operator.vhd:118:17 */
  assign n1849 = n1763 ? n1876 : n1845;
  /*# work/sms-vhdl/compat/operator.vhd:118:17 */
  assign n1851 = n1763 ? ff_egout : n1846;
  /*# work/sms-vhdl/compat/operator.vhd:117:13 */
  assign n1855 = n1763 & clkena;
  /*# work/sms-vhdl/compat/operator.vhd:58:9 */
  assign n1871 = ~reset;
  /*# work/sms-vhdl/compat/operator.vhd:58:9 */
  assign n1872 = clkena & n1871;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  assign n1873 = n1872 ? n1848 : n1874;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  always @(posedge clk)
    n1874 <= n1873;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  assign n1875 = clkena ? n1849 : n1876;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1876 <= 14'b00000000000000;
    else
      n1876 <= n1875;
  /*# work/sms-vhdl/compat/operator.vhd:77:12 */
  assign n1877 = ~reset;
  /*# work/sms-vhdl/compat/operator.vhd:77:12 */
  assign n1878 = n1855 & n1877;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  assign n1879 = n1878 ? n1800 : addr;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  always @(posedge clk)
    n1880 <= n1879;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  assign n1881 = clkena ? n1851 : ff_egout;
  /*# work/sms-vhdl/compat/operator.vhd:116:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1882 <= 13'b0000000000000;
    else
      n1882 <= n1881;
endmodule

module phasegenerator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  pm,
   input  [3:0] ml,
   input  [2:0] blk,
   input  [8:0] fnum,
   input  key,
   output noise,
   output [17:0] pgout);
  wire memwr;
  wire [17:0] memout;
  wire [17:0] memin;
  wire [12:0] pmcount;
  reg [17:0] n1455_lastkey;
  reg n1455_noise14;
  reg n1455_noise17;
  wire n1463;
  wire [31:0] n1464;
  wire n1466;
  wire [31:0] n1467;
  wire n1469;
  wire [31:0] n1470;
  wire n1472;
  wire [31:0] n1473;
  wire n1475;
  wire [12:0] n1478;
  wire [12:0] n1479;
  wire [13:0] n1486;
  wire [13:0] n1487;
  wire [13:0] n1488;
  wire [21:0] n1490;
  wire [21:0] n1491;
  wire [17:0] n1492;
  wire [1:0] n1493;
  wire [17:0] n1495;
  wire [17:0] n1496;
  wire n1498;
  wire [17:0] n1500;
  wire [17:0] n1501;
  wire n1503;
  wire [1:0] n1504;
  reg [17:0] n1505;
  wire [17:0] n1506;
  wire n1510;
  wire n1511;
  wire n1512;
  wire n1514;
  wire n1516;
  wire n1517;
  wire n1518;
  wire n1519;
  wire [17:0] n1520;
  wire [17:0] n1522;
  wire n1527;
  wire [5:0] n1528;
  wire n1534;
  wire [2:0] n1535;
  wire n1540;
  wire n1541;
  wire n1542;
  wire [31:0] n1543;
  wire n1545;
  wire n1547;
  wire [17:0] n1548;
  wire n1550;
  wire [17:0] n1551;
  wire n1552;
  wire [17:0] n1553;
  wire n1555;
  wire n1556;
  wire [17:0] n1558;
  wire n1559;
  wire [17:0] n1560;
  wire [12:0] n1561;
  wire [17:0] n1562;
  wire n1564;
  wire n1565;
  wire [17:0] n1567;
  wire n1569;
  wire [17:0] n1570;
  wire [12:0] n1571;
  wire [17:0] n1572;
  wire n1574;
  wire n1575;
  wire [17:0] mem_n1614;
  wire n1617;
  wire n1618;
  wire n1619;
  reg n1620;
  wire n1621;
  wire n1622;
  wire [17:0] n1623;
  reg [17:0] n1624;
  wire n1625;
  reg n1626;
  wire n1627;
  wire n1628;
  wire [17:0] n1629;
  reg [17:0] n1630;
  wire [12:0] n1631;
  reg [12:0] n1632;
  wire [17:0] n1633;
  reg [17:0] n1634;
  wire n1635;
  reg n1636;
  wire n1637;
  reg n1638;
  wire [4:0] n1641; // mem_rd
  wire n1643; // mem_rd
  wire n1645; // mem_rd
  wire [31:0] n1647;
  wire n1648;
  wire n1649;
  wire n1650;
  wire n1651;
  wire n1652;
  wire n1653;
  wire n1654;
  wire n1655;
  wire n1656;
  wire n1657;
  wire n1658;
  wire n1659;
  wire n1660;
  wire n1661;
  wire n1662;
  wire n1663;
  wire n1664;
  wire n1665;
  wire n1666;
  wire n1667;
  wire n1668;
  wire n1669;
  wire n1670;
  wire n1671;
  wire n1672;
  wire n1673;
  wire n1674;
  wire n1675;
  wire n1676;
  wire n1677;
  wire n1678;
  wire n1679;
  wire n1680;
  wire n1681;
  wire n1682;
  wire n1683;
  wire n1684;
  wire n1685;
  wire n1686;
  wire n1687;
  wire n1688;
  wire n1689;
  wire n1690;
  wire n1691;
  wire n1692;
  wire n1693;
  wire n1694;
  wire n1695;
  wire n1696;
  wire n1697;
  wire n1698;
  wire n1699;
  wire n1700;
  wire n1701;
  wire n1702;
  wire n1703;
  wire n1704;
  wire n1705;
  wire n1706;
  wire n1707;
  wire n1708;
  wire n1709;
  wire n1710;
  wire n1711;
  wire n1712;
  wire n1713;
  wire n1714;
  wire n1715;
  wire n1716;
  wire n1717;
  wire n1718;
  wire n1719;
  wire n1720;
  wire n1721;
  wire n1722;
  wire n1723;
  wire n1724;
  wire n1725;
  wire n1726;
  wire n1727;
  wire n1728;
  wire n1729;
  wire [17:0] n1730;
  assign noise = n1620; //(module output)
  assign pgout = n1624; //(module output)
  /*# work/sms-vhdl/compat/phasegenerator.vhd:88:10 */
  assign memwr = n1626; // (signal)
  /*# work/sms-vhdl/compat/phasegenerator.vhd:89:10 */
  assign memout = mem_n1614; // (signal)
  /*# work/sms-vhdl/compat/phasegenerator.vhd:89:18 */
  assign memin = n1630; // (signal)
  /*# work/sms-vhdl/compat/phasegenerator.vhd:92:10 */
  assign pmcount = n1632; // (signal)
  /*# work/sms-vhdl/compat/phasegenerator.vhd:97:18 */
  always @*
    n1455_lastkey = n1634; // (isignal)
  initial
    n1455_lastkey = 18'bX;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:99:18 */
  always @*
    n1455_noise14 = n1636; // (isignal)
  initial
    n1455_noise14 = 1'bX;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:100:18 */
  always @*
    n1455_noise17 = n1638; // (isignal)
  initial
    n1455_noise17 = 1'bX;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:115:24 */
  assign n1463 = n1455_noise14 ^ n1455_noise17;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:16 */
  assign n1464 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:16 */
  assign n1466 = n1464 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:19 */
  assign n1467 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:19 */
  assign n1469 = n1467 == 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:19 */
  assign n1470 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:19 */
  assign n1472 = n1470 == 32'b00000000000000000000000000000010;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:128:17 */
  assign n1473 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:128:17 */
  assign n1475 = n1473 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:129:30 */
  assign n1478 = pmcount + 13'b0000000000001;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1479 = n1552 ? n1478 : pmcount;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:40 */
  assign n1486 = {5'b0, fnum};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:40 */
  assign n1487 = {9'b0, n1641};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:40 */
  assign n1488 = n1486 * n1487; // umul
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:34 */
  assign n1490 = {8'b00000000, n1488};
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:20 */
  assign n1491 = n1490 << blk;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:70 */
  assign n1492 = n1491[19:2]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:136:24 */
  assign n1493 = pmcount[12:11]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:138:35 */
  assign n1495 = n1492 >> 3'b111;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:138:33 */
  assign n1496 = n1492 + n1495;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:137:14 */
  assign n1498 = n1493 == 2'b01;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:140:35 */
  assign n1500 = n1492 >> 3'b111;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:140:33 */
  assign n1501 = n1492 - n1500;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:139:14 */
  assign n1503 = n1493 == 2'b11;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:136:12 */
  assign n1504 = {n1503, n1498};
  /*# work/sms-vhdl/compat/phasegenerator.vhd:136:12 */
  always @*
    case (n1504)
      2'b10: n1505 = n1501;
      2'b01: n1505 = n1496;
      default: n1505 = n1492;
    endcase
  /*# work/sms-vhdl/compat/phasegenerator.vhd:135:9 */
  assign n1506 = pm ? n1505 : n1492;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:40 */
  assign n1510 = ~n1648;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:46 */
  assign n1511 = key & n1510;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:72 */
  assign n1512 = ~rhythm;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:87 */
  assign n1514 = slot != 5'b01110;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:107 */
  assign n1516 = slot != 5'b10001;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:98 */
  assign n1517 = n1516 & n1514;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:78 */
  assign n1518 = n1512 | n1517;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:60 */
  assign n1519 = n1518 & n1511;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:149:27 */
  assign n1520 = memout + n1506;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:9 */
  assign n1522 = n1519 ? 18'b000000000000000000 : n1520;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:154:17 */
  assign n1527 = slot == 5'b01110;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:155:53 */
  assign n1528 = memout[15:10]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:156:20 */
  assign n1534 = slot == 5'b10001;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:157:53 */
  assign n1535 = memout[13:11]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:156:9 */
  assign n1540 = n1534 ? n1645 : n1455_noise17;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1541 = n1555 ? n1643 : n1455_noise14;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:154:9 */
  assign n1542 = n1527 ? n1455_noise17 : n1540;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:164:19 */
  assign n1543 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/phasegenerator.vhd:164:19 */
  assign n1545 = n1543 == 32'b00000000000000000000000000000011;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:164:7 */
  assign n1547 = n1545 ? 1'b0 : memwr;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1548 = n1472 ? memout : n1624;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1550 = n1472 ? 1'b1 : n1547;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1551 = n1472 ? n1522 : memin;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1552 = n1475 & n1472;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1553 = n1472 ? n1730 : n1455_lastkey;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1555 = n1527 & n1472;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:125:7 */
  assign n1556 = n1472 ? n1542 : n1455_noise17;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1558 = n1469 ? n1624 : n1548;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1559 = n1469 ? memwr : n1550;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1560 = n1469 ? memin : n1551;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1561 = n1469 ? pmcount : n1479;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1562 = n1469 ? n1455_lastkey : n1553;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1564 = n1469 ? n1455_noise14 : n1541;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:121:7 */
  assign n1565 = n1469 ? n1455_noise17 : n1556;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1567 = n1466 ? n1624 : n1558;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1569 = n1466 ? 1'b0 : n1559;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1570 = n1466 ? memin : n1560;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1571 = n1466 ? pmcount : n1561;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1572 = n1466 ? n1455_lastkey : n1562;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1574 = n1466 ? n1455_noise14 : n1564;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:117:7 */
  assign n1575 = n1466 ? n1455_noise17 : n1565;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:174:3 */
  phasememory_Brtl mem (
    .clk(clk),
    .reset(reset),
    .slot(slot),
    .memwr(memwr),
    .memin(memin),
    .memout(mem_n1614));
  /*# work/sms-vhdl/compat/phasegenerator.vhd:56:3 */
  assign n1617 = ~reset;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:56:3 */
  assign n1618 = clkena & n1617;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1619 = n1618 ? n1463 : n1620;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk)
    n1620 <= n1619;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:57:3 */
  assign n1621 = ~reset;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:57:3 */
  assign n1622 = clkena & n1621;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1623 = n1622 ? n1567 : n1624;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk)
    n1624 <= n1623;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1625 = clkena ? n1569 : memwr;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1626 <= 1'b0;
    else
      n1626 <= n1625;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:89:18 */
  assign n1627 = ~reset;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:89:18 */
  assign n1628 = clkena & n1627;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1629 = n1628 ? n1570 : memin;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk)
    n1630 <= n1629;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1631 = clkena ? n1571 : pmcount;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1632 <= 13'b0000000000000;
    else
      n1632 <= n1631;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1633 = clkena ? n1572 : n1455_lastkey;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1634 <= 18'b000000000000000000;
    else
      n1634 <= n1633;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1635 = clkena ? n1574 : n1455_noise14;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1636 <= 1'b0;
    else
      n1636 <= n1635;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  assign n1637 = clkena ? n1575 : n1455_noise17;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:113:5 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1638 <= 1'b0;
    else
      n1638 <= n1637;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:47 */
  reg [4:0] n1639[15:0] ; // memory
  initial begin
    n1639[15] = 5'b11110;
    n1639[14] = 5'b11110;
    n1639[13] = 5'b11000;
    n1639[12] = 5'b11000;
    n1639[11] = 5'b10100;
    n1639[10] = 5'b10100;
    n1639[9] = 5'b10010;
    n1639[8] = 5'b10000;
    n1639[7] = 5'b01110;
    n1639[6] = 5'b01100;
    n1639[5] = 5'b01010;
    n1639[4] = 5'b01000;
    n1639[3] = 5'b00110;
    n1639[2] = 5'b00100;
    n1639[1] = 5'b00010;
    n1639[0] = 5'b00001;
    end
  assign n1641 = n1639[ml];
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:47 */
  /*# work/sms-vhdl/compat/phasegenerator.vhd:133:46 */
  reg n1642[63:0] ; // memory
  initial begin
    n1642[63] = 1'b1;
    n1642[62] = 1'b0;
    n1642[61] = 1'b0;
    n1642[60] = 1'b0;
    n1642[59] = 1'b1;
    n1642[58] = 1'b0;
    n1642[57] = 1'b0;
    n1642[56] = 1'b0;
    n1642[55] = 1'b1;
    n1642[54] = 1'b0;
    n1642[53] = 1'b0;
    n1642[52] = 1'b0;
    n1642[51] = 1'b1;
    n1642[50] = 1'b0;
    n1642[49] = 1'b0;
    n1642[48] = 1'b0;
    n1642[47] = 1'b1;
    n1642[46] = 1'b0;
    n1642[45] = 1'b0;
    n1642[44] = 1'b0;
    n1642[43] = 1'b1;
    n1642[42] = 1'b0;
    n1642[41] = 1'b0;
    n1642[40] = 1'b0;
    n1642[39] = 1'b1;
    n1642[38] = 1'b0;
    n1642[37] = 1'b0;
    n1642[36] = 1'b0;
    n1642[35] = 1'b1;
    n1642[34] = 1'b0;
    n1642[33] = 1'b0;
    n1642[32] = 1'b1;
    n1642[31] = 1'b0;
    n1642[30] = 1'b0;
    n1642[29] = 1'b0;
    n1642[28] = 1'b1;
    n1642[27] = 1'b0;
    n1642[26] = 1'b0;
    n1642[25] = 1'b0;
    n1642[24] = 1'b1;
    n1642[23] = 1'b0;
    n1642[22] = 1'b0;
    n1642[21] = 1'b0;
    n1642[20] = 1'b1;
    n1642[19] = 1'b0;
    n1642[18] = 1'b0;
    n1642[17] = 1'b0;
    n1642[16] = 1'b1;
    n1642[15] = 1'b0;
    n1642[14] = 1'b0;
    n1642[13] = 1'b0;
    n1642[12] = 1'b1;
    n1642[11] = 1'b0;
    n1642[10] = 1'b0;
    n1642[9] = 1'b0;
    n1642[8] = 1'b1;
    n1642[7] = 1'b0;
    n1642[6] = 1'b0;
    n1642[5] = 1'b0;
    n1642[4] = 1'b1;
    n1642[3] = 1'b0;
    n1642[2] = 1'b0;
    n1642[1] = 1'b0;
    n1642[0] = 1'b0;
    end
  assign n1643 = n1642[n1528];
  /*# work/sms-vhdl/compat/phasegenerator.vhd:155:34 */
  /*# work/sms-vhdl/compat/phasegenerator.vhd:155:33 */
  reg n1644[7:0] ; // memory
  initial begin
    n1644[7] = 1'b0;
    n1644[6] = 1'b0;
    n1644[5] = 1'b0;
    n1644[4] = 1'b0;
    n1644[3] = 1'b1;
    n1644[2] = 1'b0;
    n1644[1] = 1'b1;
    n1644[0] = 1'b0;
    end
  assign n1645 = n1644[n1535];
  /*# work/sms-vhdl/compat/phasegenerator.vhd:157:34 */
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:20 */
  assign n1647 = {14'bX, n1455_lastkey};
  /*# work/sms-vhdl/compat/phasegenerator.vhd:146:20 */
  assign n1648 = n1647[slot * 1 +: 1]; //(Bmux)
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1649 = slot[4]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1650 = ~n1649;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1651 = slot[3]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1652 = ~n1651;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1653 = n1650 & n1652;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1654 = n1650 & n1651;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1655 = n1649 & n1652;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1656 = slot[2]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1657 = ~n1656;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1658 = n1653 & n1657;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1659 = n1653 & n1656;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1660 = n1654 & n1657;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1661 = n1654 & n1656;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1662 = n1655 & n1657;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1663 = slot[1]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1664 = ~n1663;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1665 = n1658 & n1664;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1666 = n1658 & n1663;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1667 = n1659 & n1664;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1668 = n1659 & n1663;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1669 = n1660 & n1664;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1670 = n1660 & n1663;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1671 = n1661 & n1664;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1672 = n1661 & n1663;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1673 = n1662 & n1664;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1674 = slot[0]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1675 = ~n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1676 = n1665 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1677 = n1665 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1678 = n1666 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1679 = n1666 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1680 = n1667 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1681 = n1667 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1682 = n1668 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1683 = n1668 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1684 = n1669 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1685 = n1669 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1686 = n1670 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1687 = n1670 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1688 = n1671 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1689 = n1671 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1690 = n1672 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1691 = n1672 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1692 = n1673 & n1675;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1693 = n1673 & n1674;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1694 = n1455_lastkey[0]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1695 = n1676 ? key : n1694;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1696 = n1455_lastkey[1]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1697 = n1677 ? key : n1696;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1698 = n1455_lastkey[2]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1699 = n1678 ? key : n1698;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1700 = n1455_lastkey[3]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1701 = n1679 ? key : n1700;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1702 = n1455_lastkey[4]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1703 = n1680 ? key : n1702;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1704 = n1455_lastkey[5]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1705 = n1681 ? key : n1704;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1706 = n1455_lastkey[6]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1707 = n1682 ? key : n1706;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1708 = n1455_lastkey[7]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1709 = n1683 ? key : n1708;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1710 = n1455_lastkey[8]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1711 = n1684 ? key : n1710;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1712 = n1455_lastkey[9]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1713 = n1685 ? key : n1712;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1714 = n1455_lastkey[10]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1715 = n1686 ? key : n1714;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1716 = n1455_lastkey[11]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1717 = n1687 ? key : n1716;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1718 = n1455_lastkey[12]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1719 = n1688 ? key : n1718;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1720 = n1455_lastkey[13]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1721 = n1689 ? key : n1720;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1722 = n1455_lastkey[14]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1723 = n1690 ? key : n1722;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1724 = n1455_lastkey[15]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1725 = n1691 ? key : n1724;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1726 = n1455_lastkey[16]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1727 = n1692 ? key : n1726;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1728 = n1455_lastkey[17]; // extract
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1729 = n1693 ? key : n1728;
  /*# work/sms-vhdl/compat/phasegenerator.vhd:151:9 */
  assign n1730 = {n1729, n1727, n1725, n1723, n1721, n1719, n1717, n1715, n1713, n1711, n1709, n1707, n1705, n1703, n1701, n1699, n1697, n1695};
endmodule

module envelopegenerator_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  rhythm,
   input  am,
   input  [6:0] tl,
   input  [3:0] ar,
   input  [3:0] dr,
   input  [3:0] sl,
   input  [3:0] rr,
   input  [3:0] rks,
   input  key,
   output [12:0] egout);
  wire [4:0] rslot;
  wire [24:0] memin;
  wire [24:0] memout;
  wire memwr;
  wire [21:0] aridx;
  wire [12:0] ardata;
  wire [12:0] u_attack_table_n992;
  wire [24:0] u_envelope_memory_n995;
  wire [1:0] \u_envelope_memory.rdata[state] ;
  wire [22:0] \u_envelope_memory.rdata[phase] ;
  wire [1:0] n996;
  wire [22:0] n997;
  wire [24:0] n998;
  wire n1005;
  wire n1007;
  wire [4:0] n1009;
  wire [4:0] n1011;
  wire n1013;
  reg [17:0] n1018_lastkey;
  reg [4:0] n1018_rm;
  reg [14:0] n1018_egtmp;
  reg [19:0] n1018_amphase;
  reg [22:0] n1018_egphase;
  reg [1:0] n1018_egstate;
  reg [17:0] n1018_ntable;
  wire [21:0] n1031;
  wire [16:0] n1032;
  wire n1033;
  wire [17:0] n1034;
  wire n1035;
  wire n1036;
  wire [17:0] n1037;
  wire n1038;
  wire n1039;
  wire [19:0] n1042;
  wire [4:0] n1043;
  wire n1045;
  wire [4:0] n1047;
  wire [4:0] n1048;
  wire [14:0] n1049;
  wire [31:0] n1050;
  wire n1052;
  wire [1:0] n1053;
  wire [22:0] n1054;
  wire [31:0] n1055;
  wire n1057;
  wire [31:0] n1058;
  wire n1060;
  wire [4:0] n1062;
  wire [8:0] n1064;
  wire [14:0] n1066;
  wire [14:0] n1068;
  wire [14:0] n1069;
  wire n1071;
  wire [4:0] n1073;
  wire [8:0] n1075;
  wire [14:0] n1077;
  wire [12:0] n1078;
  wire [14:0] n1080;
  wire [14:0] n1081;
  wire n1083;
  wire [4:0] n1085;
  wire [8:0] n1087;
  wire [14:0] n1089;
  wire [12:0] n1090;
  wire [14:0] n1092;
  wire [14:0] n1093;
  wire n1095;
  wire n1099;
  wire [3:0] n1100;
  reg [4:0] n1101;
  wire [12:0] n1102;
  wire [12:0] n1103;
  wire [12:0] n1104;
  wire [12:0] n1105;
  reg [12:0] n1106;
  wire [1:0] n1107;
  wire [1:0] n1108;
  wire [1:0] n1109;
  wire [1:0] n1110;
  reg [1:0] n1111;
  wire [17:0] n1112;
  wire n1113;
  wire [31:0] n1114;
  wire [31:0] n1116;
  wire n1118;
  wire n1119;
  wire n1120;
  wire [14:0] n1121;
  wire [14:0] n1123;
  wire [14:0] n1124;
  wire [14:0] n1125;
  wire [19:0] n1126;
  wire n1127;
  wire n1128;
  wire [19:0] n1129;
  wire [9:0] n1130;
  wire [9:0] n1132;
  wire [14:0] n1134;
  wire [14:0] n1135;
  wire [19:0] n1136;
  wire [9:0] n1137;
  wire [9:0] n1139;
  wire [14:0] n1141;
  wire [14:0] n1142;
  wire [14:0] n1143;
  wire [14:0] n1144;
  wire [1:0] n1145;
  wire n1147;
  wire [12:0] n1148;
  wire [12:0] n1150;
  wire n1152;
  wire [1:0] n1153;
  wire [4:0] n1154;
  wire [4:0] n1155;
  wire n1156;
  wire [3:0] n1158;
  wire [3:0] n1159;
  wire n1160;
  localparam [17:0] n1161 = 18'b000000000000000000;
  wire [1:0] n1162;
  wire [2:0] n1164;
  wire [5:0] n1167;
  wire [5:0] n1168;
  wire [16:0] n1169;
  wire [4:0] n1170;
  wire [3:0] n1171;
  wire [22:0] n1172;
  wire [22:0] n1173;
  wire [22:0] n1174;
  wire n1176;
  wire [1:0] n1178;
  wire [2:0] n1180;
  wire [4:0] n1181;
  wire [3:0] n1182;
  wire [3:0] n1185;
  wire [22:0] n1186;
  wire [22:0] n1187;
  wire [22:0] n1188;
  wire n1190;
  wire n1192;
  wire n1193;
  wire n1195;
  wire [2:0] n1196;
  reg [22:0] n1197;
  wire [4:0] n1199;
  wire [4:0] n1200;
  wire [22:0] n1201;
  wire n1203;
  wire [22:0] n1205;
  wire [1:0] n1207;
  wire n1209;
  wire [4:0] n1210;
  wire [4:0] n1212;
  wire n1213;
  wire [1:0] n1215;
  wire n1217;
  wire [4:0] n1218;
  wire n1220;
  wire [1:0] n1222;
  wire n1224;
  wire n1226;
  wire [3:0] n1227;
  reg [22:0] n1229;
  reg [1:0] n1230;
  wire n1234;
  wire n1235;
  wire n1241;
  wire n1242;
  wire n1244;
  wire n1245;
  wire [1:0] n1247;
  wire [22:0] n1248;
  wire [22:0] n1249;
  wire [1:0] n1251;
  wire [24:0] n1255;
  wire [31:0] n1256;
  wire n1258;
  wire n1260;
  wire [12:0] n1261;
  wire [24:0] n1262;
  wire n1264;
  wire [17:0] n1265;
  wire [4:0] n1266;
  wire [14:0] n1267;
  wire [22:0] n1268;
  wire [1:0] n1269;
  wire [12:0] n1271;
  wire [24:0] n1272;
  wire n1273;
  wire [17:0] n1274;
  wire [4:0] n1275;
  wire [14:0] n1276;
  wire [22:0] n1277;
  wire [1:0] n1278;
  wire [12:0] n1280;
  wire [24:0] n1281;
  wire n1282;
  wire [17:0] n1283;
  wire [4:0] n1284;
  wire [14:0] n1285;
  wire [22:0] n1286;
  wire [1:0] n1287;
  wire [19:0] n1295;
  wire [17:0] n1300;
  wire [19:0] n1324;
  wire n1334;
  wire n1335;
  wire [12:0] n1336;
  reg [12:0] n1337;
  wire [4:0] n1338;
  reg [4:0] n1339;
  wire n1340;
  wire n1341;
  wire [24:0] n1342;
  reg [24:0] n1343;
  wire n1344;
  reg n1345;
  wire n1346;
  wire [21:0] n1347;
  reg [21:0] n1348;
  wire [17:0] n1349;
  reg [17:0] n1350;
  wire [4:0] n1351;
  reg [4:0] n1352;
  wire n1353;
  wire n1354;
  wire [14:0] n1355;
  reg [14:0] n1356;
  wire [19:0] n1357;
  reg [19:0] n1358;
  wire [22:0] n1359;
  reg [22:0] n1360;
  wire [1:0] n1361;
  reg [1:0] n1362;
  wire [17:0] n1363;
  reg [17:0] n1364;
  wire [31:0] n1366;
  wire n1367;
  wire [31:0] n1369;
  wire n1370;
  wire n1371;
  wire n1372;
  wire n1373;
  wire n1374;
  wire n1375;
  wire n1376;
  wire n1377;
  wire n1378;
  wire n1379;
  wire n1380;
  wire n1381;
  wire n1382;
  wire n1383;
  wire n1384;
  wire n1385;
  wire n1386;
  wire n1387;
  wire n1388;
  wire n1389;
  wire n1390;
  wire n1391;
  wire n1392;
  wire n1393;
  wire n1394;
  wire n1395;
  wire n1396;
  wire n1397;
  wire n1398;
  wire n1399;
  wire n1400;
  wire n1401;
  wire n1402;
  wire n1403;
  wire n1404;
  wire n1405;
  wire n1406;
  wire n1407;
  wire n1408;
  wire n1409;
  wire n1410;
  wire n1411;
  wire n1412;
  wire n1413;
  wire n1414;
  wire n1415;
  wire n1416;
  wire n1417;
  wire n1418;
  wire n1419;
  wire n1420;
  wire n1421;
  wire n1422;
  wire n1423;
  wire n1424;
  wire n1425;
  wire n1426;
  wire n1427;
  wire n1428;
  wire n1429;
  wire n1430;
  wire n1431;
  wire n1432;
  wire n1433;
  wire n1434;
  wire n1435;
  wire n1436;
  wire n1437;
  wire n1438;
  wire n1439;
  wire n1440;
  wire n1441;
  wire n1442;
  wire n1443;
  wire n1444;
  wire n1445;
  wire n1446;
  wire n1447;
  wire n1448;
  wire n1449;
  wire n1450;
  wire n1451;
  wire [17:0] n1452;
  assign egout = n1337; //(module output)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:89:12 */
  assign rslot = n1339; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:90:12 */
  assign memin = n1343; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:91:12 */
  assign memout = u_envelope_memory_n995; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:92:12 */
  assign memwr = n1345; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:94:12 */
  assign aridx = n1348; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:95:12 */
  assign ardata = u_attack_table_n992; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:99:5 */
  attacktable_Brtl u_attack_table (
    .clk(clk),
    .clkena(clkena),
    .addr(aridx),
    .data(u_attack_table_n992));
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:115:21 */
  assign u_envelope_memory_n995 = n998; // (signal)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:107:5 */
  envelopememory_Brtl u_envelope_memory (
    .clk(clk),
    .reset(reset),
    .waddr(slot),
    .wr(memwr),
    .\wdata[state] (n996),
    .\wdata[phase] (n997),
    .raddr(rslot),
    .\rdata[state] (\u_envelope_memory.rdata[state] ),
    .\rdata[phase] (\u_envelope_memory.rdata[phase] ));
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:107:5 */
  assign n996 = memin[1:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:107:5 */
  assign n997 = memin[24:2]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:107:5 */
  assign n998 = {\u_envelope_memory.rdata[phase] , \u_envelope_memory.rdata[state] };
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:125:27 */
  assign n1005 = stage == 2'b10;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:126:30 */
  assign n1007 = slot == 5'b10001;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:129:39 */
  assign n1009 = slot + 5'b00001;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:126:21 */
  assign n1011 = n1007 ? 5'b00000 : n1009;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:124:13 */
  assign n1013 = n1005 & clkena;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:137:18 */
  always @*
    n1018_lastkey = n1350; // (isignal)
  initial
    n1018_lastkey = 18'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:138:18 */
  always @*
    n1018_rm = n1352; // (isignal)
  initial
    n1018_rm = 5'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  always @*
    n1018_egtmp = n1356; // (isignal)
  initial
    n1018_egtmp = 15'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:140:18 */
  always @*
    n1018_amphase = n1358; // (isignal)
  initial
    n1018_amphase = 20'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:141:18 */
  always @*
    n1018_egphase = n1360; // (isignal)
  initial
    n1018_egphase = 23'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:142:18 */
  always @*
    n1018_egstate = n1362; // (isignal)
  initial
    n1018_egstate = 2'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:144:18 */
  always @*
    n1018_ntable = n1364; // (isignal)
  initial
    n1018_ntable = 18'bX;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:158:29 */
  assign n1031 = n1018_egphase[21:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:162:50 */
  assign n1032 = n1018_ntable[16:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:144:18 */
  assign n1033 = n1018_ntable[0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:144:18 */
  assign n1034 = {n1032, n1033};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:163:50 */
  assign n1035 = n1034[17]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:144:18 */
  assign n1036 = n1018_ntable[0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:144:18 */
  assign n1037 = {n1032, n1036};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:163:67 */
  assign n1038 = n1037[14]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:163:57 */
  assign n1039 = n1035 ^ n1038;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:166:36 */
  assign n1042 = n1018_amphase + 20'b00000000000000000001;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:167:27 */
  assign n1043 = n1042[19:15]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:167:64 */
  assign n1045 = n1043 == 5'b11111;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:140:18 */
  assign n1047 = n1042[19:15]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:167:17 */
  assign n1048 = n1045 ? 5'b00001 : n1047;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:140:18 */
  assign n1049 = n1042[14:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:26 */
  assign n1050 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:26 */
  assign n1052 = n1050 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:172:39 */
  assign n1053 = memout[1:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:173:39 */
  assign n1054 = memout[24:2]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:29 */
  assign n1055 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:29 */
  assign n1057 = n1055 == 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:29 */
  assign n1058 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:29 */
  assign n1060 = n1058 == 32'b00000000000000000000000000000010;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:181:38 */
  assign n1062 = {1'b0, ar};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:182:43 */
  assign n1064 = {2'b00, tl};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:182:46 */
  assign n1066 = {n1064, 6'b000000};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:182:64 */
  assign n1068 = {2'b00, ardata};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:182:57 */
  assign n1069 = n1066 + n1068;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:180:25 */
  assign n1071 = n1018_egstate == 2'b01;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:184:38 */
  assign n1073 = {1'b0, dr};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:43 */
  assign n1075 = {2'b00, tl};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:46 */
  assign n1077 = {n1075, 6'b000000};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:72 */
  assign n1078 = n1018_egphase[21:9]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:64 */
  assign n1080 = {2'b00, n1078};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:57 */
  assign n1081 = n1077 + n1080;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:183:25 */
  assign n1083 = n1018_egstate == 2'b10;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:187:38 */
  assign n1085 = {1'b0, rr};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:43 */
  assign n1087 = {2'b00, tl};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:46 */
  assign n1089 = {n1087, 6'b000000};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:72 */
  assign n1090 = n1018_egphase[21:9]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:64 */
  assign n1092 = {2'b00, n1090};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:57 */
  assign n1093 = n1089 + n1092;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:186:25 */
  assign n1095 = n1018_egstate == 2'b11;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:189:25 */
  assign n1099 = n1018_egstate == 2'b00;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:179:21 */
  assign n1100 = {n1099, n1095, n1083, n1071};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:179:21 */
  always @*
    case (n1100)
      4'b1000: n1101 = n1018_rm;
      4'b0100: n1101 = n1085;
      4'b0010: n1101 = n1073;
      4'b0001: n1101 = n1062;
      default: n1101 = n1018_rm;
    endcase
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:182:57 */
  assign n1102 = n1069[12:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:57 */
  assign n1103 = n1081[12:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:57 */
  assign n1104 = n1093[12:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  assign n1105 = n1018_egtmp[12:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:179:21 */
  always @*
    case (n1100)
      4'b1000: n1106 = 13'b1111111111111;
      4'b0100: n1106 = n1104;
      4'b0010: n1106 = n1103;
      4'b0001: n1106 = n1102;
      default: n1106 = n1105;
    endcase
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:182:57 */
  assign n1107 = n1069[14:13]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:185:57 */
  assign n1108 = n1081[14:13]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:188:57 */
  assign n1109 = n1093[14:13]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  assign n1110 = n1018_egtmp[14:13]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:179:21 */
  always @*
    case (n1100)
      4'b1000: n1111 = 2'b00;
      4'b0100: n1111 = n1109;
      4'b0010: n1111 = n1108;
      4'b0001: n1111 = n1107;
      default: n1111 = n1110;
    endcase
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:144:18 */
  assign n1112 = {n1032, n1039};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:30 */
  assign n1113 = n1112[0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:42 */
  assign n1114 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:60 */
  assign n1116 = $signed(n1114) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:63 */
  assign n1118 = n1116 == 32'b00000000000000000000000000000111;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:38 */
  assign n1119 = n1118 & n1113;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:67 */
  assign n1120 = rhythm & n1119;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  assign n1121 = {n1111, n1106};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:197:40 */
  assign n1123 = n1121 + 15'b010000000000000;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  assign n1124 = {n1111, n1106};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:196:21 */
  assign n1125 = n1120 ? n1123 : n1124;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:140:18 */
  assign n1126 = {n1048, n1049};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:202:36 */
  assign n1127 = n1126[19]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:202:51 */
  assign n1128 = ~n1127;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:140:18 */
  assign n1129 = {n1048, n1049};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:204:63 */
  assign n1130 = n1129[18:9]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:204:103 */
  assign n1132 = n1130 - 10'b0001000000;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:204:54 */
  assign n1134 = {5'b00000, n1132};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:204:44 */
  assign n1135 = n1125 + n1134;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:140:18 */
  assign n1136 = {n1048, n1049};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:207:76 */
  assign n1137 = n1136[18:9]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:207:68 */
  assign n1139 = 10'b1111000000 - n1137;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:207:54 */
  assign n1141 = {5'b00000, n1139};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:207:44 */
  assign n1142 = n1125 + n1141;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:202:25 */
  assign n1143 = n1128 ? n1135 : n1142;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:201:21 */
  assign n1144 = am ? n1143 : n1125;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:212:29 */
  assign n1145 = n1144[14:13]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:212:62 */
  assign n1147 = n1145 == 2'b00;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:213:39 */
  assign n1148 = n1144[12:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:212:21 */
  assign n1150 = n1147 ? n1148 : 13'b1111111111111;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:218:27 */
  assign n1152 = n1101 != 5'b00000;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:220:39 */
  assign n1153 = rks[3:2]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:220:34 */
  assign n1154 = {3'b0, n1153};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:220:34 */
  assign n1155 = n1101 + n1154;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:221:30 */
  assign n1156 = n1155[4]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:138:18 */
  assign n1158 = n1155[3:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:221:25 */
  assign n1159 = n1156 ? 4'b1111 : n1158;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:138:18 */
  assign n1160 = n1155[4]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:228:71 */
  assign n1162 = rks[1:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:228:67 */
  assign n1164 = {1'b1, n1162};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:228:61 */
  assign n1167 = {3'b0, n1164};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:228:61 */
  assign n1168 = 6'b000110 * n1167; // umul
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:143:18 */
  assign n1169 = n1161[17:1]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:138:18 */
  assign n1170 = {n1160, n1159};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:229:58 */
  assign n1171 = n1170[3:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:143:18 */
  assign n1172 = {n1169, n1168};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:229:43 */
  assign n1173 = n1172 << n1171;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:230:52 */
  assign n1174 = n1018_egphase - n1173;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:226:29 */
  assign n1176 = n1018_egstate == 2'b01;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:233:62 */
  assign n1178 = rks[1:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:233:58 */
  assign n1180 = {1'b1, n1178};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:138:18 */
  assign n1181 = {n1160, n1159};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:234:58 */
  assign n1182 = n1181[3:0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:234:71 */
  assign n1185 = n1182 - 4'b0001;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:143:18 */
  assign n1186 = {20'b00000000000000000000, n1180};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:234:44 */
  assign n1187 = n1186 << n1185;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:235:52 */
  assign n1188 = n1018_egphase + n1187;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:231:29 */
  assign n1190 = n1018_egstate == 2'b10;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:231:40 */
  assign n1192 = n1018_egstate == 2'b11;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:231:40 */
  assign n1193 = n1190 | n1192;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:236:29 */
  assign n1195 = n1018_egstate == 2'b00;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:225:25 */
  assign n1196 = {n1195, n1193, n1176};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:225:25 */
  always @*
    case (n1196)
      3'b100: n1197 = n1018_egphase;
      3'b010: n1197 = n1188;
      3'b001: n1197 = n1174;
      default: n1197 = n1018_egphase;
    endcase
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:218:21 */
  assign n1199 = {n1160, n1159};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:218:21 */
  assign n1200 = n1152 ? n1199 : n1101;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:218:21 */
  assign n1201 = n1152 ? n1197 : n1018_egphase;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:245:39 */
  assign n1203 = n1201[22]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:245:29 */
  assign n1205 = n1203 ? 23'b00000000000000000000000 : n1201;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:245:29 */
  assign n1207 = n1203 ? 2'b10 : n1018_egstate;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:244:25 */
  assign n1209 = n1018_egstate == 2'b01;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:250:39 */
  assign n1210 = n1201[22:18]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:250:82 */
  assign n1212 = {1'b0, sl};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:250:76 */
  assign n1213 = $unsigned(n1210) >= $unsigned(n1212);
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:250:29 */
  assign n1215 = n1213 ? 2'b11 : n1018_egstate;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:249:25 */
  assign n1217 = n1018_egstate == 2'b10;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:254:40 */
  assign n1218 = n1201[22:18]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:254:77 */
  assign n1220 = $unsigned(n1218) >= $unsigned(5'b01111);
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:254:29 */
  assign n1222 = n1220 ? 2'b00 : n1018_egstate;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:253:25 */
  assign n1224 = n1018_egstate == 2'b11;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:257:25 */
  assign n1226 = n1018_egstate == 2'b00;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:243:21 */
  assign n1227 = {n1226, n1224, n1217, n1209};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:243:21 */
  always @*
    case (n1227)
      4'b1000: n1229 = 23'b11111111111111111111111;
      4'b0100: n1229 = n1201;
      4'b0010: n1229 = n1201;
      4'b0001: n1229 = n1205;
      default: n1229 = n1201;
    endcase
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:243:21 */
  always @*
    case (n1227)
      4'b1000: n1230 = n1018_egstate;
      4'b0100: n1230 = n1222;
      4'b0010: n1230 = n1215;
      4'b0001: n1230 = n1207;
      default: n1230 = n1018_egstate;
    endcase
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:52 */
  assign n1234 = ~n1367;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:58 */
  assign n1235 = key & n1234;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:69 */
  assign n1241 = ~key;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:61 */
  assign n1242 = n1241 & n1370;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:87 */
  assign n1244 = n1230 != 2'b00;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:75 */
  assign n1245 = n1244 & n1242;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:21 */
  assign n1247 = n1245 ? 2'b11 : n1230;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:21 */
  assign n1248 = {1'b0, 22'b1111111111111111111111};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:21 */
  assign n1249 = n1235 ? n1248 : n1229;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:21 */
  assign n1251 = n1235 ? 2'b01 : n1247;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:272:30 */
  assign n1255 = {n1249, n1251};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:274:29 */
  assign n1256 = {30'b0, stage};  // uext
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:274:29 */
  assign n1258 = n1256 == 32'b00000000000000000000000000000011;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:274:17 */
  assign n1260 = n1258 ? 1'b0 : memwr;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1261 = n1060 ? n1150 : n1337;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1262 = n1060 ? n1255 : memin;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1264 = n1060 ? 1'b1 : n1260;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1265 = n1060 ? n1452 : n1018_lastkey;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1266 = n1060 ? n1200 : n1018_rm;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1267 = n1060 ? n1144 : n1018_egtmp;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1268 = n1060 ? n1249 : n1018_egphase;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:178:17 */
  assign n1269 = n1060 ? n1251 : n1018_egstate;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1271 = n1057 ? n1337 : n1261;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1272 = n1057 ? memin : n1262;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1273 = n1057 ? memwr : n1264;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1274 = n1057 ? n1018_lastkey : n1265;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1275 = n1057 ? n1018_rm : n1266;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1276 = n1057 ? n1018_egtmp : n1267;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1277 = n1057 ? n1018_egphase : n1268;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:175:17 */
  assign n1278 = n1057 ? n1018_egstate : n1269;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1280 = n1052 ? n1337 : n1271;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1281 = n1052 ? memin : n1272;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1282 = n1052 ? memwr : n1273;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1283 = n1052 ? n1018_lastkey : n1274;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1284 = n1052 ? n1018_rm : n1275;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1285 = n1052 ? n1018_egtmp : n1276;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1286 = n1052 ? n1054 : n1277;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:171:17 */
  assign n1287 = n1052 ? n1053 : n1278;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:160:13 */
  assign n1295 = {n1048, n1049};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:160:13 */
  assign n1300 = {n1032, n1039};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:146:9 */
  assign n1324 = {5'b00001, 15'b000000000000000};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:61:9 */
  assign n1334 = ~reset;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:61:9 */
  assign n1335 = clkena & n1334;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1336 = n1335 ? n1280 : n1337;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk)
    n1337 <= n1336;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:123:9 */
  assign n1338 = n1013 ? n1011 : rslot;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:123:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1339 <= 5'b00000;
    else
      n1339 <= n1338;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:90:12 */
  assign n1340 = ~reset;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:90:12 */
  assign n1341 = clkena & n1340;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1342 = n1341 ? n1281 : memin;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk)
    n1343 <= n1342;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1344 = clkena ? n1282 : memwr;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1345 <= 1'b0;
    else
      n1345 <= n1344;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:94:12 */
  assign n1346 = ~reset;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1347 = n1346 ? n1031 : aridx;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk)
    n1348 <= n1347;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1349 = clkena ? n1283 : n1018_lastkey;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1350 <= 18'b000000000000000000;
    else
      n1350 <= n1349;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1351 = clkena ? n1284 : n1018_rm;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1352 <= 5'b00000;
    else
      n1352 <= n1351;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  assign n1353 = ~reset;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:139:18 */
  assign n1354 = clkena & n1353;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1355 = n1354 ? n1285 : n1018_egtmp;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk)
    n1356 <= n1355;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1357 = clkena ? n1295 : n1018_amphase;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1358 <= n1324;
    else
      n1358 <= n1357;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1359 = clkena ? n1286 : n1018_egphase;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1360 <= 23'b00000000000000000000000;
    else
      n1360 <= n1359;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1361 = clkena ? n1287 : n1018_egstate;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1362 <= 2'b00;
    else
      n1362 <= n1361;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  assign n1363 = clkena ? n1300 : n1018_ntable;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:156:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n1364 <= 18'b111111111111111111;
    else
      n1364 <= n1363;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:32 */
  assign n1366 = {14'bX, n1018_lastkey};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:262:32 */
  assign n1367 = n1366[slot * 1 +: 1]; //(Bmux)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:35 */
  assign n1369 = {14'bX, n1018_lastkey};
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:266:35 */
  assign n1370 = n1369[slot * 1 +: 1]; //(Bmux)
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1371 = slot[4]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1372 = ~n1371;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1373 = slot[3]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1374 = ~n1373;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1375 = n1372 & n1374;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1376 = n1372 & n1373;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1377 = n1371 & n1374;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1378 = slot[2]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1379 = ~n1378;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1380 = n1375 & n1379;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1381 = n1375 & n1378;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1382 = n1376 & n1379;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1383 = n1376 & n1378;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1384 = n1377 & n1379;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1385 = slot[1]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1386 = ~n1385;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1387 = n1380 & n1386;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1388 = n1380 & n1385;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1389 = n1381 & n1386;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1390 = n1381 & n1385;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1391 = n1382 & n1386;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1392 = n1382 & n1385;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1393 = n1383 & n1386;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1394 = n1383 & n1385;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1395 = n1384 & n1386;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1396 = slot[0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1397 = ~n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1398 = n1387 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1399 = n1387 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1400 = n1388 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1401 = n1388 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1402 = n1389 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1403 = n1389 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1404 = n1390 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1405 = n1390 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1406 = n1391 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1407 = n1391 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1408 = n1392 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1409 = n1392 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1410 = n1393 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1411 = n1393 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1412 = n1394 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1413 = n1394 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1414 = n1395 & n1397;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1415 = n1395 & n1396;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1416 = n1018_lastkey[0]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1417 = n1398 ? key : n1416;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1418 = n1018_lastkey[1]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1419 = n1399 ? key : n1418;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1420 = n1018_lastkey[2]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1421 = n1400 ? key : n1420;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1422 = n1018_lastkey[3]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1423 = n1401 ? key : n1422;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1424 = n1018_lastkey[4]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1425 = n1402 ? key : n1424;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1426 = n1018_lastkey[5]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1427 = n1403 ? key : n1426;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1428 = n1018_lastkey[6]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1429 = n1404 ? key : n1428;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1430 = n1018_lastkey[7]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1431 = n1405 ? key : n1430;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1432 = n1018_lastkey[8]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1433 = n1406 ? key : n1432;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1434 = n1018_lastkey[9]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1435 = n1407 ? key : n1434;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1436 = n1018_lastkey[10]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1437 = n1408 ? key : n1436;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1438 = n1018_lastkey[11]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1439 = n1409 ? key : n1438;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1440 = n1018_lastkey[12]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1441 = n1410 ? key : n1440;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1442 = n1018_lastkey[13]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1443 = n1411 ? key : n1442;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1444 = n1018_lastkey[14]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1445 = n1412 ? key : n1444;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1446 = n1018_lastkey[15]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1447 = n1413 ? key : n1446;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1448 = n1018_lastkey[16]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1449 = n1414 ? key : n1448;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1450 = n1018_lastkey[17]; // extract
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1451 = n1415 ? key : n1450;
  /*# work/sms-vhdl/compat/envelopegenerator.vhd:269:21 */
  assign n1452 = {n1451, n1449, n1447, n1445, n1443, n1441, n1439, n1437, n1435, n1433, n1431, n1429, n1427, n1425, n1423, n1421, n1419, n1417};
endmodule

module controller_Brtl
  (input  clk,
   input  reset,
   input  clkena,
   input  [4:0] slot,
   input  [1:0] stage,
   input  wr,
   input  [7:0] addr,
   input  [7:0] data,
   output am,
   output pm,
   output wf,
   output [3:0] ml,
   output [6:0] tl,
   output [2:0] fb,
   output [3:0] ar,
   output [3:0] dr,
   output [3:0] sl,
   output [3:0] rr,
   output [2:0] blk,
   output [8:0] fnum,
   output [3:0] rks,
   output key,
   output rhythm);
  wire [35:0] inst_cache;
  wire [5:0] slot_voice_addr;
  wire [35:0] slot_voice_data;
  wire user_voice_wr;
  wire [5:0] user_voice_addr;
  wire [35:0] user_voice_rdata;
  wire [35:0] user_voice_wdata;
  wire regs_wr;
  wire [3:0] regs_addr;
  wire [23:0] regs_rdata;
  wire [23:0] regs_wdata;
  wire [7:0] rflag;
  wire [3:0] w_channel;
  wire [23:0] u_register_memory_n242;
  wire [35:0] vmem_n245;
  wire [35:0] vmem_n246;
  wire \vmem.odata[am] ;
  wire \vmem.odata[pm] ;
  wire \vmem.odata[eg] ;
  wire \vmem.odata[kr] ;
  wire [3:0] \vmem.odata[ml] ;
  wire [1:0] \vmem.odata[kl] ;
  wire [5:0] \vmem.odata[tl] ;
  wire \vmem.odata[wf] ;
  wire [2:0] \vmem.odata[fb] ;
  wire [3:0] \vmem.odata[ar] ;
  wire [3:0] \vmem.odata[dr] ;
  wire [3:0] \vmem.odata[sl] ;
  wire [3:0] \vmem.odata[rr] ;
  wire \vmem.rodata[am] ;
  wire \vmem.rodata[pm] ;
  wire \vmem.rodata[eg] ;
  wire \vmem.rodata[kr] ;
  wire [3:0] \vmem.rodata[ml] ;
  wire [1:0] \vmem.rodata[kl] ;
  wire [5:0] \vmem.rodata[tl] ;
  wire \vmem.rodata[wf] ;
  wire [2:0] \vmem.rodata[fb] ;
  wire [3:0] \vmem.rodata[ar] ;
  wire [3:0] \vmem.rodata[dr] ;
  wire [3:0] \vmem.rodata[sl] ;
  wire [3:0] \vmem.rodata[rr] ;
  wire n247;
  wire n248;
  wire n249;
  wire n250;
  wire [3:0] n251;
  wire [1:0] n252;
  wire [5:0] n253;
  wire n254;
  wire [2:0] n255;
  wire [3:0] n256;
  wire [3:0] n257;
  wire [3:0] n258;
  wire [3:0] n259;
  wire [35:0] n260;
  wire [35:0] n262;
  wire n270;
  wire [3:0] n271;
  wire n273;
  wire n282;
  wire n283;
  wire n285;
  wire n286;
  wire [31:0] n287;
  wire [31:0] n289;
  wire [31:0] n291;
  wire [5:0] n292;
  wire [31:0] n293;
  wire [31:0] n295;
  wire [3:0] n296;
  wire [3:0] n298;
  wire [31:0] n301;
  wire [31:0] n303;
  wire [31:0] n304;
  wire n305;
  wire [31:0] n306;
  wire [31:0] n307;
  wire [5:0] n308;
  wire [5:0] n309;
  wire n311;
  wire [3:0] n316;
  reg n317_kflag;
  reg n317_extra_mode;
  reg [5:0] n317_vindex;
  wire [31:0] n329;
  wire n330;
  wire [5:0] n332;
  wire n334;
  wire n336;
  wire n337;
  wire [31:0] n338;
  wire n340;
  wire n341;
  wire [1:0] n342;
  wire n343;
  wire [31:0] n344;
  wire [31:0] n345;
  wire n346;
  wire [31:0] n347;
  wire n348;
  wire n349;
  wire n350;
  wire n351;
  wire n352;
  wire [3:0] n353;
  wire n355;
  wire [7:0] n356;
  wire [7:0] n357;
  wire [7:0] n358;
  wire n360;
  wire n361;
  wire n362;
  wire [31:0] n363;
  wire n364;
  wire [31:0] n365;
  wire n367;
  wire n368;
  wire [1:0] n369;
  wire [5:0] n370;
  wire n371;
  wire [31:0] n372;
  wire n373;
  wire [31:0] n374;
  wire n376;
  wire n377;
  wire n378;
  wire [2:0] n379;
  wire n380;
  wire [31:0] n381;
  wire n382;
  wire [31:0] n383;
  wire n385;
  wire n386;
  wire [1:0] n387;
  wire n388;
  wire n390;
  wire [1:0] n391;
  wire [1:0] n392;
  wire n393;
  wire n394;
  wire n396;
  wire [3:0] n397;
  wire [1:0] n398;
  wire [1:0] n399;
  wire n400;
  wire n401;
  wire [2:0] n402;
  wire [2:0] n403;
  wire [2:0] n404;
  wire n406;
  wire [3:0] n407;
  wire [7:0] n408;
  wire [1:0] n409;
  wire [1:0] n410;
  wire [5:0] n411;
  wire [5:0] n412;
  wire [5:0] n413;
  wire [3:0] n414;
  wire [3:0] n415;
  wire n417;
  wire n418;
  wire [31:0] n419;
  wire [31:0] n420;
  wire n421;
  wire [31:0] n422;
  wire n423;
  wire [3:0] n424;
  wire [3:0] n425;
  wire n427;
  wire [7:0] n428;
  wire [7:0] n429;
  wire [7:0] n430;
  wire n432;
  wire n433;
  wire [31:0] n434;
  wire [31:0] n435;
  wire n436;
  wire [31:0] n437;
  wire n438;
  wire [3:0] n439;
  wire [3:0] n440;
  wire n442;
  wire [7:0] n443;
  wire [7:0] n444;
  wire [7:0] n445;
  wire n447;
  wire [3:0] n448;
  reg n449;
  wire [7:0] n450;
  reg [7:0] n451;
  wire [1:0] n452;
  reg [1:0] n453;
  wire [5:0] n454;
  reg [5:0] n455;
  wire [3:0] n456;
  reg [3:0] n457;
  wire [7:0] n458;
  reg [7:0] n459;
  wire [7:0] n460;
  reg [7:0] n461;
  wire [35:0] n467;
  wire [31:0] n468;
  wire n470;
  wire [31:0] n471;
  wire n473;
  wire [31:0] n474;
  wire n476;
  wire [3:0] n477;
  wire [31:0] n478;
  wire [31:0] n479;
  wire [31:0] n481;
  wire n482;
  wire [1:0] n483;
  wire n485;
  wire n486;
  wire n487;
  wire [2:0] n488;
  wire n489;
  wire n491;
  wire [3:0] n492;
  wire [3:0] n493;
  wire n495;
  wire [2:0] n496;
  reg n500;
  wire [7:0] n501;
  reg [7:0] n502;
  wire n503;
  reg n504;
  wire [2:0] n505;
  reg [2:0] n506;
  wire n507;
  reg n508;
  wire n509;
  reg n510;
  wire [3:0] n511;
  reg [3:0] n512;
  wire [3:0] n513;
  reg [3:0] n514;
  wire [1:0] n521;
  wire [23:0] n522;
  wire n523;
  wire [23:0] n524;
  wire [31:0] n527;
  wire n529;
  wire n531;
  wire n534;
  wire n535;
  wire n536;
  wire n537;
  wire n539;
  wire n540;
  wire [23:0] n541;
  wire n543;
  wire n544;
  wire [23:0] n545;
  wire [7:0] n546;
  wire n548;
  wire n549;
  wire [35:0] n550;
  wire n551;
  wire [23:0] n552;
  wire [7:0] n553;
  wire n557;
  wire n558;
  wire n559;
  wire n560;
  wire [23:0] n561;
  wire [7:0] n562;
  wire n565;
  wire n567;
  wire [31:0] n568;
  wire [31:0] n570;
  wire [3:0] n571;
  wire [3:0] n573;
  wire [3:0] n575;
  wire n578;
  wire n579;
  wire [31:0] n581;
  wire n582;
  wire n583;
  wire n584;
  wire n586;
  wire n588;
  wire n589;
  wire n590;
  wire n592;
  wire n593;
  wire n595;
  wire n596;
  wire n598;
  wire n599;
  wire n601;
  wire [4:0] n602;
  reg n603;
  wire n605;
  wire n606;
  wire n607;
  wire [3:0] n608;
  wire [6:0] n616;
  wire [2:0] n617;
  wire [2:0] n619;
  wire [3:0] n621;
  wire [6:0] n623;
  wire [6:0] n624;
  wire [7:0] n626;
  wire n627;
  wire [1:0] n628;
  wire n630;
  wire n631;
  wire [1:0] n632;
  wire [1:0] n634;
  wire [7:0] n635;
  wire [7:0] n637;
  wire n638;
  wire n640;
  wire n642;
  wire n643;
  wire n644;
  wire [3:0] n645;
  wire [4:0] n647;
  wire [7:0] n649;
  wire n650;
  wire n651;
  wire [5:0] n652;
  wire [6:0] n654;
  wire [7:0] n656;
  wire [3:0] n657;
  wire [4:0] n659;
  wire [7:0] n661;
  wire [7:0] n662;
  wire [7:0] n663;
  wire [7:0] n664;
  wire n665;
  wire [6:0] n666;
  wire [6:0] n668;
  wire [8:0] n669;
  wire [2:0] n670;
  wire n671;
  wire [31:0] n673;
  wire n674;
  wire n675;
  wire n676;
  wire [1:0] n677;
  wire [3:0] n679;
  wire [3:0] n681;
  wire n682;
  wire [2:0] n683;
  wire n684;
  wire [3:0] n685;
  wire [1:0] n686;
  wire [3:0] n688;
  wire [3:0] n689;
  wire [3:0] n690;
  wire n691;
  wire n692;
  wire [3:0] n693;
  wire n694;
  wire [2:0] n695;
  wire [3:0] n696;
  wire [3:0] n697;
  wire [3:0] n698;
  wire n699;
  wire [3:0] n700;
  wire [3:0] n702;
  wire n703;
  wire n704;
  wire n705;
  wire [31:0] n706;
  wire [31:0] n708;
  wire n710;
  wire n711;
  wire n712;
  wire n713;
  wire n714;
  wire n715;
  wire n716;
  wire [3:0] n717;
  wire [3:0] n719;
  wire [3:0] n721;
  wire [3:0] n723;
  wire [3:0] n724;
  wire n726;
  wire [3:0] n727;
  reg n728;
  reg n729;
  reg n730;
  reg [3:0] n731;
  reg [6:0] n732;
  reg [2:0] n733;
  reg [3:0] n734;
  reg [3:0] n735;
  reg [3:0] n736;
  reg [3:0] n737;
  reg [2:0] n738;
  reg [8:0] n739;
  reg [3:0] n740;
  reg n741;
  reg n742;
  reg [35:0] n743;
  reg n745;
  reg [5:0] n746;
  reg [35:0] n747;
  reg n749;
  reg [23:0] n750;
  reg [7:0] n751;
  reg n752;
  reg n759;
  reg [5:0] n760;
  wire n877;
  wire n878;
  wire n879;
  reg n880;
  wire n881;
  wire n882;
  wire n883;
  reg n884;
  wire n885;
  reg n886;
  wire [3:0] n887;
  reg [3:0] n888;
  wire [6:0] n889;
  reg [6:0] n890;
  wire [2:0] n891;
  reg [2:0] n892;
  wire [3:0] n893;
  reg [3:0] n894;
  wire [3:0] n895;
  reg [3:0] n896;
  wire [3:0] n897;
  reg [3:0] n898;
  wire [3:0] n899;
  reg [3:0] n900;
  wire [2:0] n901;
  reg [2:0] n902;
  wire [8:0] n903;
  reg [8:0] n904;
  wire [3:0] n905;
  reg [3:0] n906;
  wire n907;
  reg n908;
  wire n909;
  reg n910;
  wire n911;
  wire n912;
  wire [35:0] n913;
  reg [35:0] n914;
  wire [5:0] n915;
  reg [5:0] n916;
  wire n917;
  reg n918;
  wire [5:0] n919;
  reg [5:0] n920;
  wire n921;
  wire n922;
  wire [35:0] n923;
  reg [35:0] n924;
  wire n925;
  reg n926;
  wire [3:0] n927;
  reg [3:0] n928;
  wire n929;
  wire n930;
  wire [23:0] n931;
  reg [23:0] n932;
  wire [7:0] n933;
  reg [7:0] n934;
  wire n935;
  reg n936;
  wire n937;
  reg n938;
  wire [5:0] n939;
  reg [5:0] n940;
  wire [5:0] n943; // mem_rd
  wire [63:0] n945;
  wire [3:0] n946;
  wire n947;
  wire n948;
  wire n949;
  wire n950;
  wire n951;
  wire n952;
  wire n953;
  wire n954;
  wire n955;
  wire n956;
  wire n957;
  wire n958;
  wire n959;
  wire n960;
  wire n961;
  wire n962;
  wire n963;
  wire n964;
  wire n965;
  wire n966;
  wire n967;
  wire n968;
  wire n969;
  wire n970;
  wire n971;
  wire [3:0] n972;
  wire [3:0] n973;
  wire [3:0] n974;
  wire [3:0] n975;
  wire [3:0] n976;
  wire [3:0] n977;
  wire [3:0] n978;
  wire [3:0] n979;
  wire [3:0] n980;
  wire [3:0] n981;
  wire [3:0] n982;
  wire [3:0] n983;
  wire [3:0] n984;
  wire [3:0] n985;
  wire [3:0] n986;
  wire [3:0] n987;
  wire [3:0] n988;
  wire [3:0] n989;
  wire [35:0] n990;
  assign am = n880; //(module output)
  assign pm = n884; //(module output)
  assign wf = n886; //(module output)
  assign ml = n888; //(module output)
  assign tl = n890; //(module output)
  assign fb = n892; //(module output)
  assign ar = n894; //(module output)
  assign dr = n896; //(module output)
  assign sl = n898; //(module output)
  assign rr = n900; //(module output)
  assign blk = n902; //(module output)
  assign fnum = n904; //(module output)
  assign rks = n906; //(module output)
  assign key = n908; //(module output)
  assign rhythm = n910; //(module output)
  /*# work/sms-vhdl/compat/controller.vhd:132:12 */
  assign inst_cache = n914; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:143:12 */
  assign slot_voice_addr = n916; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:144:12 */
  assign slot_voice_data = vmem_n246; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:147:12 */
  assign user_voice_wr = n918; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:148:12 */
  assign user_voice_addr = n920; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:149:12 */
  assign user_voice_rdata = vmem_n245; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:150:12 */
  assign user_voice_wdata = n924; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:153:12 */
  assign regs_wr = n926; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:154:12 */
  assign regs_addr = n928; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:155:12 */
  assign regs_rdata = u_register_memory_n242; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:156:12 */
  assign regs_wdata = n932; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:158:12 */
  assign rflag = n934; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:159:12 */
  assign w_channel = n316; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:165:5 */
  registermemory_Brtl u_register_memory (
    .clk(clk),
    .reset(reset),
    .addr(regs_addr),
    .wr(regs_wr),
    .idata(regs_wdata),
    .odata(u_register_memory_n242));
  /*# work/sms-vhdl/compat/controller.vhd:177:9 */
  assign vmem_n245 = n260; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:177:27 */
  assign vmem_n246 = n262; // (signal)
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  voicememory_Brtl vmem (
    .clk(clk),
    .reset(reset),
    .\idata[am] (n247),
    .\idata[pm] (n248),
    .\idata[eg] (n249),
    .\idata[kr] (n250),
    .\idata[ml] (n251),
    .\idata[kl] (n252),
    .\idata[tl] (n253),
    .\idata[wf] (n254),
    .\idata[fb] (n255),
    .\idata[ar] (n256),
    .\idata[dr] (n257),
    .\idata[sl] (n258),
    .\idata[rr] (n259),
    .wr(user_voice_wr),
    .rwaddr(user_voice_addr),
    .roaddr(slot_voice_addr),
    .\odata[am] (\vmem.odata[am] ),
    .\odata[pm] (\vmem.odata[pm] ),
    .\odata[eg] (\vmem.odata[eg] ),
    .\odata[kr] (\vmem.odata[kr] ),
    .\odata[ml] (\vmem.odata[ml] ),
    .\odata[kl] (\vmem.odata[kl] ),
    .\odata[tl] (\vmem.odata[tl] ),
    .\odata[wf] (\vmem.odata[wf] ),
    .\odata[fb] (\vmem.odata[fb] ),
    .\odata[ar] (\vmem.odata[ar] ),
    .\odata[dr] (\vmem.odata[dr] ),
    .\odata[sl] (\vmem.odata[sl] ),
    .\odata[rr] (\vmem.odata[rr] ),
    .\rodata[am] (\vmem.rodata[am] ),
    .\rodata[pm] (\vmem.rodata[pm] ),
    .\rodata[eg] (\vmem.rodata[eg] ),
    .\rodata[kr] (\vmem.rodata[kr] ),
    .\rodata[ml] (\vmem.rodata[ml] ),
    .\rodata[kl] (\vmem.rodata[kl] ),
    .\rodata[tl] (\vmem.rodata[tl] ),
    .\rodata[wf] (\vmem.rodata[wf] ),
    .\rodata[fb] (\vmem.rodata[fb] ),
    .\rodata[ar] (\vmem.rodata[ar] ),
    .\rodata[dr] (\vmem.rodata[dr] ),
    .\rodata[sl] (\vmem.rodata[sl] ),
    .\rodata[rr] (\vmem.rodata[rr] ));
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n247 = user_voice_wdata[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n248 = user_voice_wdata[1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n249 = user_voice_wdata[2]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n250 = user_voice_wdata[3]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n251 = user_voice_wdata[7:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n252 = user_voice_wdata[9:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n253 = user_voice_wdata[15:10]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n254 = user_voice_wdata[16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n255 = user_voice_wdata[19:17]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n256 = user_voice_wdata[23:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n257 = user_voice_wdata[27:24]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n258 = user_voice_wdata[31:28]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n259 = user_voice_wdata[35:32]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n260 = {\vmem.odata[rr] , \vmem.odata[sl] , \vmem.odata[dr] , \vmem.odata[ar] , \vmem.odata[fb] , \vmem.odata[wf] , \vmem.odata[tl] , \vmem.odata[kl] , \vmem.odata[ml] , \vmem.odata[kr] , \vmem.odata[eg] , \vmem.odata[pm] , \vmem.odata[am] };
  /*# work/sms-vhdl/compat/controller.vhd:175:5 */
  assign n262 = {\vmem.rodata[rr] , \vmem.rodata[sl] , \vmem.rodata[dr] , \vmem.rodata[ar] , \vmem.rodata[fb] , \vmem.rodata[wf] , \vmem.rodata[tl] , \vmem.rodata[kl] , \vmem.rodata[ml] , \vmem.rodata[kr] , \vmem.rodata[eg] , \vmem.rodata[pm] , \vmem.rodata[am] };
  /*# work/sms-vhdl/compat/controller.vhd:186:27 */
  assign n270 = stage == 2'b00;
  /*# work/sms-vhdl/compat/controller.vhd:187:38 */
  assign n271 = slot[4:1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:185:13 */
  assign n273 = n270 & clkena;
  /*# work/sms-vhdl/compat/controller.vhd:202:27 */
  assign n282 = stage == 2'b00;
  /*# work/sms-vhdl/compat/controller.vhd:203:30 */
  assign n283 = rflag[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:203:54 */
  assign n285 = $unsigned(w_channel) >= $unsigned(4'b0110);
  /*# work/sms-vhdl/compat/controller.vhd:203:40 */
  assign n286 = n285 & n283;
  /*# work/sms-vhdl/compat/controller.vhd:205:44 */
  assign n287 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:205:63 */
  assign n289 = n287 - 32'b00000000000000000000000000001100;
  /*# work/sms-vhdl/compat/controller.vhd:205:68 */
  assign n291 = n289 + 32'b00000000000000000000000000100000;
  /*# work/sms-vhdl/compat/controller.vhd:205:44 */
  assign n292 = n291[5:0];  // trunc
  /*# work/sms-vhdl/compat/controller.vhd:207:55 */
  assign n293 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:207:73 */
  assign n295 = $signed(n293) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/controller.vhd:207:73 */
  assign n296 = n295[3:0];  // trunc
  /*# work/sms-vhdl/compat/controller.vhd:207:73 */
  assign n298 = 4'b1000 - n296;
  /*# work/sms-vhdl/compat/controller.vhd:207:77 */
  assign n301 = {28'b0, n946};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:207:77 */
  assign n303 = $signed(n301) * $signed(32'b00000000000000000000000000000010); // smul
  /*# work/sms-vhdl/compat/controller.vhd:207:83 */
  assign n304 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:207:102 */
  assign n305 = n304[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:207:102 */
  assign n306 = {31'b0, n305};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:207:81 */
  assign n307 = n303 + n306;
  /*# work/sms-vhdl/compat/controller.vhd:207:44 */
  assign n308 = n307[5:0];  // trunc
  /*# work/sms-vhdl/compat/controller.vhd:203:21 */
  assign n309 = n286 ? n292 : n308;
  /*# work/sms-vhdl/compat/controller.vhd:201:13 */
  assign n311 = n282 & clkena;
  /*# work/sms-vhdl/compat/controller.vhd:216:28 */
  assign n316 = slot[4:1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:221:18 */
  always @*
    n317_kflag = n936; // (isignal)
  initial
    n317_kflag = 1'bX;
  /*# work/sms-vhdl/compat/controller.vhd:231:18 */
  always @*
    n317_extra_mode = n938; // (isignal)
  initial
    n317_extra_mode = 1'bX;
  /*# work/sms-vhdl/compat/controller.vhd:232:18 */
  always @*
    n317_vindex = n940; // (isignal)
  initial
    n317_vindex = 6'b000000;
  /*# work/sms-vhdl/compat/controller.vhd:273:32 */
  assign n329 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:273:51 */
  assign n330 = n329[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:273:22 */
  assign n332 = {5'b0, n330};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:269:13 */
  assign n334 = stage == 2'b00;
  /*# work/sms-vhdl/compat/controller.vhd:289:13 */
  assign n336 = stage == 2'b01;
  /*# work/sms-vhdl/compat/controller.vhd:301:36 */
  assign n337 = ~n317_extra_mode;
  /*# work/sms-vhdl/compat/controller.vhd:301:46 */
  assign n338 = {24'b0, addr};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:301:65 */
  assign n340 = $signed(n338) < $signed(32'b00000000000000000000000000001000);
  /*# work/sms-vhdl/compat/controller.vhd:301:42 */
  assign n341 = n340 & n337;
  /*# work/sms-vhdl/compat/controller.vhd:306:34 */
  assign n342 = addr[2:1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:308:53 */
  assign n343 = addr[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:308:36 */
  assign n344 = {31'b0, n343};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:308:77 */
  assign n345 = {26'b0, n317_vindex};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:308:77 */
  assign n346 = n345[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:308:77 */
  assign n347 = {31'b0, n346};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:308:67 */
  assign n348 = n344 == n347;
  /*# work/sms-vhdl/compat/controller.vhd:309:62 */
  assign n349 = data[7]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:310:62 */
  assign n350 = data[6]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:311:62 */
  assign n351 = data[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:312:62 */
  assign n352 = data[4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:313:62 */
  assign n353 = data[3:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:308:33 */
  assign n355 = n348 ? 1'b1 : user_voice_wr;
  /*# work/sms-vhdl/compat/controller.vhd:308:33 */
  assign n356 = {n353, n352, n351, n350, n349};
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n357 = user_voice_rdata[7:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:308:33 */
  assign n358 = n348 ? n356 : n357;
  /*# work/sms-vhdl/compat/controller.vhd:307:29 */
  assign n360 = n342 == 2'b00;
  /*# work/sms-vhdl/compat/controller.vhd:318:40 */
  assign n361 = addr[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:318:43 */
  assign n362 = ~n361;
  /*# work/sms-vhdl/compat/controller.vhd:318:60 */
  assign n363 = {26'b0, n317_vindex};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:318:60 */
  assign n364 = n363[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:318:60 */
  assign n365 = {31'b0, n364};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:318:66 */
  assign n367 = n365 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/controller.vhd:318:48 */
  assign n368 = n367 & n362;
  /*# work/sms-vhdl/compat/controller.vhd:319:62 */
  assign n369 = data[7:6]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:320:62 */
  assign n370 = data[5:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:322:43 */
  assign n371 = addr[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:322:63 */
  assign n372 = {26'b0, n317_vindex};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:322:63 */
  assign n373 = n372[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:322:63 */
  assign n374 = {31'b0, n373};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:322:69 */
  assign n376 = n374 == 32'b00000000000000000000000000000000;
  /*# work/sms-vhdl/compat/controller.vhd:322:51 */
  assign n377 = n376 & n371;
  /*# work/sms-vhdl/compat/controller.vhd:323:62 */
  assign n378 = data[3]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:324:62 */
  assign n379 = data[2:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:326:43 */
  assign n380 = addr[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:326:63 */
  assign n381 = {26'b0, n317_vindex};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:326:63 */
  assign n382 = n381[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:326:63 */
  assign n383 = {31'b0, n382};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:326:69 */
  assign n385 = n383 == 32'b00000000000000000000000000000001;
  /*# work/sms-vhdl/compat/controller.vhd:326:51 */
  assign n386 = n385 & n380;
  /*# work/sms-vhdl/compat/controller.vhd:327:62 */
  assign n387 = data[7:6]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:328:62 */
  assign n388 = data[4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:326:33 */
  assign n390 = n386 ? 1'b1 : user_voice_wr;
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n391 = user_voice_rdata[9:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:326:33 */
  assign n392 = n386 ? n387 : n391;
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n393 = user_voice_rdata[16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:326:33 */
  assign n394 = n386 ? n388 : n393;
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n396 = n377 ? 1'b1 : n390;
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n397 = {n379, n378};
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n398 = user_voice_rdata[9:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n399 = n377 ? n398 : n392;
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n400 = n397[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n401 = n377 ? n400 : n394;
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n402 = n397[3:1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n403 = user_voice_rdata[19:17]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:322:33 */
  assign n404 = n377 ? n402 : n403;
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n406 = n368 ? 1'b1 : n396;
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n407 = {n404, n401};
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n408 = {n370, n369};
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n409 = n408[1:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n410 = n368 ? n409 : n399;
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n411 = n408[7:2]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n412 = user_voice_rdata[15:10]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n413 = n368 ? n411 : n412;
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n414 = user_voice_rdata[19:16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:318:33 */
  assign n415 = n368 ? n414 : n407;
  /*# work/sms-vhdl/compat/controller.vhd:317:29 */
  assign n417 = n342 == 2'b01;
  /*# work/sms-vhdl/compat/controller.vhd:333:53 */
  assign n418 = addr[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:333:36 */
  assign n419 = {31'b0, n418};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:333:77 */
  assign n420 = {26'b0, n317_vindex};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:333:77 */
  assign n421 = n420[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:333:77 */
  assign n422 = {31'b0, n421};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:333:67 */
  assign n423 = n419 == n422;
  /*# work/sms-vhdl/compat/controller.vhd:334:62 */
  assign n424 = data[7:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:335:62 */
  assign n425 = data[3:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:333:33 */
  assign n427 = n423 ? 1'b1 : user_voice_wr;
  /*# work/sms-vhdl/compat/controller.vhd:333:33 */
  assign n428 = {n425, n424};
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n429 = user_voice_rdata[27:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:333:33 */
  assign n430 = n423 ? n428 : n429;
  /*# work/sms-vhdl/compat/controller.vhd:332:29 */
  assign n432 = n342 == 2'b10;
  /*# work/sms-vhdl/compat/controller.vhd:340:53 */
  assign n433 = addr[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:340:36 */
  assign n434 = {31'b0, n433};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:340:77 */
  assign n435 = {26'b0, n317_vindex};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:340:77 */
  assign n436 = n435[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:340:77 */
  assign n437 = {31'b0, n436};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:340:67 */
  assign n438 = n434 == n437;
  /*# work/sms-vhdl/compat/controller.vhd:341:62 */
  assign n439 = data[7:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:342:62 */
  assign n440 = data[3:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:340:33 */
  assign n442 = n438 ? 1'b1 : user_voice_wr;
  /*# work/sms-vhdl/compat/controller.vhd:340:33 */
  assign n443 = {n440, n439};
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n444 = user_voice_rdata[35:28]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:340:33 */
  assign n445 = n438 ? n443 : n444;
  /*# work/sms-vhdl/compat/controller.vhd:339:29 */
  assign n447 = n342 == 2'b11;
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  assign n448 = {n447, n432, n417, n360};
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n449 = n442;
      4'b0100: n449 = n427;
      4'b0010: n449 = n406;
      4'b0001: n449 = n355;
      default: n449 = user_voice_wr;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n450 = user_voice_rdata[7:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n451 = n450;
      4'b0100: n451 = n450;
      4'b0010: n451 = n450;
      4'b0001: n451 = n358;
      default: n451 = n450;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n452 = user_voice_rdata[9:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n453 = n452;
      4'b0100: n453 = n452;
      4'b0010: n453 = n410;
      4'b0001: n453 = n452;
      default: n453 = n452;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n454 = user_voice_rdata[15:10]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n455 = n454;
      4'b0100: n455 = n454;
      4'b0010: n455 = n413;
      4'b0001: n455 = n454;
      default: n455 = n454;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n456 = user_voice_rdata[19:16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n457 = n456;
      4'b0100: n457 = n456;
      4'b0010: n457 = n415;
      4'b0001: n457 = n456;
      default: n457 = n456;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n458 = user_voice_rdata[27:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n459 = n458;
      4'b0100: n459 = n430;
      4'b0010: n459 = n458;
      4'b0001: n459 = n458;
      default: n459 = n458;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n460 = user_voice_rdata[35:28]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:306:25 */
  always @*
    case (n448)
      4'b1000: n461 = n445;
      4'b0100: n461 = n460;
      4'b0010: n461 = n460;
      4'b0001: n461 = n460;
      default: n461 = n460;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:226:18 */
  assign n467 = {n461, n459, n457, n455, n453, n451};
  /*# work/sms-vhdl/compat/controller.vhd:350:27 */
  assign n468 = {24'b0, addr};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:350:46 */
  assign n470 = n468 == 32'b00000000000000000000000000001110;
  /*# work/sms-vhdl/compat/controller.vhd:354:27 */
  assign n471 = {24'b0, addr};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:354:46 */
  assign n473 = $signed(n471) < $signed(32'b00000000000000000000000000010000);
  /*# work/sms-vhdl/compat/controller.vhd:358:27 */
  assign n474 = {24'b0, addr};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:358:46 */
  assign n476 = $signed(n474) <= $signed(32'b00000000000000000000000000111111);
  /*# work/sms-vhdl/compat/controller.vhd:360:46 */
  assign n477 = addr[3:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:360:29 */
  assign n478 = {28'b0, n477};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:360:63 */
  assign n479 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:360:82 */
  assign n481 = $signed(n479) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/controller.vhd:360:61 */
  assign n482 = n478 == n481;
  /*# work/sms-vhdl/compat/controller.vhd:362:38 */
  assign n483 = addr[5:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:363:33 */
  assign n485 = n483 == 2'b01;
  /*# work/sms-vhdl/compat/controller.vhd:367:57 */
  assign n486 = data[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:368:57 */
  assign n487 = data[4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:369:66 */
  assign n488 = data[3:1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:370:56 */
  assign n489 = data[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:366:33 */
  assign n491 = n483 == 2'b10;
  /*# work/sms-vhdl/compat/controller.vhd:373:67 */
  assign n492 = data[7:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:374:67 */
  assign n493 = data[3:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:372:33 */
  assign n495 = n483 == 2'b11;
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  assign n496 = {n495, n491, n485};
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n500 = 1'b1;
      3'b010: n500 = 1'b1;
      3'b001: n500 = 1'b1;
      default: n500 = regs_wr;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n501 = regs_rdata[7:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n502 = n501;
      3'b010: n502 = n501;
      3'b001: n502 = data;
      default: n502 = n501;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n503 = regs_rdata[8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n504 = n503;
      3'b010: n504 = n489;
      3'b001: n504 = n503;
      default: n504 = n503;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n505 = regs_rdata[11:9]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n506 = n505;
      3'b010: n506 = n488;
      3'b001: n506 = n505;
      default: n506 = n505;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n507 = regs_rdata[12]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n508 = n507;
      3'b010: n508 = n487;
      3'b001: n508 = n507;
      default: n508 = n507;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n509 = regs_rdata[13]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n510 = n509;
      3'b010: n510 = n486;
      3'b001: n510 = n509;
      default: n510 = n509;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n511 = regs_rdata[19:16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n512 = n493;
      3'b010: n512 = n511;
      3'b001: n512 = n511;
      default: n512 = n511;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n513 = regs_rdata[23:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:362:29 */
  always @*
    case (n496)
      3'b100: n514 = n492;
      3'b010: n514 = n513;
      3'b001: n514 = n513;
      default: n514 = n513;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n521 = regs_rdata[15:14]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:225:18 */
  assign n522 = {n514, n512, n521, n510, n508, n506, n504, n502};
  /*# work/sms-vhdl/compat/controller.vhd:358:21 */
  assign n523 = n536 ? n500 : regs_wr;
  /*# work/sms-vhdl/compat/controller.vhd:358:21 */
  assign n524 = n537 ? n522 : regs_wdata;
  /*# work/sms-vhdl/compat/controller.vhd:382:27 */
  assign n527 = {24'b0, addr};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:382:46 */
  assign n529 = n527 == 32'b00000000000000000000000011110000;
  /*# work/sms-vhdl/compat/controller.vhd:384:45 */
  assign n531 = data == 8'b10000000;
  /*# work/sms-vhdl/compat/controller.vhd:384:25 */
  assign n534 = n531 ? 1'b1 : 1'b0;
  /*# work/sms-vhdl/compat/controller.vhd:382:21 */
  assign n535 = n529 ? n534 : n317_extra_mode;
  /*# work/sms-vhdl/compat/controller.vhd:358:21 */
  assign n536 = n482 & n476;
  /*# work/sms-vhdl/compat/controller.vhd:358:21 */
  assign n537 = n482 & n476;
  /*# work/sms-vhdl/compat/controller.vhd:358:21 */
  assign n539 = n476 ? n317_extra_mode : n535;
  /*# work/sms-vhdl/compat/controller.vhd:354:21 */
  assign n540 = n473 ? regs_wr : n523;
  /*# work/sms-vhdl/compat/controller.vhd:354:21 */
  assign n541 = n473 ? regs_wdata : n524;
  /*# work/sms-vhdl/compat/controller.vhd:354:21 */
  assign n543 = n473 ? n317_extra_mode : n539;
  /*# work/sms-vhdl/compat/controller.vhd:350:21 */
  assign n544 = n470 ? regs_wr : n540;
  /*# work/sms-vhdl/compat/controller.vhd:350:21 */
  assign n545 = n470 ? regs_wdata : n541;
  /*# work/sms-vhdl/compat/controller.vhd:350:21 */
  assign n546 = n470 ? data : rflag;
  /*# work/sms-vhdl/compat/controller.vhd:350:21 */
  assign n548 = n470 ? n317_extra_mode : n543;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n549 = n558 ? n449 : user_voice_wr;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n550 = n559 ? n467 : user_voice_wdata;
  /*# work/sms-vhdl/compat/controller.vhd:301:21 */
  assign n551 = n341 ? regs_wr : n544;
  /*# work/sms-vhdl/compat/controller.vhd:301:21 */
  assign n552 = n341 ? regs_wdata : n545;
  /*# work/sms-vhdl/compat/controller.vhd:301:21 */
  assign n553 = n341 ? rflag : n546;
  /*# work/sms-vhdl/compat/controller.vhd:301:21 */
  assign n557 = n341 ? n317_extra_mode : n548;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n558 = n341 & wr;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n559 = n341 & wr;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n560 = wr ? n551 : regs_wr;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n561 = wr ? n552 : regs_wdata;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n562 = wr ? n553 : rflag;
  /*# work/sms-vhdl/compat/controller.vhd:297:17 */
  assign n565 = wr ? n557 : n317_extra_mode;
  /*# work/sms-vhdl/compat/controller.vhd:295:13 */
  assign n567 = stage == 2'b10;
  /*# work/sms-vhdl/compat/controller.vhd:403:28 */
  assign n568 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:403:46 */
  assign n570 = $signed(n568) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/controller.vhd:403:46 */
  assign n571 = n570[3:0];  // trunc
  /*# work/sms-vhdl/compat/controller.vhd:403:46 */
  assign n573 = 4'b1000 - n571;
  /*# work/sms-vhdl/compat/controller.vhd:403:76 */
  assign n575 = regs_rdata[23:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:405:32 */
  assign n578 = rflag[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:408:25 */
  assign n579 = rflag[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:408:42 */
  assign n581 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:408:42 */
  assign n582 = $unsigned(32'b00000000000000000000000000001100) <= $unsigned(n581);
  /*# work/sms-vhdl/compat/controller.vhd:408:35 */
  assign n583 = n582 & n579;
  /*# work/sms-vhdl/compat/controller.vhd:411:43 */
  assign n584 = rflag[4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:410:25 */
  assign n586 = slot == 5'b01100;
  /*# work/sms-vhdl/compat/controller.vhd:410:38 */
  assign n588 = slot == 5'b01101;
  /*# work/sms-vhdl/compat/controller.vhd:410:38 */
  assign n589 = n586 | n588;
  /*# work/sms-vhdl/compat/controller.vhd:413:43 */
  assign n590 = rflag[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:412:25 */
  assign n592 = slot == 5'b01110;
  /*# work/sms-vhdl/compat/controller.vhd:415:43 */
  assign n593 = rflag[3]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:414:25 */
  assign n595 = slot == 5'b01111;
  /*# work/sms-vhdl/compat/controller.vhd:417:43 */
  assign n596 = rflag[2]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:416:25 */
  assign n598 = slot == 5'b10000;
  /*# work/sms-vhdl/compat/controller.vhd:419:43 */
  assign n599 = rflag[1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:418:25 */
  assign n601 = slot == 5'b10001;
  /*# work/sms-vhdl/compat/controller.vhd:409:21 */
  assign n602 = {n601, n598, n595, n592, n589};
  /*# work/sms-vhdl/compat/controller.vhd:409:21 */
  always @*
    case (n602)
      5'b10000: n603 = n599;
      5'b01000: n603 = n596;
      5'b00100: n603 = n593;
      5'b00010: n603 = n590;
      5'b00001: n603 = n584;
      default: n603 = n317_kflag;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:408:17 */
  assign n605 = n583 ? n603 : 1'b0;
  /*# work/sms-vhdl/compat/controller.vhd:426:45 */
  assign n606 = regs_rdata[12]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:426:32 */
  assign n607 = n605 | n606;
  /*# work/sms-vhdl/compat/controller.vhd:429:62 */
  assign n608 = regs_rdata[8:5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:429:29 */
  assign n616 = {1'b0, n943};
  /*# work/sms-vhdl/compat/controller.vhd:430:50 */
  assign n617 = regs_rdata[11:9]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:430:39 */
  assign n619 = 3'b111 - n617;
  /*# work/sms-vhdl/compat/controller.vhd:430:32 */
  assign n621 = {1'b0, n619};
  /*# work/sms-vhdl/compat/controller.vhd:430:64 */
  assign n623 = {n621, 3'b000};
  /*# work/sms-vhdl/compat/controller.vhd:430:26 */
  assign n624 = n616 - n623;
  /*# work/sms-vhdl/compat/controller.vhd:430:73 */
  assign n626 = {n624, 1'b0};
  /*# work/sms-vhdl/compat/controller.vhd:432:23 */
  assign n627 = n626[7]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:432:58 */
  assign n628 = slot_voice_data[9:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:432:61 */
  assign n630 = n628 == 2'b00;
  /*# work/sms-vhdl/compat/controller.vhd:432:39 */
  assign n631 = n627 | n630;
  /*# work/sms-vhdl/compat/controller.vhd:435:60 */
  assign n632 = slot_voice_data[9:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:435:42 */
  assign n634 = 2'b11 - n632;
  /*# work/sms-vhdl/compat/controller.vhd:435:28 */
  assign n635 = n626 >> n634;
  /*# work/sms-vhdl/compat/controller.vhd:432:17 */
  assign n637 = n631 ? 8'b00000000 : n635;
  /*# work/sms-vhdl/compat/controller.vhd:439:25 */
  assign n638 = rflag[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:439:45 */
  assign n640 = slot == 5'b01110;
  /*# work/sms-vhdl/compat/controller.vhd:439:63 */
  assign n642 = slot == 5'b10000;
  /*# work/sms-vhdl/compat/controller.vhd:439:55 */
  assign n643 = n640 | n642;
  /*# work/sms-vhdl/compat/controller.vhd:439:35 */
  assign n644 = n643 & n638;
  /*# work/sms-vhdl/compat/controller.vhd:440:45 */
  assign n645 = regs_rdata[23:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:440:33 */
  assign n647 = {1'b0, n645};
  /*# work/sms-vhdl/compat/controller.vhd:440:60 */
  assign n649 = {n647, 3'b000};
  /*# work/sms-vhdl/compat/controller.vhd:441:28 */
  assign n650 = slot[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:441:32 */
  assign n651 = ~n650;
  /*# work/sms-vhdl/compat/controller.vhd:442:51 */
  assign n652 = slot_voice_data[15:10]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:442:33 */
  assign n654 = {1'b0, n652};
  /*# work/sms-vhdl/compat/controller.vhd:442:54 */
  assign n656 = {n654, 1'b0};
  /*# work/sms-vhdl/compat/controller.vhd:444:45 */
  assign n657 = regs_rdata[19:16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:444:33 */
  assign n659 = {1'b0, n657};
  /*# work/sms-vhdl/compat/controller.vhd:444:60 */
  assign n661 = {n659, 3'b000};
  /*# work/sms-vhdl/compat/controller.vhd:441:17 */
  assign n662 = n651 ? n656 : n661;
  /*# work/sms-vhdl/compat/controller.vhd:439:17 */
  assign n663 = n644 ? n649 : n662;
  /*# work/sms-vhdl/compat/controller.vhd:447:28 */
  assign n664 = n663 + n637;
  /*# work/sms-vhdl/compat/controller.vhd:449:23 */
  assign n665 = n664[7]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:452:30 */
  assign n666 = n664[6:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:449:17 */
  assign n668 = n665 ? 7'b1111111 : n666;
  /*# work/sms-vhdl/compat/controller.vhd:456:35 */
  assign n669 = regs_rdata[8:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:457:34 */
  assign n670 = regs_rdata[11:9]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:460:25 */
  assign n671 = rflag[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:460:42 */
  assign n673 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:460:42 */
  assign n674 = $unsigned(32'b00000000000000000000000000001110) <= $unsigned(n673);
  /*# work/sms-vhdl/compat/controller.vhd:460:35 */
  assign n675 = n674 & n671;
  /*# work/sms-vhdl/compat/controller.vhd:461:40 */
  assign n676 = slot_voice_data[3]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:464:49 */
  assign n677 = regs_rdata[11:10]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:464:37 */
  assign n679 = {2'b00, n677};
  /*# work/sms-vhdl/compat/controller.vhd:461:21 */
  assign n681 = n676 ? 4'b0101 : n679;
  /*# work/sms-vhdl/compat/controller.vhd:467:40 */
  assign n682 = slot_voice_data[3]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:468:42 */
  assign n683 = regs_rdata[11:9]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:468:68 */
  assign n684 = regs_rdata[8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:468:56 */
  assign n685 = {n683, n684};
  /*# work/sms-vhdl/compat/controller.vhd:470:49 */
  assign n686 = regs_rdata[11:10]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:470:37 */
  assign n688 = {2'b00, n686};
  /*# work/sms-vhdl/compat/controller.vhd:467:21 */
  assign n689 = n682 ? n685 : n688;
  /*# work/sms-vhdl/compat/controller.vhd:460:17 */
  assign n690 = n675 ? n681 : n689;
  /*# work/sms-vhdl/compat/controller.vhd:478:39 */
  assign n691 = slot_voice_data[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:479:39 */
  assign n692 = slot_voice_data[1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:480:39 */
  assign n693 = slot_voice_data[7:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:481:43 */
  assign n694 = slot_voice_data[16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:482:43 */
  assign n695 = slot_voice_data[19:17]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:485:39 */
  assign n696 = slot_voice_data[23:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:486:39 */
  assign n697 = slot_voice_data[27:24]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:487:39 */
  assign n698 = slot_voice_data[31:28]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:491:40 */
  assign n699 = slot_voice_data[2]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:494:47 */
  assign n700 = slot_voice_data[35:32]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:491:21 */
  assign n702 = n699 ? 4'b0000 : n700;
  /*# work/sms-vhdl/compat/controller.vhd:497:29 */
  assign n703 = slot[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:497:33 */
  assign n704 = ~n703;
  /*# work/sms-vhdl/compat/controller.vhd:497:55 */
  assign n705 = rflag[5]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:497:75 */
  assign n706 = {27'b0, slot};  // uext
  /*# work/sms-vhdl/compat/controller.vhd:497:93 */
  assign n708 = $signed(n706) / $signed(32'b00000000000000000000000000000010); // sdiv
  /*# work/sms-vhdl/compat/controller.vhd:497:72 */
  assign n710 = $signed(32'b00000000000000000000000000000111) <= $signed(n708);
  /*# work/sms-vhdl/compat/controller.vhd:497:65 */
  assign n711 = n710 & n705;
  /*# work/sms-vhdl/compat/controller.vhd:497:44 */
  assign n712 = ~n711;
  /*# work/sms-vhdl/compat/controller.vhd:497:40 */
  assign n713 = n712 & n704;
  /*# work/sms-vhdl/compat/controller.vhd:499:37 */
  assign n714 = regs_rdata[13]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:501:43 */
  assign n715 = slot_voice_data[2]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:501:46 */
  assign n716 = ~n715;
  /*# work/sms-vhdl/compat/controller.vhd:504:48 */
  assign n717 = slot_voice_data[35:32]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:501:21 */
  assign n719 = n716 ? 4'b0111 : n717;
  /*# work/sms-vhdl/compat/controller.vhd:499:21 */
  assign n721 = n714 ? 4'b0101 : n719;
  /*# work/sms-vhdl/compat/controller.vhd:497:21 */
  assign n723 = n713 ? 4'b0000 : n721;
  /*# work/sms-vhdl/compat/controller.vhd:490:17 */
  assign n724 = n607 ? n702 : n723;
  /*# work/sms-vhdl/compat/controller.vhd:397:13 */
  assign n726 = stage == 2'b11;
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  assign n727 = {n726, n567, n336, n334};
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n728 = n691;
      4'b0100: n728 = n880;
      4'b0010: n728 = n880;
      4'b0001: n728 = n880;
      default: n728 = n880;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n729 = n692;
      4'b0100: n729 = n884;
      4'b0010: n729 = n884;
      4'b0001: n729 = n884;
      default: n729 = n884;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n730 = n694;
      4'b0100: n730 = n886;
      4'b0010: n730 = n886;
      4'b0001: n730 = n886;
      default: n730 = n886;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n731 = n693;
      4'b0100: n731 = n888;
      4'b0010: n731 = n888;
      4'b0001: n731 = n888;
      default: n731 = n888;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n732 = n668;
      4'b0100: n732 = n890;
      4'b0010: n732 = n890;
      4'b0001: n732 = n890;
      default: n732 = n890;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n733 = n695;
      4'b0100: n733 = n892;
      4'b0010: n733 = n892;
      4'b0001: n733 = n892;
      default: n733 = n892;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n734 = n696;
      4'b0100: n734 = n894;
      4'b0010: n734 = n894;
      4'b0001: n734 = n894;
      default: n734 = n894;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n735 = n697;
      4'b0100: n735 = n896;
      4'b0010: n735 = n896;
      4'b0001: n735 = n896;
      default: n735 = n896;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n736 = n698;
      4'b0100: n736 = n898;
      4'b0010: n736 = n898;
      4'b0001: n736 = n898;
      default: n736 = n898;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n737 = n724;
      4'b0100: n737 = n900;
      4'b0010: n737 = n900;
      4'b0001: n737 = n900;
      default: n737 = n900;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n738 = n670;
      4'b0100: n738 = n902;
      4'b0010: n738 = n902;
      4'b0001: n738 = n902;
      default: n738 = n902;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n739 = n669;
      4'b0100: n739 = n904;
      4'b0010: n739 = n904;
      4'b0001: n739 = n904;
      default: n739 = n904;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n740 = n690;
      4'b0100: n740 = n906;
      4'b0010: n740 = n906;
      4'b0001: n740 = n906;
      default: n740 = n906;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n741 = n607;
      4'b0100: n741 = n908;
      4'b0010: n741 = n908;
      4'b0001: n741 = n908;
      default: n741 = n908;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n742 = n578;
      4'b0100: n742 = n910;
      4'b0010: n742 = n910;
      4'b0001: n742 = n910;
      default: n742 = n910;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n743 = n990;
      4'b0100: n743 = inst_cache;
      4'b0010: n743 = inst_cache;
      4'b0001: n743 = inst_cache;
      default: n743 = inst_cache;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n745 = user_voice_wr;
      4'b0100: n745 = n549;
      4'b0010: n745 = user_voice_wr;
      4'b0001: n745 = 1'b0;
      default: n745 = user_voice_wr;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n746 = user_voice_addr;
      4'b0100: n746 = user_voice_addr;
      4'b0010: n746 = user_voice_addr;
      4'b0001: n746 = n332;
      default: n746 = user_voice_addr;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n747 = user_voice_wdata;
      4'b0100: n747 = n550;
      4'b0010: n747 = user_voice_wdata;
      4'b0001: n747 = user_voice_wdata;
      default: n747 = user_voice_wdata;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n749 = regs_wr;
      4'b0100: n749 = n560;
      4'b0010: n749 = regs_wr;
      4'b0001: n749 = 1'b0;
      default: n749 = regs_wr;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n750 = regs_wdata;
      4'b0100: n750 = n561;
      4'b0010: n750 = regs_wdata;
      4'b0001: n750 = regs_wdata;
      default: n750 = regs_wdata;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n751 = rflag;
      4'b0100: n751 = n562;
      4'b0010: n751 = rflag;
      4'b0001: n751 = rflag;
      default: n751 = rflag;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n752 = n607;
      4'b0100: n752 = n317_kflag;
      4'b0010: n752 = n317_kflag;
      4'b0001: n752 = n317_kflag;
      default: n752 = n317_kflag;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n759 = n317_extra_mode;
      4'b0100: n759 = n565;
      4'b0010: n759 = n317_extra_mode;
      4'b0001: n759 = n317_extra_mode;
      default: n759 = n317_extra_mode;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:265:13 */
  always @*
    case (n727)
      4'b1000: n760 = n317_vindex;
      4'b0100: n760 = n317_vindex;
      4'b0010: n760 = n317_vindex;
      4'b0001: n760 = n332;
      default: n760 = n317_vindex;
    endcase
  /*# work/sms-vhdl/compat/controller.vhd:84:5 */
  assign n877 = ~reset;
  /*# work/sms-vhdl/compat/controller.vhd:84:5 */
  assign n878 = clkena & n877;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n879 = n878 ? n728 : n880;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk)
    n880 <= n879;
  /*# work/sms-vhdl/compat/controller.vhd:85:5 */
  assign n881 = ~reset;
  /*# work/sms-vhdl/compat/controller.vhd:85:5 */
  assign n882 = clkena & n881;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n883 = n882 ? n729 : n884;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk)
    n884 <= n883;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n885 = clkena ? n730 : n886;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n886 <= 1'b0;
    else
      n886 <= n885;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n887 = clkena ? n731 : n888;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n888 <= 4'b0000;
    else
      n888 <= n887;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n889 = clkena ? n732 : n890;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n890 <= 7'b0000000;
    else
      n890 <= n889;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n891 = clkena ? n733 : n892;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n892 <= 3'b000;
    else
      n892 <= n891;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n893 = clkena ? n734 : n894;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n894 <= 4'b0000;
    else
      n894 <= n893;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n895 = clkena ? n735 : n896;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n896 <= 4'b0000;
    else
      n896 <= n895;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n897 = clkena ? n736 : n898;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n898 <= 4'b0000;
    else
      n898 <= n897;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n899 = clkena ? n737 : n900;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n900 <= 4'b0000;
    else
      n900 <= n899;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n901 = clkena ? n738 : n902;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n902 <= 3'b000;
    else
      n902 <= n901;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n903 = clkena ? n739 : n904;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n904 <= 9'b000000000;
    else
      n904 <= n903;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n905 = clkena ? n740 : n906;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n906 <= 4'b0000;
    else
      n906 <= n905;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n907 = clkena ? n741 : n908;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n908 <= 1'b0;
    else
      n908 <= n907;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n909 = clkena ? n742 : n910;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n910 <= 1'b0;
    else
      n910 <= n909;
  /*# work/sms-vhdl/compat/controller.vhd:132:12 */
  assign n911 = ~reset;
  /*# work/sms-vhdl/compat/controller.vhd:132:12 */
  assign n912 = clkena & n911;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n913 = n912 ? n743 : inst_cache;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk)
    n914 <= n913;
  /*# work/sms-vhdl/compat/controller.vhd:200:9 */
  assign n915 = n311 ? n309 : slot_voice_addr;
  /*# work/sms-vhdl/compat/controller.vhd:200:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n916 <= 6'b000000;
    else
      n916 <= n915;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n917 = clkena ? n745 : user_voice_wr;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n918 <= 1'b0;
    else
      n918 <= n917;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n919 = clkena ? n746 : user_voice_addr;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n920 <= 6'b000000;
    else
      n920 <= n919;
  /*# work/sms-vhdl/compat/controller.vhd:150:12 */
  assign n921 = ~reset;
  /*# work/sms-vhdl/compat/controller.vhd:150:12 */
  assign n922 = clkena & n921;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n923 = n922 ? n747 : user_voice_wdata;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk)
    n924 <= n923;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n925 = clkena ? n749 : regs_wr;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n926 <= 1'b0;
    else
      n926 <= n925;
  /*# work/sms-vhdl/compat/controller.vhd:184:9 */
  assign n927 = n273 ? n271 : regs_addr;
  /*# work/sms-vhdl/compat/controller.vhd:184:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n928 <= 4'b0000;
    else
      n928 <= n927;
  /*# work/sms-vhdl/compat/controller.vhd:156:12 */
  assign n929 = ~reset;
  /*# work/sms-vhdl/compat/controller.vhd:156:12 */
  assign n930 = clkena & n929;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n931 = n930 ? n750 : regs_wdata;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk)
    n932 <= n931;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n933 = clkena ? n751 : rflag;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n934 <= 8'b00000000;
    else
      n934 <= n933;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n935 = clkena ? n752 : n317_kflag;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n936 <= 1'b0;
    else
      n936 <= n935;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n937 = clkena ? n759 : n317_extra_mode;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n938 <= 1'b0;
    else
      n938 <= n937;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  assign n939 = clkena ? n760 : n317_vindex;
  /*# work/sms-vhdl/compat/controller.vhd:263:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n940 <= 6'b000000;
    else
      n940 <= n939;
  /*# work/sms-vhdl/compat/controller.vhd:429:39 */
  reg [5:0] n941[15:0] ; // memory
  initial begin
    n941[15] = 6'b111000;
    n941[14] = 6'b110111;
    n941[13] = 6'b110110;
    n941[12] = 6'b110101;
    n941[11] = 6'b110100;
    n941[10] = 6'b110011;
    n941[9] = 6'b110010;
    n941[8] = 6'b110000;
    n941[7] = 6'b101111;
    n941[6] = 6'b101101;
    n941[5] = 6'b101011;
    n941[4] = 6'b101000;
    n941[3] = 6'b100101;
    n941[2] = 6'b100000;
    n941[1] = 6'b011000;
    n941[0] = 6'b000000;
    end
  assign n943 = n941[n608];
  /*# work/sms-vhdl/compat/controller.vhd:429:39 */
  /*# work/sms-vhdl/compat/controller.vhd:207:73 */
  assign n945 = {28'bX, inst_cache};
  /*# work/sms-vhdl/compat/controller.vhd:207:73 */
  assign n946 = n945[n298 * 4 +: 4]; //(Bmux)
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n947 = n573[3]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n948 = ~n947;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n949 = n573[2]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n950 = ~n949;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n951 = n948 & n950;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n952 = n948 & n949;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n953 = n947 & n950;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n954 = n573[1]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n955 = ~n954;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n956 = n951 & n955;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n957 = n951 & n954;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n958 = n952 & n955;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n959 = n952 & n954;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n960 = n953 & n955;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n961 = n573[0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n962 = ~n961;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n963 = n956 & n962;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n964 = n956 & n961;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n965 = n957 & n962;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n966 = n957 & n961;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n967 = n958 & n962;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n968 = n958 & n961;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n969 = n959 & n962;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n970 = n959 & n961;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n971 = n960 & n962;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n972 = inst_cache[3:0]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n973 = n963 ? n575 : n972;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n974 = inst_cache[7:4]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n975 = n964 ? n575 : n974;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n976 = inst_cache[11:8]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n977 = n965 ? n575 : n976;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n978 = inst_cache[15:12]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n979 = n966 ? n575 : n978;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n980 = inst_cache[19:16]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n981 = n967 ? n575 : n980;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n982 = inst_cache[23:20]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n983 = n968 ? n575 : n982;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n984 = inst_cache[27:24]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n985 = n969 ? n575 : n984;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n986 = inst_cache[31:28]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n987 = n970 ? n575 : n986;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n988 = inst_cache[35:32]; // extract
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n989 = n971 ? n575 : n988;
  /*# work/sms-vhdl/compat/controller.vhd:403:17 */
  assign n990 = {n989, n987, n985, n983, n981, n979, n977, n975, n973};
endmodule

module slotcounter_Brtl_8
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage);
  wire [6:0] ff_count;
  wire n213;
  wire [6:0] n215;
  wire [6:0] n217;
  wire [1:0] n223;
  wire [4:0] n224;
  wire [6:0] n225;
  reg [6:0] n226;
  assign slot = n224; //(module output)
  assign stage = n223; //(module output)
  /*# work/sms-vhdl/compat/slotcounter.vhd:55:12 */
  assign ff_count = n226; // (signal)
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:30 */
  assign n213 = ff_count == 7'b1000111;
  /*# work/sms-vhdl/compat/slotcounter.vhd:67:42 */
  assign n215 = ff_count + 7'b0000001;
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:17 */
  assign n217 = n213 ? 7'b0000000 : n215;
  /*# work/sms-vhdl/compat/slotcounter.vhd:73:24 */
  assign n223 = ff_count[1:0]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:74:24 */
  assign n224 = ff_count[6:2]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  assign n225 = clkena ? n217 : ff_count;
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n226 <= 7'b0111111;
    else
      n226 <= n225;
endmodule

module slotcounter_Brtl_5
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage);
  wire [6:0] ff_count;
  wire n193;
  wire [6:0] n195;
  wire [6:0] n197;
  wire [1:0] n203;
  wire [4:0] n204;
  wire [6:0] n205;
  reg [6:0] n206;
  assign slot = n204; //(module output)
  assign stage = n203; //(module output)
  /*# work/sms-vhdl/compat/slotcounter.vhd:55:12 */
  assign ff_count = n206; // (signal)
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:30 */
  assign n193 = ff_count == 7'b1000111;
  /*# work/sms-vhdl/compat/slotcounter.vhd:67:42 */
  assign n195 = ff_count + 7'b0000001;
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:17 */
  assign n197 = n193 ? 7'b0000000 : n195;
  /*# work/sms-vhdl/compat/slotcounter.vhd:73:24 */
  assign n203 = ff_count[1:0]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:74:24 */
  assign n204 = ff_count[6:2]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  assign n205 = clkena ? n197 : ff_count;
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n206 <= 7'b1000010;
    else
      n206 <= n205;
endmodule

module slotcounter_Brtl_2
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage);
  wire [6:0] ff_count;
  wire n173;
  wire [6:0] n175;
  wire [6:0] n177;
  wire [1:0] n183;
  wire [4:0] n184;
  wire [6:0] n185;
  reg [6:0] n186;
  assign slot = n184; //(module output)
  assign stage = n183; //(module output)
  /*# work/sms-vhdl/compat/slotcounter.vhd:55:12 */
  assign ff_count = n186; // (signal)
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:30 */
  assign n173 = ff_count == 7'b1000111;
  /*# work/sms-vhdl/compat/slotcounter.vhd:67:42 */
  assign n175 = ff_count + 7'b0000001;
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:17 */
  assign n177 = n173 ? 7'b0000000 : n175;
  /*# work/sms-vhdl/compat/slotcounter.vhd:73:24 */
  assign n183 = ff_count[1:0]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:74:24 */
  assign n184 = ff_count[6:2]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  assign n185 = clkena ? n177 : ff_count;
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n186 <= 7'b1000101;
    else
      n186 <= n185;
endmodule

module slotcounter_Brtl_0
  (input  clk,
   input  reset,
   input  clkena,
   output [4:0] slot,
   output [1:0] stage);
  wire [6:0] ff_count;
  wire n153;
  wire [6:0] n155;
  wire [6:0] n157;
  wire [1:0] n163;
  wire [4:0] n164;
  wire [6:0] n165;
  reg [6:0] n166;
  assign slot = n164; //(module output)
  assign stage = n163; //(module output)
  /*# work/sms-vhdl/compat/slotcounter.vhd:55:12 */
  assign ff_count = n166; // (signal)
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:30 */
  assign n153 = ff_count == 7'b1000111;
  /*# work/sms-vhdl/compat/slotcounter.vhd:67:42 */
  assign n155 = ff_count + 7'b0000001;
  /*# work/sms-vhdl/compat/slotcounter.vhd:64:17 */
  assign n157 = n153 ? 7'b0000000 : n155;
  /*# work/sms-vhdl/compat/slotcounter.vhd:73:24 */
  assign n163 = ff_count[1:0]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:74:24 */
  assign n164 = ff_count[6:2]; // extract
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  assign n165 = clkena ? n157 : ff_count;
  /*# work/sms-vhdl/compat/slotcounter.vhd:62:9 */
  always @(posedge clk or posedge reset)
    if (reset)
      n166 <= 7'b1000111;
    else
      n166 <= n165;
endmodule

module opll
  (input  xin,
   output xout,
   input  xena,
   input  [7:0] d,
   input  a,
   input  cs_n,
   input  we_n,
   input  ic_n,
   output [13:0] mixout);
  wire reset;
  wire [7:0] opllptr;
  wire [7:0] oplldat;
  wire opllwr;
  wire am;
  wire pm;
  wire wf;
  wire [6:0] tl;
  wire [2:0] fb;
  wire [3:0] ar;
  wire [3:0] dr;
  wire [3:0] sl;
  wire [3:0] rr;
  wire [3:0] ml;
  wire [8:0] fnum;
  wire [2:0] blk;
  wire [3:0] rks;
  wire key;
  wire rhythm;
  wire noise;
  wire [17:0] pgout;
  wire [12:0] egout;
  wire [13:0] opout;
  wire [3:0] faddr;
  wire [4:0] maddr;
  wire [9:0] fdata;
  wire [9:0] mdata;
  wire [4:0] slot;
  wire [4:0] slot2;
  wire [4:0] slot5;
  wire [4:0] slot8;
  wire [1:0] stage;
  wire [1:0] stage2;
  wire [1:0] stage5;
  wire [1:0] stage8;
  wire n2;
  wire n6;
  wire n7;
  wire n8;
  wire n9;
  wire n10;
  wire n11;
  wire n12;
  wire n13;
  wire n14;
  wire [7:0] n15;
  wire n17;
  wire [7:0] n19;
  wire n21;
  wire n22;
  wire [4:0] s0_n34;
  wire [1:0] s0_n35;
  wire [4:0] s2_n40;
  wire [1:0] s2_n41;
  wire [4:0] s5_n46;
  wire [1:0] s5_n47;
  wire [4:0] s8_n52;
  wire [1:0] s8_n53;
  wire ct_n58;
  wire ct_n59;
  wire ct_n60;
  wire [3:0] ct_n61;
  wire [6:0] ct_n62;
  wire [2:0] ct_n63;
  wire [3:0] ct_n64;
  wire [3:0] ct_n65;
  wire [3:0] ct_n66;
  wire [3:0] ct_n67;
  wire [2:0] ct_n68;
  wire [8:0] ct_n69;
  wire [3:0] ct_n70;
  wire ct_n71;
  wire ct_n72;
  wire [12:0] eg_n103;
  wire pg_n106;
  wire [17:0] pg_n107;
  wire [3:0] op_n112;
  wire [13:0] op_n113;
  wire n115;
  wire [8:0] n116;
  wire [9:0] og_n120;
  wire [9:0] og_n121;
  wire \og.fdata[sign] ;
  wire [8:0] \og.fdata[value] ;
  wire \og.mdata[sign] ;
  wire [8:0] \og.mdata[value] ;
  wire [9:0] n122;
  wire [9:0] n124;
  wire [4:0] tm_n128;
  wire [13:0] tm_n129;
  wire n131;
  wire [8:0] n132;
  wire [7:0] n139;
  reg [7:0] n140;
  wire n141;
  wire n142;
  wire [7:0] n143;
  reg [7:0] n144;
  wire n145;
  reg n146;
  assign xout = xin; //(module output)
  assign mixout = tm_n129; //(module output)
  /*# work/sms-vhdl/compat/opll.vhd:204:12 */
  assign reset = n2; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:206:12 */
  assign opllptr = n140; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:207:12 */
  assign oplldat = n144; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:208:12 */
  assign opllwr = n146; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:210:12 */
  assign am = ct_n58; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:211:12 */
  assign pm = ct_n59; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:212:12 */
  assign wf = ct_n60; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:213:12 */
  assign tl = ct_n62; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:214:12 */
  assign fb = ct_n63; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:215:12 */
  assign ar = ct_n64; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:216:12 */
  assign dr = ct_n65; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:217:12 */
  assign sl = ct_n66; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:218:12 */
  assign rr = ct_n67; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:219:12 */
  assign ml = ct_n61; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:220:12 */
  assign fnum = ct_n69; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:221:12 */
  assign blk = ct_n68; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:222:12 */
  assign rks = ct_n70; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:223:12 */
  assign key = ct_n71; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:225:12 */
  assign rhythm = ct_n72; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:227:12 */
  assign noise = pg_n106; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:228:12 */
  assign pgout = pg_n107; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:230:12 */
  assign egout = eg_n103; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:232:12 */
  assign opout = op_n113; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:235:12 */
  assign faddr = op_n112; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:236:12 */
  assign maddr = tm_n128; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:237:12 */
  assign fdata = og_n120; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:238:12 */
  assign mdata = og_n121; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:243:12 */
  assign slot = s0_n34; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:244:12 */
  assign slot2 = s2_n40; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:245:12 */
  assign slot5 = s5_n46; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:246:12 */
  assign slot8 = s8_n52; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:247:12 */
  assign stage = s0_n35; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:248:12 */
  assign stage2 = s2_n41; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:249:12 */
  assign stage5 = s5_n47; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:250:12 */
  assign stage8 = s8_n53; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:255:16 */
  assign n2 = ~ic_n;
  /*# work/sms-vhdl/compat/opll.vhd:264:29 */
  assign n6 = ~cs_n;
  /*# work/sms-vhdl/compat/opll.vhd:264:44 */
  assign n7 = ~we_n;
  /*# work/sms-vhdl/compat/opll.vhd:264:35 */
  assign n8 = n7 & n6;
  /*# work/sms-vhdl/compat/opll.vhd:264:56 */
  assign n9 = ~a;
  /*# work/sms-vhdl/compat/opll.vhd:264:50 */
  assign n10 = n9 & n8;
  /*# work/sms-vhdl/compat/opll.vhd:267:29 */
  assign n11 = ~cs_n;
  /*# work/sms-vhdl/compat/opll.vhd:267:44 */
  assign n12 = ~we_n;
  /*# work/sms-vhdl/compat/opll.vhd:267:35 */
  assign n13 = n12 & n11;
  /*# work/sms-vhdl/compat/opll.vhd:267:50 */
  assign n14 = a & n13;
  /*# work/sms-vhdl/compat/opll.vhd:267:17 */
  assign n15 = n14 ? d : oplldat;
  /*# work/sms-vhdl/compat/opll.vhd:267:17 */
  assign n17 = n14 ? 1'b1 : opllwr;
  /*# work/sms-vhdl/compat/opll.vhd:264:17 */
  assign n19 = n10 ? oplldat : n15;
  /*# work/sms-vhdl/compat/opll.vhd:264:17 */
  assign n21 = n10 ? 1'b0 : n17;
  /*# work/sms-vhdl/compat/opll.vhd:263:13 */
  assign n22 = n10 & xena;
  /*# work/sms-vhdl/compat/opll.vhd:275:5 */
  slotcounter_Brtl_0 s0 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(s0_n34),
    .stage(s0_n35));
  /*# work/sms-vhdl/compat/opll.vhd:287:5 */
  slotcounter_Brtl_2 s2 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(s2_n40),
    .stage(s2_n41));
  /*# work/sms-vhdl/compat/opll.vhd:299:5 */
  slotcounter_Brtl_5 s5 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(s5_n46),
    .stage(s5_n47));
  /*# work/sms-vhdl/compat/opll.vhd:311:5 */
  slotcounter_Brtl_8 s8 (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(s8_n52),
    .stage(s8_n53));
  /*# work/sms-vhdl/compat/opll.vhd:324:5 */
  controller_Brtl ct (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot),
    .stage(stage),
    .wr(opllwr),
    .addr(opllptr),
    .data(oplldat),
    .am(ct_n58),
    .pm(ct_n59),
    .wf(ct_n60),
    .ml(ct_n61),
    .tl(ct_n62),
    .fb(ct_n63),
    .ar(ct_n64),
    .dr(ct_n65),
    .sl(ct_n66),
    .rr(ct_n67),
    .blk(ct_n68),
    .fnum(ct_n69),
    .rks(ct_n70),
    .key(ct_n71),
    .rhythm(ct_n72));
  /*# work/sms-vhdl/compat/opll.vhd:329:5 */
  envelopegenerator_Brtl eg (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot2),
    .stage(stage2),
    .rhythm(rhythm),
    .am(am),
    .tl(tl),
    .ar(ar),
    .dr(dr),
    .sl(sl),
    .rr(rr),
    .rks(rks),
    .key(key),
    .egout(eg_n103));
  /*# work/sms-vhdl/compat/opll.vhd:336:5 */
  phasegenerator_Brtl pg (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot2),
    .stage(stage2),
    .rhythm(rhythm),
    .pm(pm),
    .ml(ml),
    .blk(blk),
    .fnum(fnum),
    .key(key),
    .noise(pg_n106),
    .pgout(pg_n107));
  /*# work/sms-vhdl/compat/opll.vhd:344:5 */
  operator_Brtl op (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot5),
    .stage(stage5),
    .rhythm(rhythm),
    .wf(wf),
    .fb(fb),
    .noise(noise),
    .pgout(pgout),
    .egout(egout),
    .\fdata[sign] (n115),
    .\fdata[value] (n116),
    .faddr(op_n112),
    .opout(op_n113));
  /*# work/sms-vhdl/compat/opll.vhd:344:5 */
  assign n115 = fdata[0]; // extract
  /*# work/sms-vhdl/compat/opll.vhd:344:5 */
  assign n116 = fdata[9:1]; // extract
  /*# work/sms-vhdl/compat/opll.vhd:353:23 */
  assign og_n120 = n122; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:353:37 */
  assign og_n121 = n124; // (signal)
  /*# work/sms-vhdl/compat/opll.vhd:351:5 */
  outputgenerator_Brtl og (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot8),
    .stage(stage8),
    .rhythm(rhythm),
    .opout(opout),
    .faddr(faddr),
    .maddr(maddr),
    .\fdata[sign] (\og.fdata[sign] ),
    .\fdata[value] (\og.fdata[value] ),
    .\mdata[sign] (\og.mdata[sign] ),
    .\mdata[value] (\og.mdata[value] ));
  /*# work/sms-vhdl/compat/opll.vhd:351:5 */
  assign n122 = {\og.fdata[value] , \og.fdata[sign] };
  /*# work/sms-vhdl/compat/opll.vhd:351:5 */
  assign n124 = {\og.mdata[value] , \og.mdata[sign] };
  /*# work/sms-vhdl/compat/opll.vhd:357:5 */
  temporalmixer_Brtl tm (
    .clk(xin),
    .reset(reset),
    .clkena(xena),
    .slot(slot),
    .stage(stage),
    .rhythm(rhythm),
    .\mdata[sign] (n131),
    .\mdata[value] (n132),
    .maddr(tm_n128),
    .mixout(tm_n129));
  /*# work/sms-vhdl/compat/opll.vhd:357:5 */
  assign n131 = mdata[0]; // extract
  /*# work/sms-vhdl/compat/opll.vhd:357:5 */
  assign n132 = mdata[9:1]; // extract
  /*# work/sms-vhdl/compat/opll.vhd:262:9 */
  assign n139 = n22 ? d : opllptr;
  /*# work/sms-vhdl/compat/opll.vhd:262:9 */
  always @(posedge xin or posedge reset)
    if (reset)
      n140 <= 8'b00000000;
    else
      n140 <= n139;
  /*# work/sms-vhdl/compat/opll.vhd:207:12 */
  assign n141 = ~reset;
  /*# work/sms-vhdl/compat/opll.vhd:207:12 */
  assign n142 = xena & n141;
  /*# work/sms-vhdl/compat/opll.vhd:262:9 */
  assign n143 = n142 ? n19 : oplldat;
  /*# work/sms-vhdl/compat/opll.vhd:262:9 */
  always @(posedge xin)
    n144 <= n143;
  /*# work/sms-vhdl/compat/opll.vhd:262:9 */
  assign n145 = xena ? n21 : opllwr;
  /*# work/sms-vhdl/compat/opll.vhd:262:9 */
  always @(posedge xin or posedge reset)
    if (reset)
      n146 <= 1'b0;
    else
      n146 <= n145;
endmodule

