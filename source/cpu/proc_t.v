module proc_t();
	
	reg clk, rst;
   reg [10:0] count;
	proc PROC(.clk(clk), .rst(rst));
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	always @ (posedge clk, posedge rst) begin
	       if(rst)
	          count = 0;    
	       else
	          count = count + 1;
	end

	initial begin
		rst = 1;
		#2 rst = 0;
		$monitor(" Time: %g => \n reg0: %d\n reg1: %d\n reg2: %d\n reg3: %d\n reg4: %d\n reg5: %d\n reg6: %d\n reg7: %d", 
			$time,
			PROC.DECODE.Reg.reg0.DataOut,
			PROC.DECODE.Reg.reg1.DataOut,
			PROC.DECODE.Reg.reg2.DataOut,
			PROC.DECODE.Reg.reg3.DataOut,
			PROC.DECODE.Reg.reg4.DataOut,
			PROC.DECODE.Reg.reg5.DataOut,
			PROC.DECODE.Reg.reg6.DataOut,
			PROC.DECODE.Reg.reg7.DataOut);
		#200;
		$stop;
	end
endmodule;
