module LEGv8_TopLevel(CLOCK_50, SW, LEDG, BUTTON, GPIO1_D, GPIO0_D, HEX0, HEX1, HEX2, HEX3);
	input CLOCK_50;
	input [9:0]SW;
	input [2:0]BUTTON;
	output [9:0]LEDG;
	inout [63:0]GPIO1_D;
	output [63:0]GPIO0_D;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	
	wire clock, reset, M_Write, En_Ram;
	tri [63:0]data;
	tri [63:0]portA;
	wire [63:0]address;
	
	wire clock25;
	
	myPLL mp(CLOCK_50,clock25);
	assign clock = clock25;
	//assign clock = ~BUTTON[1];
	assign reset = ~BUTTON[0];
	
	wire [31:0] I;
	wire [63:0] r0, r1, r2, r3, r4, r5, r6, r7, PC;
	
	LEGv8Processor lp(clock, reset, r0, r1, r2, r3, r4, r5, r6, r7, PC, data, address, M_Write, En_Ram, I);
	
	

	
	tri [63:0] g0, g1, g2, g3, g4, g5, g6, g7, g8;

	LEGv8_GPIO gp0(clock, reset, data, address, M_Write, En_Ram, g0);
	LEGv8_GPIO gp1(clock, reset, data, address, M_Write, En_Ram, g1);
	LEGv8_GPIO gp2(clock, reset, data, address, M_Write, En_Ram, g2);
	LEGv8_GPIO gp3(clock, reset, data, address, M_Write, En_Ram, g3);
	LEGv8_GPIO gp4(clock, reset, data, address, M_Write, En_Ram, g4);
	LEGv8_GPIO gp5(clock, reset, data, address, M_Write, En_Ram, g5);
	LEGv8_GPIO gp6(clock, reset, data, address, M_Write, En_Ram, g6);
	LEGv8_GPIO gp7(clock, reset, data, address, M_Write, En_Ram, g7);
	
	LEGv8_GPIO gp8(clock, reset, data, address, M_Write, En_Ram, g8);
	
	defparam gp0.pd.out_det = 64'h1000000000000000;
	defparam gp1.pd.out_det = 64'h1000000000000008;
	defparam gp2.pd.out_det = 64'h1000000000000010;
	defparam gp3.pd.out_det = 64'h1000000000000018;
	defparam gp4.pd.out_det = 64'h1000000000000020;
	defparam gp5.pd.out_det = 64'h1000000000000028;
	defparam gp6.pd.out_det = 64'h1000000000000030;
	defparam gp7.pd.out_det = 64'h1000000000000038;
	defparam gp8.pd.out_det = 64'h1000000000000040;
	
	defparam gp0.dd.dir_det = 64'h1000000000000100;
	defparam gp1.dd.dir_det = 64'h1000000000000108;
	defparam gp2.dd.dir_det = 64'h1000000000000110;
	defparam gp3.dd.dir_det = 64'h1000000000000118;
	defparam gp4.dd.dir_det = 64'h1000000000000120;
	defparam gp5.dd.dir_det = 64'h1000000000000128;
	defparam gp6.dd.dir_det = 64'h1000000000000130;
	defparam gp7.dd.dir_det = 64'h1000000000000138;
	defparam gp8.dd.dir_det = 64'h1000000000000140;
	
	defparam gp0.id.in_det = 64'h1000000000000200;
	defparam gp1.id.in_det = 64'h1000000000000208;
	defparam gp2.id.in_det = 64'h1000000000000210;
	defparam gp3.id.in_det = 64'h1000000000000218;
	defparam gp4.id.in_det = 64'h1000000000000220;
	defparam gp5.id.in_det = 64'h1000000000000228;
	defparam gp6.id.in_det = 64'h1000000000000230;
	defparam gp7.id.in_det = 64'h1000000000000238;
	
	defparam gp8.id.in_det = 64'h1000000000000058;
	
	
	GPIO_Board gpio_board(
	CLOCK_50,
	g0[63:48], g1[63:48], g2[63:48], g3[63:48], g4[63:48], g5[63:48], g6[63:48], g7[63:48],
	h0, 1'b0, h1, 1'b0,
	h2, 1'b0, h3, 1'b0,
	h4, 1'b0, h5, 1'b0,
	h5, 1'b0, h7, 1'b0,
	DIP_SW,
	I,
	GPIO0_D,
	GPIO1_D
	);
	
	wire[6:0] h0, h1, h2, h3, h4, h5, h6, h7;
	wire[6:0] hex0, hex1, hex2, hex3;
	quad_7seg_decoder address_decoder (address[15:0], h7, h6, h5, h4);
	quad_7seg_decoder data_decoder (data[15:0], h3, h2, h1, h0);
	quad_7seg_decoder pc_decoder (PC[15:0], hex3, hex2, hex1, hex0);
	wire [31:0] DIP_SW;
	
	assign HEX0 = ~hex0;
	assign HEX1 = ~hex1;
	assign HEX2 = ~hex2;
	assign HEX3 = ~hex3;
	
	/*
	GPIO_Board gpio_board(
	CLOCK_50,
	r0[15:0], r1[15:0], r2[15:0], r3[15:0], r4[15:0], r5[15:0], r6[15:0], r7[15:0],
	h0, 1'b0, h1, 1'b0,
	h2, 1'b0, h3, 1'b0,
	h4, 1'b0, h5, 1'b0,
	h5, 1'b0, h7, 1'b0,
	DIP_SW,
	I,
	GPIO0_D,
	GPIO1_D
	);*/
	/*clock_50, // connect to CLOCK_50 of the DE0
	R0, R1, R2, R3, R4, R5, R6, R7, // row display inputs
	HEX0, HEX0_DP, HEX1, HEX1_DP, // hex display inputs
	HEX2, HEX2_DP, HEX3, HEX3_DP, 
	HEX4, HEX4_DP, HEX5, HEX5_DP, 
	HEX6, HEX6_DP, HEX7, HEX7_DP, 
	DIP_SW, // 32x DIP switch output
	LEDS, // 32x LED input
	GPIO_0, // (output) connect to GPIO0_D
	GPIO_1 // (input/output) connect to GPIO1_D*/
	
	assign LEDG[9:0] = r0[9:0];
	assign g8[9:0] = ~En_Ram ? SW[9:0] : 10'bz;
endmodule

