module LEGv8_datapath (controlWord, K, instr, clock, reset, status_sig, r0, r1, r2, r3, r4, r5, r6, r7, PCo, Datao, Addresso, M_Writeo, En_Ramo);

	input [30:0]controlWord;
	input [63:0]K;
	input clock;
	input reset;
	output[31:0]instr;
	output [4:0]status_sig;
	output [63:0] r0, r1, r2, r3, r4, r5, r6, r7;
	output [63:0]PCo;
	output [63:0]Datao, Addresso;
	output M_Writeo, En_Ramo;
	
	wire RegWrite, ASel, BSel, En_mem, En_Alu, En_B, mem_write, En_PC, IR_L, status_load;
	wire [1:0]PS;
	wire [4:0]DA, SA, SB, FS;
	wire[3:0] status;//V, C, N, Z
	wire[63:0] A, B, D, Bmuxout, Amuxout, Data, mem_output, alu_output, PC, PC4, Rom_out;
	//wire[63:0] k;
	
	assign PCo = PC;
	
	assign Datao = Data;
	assign Addresso = alu_output;
	assign M_Writeo = mem_write;
	assign En_Ramo = En_mem;
	
	//Asel, k, En_B
	//assign {DA, SA, SB, FS, RegWrite, BSel, C0, En_mem, En_Alu, En_B, mem_write, PS, En_PC, status_load, Asel} = controlWord;
	assign {DA, SA, SB, FS, BSel, ASel, RegWrite, mem_write, status_load, En_B, En_Alu, En_mem, En_PC, PS} = controlWord;
	
	
	
	RegisterFile32x64 Regmain(A, B, SA, SB, Data, DA, RegWrite, reset, clock, r0, r1, r2, r3, r4, r5, r6, r7);
	Mux2to1Nbit Bmux(B, K, BSel, Bmuxout);
	Mux2to1Nbit Amux(A, K, ASel, Amuxout);
	ALU_LEGv8 ALUmain (A, Bmuxout, FS, FS[0], alu_output, status);
	LEGv8_RAM data_mem(alu_output[12:0], clock, Data, mem_write, mem_output);
	LEGv8_programCounter PgC (Amuxout, PS, PC, PC4, clock, reset);
	rom_case RC (instr, PC[17:2]);
	
	RegisterNbit Status_Reg (status_sig[4:1], status, status_load, reset, clock);
	defparam Status_Reg.n = 4;
	assign status_sig[0] = status[0];

	
	assign Data = En_mem ? mem_output:64'bz;//edit mem map here
	assign Data = En_Alu ? alu_output:64'bz;
	assign Data = En_B ? B:64'bz;
	assign Data = En_PC ? PC4:64'bz;
	
	//defparam data_mem.memorywords = 6000;
	
	//RegisterNbit IR (Q, Rom_out, IR_L, reset, clock);
	//defparam IR.n = 32;
	
endmodule
