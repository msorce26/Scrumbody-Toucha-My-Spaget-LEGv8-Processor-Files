//RegisterNbit.v
module RegisterNbit (Q, D, L, R, clock);
	parameter n = 8;
	output reg [n-1:0]Q;// register output
	input [n-1:0]D; //data input
	input L; // load enable
	input R; // positive logic asynchronous reset
	input clock;
	
	always @(posedge clock or posedge R) begin
		if(R)
			Q <= 0;
		else if(L)
			Q <= D;
		else
			Q <= Q;
	end
endmodule

//Decoder5to32.v
module Decoder5to32(S, m);
	input [4:0]S; //select
	output [31:0]m; //32 minterms
	
	assign m[0] = ~S[4]&~S[3]&~S[2]&~S[1]&~S[0];
	assign m[1] = ~S[4]&~S[3]&~S[2]&~S[1]& S[0];
	assign m[2] = ~S[4]&~S[3]&~S[2]& S[1]&~S[0];
	assign m[3] = ~S[4]&~S[3]&~S[2]& S[1]& S[0];
	assign m[4] = ~S[4]&~S[3]& S[2]&~S[1]&~S[0];
	assign m[5] = ~S[4]&~S[3]& S[2]&~S[1]& S[0];
	assign m[6] = ~S[4]&~S[3]& S[2]& S[1]&~S[0];
	assign m[7] = ~S[4]&~S[3]& S[2]& S[1]& S[0];
	assign m[8] = ~S[4]& S[3]&~S[2]&~S[1]&~S[0];
	assign m[9] = ~S[4]& S[3]&~S[2]&~S[1]& S[0];
	assign m[10] = ~S[4]& S[3]&~S[2]& S[1]&~S[0];
	assign m[11] = ~S[4]& S[3]&~S[2]& S[1]& S[0];
	assign m[12] = ~S[4]& S[3]& S[2]&~S[1]&~S[0];
	assign m[13] = ~S[4]& S[3]& S[2]&~S[1]& S[0];
	assign m[14] = ~S[4]& S[3]& S[2]& S[1]&~S[0];
	assign m[15] = ~S[4]& S[3]& S[2]& S[1]& S[0];
	
	assign m[16] = S[4]&~S[3]&~S[2]&~S[1]&~S[0];
	assign m[17] = S[4]&~S[3]&~S[2]&~S[1]& S[0];
	assign m[18] = S[4]&~S[3]&~S[2]& S[1]&~S[0];
	assign m[19] = S[4]&~S[3]&~S[2]& S[1]& S[0];
	assign m[20] = S[4]&~S[3]& S[2]&~S[1]&~S[0];
	assign m[21] = S[4]&~S[3]& S[2]&~S[1]& S[0];
	assign m[22] = S[4]&~S[3]& S[2]& S[1]&~S[0];
	assign m[23] = S[4]&~S[3]& S[2]& S[1]& S[0];
	assign m[24] = S[4]& S[3]&~S[2]&~S[1]&~S[0];
	assign m[25] = S[4]& S[3]&~S[2]&~S[1]& S[0];
	assign m[26] = S[4]& S[3]&~S[2]& S[1]&~S[0];
	assign m[27] = S[4]& S[3]&~S[2]& S[1]& S[0];
	assign m[28] = S[4]& S[3]& S[2]&~S[1]&~S[0];
	assign m[29] = S[4]& S[3]& S[2]&~S[1]& S[0];
	assign m[30] = S[4]& S[3]& S[2]& S[1]&~S[0];
	assign m[31] = S[4]& S[3]& S[2]& S[1]& S[0];
	
endmodule

module Mux32to1Nbit(F, S, I00, I01, I02, I03, I04, I05, I06, I07, I08, I09, 
								  I10, I11, I12, I13, I14, I15, I16, I17, I18, I19, 
								  I20, I21, I22, I23, I24, I25, I26, I27, I28, I29,
								  I30, I31);

parameter n = 8;
output reg[n-1:0]F; //output
input [4:0]S; //select
input [n-1:0]I00, I01, I02, I03, I04, I05, I06, I07, I08, I09;
input [n-1:0]I10, I11, I12, I13, I14, I15, I16, I17, I18, I19;
input [n-1:0]I20, I21, I22, I23, I24, I25, I26, I27, I28, I29;
input [n-1:0]I30, I31;

always @(*) begin
		case(S)
			5'h00: F <= I00;
			5'h01: F <= I01;
			5'h02: F <= I02;
			5'h03: F <= I03;
			5'h04: F <= I04;
			5'h05: F <= I05;
			5'h06: F <= I06;
			5'h07: F <= I07;
			5'h08: F <= I08;
			5'h09: F <= I09;
			5'h0A: F <= I10;
			5'h0B: F <= I11;
			5'h0C: F <= I12;
			5'h0D: F <= I13;
			5'h0E: F <= I14;
			5'h0F: F <= I15;
			5'h10: F <= I16;
			5'h11: F <= I17;
			5'h12: F <= I18;
			5'h13: F <= I19;
			5'h14: F <= I20;
			5'h15: F <= I21;
			5'h16: F <= I22;
			5'h17: F <= I23;
			5'h18: F <= I24;
			5'h19: F <= I25;
			5'h1A: F <= I26;
			5'h1B: F <= I27;
			5'h1C: F <= I28;
			5'h1D: F <= I29;
			5'h1E: F <= I30;
			5'h1F: F <= I31;
		endcase
	end
endmodule

