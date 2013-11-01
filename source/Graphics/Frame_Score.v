
module Frame_Score(
	input clk,
	input rst,
	input[15:0] your_score,
	input[15:0] their_score,
	input[15:0] game_state,
	input[15:0] pixel_x,
	input[15:0] pixel_y,
	output[2:0] color
    );
	
	wire draw;
	
	Static_Frame_Draw s(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(draw));
	  
	assign color = (draw) ? 3'b1 : 3'b0;
	

endmodule