module Memory(clk, rst, Stall, ALUResult, DataIn, MemWr, MemOut, ALUResultOut);
    
	input clk, rst, Stall, MemWr;
	input[15:0] ALUResult, DataIn;

	output[15:0] MemOut, ALUResultOut;

	wire[15:0] MemOutRegIn, ALUResultOutRegIn;

	assign ALUResultOut = ALUResult;

	MEM mem(.ADDRA(ALUResult), .DINA(DataIn), .WEA(MemWr), .CLKA(clk), .DOUTA(MemOutRegIn));

	MemoryReg Reg (.clk(clk), .rst(rst), .stall(Stall), .MemOutIn(MemOutRegIn),
				   .ALUResultOutIn(ALUResultOutRegIn), .MemOutOut(MemOut), .ALUResultOutOut(ALUResultOut));

endmodule