
module Graphics_ASIC(
    input clk,
	input rst,
	input chipselect,
    input read,
	input[15:0] databus,
	input[3:0] data_address,
	input VGA_ready,
    output[23:0] color,
    output[18:0] pixel_address
    );

	reg[15:0] paddle_1_x, paddle_1_x_buffer;
	reg[15:0] paddle_1_y, paddle_1_y_buffer;
	reg[15:0] paddle_2_x, paddle_2_x_buffer;
	reg[15:0] paddle_2_y, paddle_2_y_buffer;
	reg[15:0] ball_x, ball_x_buffer;
	reg[15:0] ball_y, ball_y_buffer;
	reg[15:0] ball_z, ball_z_buffer;
	reg[15:0] player_1_score, player_1_score_buffer;
	reg[15:0] player_2_score, player_2_score_buffer;
	reg[15:0] game_state, game_state_buffer;

    wire[15:0] next_paddle_1_x, next_paddle_1_y;
    wire[15:0] next_paddle_2_x, next_paddle_2_y;
    wire[15:0] next_ball_x, next_ball_y, next_ball_z;
    wire[15:0] next_player_1_score, next_player_1_score;

	wire[15:0] pixel_x, pixel_y;
	wire[23:0] paddle_1_color, paddle_2_color, ball_color,  frame_score_color;


	// logic for next values of databus
    always @( * ) begin
        next_paddle_1_x = paddle_1_x;
        next_paddle_1_y = paddle_1_y;
        next_paddle_2_x = paddle_2_x;
        next_paddle_2_y = paddle_2_y;
        next_ball_x = ball_x;
        next_ball_y = ball_y;
        next_ball_z = ball_z;
        next_player_1_score = player_1_score;
        next_player_2_score = player_2_score;
        next_game_state = game_state;
        next_databus = 16'hzzzz;

        if (rst) begin
            next_paddle_1_x = 16'd320;
            next_paddle_1_y = 16'd240;
            next_paddle_2_x = 16'd320;
            next_paddle_2_y = 16'd240;
            next_ball_x = 16'd320;
            next_ball_y = 16'd240;
            next_ball_z = 16'd0;
            next_player_1_score = 16'd0;
            next_player_2_score = 16'd0;
            next_game_state = 16'd0;
        end
        else if (chipselect) begin
            if (read) begin
                case (data_address) begin
                    4'h0: next_databus = paddle_1_x;
                    4'h1: next_databus = paddle_1_y;
                    4'h2: next_databus = paddle_2_x;
                    4'h3: next_databus = paddle_2_y;
                    4'h4: next_databus = ball_x;
                    4'h5: next_databus = ball_y;
                    4'h6: next_databus = ball_z;
                    4'h7: next_databus = player_1_score;
                    4'h8: next_databus = player_2_score;
                    4'h9: next_databus = game_state;
                end
            end
            else begin
                case (data_address) begin
                    4'h0: next_paddle_1_x = databus;
                    4'h1: next_paddle_1_y = databus;
                    4'h2: next_paddle_2_x = databus;
                    4'h3: next_paddle_2_y = databus;
                    4'h4: next_ball_x = databus;
                    4'h5: next_ball_y = databus;
                    4'h6: next_ball_z = databus;
                    4'h7: next_player_1_score = databus;
                    4'h8: next_player_2_score = databus;
                    4'h9: next_game_state = databus;
                end
            end
        end
    end

    // buffer registers from databus
    always @(posedge clk) begin
        if (rst) begin
            paddle_1_x <= 16'd320;
            paddle_1_y <= 16'd240;
            paddle_2_x <= 16'd320;
            paddle_2_y <= 16'd240;
            ball_x <= 16'd320;
            ball_y <= 16'd240;
            ball_z <= 16'd0;
            player_1_score <= 16'd0;
            player_2_score <= 16'd0;
            game_state <= 16'd0;
        end
        else begin
            paddle_1_x <= next_paddle_1_x;
            paddle_1_y <= next_paddle_1_y;
            paddle_2_x <= next_paddle_2_x;
            paddle_2_y <= next_paddle_2_y;
            ball_x <= next_ball_x;
            ball_y <= next_ball_y;
            ball_z <= next_ball_z;
            player_1_score <= next_player_1_score;
            player_2_score <= next_player_2_score;
            game_state <= next_game_state;
        end
    end
	
    // buffer the registers on begining of a frame
	always @(posedge clk) begin
		if (rst) begin
			paddle_1_x_buffer <= paddle_1_x;
			paddle_1_y_buffer <= paddle_1_y;
			paddle_2_x_buffer <= paddle_2_x;
			paddle_2_y_buffer <= paddle_2_y;
            ball_x_buffer <= ball_x;
            ball_y_buffer <= ball_y;
            ball_z_buffer <= ball_z;
            game_state_buffer <= game_state;
		end
		else if (pixel_address == 19'h4AFFF && VGA_ready) begin
			paddle_1_x_buffer <= paddle_1_x;
			paddle_1_y_buffer <= paddle_1_y;
			paddle_2_x_buffer <= paddle_2_x;
			paddle_2_y_buffer <= paddle_2_y;
            ball_x_buffer <= ball_x;
            ball_y_buffer <= ball_y;
            ball_z_buffer <= ball_z;
            game_state_buffer <= game_state;
        end
	end

	Paddle_1 paddle_1(.clk(clk),
					.rst(rst),
					.x_loc(paddle_1_x_buffer),
					.y_loc(paddle_1_y_buffer),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(paddle_1_color));

	Paddle_2 paddle_2(.clk(clk),
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
