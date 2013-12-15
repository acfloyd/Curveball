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
module read_driver(
    input clk,						// 75 MHz clock
    input rst,						// Asynchronous reset, tied to dip switch 0
    input rda,						// received data available
	 input [7:0] data_in,
	 input [1:0] addr,
	 output [15:0] data_out
    );
	 
	 localparam MSTATUS = 2'b00;
	 localparam XPOS = 2'b01;
	 localparam YPOS = 2'b10;
	 
	 reg[15:0] mouseData[0:2];
    
	 reg [7:0] first_status, second_status, next_first_status, next_second_status;
	 reg [7:0] first_x_loc, second_x_loc, next_first_x_loc, next_second_x_loc;
	 reg [7:0] first_y_loc, second_y_loc, next_first_y_loc, next_second_y_loc;
    reg [3:0] state, next_state;			// state and next state
	 reg next_dav, dav;
    
	 // state variables
	 localparam WAIT_START_1 = 4'hc;
	 localparam READ_START_1 = 4'hd;
	 localparam WAIT_START_2 = 4'he;
	 localparam READ_START_2 = 4'hf;
    localparam WAIT_STATUS_1 = 4'h0;
	 localparam READ_STATUS_1 = 4'h1;
	 localparam WAIT_STATUS_2 = 4'h2;
	 localparam READ_STATUS_2 = 4'h3;
	 localparam WAIT_X_1 = 4'h4;
	 localparam READ_X_1 = 4'h5;
	 localparam WAIT_X_2 = 4'h6;
	 localparam READ_X_2 = 4'h7;
	 localparam WAIT_Y_1 = 4'h8;
	 localparam READ_Y_1 = 4'h9;
	 localparam WAIT_Y_2 = 4'ha;
	 localparam READ_Y_2 = 4'hb;
	 
	 assign data_out = (addr == 2'b00) ? mouseData[MSTATUS] : 
                (addr == 2'b01) ? mouseData[XPOS] :
                (addr == 2'b10) ? mouseData[YPOS] : 16'd0;
					 
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			mouseData[MSTATUS] <= 16'd0;
			mouseData[XPOS] <= 16'd0;
			mouseData[YPOS] <= 16'd0;
		end
		else if (dav) begin
			mouseData[MSTATUS] <= {first_status, second_status};
			mouseData[XPOS] <= {first_x_loc, second_x_loc};
			mouseData[YPOS] <= {first_y_loc, second_y_loc};
		end
	end
    
	 // sequential logic
    always@(posedge clk, posedge rst) begin
       if(rst) begin
           state <= WAIT_START_1;	
			  first_status <= 8'd0;
			  second_status <= 8'd0;
			  first_x_loc <= 8'd0;
			  second_x_loc <= 8'd0;
			  first_y_loc <= 8'd0;
			  second_y_loc <= 8'd0;
			  dav <= 1'b0;
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
		  next_state = state;
		  next_first_status = first_status;
		  next_second_status = second_status;
		  next_first_x_loc = first_x_loc;
		  next_second_x_loc = second_x_loc;
		  next_first_y_loc = first_y_loc;
		  next_second_y_loc = second_y_loc;
		  next_dav = 1'b0;
        case(state)
           WAIT_START_1: begin
              if(rda) begin
                 next_state = READ_START_1;
              end 
              else begin
                 next_state = WAIT_START_1; 
              end
           end
			  READ_START_1: begin
				  if(data_in != 8'hBA)
				     next_state = WAIT_START_1;
				  else
				     next_state = WAIT_START_2;
           end
			  WAIT_START_2: begin
              if(rda) begin
                 next_state = READ_START_2;
              end 
              else begin
                 next_state = WAIT_START_2; 
              end
           end
			  READ_START_2: begin
				  if(data_in != 8'h11)
				     next_state = WAIT_START_1;
				  else
				     next_state = WAIT_STATUS_1;
           end
			  WAIT_STATUS_1: begin
              if(rda) begin
                 next_state = READ_STATUS_1;
              end 
              else begin
                 next_state = WAIT_STATUS_1; 
              end
           end
           READ_STATUS_1: begin
				  next_first_status = data_in;
				  next_state = WAIT_STATUS_2;
           end
           WAIT_STATUS_2: begin
              if(rda) begin
                 next_state = READ_STATUS_2;
              end 
              else begin
                 next_state = WAIT_STATUS_2; 
              end
           end
           READ_STATUS_2: begin
				  next_second_status = data_in;
              next_state = WAIT_X_1;
           end
           WAIT_X_1: begin
              if(rda) begin
                 next_state = READ_X_1;
              end 
              else begin
                 next_state = WAIT_X_1; 
              end
           end
           READ_X_1: begin
				  next_first_x_loc = data_in;
              next_state = WAIT_X_2;
           end
           WAIT_X_2: begin
              if(rda) begin
                 next_state = READ_X_2;
              end 
              else begin
                 next_state = WAIT_X_2; 
              end
           end
           READ_X_2: begin
				  next_second_x_loc = data_in;
              next_state = WAIT_Y_1;
           end
           WAIT_Y_1: begin
              if(rda) begin
                 next_state = READ_Y_1;
              end 
              else begin
                 next_state = WAIT_Y_1; 
              end
           end
           READ_Y_1: begin
				  next_first_y_loc = data_in;
              next_state = WAIT_Y_2;
           end
           WAIT_Y_2: begin
              if(rda) begin
                 next_state = READ_Y_2;
              end 
              else begin
                 next_state = WAIT_Y_2; 
              end
           end
           READ_Y_2: begin
					next_dav = 1'b1;
					next_second_y_loc = data_in;
               next_state = WAIT_START_1;
           end
       endcase
    end
endmodule


