`timescale 1ns / 1ps
module proc_wrapper(clk, rst);
	
	input clk, rst; 
	wire CLKIN_IBUFG_OUT, CLK0_OUT, LOCKED_OUT;

	clk CLK(clk, rst, CLKIN_IBUFG_OUT, CLK0_OUT, LOCKED_OUT);
	proc PROC(.clk(CLKIN_IBUFG_OUT), .rst(rst));


  
endmodule
