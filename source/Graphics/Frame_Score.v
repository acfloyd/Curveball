// Top level module for displaying frame and score data
module Frame_Score(
	input clk, // CPU clk
	input rst, // global reset
	input VGA_Ready, // signal indicating VGA is ready for input
	input[15:0] your_score, // P1 score
	input[15:0] their_score, // P2 score
	input[15:0] game_state, // current state of game
	input[15:0] ball_z, // ball's z coordinate
	input[15:0] pixel_x, // current x coordinate
	input[15:0] pixel_y, // current y coordinate
	output[23:0] color // color to be output from frame_score module
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
	wire highlight_draw;
	wire[3:0] diag_draw;
	wire[23:0] win_color;
	
	// static square frames
	Static_Frame_Draw #( 63,  47, 514, 386) frame0(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[0]));
	Static_Frame_Draw #(132,  99, 376, 283) frame1(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[1]));
	Static_Frame_Draw #(171, 128, 297, 223) frame2(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[2]));
	Static_Frame_Draw #(197, 148, 245, 185) frame3(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[3]));
	Static_Frame_Draw #(215, 161, 209, 157) frame4(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[4]));
	Static_Frame_Draw #(229, 171, 182, 137) frame5(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[5]));
	Static_Frame_Draw #(239, 179, 162, 122) frame6(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[6]));
	Static_Frame_Draw #(247, 185, 145, 109) frame7(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[7]));
	Static_Frame_Draw #(255, 191, 130,  98) frame8(.pixel_x(pixel_x), .pixel_y(pixel_y), .draw(frame_draw[8]));

	// Diagonals
	Diagonal_Draw #(63, 47, 255, 191) d1(.clk(clk), .rst(rst), .en(VGA_Ready), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(diag_draw[0]));
	Diagonal_Draw #(384, 288, 576, 432) d2(.clk(clk), .rst(rst), .en(VGA_Ready), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(diag_draw[1]));
	Diagonal_Draw_R #(255, 288, 63, 432) d3(.clk(clk), .rst(rst), .en(VGA_Ready), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(diag_draw[2]));
	Diagonal_Draw_R #(576, 47, 384, 191) d4(.clk(clk), .rst(rst), .en(VGA_Ready), .pixel_x(pixel_x), .pixel_y(pixel_y), .draw(diag_draw[3]));
	
	// Score and win info
	Score_Draw score(.clk(clk), .pixel_x(pixel_x), .pixel_y(pixel_y), .your_score(your_score), .their_score(their_score), .draw(score_draw)); 
	Win_Draw wd(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .game_state(game_state[1:0]), .ready(VGA_Ready), .color(win_color));
	
	// Sets highlighting to frame nearest ball z position
	assign highlight_draw = (frame_draw[0] && ball_z >=   0 && ball_z <=  62) ||
				(frame_draw[1] && ball_z >=  63 && ball_z <= 187) ||
				(frame_draw[2] && ball_z >= 188 && ball_z <= 312) ||
				(frame_draw[3] && ball_z >= 313 && ball_z <= 437) ||
				(frame_draw[4] && ball_z >= 438 && ball_z <= 562) ||
				(frame_draw[5] && ball_z >= 563 && ball_z <= 687) ||
				(frame_draw[6] && ball_z >= 688 && ball_z <= 812) ||
			 	(frame_draw[7] && ball_z >= 813 && ball_z <= 937) ||
				(frame_draw[8] && ball_z >= 938);
	
	// color layering
	assign color =  (win_color) ? 		win_color :
			(highlight_draw) ?	TEAL :
			(frame_draw) ? 		GREEN : 
			(diag_draw) ? 		GREEN : 
			(score_draw) ? 		TEAL : 
						BLACK;
endmodule

// Draw a single -3/4 slope line based on parameters
module Diagonal_Draw (
	input clk, // CPU clk
	input rst, // global rst
	input en, // enable signal for updating sequential logic
	input[15:0] pixel_x, // current x coordinate
	input[15:0] pixel_y, // current y coordinate
	output draw // signal indicating drawing of diagonal
	);
	
	parameter x1 = 63; // starting x
	parameter y1 = 47; // starting y
	parameter x2 = 255; // ending x
	parameter y2 = 191; // ending y
	
	reg[1:0] cnt3; // cnts when to write three pixels 
	reg[15:0] x_start; // start position in x dir
	
	// determine staring x position
	always@(posedge clk) begin
		if(rst) begin
			x_start <= x1;
			cnt3 <= 0;
		end else if(en && pixel_y + 1 == y1) begin
			x_start <= x1;
			cnt3 <= 0;
		end else if(en && pixel_x == 639 && pixel_y >= y1 && pixel_y <= y2) begin
			if(cnt3 == 2) begin
				cnt3 <= 0;
				x_start <= x_start + 2;
			end else begin
				cnt3 <= cnt3 + 1;
				x_start <= x_start + 1;
			end
		end
	end
	
	// decide whether to draw or not
	assign draw = ~(pixel_y >= y1 && pixel_y <= y2 && pixel_x >= x1 && pixel_x <= x2) ? 1'd0 : 
			(cnt3 == 2) ? (pixel_x >= x_start && pixel_x <= x_start + 2) :
			(pixel_x >= x_start && pixel_x <= x_start + 1);
	
endmodule

// Draw a single 3/4 slope line based on parameters
module Diagonal_Draw_R (
	input clk, // CPU clk
	input rst, // global reset
	input en, // enable signal for updating sequential logic
	input[15:0] pixel_x, // current x coordinate
	input[15:0] pixel_y, // current y coordinate
	output draw // signal indicating drawing of diagonal
	);
	
	parameter x1 = 63; // starting x
	parameter y1 = 47; // starting y
	parameter x2 = 255; // ending x
	parameter y2 = 191; // ending y
	
	reg[1:0] cnt3; // cnts when to write three pixels 
	reg[15:0] x_start; // start position in x dir

	// determine staring x position	
	always@(posedge clk) begin
		if(rst) begin
			x_start <= x1;
			cnt3 <= 0;
		end else if(en && pixel_y + 1 == y1) begin
			x_start <= x1;
			cnt3 <= 0;
		end else if(en && pixel_x == 639 && pixel_y >= y1 && pixel_y <= y2) begin
			if(cnt3 == 2) begin
				cnt3 <= 0;
				x_start <= x_start - 2;
			end else begin
				cnt3 <= cnt3 + 1;
				x_start <= x_start - 1;
			end
		end
	end
	
	// decide whether to draw or not
	assign draw = ~(pixel_y >= y1 && pixel_y <= y2 && pixel_x >= x2 && pixel_x <= x1) ? 1'd0 : 
			(cnt3 == 2) ? (pixel_x >= x_start - 2 && pixel_x <= x_start) :
			(pixel_x >= x_start - 1 && pixel_x <= x_start);
	
endmodule


// module for drawing a static frame. Parameters specify upper left corner point and side lengths
module Static_Frame_Draw(
	input[15:0] pixel_x, // current x coordinate
	input[15:0] pixel_y, // current y coordinate
	output draw // signal indicating drawing of frame
    );
	
	parameter box_ul_x = 63; // upper left x
	parameter box_ul_y = 47; // upper left y
	parameter x_len = 514; // x length
	parameter y_len = 386; // y length
	
	// determine if pixel_x and pixel_y are in box
	wire h_line_v, h_line_h;
	wire v_line_v, v_line_h;
	
	assign h_line_v = (pixel_y == box_ul_y || pixel_y == box_ul_y + y_len - 1) ? 1'b1 : 1'b0;
	assign h_line_h = (pixel_x >= box_ul_x && pixel_x < box_ul_x + x_len) ? 1'b1 : 1'b0;
	assign v_line_v = (pixel_y >= box_ul_y && pixel_y < box_ul_y + y_len) ? 1'b1 : 1'b0;
	assign v_line_h = (pixel_x == box_ul_x || pixel_x == box_ul_x + x_len - 1) ? 1'b1 : 1'b0;

	// assert draw when on box
	assign draw = ((h_line_v && h_line_h) || (v_line_v && v_line_h)) ? 1'b1 : 1'b0;
	
endmodule


// module for drawing scores. Uses a pre-built ROM
module Score_Draw(
  input clk, // CPU clk
  input[15:0] pixel_x, // current x coordinate
  input[15:0] pixel_y, // current y coordinate
  input[15:0] your_score, // P1 score
  input[15:0] their_score, // P2 score
  output draw // indicates score info to be drawn
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
  assign digit = (pixel_x < x1 + score_width) ? your_score[3:0] :
					  their_score[3:0];
  assign addr = {addr_y, digit, addr_x};
   
  // ceiling log2, used for address sizing
  function integer clog2;
    input integer value;
    begin 
      value = value-1;
      for (clog2=0; value>0; clog2=clog2+1)
        value = value>>1;
    end 
  endfunction
endmodule

// module for drawing win condition
module Win_Draw(
	input clk, // CPU clk
	input rst, // global reset
	input[15:0] pixel_x, // current x coordinate
	input[15:0] pixel_y, // current y coordinate
	input[1:0] game_state, // game state info
	input ready, // enable signal for updating sequential logic
	output[23:0] color // color to be drawn
   );
	
	// character info 
	parameter CHAR_WIDTH = 32;
	parameter CHAR_HEIGHT = 32;
	parameter addr_width = clog2(CHAR_WIDTH * CHAR_HEIGHT * 8);

	parameter x = 192; // upper left x
	parameter y = 10; // upper left y

	// ROMS
	wire[addr_width - 1:0] addr;
	wire P1_data, P2_data;
	P1_ROM p1rom(.clka(clk), .addra(addr), .douta(P1_data));
	P2_ROM p2rom(.clka(clk), .addra(addr), .douta(P2_data));
	
	// address logic
	wire[2:0] digit;
	wire[4:0] addr_x, addr_y;
	assign addr_x = (pixel_x < 639) ? pixel_x + 1 : 16'd0;
	assign addr_y = pixel_y - y;
	assign digit = (pixel_x - x) >> 5;
	assign addr = {addr_y, digit, addr_x};
	
	// rainbow colors
	reg[23:0] colors[7:0];
	initial begin
		colors[0] = 24'hFF0000;
		colors[1] = 24'hFF4500;
		colors[2] = 24'hFFFF00;
		colors[3] = 24'h00FF00;
		colors[4] = 24'h00FFFF;
		colors[5] = 24'h0000FF;
		colors[6] = 24'h4B0082;
		colors[7] = 24'hFF00FF;
	end
	
	// output logic
	reg[21:0] offset;
	always@(posedge clk) begin
		if(rst) offset <= 0;
		else if(ready) offset <= offset + 1;
	end
	
	assign color = ~(pixel_x >= x && pixel_x <= x + CHAR_WIDTH * 8 && 
			 pixel_y >= y && pixel_y <= y + CHAR_HEIGHT) ? 24'h000000 :
			(game_state == 2'b01 && P1_data) ? colors[(addr_y >> 1) + offset[21:19]] :
			(game_state == 2'b10 && P2_data) ? colors[(addr_y >> 1) + offset[21:19]]  :
			 24'd0;

    // ceiling log2, used for address sizing		
    function integer clog2;
    input integer value;
    begin 
      value = value-1;
      for (clog2=0; value>0; clog2=clog2+1)
        value = value>>1;
    end 
  endfunction
  
endmodule
