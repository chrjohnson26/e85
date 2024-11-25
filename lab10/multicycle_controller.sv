// lab10_CJ
// risc-v multicycle controller
// Christian Johnson
// chrjohnson@hmc.edu
// 11/24/2024

// Structural Verilog Code for the ALU controller

module multicycle_controller(input logic clk,
						 input logic reset, 
						 input logic [6:0] op,
						 input logic [2:0] funct3,
						 input logic funct7b5,
						 input logic zero,
						 output logic [1:0] immsrc,
						 output logic [1:0] alusrca, alusrcb,
						 output logic [1:0] resultsrc, 
						 output logic adrsrc,
						 output logic [2:0] alucontrol,
						 output logic irwrite, pcwrite, 
						 output logic regwrite, memwrite);
		
		// Defining internal logic for the multicycle controller
		logic pcupdate, branch;	
		logic [1:0] aluop;
		
		// Calling mainFSM module
		mainFSM fsm(clk, reset, op, pcupdate, branch, regwrite, memwrite, irwrite, resultsrc, alusrca, alusrcb, adrsrc, aluop);
		
		
		/*
		Calling alu_decoder (from lab 2 implementation)
		aluop[1]: a
		aluop[0]: b
		
		funct3[2]: c
		funct3[1]: d
		funct3[0]: e
		
		op[5]: 	 f
		funct7b5: g
		*/
		alu_decoder aludec(aluop[1], aluop[0], funct3[2], funct3[1], funct3[0], op[5], funct7b5, alucontrol[2], alucontrol[1], alucontrol[0]);
		
		// Calling instr_decoder module
		instr_decoder id(op, immsrc);
		
							
		// output logic
		assign pcwrite = branch & zero | pcupdate;
endmodule



module mainFSM(input logic clk,
					input logic reset,
					input logic [6:0] op,
					output logic pcupdate,
					output logic branch,
					output logic regwrite, memwrite,
					output logic irwrite,
					output logic [1:0] resultsrc,
					output logic [1:0] alusrca, alusrcb,
					output logic adrsrc,
					output logic [1:0] aluop);
					
					
		// Internal logic for states
		typedef enum logic [3:0] {FETCH, DECODE, MEMADR, MEMREAD, MEMWB, MEMWRITE, EXECUTER, ALUWB, EXECUTEI, JAL, BEQ} statetype;
		statetype state, nextstate;
		logic [13:0] controls;
		
		// state register
		always_ff @(posedge clk, posedge reset)
			if (reset) state <= FETCH;
			else state <= nextstate;
			
		
		// next state logic
		always_comb
			casez (state)
				FETCH:		nextstate = DECODE;
				
				DECODE:		casez(op)
									7'b0?00011:			nextstate = MEMADR;
									7'b0110011:			nextstate = EXECUTER;
									7'b0010011:			nextstate = EXECUTEI;
									7'b1101111:			nextstate = JAL;
									7'b1100011:			nextstate = BEQ;
									default:				nextstate = state;
								endcase
									
				MEMADR:		casez(op)
									7'b0000011:			nextstate = MEMREAD;
									7'b0100011:			nextstate = MEMWRITE;
									default:				nextstate = state;
								endcase
				
				MEMREAD:		nextstate = MEMWB;
				
				MEMWB:		nextstate = FETCH;
				
				MEMWRITE:	nextstate = FETCH;
				
				EXECUTER:	nextstate = ALUWB;
				
				ALUWB:		nextstate = FETCH;
				
				EXECUTEI:   nextstate = ALUWB;
				
				JAL:			nextstate = ALUWB;
				
				BEQ:			nextstate = FETCH;
				
				default:		nextstate = state;
		endcase
		
	
				
		// setting current state signals
		always_comb
			case (state)
						// pcupdate__branch__regwrite__memwrite__irwrite__resultsrc__alusrcb__alusrca__adrsrc__aluop
				FETCH: 		controls = 14'b1_0_0_0_1_10_10_00_0_00;
				
				DECODE:		controls = 14'b0_0_0_0_0_00_01_01_0_00;
				
				MEMADR:		controls = 14'b0_0_0_0_0_00_01_10_0_00;
					
				MEMREAD: 	controls = 14'b0_0_0_0_0_00_00_00_1_00;
					
				MEMWB:		controls = 14'b0_0_1_0_0_01_00_00_0_00;
					
				MEMWRITE:	controls = 14'b0_0_0_1_0_00_00_00_1_00;
					
				EXECUTER:	controls = 14'b0_0_0_0_0_00_00_10_0_10;
					
				ALUWB:		controls = 14'b0_0_1_0_0_00_00_00_0_00;
					
				EXECUTEI:	controls = 14'b0_0_0_0_0_00_01_10_0_10;
					
				JAL:			controls = 14'b1_0_0_0_0_00_10_01_0_00;
					
				BEQ:			controls = 14'b0_1_0_0_0_00_00_10_0_01;
					
				default:		controls = 14'b0_0_0_0_0_00_00_00_0_00;
		endcase
			
			assign {pcupdate, branch, regwrite, memwrite, irwrite, resultsrc, alusrcb, alusrca, adrsrc, aluop} = controls;
endmodule
		
			
		

						 
// Structural Verilog Code for the ALU Decoder adapted from lab 2
module alu_decoder(input  logic a, b, c, d, e, f, g, 
						output logic y2, y1, y0);
		// Declaring the internal logic signals or local variables
		// which can only be used inside of this module
		logic n1, n2, n3, na, nb, nc, nd, ne;
		
		// Getting negations of each input
		not g1(na, a);
		not g2(nb, b);
		not g3(nc, c);
		not g4(nd, d);
		not g5(ne, e);
		
		// y2 output logic
		and a1(y2, a, nb, nc, d, ne);  
		
		// y1 output logic
		and a2(y1, a, nb, c, d);
		
		// y0 output logic
		and a3(n1, na, b);
		and a4(n2, a, nb, nc, nd, ne, f, g);
		and a5(n3, a, nb, d, ne);
		or o1(y0, n1, n2, n3);
endmodule




// Strucutural Verilog Code for the instr decoder

module instr_decoder(input logic [6:0] op,
							output logic [1:0] immsrc);
							
		// Logic for choosing the immsrc
		always_comb
			casez (op)
				7'b0110011: immsrc <= 2'b00; // R-type data processing (dont care but setting to 0's)
				7'b0010011: immsrc <= 2'b00; // I-type data processing
				7'b0000011: immsrc <= 2'b00; // LW
				7'b0100011: immsrc <= 2'b01; // SW
				7'b1100011: immsrc <= 2'b10; // BEQ
				7'b1101111: immsrc <= 2'b11; // JAL
			 default: immsrc <= 2'b00;		  // ???
		endcase
endmodule
