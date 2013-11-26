
module Control(
	input clk,
	input rst,
	input[2:0] paddle_1,
	input[2:0] paddle_2,
	input[2:0] ball,
	input[2:0] frame_score,
	input VGA_ready,
	output reg[15:0] pixel_x,
	output reg[15:0] pixel_y,
	output[2:0] color,
	output reg[18:0] address
    );

	reg[15:0] next_x, next_y;

    reg[18:0] next_addr;

	assign color = 		(paddle_1) ? 
										paddle_1 
									: (ball) ? 
										ball 
									: (frame_score) ? 
										frame_score 
									: (paddle_2) ? 
										paddle_2 
									: 3'h0;

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
