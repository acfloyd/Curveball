module FetchReg(clk, rst, halt, stall, NextPCIn, InstructIn, NextPCOut, InstructOut);
	input clk, rst, halt, stall;
	input [15:0] NextPCIn, InstructIn;
	output reg [15:0] NextPCOut, InstructOut;

	parameter NOP = 16'b1110100000000000;
	parameter HALT = 16'b1110000000000000;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			NextPCOut <= 16'd0;
			InstructOut <= NOP;
		end
		else if (halt) begin
			NextPCOut <= 16'd0;
			InstructOut <= HALT;
		end
		else if (stall) begin
			NextPCOut <= NextPCOut;
			InstructOut <= InstructOut;
		end
		else begin
			NextPCOut <= NextPCIn;
			InstructOut <= NextPCOut;
		end
	end
endmodule
