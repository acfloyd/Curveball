// Top level module for displaying frame and score data
module Frame_Score(
	input clk,
	input rst,
	input[15:0] your_score,
	input[15:0] their_score,
	input[15:0] game_state,
	input[15:0] pixel_x,
	input[15:0] pixel_y,
	output[23:0] color
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
	
	wire[8:0] frame_draw;
	wire score_draw;
	
	// static square frames
	Static_Frame_Draw #( 63,  47, 514, 386) frame0(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[0]));
	Static_Frame_Draw #( 99,  74, 442, 332) frame1(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[1]));
	Static_Frame_Draw #(133, 100, 374, 281) frame2(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[2]));
	Static_Frame_Draw #(163, 122, 314, 236) frame3(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[3]));
	Static_Frame_Draw #(189, 142, 263, 197) frame4(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[4]));
	Static_Frame_Draw #(211, 158, 218, 164) frame5(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[5]));
	Static_Frame_Draw #(229, 172, 182, 137) frame6(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[6]));
	Static_Frame_Draw #(243, 182, 154, 116) frame7(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[7]));
	Static_Frame_Draw #(255, 191, 130,  98) frame8(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[8]));

	
	// Score
	Score_Draw score(.clk(clk), .pixel_x(pixel_x), .pixel_y(pixel_y), .your_score(your_score), .their_score(their_score), .draw(score_draw)); 
	
	assign color = (frame_draw) ? GREEN : (score_draw) ? TEAL: BLACK;
	
endmodule


// module for drawing a static frame. Parameters specify upper left corner point and side lengths
module Static_Frame_Draw(
	input clk,
	input rst,
	input[15:0] pixel_x,
	input[15:0] pixel_y,
	output draw
    );
	
	parameter box_ul_x = 63;
	parameter box_ul_y = 47;
	parameter x_len = 514;
	parameter y_len = 386;
	
	wire h_line_v, h_line_h;
	wire v_line_v, v_line_h;
	
	assign h_line_v = (pixel_y == box_ul_y || pixel_y == box_ul_y + y_len - 1) ? 1'b1 : 1'b0;
	assign h_line_h = (pixel_x >= box_ul_x && pixel_x < box_ul_x + x_len) ? 1'b1 : 1'b0;
	assign v_line_v = (pixel_y >= box_ul_y && pixel_y < box_ul_y + y_len) ? 1'b1 : 1'b0;
	assign v_line_h = (pixel_x == box_ul_x || pixel_x == box_ul_x + x_len - 1) ? 1'b1 : 1'b0;

	assign draw = ((h_line_v && h_line_h) || (v_line_v && v_line_h)) ? 1'b1 : 1'b0;
	
endmodule


// module for drawing scores. Uses a pre-built ROM
module Score_Draw(
  input clk,
  input[15:0] pixel_x,
  input[15:0] pixel_y,
  input[15:0] your_score,
  input[15:0] their_score,
  output draw
    );
    
  // general score parameters
  parameter score_width = 32;
  parameter score_height = 32;
  parameter addr_width = clog2(score_width * score_height * 16);
    
  // parameters for scores
  parameter x1 = 64; // ul x coordinate for score 1
  parameter x2 = 544; // ul x coordinate for score 2
  parameter y = 10; // ul y coordinate for both scores
  
  // build score ROM
  wire[addr_width - 1:0] addr;
  wire data;
  Score_ROM r(.clka(clk), .addra(addr), .douta(data));
  
  // draw logic
  wire p1_w, p2_w, p_v;
  assign p1_w = pixel_x >= x1 && pixel_x < x1 + score_width;
  assign p2_w = pixel_x >= x2 && pixel_x < x2 + score_width;
  assign p_v = pixel_y >= y && pixel_y < y + score_height;
  assign draw = (p_v && (p1_w || p2_w)) ? data : 1'b0;
  
  // addr logic
  wire[3:0] digit;
  wire[4:0] addr_x, addr_y;
  assign addr_x = (pixel_x < 639) ? pixel_x + 1 : 16'd0;
  assign addr_y = pixel_y - y;
  assign digit = (pixel_x < x1 + score_width) ? your_score[3:0] : their_score[3:0];
  assign addr = {addr_y, digit, addr_x};
   
  function integer clog2;
    input integer value;
    begin 
      value = value-1;
      for (clog2=0; value>0; clog2=clog2+1)
        value = value>>1;
    end 
  endfunction
endmodule
  