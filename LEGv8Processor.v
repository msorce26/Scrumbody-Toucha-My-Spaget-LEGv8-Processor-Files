module LEGv8Processor(clock, reset, r0, r1, r2, r3, r4, r5, r6, r7, PC, data, address, M_Write, En_Ram, inst);// r0, r1, r2, r3, r4, r5, r6, r7, PCo, Datao, Addresso, M_Writeo, En_Ramo
	input clock, reset;
	output [63:0] data;
	output [63:0] address;
	output M_Write;
	output En_Ram;
	output[63:0]r0, r1, r2, r3, r4, r5, r6, r7, PC;
	output [31:0] inst;
	
	wire [63:0]k;
	wire [31:0]I;
	wire [4:0]status;
	wire [30:0]cw;
	wire[63:0] r0, r1, r2, r3, r4, r5, r6, r7, PC;
	
	assign inst = I;
	
	LEGv8_controlUnit CU(I, status, cw, k, reset, clock);
	LEGv8_datapath dp(cw, k, I, clock, reset, status, r0, r1, r2, r3, r4, r5, r6, r7, PC, data, address, M_Write, En_Ram);
	
	//assign data = dp.Data;
	//assign address = dp.alu_output[12:0];
	//assign M_Write = dp.mem_write;
	//assign En_Ran = dp.En_mem;

endmodule
