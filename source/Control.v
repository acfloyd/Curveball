

module Control(
	input clk,
	input rst,
	input[23:0] paddle_1,
	input[23:0] paddle_2,
	input[23:0] ball,
	input[23:0] frame_score,
	input ready,
	output[15:0] pixel_x,
	output[15:0] pixel_y
	output[23:0] color,
	output[18:0] address
    );
	
endmodule
