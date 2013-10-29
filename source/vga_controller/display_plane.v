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
	input fifo_empty,
	input fifo_full,
	output [12:0] rom_addr,
	output fifo_wr_en
    );
	
	// pixel multiply counters
	reg[2:0] h_cnt;
	reg[2:0] v_cnt;
	reg[6:0] h_addr;
	reg[12:0] v_addr;
	
	wire[2:0] next_h_cnt;
	wire[2:0] next_v_cnt;
	wire[6:0] next_h_addr;
	wire[12:0] next_v_addr;
	
	// state logic
	reg state;
	reg next_state;
	
	parameter FILL = 1'b1;
	parameter READ = 1'b0;
	
	// write enable is only on in FILL state
	assign fifo_wr_en = state;

	// update address and counters
	assign next_v_cnt = (state == FILL && h_addr == 7'd79 && h_cnt == 3'd7) ? v_cnt + 1 : v_cnt;
	assign next_h_cnt = (state == FILL) ? h_cnt + 1 : h_cnt;
	assign next_h_addr = (state == FILL && h_cnt == 3'd7) ? 
							((h_addr == 7'd79) ? 10'd0 : h_addr + 1) : h_addr;
	assign next_v_addr = (state == FILL && v_cnt == 3'd7 && h_addr == 7'd79 && h_cnt == 3'd7) ? 
								((v_addr > 13'd4719) ? 13'd0 : v_addr + 13'd80) : v_addr;
	assign rom_addr = h_addr + v_addr;
	
	// sequential logic
	always@(posedge clk) begin
		if(rst) begin
			h_cnt <= 3'd0;
			v_cnt <= 3'd0;
			h_addr <= 6'd0;
			v_addr <= 13'd0;
			state <= READ;

		end else begin
			h_cnt <= next_h_cnt;
			v_cnt <= next_v_cnt;
			h_addr <= next_h_addr;
			v_addr <= next_v_addr;
			state <= next_state;
		end
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
