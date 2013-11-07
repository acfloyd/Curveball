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
// TODO: need to rewrite outputs 
module vga_controller(
	input clk_100mhz_buf,
	input rst,
    input[18:0] Waddr,
    input[2:0] Wdata,
    output ready,
	input vgaclk,
	output blank,
	output comp_sync,
	output hsync,
	output vsync,
	output[7:0] pixel_r,
	output[7:0] pixel_g,
	output[7:0] pixel_b
    );

    // color decode
    localparam[23:0] BLACK = 24'h000000;
    localparam[23:0] GREEN = 24'h00FF00;
    localparam[23:0] BLUE = 24'h0000FF;
    localparam[23:0] RED = 24'hFF0000;
    localparam[23:0] TEAL = 24'h66FFFF;
    localparam[23:0] GRAY = 24'hD3D3D3;
    localparam[23:0] WHITE = 24'hFFFFFF;
    localparam[23:0] GWHITE = 24'hCCFF99;

	// vga_clk wires
	wire clkin_ibufg_out;
	//wire clk_100mhz_buf;
	wire locked_dcm;
	
	// fifo wires
	wire[23:0] fifo_dout;
	wire wr_en, empty, full; 
	
	// ram wires
	wire[2:0] ram_dout;
	wire[19:0] ram_Raddr;
	wire[19:0] ram_Waddr;
   reg[23:0] color_val;

	// global reset
	wire g_rst;

    // color value decode
    always @(*) begin
        case(ram_dout)
            3'd0: color_val = BLACK;
            3'd1: color_val = GREEN;
            3'd2: color_val = BLUE;
            3'd3: color_val = RED;
            3'd4: color_val = TEAL;
            3'd5: color_val = GRAY;
            3'd6: color_val = WHITE;
            3'd7: color_val = GWHITE;
        endcase
    end
	
	assign {pixel_r, pixel_g, pixel_b} = fifo_dout; // RGB directly connected to FIFO
	assign g_rst = rst | ~locked_dcm; // only exit reset once 25 mhz clock is locked
	
	// modules:
	//vga_clk vga_clk_gen1(clk_100mhz, rst, vgaclk, clkin_ibufg_out, clk_100mhz_buf, locked_dcm);
	
	vga_logic vgal(vgaclk, g_rst, empty, blank, comp_sync, hsync, vsync);
	
	xclk_fifo fifo(color_val, vgaclk, blank, g_rst, clk_100mhz_buf, wr_en, fifo_dout, empty, full);
	
    frame_buf fBuf(clk_100mhz_buf, Wdata, ram_Waddr, ready, clk_100mhz_buf, ram_Raddr, ram_dout);
	
	display_plane disp(clk_100mhz_buf, g_rst, full, Waddr, ram_Raddr, ram_Waddr, wr_en, ready);

endmodule
