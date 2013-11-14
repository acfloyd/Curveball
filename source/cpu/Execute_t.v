module Execute_t();

	reg clk, rst;
	reg [10:0] clkCount;

	wire Stall, DivStall, NotBranchOrJump, WrRegEn, ZeroExtend8, NextPCSel, BranchImmedSel;
	wire LoadR7, DataOut2Sel, Branch, Jump, AddMode, ZeroB, FlagMux, WrMemEn, MemToReg;
	wire [1:0] WrMuxSel, SignExtSel, SetFlagD, ShiftMode, SetFlagE, AOp;
	wire [2:0] ALUOp;

	//Fetch
	wire [15:0] NextPC, Instruct, InstructToControl;

	//Decode
	wire [15:0] DataOut1, DataOut2, TruePC;

	//Execute
	wire [15:0] ALUOut, Remainder, DataOut1Out;

	wire error;

	reg [10:0] controls [0:34];
    initial begin
        $readmemb("text_files/decode_control.txt", controls);
    end
    wire [10:0] controlCompare, actualControls;

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

	Decode DECODE(.clk(clk), .rst(rst), .Stall(Stall), .Instruct(Instruct), .DataIn(0), 
				  .WrEn(WrRegEn), .SignExtSel(SignExtSel), .ZeroExtend8(ZeroExtend8), 
				  .SetFlag(SetFlagD), .WrMuxSel(WrMuxSel), .DataOut2Sel(DataOut2Sel), 
			  	  .NextPC(NextPC), .RsForwarding(0), .RtForwarding(0), 
			  	  .ForwardRs(0), .ForwardRt(0), .Branch(Branch), 
			  	  .NextPCSel(NextPCSel), .LoadR7(LoadR7), .BranchImmedSel(BranchImmedSel), 
			  	  .DataOut1(DataOut1), .DataOut2(DataOut2), .TruePC(TruePC), .Jump(Jump));

	Execute EXECUTE(.DataOut1(DataOut1), .DataOut2(DataOut2), .RsForwarding(0), .RtForwarding(0), 
               		.ForwardRs(0), .ForwardRt(0), .ALUOp(ALUOp), .SetFlag(SetFlagE), .AOp(AOp),
               		.ZeroB(ZeroB), .ShiftMode(ShiftMode), .AddMode(AddMode), .FlagMux(FlagMux),
               		.clk(clk), .rst(rst), .ALUOut(ALUOut), .Remainder(Remainder), 
               		.DataOut1Out(DataOut1Out), .DivStall(DivStall), .Stall(Stall));

	initial begin
    	clk = 0;
    	forever #5 clk = ~clk;
    end

	initial begin
		rst = 1;
		#2 rst = 0;
	end  
	
	always @ (posedge clk, posedge rst) begin
		if(rst) begin
			clkCount = 11'd0;
		end
		else begin
			clkCount = clkCount + 1;
		end
	end
	assign controlCompare = controls[clkCount - 1];
	assign actualControls = {SignExtSel, ZeroExtend8, NextPCSel, BranchImmedSel, LoadR7, DataOut2Sel, SetFlagD, Branch, Jump};
	assign error = !(actualControls == controlCompare);



endmodule