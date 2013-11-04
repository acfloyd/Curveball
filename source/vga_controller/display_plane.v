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
    input [17:0] Waddr,
	output [18:0] ram_Raddr,
	output reg[18:0] ram_Waddr,
	output fifo_wr_en,
    output ready
    );
	
    // TODO : old code
    /*
	// pixel multiply counters
	reg[2:0] h_cnt;
	reg[2:0] v_cnt;
    */

    /*
	wire[2:0] next_h_cnt;
	wire[2:0] next_v_cnt;
    */

	// update address and counters
    /*
	assign next_v_cnt = (state == FILL && h_addr == 7'd79 && h_cnt == 3'd7) ? v_cnt + 1 : v_cnt;
	assign next_h_cnt = (state == FILL) ? h_cnt + 1 : h_cnt;
	assign next_h_addr = (state == FILL && h_cnt == 3'd7) ? 
							((h_addr == 7'd79) ? 10'd0 : h_addr + 1) : h_addr;
	assign next_v_addr = (state == FILL && v_cnt == 3'd7 && h_addr == 7'd79 && h_cnt == 3'd7) ? 
								((v_addr > 13'd4719) ? 13'd0 : v_addr + 13'd80) : v_addr;
	assign rom_addr = h_addr + v_addr;
    */

    /*
	assign next_h_addr = (state == FILL) ? ((h_addr == 10'd639) ? 10'd0 : h_addr + 1) : h_addr;
	assign next_v_addr = (state == FILL && h_addr == 10'd639) ? 
                            ((v_addr > 19'd3065659) ? 19'd0 : v_addr + 19'd640) : v_addr;
    */

    // pixel counters
	reg[9:0] h_addr;
	reg[17:0] v_addr;
	reg[9:0] next_h_addr;
	reg[17:0] next_v_addr;
	
	// state logic
	reg state;
	reg next_state;

    // keeps track of frames available to be written to
    reg[1:0] deadFrame;
    reg currFrame;
	
	parameter FILL = 1'b1;
	parameter READ = 1'b0;

	// write enable is only on in FILL state
	assign fifo_wr_en = state;

    // we are ready to accept frames as long as we have a single dead frame
    assign ready = |deadFrame;

    always @( * ) begin
        // dead frame logic
        if (rst) begin
            deadFrame = 2'b11;
            currFrame = 1'b0;
        end
        else if (state == FILL && h_addr == 10'd639 && v_addr > 18'd306560) begin
            deadFrame[currFrame] = 1'b1;
            currFrame = ~currFrame;
        end
        else begin
            deadFrame = deadFrame;
            currFrame = currFrame;
        end

        // combo logic for outputing the correct writting frame address
        if (deadFrame[currFrame] == 1'b1) 
            ram_Waddr = (currFrame) ? (Waddr + 19'd307200) : Waddr;
        else
            ram_Waddr = (~currFrame) ? (Waddr + 19'd307200) : Waddr;

        // if there are no frames ready to be displayed keep the addrs at 0,0
        if (deadFrame[currFrame] == 1'b1) begin
            next_h_addr = 10'd0;
            next_v_addr = 18'd0;
        end
        else begin
            // next addr logic
            if (state == FILL) begin
                if (h_addr == 10'd639) begin
                    next_h_addr = 10'd0;

                    if (v_addr > 18'd306560)
                        next_v_addr = 18'd0;
                    else 
                        next_v_addr = v_addr + 18'd640;
                end
                else begin
                    next_h_addr = h_addr + 1;
                    next_v_addr = v_addr;
                end

            end
            else begin
                next_h_addr = h_addr;
                next_v_addr = v_addr;
            end
        end

        // when done writing a frame to ram, set that frame as ready to be displayed
        if (ram_Waddr > 18'd307198) begin
            if (deadFrame[currFrame] == 1'b1)
                deadFrame[currFrame] = 1'b0;
            else
                deadFrame[~currFrame] = 1'b0;
        end

    end

    assign ram_Raddr = (currFrame) ? (h_addr + v_addr + 19'd306560) : (h_addr + v_addr); 


	// sequential logic
	always@(posedge clk) begin
		if(rst) begin
			h_addr <= 10'd0;
			v_addr <= 18'd0;
			state <= READ;
		end else begin
			h_addr <= next_h_addr;
			v_addr <= next_v_addr;
			state <= next_state;
		end
	end
		
		
	// state transition logic
	always@( * ) begin
		case(state)	
			READ: if(fifo_full) 
						next_state = READ;					
					else 
						next_state = FILL;
						
			FILL: next_state = READ;

		endcase
	end
endmodule
