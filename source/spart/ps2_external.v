//module that wraps the functionality of the read and read_driver modules
module ps2_external(
	input clk, rst, cs, rxd;			//clk, rst, and chip select signals
	input[1:0] addr_in;				//read address from read_driver	
	inout[15:0] DataBus;				//input/output databus
);
	
	reg Drive_DataBus;				//control tristate databus
	wire rda;					//receive data available
	wire[7:0] data_in;				//data read from the receiver
	wire[15:0] spart_data;				//data read from receiver
	reg [15:0] data_driven;				//data driven onto databus

	//databus logic
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			Drive_DataBus <= 1'b0;
			data_driven <= 16'd0;
		end
		else if (cs) begin
			Drive_DataBus <= 1'b1;
			data_driven <= spart_data;
		end
		else begin
			Drive_DataBus <= 1'b0;
			data_driven <= data_driven;
		end
	end

	//write to or disconnect databus
	assign DataBus = (Drive_DataBus) ? data_driven : 16'hzzzz;
	
	//instantiate read_driver module
	read_driver driver1(.clk(clk),
	                    .rst(rst),
			    .rda(rda),
			    .data_in(data_in),
			    .addr(addr_in),
			    .data_out(spart_data));
				
	//instantiating read module	 
	reader spart1(.clk(clk),
                      .rst(rst),
		      .rda(rda),
		      .data_out(data_in),
		      .rxd(rxd));

endmodule
