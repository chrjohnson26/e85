module lab5_CJ(input logic reset,
					input logic clk,
					input logic [6:0] key,
					output logic sout);

        logic [31:0] q6, q5, q4, q3, q2, q1, q0;
        logic y;

        // key6 register -- D key
		always_ff @(posedge clk)
            if (reset)     q6 <= 0;
            else           q6 <= q6 + 25228; 

        // key5 register -- F key
		always_ff @(posedge clk)
            if (reset)     q5 <= 0;
            else           q5 <= q5 + 29996; 

        // key4 register -- B key
		always_ff @(posedge clk)
            if (reset)     q4 <= 0;
            else           q4 <= q4 + 42426; 

        // key3 register -- C key
		always_ff @(posedge clk)
            if (reset)     q3 <= 0;
            else           q3 <= q3 + 22471;

        // key2 register -- E key
        always_ff @(posedge clk)
            if (reset)     q2 <= 0;
            else           q2 <= q2 + 28312;

        // key1 register -- G key
        always_ff @(posedge clk)
            if (reset)     q1 <= 0;
            else           q1 <= q1 + 33673;

        // key0 register -- A key
        always_ff @(posedge clk)
            if (reset)     q0 <= 0;
            else           q0 <= q0 + 37796;

        // 7:1 Mux
        // If key[6] is 0, select MSB of q6
        // If key[5] is 0, select MSB of q5
        // If key[4] is 0, select MSB of q4
        // If key[3] is 0, select MSB of q3
        // If key[2] is 0, select MSB of q2
        // If key[1] is 0, select MSB of q1
        // If key[0] is 0, select MSB of q0
        // If no keys are pressed then assign y to 0.

        // Notice that the larger the bit of key the more precedence it has in being selected to play.
        assign y = (~key[6] ? q6 : (~key[5] ? q5[31] : (~key[4] ? q4[31] : (~key[3] ? q3[31]: (~key[2] ? q2[31] : (~key[1] ? q1[31] : (~key[0] ? q0[31]: 0)))))));

        // Output logic
        assign sout = y; // y will either hold the MSB of the respective q value or 0 if no key is pressed.

endmodule
