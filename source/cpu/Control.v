module Control(clk, rst, Stall, DivStall, Instruct, NotBranchOrJump, WrRegEn, 
				WrRegAddr, SignExtSel, ZeroExtend8, NextPCSel, BranchImmedSel, LoadR7, 
				DataOut2Sel, ALUOp, AddMode, ShiftMode, SetFlagD, Branch, Jump,
				SetFlagE, AOp, ZeroB, FlagMux, WrMemEn, MemToReg, RsForwardSel, RtForwardSel,
				ForwardRs, ForwardRt);
//ForwardRsDecode, ForwardRtDecode
input clk, rst, DivStall;
input[15:0] Instruct;

output NotBranchOrJump, WrRegEn, ZeroExtend8, NextPCSel, BranchImmedSel, LoadR7, DataOut2Sel; 
output AddMode, ZeroB, FlagMux, WrMemEn, MemToReg, Stall, Branch, Jump;
output ForwardRs, ForwardRt;
output [1:0] SignExtSel, ShiftMode, SetFlagD, SetFlagE, AOp;
output [1:0] RsForwardSel, RtForwardSel;
output [2:0] WrRegAddr;
output reg[2:0] ALUOp;

wire MemLoadDetect;
wire [1:0] WrMuxSel;
reg StallReg;


//i6 is for timing of register writes
reg [15:0] i2, i3, i4, i5, i6;
parameter NOP = 16'b1110100000000000;

always @ (posedge clk, posedge rst) begin
	if(rst) begin
		i2 <= NOP;
		i3 <= NOP;
		i4 <= NOP;
		i5 <= NOP;
		i6 <= NOP;
	end
	else if (Stall) begin
		i2 <= i2;
		i3 <= i3;
		i4 <= i4;
		i5 <= i5;
		i6 <= i6;
	end
	else begin
		i2 <= Instruct;
		i3 <= i2;
		i4 <= i3;
		i5 <= i4;
		i6 <= i5;
	end
end

wire ValidDest;
wire [2:0] Dest;
reg ValidDest4, ValidDest5, ValidDest6;
reg [2:0] Dest4, Dest5, Dest6;
wire [1:0] ChooseDest;

always @ (posedge clk, posedge rst) begin
	if(rst) begin
		ValidDest4 <= 1'b0;
		ValidDest5 <= 1'b0;
		ValidDest6 <= 1'b0;
		Dest4 <= 3'h0;
		Dest5 <= 3'h0;
		Dest6 <= 3'h0;
	end
	else if (Stall) begin
		ValidDest4 <= ValidDest4;
		ValidDest5 <= ValidDest5;
		ValidDest6 <= ValidDest6;
		Dest4 <= Dest4;
		Dest5 <= Dest5;
		Dest6 <= Dest6;
	end
	else begin
		ValidDest4 <= ValidDest;
		ValidDest5 <= ValidDest4;
		ValidDest6 <= ValidDest5;
		Dest4 <= Dest;
		Dest5 <= Dest4;
		Dest6 <= Dest5;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		StallReg <= 1'b0;		
	end
	else if (MemLoadDetect) begin
		StallReg <= Stall;
	end
end
assign Stall = MemLoadDetect ^ StallReg;

