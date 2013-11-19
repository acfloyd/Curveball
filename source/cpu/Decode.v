module Decode(clk, rst, Stall, Instruct, DataIn, WrEn, SignExtSel, ZeroExtend8, SetFlag, WrMuxSel, DataOut2Sel, 
			  NextPC, RsForwardData, RtForwardData, ForwardRs, ForwardRt, Branch, NextPCSel, LoadR7,
			  BranchImmedSel, DataOut1, DataOut2, TruePC, Jump);

	input clk, rst, WrEn, DataOut2Sel, ForwardRs, ForwardRt, Branch, NextPCSel, ZeroExtend8;
	input LoadR7, BranchImmedSel, Jump, Stall;
	input [1:0] WrMuxSel, SignExtSel, SetFlag;
	input [15:0] Instruct, DataIn, NextPC, RsForwardData, RtForwardData;
	output [15:0] DataOut1, DataOut2, TruePC;
	wire [15:0] DataOut1RegIn, DataOut2RegIn;

	wire [2:0] WrMuxOut;
	wire [15:0] Data;
	wire [15:0] SignExt, SignExt5, SignExt8, SignExt11, ZeroExtOut;
	wire [15:0] PCAddIn1, PCAddIn2, CalculatedPC;
	wire [15:0] RegOut1, RegOut2;
	wire [15:0] Reg2MuxOut;
	wire BranchFlag, DataZero, Flag, JumpOrBranchFlag;

	assign Data = (LoadR7) ? NextPC : DataIn;

	assign WrMuxOut = (WrMuxSel == 2'b00) ? Instruct[7:5] : 
					  (WrMuxSel == 2'b01) ? Instruct[4:2] :
					  (WrMuxSel == 2'b10) ? Instruct[10:8] :
					  (WrMuxSel == 2'b11) ? 3'd7 : 3'bzzz;

	assign SignExt5 = {{11{Instruct[4]}}, Instruct[4:0]};
	assign SignExt8 = {{8{Instruct[7]}}, Instruct[7:0]};
	assign SignExt11 = {{5{Instruct[10]}}, Instruct[10:0]};
	assign ZeroExtOut = (ZeroExtend8) ? {{8{1'b0}}, Instruct[7:0]} : {{12{1'b0}}, Instruct[3:0]};

	assign SignExt = (SignExtSel == 2'b00) ? SignExt5 : 
					 (SignExtSel == 2'b01) ? SignExt8 :
					 (SignExtSel == 2'b10) ? SignExt11 :
					 (SignExtSel == 2'b11) ? ZeroExtOut : 16'dz;

	//Register Mem
	Reg_Mem Reg(.clk(clk), .rst(rst), .DataIn(Data), .AddrS(Instruct[10:8]),
	            .AddrT(Instruct[7:5]), .WrSel(WrMuxOut), .WrRegEn(WrEn), .Rs(RegOut1), .Rt(RegOut2));


	assign DataOut1RegIn = (ForwardRs) ? RsForwardData : RegOut1;
	assign Reg2MuxOut = (ForwardRt) ? RtForwardData : RegOut2;

	assign DataOut2RegIn = (DataOut2Sel) ? SignExt : Reg2MuxOut;

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

	DecodeReg DECODEREG(.clk(clk), .rst(rst), .Stall(Stall), .DataOut1In(DataOut1RegIn), 
						.DataOut2In(DataOut2RegIn), .DataOut1Out(DataOut1),	.DataOut2Out(DataOut2));


endmodule
