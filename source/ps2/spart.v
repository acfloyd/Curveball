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
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );
      
    wire [7:0] trans_buff, baud_gen, rec_buff; 
	 
      
    bus_interface bi(.trans_buff(trans_buff), 
                     .baud_gen(baud_gen), 
                     .trans_load(trans_load), 
                     .baud_load(baud_load), 
                     .RDA(rda), 
                     .TBR(tbr), 
                     .DATABUS(databus), 
                     .rec_buff(rec_buff), 
                     .IOADDR(ioaddr), 
                     .rec_data_avail(rec_data_avail), 
                     .trans_buff_rdy(trans_buff_rdy), 
                     .IOCS(iocs), 
                     .IORW(iorw));
                     
    baud_generator bg(.baud_gen(baud_gen), 
                      .baud_load(baud_load), 
                      .clk(clk), 
                      .rst(rst), 
                      .IOADDR(ioaddr), 
                      .txEnable(txEnable), 
                      .rxEnable(rxEnable));
                      
    transmitter tx(.TxD(txd), 
                   .TBR(trans_buff_rdy), 
                   .trans_buff(trans_buff), 
                   .clk(clk), 
                   .rst(rst), 
                   .txEnable(txEnable), 
                   .trans_load(trans_load));

    receiver rx(.rec_buff(rec_buff), 
                  .RDA(rec_data_avail), 
                  .IOADDR(ioaddr), 
                  .clk(clk), 
                  .rst(rst), 
                  .RxD(rxd), 
                  .IOCS(iocs), 
                  .IORW(iorw), 
                  .rxEnable(rxEnable));

endmodule
