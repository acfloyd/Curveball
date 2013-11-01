
module Static_Frame_Draw(
	input clk,
	input rst,
	input[15:0] pixel_x,
	input[15:0] pixel_y,
	output draw
    );
	
	parameter box_ul_x = 63;
	parameter box_ul_y = 47;
	parameter x_len = 386;
	parameter y_len = 514;
	
	wire h_line, v_line;
	wire h_line_v, h_line_h;
	wire v_line_v, v_line_h;
	
	assign h_line_v = (pixel_y == box_ul_y || pixel_y == box_ul_y + y_len) ? 1'b1 : 1'b0;
	assign h_line_h = (pixel_x >= box_ul_x && pixel_x < box_ul_x + x_len) ? 1'b1 : 1'b0;
	assign v_line_v = (pixel_y >= box_ul_y && pixel_y < box_ul_y + y_len) ? 1'b1 : 1'b0;
	assign v_line_h = (pixel_x == box_ul_x || pixel_x == box_ul_x + x_len) ? 1'b1 : 1'b0;

	assign draw = ((h_line_v && h_line_h) || (v_line_v && v_line_h)) ? 1'b1 : 1'b0;
	
endmodule

