/***********************
module t_Frame_Score();
  //parameters
  parameter N=8;
  //outputs
  wire[23:0] color;
  //inputs
  reg clk, rst;
  reg[15:0] your_score, their_score, game_state, pixel_x, pixel_y;
  //Wires and registers for testbench use
  reg[7:0] i;
  //Instantiate test object
  Frame_Score test(clk,rst,your_score,their_score,game_state,pixel_x,pixel_y,color);
  
  initial begin   //Assign initial values
    clk = 1'b0;
    rst = 1'b0;
    your_score = 15'b0;
	their_score = 15'b0;
	game_state = 15'b0;
  end
  
  initial begin
    for (i = 0; i < 16 ; i = i + 1) begin
      #10
      $display("%d + %d +%d = %d, %d",A,B,C,Y,(A+B+C));
      A=$random;
      B=$random;
      C=$random;
    end
    #10 $stop;
  end  
 
endmodule
*************************/

`timescale 1ns/1ns

module t_Paddle_2;
  
  reg clk, rst;
  reg[15:0] pixel_x, pixel_y, x_loc, y_loc, x_loc2, y_loc2;
  wire[2:0] color, color2, color_out;
  
  reg[23:0] rgb;
  
  integer file, rc;
  
  Paddle_2 p1(clk, rst, x_loc, y_loc, pixel_x, pixel_y, color);
//  Paddle_1_test p2(clk, rst, x_loc2, y_loc2, pixel_x, pixel_y, color2);

  
  // clk logic
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
  
  // pixel x/y logic
  initial begin
    pixel_x = 0;
    pixel_y = 0;
    
    while(pixel_y <= 479) begin
      #10
      pixel_x = pixel_x + 1;
      if(pixel_x == 640) begin
        pixel_x = 0;
        pixel_y = pixel_y + 1;
      end
    end
    pixel_y = 480;
  end
  
  // color decode
  localparam[23:0] BLACK = 24'h000000;
  localparam[23:0] GREEN = 24'h00FF00;
  localparam[23:0] BLUE = 24'h0000FF;
  localparam[23:0] RED = 24'hFF0000;
  localparam[23:0] TEAL = 24'h66FFFF;
  localparam[23:0] GRAY = 24'hD3D3D3;
  localparam[23:0] WHITE = 24'hFFFFFF;
  localparam[23:0] GWHITE = 24'hCCFF99;

  assign color_out = (color != BLACK) ? color : color2;

  // color value decode
  always @(*) begin
    case(color)
      3'd0: rgb = BLACK;
      3'd1: rgb = GREEN;
      3'd2: rgb = BLUE;
      3'd3: rgb = RED;
      3'd4: rgb = TEAL;
      3'd5: rgb = GRAY;
      3'd6: rgb = WHITE;
      3'd7: rgb = GWHITE;
    endcase
  end
  
  // file ouput
  initial begin
    file = $fopen("image", "w");
    if(file == 0)
      $display("error");
  end
  
  always@(pixel_x) begin
    $fwrite(file, "%x\n", rgb);
    //$display("pixel_x: %d, pixel_y: %d, val: %x, x_diff: %d, y_diff: %d\n", pixel_x, pixel_y, 
    //        rgb, p1.x_diff, p1.y_diff);
  end
  
  // ending logic
  always@(pixel_y)
    if(pixel_y >= 480) begin
      $fclose(file);
      $stop;
    end
  
  // init other inputs to nothing
  initial begin
    x_loc = 16'd100;
    y_loc = 16'd100;
    x_loc2 = 16'd150;
    y_loc2 = 16'd150;
  end
  
endmodule

