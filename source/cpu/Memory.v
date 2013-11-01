module Memory(ALUResult, DataIn, MemWr, MemOut, ALUResultOut);

	input MemWr;
	input[15:0] ALUResult, DataIn;

	output[15:0] MemOut, ALUResultOut;

	assign ALUResultOut = ALUResult;

	//MEM mem();

endmodule