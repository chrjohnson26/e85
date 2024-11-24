// lab10_CJ
// risc-v multicycle controller
// Christian Johnson
// chrjohnson@hmc.edu
// 11/23/2024

// Structural Verilog Code for the ALU controller

module controller(input logic clk,
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
		
		logic pcupdate, branch;	
		logic [1:0] aluop;
		
		mainFSM fsm(clk, reset, op, pcupdate, branch, regwrite, memwrite, irwrite, resultsrc, alusrca, alusrcb, adrsrc, aluop);
		
		
		// aluop[1]: a
		// aluop[0]: b
		
		// funct3[2]: c
		// funct3[1]: d
		// funct3[0]: e
		
		// op[5]: 	 f
		// funct7b5: g
		alu_decoder aludec(aluop[1], aluop[0], funct3[2], funct3[1], funct3[0], op[5], funct7b5, alucontrol[2], alucontrol[1], alucontrol[0]);
		
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
		typedef enum logic [3:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10} statetype;
		statetype state, nextstate;
		
		// state register
		always_ff @(posedge clk, posedge reset)
			if (reset) state <= S0;
			else state <= nextstate;
			
		
		// next state logic
		always_comb
			case (state)
				S0:		begin
							nextstate = S1;
							adrsrc  = 1'b0;
							irwrite = 1'b1;
							alusrca = 2'b00;
							alusrcb = 2'b10;
							aluop = 2'b00;
							resultsrc = 2'b10;
							pcupdate = 1'b1;
				end
							
				S1:		begin
							if ((op == 7'b0000011) | (op == 7'b0100011))		nextstate = S2;
							else if (op == 7'b0110011) 							nextstate = S6;
							else if (op == 7'b0010011) 							nextstate = S8;
							else if (op == 7'b1101111) 							nextstate = S9;
							else 	  														nextstate = S10;
							alusrca = 2'b01;
							alusrcb = 2'b01;
							aluop   = 2'b00;
							resultsrc = 2'b10;
				end
							
				S2:		begin
							if 	  (op == 7'b0000011)		nextstate = S3;
							else	  							 	nextstate = S5;
							alusrca = 2'b10;
							alusrcb = 2'b01;
							aluop   = 2'b00;
							resultsrc = 2'b10;
				end
							
				S3: 		begin
							nextstate = S4;
							resultsrc = 2'b00;
							adrsrc    = 1'b1;
				end
				
				S4:		begin
							nextstate = S0;
							resultsrc = 2'b01;
							regwrite  = 1'b1;
				end
							
				S5: 		begin
							nextstate = S0;
							resultsrc = 2'b00;
							adrsrc    = 1'b1;
							memwrite  = 1'b1;
				end
							
				S6: 		begin
							nextstate = S7;
							alusrca   = 2'b10;
							alusrcb   = 2'b00;
							aluop     = 2'b10;
							resultsrc = 2'b10;
				end
							
				S7: 		begin
							nextstate = S0;
							resultsrc = 2'b00;
							regwrite  = 1'b1;
				end
							
				S8:		begin
							nextstate = S7;
							alusrca 	 = 2'b10;
							alusrcb   = 2'b01;
							aluop		 = 2'b10;
							resultsrc = 2'b10;
				end
				
				S9: 		begin
							nextstate = S7;
							resultsrc = 2'b00;
							regwrite  = 1'b1;
				end
				
				S10: 		begin
							nextstate = S0;
							alusrca   = 2'b10;
							alusrcb   = 2'b00;
							aluop     = 2'b01;
							resultsrc = 2'b00;
							branch    = 1'b1;
				end
				default:	nextstate = state;
		endcase					
endmodule
		
			
		

						 
// Structural Verilog Code for the ALU Decoder

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
			casez(op)
								// regwrite_immsrc_alusrc_branch_memwrite_memtoreg_jump_aluop
				7'b0110011: immsrc <= 2'b00; // R-type data processing (dont care but setting to 0's)
				7'b0010011: immsrc <= 2'b00; // I-type data processing
				7'b0000011: immsrc <= 2'b00; // LW
				7'b0100011: immsrc <= 2'b01; // SW
				7'b1100011: immsrc <= 2'b10; // BEQ
				7'b1101111: immsrc <= 2'b11; // JAL
			 default: immsrc <= 2'b00;		  // ???
		endcase
endmodule