//RegisterFile32x64.v(A, B, SA, SB, D)
module RegisterFile32x64(A, B, SA, SB, D, DA, W, reset, clock, r0, r1, r2, r3, r4, r5, r6, r7);
	output [63:0]A; //A bus
	output [63:0]B; //B bus
	input [4:0]SA; // Select A - A Address
	input [4:0]SB; // Select B - B Address
	input [63:0]D; // Data input
	input [4:0]DA; // Data destination address
	input W; //write enable
	input reset; // positive logic asynchronous reset
	input clock;
	output [63:0]r0, r1, r2, r3, r4, r5, r6, r7;
	
	wire [31:0]m;
	wire [31:0]load_enable;
	Decoder5to32 decoder(DA, m);
	assign load_enable = m & {W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W,W};
	
	wire [63:0]R00, R01, R02, R03, R04, R05, R06, R07, R08, R09;
	wire [63:0]R10, R11, R12, R13, R14, R15, R16, R17, R18, R19;
	wire [63:0]R20, R21, R22, R23, R24, R25, R26, R27, R28, R29;
	wire [63:0]R30, R31;
	
	RegisterNbit reg00 (R00, D, load_enable[0], reset, clock);
	RegisterNbit reg01 (R01, D, load_enable[1], reset, clock);
	RegisterNbit reg02 (R02, D, load_enable[2], reset, clock);
	RegisterNbit reg03 (R03, D, load_enable[3], reset, clock);
	RegisterNbit reg04 (R04, D, load_enable[4], reset, clock);
	RegisterNbit reg05 (R05, D, load_enable[5], reset, clock);
	RegisterNbit reg06 (R06, D, load_enable[6], reset, clock);
	RegisterNbit reg07 (R07, D, load_enable[7], reset, clock);
	RegisterNbit reg08 (R08, D, load_enable[8], reset, clock);
	RegisterNbit reg09 (R09, D, load_enable[9], reset, clock);
	RegisterNbit reg10 (R10, D, load_enable[10], reset, clock);
	RegisterNbit reg11 (R11, D, load_enable[11], reset, clock);
	RegisterNbit reg12 (R12, D, load_enable[12], reset, clock);
	RegisterNbit reg13 (R13, D, load_enable[13], reset, clock);
	RegisterNbit reg14 (R14, D, load_enable[14], reset, clock);
	RegisterNbit reg15 (R15, D, load_enable[15], reset, clock);
	RegisterNbit reg16 (R16, D, load_enable[16], reset, clock);
	RegisterNbit reg17 (R17, D, load_enable[17], reset, clock);
	RegisterNbit reg18 (R18, D, load_enable[18], reset, clock);
	RegisterNbit reg19 (R19, D, load_enable[19], reset, clock);
	RegisterNbit reg20 (R20, D, load_enable[20], reset, clock);
	RegisterNbit reg21 (R21, D, load_enable[21], reset, clock);
	RegisterNbit reg22 (R22, D, load_enable[22], reset, clock);
	RegisterNbit reg23 (R23, D, load_enable[23], reset, clock);
	RegisterNbit reg24 (R24, D, load_enable[24], reset, clock);
	RegisterNbit reg25 (R25, D, load_enable[25], reset, clock);
	RegisterNbit reg26 (R26, D, load_enable[26], reset, clock);
	RegisterNbit reg27 (R27, D, load_enable[27], reset, clock);
	RegisterNbit reg28 (R28, D, load_enable[28], reset, clock);
	RegisterNbit reg29 (R29, D, load_enable[29], reset, clock);
	RegisterNbit reg30 (R30, D, load_enable[30], reset, clock);
	assign R31 = 64'h0;
	
	defparam reg00.n = 64;
	defparam reg01.n = 64;
	defparam reg02.n = 64;
	defparam reg03.n = 64;
	defparam reg04.n = 64;
	defparam reg05.n = 64;
	defparam reg06.n = 64;
	defparam reg07.n = 64;
	defparam reg08.n = 64;
	defparam reg09.n = 64;
	defparam reg10.n = 64;
	defparam reg11.n = 64;
	defparam reg12.n = 64;
	defparam reg13.n = 64;
	defparam reg14.n = 64;
	defparam reg15.n = 64;
	defparam reg16.n = 64;
	defparam reg17.n = 64;
	defparam reg18.n = 64;
	defparam reg19.n = 64;
	defparam reg20.n = 64;
	defparam reg21.n = 64;
	defparam reg22.n = 64;
	defparam reg23.n = 64;
	defparam reg24.n = 64;
	defparam reg25.n = 64;
	defparam reg26.n = 64;
	defparam reg27.n = 64;
	defparam reg28.n = 64;
	defparam reg29.n = 64;
	defparam reg30.n = 64;
	//defparam reg31.n = 64;
	
	assign r0 = R00;
	assign r1 = R01;
	assign r2 = R02;
	assign r3 = R03;
	assign r4 = R04;
	assign r5 = R05;
	assign r6 = R06;
	assign r7 = R07;
	
	
	Mux32to1Nbit muxA (A, SA, R00, R01, R02, R03, R04, R05, R06, R07, R08, R09,
									  R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
									  R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31);
	
	Mux32to1Nbit muxB (B, SB, R00, R01, R02, R03, R04, R05, R06, R07, R08, R09,
									  R10, R11, R12, R13, R14, R15, R16, R17, R18, R19,
									  R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31);
	
	defparam muxA.n = 64;
	defparam muxB.n = 64;
endmodule

module Mux2to1Nbit(zero, one, select, out);

input [63:0]zero, one;
input select;
output [63:0]out;

assign out = select ? one : zero;

endmodule

	
//later
//NbitRegister scrumdidty (whateve);
//defparm scrumdidty.n = 64;