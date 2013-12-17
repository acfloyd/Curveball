
module Graphics_ASIC(
   input clk,
	input rst,
	input chipselect,
	inout[15:0] databus,
	input[3:0] data_address,
   input read,
	input VGA_ready,
   output[23:0] color,
	output[3:0] zone);

	parameter paddle_1_x_pos = 0;
	parameter paddle_1_y_pos = 1;
	parameter paddle_2_x_pos = 2;
	parameter paddle_2_y_pos = 3;
	parameter ball_x_pos = 4;
	parameter ball_y_pos = 5;
	parameter ball_z_pos = 6;
	parameter p1_score_pos = 7;
	parameter p2_score_pos = 8;
	parameter game_state_pos = 9;

	wire[18:0] pixel_address;

   reg[15:0] databus_reg;
	reg[15:0] paddle_1_x, paddle_1_y, paddle_2_x, paddle_2_y, ball_x, ball_y, ball_z,
				 p1_score, p2_score, game_state;
	
	wire[15:0] pixel_x, pixel_y;
	wire[23:0] paddle_1_color, paddle_2_color, ball_color,  frame_score_color;
	
	reg[15:0] buffer_regs[9:0];

   assign databus = databus_reg;

	// data bus assignment
	always@(posedge clk) begin
		if (rst)
         databus_reg <= 16'hzzzz;
		else if(chipselect & read)
			databus_reg <= buffer_regs[data_address];
		else
			databus_reg <= 16'hzzzz;
	end
	
	// buffer assignment
	always@(posedge clk) begin
		if(rst) begin
			buffer_regs[0] <= 320;
			buffer_regs[1] <= 240;
			buffer_regs[2] <= 320;
			buffer_regs[3] <= 240;
			buffer_regs[4] <= 320;
			buffer_regs[5] <= 240;
			buffer_regs[6] <= 500;
			buffer_regs[7] <= 0;
			buffer_regs[8] <= 0;
			buffer_regs[9] <= 0;
		end else if(chipselect & ~read) begin
			buffer_regs[data_address] <= databus;
		end
	end	
	
	// register assignment
	always@(posedge clk) begin
		if(rst) begin
			paddle_1_x <= 320;
			paddle_1_y <= 240;
			paddle_2_x <= 320;
			paddle_2_y <= 240;
			ball_x <= 320;
			ball_y <= 240;
			ball_z <= 500;
			p1_score <= 0;
			p2_score <= 0;
			game_state <= 0;
		end else if(VGA_ready && pixel_x == 639 && pixel_y == 479) begin
			paddle_1_x <= buffer_regs[paddle_1_x_pos];
			paddle_1_y <= buffer_regs[paddle_1_y_pos];
			paddle_2_x <= buffer_regs[paddle_2_x_pos];
			paddle_2_y <= buffer_regs[paddle_2_y_pos];
			ball_x <= buffer_regs[ball_x_pos];
			ball_y <= buffer_regs[ball_y_pos];
			ball_z <= buffer_regs[ball_z_pos];
			p1_score <= buffer_regs[p1_score_pos];
			p2_score <= buffer_regs[p2_score_pos];
			game_state <= buffer_regs[game_state_pos];
		end
	end
		

	Paddle_1 paddle_1(
					.x_loc(paddle_1_x),
					.y_loc(paddle_1_y),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(paddle_1_color));

	
	Paddle_2 paddle_2(
					.x_loc(paddle_2_x),
					.y_loc(paddle_2_y),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(paddle_2_color));
	
	
	Ball ball(.zone_copy(zone),
				.clk(clk),
				.rst(rst),
				.x_loc(ball_x),
				.y_loc(ball_y),
				.z_loc(ball_z),
				.pixel_x(pixel_x),
				.pixel_y(pixel_y),
				.color(ball_color));
	
	//assign ball_color = 0;
	
	Frame_Score frame_score(.clk(clk),
							.rst(rst),
							.VGA_Ready(VGA_ready),
							.your_score(p1_score),
							.their_score(p2_score),
							.game_state(game_state),
							.ball_z(ball_z),
							.pixel_x(pixel_x),
							.pixel_y(pixel_y),
							.color(frame_score_color));
						
	Control control(.clk(clk),
					.rst(rst),
					.paddle_1(paddle_1_color),
					.paddle_2(paddle_2_color),
					.ball(ball_color),
					.frame_score(frame_score_color),
					.VGA_ready(VGA_ready),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(color),
					.address(pixel_address));
endmodule

