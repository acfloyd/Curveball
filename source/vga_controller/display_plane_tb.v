
`timescale 1 ns/1 ps

module display_plane_tb();
    
reg clk, rst, fifo_empty, fifo_full;
reg[23:0] in_pixel;

wire fifo_wr;
wire[12:0] rom_addr;
wire[23:0] out_pixel;

display_pane_2 disp(clk, rst, fifo_full, in_pixel, fifo_wr, rom_addr, out_pixel);

initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end

initial begin
    rst = 1'b1;
    fifo_full = 1'b0;
    fifo_empty = 1'b1;
    #100;
    rst = 1'b0;
    #10000;
    fifo_empty = 1'b0;
    fifo_full = 1'b1;
    #1000;
    fifo_empty = 1'b1;
    fifo_full = 1'b0;
    #10000;
    fifo_empty = 1'b0;
    fifo_full = 1'b1;
    #1000;
    fifo_empty = 1'b1;
    fifo_full = 1'b0;
    #1000000;
    $stop;
end

endmodule