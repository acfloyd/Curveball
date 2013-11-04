module DecodeReg(clk, rst, halt, stall, NextPCIn, DataOut1In, DataOut2In, 
				 SignExtIn, InstructIn, TruePCIn, NextPCOut, DataOut1Out, 
				 DataOut2Out, SignExtOut, InstructOut, TruePCOut);
	input clk, rst, halt, stall;
	input [15:0] NextPCIn, DataOut1In, DataOut2In, SignExtIn, InstructIn, TruePCIn;
	output reg [15:0] NextPCOut, DataOut1Out, DataOut2Out, SignExtOut, InstructOut, TruePCOut;

	parameter NOP = 16'b1110100000000000;
	parameter HALT = 16'b1110000000000000;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			NextPCOut <= 16'd0;
			DataOut1Out <= 16'd0;
			DataOut2Out <= 16'd0;
			SignExtOut <= 16'd0;
			InstructOut <= NOP;
			TruePCOut <= 16'd0;
		end
		else if (halt) begin
			NextPCOut <= 16'd0;
			DataOut1Out <= 16'd0;
			DataOut2Out <= 16'd0;
			SignExtOut <= 16'd0;
			InstructOut <= HALT;
			TruePCOut <= 16'd0;
		end
		else if (stall) begin
			NextPCOut <= NextPCOut;
			DataOut1Out <= DataOut1Out;
			DataOut2Out <= DataOut2Out;
			SignExtOut <= SignExtOut;
			InstructOut <= InstructOut;
			TruePCOut <= TruePCOut;
		end
		else begin
			NextPCOut <= NextPCIn;
			DataOut1Out <= DataOut1In;
			DataOut2Out <= DataOut2In;
			SignExtOut <= SignExtIn;
			InstructOut <= InstructIn;
			TruePCOut <= TruePCIn;
		end
	end
endmodule

