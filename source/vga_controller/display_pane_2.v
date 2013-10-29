`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:04:53 02/08/2012 
// Design Name: 
// Module Name:    display_pane_2 
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
module display_pane_2(input clk, rst, fifo_full, input[23:0] in_pixel, 
	output reg fifo_wr, output reg [12:0] addr, output[23:0] out_pixel 
   );
	
	parameter READ = 1'b0;
	parameter WRITE = 1'b1;
	
	reg state, next_state;	
	
	reg[12:0] vertical_start_addr;
	wire[12:0] next_vertical_start_addr, next_addr;
	
	wire[2:0] next_h_stretch, next_v_stretch;
	wire[7:0] next_h_count;
	wire[6:0] next_v_count;
	
	reg[2:0] h_stretch, v_stretch;
	reg[7:0] h_count;
	reg[6:0] v_count;
	
	reg inc_h_count, inc_h_stretch, inc_v_count, inc_v_stretch;
	reg inc_addr, inc_vertical_start_addr, load_vertical_addr;
	
	assign out_pixel = in_pixel;
	
	// h_stretch, v_stretch are mod8 counters to count the number of duplicated pixels.
	// h_count, v_count are counters to count the number of actual pixel that have been printed.
	// 0-79 and 0-59 respectively.
	// Vertical start address keeps the first address of the line that we are replicating, counting up by 80.
	assign next_h_stretch = inc_h_stretch ? (h_stretch == 3'd7 ? 3'd0 : h_stretch + 1) : h_stretch;
	assign next_v_stretch = inc_v_stretch ? (v_stretch == 3'd7 ? 3'd0 : v_stretch + 1) : v_stretch;
	assign next_h_count = inc_h_count ? (h_count == 8'd79 ? 8'd0 : h_count + 1) : h_count;
	assign next_v_count = inc_v_count ? (v_count == 7'd59 ? 8'd0 : v_count + 1) : v_count;
	assign next_vertical_start_addr = inc_vertical_start_addr ? 
												(vertical_start_addr == 13'd4720 ? 13'd0 : vertical_start_addr + 13'd80)
												: vertical_start_addr;
												
	assign next_addr = load_vertical_addr ? vertical_start_addr :
								(inc_addr ? (addr == 13'd4799 ? 13'd0 : addr + 1) : addr);
	
	
	
	always@(posedge clk) begin
		
		if(rst) begin
			addr <= 13'b0;
			state <= READ;
			h_count <= 8'b0;
			v_count <= 7'b0;
			h_stretch <= 3'b0;
			v_stretch <= 3'b0;
			vertical_start_addr <= 13'b0;
		end else begin
			addr <= next_addr;
			state <= next_state;
			h_count <= next_h_count;
			v_count <= next_v_count;
			h_stretch <= next_h_stretch;
			v_stretch <= next_v_stretch;
			vertical_start_addr <= next_vertical_start_addr;
		end
		
	end
	
	always@(*) begin
		
		// Default to not change any counters.
		inc_v_count = 1'b0;
		inc_v_stretch = 1'b0;
		inc_h_count = 1'b0;
		inc_h_stretch = 1'b0;
		inc_addr = 1'b0;
		inc_vertical_start_addr = 1'b0;
		load_vertical_addr = 1'b0;
  
		case(state)
		READ: begin
			fifo_wr = 1'b0;
			// If fifo is full, do nothing.
			if(fifo_full) 
			begin
				next_state = READ;
			end else 
			begin
				next_state = WRITE;
				
				//handling the replications
				inc_h_stretch = 1'b1; //at this point we will always be displaying a pixel, so increment the h_stretch by 1 to reflect this
								
				if((v_stretch == 3'b111) && (h_count == 8'd79) && (h_stretch == 3'b111))  //check to see if we are at the end of a line and vertical stretch portion
				begin
					// Completely finished with duplicating a row.  Increment all counters.
					inc_v_stretch = 1'b1;
					inc_v_count = 1'b1;
					inc_h_count = 1'b1;
					inc_addr = 1'b1;
					inc_vertical_start_addr = 1'b1; 
				end else if((h_count == 8'd79) && (h_stretch == 3'b111)) //check to see if we are at the end of a line
				begin
					// Continue to duplicate one row.  Increment v_stretch and h_count, and reset addr to the vertical start address.
					inc_v_stretch = 1'b1;
					load_vertical_addr = 1'b1;
					inc_h_count = 1'b1;
				end else if(h_stretch == 3'b111) //check to see if we have replicated bit 8 times horizontally
				begin
					// Finished duplicating one pixel, increment the horizontal count and the address.
					inc_h_count = 1'b1;
					inc_addr = 1'b1;
				end 
			end
	   end
	   WRITE: begin
			// Write data from the ROM to the FIFO.
			fifo_wr = 1'b1;
			next_state = READ;
	   end	
	   
		endcase
	end





endmodule

