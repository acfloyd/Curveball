
module Control(
	input clk,
	input rst,
	input[2:0] paddle_1,
	input[2:0] paddle_2,
	input[2:0] ball,
	input[2:0] frame_score,
	input VGA_ready,
	output[15:0] pixel_x,
	output[15:0] pixel_y,
	output[2:0] color,
	output[18:0] address
    );
	reg[15:0] x,y;
	wire[15:0] next_x, next_y;
	assign color = (paddle_1) ? paddle_1 :
					(ball) ? ball :
					(frame_score) ? frame_score :
					(paddle_2) ? paddle_2 : 3'b0;
	// clock new values into registers
	always@(posedge clk) begin
		if(rst) begin
			x <= 16'b0;
			y <= 16'b0;
		end
		else begin
			x <= next_x;
			y <= next_y;
		end
	end
	
	// update counters
	assign next_x = (x == 16'd640) ? 16'b0 : x + 1;
	assign next_y = (x == 16'd640) ? (y == 16'd480) ? 16'b0 : y + 1 : y;
	
	// produce outputs
	assign pixel_x = x;
	assign pixel_y = y;
	assign address = x + (y << 7) * 5;	// 640*y
endmodule
