`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:41:05 11/19/2013 
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
			input clk, 
			input rst,
			input BIT_CLK, 
			output SDATA_OUT, 
			output SYNC, 
			output BEEP_TONE_IN, 
			output AUDIO_RESET_Z
    );		
	
	 assign BEEP_TONE_IN = 1'b0;
    
	 wire cs, rw;
	 wire[15:0] data;
    Driver d(.clk(clk), .rst(rst), .cs(cs), .rw(rw), .data(data));
    Audio_Controller ac(.clk(clk), .rst(rst), .cs(cs), .rw(rw), .data(data), .BIT_CLK(BIT_CLK), .SDATA_OUT(SDATA_OUT), .SYNC(SYNC), .AUDIO_RESET_Z(AUDIO_RESET_Z));
						  
endmodule