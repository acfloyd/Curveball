`timescale 1ns/1ns
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
