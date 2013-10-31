module ps2_mouse(output [9:0] data, output RDA, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst, io_cs, addr);

  
endmodule 

module ps2_tx(output data, output TCP, inout MOUSE_CLOCK, MOUSE_DATA, input clk, rst);
  
  reg [7:0] shifter, next_shift;
  reg [3:0] state, next_state;
  reg m_clk, t_clk, m_data, t_data, clk_low;
  wire [7:0] status_req;
  
  localparam INIT = 4'd0, SEND_START = 4'd1, SEND_DATA = 4'd2, SEND_PAR = 4'd11;
  
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
      SEND_PAR: begin
         t_data = 1'b1;
         m_data = shifter[0];
         if(clk_low)
           next_state = INIT;
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