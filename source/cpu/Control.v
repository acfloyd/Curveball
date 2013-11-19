module Control(clk, rst, Stall, DivStall, Instruct, NotBranchOrJump, WrRegEn, 
				WrMuxSel, SignExtSel, ZeroExtend8, NextPCSel, BranchImmedSel, LoadR7, 
				DataOut2Sel, ALUOp, AddMode, ShiftMode, SetFlagD, Branch, Jump,
				SetFlagE, AOp, ZeroB, FlagMux, WrMemEn, MemToReg, ForwardRsDecode, 
				ForwardRtDecode);

input clk, rst, DivStall;
input[15:0] Instruct;

output NotBranchOrJump, WrRegEn, ZeroExtend8, NextPCSel, BranchImmedSel, LoadR7, DataOut2Sel; 
output AddMode, ZeroB, FlagMux, WrMemEn, MemToReg, Stall, Branch, Jump;
output ForwardRsDecode, ForwardRtDecode;
output[1:0] WrMuxSel, SignExtSel, ShiftMode, SetFlagD, SetFlagE, AOp;
output reg[2:0] ALUOp;

wire MemLoadDetect;
reg StallReg;

//Forwarding 
wire ForwardRsDecodeEn;

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
assign ZeroB = ((i3[15:11] == 5'b01100) | (i3[15:13] == 3'b101) | (i3[15:13] == 4'b1101));
assign FlagMux = i3[15:11] == 5'b10011;
assign WrMemEn = i4[14:11] == 4'b1110;
assign MemLoadDetect = i4[14] & i4[13] & i4[12] & i4[11];
assign MemToReg = i5[14:11] == 4'b1111;
assign WrRegEn = !((i6[15:11] == 5'b01110) | (i6[15] & !i6[14] & i6[13]) | (i6[15:12] == 4'b1100) | 
				   (i6[15:12] == 4'b1110) | (i6[15:11] == 5'b11110));
//NEED TO FIX!!!!!
assign WrMuxSel[0] = !(!i6[15] | (&i6[15:11]));
assign WrMuxSel[1] = (i6[15:13] == 3'b011) | (i6[15:12] == 4'b1101) | (&i6[15:11]);

assign ForwardRsDecodeEnableFromExecute = (!i3[15] & !(i3[14:11] == 4'b1110)) | (i3[15] & !i3[14] & !i3[13]);
//opcode 00000 - 01011, 01101
assign DecodeRsMatchExecuteRd = i2[10:8] == ( (!i3[15] & !(i3[14] & i3[13] & ( i3[12] | (!i3[12] & !i3[11])  ))) ? i3[7:5] :
											   (!i3[15] & i3[14] & i3[13]) ? i3[10:8] :
											   i3[4:2]);
assign ForwardRsDecode = ForwardRsDecodeEnableFromExecute & DecodeRsMatchExecuteRd;


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
