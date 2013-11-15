module mouse_display(output [18:0] wr_addr, output [2:0] wr_data, output reg [1:0] addr, input [7:0] data, input clk, rst, VGA_ready);

   reg [7:0] x_loc, next_x_loc, y_loc, next_y_loc, status, next_status;
   reg [1:0] state, next_state;
   reg [15:0] x, y;
   wire [15:0] next_x, next_y;
   wire [2:0] color;
	
   localparam read_status = 2'd0, read_x = 2'd1, read_y = 2'd2;
   
   assign wr_addr = x + (y << 7) * 5;
   assign wr_data = ((x == x_loc) && (y == y_loc)) ? color : 3'd0;
   assign color = ((status[2:0] == 3'b001)) ? 3'd3 : 3'd6;
	
   assign next_x = (VGA_ready) ? 
							(x == 16'd640) ? 
								16'b0 : x + 1 
							: x;
	assign next_y = (VGA_ready) ? 
							(x == 16'd640) ? 
								(y == 16'd480) ? 
									16'b0 : y + 1 
								: y 
							: y;
   
   always@(posedge clk, posedge rst) begin
      if(rst) begin
			x <= 16'b0;
			y <= 16'b0;
		end
		else begin
			x <= next_x;
			y <= next_y;
		end   
   end
   
   always@(posedge clk, posedge rst) begin
      if(rst) begin
         status <= 8'd0;
         x_loc <= 8'd0;
         y_loc <= 8'd0;
      end
      else begin
         x_loc <= next_x_loc;
         y_loc <= next_y_loc;
         status <= next_status;
			state <= next_state;
      end 
   end

   always@(*) begin
       next_x_loc = x_loc;
       next_y_loc = y_loc;
       next_status = status;
       addr = 2'd0;
       case(state)
          read_status: begin
             addr = 2'd0;
             next_status = data; 
             next_state = read_x; 
          end
          read_x: begin
             addr = 2'd1;
             next_x_loc = data; 
             next_state = read_y; 
          end
          read_y: begin
             addr = 2'd2;
             next_y_loc = data; 
             next_state = read_status; 
          end
       endcase
   end
   
endmodule 