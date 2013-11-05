module Control(clk, rst, Halt, Stall, Flush, DivStall, Instruct, NotBranchOrJump, WrRegEn, 
				WrMuxSel, SignExtSel, ZeroExtend8, NextPCSel, BranchImmSel, LoadR7, 
				DataOut2Sel, ALUOp, AddMode, ShiftMode, SetFlagD, SetFlagE, AOp, 
				ZeroB, FlagMux, WrMemEn, MemToReg);

input clk, rst, DivStall;
input[15:0] Instruct;

output NotBranchOrJump, WrRegEn, ZeroExtend8, NextPCSel, BranchImmSel, LoadR7, DataOut2Sel; 
output AddMode, ZeroB, FlagMux, WrMemEn, MemToReg, Halt, Stall, Flush;
output[1:0] WrMuxSel, SignExtSel, ShiftMode, SetFlagD, SetFlagE, AOp;
output reg[2:0] ALUOp;

reg [15:0] i1, i2, i3, i4, i5;
parameter NOP = 16'b1110100000000000;
assign Halt = i1[15] & i1[14] & i1[13] & ~i1[12] & ~i1[11];

always @ (posedge clk, posedge rst) begin
	if(rst) begin
		i1 <= NOP;
		i2 <= NOP;
		i3 <= NOP;
		i4 <= NOP;
		i5 <= NOP;
	end
	else if (halt) begin
		i1 <= i1;
		i2 <= i2;
		i3 <= i3;
		i4 <= i4;
		i5 <= i5;
	end
	else begin
		i1 <= Instruct;
		i2 <= i1;
		i3 <= i2;
		i4 <= i3;
		i5 <= i4;
	end
end

assign Flush = ~NotBranchOrJump;
assign NotBranchOrJump = !((i2[15] & !i2[14] & i2[13]) | (i2[15] & i2[14] & !i2[13]));
assign WrRegEn = !((i2[15:11] == 5'b01110) | (i2[15] & !i2[14] & i2[13]) | (i2[15:12] == 4'b1100) | 
				   (i2[15:12] == 4'b1110) | (i2[15:11] == 5'b11110));
assign WrMuxSel[0] = !(!i2[15] | (&i2[15:11]));
assign WrMuxSel[1] = (i2[15:13] == 3'b011) | (i2[15:12] == 4'b1101) | (&i2[15:11]);
assign SignExtSel[0] = (i2[15:13] == 3'b011) | (i2[15:13] == 3'b101) | (i2[15] & i2[14] & !i2[13] & i2[11]) | 
						(i2[15:12] == 4'b1111);
assign SignExtSel[1] = (i2[15:12] == 4'b0111) | (i2[15] & i2[14] & !i2[13] & !i2[11]);
assign ZeroExtend8 = i2[15:12] == 4'b0111;
assign NextPCSel = !(i2[15] & i2[14] & !i2[13] & i2[11]);
assign BranchImmSel = !(i2[15] & i2[14] & !i2[13] & !i2[11]);
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
assign MemToReg = i5[14:11] == 4'b1111;


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
