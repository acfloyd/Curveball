module Audio_Shifter(input clk, input rst, input load, input[63:0] data, 
							output ready, output SYNC, output SDATA_OUT);

	parameter IDLE = 1'b0;
	parameter SHIFTING = 1'b1;

	reg state;
	wire next_state;
	reg[7:0] bit_counter;
	wire[7:0] next_bit_counter;
	reg[64:0] shifter;
	wire[64:0] next_shifter;

	assign ready = (state == IDLE);
	assign next_state =  (state == IDLE && load) ? SHIFTING : 
								(state == IDLE && !load) ? IDLE:
								(state == SHIFTING && bit_counter == 8'd255) ? IDLE : SHIFTING;
								
	assign next_bit_counter = (state == SHIFTING) ? bit_counter + 1 : 8'd0;
	assign next_shifter = (state == IDLE) ? {1'b0, data} : {shifter[63:0], 1'b0};

	// AC97 controls
	assign SDATA_OUT = shifter[64];
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