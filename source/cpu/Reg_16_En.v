module Reg_16_En(clk, rst, WrRegEn, DataIn, DataOut);
	input clk, rst;
	input WrRegEn;
	input [15:0] DataIn;
	output reg [15:0] DataOut;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			DataOut <= 16'd0;
		end
		else if (WrRegEn) begin
			DataOut <= DataIn;
		end
		else begin
			DataOut <= DataOut;
		end
	end

endmodule
