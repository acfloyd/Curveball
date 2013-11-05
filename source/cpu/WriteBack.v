module WriteBack(clk, rst, Stall, MemOut, ALUOut, MemToReg, WriteBack);

	input MemToReg, clk, rst, Stall;
	input[15:0] MemOut, ALUOut;

	output[15:0] WriteBack;

	assign WriteBack = (MemToReg) ? ALUOut : MemOut;

	WriteBackReg Reg (.clk(clk), .rst(rst), .stall(Stall), .WriteBackIn(), WriteBackOut);

endmodule