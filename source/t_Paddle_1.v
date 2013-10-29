`timescale 1ns/1ns
module t_Paddle_1();
  //parameters
  parameter N=8;
  //outputs
  wire[23:0] color;
  //inputs
  reg clk, rst;
  reg[15:0] x_loc,y_loc,pixel_x,pixel_y;
  //Wires and registers for testbench use
  reg[7:0] i;
  //Instantiate test object
  Paddle_1 test(clk,rst,x_loc,y_loc,pixel_x,pixel_y,color);
  
  initial begin   //Assign initial values
    clk = 1'b0;
    rst = 1'b0;
    x_loc = 16'b0;
	y_loc = 16'b0;
	x_pixel = 16'b0;
	y_pixel = 16'b0;
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
