module lab3_CJ(input logic clk,
 input logic reset,
 input logic left, right,
 output logic la, lb, lc, ra, rb, rc);
 
	// Declare internal logic
 	logic [6:0] s, sp;
	logic nr, nl, temp1;

	// HDL Example 7.8 Resettable Flip-Flop from textbook
	always_ff @ (posedge clk, posedge reset)
					if (reset) s <= 7'b0000001;
					else s<=sp;
					
	////		 State Changing:
	
	// Negating left and right inputs
	not n1(nr, right);
	not n2(nl, left);
	
	// Logic for sp[0]
	and a1(temp1, nr, nl, s[0]);
	or o1(sp[0], temp1, s[5], s[6]);
	
	// Logic for sp[1]
	and a2(sp[1], left, nr, s[0]);
	
	// Logic for sp[2]
	and a3(sp[2], nl, right, s[0]);
	
	// Logic for sp[3]
	buf b1(sp[3], s[1]);
	
	// Logic for sp[4]
	buf b2(sp[4], s[2]);
		
	// Logic for sp[5]
	buf b3(sp[5], s[3]);
			
	// Logic for sp[6]
	buf b4(sp[6], s[4]);
	
	//		 Logic for Outputs:
	
	
	// la logic
	or o2(la, s[1], s[3], s[5]);
	
	// lb logic
	or o3(lb, s[3], s[5]);
	
	// lc logic
	buf b5(lc, s[5]);
	
	// ra logic
	or o4(ra, s[2], s[4], s[6]);
	
	// lb logic
	or o5(rb, s[6], s[4]);
	
	// lc logic
	buf b6(rc, s[6]);
	
 
endmodule