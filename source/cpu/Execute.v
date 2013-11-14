module Execute(DataOut1, DataOut2, RsForwarding, RtForwarding, 
               ForwardRs, ForwardRt, ALUOp, SetFlag, AOp, ZeroB, ShiftMode, 
               AddMode, FlagMux, clk, rst, ALUOut, Remainder, DataOut1Out, DivStall, Stall);
	input clk, rst, Stall, ForwardRs, ForwardRt, ZeroB, AddMode, FlagMux;
 	input[1:0] SetFlag, AOp, ShiftMode;
 	input[2:0] ALUOp;
 	input[15:0] DataOut1, DataOut2, RsForwarding, RtForwarding;

 	output DivStall;
 	output[15:0] Remainder, ALUOut, DataOut1Out;


 	wire Flag, DivStallRegIn;
 	wire [15:0] AIn, BIn, RemainderRegIn, ALUOutRegIn; 

 	assign AIn = (ForwardRs) ? RsForwarding : DataOut1;
 	assign BIn = (ForwardRt) ? RtForwarding : DataOut2;

 	ALU ALU (.A(AIn), .B(BIn), .ALUMux(ALUOp), .SetFlag(SetFlag), .AOp(AOp), 
 	         .ZeroB(ZeroB), .ShiftMode(ShiftMode), .AddMode(AddMode), .clk(clk), 
 	         .Flag(Flag), .divStall(DivStallRegIn), .Out(ALUOutRegIn), .Remainder(RemainderRegIn), .rst(rst));

 	ExecuteReg Reg (.clk(clk), .rst(rst), .stall(Stall), .DivStallIn(DivStallRegIn), .RemainderIn(RemainderRegIn),
 					.ALUOutIn(ALUOutRegIn), .DataOut1In(DataOut1),.DivStallOut(DivStall), .RemainderOut(Remainder),
 					.ALUOutOut(ALUOut), .DataOut1Out(DataOut1Out));

endmodule
