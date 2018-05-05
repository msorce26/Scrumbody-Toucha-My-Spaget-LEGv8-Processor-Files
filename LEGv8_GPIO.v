module LEGv8_GPIO(clock, reset, data, address, write, read, out);
	input[63:0] address;
	inout [63:0] data, out;
	input write, read, clock, reset;
	/*output pord;
	output [15:0] dout, oout;
	output lc;*/
	
	wire pd_out, dd_out, in_out;
	
	wire [63:0] inQ, outQ, dirQ;
	
	/*assign pord = pd_out;
	assign dout = data[15:0];
	assign oout = outQ[15:0];
	assign lc = (write & pd_out);*/
	
	portdet pd(address, pd_out);
	dirdet dd(address, dd_out);
	indet id(address, in_out);
	
	
	assign data = (read & in_out) ? inQ:64'bz;
	assign data = (read & pd_out) ? outQ:64'bz;
	assign data = (read & dd_out) ? dirQ:64'bz;
	
	
	RegisterNbit IN(inQ, out, 1'b1, reset, clock);
	RegisterNbit OUT(outQ, data, (write & pd_out), reset, clock);
	RegisterNbit DIR(dirQ, data, (dd_out & write), reset, clock);
	defparam IN.n = 64;
	defparam OUT.n = 64;
	defparam DIR.n = 64;
	
	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1)begin: PIN_GEN
			assign out[i] = dirQ[i] ? outQ[i] : 1'bz;
		end
	endgenerate
	
endmodule


module portdet(address, out);
	input [63:0]address;
	output out;

	parameter out_det = 64'h0000000000000000;
	
	assign out = (out_det == address) ? 1'b1 : 1'b0;
	
endmodule


module dirdet(address, out);
	input [63:0]address;
	output out;
	
	parameter dir_det = 64'h0000000000000001;
	
	assign out = (dir_det == address) ? 1'b1 : 1'b0;

endmodule


module indet(address, out);
	input [63:0]address;
	output out;
	
	parameter in_det = 64'h0000000000000002;
	
	assign out = (in_det == address) ? 1'b1 : 1'b0;

endmodule

