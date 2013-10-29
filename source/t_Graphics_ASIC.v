`timescale 1ns/1ns
module t_Graphics_ASIC();
  //parameters
  parameter N=8;
  //outputs
  wire[23:0] color;
  wire[18:0] frame_address;
  //inputs
  reg clk, rst, chipselect;
  reg[15:0] databus;
  reg[3:0] data_address;
  //Wires and registers for testbench use
  reg[7:0] i;
  //Instantiate test object
  Graphics_ASIC test(clk,rst,chipselect,databus,data_address,color,frame_address);
  
  initial begin   //Assign initial values
    clk = 1'b0;
    rst = 1'b0;
    chipselect = 1'b0;
	databus = 16'b0;
	data_address = 4'b0;
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
