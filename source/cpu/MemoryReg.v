module MemoryReg(clk, rst, stall, MemOutIn, ALUResultOutIn, MemOutOut, ALUResultOutOut);
	input clk, rst, stall;
	input [15:0] MemOutIn, ALUResultOutIn;
	output reg [15:0] MemOutOut, ALUResultOutOut;

	parameter NOP = 16'b1110100000000000;
	parameter HALT = 16'b1110000000000000;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			MemOutOut <= 16'd0;
			ALUResultOutOut <= 16'd0;
		end
		else if (stall) begin
			MemOutOut <= MemOutOut;
			ALUResultOutOut <= ALUResultOutOut;
		end
		else begin
			MemOutOut <= MemOutIn;
			ALUResultOutOut <= ALUResultOutIn;
		end
	end
endmodule

