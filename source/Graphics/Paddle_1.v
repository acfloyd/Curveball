`timescale 1ns / 1ps
module Paddle_1(
	input[15:0] x_loc,
	input[15:0] y_loc,
	input[15:0] pixel_x,
	input[15:0] pixel_y,
	output reg[23:0] color
    );
	// colors
	localparam[23:0] BLACK = 24'h000000;
	localparam[23:0] GREEN = 24'h00FF00;
	localparam[23:0] BLUE = 24'h0000FF;
	localparam[23:0] RED = 24'hFF0000;
	localparam[23:0] TEAL = 24'h66FFFF;
	localparam[23:0] GRAY = 24'hD3D3D3;
	localparam[23:0] WHITE = 24'hFFFFFF;
	localparam[23:0] GWHITE = 24'hCCFF99;

  wire[15:0] y_diff_in, x_diff_in; 
  //wire checkered;
  reg[15:0] x_diff, y_diff;
  reg[1:0] quad;

  assign y_diff_in = pixel_y - y_loc;
  assign x_diff_in = pixel_x - x_loc;

//  assign checkered = ((pixel_x[0] == 1'b0 && pixel_y[0] == 1'b0) ||
//    (pixel_x[0] == 1'b1 && pixel_y[0] == 1'b1));

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
    color = BLACK;
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
              color = BLUE;
          end
        end
        // 2nd down
        else if (y_diff >= 16'd4 && y_diff <= 16'd7) begin
          if (~(y_diff <= 16'd5 && x_diff == 16'd0)) begin
            color = BLUE;
          end
        end
        // middle section
        else if (y_diff >= 16'd8 && y_diff <= 16'd38) begin
          color = BLUE;
        end
      end
      // 2nd in from left
      else if (x_diff >= 16'd4 && x_diff <= 16'd7) begin
        // top
        if (y_diff <= 16'd3) begin
          if (~(y_diff == 16'd0 && x_diff <= 16'd5))
            color = BLUE;
        end
        // 2nd down
        else if (y_diff >= 16'd4 && y_diff <= 16'd7) begin
          if ((y_diff == 16'd7 && x_diff >= 16'd6) || 
              (y_diff == 16'd6 && x_diff == 16'd7))
            color = GRAY;
          else 
            color = BLUE;
        end
        // 3rd down
        else if (y_diff >= 16'd8 && y_diff <= 16'd11) begin
          if (x_diff == 16'd4 && y_diff <= 9)
            color = BLUE;
          else
            color = GRAY;
        end
        // middle section
        else if (y_diff >= 16'd12 && y_diff <= 16'd38) begin
          if (y_diff >= 16'd37 && y_diff <= 16'd38)
            color = BLUE;
          else
            color = GRAY;
        end
      end
      // 3rd in from left
      else if (x_diff >= 16'd8 && x_diff <= 16'd11) begin
        // top
        if (y_diff <= 16'd3)
          color = BLUE;
        // 2nd down
        else if (y_diff >= 16'd4 && y_diff <= 16'd7) begin
          if (y_diff == 16'd4 && x_diff <= 16'd9)
            color = BLUE;
          else
            color = GRAY;
        end
        // middle section
        else if (y_diff >= 16'd8 && y_diff <= 16'd38) begin
          if (y_diff >= 16'd37 && y_diff <= 16'd38)
            color = BLUE;
          else 
            color = GRAY;
        end
      end
      // middle section
      else if (x_diff >= 16'd12 && x_diff <= 16'd43) begin
        if (y_diff <= 16'd3)
          color = BLUE;
        else if (((y_diff >= 16'd37 && y_diff <= 16'd38) ||
          (x_diff >= 16'd50 && x_diff <= 16'd51) || y_diff <= 16'd3))
          color = BLUE;
        else
          color = GRAY;
      end
      // second from middle
      else if (x_diff >= 16'd44 && x_diff <= 16'd47) begin
        // top
        if (y_diff <= 16'd3)
          color = BLUE;
        // 2nd from middle
        else if (y_diff >= 16'd31 && y_diff <= 16'd34) begin
          if (x_diff >= 16'd45 && x_diff <= 16'd46 && y_diff >= 16'd33)
              color = BLUE;
          else if (x_diff >= 16'd46 && y_diff >= 16'd32 && y_diff <= 16'd33)
              color = BLUE;
          else
            color = GRAY;
        end
        // next to middle bottom
        else if (y_diff >= 16'd35 && y_diff <= 16'd38) begin
          if (x_diff <= 16'd45)
            color = BLUE;
          else
            color = GRAY;
        end
        else
          color = GRAY;
      end
      // next to middle right
      else if (x_diff >= 16'd48 && x_diff <= 16'd51) begin
        // top
        if (y_diff <= 16'd3)
          color = BLUE;
        // vert blue line
        else if (x_diff >= 16'd50 && x_diff <= 16'd51 && y_diff <= 16'd30)
          color = BLUE;
        // 2nd from middle
        else if (y_diff >= 16'd31 && y_diff <= 16'd32)
          color = BLUE;
        else
          color = GRAY;
      end
    end
  end
endmodule
