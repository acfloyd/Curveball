`timescale 1ns / 1ps
module Paddle_1(
	input clk,
	input rst,
	input[15:0] x_loc,
	input[15:0] y_loc,
	input[15:0] pixel_x,
	input[15:0] pixel_y,
	output reg[2:0] color
    );

  wire[15:0] y_diff_in, x_diff_in; 
  wire checkered;
  reg[15:0] x_diff, y_diff;
  reg[1:0] quad;

  assign y_diff_in = pixel_y - y_loc;
  assign x_diff_in = pixel_x - x_loc;

  assign checkered = ((pixel_x[0] == 1'b0 && pixel_y[0] == 1'b0) ||
    (pixel_x[0] == 1'b1 && pixel_y[0] == 1'b1));

  always @( * ) begin
    if (x_diff_in <= 16'd51) begin
      if (y_diff_in <= 16'd38)
        quad = 2'h0;
      else
        quad = 2'h2;
    end
    else begin
      if (y_diff_in <= 16'd38)
        quad = 2'h1;
      else
        quad = 2'h3;
    end
  end

  always @( * ) begin
    case (quad)
      2'h0: begin
        x_diff = x_diff_in;
        y_diff = y_diff_in;
      end
      2'h1: begin
        x_diff = 16'd101 - x_diff_in;
        y_diff = y_diff_in;
      end
      2'h2: begin
        x_diff = x_diff_in;
        y_diff = 16'd75 - y_diff_in;
      end
      2'h3: begin
        x_diff = 16'd101 - x_diff_in;
        y_diff = 16'd75 - y_diff_in;
      end
    endcase
  end


  always @( * ) begin
    color = 3'h0;
    // test indide paddle box
    if (pixel_x >= x_loc && x_diff_in <= 16'd101 &&
      pixel_y >= y_loc && y_diff_in <= 16'd75) begin

      // new test for quadrants
      // far left
      if (x_diff <= 16'd3) begin
        // top
        if (y_diff <= 16'd3) begin
          if (x_diff >= 16'd2 && y_diff >= 16'd2) begin
            if (~(y_diff == 16'd2 && x_diff == 16'd2))
              color = 3'h2;
          end
        end
        // 2nd down
        else if (y_diff >= 16'd4 && y_diff <= 16'd7) begin
          if (~(y_diff <= 16'd5 && x_diff == 16'd0)) begin
            color = 3'h2;
          end
        end
        // middle section
        else if (y_diff >= 16'd8 && y_diff <= 16'd38) begin
          color = 3'h2;
        end
      end
      // 2nd in from left
      else if (x_diff >= 16'd4 && x_diff <= 16'd7) begin
        // top
        if (y_diff <= 16'd3) begin
          if (~(y_diff == 16'd0 && x_diff <= 16'd5))
            color = 3'h2;
        end
        // 2nd down
        else if (y_diff >= 16'd4 && y_diff <= 16'd7) begin
          if ((y_diff == 16'd7 && x_diff >= 16'd6) || 
              (y_diff == 16'd6 && x_diff == 16'd7) &&
              checkered)
            color = 3'h5;
          else 
            color = 3'h2;
        end
        // 3rd down
        else if (y_diff >= 16'd8 && y_diff <= 16'd11) begin
          if (x_diff == 16'd4 && y_diff <= 9)
            color = 3'h2;
          else if (checkered)
            color = 3'h5;
        end
        // middle section
        else if (y_diff >= 16'd12 && y_diff <= 16'd38 && checkered) begin
          if (y_diff >= 16'd37 && y_diff <= 16'd38)
            color = 3'd2;
          else
            color = 3'd5;
        end
      end
      // 3rd in from left
      else if (x_diff >= 16'd8 && x_diff <= 16'd11) begin
        // top
        if (y_diff <= 16'd3)
          color = 3'h2;
        // 2nd down
        else if (y_diff >= 16'd4 && y_diff <= 16'd7) begin
          if (y_diff == 16'd4 && x_diff <= 16'd9)
            color = 3'h2;
          else if (checkered)
            color = 3'h5;
        end
        // middle section
        else if (y_diff >= 16'd8 && y_diff <= 16'd38 && checkered) begin
          if (y_diff >= 16'd37 && y_diff <= 16'd38)
            color = 3'h2;
          else 
            color = 3'h5;
        end
      end
      // middle section
      else if (x_diff >= 16'd12 && x_diff <= 16'd43) begin
        if (y_diff <= 16'd3)
          color = 3'h2;
        else if (((y_diff >= 16'd37 && y_diff <= 16'd38) ||
          (x_diff >= 16'd50 && x_diff <= 16'd51) || y_diff <= 16'd3) && checkered)
          color = 3'h2;
        else if (checkered)
          color = 3'h5;
      end
      // second from middle
      else if (x_diff >= 16'd44 && x_diff <= 16'd47) begin
        // top
        if (y_diff <= 16'd3)
          color = 3'h2;
        // 2nd from middle
        else if (y_diff >= 16'd31 && y_diff <= 16'd34) begin
          if (x_diff >= 16'd45 && x_diff <= 16'd46 && y_diff >= 16'd33)
              color = 3'h2;
          else if (x_diff >= 16'd46 && y_diff >= 16'd32 && y_diff <= 16'd33)
              color = 3'h2;
          else if (checkered)
            color = 3'h5;
        end
        // next to middle bottom
        else if (y_diff >= 16'd35 && y_diff <= 16'd38) begin
          if (x_diff <= 16'd45)
            color = 3'h2;
          else if (checkered)
            color = 3'h5;
        end
        else if (checkered)
          color = 3'h5;
      end
      // next to middle right
      else if (x_diff >= 16'd48 && x_diff <= 16'd51) begin
        // top
        if (y_diff <= 16'd3)
          color = 3'h2;
        // vert blue line
        else if (x_diff >= 16'd50 && x_diff <= 16'd51 && y_diff <= 16'd30 && checkered)
          color = 3'h2;
        // 2nd from middle
        else if (y_diff >= 16'd31 && y_diff <= 16'd32)
          color = 3'h2;
        else if (checkered)
          color = 3'h5;
      end
    end
  end
endmodule
