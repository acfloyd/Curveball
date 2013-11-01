module Execute(NextPC, CalculatedPC, Branch, Jump, DataOut1, DataOut2, RsForwarding, RtForwarding, ForwardRs, ForwardRt, ALUOp, SetFlag, AOp, ZeroB, ShiftMode, AddMode, FlagMux, clk, rst, TruePC, ALUOut, Remainder, DataOut1Out, DivStall);
	input clk, rst, Branch, Jump, ForwardRs, ForwardRt, ZeroB, AddMode, FlagMux;
 	input[1:0] SetFlag, AOp;
 	input[2:0] ALUOp;
 	input[15:0] NextPC, CalculatedPC, DataOut1, DataOut2, RsForwarding, RtForwarding;

 	output DivStall;
 	output[15:0] Remainder, TruePC, ALUOut, DataOut1Out;

 	wire Flag,;
 	wire[15:0] 

 	assign AIn = (ForwardRs) ? RsForwarding : DataOut1;
 	assign BIn = (ForwardRt) ? RtForwarding : DataOut2;
 	//assign TruePC = ((Branch && Flag) || Jump) ? CalculatedPC : NextPC;
 	assign DataOut1Out = DataOut1;

 	ALU ALU (.A(AIn), .B(BIn), .ALUMux(ALUOp), .SetFlag(SetFlag), .AOp(AOp), .ZeroB(ZeroB), .ShiftMode(ShiftMode), .AddMode(AddMode), .clk(clk), .Flag(Flag), .divStall(DivStall), .Out(ALUOut), .Remainder(Remainder), rst(rst));


endmodule