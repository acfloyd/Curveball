module proc_t();
	
	reg clk, rst;
   reg [10:0] count;
   integer i;

    reg [15:0] mem [0:31];
    initial begin
        $readmemh("text_files/individual_test_arithmetic_results", mem);
    end


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

		i = 0;
	end

	always @ (posedge clk) begin
		if (PROC.CONTROL.i6 == 16'he000) begin
			$stop;
		end
	end

	/*always @ (posedge clk) begin
	    if (PROC.DECODE.Reg.reg2.WrRegEn) begin
		   if (PROC.DECODE.Reg.reg2.DataIn != mem[i]) begin
			   $display("ERROR Line %d: \nExpected value: %b \nActual Value: %b", i, mem[i], PROC.DECODE.Reg.reg2.DataIn);
		   end
		   i = i + 1;
		end
	end*/
endmodule;
