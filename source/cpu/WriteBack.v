module WriteBack(MemOut, ALUOut, MemToReg, WriteBack);

	input MemToReg;
	input[15:0] MemOut, ALUOut;

	output[15:0] WriteBack;

	assign WriteBack = (MemToReg) ? ALUOut : MemOut;

endmodule