`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 	UW-Madison ECE 554
// Engineer: 	John Cabaj, Nate Williams, Paul McBride
// 
// Create Date:    September 15, 2013
// Design Name: 	 SPART
// Module Name:    driver 
// Project Name: 		Mini-Project 1 - SPART
// Target Devices: 	Xilinx Vertex II FPGA
// Tool versions: 
// Description: 		Implements a driver to control SPART operation
//
// Dependencies: 
//
// Revision: 		1.0
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module temp_read_driver(
    input clk,						// 100 MHz clock
    input rst,						// Asynchronous reset, tied to dip switch 0
    output reg iocs,				// chip select
	 output reg read,
    input rda,						// received data available
	 input [7:0] data_in,
	 input [1:0] addr,
	 output [15:0] data_out,
	 output reg dav
    );
    
	 reg [7:0] first_status, second_status, next_first_status, next_second_status;
	 reg [7:0] first_x_loc, second_x_loc, next_first_x_loc, next_second_x_loc;
	 reg [7:0] first_y_loc, second_y_loc, next_first_y_loc, next_second_y_loc;
    reg [2:0] state, next_state;			// state and next state
	 reg next_dav;
    
	 // state variables
    localparam WAIT_STATUS_1 = 3'h0;
	 localparam WAIT_STATUS_2 = 3'h1;
	 localparam WAIT_X_1 = 3'h2;
	 localparam WAIT_X_2 = 3'h3;
	 localparam WAIT_Y_1 = 3'h4;
	 localparam WAIT_Y_2 = 3'h5;
	 
	 assign data_out = (addr == 2'b00) ? {first_status, second_status} : 
                (addr == 2'b01) ? {first_x_loc, second_x_loc} :
                (addr == 2'b10) ? {first_y_loc, second_y_loc} : 16'd0;
    
	 // sequential logic
    always@(posedge clk, posedge rst) begin
       if(rst) begin
           state <= WAIT_STATUS_1;	
			  first_status <= 8'd0;
			  second_status <= 8'd0;
			  first_x_loc <= 8'd0;
			  second_x_loc <= 8'd0;
			  first_y_loc <= 8'd0;
			  second_y_loc <= 8'd0;
       end 
       else begin
           state <= next_state;		
			  first_status <= next_first_status;
			  second_status <= next_second_status;
			  first_x_loc <= next_first_x_loc;
			  second_x_loc <= next_second_x_loc;
			  first_y_loc <= next_first_y_loc;
			  second_y_loc <= next_second_y_loc;
			  dav <= next_dav;
       end
    end
    
	 // next state and combinational logic
	 // determine next state and output signals
    always@(*) begin
	     iocs = 1'b1;
		  next_state = state;
		  next_first_status = first_status;
		  next_second_status = second_status;
		  next_first_x_loc = first_x_loc;
		  next_second_x_loc = second_x_loc;
		  next_first_y_loc = first_y_loc;
		  next_second_y_loc = second_y_loc;
		  read = 1'b0;
		  next_dav = 1'b0;
        case(state)
           WAIT_STATUS_1: begin
              iocs = 1'b1;
              if(rda) begin
                 read = 1'b1;
					  next_first_status = data_in;
					  next_state = WAIT_STATUS_2;
              end 
              else begin
                 next_state = WAIT_STATUS_1; 
              end
           end
           WAIT_STATUS_2: begin
              iocs = 1'b1;
              if(rda) begin
                 read = 1'b1;
					  next_second_status = data_in;
					  next_state = WAIT_X_1;
              end 
              else begin
                 next_state = WAIT_STATUS_2; 
              end
           end
           WAIT_X_1: begin
              iocs = 1'b1;
              if(rda) begin
                 read = 1'b1;
					  next_first_x_loc = data_in;
					  next_state = WAIT_X_2;
              end 
              else begin
                 next_state = WAIT_X_1; 
              end
           end
           WAIT_X_2: begin
              iocs = 1'b1;
              if(rda) begin
                 read = 1'b1;
					  next_second_x_loc = data_in;
					  next_state = WAIT_Y_1;
              end 
              else begin
                 next_state = WAIT_X_2; 
              end
           end
           WAIT_Y_1: begin
              iocs = 1'b1;
              if(rda) begin
                 read = 1'b1;
					  next_first_y_loc = data_in;
					  next_state = WAIT_Y_2;
              end 
              else begin
                 next_state = WAIT_Y_1; 
              end
           end
           WAIT_Y_2: begin
              iocs = 1'b1;
              if(rda) begin
                 read = 1'b1;
					  next_second_y_loc = data_in;
					  next_state = WAIT_STATUS_1;
              end 
              else begin
                 next_state = WAIT_Y_2; 
              end
           end
       endcase
    end
endmodule


