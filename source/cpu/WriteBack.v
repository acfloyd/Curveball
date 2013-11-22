module WriteBack(clk, rst, Stall, MemOut, ALUOut, MemToReg, WriteBack, WBDataForward);

	input MemToReg, clk, rst, Stall;
	input[15:0] MemOut, ALUOut;

	output[15:0] WriteBack, WBDataForward;
   
   	wire[15:0] WriteBackRegIn;
   
	assign WriteBackRegIn = (MemToReg) ? MemOut : ALUOut;
	assign WBDataForward = WriteBackRegIn;

	WriteBackReg Reg (.clk(clk), .rst(rst), .stall(Stall),
	                  .WriteBackIn(WriteBackRegIn), .WriteBackOut(WriteBack));

endmodule