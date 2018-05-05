module LEGv8_programCounter(in, PS, PC, PC4, clock, reset);

	input [1:0]PS;
	input[63:0] in;
	input clock, reset;
	output[63:0] PC, PC4;

	wire[63:0] inshift, add2_out, D;
	wire L, PS0, PS1;
	assign PS0 = PS[0];
	assign PS1 = PS[1];

	assign PC4 = PC + 4;
	assign inshift = {in[61:0],2'b00};
	assign add2_out = PC4 + inshift;
	assign L = PS1 | PS0;

	//Mux2to1Nbit min (in, inshift, PS0, min_out);
	//Mux2to1Nbit mreg (PC4, add2_out, PS1, D);
	
	RegisterNbit PCReg (PC, D, L, reset, clock);
	defparam PCReg.n = 64;
	
	Mux4to1Nbit mux2(D, PS, PC, PC4, in, add2_out);


endmodule


