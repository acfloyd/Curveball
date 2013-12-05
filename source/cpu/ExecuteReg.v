module ExecuteReg(clk, rst, Stall, RemainderIn, ALUOutIn, RemainderOut, 
				  ALUOutOut, WriteDataIn, WriteDataOut);
input clk, rst, Stall;
input[15:0] RemainderIn, ALUOutIn, WriteDataIn;

output reg[15:0] RemainderOut, ALUOutOut, WriteDataOut;

always @(posedge clk, posedge rst) begin
	if (rst) begin
		RemainderOut <= 1'd0;
		ALUOutOut <= 16'd0;
		WriteDataOut <= 16'd0;
	end
	else if (Stall) begin
		RemainderOut <= RemainderOut;
		ALUOutOut <= ALUOutOut;
		WriteDataOut <= WriteDataOut;
	end
	else begin
		RemainderOut <= RemainderIn;
		ALUOutOut <= ALUOutIn;
		WriteDataOut <= WriteDataIn;
	end
end


endmodule