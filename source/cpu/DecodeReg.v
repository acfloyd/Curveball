module DecodeReg(clk, rst, Stall, DataOut1In, DataOut2In, WriteDataIn,
				 DataOut1Out, DataOut2Out, WriteDataOut);
	input clk, rst, Stall;
	input [15:0] DataOut1In, DataOut2In, WriteDataIn;
	output reg [15:0] DataOut1Out, DataOut2Out, WriteDataOut;

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			DataOut1Out <= 16'd0;
			DataOut2Out <= 16'd0;
			WriteDataOut <= 16'd0;
		end
		else if (Stall) begin
			DataOut1Out <= DataOut1Out;
			DataOut2Out <= DataOut2Out;
			WriteDataOut <= WriteDataOut;
		end
		else begin
			DataOut1Out <= DataOut1In;
			DataOut2Out <= DataOut2In;
			WriteDataOut <= WriteDataIn;
		end
	end
endmodule

