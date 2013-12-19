module Audio_Shifter(
	input clk, // BIT_CLK
	input rst, // global reset
	input load, // load signal indicating input
	input[75:0] data, // data to be shifted
	output ready, // indicates shifter is ready for new cmd
	output SYNC, // SYNC FPGA pin
	output SDATA_OUT // SDATA_OUT FPGA pin
	);

	// state parameters
	parameter IDLE = 1'b0; // Idle state
	parameter SHIFTING = 1'b1; // sending state

	// state regs
	reg state;
	wire next_state;
	
	// counting values
	reg[7:0] bit_counter;
	wire[7:0] next_bit_counter;
	
	// shifting data
	reg[76:0] shifter;
	wire[76:0] next_shifter;

	assign ready = (state == IDLE);
	
	// next state logic
	assign next_state =  (state == IDLE && load) ? SHIFTING : 
			     (state == IDLE && !load) ? IDLE:
			     (state == SHIFTING && bit_counter == 8'd255) ? IDLE : SHIFTING;
				
	// update counter and shift data							
	assign next_bit_counter = (state == SHIFTING) ? bit_counter + 1 : 8'd0;
	assign next_shifter = (state == IDLE) ? {1'b0, data} : {shifter[75:0], 1'b0};

	// AC'97 controls
	assign SDATA_OUT = shifter[76];
	assign SYNC = (state == SHIFTING && bit_counter < 8'd16) ? 1'b1 : 1'b0;

	// update sequential logic
	always@(posedge clk) begin
		if(rst) begin
			state <= IDLE;
			shifter <= 64'd0;
			bit_counter <= 8'd0;
		end else begin
			state <= next_state;
			shifter <= next_shifter;
			bit_counter <= next_bit_counter;
		end
	end
endmodule
