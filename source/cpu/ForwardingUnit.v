module ForwardingUnit(i3, i4, i5, i6, );
	input [15:0] i3, i4, i5, i6;


	reg [2:0] dest
	//Forwarding 
	wire ForwardRsDecodeEnable, DecodeRsMatchExecuteRd, ForwardRsDecodeFromExecute;
	wire ForwardRtDecodeEnable, DecodeRtMatchExecuteRd, ForwardRtDecodeFromExecute;
	wire [2:0] ForwardingExcuteDestReg;

	wire DecodeRsMatchMemoryRd, ForwardRsDecodeFromMemory; 
	wire DecodeRtMatchMemoryRd, ForwardRtDecodeFromMemory;
	wire [2:0] ForwardingMemoryDestReg;

	//DECODE Forwarding wires

	//want to enable the possibility of forwarding in decode when Rs and Rt are being used.
	//For Rs: !(01100 and 01111 and 11000 and 11010 and 11100 and 11101)/
	//For Rt: 100
	assign ForwardRsDecodeEnable = (i2[15:11] != 5'b01100) | (i2[15:11] != 5'b01111) |
								   (i2[15:11] != 5'b11000) | (i2[15:11] != 5'b11010) |
								   (i2[15:12] != 5'b1110);
	assign ForwardRtDecodeEnable = i2[15] & !i2[14] & !i2[13];
	   //opcode 00000 - 01011 --> i3[7:5]
	   //opcode 00000 - 01011 --> i3[7:5]
	   //opcode 011xx --> i3[10:8]
	   //else --> i3[4:2]
	assign ForwardingExcuteDestReg = (!i3[15] & !(i3[14] & i3[13] )) ? i3[7:5] :
									 (!i3[15]) ? i3[10:8] : i3[4:2];
	assign DecodeRsMatchExecuteRd = (i2[10:8] == ForwardingExcuteDestReg) & !(i3[15:11] == 5'b11101);
	assign DecodeRtMatchExecuteRd = (i2[7:5] == ForwardingExcuteDestReg) & !(i3[15:11] == 5'b11101);

	assign ForwardingExcuteDestReg = (!i4[15] & !(i4[14] & i4[13] )) ? i4[7:5] :
									 (!i4[15]) ? i4[10:8] : i4[4:2];

	assign DecodeRsMatchMemoryRd = 
	assign DecodeRtMatchMemoryRd = 

	//Final Forwarding Signals
	assign ForwardRsDecodeFromExecute = ForwardRsDecodeEnable & DecodeRsMatchExecuteRd;
	assign ForwardRtDecodeFromExecute = ForwardRtDecodeEnable & DecodeRtMatchExecuteRd;



	assign ValidDest = !((i2[15:11] == 5'b01110) | (i2[15] & !i2[14] & i2[13]) | (i2[15:12] == 4'b1100) | 
					   (i2[15:12] == 4'b1110) | (i2[15:11] == 5'b11110));
	//NEED TO FIX!!!!!
	assign WrMuxSel[0] = !(!i2[15] | (&i2[15:11]));
	assign WrMuxSel[1] = (i2[15:13] == 3'b011) | (i2[15:12] == 4'b1101);

endmodule
