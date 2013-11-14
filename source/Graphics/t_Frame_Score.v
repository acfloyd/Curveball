`timescale 1ns/1ns

module t_Frame_Score;
  
  reg clk, rst;
  reg[15:0] pixel_x, pixel_y, your_score, their_score, game_state;
  wire[2:0] color;
  
  wire[23:0] rgb;
  
  integer file, rc;
  
  Frame_Score fs(.clk(clk), .rst(rst), .pixel_x(pixel_x), .pixel_y(pixel_y), .your_score(your_score), .their_score(their_score), .game_state(game_state), .color(color));
  
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
  end
  
  // handle color
  assign rgb = (color == 1) ? 24'h00FF00 : (color == 4) ? 24'h0000FF : 24'h000000;
  
  // file ouput
  initial begin
    file = $fopen("image", "w");
    if(file == 0)
      $display("error");
  end
  
  always@(pixel_x)
    $fwrite(file, "%x\n", rgb);
  
  // ending logic
  always@(pixel_y)
    if(pixel_y >= 480) begin
      $fclose(file);
      $stop;
    end
  
  // init other inputs to nothing
  initial begin
    your_score = 3;
    their_score = 4;
    game_state = 0;
  end
  
endmodule




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