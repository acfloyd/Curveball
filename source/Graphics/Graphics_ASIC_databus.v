
module Graphics_ASIC(
   input clk,
	input rst,
	input chipselect,
	inout[15:0] databus,
	input[3:0] data_address,
   input read,
	input VGA_ready,
   output[23:0] color);

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
	wire[15:0] next_ball_z;

   reg[15:0] databus_reg;
	reg[15:0] paddle_1_x, paddle_1_y, paddle_2_x, paddle_2_y, ball_x, ball_y, ball_z,
				 p1_score, p2_score, game_state;
	
	wire[15:0] pixel_x, pixel_y;
	wire[23:0] paddle_1_color, paddle_2_color, ball_color,  frame_score_color;
	
	reg[15:0] buffer_regs[9:0];
	//assign player_1_score_buffer = 16'd1;
	//assign player_2_score_buffer = 16'd2;
	
	//assign paddle_2_x_buffer = 16'd350;
	//assign paddle_2_y_buffer = 16'd250;
/*	
	assign next_pad1_x = (VGA_ready && pixel_address == 19'h4AFFF) ?
									(paddle_1_x_buffer <= 16'd400) ?
										paddle_1_x_buffer + 16'd1
									: 16'd100
								:paddle_1_x_buffer;
*/
								
	//assign paddle_1_y_buffer = 16'd200;

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
			buffer_regs[6] <= 0;
			buffer_regs[7] <= 0;
			buffer_regs[8] <= 0;
			buffer_regs[9] <= 0;
		end else if(chipselect & ~read) begin
			buffer_regs[data_address] <= databus;
		end
		else begin
			buffer_regs[ball_z_pos] <= next_ball_z;
		end
	end

	assign next_ball_z = (VGA_ready && pixel_address == 19'h4AFFF) ?
								(buffer_regs[ball_z_pos] < 16'd999) ? 
								buffer_regs[ball_z_pos] + 16'd10 : 16'd000 : buffer_regs[ball_z_pos];
	
	
	// register assignment
	always@(posedge clk) begin
		if(rst) begin
			paddle_1_x <= 320;
			paddle_1_y <= 240;
			paddle_2_x <= 320;
			paddle_2_y <= 240;
			ball_x <= 320;
			ball_y <= 240;
			ball_z <= 0;
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
	/*				
	Ball ball(.clk(clk),
				.rst(rst),
				.x_loc(ball_x),
				.y_loc(ball_y),
				.z_loc(ball_z),
				.pixel_x(pixel_x),
				.pixel_y(pixel_y),
				.color(ball_color));
	*/

	Ball ball(.clk(clk),
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
							.your_score(p1_score[3:0]),
							.their_score(p2_score[3:0]),
							.their_score(p2_score[3:0]),
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