assign NotBranchOrJump = !((i2[15] & !i2[14] & i2[13]) | (i2[15] & i2[14] & !i2[13]));
assign SignExtSel[0] = (i2[15:13] == 3'b011) | (i2[15:13] == 3'b101) | (i2[15] & i2[14] & !i2[13] & i2[11]) | 
						(i2[15:12] == 4'b1111);
assign SignExtSel[1] = (i2[15:12] == 4'b0111) | (i2[15] & i2[14] & !i2[13] & !i2[11]);
assign ZeroExtend8 = i2[15:12] == 4'b0111;
assign NextPCSel = !(i2[15] & i2[14] & !i2[13] & i2[11]);
assign BranchImmedSel = i2[15] & i2[14] & !i2[13] & !i2[11];
assign LoadR7 = i2[15:12] == 4'b1101;
assign DataOut2Sel = !(i2[15:13] == 4'b100);
assign SetFlagD = i2[12:11];
assign Branch = i2[15:13] == 3'b101;
assign Jump = i2[15:13] == 3'b110;
assign AddMode = !((i3[15:11] == 5'b00001) | (i3[15:11] == 5'b10000 & i3[1:0] == 2'b01) |
				 (i3[15:11] == 5'b10011 & !(i3[1:0] == 2'b11)) );
assign ShiftMode = (i3[15:13] == 3'b010) ? i3[12:11] : i3[1:0];
assign SetFlagE = i3[1:0];
assign AOp[0] = ((i3[15:11] == 5'b01100) | (i3[15:12] == 4'b0111) | (i3[15:11] == 5'b10001 & i3[1:0] == 2'b11));
assign AOp[1] = i3[15:13] == 3'b011;
assign ZeroB = (i3[15:13] == 3'b101) | (i3[15:13] == 4'b1101);
assign FlagMux = i3[15:11] == 5'b10011;
assign WrMemEn = i4[14:11] == 4'b1110;
assign MemLoadDetect = i4[14] & i4[13] & i4[12] & i4[11];
assign MemToReg = i5[14:11] == 4'b1111;
assign WrRegEn = !((i6[15:11] == 5'b01110) | (i6[15] & !i6[14] & i6[13]) | (i6[15:12] == 4'b1100) | 
				   (i6[15:12] == 4'b1110) | (i6[15:11] == 5'b11110));

assign WrMuxSel[0] = !(!i6[15] | (&i6[15:11]));
assign WrMuxSel[1] = (i6[15:13] == 3'b011) | (i6[15:12] == 4'b1101);

assign WrRegAddr = (WrMuxSel == 2'b00) ? i6[7:5] : 
					  (WrMuxSel == 2'b01) ? i6[4:2] :
					  (WrMuxSel == 2'b10) ? i6[10:8] :
					  (WrMuxSel == 2'b11) ? 3'd7 : 3'bzzz;


assign ValidDest = !((i3[15:11] == 5'b01110) | (i3[15] & !i3[14] & i3[13]) | (i3[15:12] == 4'b1100) | 
					   (i3[15:12] == 4'b1110) | (i3[15:11] == 5'b11110));
//NEED TO FIX!!!!!
assign ChooseDest[0] = !(!i3[15] | (&i3[15:11]));
assign ChooseDest[1] = (i3[15:13] == 3'b011) | (i3[15:12] == 4'b1101);

assign Dest = (ChooseDest == 2'b00) ? i3[7:5] : 
					  (ChooseDest == 2'b01) ? i3[4:2] :
					  (ChooseDest == 2'b10) ? i3[10:8] :
					  3'd7;

assign RsForwardEnable = (i3[15:11] != 5'b01100) & (i3[15:11] != 5'b01111) &
						 (i3[15:11] != 5'b11000) & (i3[15:11] != 5'b11010) &
						 (i3[15:12] != 4'b1110);
assign RtForwardEnable = i3[15] & !i3[14] & !i3[13];

assign ForwardRs = RsForwardEnable & ((ValidDest4 & (i3[10:8] == Dest4)) | 
									  (ValidDest5 & (i3[10:8] == Dest5)) |
									  (ValidDest6 & (i3[10:8] == Dest6)));
assign ForwardRt = RtForwardEnable & ((ValidDest4 & (i3[7:5] == Dest4)) | 
									  (ValidDest5 & (i3[7:5] == Dest5)) |
									  (ValidDest6 & (i3[7:5] == Dest6)));

assign RsForwardSel = (ValidDest4 & (i3[10:8] == Dest4) & (&i4[14:11]) ) ? 2'b01:
					  (ValidDest4 & (i3[10:8] == Dest4)) ? 2'b00 :
					  (ValidDest5 & (i3[10:8] == Dest5)) ? 2'b10 :
					  (ValidDest6 & (i3[10:8] == Dest6)) ? 2'b11 : 2'b00;
assign RtForwardSel = (ValidDest4 & (i3[7:5] == Dest4) & (&i4[14:11])) ? 2'b01:
					  (ValidDest4 & (i3[7:5] == Dest4)) ? 2'b00 :
					  (ValidDest5 & (i3[7:5] == Dest5)) ? 2'b10 :
					  (ValidDest6 & (i3[7:5] == Dest6)) ? 2'b11 : 2'b00;
always @ (i3) begin
   casez({i3[15:11], i3[1:0]})
	   7'b00010zz: ALUOp = 3'b010;
	   7'b00011zz: ALUOp = 3'b011;
	   7'b00100zz: ALUOp = 3'b100;
	   7'b00101zz: ALUOp = 3'b101;
	   7'b00110zz: ALUOp = 3'b110;
	   7'b010zzzz: ALUOp = 3'b001;
	   7'b01101zz: ALUOp = 3'b101;
	   7'b1000010: ALUOp = 3'b010;
	   7'b1000011: ALUOp = 3'b011;
	   7'b1000100: ALUOp = 3'b100;
	   7'b1000101: ALUOp = 3'b101;
	   7'b1000110: ALUOp = 3'b110;
	   7'b1000111: ALUOp = 3'b111;
	   7'b10010zz: ALUOp = 3'b001;
	   default: ALUOp = 3'b000;
   endcase
end

endmodule
