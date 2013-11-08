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
    input [18:0] Waddr,
	output [19:0] ram_Raddr,
	output reg[19:0] ram_Waddr,
	output fifo_wr_en,
    output ready
    );

    // pixel counters
	reg[9:0] h_addr;
	reg[18:0] v_addr;
	reg[9:0] next_h_addr;
	reg[18:0] next_v_addr;
	
	// state logic
	reg state;
	reg next_state;

    // keeps track of frames available to be written to
    reg[1:0] deadFrame, next_deadFrame;
    reg currFrame, next_currFrame;
	
	parameter FILL = 1'b1;
	parameter READ = 1'b0;

	// write enable is only on in FILL state
	assign fifo_wr_en = state;

    // we are ready to accept frames as long as we have a single dead frame
    assign ready = |deadFrame;

    always @( * ) begin
        next_deadFrame = deadFrame;
        next_currFrame = currFrame;
        next_h_addr = h_addr;
        next_v_addr = v_addr;

        // dead frame logic
        if (state == FILL && h_addr == 10'd639 && v_addr == 19'd306560) begin
            next_deadFrame[currFrame] = 1'b1;
            next_currFrame = ~currFrame;
        end

        // combo logic for outputing the correct writting frame address
        if (deadFrame[currFrame] == 1'b1) 
            ram_Waddr = (currFrame) ? (Waddr + 20'd307200) : {1'b0,Waddr};
        else
            ram_Waddr = (~currFrame) ? (Waddr + 20'd307200) : {1'b0,Waddr};

        // if there are no frames ready to be displayed keep the addrs at 0,0
        if (deadFrame[currFrame] == 1'b1) begin
            next_h_addr = 10'd0;
            next_v_addr = 19'd0;
        end
        else begin
            // next addr logic
            if (state == FILL) begin
                if (h_addr == 10'd639) begin
                    next_h_addr = 10'd0;

                    if (v_addr == 19'd306560)
                        next_v_addr = 19'd0;
                    else 
                        next_v_addr = v_addr + 19'd640;
                end
                else begin
                    next_h_addr = h_addr + 1'b1;
                    next_v_addr = v_addr;
                end

            end
        end

        // when done writing a frame to ram, set that frame as ready to be displayed
        if (Waddr > 19'h4AFFE) begin
            if (deadFrame[currFrame] == 1'b1)
                next_deadFrame[currFrame] = 1'b0;
            else
                next_deadFrame[~currFrame] = 1'b0;
        end

    end

    assign ram_Raddr = (currFrame) ? (h_addr + v_addr + 20'd307200) : (h_addr + v_addr); 


	// sequential logic
	always@(posedge clk) begin
		if(rst) begin
			h_addr <= 10'd0;
			v_addr <= 19'd0;
            deadFrame <= 2'b11;
            currFrame <= 1'b0;
			state <= READ;
		end else begin
			h_addr <= next_h_addr;
			v_addr <= next_v_addr;
            deadFrame <= next_deadFrame;
            currFrame <= next_currFrame;
			state <= next_state;
		end
	end
		
		
	// state transition logic
	always@( * ) begin
		case(state)	
			READ: if(fifo_full || deadFrame[currFrame] == 1'b1) 
						next_state = READ;					
					else 
						next_state = FILL;
						
			FILL: next_state = READ;
		endcase
	end
endmodule
