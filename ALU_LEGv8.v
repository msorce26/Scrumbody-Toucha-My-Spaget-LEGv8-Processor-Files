module ALU_LEGv8(A, B, FS, C0, F, status);

	input [63:0] A, B;
	input [4:0]FS;
	//FS0 - b invert
	//FS1 - a invert
	//FS4:2 - op.select
	//  000 - AND
	//  001 - OR
	//  010 - ADD
	//  011 - XOR
	//  100 - shiftleft
	//  101 - shiftright
	//  110 - 0
	//  111 - 0
	input C0;
	output [63:0]F;
	output [3:0]status;
	
	wire Z, N, C, V;
	assign status = {V, C, N, Z};
	
	wire[63:0] A_Signal, B_Signal;
	//A MUX
	assign A_Signal = FS[1] ? ~A : A;
	//B MUX
	assign B_Signal = FS[0] ? ~B : B;
	
	assign N = F[63];
	
	assign Z = (F == 64'b0) ? 1'b1 : 1'b0;
	
	assign V = ~(A_Signal[63] ^ B_Signal[63]) & (F[63] ^ A_Signal[63]);
	
	
	
	wire [63:0]and_output, or_output, xor_output, add_output, shift_left, shift_right;
	
	assign and_output = A_Signal & B_Signal;
	assign or_output = A_Signal | B_Signal;
	assign xor_output = A_Signal ^ B_Signal;
	
	Adder adder_inst (A_Signal, B_Signal, C0, add_output, C);
	Shifter shift_inst(A, B[5:0], shift_left, shift_right);
	
	Mux8to1Nbit main_mux (F, FS[4:2], and_output, or_output, add_output, xor_output, shift_left, shift_right, 64'b0, 64'b0);

endmodule

module Shifter(A, shift_amount, left, right);
	input[63:0] A;
	input[5:0]shift_amount;
	output[63:0]left, right;
	
	assign left = A << shift_amount;
	assign right = A >> shift_amount;
endmodule

module Adder (A, B, Cin, S, Cout);
	input [63:0] A, B;
	input Cin;
	output [63:0] S;
	output Cout;
	
	assign {Cout, S} = A + B + Cin;
	
endmodule

module Mux8to1Nbit(F, S, I0, I1, I2, I3, I4, I5, I6, I7);
	parameter N = 64;
	input [N-1:0]I0, I1, I2, I3, I4, I5, I6, I7;
	input [2:0]S;
	output [N-1:0]F;

	assign F = S[2] ? (S[1] ? (S[0] ? I7 : I6) : (S[0] ? I5 : I4)) : (S[1] ? (S[0] ? I3 : I2) : (S[0] ? I1 : I0));
	
endmodule

module Mux4to1Nbit(F, S, I0, I1, I2, I3);
	parameter N = 64;
	input [N-1:0]I0, I1, I2, I3;
	input [1:0]S;
	output [N-1:0]F;
	
	assign F = S[1] ? (S[0] ? I3 : I2) : (S[0] ? I1 : I0);
	//assign F = S[2] ? (S[1] ? (S[0] ? I7 : I6) : (S[0] ? I5 : I4)) : (S[1] ? (S[0] ? I3 : I2) : (S[0] ? I1 : I0));
	
endmodule

module Mux2to1Nbit2(zero, one, select, out);

	parameter N = 64;
	input [N-1:0]zero, one;
	input select;
	output [N-1:0]out;

	assign out = select ? one : zero;

endmodule

