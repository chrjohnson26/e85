module testbench4();
	logic			clk, reset;
	logic			N, W, E, S, WIN_expected, DIE_expected;
	logic			WIN, DIE;
	logic 		[31:0] vectornum, errors; // bookkeeping variables
	logic 		