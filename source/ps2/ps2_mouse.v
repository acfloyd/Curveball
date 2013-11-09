module ps2_mouse(output [7:0] data, output reg t_clk, m_ack, inout MOUSE_CLOCK, MOUSE_DATA, input[1:0] addr, input clk, rst, io_cs);

  ps2_tx tx(.TCP(TCP), .t_clk(t_clk), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst));
  ps2_rx rx(.data(data_out), .dav(dav), .m_ack(m_ack), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .TCP(TCP));
  
  reg [9:0] pos_x, next_pos_x;
  reg [8:0] pos_y, next_pos_y;
  reg [2:0] status, next_status;
  wire [23:0] data_in;
  
  localparam top = 9'd85;
  localparam bottom = 9'd393;
  localparam right = 10'd524;
  localparam left = 10'd114;
  localparam middle_x = 10'd319;
  localparam middle_y = 9'd239;
  
  assign data_in = data_out;
  assign data = (addr == 2'b00) ? status : 
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
      next_pos_x = pos_x + data_in[15:8];
      next_pos_y = pos_y + data_in[7:0];
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

module ps2_rx(output reg [23:0] data, output dav, output reg m_ack, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, TCP);
  
  reg [7:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg [1:0] count, next_count;
  reg ack, MOUSE_CLOCK_REG;
  wire clk_high;
  
  localparam INIT = 4'd0, IDLE = 4'd1, START = 4'd2, STOP = 4'd11;
  
  assign dav = (count == 2'd3) ? 1'b1 : 1'b0; 
  assign clk_high = (~MOUSE_CLOCK_REG) & MOUSE_CLOCK;
  
  always@(posedge clk, posedge rst) begin
    if(rst) begin
      state <= INIT;
      shifter <= 8'd0;
      count <= 2'd0;
      data <= 24'd0;
      m_ack <= 1'b0;
      MOUSE_CLOCK_REG <= 1'b0;
    end
    else begin
      state <= next_state;
      shifter <= next_shift; 
      count <= next_count;
      MOUSE_CLOCK_REG <= MOUSE_CLOCK;
      if(ack == 1'b1)
        m_ack <= ack;
      if(state == STOP) begin
        case(next_count)
          2'd1:
            data[23:16] <= shifter;
          2'd2:
            data[15:8] <= shifter;
          2'd3:
            data[7:0] <= shifter;
        endcase 
      end
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
        next_count = count + 1'd1;
        if(shifter == 8'hfa) begin
          next_count = 1'd0;
          ack = 1'b1;
        end
      end
      default: begin
        if(clk_high) begin
          next_shift = {shifter[6:0], MOUSE_DATA};
          next_state = state + 4'd1;  
        end
      end
    endcase
  end
  
endmodule

module ps2_tx(output reg TCP, t_clk, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst);
  
  reg [13:0] hold_clk, next_hold_clk;
  reg [7:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg m_clk, m_data, t_data, MOUSE_CLOCK_REG, t_cmp; 
  wire clk_low;
  wire [7:0] status_req;
  
  localparam INIT = 4'd0, SEND_REQ = 4'd1, SEND_START = 4'd2, SEND_DATA = 4'd3, STOP = 4'd11;
  
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
      if(t_cmp == 1'b1)
        TCP <= t_cmp;
    end
  end
  
  always@(*) begin
    t_clk = 1'b0;
    m_clk = 1'b1;
    t_data = 1'b0;
    m_data = 1'b1;
    next_state = state;
    next_shift = shifter;
    t_cmp = 1'b0;
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
         t_data = 1'b1;
         m_data = shifter[0];
         if(clk_low) begin
           next_state = INIT;
           t_cmp = 1'b1;
        end
      end
      default: begin
        t_data = 1'b1;
        m_data = shifter[0];
        if(clk_low) begin
          next_shift = {1'b1, shifter[7:1]};
          next_state = state + 4'd1;
        end
      end 
    endcase
  end
    
endmodule
