module Memory(clk, rst, Stall, ALUResult, DataIn, MemWr, MemOut, ALUResultOut,
			  MemDataForward);
    
	input clk, rst, Stall, MemWr;
	input[15:0] ALUResult, DataIn;

	output[15:0] MemOut, ALUResultOut, MemDataForward;

	wire[15:0] MemOutRegIn;

	//MEM mem(.ADDRA(ALUResult), .DINA(DataIn), .WEA(MemWr), .CLKA(clk), .DOUTA(MemOutRegIn));
	//Temp Mem
	reg [15:0] mem [0:31];
    initial begin
        $readmemh("text_files/mem_initialize.txt", mem);
    end

    assign MemOutRegIn = mem[ALUResult];
    always @ (posedge clk) begin
    	if(MemWr) begin
    		mem[ALUResult] <= DataIn;
    	end
    end
    assign MemDataForward = MemOutRegIn;

	MemoryReg Reg (.clk(clk), .rst(rst), .stall(Stall), .MemOutIn(MemOutRegIn),
				   .ALUResultOutIn(ALUResult), .MemOutOut(MemOut), .ALUResultOutOut(ALUResultOut));

endmodule