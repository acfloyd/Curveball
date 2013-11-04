module WriteBackReg(clk, rst, stall, WriteBackIn, WriteBackOut);
input clk, rst, stall;
input[15:0] WriteBackIn;

output reg[15:0] WriteBackOut;

always @(posedge clk, posedge rst) begin
	if (rst) begin
		WriteBackOut = 16'd0;
	end
	else if (stall) begin
		WriteBackOut = WriteBackOut;
	end
	else begin
		WriteBackOut = WriteBackIn;
	end
end

endmodule