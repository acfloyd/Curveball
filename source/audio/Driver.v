module Driver(
	input clk,
	input rst,
	output cs,
	output rw,
	inout[15:0] data,
	output LED_0
    );
	 
	 parameter IDLE = 2'd0;
	 parameter SEND = 2'd2;
	 parameter INTERUPT = 2'd3;
	 parameter DONE = 1'd1;

	 reg[1:0] state, next_state;
	 
	 assign cs = (state == IDLE) || (state == SEND);
	 assign rw = ~(state == SEND);
	 assign data = (state == SEND) ? 16'h8008 : 16'dz;
	 
	 reg[26:0] wait_cnt;
	 reg[23:0] int_cnt;
	 reg interupted;
	 
	 assign LED_0 = ~(state == INTERUPT);
	 
	 always@(posedge clk) begin
		if(rst) begin
			state <= IDLE;
			wait_cnt <= 1;
			int_cnt <= 1;
			interupted <= 0;
			
		end
		else begin 
			state <= next_state;
			wait_cnt <= wait_cnt + 1;
			if(state == INTERUPT) begin 
				int_cnt <= int_cnt + 1;
				interupted <= 1;
			end else int_cnt <= 1;
		end
	 end
	 
	 always@(*) begin
		case(state)
			IDLE: if(wait_cnt == 0) next_state = SEND;
					else next_state = IDLE;		
					
			SEND: if(interupted) next_state = DONE;
					else next_state = INTERUPT;
			
			INTERUPT: if(int_cnt == 0) next_state = SEND;
			          else next_state = INTERUPT;
						 
			DONE: next_state = DONE;
		endcase
	end
endmodule
