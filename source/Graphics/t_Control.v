`timescale 1ns/1ns
module t_Control();
	//parameters
	parameter N=8;
	//outputs
	wire[15:0] pixel_x, pixel_y;
	wire[2:0] color;
	wire[18:0] address;
	//inputs
	reg clk, rst, VGA_ready;
	reg[2:0] paddle_1, paddle_2, ball, frame_score;
	//Wires and registers for testbench use
	reg[7:0] i;
	//Instantiate test object
	Control test(clk,rst,paddle_1,paddle_2,ball,frame_score, VGA_ready,pixel_x,pixel_y,color, address);

	initial begin   //Assign initial values
		clk = 1'b0;
		rst = 1'b1;
		paddle_1 = 3'b0;
		paddle_2 = 3'b0;
		ball = 3'b0;
		frame_score = 3'b0;
		VGA_ready = 1'b0;
	end
	
	initial forever #5 clk = ~clk;

	initial begin
	  #100 rst = 1'b0;
	  #1000 paddle_1 = 3'b001;
	  #1000 ball = 3'b010;
	  #1000 paddle_1 = 3'b0;
	  #1000 frame_score = 3'b100;
	  #1000 ball = 3'b0;
	  #1000 paddle_2 = 3'b111;
	  #1000 frame_score = 3'b0;
		#10000 $stop;
	end  

endmodule
