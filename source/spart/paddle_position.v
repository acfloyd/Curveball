`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:09:04 12/05/2013 
// Design Name: 
// Module Name:    paddle_position 
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
module paddle_position(output reg [15:0] x_loc, y_loc, output reg [1:0] status, output reg [1:0] addr, input [15:0] data, input dav, clk, rst);

   reg [15:0] next_x_loc, next_y_loc;
	reg [1:0] next_status;
   reg [1:0] state, next_state;
	
   localparam idle = 2'h0, read_status = 2'h1, read_x = 2'h2, read_y = 2'd3;
   
   always@(posedge clk, posedge rst) begin
      if(rst) begin
         status <= 2'd0;
         x_loc <= 16'd0;
         y_loc <= 16'd0;
			state <= 2'd0;
      end
      else begin
         x_loc <= next_x_loc;
         y_loc <= next_y_loc;
         status <= next_status;
			state <= next_state;
      end 
   end

   always@(*) begin
		 next_state = state;
       next_x_loc = x_loc;
       next_y_loc = y_loc;
       next_status = status;
       addr = 2'b00;
       case(state)
          idle: begin
             if(dav)
                next_state = read_status; 
          end
          read_status: begin
				addr = 2'b00;
				next_status = data[1:0]; 
				next_state = read_x; 
          end
          read_x: begin
				addr = 2'b01;
            next_x_loc = data; 
            next_state = read_y; 
          end
          read_y: begin
            addr = 2'b10;
            next_y_loc = data; 
            next_state = idle; 
          end
       endcase
   end
   
endmodule 