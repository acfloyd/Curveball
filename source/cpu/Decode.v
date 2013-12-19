module Decode(clk, rst, Stall, Instruct, DataIn, WrEn, SignExtSel, ZeroExtend8, SetFlag, WrRegAddr, DataOut2Sel, 
			  NextPC, Branch, NextPCSel, LoadR7,
			  BranchImmedSel, DataOut1, DataOut2, TruePC, Jump,
			  ALUForward, MemData2, WriteBackData, BJForwardSel, BranchOrJumpRegForwardRs,
			  StoreImmed, WriteData);

	input clk, rst, WrEn, DataOut2Sel, Branch, NextPCSel, ZeroExtend8;
	input LoadR7, BranchImmedSel, Jump, Stall, BranchOrJumpRegForwardRs, StoreImmed;
	input [1:0] SignExtSel, SetFlag, BJForwardSel;
	input [2:0] WrRegAddr;
	input [15:0] Instruct, DataIn, NextPC;
	input [15:0] ALUForward, MemData2, WriteBackData;
	output [15:0] DataOut1, DataOut2, TruePC, WriteData;
	wire [15:0] DataOut1Temp, DataOut1RegIn, DataOut2RegIn, WriteDataIn;

	wire [15:0] SignExt, SignExt5, SignExt8, SignExt11, ZeroExtOut;
	wire [15:0] PCAddIn1, PCAddIn2, CalculatedPC;
	wire [15:0] RegOut1, RegOut2, JumpRegMuxOut;
	wire BranchFlag, DataZero, Flag, JumpOrBranchFlag;
	wire [2:0] RtReadAddr;

	//Sign extend immediate values
	assign SignExt5 = {{11{Instruct[4]}}, Instruct[4:0]};
	assign SignExt8 = {{8{Instruct[7]}}, Instruct[7:0]};
	assign SignExt11 = {{5{Instruct[10]}}, Instruct[10:0]};
	assign ZeroExtOut = (ZeroExtend8) ? {{8{1'b0}}, Instruct[7:0]} : {{12{1'b0}}, Instruct[3:0]};
	
	//Selects the appropriate sign extended value
	assign SignExt = (SignExtSel == 2'b00) ? SignExt5 : 
					 (SignExtSel == 2'b01) ? SignExt8 :
					 (SignExtSel == 2'b10) ? SignExt11 :
					 (SignExtSel == 2'b11) ? ZeroExtOut : 16'dz;

	wire [15:0] RegOut1Wire, RegOut2Wire;
	
	//Rt is in a different location in different instructions, depending on the instruction, determine the correct value of Rt
	assign RtReadAddr = (StoreImmed) ? Instruct[10:8] : Instruct[7:5];
	//Register Mem
	Reg_Mem Reg(.clk(clk), .rst(rst), .DataIn(DataIn), .AddrS(Instruct[10:8]),
	            .AddrT(RtReadAddr), .WrSel(WrRegAddr), .WrRegEn(WrEn), .Rs(RegOut1Wire), .Rt(RegOut2Wire));

	//Determines Data to be written into a register. Can be forwarded or from Write Back
	assign WriteDataIn = (WrEn & (WrRegAddr == RtReadAddr)) ? DataIn : RegOut2Wire;

	//Determines data coming from the registers. Can be forwarded data as well
	assign RegOut1 = (WrEn & (WrRegAddr == Instruct[10:8])) ? DataIn : RegOut1Wire;
	assign RegOut2 = (WrEn & (WrRegAddr == Instruct[7:5])) ? DataIn : RegOut2Wire; 
	
	//In the case of a JALR or JAL, writes the PC value into R7
	assign DataOut1RegIn = (LoadR7) ? NextPC : DataOut1Temp;
	
	//Register value to determine the next PC value in case of a JR or JALR
	assign JumpRegMuxOut = BranchOrJumpRegForwardRs ? DataOut1Temp : RegOut1;

	//Determines if the value of Rt is immediate or from Register 2
	assign DataOut2RegIn = (DataOut2Sel) ? SignExt : RegOut2;

	//Data forwarding
	assign DataOut1Temp = (BJForwardSel == 2'b00) ? ALUForward: 
					  (BJForwardSel == 2'b01) ? MemData2:
					  (BJForwardSel == 2'b10) ? WriteBackData:
					  RegOut1;
	//Logic to determine next PC
	assign PCAddIn1 = (NextPCSel) ? NextPC : JumpRegMuxOut;
	assign PCAddIn2 = (BranchImmedSel) ? SignExt11 : SignExt8;
	
	//Flag logic (flags used in Branches)
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

	DecodeReg DECODEREG(.clk(clk), .rst(rst), .Stall(Stall), .DataOut1In(DataOut1RegIn), .WriteDataIn(WriteDataIn),
						.DataOut2In(DataOut2RegIn), .DataOut1Out(DataOut1),	.DataOut2Out(DataOut2),
						.WriteDataOut(WriteData));


endmodule
