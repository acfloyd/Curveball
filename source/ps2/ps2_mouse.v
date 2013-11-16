module ps2_mouse(output [7:0] data, output TCP, t_clk, t_data, output m_ack, dav, stuck_state, inout MOUSE_CLOCK, MOUSE_DATA, input[1:0] addr, input clk, rst, io_cs);
  
  reg [8:0] pos_x, next_pos_x;
  reg [8:0] pos_y, next_pos_y;
  reg [2:0] status, next_status;
  wire [23:0] data_in;
  
  ps2_tx tx(.TCP(TCP), .t_clk(t_clk), .t_data(t_data), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst));
  ps2_rx rx(.data_out(data_in), .dav(dav), .stuck_state(stuck_state), .m_ack(m_ack), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .TCP(TCP));

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

module ps2_rx(output reg [23:0] data_out, output dav, output [3:0] stuck_state, output reg m_ack, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, TCP);
  
  reg [9:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg [1:0] count, next_count;
  reg ack, MOUSE_CLOCK_REG;
  wire clk_high;
  
  localparam INIT = 4'd0, IDLE = 4'd1, START = 4'd2, STOP = 4'd12;
  
  //assign dav = (count == 2'd3) ? 1'b1 : 1'b0; 
  assign clk_high = (~MOUSE_CLOCK_REG) & MOUSE_CLOCK;
  assign dav = ((state == STOP) && count == 2'd2)) ? 1'b1 : 1'b0;
  assign stuck_state = state;
  
  always@(posedge clk, posedge rst) begin
    if(rst) begin
      state <= INIT;
      shifter <= 8'd0;
      count <= 2'd0;
      data_out <= 24'd0;
      m_ack <= 1'b0;
      MOUSE_CLOCK_REG <= 1'b0;
      //dav <= 1'b0;
    end
    else begin
      state <= next_state;
      shifter <= next_shift; 
      count <= next_count;
      MOUSE_CLOCK_REG <= MOUSE_CLOCK;
      if(ack == 1'b1)
        m_ack <= ack;
      if(state == STOP) begin
        case(count)
          2'd0:
            data_out[23:16] <= shifter[7:0];
          2'd1:
            data_out[15:8] <= shifter[7:0];
          2'd2:
            data_out[7:0] <= shifter[7:0];
        endcase
      end
      /*if((state == STOP) && (count == 2'd2))
         dav <= 1'b1;
      else
         dav <= 1'b0;*/
    end
  end
   
  always@(*) begin
    next_state = state;
    next_shift = shifter;
    next_count = count;
    ack = 1'b0;
    case(state)
      INIT: begin
        if(TCP)
          next_state = IDLE;  
      end
      IDLE: begin
        if(clk_high && !MOUSE_DATA)
          next_state = state + 4'd1;
      end
      STOP: begin
        next_state = IDLE;
        if(count == 2'd2) begin
           next_count = 2'd0;
        end
        else   
           next_count = count + 2'd1;
        if(shifter[7:0] == 8'hfa) begin
          next_count = 2'd0;
          ack = 1'b1;
        end
      end
      default: begin
        if(clk_high) begin
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
