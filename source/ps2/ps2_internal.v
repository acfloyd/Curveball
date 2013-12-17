`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:40:08 12/14/2013 
// Design Name: 
// Module Name:    ps2_internal 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ps2_internal(clk, rst, cs, addr, DataBus, txd, MOUSE_CLOCK, MOUSE_DATA);

	input clk, rst, cs;
	input[1:0] addr;
	output txd;
	inout[15:0] DataBus;
	inout MOUSE_CLOCK, MOUSE_DATA;
	
	wire[15:0] ps2_mouse_data;
	wire[1:0] ps2_mouse_addr;
	wire[7:0] data_out;
	wire tbr;
	
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
	
	writer spart0( .clk(clk),
                 .rst(rst),
					  .write(write),
					  .tbr(tbr),
					  .data_in(data_out),
					  .txd(txd)
					);

	write_driver driver0( .clk(clk),
	                .rst(rst),
						 .dav(dav),
						 .data_in(ps2_mouse_data),
						 .addr(ps2_mouse_addr),
						 .tbr(tbr),
						 .data_out(data_out),
						 .write(write)
					 );

endmodule
