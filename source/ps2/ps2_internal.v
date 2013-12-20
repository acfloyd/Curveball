//module that wraps the functionality of the ps2_mouse, as well as the write and write_driver modules
module ps2_internal(
	input clk, rst, cs,				//clk, rst, and chip select signals
	input[1:0] addr,				//input address
	output txd,					//serial data out
	inout[15:0] DataBus,				//input/output databus
	inout MOUSE_CLOCK, MOUSE_DATA,			//input/output MOUSE_CLOCK and MOUSE_DATA
);			
	
	wire[15:0] ps2_mouse_data,			//data read from ps2_mouse
	wire[1:0] ps2_mouse_addr,			//address to read from ps2_mouse
	wire[7:0] data_out,				//data to be transmit out
	wire tbr					//transmit buffer ready				
	
	//instantiate ps2_mouse
	ps2_mouse mouse(.r_ack(ack),
			.databus(DataBus),
			.dav(dav),
			.spartdata(ps2_mouse_data),
			.spartaddr(ps2_mouse_addr),
			.MOUSE_CLOCK(MOUSE_CLOCK), 
			.MOUSE_DATA(MOUSE_DATA), 
			.addr(addr[1:0]), 
			.clk(clk), 
			.rst(rst), 
			.io_cs(cs));
	
	//instantiate serial writer
	writer spart0(.clk(clk),
                      .rst(rst),
		      .write(write),
		      .tbr(tbr),
		      .data_in(data_out),
		      .txd(txd));
		      
	//instantiate write_driver
	write_driver driver0(.clk(clk),
	                     .rst(rst),
			     .dav(dav),
			     .data_in(ps2_mouse_data),
			     .addr(ps2_mouse_addr),
			     .tbr(tbr),
			     .data_out(data_out),
			     .write(write));

endmodule
