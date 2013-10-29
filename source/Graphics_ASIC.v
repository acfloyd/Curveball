
module Graphics_ASIC(
    input clk,
	input rst,
	input[3:0] chipselect,
	input[15:0] databus,
	input[3:0] data_address,
    output[23:0] color,
    output[18:0] pixel_address
    );
	reg [15:0] paddle_1_x, paddle_1_x_buffer;
	reg [15:0] paddle_1_y, paddle_1_y_buffer;
	reg [15:0] paddle_2_x, paddle_2_x_buffer;
	reg [15:0] paddle_2_y, paddle_2_y_buffer;
	reg [15:0] ball_x, ball_x_buffer;
	reg [15:0] ball_y, ball_y_buffer;
	reg [15:0] ball_z, ball_z_buffer;
	reg [15:0] player_1_score, player_1_score_buffer;
	reg [15:0] player_2_score, player_2_score_buffer;
	reg [15:0] game_state, game_state_buffer;
	wire[15:0] pixel_x, pixel_y;
	wire[23:0] paddle_1_color, paddle_2_color, ball_color,  frame_score_color;
	Paddle_1 paddle_1(.clk(clk),
					.rst(rst),
					.x_loc(paddle_1_x_buffer),
					.y_loc(paddle_1_y_buffer),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(paddle_1_color));
	Paddle_1 paddle_2(.clk(clk),
					.rst(rst),
					.x_loc(paddle_2_x_buffer),
					.y_loc(paddle_2_y_buffer),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(paddle_2_color));
	Ball ball(.clk(clk),
				.rst(rst),
				.x_loc(ball_x_buffer),
				.y_loc(ball_y_buffer),
				.z_loc(ball_z_buffer),
				.pixel_x(pixel_x),
				.pixel_y(pixel_y),
				.color(ball_color));
	Frame_Score frame_score(.clk(clk),
							.rst(rst),
							.your_score(player_1_score_buffer),
							.their_score(player_2_score_buffer),
							.games_state(game_state_buffer),
							.pixel_x(pixel_x),
							.pixel_y(pixel_y),
							.color(paddle_2_color));
endmodule