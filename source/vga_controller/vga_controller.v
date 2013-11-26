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
    input[2:0] Wdata,
	input vgaclk,
    input locked_dcm,
    output reg state,
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

	localparam FILL = 1'b1;
	localparam READ = 1'b0;

	reg next_state;

	// vga_clk wires
	wire clkin_ibufg_out;
	
	// fifo wires
	wire[23:0] fifo_dout;
	wire wr_en, empty, full; 
	
	// ram wires
    reg[23:0] color_val;

	// global reset
	wire g_rst;

    // color value decode
    always @(*) begin
        case(Wdata)
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

	// state transition logic
	always@(*) begin
		case(state)	
			READ: if(full) 
						next_state = READ;					
					else 
						next_state = FILL;
						
			FILL: next_state = READ;

			endcase
	end
	
	always@(posedge clk_100mhz_buf) begin
		if(rst) 
			state <= READ;
		else 
			state <= next_state;
	end

	assign wr_en = state;

	assign {pixel_r, pixel_g, pixel_b} = fifo_dout; // RGB directly connected to FIFO
	assign g_rst = rst | ~locked_dcm; // only exit reset once 25 mhz clock is locked
	
	// modules
    // TODO: use . connections
	vga_logic vgal(vgaclk, g_rst, empty, blank, comp_sync, hsync, vsync);
	
	xclk_fifo fifo(color_val, vgaclk, blank, g_rst, clk_100mhz_buf, wr_en, fifo_dout, empty, full);

endmodule
