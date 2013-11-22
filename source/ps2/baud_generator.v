`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison ECE 554
// Engineer: 	John Cabaj, Nate Williams, Paul McBride
// 
// Create Date:    September 15, 2013
// Design Name: 	 SPART
// Module Name:    baud_generator
// Project Name: 		Mini-Project 1 - SPART
// Target Devices: 	Xilinx Vertex II FPGA
// Tool versions: 
// Description: 		Controls sampling and baud rate signals
//
// Dependencies: 
//
// Revision: 		1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module baud_generator(baud_gen, baud_load, clk, rst, IOADDR, txEnable, rxEnable);
    
    input rst, clk, baud_load;				// inputs
    input [1:0] IOADDR; 
    input [7:0] baud_gen;
    output reg txEnable, rxEnable;			//outputs
    reg [15:0] counter;					// counter to decrement
    reg [15:0] divBuf;					// data to load into counter
    reg [3:0] txCount;					// count for baud rate signal
    
	 // sequential logic
    always@(posedge clk, posedge rst) begin
		 // reset signals
       if(rst) begin
           divBuf <= 16'd0;
           counter <= 16'd0;
           txCount <= 4'd15;
           txEnable <= 1'b0;
           rxEnable <= 1'b0;
       end
		 
       else begin 
			 //loading the baud generator counter
          if(baud_load) begin
             if (IOADDR == 2'b10) begin
                 divBuf[7:0] <= baud_gen;
             end
             else if(IOADDR == 2'b11) begin
                 divBuf[15:8] <= baud_gen;
             end
          end
			 
			 // counter has reached 0
          else if(counter == 16'd0) begin
				  // output a baud rate signal every 16 samples
              if(txCount == 4'd0) begin
                 txCount <= 4'd15;
                 txEnable <= 1'b1;
              end
				  
				  // decrement baud rate signal counter
              else begin
                 txCount <= txCount - 4'd1;
                 txEnable <= 1'b0; 
              end
				  
				  // send sampling signal
              rxEnable <= 1'b1;
              counter <= divBuf;
          end
			 
			 // counter hasn't reached 0
          else if(counter != 1'd0) begin
             rxEnable <= 1'b0;
             txEnable <= 1'b0;
             counter <= counter - 16'd1; 
          end
       end
    end
        
endmodule