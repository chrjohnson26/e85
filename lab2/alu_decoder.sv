// Structural Verilog Code for the ALU Decoder

module alu_decoder(input  logic a, b, c, d, e, f, g,
						 output logic y2, y1, y0);
		// See page 1 naming inputs and outputs
		// See page 2 for logic reasoning

		
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