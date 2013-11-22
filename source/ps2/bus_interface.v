`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison ECE 554
// Engineer: 	John Cabaj, Nate Williams, Paul McBride
// 
// Create Date:    September 15, 2013
// Design Name: 	 SPART
// Module Name:    bus_interface
// Project Name: 		Mini-Project 1 - SPART
// Target Devices: 	Xilinx Vertex II FPGA
// Tool versions: 
// Description: 		Controls the bus interface between the SPART and the driver
//
// Dependencies: 
//
// Revision: 		1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module bus_interface(output [7:0] trans_buff, baud_gen, output trans_load, baud_load, RDA, TBR, inout [7:0] DATABUS, input [7:0] rec_buff, input [1:0] IOADDR, input rec_data_avail, trans_buff_rdy, IOCS, IORW);
  
  // manage interconnect with receive multiplexer and the data to written to the databus
  wire [7:0] write_data, mux_data;
  
  // managing the tristate data bus
  assign write_data = (!IORW && IOCS) ? DATABUS : 8'bz;
  assign DATABUS = (IORW && IOCS && !IOADDR[1]) ? mux_data : 8'bz;
  
  // output to transmitter or baud generator
  assign trans_buff = write_data;
  assign baud_gen = write_data;
  
  // signal transmitter or baud generator to load
  assign baud_load = (!IORW && (IOADDR[1] == 1'b1) && IOCS) ? 1'b1 : 1'b0;
  assign trans_load = (!IORW && (IOADDR == 2'b00) && IOCS) ? 1'b1 : 1'b0;
  
  // receive data available or transmit buffer ready
  assign RDA = rec_data_avail;
  assign TBR = trans_buff_rdy;
  
  // instantiate multiplexer
  multiplexer read_mux(mux_data, rec_buff, IOADDR, RDA, TBR);
endmodule

// multiplexer to control receiver buffer or status register read
module multiplexer(output [7:0] data, input [7:0] rec_buff, input [1:0] IOADDR, input RDA, TBR);
  
  wire [7:0] stat_reg;
  assign stat_reg = {6'b0, TBR, RDA};
  assign data = IOADDR[0] ? stat_reg : rec_buff;
  
endmodule