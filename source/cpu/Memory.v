module Memory(clk, rst, Stall, ALUResult, DataIn, MemOut, ALUResultOut,
			  MemDataForward, StoreDataForward, StoreDataForwardSel, WriteBackData, WriteBack2Data,
              ExternalWriteData, ExternalReadData);
    
	input clk, rst, Stall, StoreDataForward, StoreDataForwardSel;
	input[15:0] ALUResult, DataIn, WriteBackData, WriteBack2Data, ExternalReadData;

	output[15:0] MemOut, ALUResultOut, MemDataForward;

    output [15:0] ExternalWriteData;

	wire[15:0] DataForwarded;


    assign DataForwarded = StoreDataForwardSel ? WriteBackData : WriteBack2Data;
    assign ExternalWriteData = StoreDataForward ? DataForwarded : DataIn;
	assign MemDataForward = ExternalReadData;

	MemoryReg Reg (.clk(clk), .rst(rst), .stall(Stall), .MemOutIn(ExternalReadData),
				   .ALUResultOutIn(ALUResult), .MemOutOut(MemOut), .ALUResultOutOut(ALUResultOut));

endmodule