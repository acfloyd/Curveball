module Execute(DataOut1, DataOut2, ForwardRs, ForwardRt, ALUOp, SetFlag, AOp, ZeroB, ShiftMode, 
               AddMode, FlagMux, clk, rst, ALUOut, Remainder, DataOut1Out, DivStall, 
               Stall, MemData2, WriteBackData, WriteBack2Data, 
               RsForwardSel, RtForwardSel);
	input clk, rst, Stall, ForwardRs, ForwardRt, ZeroB, AddMode, FlagMux;
 	input[1:0] SetFlag, AOp, ShiftMode;
 	input[2:0] ALUOp;
 	input[15:0] DataOut1, DataOut2;
 	//Forwarding
 	input[15:0] MemData2, WriteBackData, WriteBack2Data;
 	input[1:0] RsForwardSel, RtForwardSel;

 	output DivStall;
 	output[15:0] Remainder, ALUOut, DataOut1Out;


 	wire Flag, DivStallRegIn;
 	wire [15:0] AIn, BIn, RemainderRegIn, ALUOutRegIn; 
 	wire [15:0] RsForwarding, RtForwarding;

 	assign RsForwarding = (RsForwardSel == 2'b00) ? ALUOut: 
					  (RsForwardSel == 2'b01) ? MemData2:
					  (RsForwardSel == 2'b10) ? WriteBackData:
					  WriteBack2Data;
	assign RtForwarding = (RtForwardSel == 2'b00) ? ALUOut: 
					  (RtForwardSel == 2'b01) ? MemData2:
					  (RtForwardSel == 2'b10) ? WriteBackData:
					  WriteBack2Data;

 	assign AIn = (ForwardRs) ? RsForwarding : DataOut1;
 	assign BIn = (ForwardRt) ? RtForwarding : DataOut2;

 	ALU ALU (.A(AIn), .B(BIn), .ALUMux(ALUOp), .SetFlag(SetFlag), .AOp(AOp), 
 	         .ZeroB(ZeroB), .ShiftMode(ShiftMode), .AddMode(AddMode), .clk(clk), 
 	         .FlagMux(FlagMux), .divStall(DivStallRegIn), .Out(ALUOutRegIn), .Remainder(RemainderRegIn), .rst(rst));

 	ExecuteReg Reg (.clk(clk), .rst(rst), .Stall(Stall), .RemainderIn(RemainderRegIn),
 					.ALUOutIn(ALUOutRegIn), .DataOut1In(DataOut1), .RemainderOut(Remainder),
 					.ALUOutOut(ALUOut), .DataOut1Out(DataOut1Out));

endmodule
