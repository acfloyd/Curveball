module FetchReg(clk, rst, Stall, NextPCIn, InstructIn, NextPCOut, InstructOut);
	input clk, rst, Stall;
	input [15:0] NextPCIn, InstructIn;
	output reg [15:0] NextPCOut, InstructOut;

	parameter NOP = 16'b1110100000000000;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			NextPCOut <= 16'd0;
			InstructOut <= NOP;
		end
		else if (Stall) begin
			NextPCOut <= NextPCOut;
			InstructOut <= InstructOut;
		end
		else begin
			NextPCOut <= NextPCIn;
			InstructOut <= InstructIn;
		end
	end
endmodule
