module t_ps2_mouse();
  
  wire [23:0] data;
  wire RDA;
  wire MOUSE_CLOCK, MOUSE_DATA;
  reg clk, mouse_clk, rst, io_cs, addr;
   
  ps2_mouse mouse(.data_out(data), .RDA(RDA), .t_clk(t_clk), .m_ack(m_ack), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .io_cs(io_cs), .addr(addr));
  
  assign MOUSE_CLOCK = (t_clk) ? 1'bz : mouse_clk;
  
  initial begin
    rst = 1'b0;
    clk = 1'b0;
    mouse_clk = 1'b0;
    forever #5 clk = ~clk;
    forever #30 mouse_clk = ~mouse_clk;
  end
  
  initial begin
    rst = 1'b1;
    #1
    rst = 1'b0;
  end
endmodule
