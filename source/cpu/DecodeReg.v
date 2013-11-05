module DecodeReg(clk, rst, Stall, DataOut1In, DataOut2In, 
				 DataOut1Out, DataOut2Out);
	input clk, rst, Stall;
	input [15:0] DataOut1In, DataOut2In;
	output reg [15:0] DataOut1Out, DataOut2Out;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			DataOut1Out <= 16'd0;
			DataOut2Out <= 16'd0;
		end
		else if (Stall) begin
			DataOut1Out <= DataOut1Out;
			DataOut2Out <= DataOut2Out;
		end
		else begin
			DataOut1Out <= DataOut1In;
			DataOut2Out <= DataOut2In;
		end
	end
endmodule

