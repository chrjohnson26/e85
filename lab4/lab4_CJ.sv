module lab4_CJ(input logic reset,
					input logic clk,
					input logic N, W, E, S,
					output logic WIN, DIE);
	
		logic visited, V, vicroy, loss;
		
		room(clk, reset, N, W, E, S, V, visited, vicroy, loss);
		sword(clk, reset, visited, V);
		
		
		// output logic
		assign WIN = (vicroy);
		assign DIE = (loss);

endmodule



module room(input logic clk,
				input logic reset,
				input logic N, W, E, S,
				input logic V,
				output logic visited,
				output logic vicroy,
				output logic loss);
				
		// Internal logic for states
		typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6} statetype;
		statetype state, nextstate;
		
		// state register
		always_ff @(posedge clk, posedge reset)
			if (reset) state <= S0;
			else state <= nextstate;
			
		// net state logic 
		always_comb
			case (state)
				S0: 		if (E)		nextstate = S1;
							else			nextstate = S0;
				
				S1:		if (W)		nextstate = S0;
							else if (S)	nextstate = S2;
							else			nextstate = S1;
							
				S2:		if (N)		nextstate = S1;
							else if (W)	nextstate = S3;
							else if (E)	nextstate = S4;
							else			nextstate = S2;
							
				S3:		if (E)		nextstate = S2;
							else			nextstate = S3;
				
				S4:		if (V & W)	nextstate = S2;
							else if (V & E) nextstate = S6;
							else if (~V)		nextstate = S5;
							else 			nextstate = S4;
							
				default: nextstate = state;
			endcase
				
		// output logic
		assign vicroy = (state == S6);
		assign loss = (state == S5);
		assign visited = (state == S3);
				
endmodule


			
module sword(input logic clk,
				input logic reset,
				input logic visited,
				output logic V);


		// Internal logic for states
		typedef enum logic [1:0] {D0, D1} statetype;
		statetype state, nextstate;
		
		// state register
		always_ff @(posedge clk, posedge reset)
			if (reset) state <= D0;
			else state <= nextstate;
			
		// next state logic
		always_comb
			case (state)
				D0: 		if (visited)		nextstate = D1;
							else			nextstate = D0;
				default:					nextstate = state;
			endcase
		
		// output logic
		assign V = (state == D1);
							
endmodule
