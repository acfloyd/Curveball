module ps2_mouse(output [7:0] data, output TCP, t_clk, t_data, output r_ack, dav, inout MOUSE_CLOCK, MOUSE_DATA, input[1:0] addr, input clk, rst, io_cs);
  
  reg [8:0] pos_x, next_pos_x;
  reg [8:0] pos_y, next_pos_y;
  reg [2:0] status, next_status;
  wire [23:0] data_in;
  wire [7:0] byte_rec;
  
  ps2_tx tx(.TCP(TCP), .t_clk(t_clk), .t_data(t_data), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst));
  ps2_rx rx(.byte_rec(byte_rec), .received(rda), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .TCP(TCP));
  ps2_packets packets(.data_out(data_in), .r_dav(dav), .r_ack(r_ack), .data_in(byte_rec), .clk(clk), .rst(rst), .rda(rda));
  
  localparam top = 9'd0;
  localparam bottom = 9'd307;
  localparam right = 9'd409;
  localparam left = 9'd0;
  localparam middle_x = 9'd204;
  localparam middle_y = 9'd153;
  
  assign data = (addr == 2'b00) ? {5'd0, status} : 
                ((addr == 2'b01) ? pos_x :
                ((addr == 2'b10) ? pos_y : 8'd0));
  
  always@(posedge clk, posedge rst) begin
    if(rst) begin
      pos_x <= middle_x;
      pos_y <= middle_y;
      status <= 3'd0;
    end
    else begin
      pos_x <= next_pos_x;
      pos_y <= next_pos_y;
      status <= next_status;
    end
  end
  
  always@(*) begin
    next_pos_x = pos_x;
    next_pos_y = pos_y;
    next_status = status;
    if(dav) begin
      next_status = data_in[18:16];
      next_pos_x = pos_x + {data_in[15], data_in[15:8]};
      next_pos_y = pos_y + {data_in[7], data_in[7:0]};
      if(next_pos_x <= left)
        next_pos_x = left;
      else if(next_pos_x >= right)
        next_pos_x = right;
      if(next_pos_y <= top)
        next_pos_y = top;
      else if(next_pos_y >= bottom)
        next_pos_y = bottom;
    end
  end
  
endmodule


module ps2_packets(output reg [23:0] data_out, output reg r_dav, r_ack, input [7:0] data_in, input clk, rst, rda);
    
   reg [7:0] button_data, x_data, y_data;
   reg [1:0] state, next_state;
   reg ack, dav;
    
   localparam ACK = 2'd0, BUTTON = 2'd1, X_MOVE = 2'd2, Y_MOVE = 2'd3;
    
   always@(posedge clk, posedge rst) begin
     if(rst) begin
        state <= ACK;
        r_dav <= 1'b0;
        r_ack <= 1'b0;
        data_out <= 23'd0; 
     end
     else begin
        state <= next_state;
        r_dav <= dav;
        if(ack)
           r_ack <= ack;
        data_out <= {button_data, x_data, y_data};
     end 
   end
   
   always@(*) begin
      next_state = state;
      ack = 1'b0;
      dav = 1'b0;
      button_data = data_out[23:16];
      x_data = data_out[15:8];
      y_data = data_out[7:0];
      case(state)
         ACK: begin
            if(rda) begin
               if(data_in == 8'hfa) begin
                   ack = 1'b1;
                   next_state = BUTTON;
               end
            end
         end
         BUTTON: begin
            if(rda) begin
                button_data = data_in;
                next_state = X_MOVE;
            end
         end
         X_MOVE: begin
            if(rda) begin
                x_data = data_in;
                next_state = Y_MOVE;
            end
         end
         Y_MOVE: begin
            if(rda) begin
                y_data = data_in;
                next_state = BUTTON;
                dav = 1'b1;
            end
         end
      endcase    
   end
   
endmodule

module ps2_rx(output reg [7:0] byte_rec, output reg received, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, TCP);
  
  reg [9:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg MOUSE_CLOCK_REG;
  wire clk_low;
  
  localparam INIT = 4'd0, IDLE = 4'd1, START = 4'd2, STOP = 4'd12;
  
  assign clk_low = (~MOUSE_CLOCK) & MOUSE_CLOCK_REG;
  
  always@(posedge clk, posedge rst) begin
    if(rst) begin
      state <= INIT;
      shifter <= 8'd0;
      MOUSE_CLOCK_REG <= 1'b0;
    end
    else begin
      state <= next_state;
      shifter <= next_shift; 
      MOUSE_CLOCK_REG <= MOUSE_CLOCK;
    end
  end
   
  always@(*) begin
    next_state = state;
    next_shift = shifter;
    received = 1'b0;
    byte_rec = 7'd0;
    case(state)
      INIT: begin
        if(TCP)
          next_state = IDLE;  
      end
      IDLE: begin
        if(clk_low && !MOUSE_DATA)
          next_state = state + 4'd1;
      end
      STOP: begin
        received = 1'b1;
        next_state = IDLE;
        byte_rec = shifter[7:0];
      end
      default: begin
        if(clk_low) begin
          next_shift = {MOUSE_DATA, shifter[9:1]};
          next_state = state + 4'd1;  
        end
      end
    endcase
  end
  
endmodule

module ps2_tx(output reg TCP, t_clk, t_data, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst);
  
  reg [13:0] hold_clk, next_hold_clk;
  reg [8:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg m_clk, m_data, MOUSE_CLOCK_REG; 
  wire clk_low;
  wire [7:0] status_req;
  
  localparam INIT = 4'd0, SEND_REQ = 4'd1, SEND_START = 4'd2, SEND_DATA = 4'd3, STOP = 4'd12;
  
  assign MOUSE_CLOCK = (t_clk) ? m_clk : 1'bz;
  assign MOUSE_DATA = (t_data) ? m_data : 1'bz;
  assign status_req = 8'hf4;
  assign par = ~(^status_req);
  assign clk_low = (~MOUSE_CLOCK) & MOUSE_CLOCK_REG;
  
  always@(posedge clk, posedge rst) begin
    if(rst) begin
      state <= INIT;
      shifter <= 8'd0;
      hold_clk <= 14'd0;
      MOUSE_CLOCK_REG <= 1'b0;
      TCP <= 1'b0;
    end
    else begin
      state <= next_state; 
      shifter <= next_shift; 
      hold_clk <= next_hold_clk;
      MOUSE_CLOCK_REG <= MOUSE_CLOCK;
      if(state == STOP)
        TCP <= 1'b1;
    end
  end
  
  always@(*) begin
    t_clk = 1'b0;
    m_clk = 1'b1;
    t_data = 1'b0;
    m_data = 1'b1;
    next_state = state;
    next_shift = shifter;
    next_hold_clk = hold_clk;
    case(state)
      INIT: begin
        if(!rst && !TCP) begin
          next_state = SEND_REQ;
          next_shift = {par, status_req};
          next_hold_clk = 14'd10000;
        end 
      end
      SEND_REQ: begin
        t_clk = 1'b1;
        m_clk = 1'b0;
        next_hold_clk = hold_clk - 14'd1;
        if(next_hold_clk == 14'd0)
          next_state = state + 4'd1; 
      end
      SEND_START: begin
         t_data = 1'b1;
         m_data = 1'b0;
         if(clk_low)
           next_state = state + 4'd1;
      end 
      STOP: begin
         if(clk_low) begin
           next_state = INIT;
        end
      end
      default: begin
        t_data = 1'b1;
        m_data = shifter[0];
        if(clk_low) begin
          next_shift = {1'b1, shifter[8:1]};
          next_state = state + 4'd1;
        end
      end 
    endcase
  end
    
endmodule
