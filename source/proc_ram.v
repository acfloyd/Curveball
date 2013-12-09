module proc_ram(clk, rst, DataBus, Addr, CS_RAM, Read);
	input clk, rst, CS_RAM, Read;
	input [7:0] Addr;
	inout [15:0] DataBus;
	
	reg Drive_DataBus;
	wire [15:0] DataOut;

	proc_mem PROCMEM(.clka(clk), 
					 .dina(DataBus),
					 .addra(Addr),
					 .wea(CS_RAM & ~Read),
					 .douta(DataOut));

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			Drive_DataBus <= 1'b0;
		end
		else if (CS_RAM & Read) begin
			Drive_DataBus <= 1'b1;
		end
		else begin
			Drive_DataBus <= 1'b0;
		end
	end

	assign DataBus = (Drive_DataBus) ? DataOut : 16'hzzzz;

	
	
endmodule