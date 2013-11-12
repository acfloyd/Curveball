module t_ps2_mouse();
  
  wire [7:0] data;
  wire RDA;
  wire MOUSE_CLOCK, MOUSE_DATA;
  reg [1:0] addr;
  reg clk, m_clk, rst, io_cs, m_data;
   
  ps2_mouse mouse(.data(data), .t_clk(t_clk), .t_data(t_data), .m_ack(m_ack), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .io_cs(io_cs), .addr(addr));
  
  assign MOUSE_CLOCK = (t_clk) ? 1'bz : m_clk;
  assign MOUSE_DATA = (t_data) ? 1'bz : m_data;
  
  initial begin
    rst = 1'b0;
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    m_clk = 1'b0;
    forever #30 m_clk = ~m_clk;
  end
  
  initial begin
    rst = 1'b1;
    #1
    rst = 1'b0;
    #100750
    m_data = 1'b0;
    #60
    m_data = 1'b0;
    #60
    m_data = 1'b1;
    #60
    m_data = 1'b0;
    #60
    m_data = 1'b1;
    #60
    m_data = 1'b1;
    #60
    m_data = 1'b1;
    #60
    m_data = 1'b1;
    #60
    m_data = 1'b1;
  end
endmodule
