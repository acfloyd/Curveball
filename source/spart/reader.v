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
module reader(
    input clk,
    input rst,
    output rda,
	 output [7:0] data_out,
    input rxd
    );
                     
    read_baud_generator bg(.clk(clk), 
                      .rst(rst), 
                      .rxEnable(rxEnable));
                     
    receiver rx(  .rec_buff(data_out), 
                  .RDA(rda),
                  .clk(clk), 
                  .rst(rst), 
                  .RxD(rxd), 
                  .rxEnable(rxEnable));

endmodule

