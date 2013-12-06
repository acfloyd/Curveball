module External_Mem(Addr, WriteData, Read, Write, DataToCPU, DataBus, CS_RAM, 
					CS_Audio, CS_Graphics, CS_Spart, CS_PS2);
	input Read, Write;
	input [3:0] Addr; 
	input [15:0] WriteData;
	output [15:0] DataToCPU;
	inout [15:0] DataBus;
	output CS_RAM, CS_Audio, CS_Graphics, CS_Spart, CS_PS2;

	assign DataBus = Write ? WriteData : 16'dz;
	assign DataToCPU = DataBus;

	assign CS_RAM = (Read | Write) & Addr == 4'b0000;
	assign CS_Graphics = (Read | Write) & Addr == 4'b0001;
	assign CS_Audio = (Read | Write) & Addr == 4'b0010;
	assign CS_Spart = (Read | Write) & Addr == 4'b0011;
	assign CS_PS2 = (Read) & Addr == 4'b0100;

endmodule
