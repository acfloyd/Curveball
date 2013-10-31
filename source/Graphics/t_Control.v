`timescale 1ns/1ns
module t_Control();
  //parameters
  parameter N=8;
  //outputs
  wire[15:0] pixel_x, pixel_y;
  wire[23:0] color;
  //inputs
  reg clk, rst;
  reg[23:0] paddle_1, paddle_2, ball, frame_score;
  //Wires and registers for testbench use
  reg[7:0] i;
  //Instantiate test object
  Control test(clk,rst,paddle_1,paddle_2,ball,frame_score,pixel_x,pixel_y,color);
  
  initial begin   //Assign initial values
    clk = 1'b0;
    rst = 1'b0;
    paddle_1 = 23'b0;
	paddle_2 = 23'b0;
	ball = 23'b0;
	frame_score = 23'b0;
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
