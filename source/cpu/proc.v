module proc(clk, rst);
	
	input clk, rst;
	
	//Control
	wire Stall, DivStall, NotBranchOrJump, WrRegEn, ZeroExtend8, NextPCSel, BranchImmedSel;
	wire LoadR7, DataOut2Sel, Branch, Jump, AddMode, ZeroB, FlagMux, WrMemEn, MemToReg;
	wire [1:0] WrMuxSel, SignExtSel, SetFlagD, ShiftMode, SetFlagE, AOp;
	wire [2:0] ALUOp;

	//Fetch
	wire [15:0] NextPC, Instruct, InstructToControl;

	//Decode
	wire [15:0] DataOut1, DataOut2, TruePC;

	//Execute
	wire [15:0] ALUOutExOut, Remainder, DataOut1ExOut;

	//Memory
	wire [15:0] ALUResultMemOut, DataMemOut;

	//Write Back
	wire [15:0] DataWB;

	Control CONTROL(.clk(clk), .rst(rst), .Stall(Stall), .DivStall(DivStall), 
					.Instruct(InstructToControl), .NotBranchOrJump(NotBranchOrJump), 
					.WrRegEn(WrRegEn), .WrMuxSel(WrMuxSel), .SignExtSel(SignExtSel), 
					.ZeroExtend8(ZeroExtend8), .NextPCSel(NextPCSel), 
					.BranchImmedSel(BranchImmedSel), .LoadR7(LoadR7), .DataOut2Sel(DataOut2Sel), 
					.ALUOp(ALUOp), .AddMode(AddMode), .ShiftMode(ShiftMode), 
					.SetFlagD(SetFlagD), .Branch(Branch), .Jump(Jump), .SetFlagE(SetFlagE), 
					.AOp(AOp), .ZeroB(ZeroB), .FlagMux(FlagMux), .WrMemEn(WrMemEn), 
					.MemToReg(MemToReg));

	Fetch FETCH(.clk(clk), .rst(rst), .Stall(Stall), .TruePC(TruePC), 
				.NotBranchOrJump(NotBranchOrJump), .NextPC(NextPC), .Instruct(Instruct),
				.InstructToControl(InstructToControl));

	Decode DECODE(.clk(clk), .rst(rst), .Stall(Stall), .Instruct(Instruct), .DataIn(DataWB), 
				  .WrEn(WrRegEn), .SignExtSel(SignExtSel), .ZeroExtend8(ZeroExtend8), 
				  .SetFlag(SetFlagD), .WrMuxSel(WrMuxSel), .DataOut2Sel(DataOut2Sel), 
			  	  .NextPC(NextPC), .RsForwarding(0), .RtForwarding(0), 
			  	  .ForwardRs(0), .ForwardRt(0), .Branch(Branch), 
			  	  .NextPCSel(NextPCSel), .LoadR7(LoadR7), .BranchImmedSel(BranchImmedSel), 
			  	  .DataOut1(DataOut1), .DataOut2(DataOut2), .TruePC(TruePC), .Jump(Jump));

	Execute EXECUTE(.DataOut1(DataOut1), .DataOut2(DataOut2), .RsForwarding(0), .RtForwarding(0), 
               		.ForwardRs(0), .ForwardRt(0), .ALUOp(ALUOp), .SetFlag(SetFlagE), .AOp(AOp),
               		.ZeroB(ZeroB), .ShiftMode(ShiftMode), .AddMode(AddMode), .FlagMux(FlagMux),
               		.clk(clk), .rst(rst), .ALUOut(ALUOutExOut), .Remainder(Remainder), 
               		.DataOut1Out(DataOut1ExOut), .DivStall(DivStall), .Stall(Stall));

	Memory MEMORY(.clk(clk), .rst(rst), .Stall(Stall), .ALUResult(ALUOutExOut), .DataIn(DataOut1ExOut), 
				  .MemWr(WrMemEn), .MemOut(DataMemOut), .ALUResultOut(ALUResultMemOut));

	WriteBack WRITEBACK(.clk(clk), .rst(rst), .Stall(Stall), .MemOut(DataMemOut), 
						.ALUOut(ALUResultMemOut), .MemToReg(MemToReg), .WriteBack(DataWB));

endmodule
