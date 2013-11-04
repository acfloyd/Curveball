module ExecuteReg(clk, rst, stall, DivStallIn, RemainderIn, ALUOutIn, DataOut1In, DivStallOut, RemainderOut, ALUOutOut, DataOut1Out);
input clk, rst, stall, DivStallIn;
input[15:0] RemainderIn, ALUOutIn, DataOut1In;

output reg DivStallOut;
output reg[15:0] RemainderOut, ALUOutOut, DataOut1Out;

always @(posedge clk, posedge rst) begin
	if (rst) begin
		DivStallOut <= 1'b0;
		RemainderOut <= 1'd0;
		ALUOutOut <= 16'd0;
		DataOut1Out <= 16'd0;
	end
	else if (stall) begin
		DivStallOut <= DivStallOut;
		RemainderOut <= RemainderOut;
		ALUOutOut <= ALUOutOut;
		DataOut1Out <= DataOut1Out;
	end
	else begin
		DivStallOut <= DivStallIn;
		RemainderOut <= RemainderIn;
		ALUOutOut <= ALUOutIn;
		DataOut1Out <= DataOut1In;
	end
end


endmodule