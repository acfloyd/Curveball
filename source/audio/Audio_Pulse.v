module Audio_Pulse(input clk, 
						 input rst, 
						 input en,
						 input shft_ready,
						 output[63:0] shft_data, 
						 output shft_load);
						 
	parameter PULSE_HIGH = 1'b0;
	parameter PULSE_LOW = 1'b1;
	
	
	reg state, next_state;
	reg[9:0] pulse_counter;
	
	assign shft_load = (en && shft_ready && next_state != state) ? 1'b1 : 1'b0;
	assign shft_data = (next_state == PULSE_HIGH) ? 64'h9000_00000_00000_FF :
																  64'h9000_00000_00000_00;
	
	always@(posedge clk) begin
		if(rst) begin
			pulse_counter <= 10'd1;
			state <= PULSE_HIGH;
		end
		else if(en) begin
			pulse_counter <= pulse_counter + 1;
			state <= next_state;
		end
	end
	
	always@(*) begin
		case(state)
			PULSE_HIGH: if(pulse_counter == 0) next_state = PULSE_LOW;
							else next_state = PULSE_HIGH;
							
			PULSE_LOW: if(pulse_counter == 0) next_state = PULSE_HIGH;
						  else next_state = PULSE_LOW;
		endcase
	end

endmodule
