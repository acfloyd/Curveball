`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:59:41 09/17/2013 
// Design Name: 
// Module Name:    top_level 
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
module top_level(
	input clk_100mhz,
	input rst,
	output vgaclk,
	output blank,
	output comp_sync,
	output hsync,
	output vsync,
	output[7:0] pixel_r,
	output[7:0] pixel_g,
	output[7:0] pixel_b
    );

	// vga_clk wires
	wire clkin_ibufg_out;
	wire clk_100mhz_buf;
	wire locked_dcm;
	
	// fifo wires
	wire[23:0] fifo_dout;
	wire rd_en, wr_en, empty, full; 
	
	// rom wires
	wire[23:0] out_pixel;
	wire[23:0] rom_dout;
	wire[12:0] rom_addr;
	
	// global reset
	wire g_rst;
	
	assign {pixel_r, pixel_g, pixel_b} = fifo_dout; // RGB directly connected to FIFO
	assign g_rst = rst | ~locked_dcm; // only exit reset once 25 mhz clock is locked
	
	// modules
	vga_clk vga_clk_gen1(clk_100mhz, rst, vgaclk, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
	
	vga_logic vgal(vgaclk, g_rst, empty, blank, comp_sync, hsync, vsync);
	
	xclk_fifo fifo(rom_dout, vgaclk, blank, g_rst, clk_100mhz_buf, wr_en, fifo_dout, empty, full);
	
	checker_rom rom(clk_100mhz_buf, rom_addr, rom_dout);
	
	display_plane disp(clk_100mhz_buf, g_rst, empty, full, rom_addr, wr_en);

endmodule
