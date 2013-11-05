module Decode(clk, rst, Halt, Stall, Instruct, DataIn, WrEn, SignExSel, ZeroExtend8, SetFlag, WrMuxSel, DataOut2Sel, 
			  NextPC, RsForwarding, RtForwarding, ForwardRs, ForwardRt, Branch, NextPCSel, LoadR7,
			  BranchImmedSel, DataOut1, DataOut2, TruePC, Jump);

	input clk, rst, WrEn, DataOut2Sel, ForwardRs, ForwardRt, Branch, NextPCSel, ZeroExtend8;
	input LoadR7, BranchImmedSel, Jump, Halt, Stall;
	input [1:0] WrMuxSel, SignExSel, SetFlag;
	input [15:0] Instruct, DataIn, NextPC, RsForwarding, RtForwarding;
	output [15:0] DataOut1, DataOut2, TruePC;
	wire [15:0] DataOut1RegIn, DataOut2RegIn;
	wire [15:0] TruePCRegIn;

	wire [2:0] wrMuxOut;
	wire [15:0] SignExt5, SignExt8, SignExt11, ZeroExtOut;
	wire [15:0] PCAddIn1, PCAddIn2, CalculatedPC;
	wire [15:0] RegOut1, RegOut2;
	wire [15:0] Reg1MuxOut, Reg2MuxOut;
	wire BranchFlag, DataZero, Flag, JumpOrBranchFlag;

	assign Data = (LoadR7) ? NextPC : DataIn;

	assign wrMuxOut = (wrMuxOut == 2'b00) ? Instruct[7:5] : 
					  (wrMuxOut == 2'b01) ? Instruct[4:2] :
					  (wrMuxOut == 2'b10) ? Instruct[10:8] :
					  (wrMuxOut == 2'b11) ? 3'd7 : 3'bzzz;

	assign SignExt5 = {{11{Instruct[4]}}, Instruct[4:0]};
	assign SignExt8 = {{8{Instruct[7]}}, Instruct[7:0]};
	assign SignExt11 = {{5{Instruct[10]}}, Instruct[10:0]};
	assign ZeroExtOut = (ZeroExtend8) ? {{8{1'b0}}, Instruct[7:0]} : {{12{1'b0}}, Instruct[3:0]};

	assign SignExt = (SignExSel == 2'b00) ? SignExt5 : 
					 (SignExSel == 2'b01) ? SignExt8 :
					 (SignExSel == 2'b10) ? SignExt11 :
					 (SignExSel == 2'b11) ? ZeroExtOut : 16'dz;

	REGMEM REGMEM(.ADDRA(Instruct[7:5]), .DINA(Data), .WEA(WrEn), .CLKA(clk), .ADDRB(Instruct[7:5]), 
				  .DINB(16'd0), .WEB(1'b0), .CLKB(clk), .DOUTA(RegOut1), .DOUTB(RegOut2));

	assign DataOut1 = (ForwardRs) ? RsForwarding : RegOut1;
	assign Reg2MuxOut = (ForwardRt) ? RtForwarding : RegOut2;

	assign DataOut2 = (DataOut2Sel) ? SignExt : Reg2MuxOut;

	assign PCAddIn1 = (NextPCSel) ? NextPC : RegOut1;
	assign PCAddIn2 = (BranchImmedSel) ? SignExt11 : SignExt8;

	assign DataZero = ~|DataOut1;
	assign Flag = (SetFlag == 2'b00) ? DataZero : //BEQZ
                  (SetFlag == 2'b01) ? ~DataZero : //BNEZ
                  (SetFlag == 2'b10) ? ~DataOut1[15] : //BLTZ
                  (SetFlag == 2'b11) ? (~DataOut1[15] | DataZero) : //BGEZ
                  1'bz; 

	assign CalculatedPC = PCAddIn1 + PCAddIn2;
	assign BranchFlag = Branch & Flag;
	assign JumpOrBranchFlag = BranchFlag | Jump;
	assign TruePC = (JumpOrBranchFlag) ? CalculatedPC : NextPC;

	DecodeReg DECODEREG(.clk(clk), .rst(rst), .stall(Stall), .DataOut1In(DataOut1RegIn), 
						.DataOut2In(DataOut2RegIn), .DataOut1Out(DataOut1),	.DataOut2Out(DataOut2));


endmodule