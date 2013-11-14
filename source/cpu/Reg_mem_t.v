module Reg_mem_t();
    
    reg clk, rst;
	reg WrRegEn;
	reg [2:0] ReadSelS, ReadSelT, WrSel;
	reg [15:0] DataIn;
	wire [15:0] Rs, Rt;
	integer i;
	Reg_Mem DUT(.clk(clk), .rst(rst), .DataIn(DataIn), .ReadSelS(ReadSelS), 
		.ReadSelT(ReadSelT), .WrSel(WrSel), .WrRegEn(WrRegEn), .Rs(Rs), .Rt(Rt));
    
	initial begin
    	clk = 0;
    	forever #2 clk = ~clk;
    end

	initial begin
		rst = 1;
		#2 rst = 0;
		#1;
		for(i = 0; i<8; i = i + 1) begin
			if (i % 2 == 1) begin
				WrRegEn = 1;
			end
			else begin
				WrRegEn = 0;
			end
			WrSel = i;
			DataIn = i;
			#4;
		end
      #4;
      
      for(i = 7; i>=0; i = i-1) begin
         ReadSelT = i;
         ReadSelS = i;
         #4;
      
      end
		$finish;
	end  


endmodule
