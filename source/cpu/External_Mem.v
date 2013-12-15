module External_Mem(clk, rst, Addr, WriteData, Read, Write, DataToCPU, DataBus, CS_RAM, 
					CS_Audio, CS_Graphics, CS_Spart, CS_PS2, switch);
	input clk, rst, Read, Write, switch;
	input [3:0] Addr; 
	input [15:0] WriteData;
	output [15:0] DataToCPU;
	inout [15:0] DataBus;
	output CS_RAM, CS_Audio, CS_Graphics, CS_Spart, CS_PS2;
	reg Drive_DataBus;

	assign DataBus = Write ? WriteData : 16'dz;
	assign DataToCPU = DataBus;

	assign CS_RAM = (Read | Write) & Addr == 4'b0000;
	assign CS_Graphics = (Read | Write) & Addr == 4'b0001;
	assign CS_Audio = (Write) & Addr == 4'b0010;
	assign CS_Spart = (Read) & Addr == 4'b0011;
	assign CS_PS2 = (Read) & Addr == 4'b0100;
	assign CS_Switch = (Read) & Addr == 4'b0101;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			Drive_DataBus <= 1'b0;
		end
		else if (CS_Switch) begin
			Drive_DataBus <= 1'b1;
		end
		else begin
			Drive_DataBus <= 1'b0;
		end
	end

	assign DataBus = (Drive_DataBus) ? {{15{1'b0}}, switch} : 16'hzzzz;

endmodule
