`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:19:33 09/17/2013 
// Design Name: 
// Module Name:    display_plane 
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
module display_plane(
	input clk,
	input rst,
	input fifo_full,
	output fifo_wr_en
    );
	
	reg state;
	reg next_state;

	parameter FILL = 1'b1;
	parameter READ = 1'b0;
	
	assign fifo_wr_en = state;

	always@(posedge clk) begin
		if(rst) 
			state <= READ;
		else 
			state <= next_state;
	end
		
		
	// state transition logic
	always@(*) begin
		case(state)	
			READ: if(fifo_full) 
						next_state = READ;					
					else 
						next_state = FILL;
						
			FILL: next_state = READ;

			endcase
	end
endmodule

