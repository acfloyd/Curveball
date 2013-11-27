module proc(clk, rst);
	
	input clk, rst;
	
	//Control
	wire Stall, DivStall, NotBranchOrJump, WrRegEn, ZeroExtend8, NextPCSel, BranchImmedSel;
	wire LoadR7, DataOut2Sel, Branch, Jump, AddMode, ZeroB, FlagMux, WrMemEn, MemToReg;
	wire ForwardRs, ForwardRt, FetchStall, Halt;
	wire [1:0] SignExtSel, SetFlagD, ShiftMode, SetFlagE, AOp;
	wire [1:0] RsForwardSel, RtForwardSel, BJForwardSel;
	wire [2:0] WrRegAddr, ALUOp;

	//Fetch
	wire [15:0] NextPC, Instruct, InstructToControl;

	//Decode
	wire [15:0] DataOut1, DataOut2, TruePC;

	//Execute
	wire [15:0] ALUOutExOut, Remainder, DataOut1ExOut;
	wire divReady;
	//Memory
	wire [15:0] ALUResultMemOut, DataMemOut, MemDataForward;

	//Write Back
	wire [15:0] DataWB, WBDataForward;

	Control CONTROL(.clk(clk), .rst(rst), .Stall(Stall), .divReady(divReady), 
					.Instruct(InstructToControl), .NotBranchOrJump(NotBranchOrJump), 
					.WrRegEn(WrRegEn), .WrRegAddr(WrRegAddr), .SignExtSel(SignExtSel), 
					.ZeroExtend8(ZeroExtend8), .NextPCSel(NextPCSel), 
					.BranchImmedSel(BranchImmedSel), .LoadR7(LoadR7), .DataOut2Sel(DataOut2Sel), 
					.ALUOp(ALUOp), .AddMode(AddMode), .ShiftMode(ShiftMode), 
					.SetFlagD(SetFlagD), .Branch(Branch), .Jump(Jump), .SetFlagE(SetFlagE), 
					.AOp(AOp), .ZeroB(ZeroB), .FlagMux(FlagMux), .WrMemEn(WrMemEn), 
					.MemToReg(MemToReg), .RsForwardSel(RsForwardSel), .RtForwardSel(RtForwardSel),
					.ForwardRs(ForwardRs), .ForwardRt(ForwardRt), .FetchStall(FetchStall),
					.BJForwardSel(BJForwardSel), .Halt(Halt));

	Fetch FETCH(.clk(clk), .rst(rst), .Stall(Stall), .Halt(Halt), .FetchStall(FetchStall), .TruePC(TruePC), 
				.NotBranchOrJump(NotBranchOrJump), .NextPC(NextPC), .Instruct(Instruct),
				.InstructToControl(InstructToControl));

	Decode DECODE(.clk(clk), .rst(rst), .Stall(Stall), .Instruct(Instruct), .DataIn(DataWB), 
				  .WrEn(WrRegEn), .SignExtSel(SignExtSel), .ZeroExtend8(ZeroExtend8), 
				  .SetFlag(SetFlagD), .WrRegAddr(WrRegAddr), .DataOut2Sel(DataOut2Sel), 
			  	  .NextPC(NextPC), .Branch(Branch), 
			  	  .NextPCSel(NextPCSel), .LoadR7(LoadR7), .BranchImmedSel(BranchImmedSel), 
			  	  .DataOut1(DataOut1), .DataOut2(DataOut2), .TruePC(TruePC), .Jump(Jump), 
			  	  .ALUForward(ALUOutExOut), .MemData2(MemDataForward), .WriteBackData(WBDataForward),
			  	  .BJForwardSel(BJForwardSel));

	Execute EXECUTE(.DataOut1(DataOut1), .DataOut2(DataOut2),
               		.ForwardRs(ForwardRs), .ForwardRt(ForwardRt), .ALUOp(ALUOp), .SetFlag(SetFlagE), .AOp(AOp),
               		.ZeroB(ZeroB), .ShiftMode(ShiftMode), .AddMode(AddMode), .FlagMux(FlagMux),
               		.clk(clk), .rst(rst), .ALUOut(ALUOutExOut), .Remainder(Remainder), 
               		.DataOut1Out(DataOut1ExOut), .Stall(Stall),
               		.MemData2(MemDataForward), .WriteBackData(WBDataForward), .WriteBack2Data(DataWB), 
               		.RsForwardSel(RsForwardSel), .RtForwardSel(RtForwardSel), .divReady(divReady));

	Memory MEMORY(.clk(clk), .rst(rst), .Stall(Stall), .ALUResult(ALUOutExOut), .DataIn(DataOut1ExOut), 
				  .MemWr(WrMemEn), .MemOut(DataMemOut), .ALUResultOut(ALUResultMemOut), .MemDataForward(MemDataForward));

	WriteBack WRITEBACK(.clk(clk), .rst(rst), .Stall(Stall), .MemOut(DataMemOut), 
						.ALUOut(ALUResultMemOut), .MemToReg(MemToReg), .WriteBack(DataWB), .WBDataForward(WBDataForward));

endmodule
