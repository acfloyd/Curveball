// Module applies appropriate reset sequence to audio controller after rst goes low

module Audio_Reset(
	input clk, // BIT_CLK 
	input rst, // global reset
	output AUDIO_RESET_Z, // AUDIO_RESET_Z FPGA pin
	output audio_ready // ready signal to begin work on audio codec
	);

	parameter START = 2'd0; // start state, sets Audio_RESET_Z high ~.5 s 
	parameter RESET = 2'd1; // reset state, sets Audio_RESET_Z low ~.5 s
	parameter HOLD = 2'd2; // finisehd state, leaves AudioRESET_Z high
	
	// state and wait counters
	reg[1:0] state, next_state;
	reg[23:0] wait_count;
	
	
	assign AUDIO_RESET_Z = (state != RESET); // set reset low in reset state, high otherwise
	assign audio_ready = (state == HOLD); // assert ready once reset sequence finished
	
	// sequential logic update
	always@(posedge clk) begin
		if(rst) begin
			state <= START;
			wait_count <= 1;
		end else begin
			state <= next_state;
			wait_count <= wait_count + 1;
		end
	end
	
	// next_state logic
	always@(*) begin
		case(state)
			START: if(wait_count == 0) next_state = RESET;
					 else next_state = START;
					 
			RESET: if(wait_count == 0) next_state = HOLD;
					 else next_state = RESET;
					 
			HOLD: next_state = HOLD;
		endcase
	end
endmodule
