module External_Mem(Addr, WriteData, Read, Write, DataToCPU, DataBus, CS_RAM, 
					CS_Audio, CS_Graphics, CS_Spart, CS_PS2);
	input Read, Write;
	input [2:0] Addr; 
	input [15:0] WriteData;
	output [15:0] DataToCPU;
	inout [15:0] DataBus;
	output CS_RAM, CS_Audio, CS_Graphics, CS_Spart, CS_PS2;

	assign DataBus = Write ? WriteData : 16'dz;
	assign DataToCPU = DataBus;

	assign CS_RAM = (Read | Write) & Addr == 3'b000;
	assign CS_Graphics = (Write) & Addr == 3'b001;
	assign CS_Audio = (Read | Write) & Addr == 3'b010;
	assign CS_Spart = (Read | Write) & Addr == 3'b011;
	assign CS_PS2 = (Read) & Addr == 3'b100;

endmodule
