`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
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
module writer(
    input clk,
    input rst,
	 input write,
    output tbr,
    input [7:0] data_in,
    output txd
    );
                     
    write_baud_generator bg(.clk(clk), 
                      .rst(rst),
                      .txEnable(txEnable));
                      
    transmitter tx(.TxD(txd), 
                   .TBR(tbr), 
                   .trans_buff(data_in), 
                   .clk(clk), 
                   .rst(rst), 
                   .txEnable(txEnable), 
                   .trans_load(write));

endmodule
