
module proc_wrapper(clk, rst);
	
	input clk, rst; 
	wire Read, Write, CS_RAM, CS_Audio, CS_Graphics, CS_Spart, CS_PS2;
	wire [15:0] Addr, WriteData, DataToCPU, DataBus, Instruct, NextPC;
	

	proc PROC(.clk(clk), .rst(rst), .WriteMem(Write), .ReadMem(Read), .ExternalAddr(Addr),
			  .ExternalWriteData(WriteData), .ExternalReadData(DataToCPU), .Instruct(Instruct), .NextPC(NextPC));

	External_Mem MEM(.Addr(Addr[15:12]), .WriteData(WriteData), .Read(Read), .Write(Write),
					 .DataToCPU(DataToCPU), .DataBus(DataBus), .CS_RAM(CS_RAM), 
					 .CS_Audio(CS_Audio), .CS_Graphics(CS_Graphics), .CS_Spart(CS_Spart),
					 .CS_PS2(CS_PS2));


  
endmodule
