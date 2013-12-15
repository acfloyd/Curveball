module ps2_external(clk, rst, cs, addr_in, DataBus, rxd);

	input clk, rst, cs, rxd;
	input[1:0] addr_in;
	inout[15:0] DataBus;
	
	reg Drive_DataBus;
	
	wire rda;
	wire[7:0] data_in;
	wire[15:0] spart_data;
	reg [15:0] data_driven;

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

	assign DataBus = (Drive_DataBus) ? data_driven : 16'hzzzz;
	
	// Instantiate your driver here
	read_driver driver1( .clk(clk),
	                .rst(rst),
						 .rda(rda),
						 .data_in(data_in),
						 .addr(addr_in),
						 .data_out(spart_data)
					 );
					 
	reader spart1( .clk(clk),
                 .rst(rst),
					  .rda(rda),
					  .data_out(data_in),
					  .rxd(rxd)
					);

endmodule
