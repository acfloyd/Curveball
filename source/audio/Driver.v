module Driver(
	input clk,
	input rst,
	output cs,
	output rw,
	inout[15:0] data
    );
	 
	 parameter IDLE = 2'd0;
	 parameter SEND = 2'd1;
	 parameter DONE = 2'd3;

	 reg[1:0] state, next_state;
	 
	 assign cs = 1'b1;
	 assign rw = ~(state == SEND);
	 assign data = (state == SEND) ? 16'h8008 : 16'dz;
	 
	 always@(posedge clk) begin
		if(rst) begin
			state <= IDLE;
		end
		else begin 
			state <= next_state;
		end
	 end
	 
	 always@(*) begin
		case(state)
			IDLE: if(data) next_state = SEND;
					else next_state = IDLE;
			SEND: next_state = DONE;
			
			DONE: next_state = DONE;
		endcase
	end
endmodule
