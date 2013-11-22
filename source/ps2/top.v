`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:52:55 11/07/2013 
// Design Name: 
// Module Name:    top 
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
module top(input clk_100mhz,
			  input rst,
			  output blank,
			  output comp_sync,
			  output hsync,
			  output vsync,
			  output[7:0] pixel_r,
			  output[7:0] pixel_g,
			  output[7:0] pixel_b,
			  output vgaclk,
			  output LED_0, 
			  output LED_1, 
			  output LED_2, 
			  output LED_3,
			  output txd,
			  inout MOUSE_DATA,
			  inout MOUSE_CLOCK
    );
	
	wire graphics_chipselect;
	wire[15:0] graphics_databus;
	wire[3:0] graphics_data_address;
	wire graphics_VGA_ready;
   wire locked_dcm;
   wire clk_100mhz_buf;
	wire[2:0] graphics_color;
	wire[18:0] graphics_pixel_address;
	
	wire [8:0] ps2_mouse_data;
	wire [1:0] ps2_mouse_addr, val_count;
	wire TCP, t_clk, t_data, r_ack, r_ack_bit, dav, r_dav;
	wire [1:0] status_bits;
	wire [23:0] data_out;
	wire [7:0] databus, byte_rec;
	wire [1:0] ioaddr;
	
	assign LED_0 = ~r_ack;
	assign LED_1 = ~r_ack_bit;
	assign LED_2 = ~status_bits[0]; 
	assign LED_3 = ~status_bits[1];
	
	/*mouse_display display(.wr_addr(graphics_pixel_address),
							  .wr_data(graphics_color),
							  .status_bits(status_bits),
							  .addr(ps2_mouse_addr),
							  .data(ps2_mouse_data),
							  .dav(dav),
							  .clk(clk_100mhz_buf),
							  .rst(rst),
							  .VGA_ready(graphics_VGA_ready));*/
							  
   ps2_mouse mouse(.data(ps2_mouse_data),
						.done(done),
						.TCP(TCP),
						.t_clk(t_clk),
						.t_data(t_data),
						.r_ack_bit(r_ack_bit),
						.r_ack(r_ack),
						.dav(dav),
						.MOUSE_CLOCK(MOUSE_CLOCK),
						.MOUSE_DATA(MOUSE_DATA),
						.addr(ps2_mouse_addr),
						.clk(clk_100mhz_buf),
						.rst(rst),
						.io_cs(graphics_chipselect));
						
	spart spart0( .clk(clk_100mhz_buf),
                 .rst(rst),
					  .iocs(iocs),
					  .iorw(iorw),
					  .rda(rda),
					  .tbr(tbr),
					  .ioaddr(ioaddr),
					  .databus(databus),
					  .txd(txd),
					  .rxd(rxd)
					);

	driver driver0( .clk(clk_100mhz_buf),
	                .rst(rst),
						 .dav(dav),
						 .data_in(ps2_mouse_data[7:0]),
						 .addr(ps2_mouse_addr),
						 .status_bits(status_bits),
						 .br_cfg(2'b11),
						 .iocs(iocs),
						 .iorw(iorw),
						 .rda(rda),
						 .tbr(tbr),
						 .ioaddr(ioaddr),
						 .databus(databus)
					 );
					 
	
	vga_controller vga(.clk_100mhz_buf(clk_100mhz_buf),
							 .rst(rst),
							 .Waddr(graphics_pixel_address),
							 .Wdata(graphics_color),
							 .vgaclk(vgaclk),
                             .locked_dcm(locked_dcm),
							 .ready(graphics_VGA_ready),
							 .blank(blank),
							 .comp_sync(comp_sync),
							 .hsync(hsync),
							 .vsync(vsync),
							 .pixel_r(pixel_r),
							 .pixel_g(pixel_g),
							 .pixel_b(pixel_b));
							 
	vga_clk vga_clk_gen1(clk_100mhz, rst, vgaclk, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
endmodule
