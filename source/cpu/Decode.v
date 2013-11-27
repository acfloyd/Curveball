module Decode(clk, rst, Stall, Instruct, DataIn, WrEn, SignExtSel, ZeroExtend8, SetFlag, WrRegAddr, DataOut2Sel, 
			  NextPC, Branch, NextPCSel, LoadR7,
			  BranchImmedSel, DataOut1, DataOut2, TruePC, Jump,
			  ALUForward, MemData2, WriteBackData, BJForwardSel);

	input clk, rst, WrEn, DataOut2Sel, Branch, NextPCSel, ZeroExtend8;
	input LoadR7, BranchImmedSel, Jump, Stall;
	input [1:0] SignExtSel, SetFlag, BJForwardSel;
	input [2:0] WrRegAddr;
	input [15:0] Instruct, DataIn, NextPC;
	input [15:0] ALUForward, MemData2, WriteBackData;
	output [15:0] DataOut1, DataOut2, TruePC;
	wire [15:0] DataOut1Temp, DataOut1RegIn, DataOut2RegIn;

	wire [15:0] SignExt, SignExt5, SignExt8, SignExt11, ZeroExtOut;
	wire [15:0] PCAddIn1, PCAddIn2, CalculatedPC;
	wire [15:0] RegOut1, RegOut2;
	wire BranchFlag, DataZero, Flag, JumpOrBranchFlag;

	//assign Data = (LoadR7) ? NextPC : DataIn;

	assign SignExt5 = {{11{Instruct[4]}}, Instruct[4:0]};
	assign SignExt8 = {{8{Instruct[7]}}, Instruct[7:0]};
	assign SignExt11 = {{5{Instruct[10]}}, Instruct[10:0]};
	assign ZeroExtOut = (ZeroExtend8) ? {{8{1'b0}}, Instruct[7:0]} : {{12{1'b0}}, Instruct[3:0]};

	assign SignExt = (SignExtSel == 2'b00) ? SignExt5 : 
					 (SignExtSel == 2'b01) ? SignExt8 :
					 (SignExtSel == 2'b10) ? SignExt11 :
					 (SignExtSel == 2'b11) ? ZeroExtOut : 16'dz;

	wire [15:0] RegOut1Wire, RegOut2Wire;
	//Register Mem
	Reg_Mem Reg(.clk(clk), .rst(rst), .DataIn(DataIn), .AddrS(Instruct[10:8]),
	            .AddrT(Instruct[7:5]), .WrSel(WrRegAddr), .WrRegEn(WrEn), .Rs(RegOut1Wire), .Rt(RegOut2Wire));

	assign RegOut1 = (WrEn & (WrRegAddr == Instruct[10:8])) ? DataIn : RegOut1Wire;
	assign RegOut2 = (WrEn & (WrRegAddr == Instruct[7:5])) ? DataIn : RegOut2Wire; 

	assign DataOut1Temp = (LoadR7) ? NextPC : RegOut1;

	assign DataOut2RegIn = (DataOut2Sel) ? SignExt : RegOut2;

	assign DataOut1RegIn = (BJForwardSel == 2'b00) ? ALUForward: 
					  (BJForwardSel == 2'b01) ? MemData2:
					  (BJForwardSel == 2'b10) ? WriteBackData:
					  DataOut1Temp;

	assign PCAddIn1 = (NextPCSel) ? NextPC : RegOut1;
	assign PCAddIn2 = (BranchImmedSel) ? SignExt11 : SignExt8;

	assign DataZero = ~|DataOut1RegIn;
	assign Flag = (SetFlag == 2'b00) ? DataZero : //BEQZ
                  (SetFlag == 2'b01) ? ~DataZero : //BNEZ
                  (SetFlag == 2'b10) ? DataOut1RegIn[15] : //BLTZ
                  (SetFlag == 2'b11) ? (DataOut1RegIn[15] | DataZero) : //BlEZ
                  1'bz; 

	assign CalculatedPC = PCAddIn1 + PCAddIn2;
	assign BranchFlag = Branch & Flag;
	assign JumpOrBranchFlag = BranchFlag | Jump;
	assign TruePC = (JumpOrBranchFlag) ? CalculatedPC : NextPC;

	DecodeReg DECODEREG(.clk(clk), .rst(rst), .Stall(Stall), .DataOut1In(DataOut1RegIn), 
						.DataOut2In(DataOut2RegIn), .DataOut1Out(DataOut1),	.DataOut2Out(DataOut2));


endmodule
