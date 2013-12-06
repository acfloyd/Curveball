module Audio_Reset(input clk, input rst, output AUDIO_RESET_Z, output audio_ready);

	parameter START = 2'd0;
	parameter RESET = 2'd1;
	parameter HOLD = 2'd2;
	
	reg[1:0] state, next_state;
	reg[23:0] wait_count;
	
	assign AUDIO_RESET_Z = (state != RESET);
	assign audio_ready = (state == HOLD);
	
	always@(posedge clk) begin
		if(rst) begin
			state <= START;
			wait_count <= 1;
		end else begin
			state <= next_state;
			wait_count <= wait_count + 1;
		end
	end
	
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
