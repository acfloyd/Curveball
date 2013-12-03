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
			  input up,
			  output blank,
			  output comp_sync,
			  output hsync,
			  output vsync,
			  output[7:0] pixel_r,
			  output[7:0] pixel_g,
			  output[7:0] pixel_b,
			  output vgaclk
    );
	
	wire graphics_chipselect;
	wire[15:0] graphics_databus;
	wire[3:0] graphics_data_address;
	wire graphics_VGA_ready;
    wire locked_dcm;
    wire clk_100mhz_buf;
	wire[23:0] graphics_color;
	wire[18:0] graphics_pixel_address;
	
	

    Graphics_ASIC graphics(.clk(clk_100mhz_buf),
					.rst(rst),
					.chipselect(graphics_chipselect),
					.databus(graphics_databus),
					.data_address(graphics_data_address),
					.VGA_ready(graphics_VGA_ready),
					.color(graphics_color),
					.pixel_address(graphics_pixel_address));
	
	
	vga_controller vga(.clk_100mhz_buf(clk_100mhz_buf),
							 .rst(rst),
							 .Wdata(graphics_color),
							 .vgaclk(vgaclk),
                             .locked_dcm(locked_dcm),
							 .state(graphics_VGA_ready),
							 .blank(blank),
							 .comp_sync(comp_sync),
							 .hsync(hsync),
							 .vsync(vsync),
							 .pixel_r(pixel_r),
							 .pixel_g(pixel_g),
							 .pixel_b(pixel_b));
							 
	vga_clk vga_clk_gen1(clk_100mhz, rst, vgaclk, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
endmodule
