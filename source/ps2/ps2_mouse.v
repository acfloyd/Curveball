module ps2_mouse(output [9:0] data_out, output RDA, inout MOUSE_CLOCK, MOUSE_DATA, input [23:0] data_in, input clk, rst, io_cs, addr, dav);

  reg [7:0] status, x_move, y_move;
  wire [7:0] next_status, next_x_move, next_y_move;
  
  assign next_status = (dav) ? data_in[23:16] : 8'd0;
  assign next_x_move = (dav) ? data_in[15:8] : 8'd0;
  assign next_y_move = (dav) ? data_in[7:0] : 8'd0;
  
  always@(posedge clk, posedge rst) begin
    if(rst) begin
      status <= 8'd0;
      x_move <= 8'd0;
      y_move <= 8'd0;
    end
    else begin
      
    end
  end
  
endmodule 

module ps2_rx(output [23:0] data, output dav, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, TCP);
  
  reg [7:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg [1:0] count, next_count;
  reg m_clk;
  
  localparam INIT = 4'd0, IDLE = 4'd1, START = 4'd2, STOP = 4'd11;
  
  assign data[23:16] = (count == 2'd1) ? shifter : 8'd0;
  assign data[15:8] = (count == 2'd2) ? shifter : 8'd0;
  assign data[7:0] = (count == 2'd3) ? shifter : 8'd0;
  assign dav = (count == 2'd3) ? 1'b1 : 1'b0; 
  
  always@(posedge MOUSE_CLOCK, negedge MOUSE_CLOCK) begin
    if(MOUSE_CLOCK)
      m_clk <= 1'b1;
    else
      m_clk <= 1'b0;
  end
  
  always@(posedge clk, posedge rst) begin
    if(rst)
      state <= INIT;
    else begin
      state <= next_state;
      shifter <= next_shift; 
      count <= next_count;   
    end
  end
  
  always@(*) begin
    next_state = state;
    next_shift = shifter;
    next_count = count;
    case(state)
      INIT: begin
        if(TCP)
          next_state = IDLE;  
      end
      IDLE: begin
        if(m_clk && !MOUSE_DATA)
          next_state = START;
      end
      STOP: begin
        next_state = IDLE; 
        next_count = count + 1'd1;
      end
      default: begin
        if(m_clk) begin
          next_shift = {shifter[6:0], MOUSE_DATA};
          next_state = state + 4'd1;  
        end
      end
    endcase
  end
  
endmodule

module ps2_tx(output reg TCP, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst);
  
  reg [7:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg m_clk, t_clk, m_data, t_data, clk_low;
  wire [7:0] status_req;
  
  localparam INIT = 4'd0, SEND_START = 4'd1, SEND_DATA = 4'd2, STOP = 4'd11;
  
  assign MOUSE_CLOCK = (t_clk) ? m_clk : 1'bz;
  assign MOUSE_DATA = (t_data) ? m_data : 1'bz;
  assign status_req = 8'hf4;
  assign par = ~(^status_req);
  
  always@(posedge MOUSE_CLOCK, negedge MOUSE_CLOCK) begin
    if(MOUSE_CLOCK)
      clk_low <= 1'b0;
    else
      clk_low <= 1'b1;
  end
  
  always@(posedge clk, posedge rst) begin
    if(rst)
      state <= INIT;
    else begin
      state <= next_state; 
      shifter <= next_shift; 
    end
  end
  
  always@(*) begin
    t_clk = 1'b0;
    m_clk = 1'b1;
    t_data = 1'b0;
    m_data = 1'b1;
    next_state = state;
    next_shift = shifter;
    TCP = 1'b0;
    case(state)
      INIT: begin
        if(!rst) begin
          next_state = SEND_START;
          t_clk = 1'b1;
          m_clk = 1'b0; 
          next_shift = {par, status_req};
        end 
      end
      SEND_START: begin
         t_data = 1'b1;
         m_data = 1'b0;
      end 
      STOP: begin
         t_data = 1'b1;
         m_data = shifter[0];
         if(clk_low) begin
           next_state = INIT;
           TCP = 1'b1;
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
