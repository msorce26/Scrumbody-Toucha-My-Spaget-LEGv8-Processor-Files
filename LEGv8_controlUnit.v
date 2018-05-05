module LEGv8_controlUnit(I, status, cw, k, reset, clock);

	input[31:0] I;
	input[4:0] status;
	input reset;
	input clock;
	output [30:0] cw;
	output[63:0] k;
	wire[95:0] mux1_out, mux2_out, mux3_out;
	wire[95:0] D_out, IAr_out, ILo_out, IW_out, RALU_out, B_out, b_cond_out, BL_out, CBZ_out, BR_out;
	
	wire state;
	RegisterNbit state_reg (state, mux3_out[0], 1'b1, reset, clock);
	defparam state_reg.n = 1;
	
	
	
	//op[4:2]
	D_Format inst_D(I, D_out);//0
	IAr inst_IAr(I, IAr_out);//2
	ILo inst_ILo(I, ILo_out);//4
	IW inst_IW(I, state, IW_out);//5
	RALU inst_RALU(I, RALU_out);//6
	
	//op[10:8]
	B inst_B(I, B_out);//0
	b_cond inst_Bcon(I, status[4:1], b_cond_out);//2
	BL inst_BL(I, BL_out);//4
	CBZ inst_CBZ(I, status[0], CBZ_out);//5
	BR inst_BR(I, BR_out);//6
	
	//I:  31 30 29 28 27 26 25 24 23 22 21
	//OP: 10  9  8  7  6  5  4  3  2  1  0
	//OP: 11 10  9  8  7  6  5  4  3  2  1
	Mux8to1Nbit mux1_inst(mux1_out, I[25:23], D_out, 96'bX, IAr_out, 96'bX, ILo_out, IW_out, RALU_out, 96'bX);//op 4:2
	Mux8to1Nbit mux2_inst(mux2_out, I[31:29], B_out, 96'bX, b_cond_out, 96'bX, BL_out, CBZ_out, BR_out, 96'bX);//(F, S, I0, I1, I2, I3, I4, I5, I6, I7); op 10:8
	Mux2to1Nbit2 mux3_inst(mux1_out, mux2_out, I[26], mux3_out);//(zero, one, select, out); I25 is op 5
	defparam mux1_inst.N = 96;
	defparam mux2_inst.N = 96;
	defparam mux3_inst.N = 96;
	
	assign cw = mux3_out[95:65];
	assign k = mux3_out[64:1];


endmodule

module b_cond(I, status, out);
	//k64, ns1
	input [31:0]I;
	input [3:0]status;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	//status[0]
	//V, C, N, Z 3 2 1 0
	//PS1L PS1inst(Z,C,N,V,PS_1,I);
	PS1L PS1inst(status[0],status[2],status[1],status[3],PS[1],I[3:0]);
	
	assign DA = 5'bX;
	assign SA = 5'bX;
	assign SB = 5'bX;
	assign FS = 5'bX;
	assign Bsel = 1'bX;
	assign Asel = 1'b1;
	assign RegWrite = 1'b0;
	assign mem_write = 1'b0;
	assign status_load = 1'b1;
	assign En_B = 1'b0;
	assign En_Alu = 1'b0;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;//check later
	assign PS[0] = 1'b1;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{45{I[23]}},I[23:5]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module PS1L(Z,C,N,V,PS_1,I);
	input Z,C,N,V;
	input[3:0] I;
	output PS_1;

	wire F;

	Mux8to1Nbit mux0 (F, I[3:1], Z, C, N, V, C&~Z, ~(V^N) , (~(V^N))&~Z, ~I[0]);
	defparam mux0.N = 1;
	
	assign PS_1 = F ^ I[0];
endmodule

module D_Format(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = I[4:0];
	assign FS = 5'b01000;
	assign Bsel = 1'b1;
	assign Asel = 1'bX;
	assign RegWrite = I[22];
	assign mem_write = ~I[22];
	assign status_load = 1'b0;
	assign En_B = ~I[22];
	assign En_Alu = 1'b0;
	assign En_mem = I[22];
	assign En_PC = 1'b0;
	assign PS[0] = 1'b1;
	assign PS[1] = 1'b0;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{55{1'b0}},I[20:12]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module CBZ(I, status, out);

	input [31:0]I;
	input status;//status[0]
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = 5'bX;
	assign SA = I[4:0];
	assign SB = 5'b11111;
	assign FS = 5'b00100;
	assign Bsel = 1'b0;
	assign Asel = 1'b1;//change
	assign RegWrite = 1'b0;
	assign mem_write = 1'b0;
	assign status_load = 1'b1;
	assign En_B = 1'b0;
	assign En_Alu = 1'b0;
	assign En_mem = 1'b0;
	assign En_PC = 1'b1;
	assign PS[0] = 1'b1;
	assign PS[1] = I[24] ^ status;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{45{I[23]}},I[23:5]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module B(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = 5'bX;
	assign SA = 5'bX;
	assign SB = 5'bX;
	assign FS = 5'bX;
	assign Bsel = 1'bX;
	assign Asel = 1'b1;
	assign RegWrite = 1'b0;
	assign mem_write = 1'b0;
	assign status_load = 1'b0;
	assign En_B = 1'b0;
	assign En_Alu = 1'b0;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;
	assign PS[0] = 1'b1;
	assign PS[1] = 1'b1;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{38{I[25]}},I[25:0]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module BL(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = 5'b11110;
	assign SA = 5'bX;
	assign SB = 5'bX;
	assign FS = 5'bX;
	assign Bsel = 1'bX;
	assign Asel = 1'b1;
	assign RegWrite = 1'b1;
	assign mem_write = 1'b0;
	assign status_load = 1'b0;
	assign En_B = 1'b0;
	assign En_Alu = 1'b0;
	assign En_mem = 1'b0;
	assign En_PC = 1'b1;
	assign PS[0] = 1'b1;
	assign PS[1] = 1'b1;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{38{I[25]}},I[25:0]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module IAr(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = 5'bX;
	assign FS = {4'b0100, I[30]};
	assign Bsel = 1'b1;
	assign Asel = 1'bX;
	assign RegWrite = 1'b1;
	assign mem_write = 1'b0;
	assign status_load = I[29] & I[30];//I[24]
	assign En_B = 1'b0;
	assign En_Alu = 1'b1;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;
	assign PS[0] = 1'b1;
	assign PS[1] = 1'b0;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{52{1'b0}},I[21:10]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module ILo(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = 5'bX;
	assign FS = {1'b0, I[30] & ~I[29], I[30] ^ I[29], 2'b00};//{0,IR[23]&~IR[22],IR[23] xor IR[22],00}
	assign Bsel = I[28];
	assign Asel = 1'bX;
	assign RegWrite = 1'b1;
	assign mem_write = 1'b0;
	assign status_load = I[29] & I[30];
	assign En_B = 1'b0;
	assign En_Alu = 1'b1;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;
	assign PS[0] = 1'b1;
	assign PS[1] = 1'b0;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{52{1'b0}},I[21:10]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module RALU(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = I[4:0];
	assign SA = I[9:5];
	assign SB = I[20:16];
	assign FS = {(I[24] & I[22]), ((~I[24] & I[30] & ~I[29]) | (I[24] & ~I[22])),(((I[30] ^ I[29])& ~I[24])+(I[24] & I[22] & ~I[21])), 1'b0, (I[24] & ~I[22] & I[30])};//fs2 = ((I30 xor I29)&~I24)+(I24&I22&~I21)
	assign Bsel = I[22];
	assign Asel = 1'bX;
	assign RegWrite = 1'b1;
	assign mem_write = 1'b0;
	assign status_load = ((I[30]&I[29]&~I[24]) + (I[24]&~I[22]&I[29]));
	assign En_B = 1'b0;
	assign En_Alu = 1'b1;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;
	assign PS[0] = 1'b1;
	assign PS[1] = 1'b0;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{58{1'b0}},I[15:10]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module BR(I, out);

	input [31:0]I;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = 5'bX;
	assign SA = I[9:5];
	assign SB = 5'bX;
	assign FS = 5'bX;
	assign Bsel = 1'bX;
	assign Asel = 1'b0;
	assign RegWrite = 1'b0;
	assign mem_write = 1'b0;
	assign status_load = 1'b0;
	assign En_B = 1'b0;
	assign En_Alu = 1'b0;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;
	assign PS[0] = 1'b0;
	assign PS[1] = 1'b1;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{38{I[25]}},I[25:0]};
	assign NS = 0;
	
	assign out = {cw, k, NS};
	
endmodule

module IW(I, state, out);

	input [31:0]I;
	input state;
	output [95:0]out; // = {cw, k, ns};
	
	wire [30:0]cw;
	
	
	wire [4:0]DA, SA, SB, FS;
	wire Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC;
	wire [1:0]PS;
	wire [63:0] k;
	wire NS;
	//{DA, SA, SB, FS, BSel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	assign DA = I[4:0];
	assign SA = {(~I[29] | I[4]),(~I[29] | I[3]),(~I[29] | I[2]),(~I[29] | I[1]),(~I[29] | I[0])};//see notes
	assign SB = 5'bX;
	assign FS = {1'b0, 1'b0, (~I[29] | state), 1'b0, 1'b0};//see notes
	assign Bsel = 1'b1;
	assign Asel = 1'b0;
	assign RegWrite = 1'b1;
	assign mem_write = 1'b0;
	assign status_load = 1'b0;
	assign En_B = 1'b0;
	assign En_Alu = 1'b1;
	assign En_mem = 1'b0;
	assign En_PC = 1'b0;
	assign PS[0] = ~I[29] | state;
	assign PS[1] = 1'b0;
	
	assign cw = {DA, SA, SB, FS, Bsel, Asel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS};
	
	assign k = {{48{(I[29] & ~state)}},
	((~I[29] | state) & I[20]),((~I[29] | state) & I[19]),((~I[29] | state) & I[18]),((~I[29] | state) & I[17]),((~I[29] | state) & I[16]),
	((~I[29] | state) & I[15]),((~I[29] | state) & I[14]),((~I[29] | state) & I[13]),((~I[29] | state) & I[12]),((~I[29] | state) & I[11]),
	((~I[29] | state) & I[10]),((~I[29] | state) & I[9]),((~I[29] | state) & I[8]),((~I[29] | state) & I[7]),((~I[29] | state) & I[6]),
	((~I[29] | state) & I[5])};//see notes
	assign NS = (I[29] & ~state);//see notes
	
	assign out = {cw, k, NS};
	
endmodule

/*
module b_cond(instruction, Control_Word, literal);
	input[31:0] instruction;
	output[29:0] Control_Word;
	output[63:0] literal;
	
	wire PS_1;
	wire[10:0]opcode;
	
	assign opcode = instruction[31:21];
	
	PS1 inst0(Z, C, N, V, PS_1, instruction[3:0]);
	assign literal = {
	instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],
	instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],
	instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],
	instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],instruction[23],
	instruction[23:0]};
	
	assign Control_Word = {5'bX, 5'bX, 5'bX, 5'bX, 1'bX, 1'bX, 0, 0, 0, 0, PS_1, 1, 1, 1, 1};
	
endmodule
*/




