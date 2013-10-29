`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:19:53 09/17/2013 
// Design Name: 
// Module Name:    vga_timing_gen 
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
module vga_timing_gen(
	input clk,
	input rst,
	output blank,
	output comp_sync,
	output hsync,
	output vsync
    );

	reg[9:0] h_cnt;
	reg[9:0] v_cnt;
	
	wire[9:0] next_h_cnt;
	wire[9:0] next_v_cnt;
	assign next_h_cnt = (h_cnt == 10'd799) ? 10'b0 : h_cnt + 1;
	assign next_v_cnt = (h_cnt == 10'd799) ? ((v_cnt == 10'd524) ? 10'b0 : v_cnt + 1) : v_cnt;
	
	always@(posedge clk, posedge rst)
		if(rst) begin 
			h_cnt <= 10'b0;
			v_cnt <= 10'b0;
		end else begin
			h_cnt <= next_h_cnt;
			v_cnt <= next_v_cnt;
		end
		
	assign hsync = (h_cnt < 10'd13 || h_cnt >= 10'd109);
	assign vsync = (v_cnt < 10'd11 || v_cnt >= 10'd13);
	assign blank = ~(v_cnt < 10'd45 || h_cnt < 10'd154);
	assign comp_sync = 1'b0;

endmodule
