`timescale 1 ns/1 ps

module top_level_tb();
    
reg clk, rst;
wire vsync, vgaclk, comp_sync, blank, hsync;
wire[23:0] pixel_g, pixel_r, pixel_b;

top_level tb(vsync, rst, vgaclk, comp_sync, blank, hsync, clk, pixel_g, pixel_r, pixel_b);

initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end

initial begin
    rst = 1'b1;
    #100;
    rst = 1'b0;
    #10000;
    $stop;
end

endmodule