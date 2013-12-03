
module Control(
	input clk,
	input rst,
	input[23:0] paddle_1,
	input[23:0] paddle_2,
	input[23:0] ball,
	input[23:0] frame_score,
	input VGA_ready,
	output reg[15:0] pixel_x,
	output reg[15:0] pixel_y,
	output reg[23:0] color,
	output reg[18:0] address
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

	reg[15:0] next_x, next_y;

    reg[18:0] next_addr;

	/*assign color = 		(paddle_1) ? 
										paddle_1 
									: (ball) ? 
										ball 
									: (frame_score) ? 
										frame_score 
									: (paddle_2) ? 
										paddle_2 
									: BLACK;*/
	always@(*) begin
		color = BLACK;		// default
		if(paddle_1 == BLUE)
			color = BLUE;
		else if(paddle_1 == GRAY) begin	// transparency
			if(ball)
				color = {(ball[23:16] + GRAY[23:16])>>1,(ball[15:8] + GRAY[15:8])>>1,(ball[7:0] + GRAY[7:0])>>1};
			else if(frame_score)
				color = 24'h69E969;
			else if(paddle_2 == RED)
				color = 24'hE96969;
			else if(paddle_2 == GRAY)
				color = GRAY;
			else
				color = 24'h696969;
		end
		else begin		// normal
			if(ball)
				color = ball;
			else if(frame_score)
				color = frame_score;
			else if(paddle_2)
				color = paddle_2;
		end
	end

    always @( * ) begin
		next_addr = address;
        next_x = pixel_x;
        next_y = pixel_y;
		
		if (rst) begin
			next_addr = 19'd0;
            next_x = 16'd0; 
            next_y = 16'd0; 
		end
		else if (VGA_ready) begin
			if (address == 19'h4AFFF) begin
				next_addr = 19'd0;
                next_x = 16'd0;
                next_y = 16'd0;
			end
         else if (pixel_x == 16'd639) begin
                next_x = 16'd0;
                next_y = pixel_y + 16'd1;
					 next_addr = address + 19'd1;
            end
			else begin
				next_addr = address + 19'd1;
            next_x = pixel_x + 16'd1;
         end
		end
			
	end
	
	always @(posedge clk) begin
		if (rst) begin
			address <= 19'd0;
            pixel_x <= 16'd0;
            pixel_y <= 16'd0;
        end
		else begin
			address <= next_addr;
            pixel_x <= next_x;
            pixel_y <= next_y;
		end
	end

endmodule
