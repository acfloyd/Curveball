module WriteBack(clk, rst, Stall, MemOut, ALUOut, MemToReg, WriteBack);

	input MemToReg, clk, rst, Stall;
	input[15:0] MemOut, ALUOut;

	output[15:0] WriteBack;
   
   wire[15:0] WriteBackRegIn;
   
	assign WriteBackRegIn = (MemToReg) ? ALUOut : MemOut;

	WriteBackReg Reg (.clk(clk), .rst(rst), .stall(Stall),
	                  .WriteBackIn(WriteBackRegIn), .WriteBackOut(WriteBack));

endmodule