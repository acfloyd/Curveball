module t_ps2_mouse();
  
  wire [7:0] data, data_init, first_data, second_data, third_data, fourth_data;
  wire RDA;
  wire MOUSE_CLOCK, MOUSE_DATA;
  wire [7:0] x_loc, y_loc;
  wire [2:0] status;
  reg [1:0] addr;
  reg clk, m_clk, rst, io_cs, m_data;
  integer i;
  wire [2:0] status_bits;
  
  ps2_mouse mouse(.data(data), .status_bits(status_bits), .done(done), .TCP(TCP), .t_clk(t_clk), .t_data(t_data), .r_ack(r_ack), .dav(dav), .MOUSE_CLOCK(MOUSE_CLOCK), .MOUSE_DATA(MOUSE_DATA), .clk(clk), .rst(rst), .io_cs(io_cs), .addr(addr));
  
  assign MOUSE_CLOCK = (t_clk) ? 1'bz : m_clk;
  assign MOUSE_DATA = (t_data) ? 1'bz : m_data;
  assign data_init = 8'hfa;
  assign first_data = 8'hab;
  assign second_data = 8'hbc;
  assign third_data = 8'hcd;
  assign fourth_data = 8'hde;
  assign status = (addr == 2'b00) ? data[2:0] : 3'd0;
  assign x_loc = (addr == 2'b01) ? data : 8'd0;
  assign y_loc = (addr == 2'b10) ? data : 8'd0;
  
  initial begin
    rst = 1'b0;
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    m_clk = 1'b0;
    forever #29940 m_clk = ~m_clk;
  end
  
  initial begin
    rst = 1'b1;
    #1
    rst = 1'b0;
    #1
    @(done);
    m_data = 1'b0;
    @(TCP);
    #29940
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = data_init[i];
    end
    #59880
    m_data = ~(^data_init);
    #59880
    m_data = 1'b1;
    @(r_ack);
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = first_data[i];
    end
    #59880
    m_data = ~(^first_data);
    #59880
    m_data = 1'b1;
    #59880
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = second_data[i];
    end
    #59880
    m_data = ~(^second_data);
    #59880
    m_data = 1'b1;
    #59880
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = third_data[i];
    end
    #59880
    m_data = ~(^third_data);
    #59880
    m_data = 1'b1;
    #59880
    m_data = 1'b1;
    @(dav);
    #10
    addr = 2'b00;
    #10
    addr = 2'b01;
    #10
    addr = 2'b10;
    #59880
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = third_data[i];
    end
    #59880
    m_data = ~(^third_data);
    #59880
    m_data = 1'b1;
    #59880
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = second_data[i];
    end
    #59880
    m_data = ~(^second_data);
    #59880
    m_data = 1'b1;
    #59880
    m_data = 1'b0;
    for(i = 0; i < 8; i = i + 1) begin
        #59880
        m_data = first_data[i];
    end
    #59880
    m_data = ~(^first_data);
    #59880
    m_data = 1'b1;
    @(dav);
    #10
    addr = 2'b00;
    #10
    addr = 2'b01;
    #10
    addr = 2'b10;
  end
endmodule
