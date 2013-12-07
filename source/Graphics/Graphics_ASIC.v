
module Graphics_ASIC(
   input clk,
	input rst,
	input[3:0] chipselect,
	input[15:0] databus,
	input[3:0] data_address,
	input VGA_ready,
   output[23:0] color,
   output[18:0] pixel_address
   );
	reg[15:0] paddle_1_x, next_paddle_1_x;
	reg[15:0] paddle_1_x_buffer;
	wire [15:0] paddle_1_y, paddle_1_y_buffer;
	wire [15:0] paddle_2_x, paddle_2_x_buffer;
	wire [15:0] paddle_2_y, paddle_2_y_buffer;
	wire [15:0] ball_x, ball_x_buffer;
	wire [15:0] ball_y, ball_y_buffer;
	reg [15:0] ball_z, ball_z_buffer;
	wire [15:0] next_ball_z;
	wire [15:0] player_1_score, player_1_score_buffer;
	wire [15:0] player_2_score, player_2_score_buffer;
	reg [15:0] game_state, game_state_buffer;
	wire[15:0] pixel_x, pixel_y;
	wire[23:0] paddle_1_color, paddle_2_color, ball_color,  frame_score_color;
	
	assign player_1_score_buffer = 16'd1;
	assign player_2_score_buffer = 16'd2;
	
	assign paddle_2_x_buffer = 16'd350;
	assign paddle_2_y_buffer = 16'd250;
								
	assign paddle_1_y_buffer = 16'd200;

    always @(*) begin
        next_paddle_1_x = paddle_1_x_buffer;

        if (VGA_ready && pixel_address == 19'h4AFFF) begin
            if (paddle_1_x_buffer <= 16'd400)
                next_paddle_1_x = paddle_1_x_buffer + 1;
            else
                next_paddle_1_x = 16'd100;
        end
    end
	
	assign next_ball_z = (VGA_ready && pixel_address == 19'h4AFFF) ?
								(ball_z_buffer < 16'd999) ? ball_z_buffer + 16'd10 : 16'd000 : ball_z_buffer;
	
	assign ball_x_buffer = 16'd305;
	assign ball_y_buffer = 16'd240;
	
	always @(posedge clk) begin
		if (rst) begin
			paddle_1_x_buffer <= 16'd100;
			ball_z_buffer <= 16'd000;
		end
		else begin
			paddle_1_x_buffer <= 16'd100;
			ball_z_buffer <= next_ball_z;
		end
	end

	Paddle_1 paddle_1(.x_loc(paddle_1_x_buffer),
					.y_loc(paddle_1_y_buffer),
					.pixel_x(pixel_x),
					.pixel_y(pixel_y),
					.color(paddle_1_color));

	Paddle_2 paddle_2(.x_loc(paddle_2_x_buffer),
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
