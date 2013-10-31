module t_ps2_mouse();
  
  wire [9:0] data;
  wire RDA;
  wire MOUSE_CLOCK, MOUSE_DATA;
  reg clk, rst, io_cs, addr;
  
  ps2_mouse mouse(.data(data), .RDA(RDA), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .io_cs(io_cs), .addr(addr));
  
  initial begin
    rst = 1'b0;
    clk = 1'b1;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rst = 1'b1;
    #1
    rst = 1'b0;
  end
endmodule
