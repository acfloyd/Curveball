
`timescale 1 ns/1 ps

module display_plane_tb();
    
reg clk, rst, fifo_empty, fifo_full;
reg[18:0] Waddr;

wire fifo_wr, ready;
wire[19:0] ram_Raddr, ram_Waddr;

display_plane disp(clk, rst, fifo_empty, fifo_full, Waddr, ram_Raddr, ram_Waddr, fifo_wr, ready);

initial begin
    clk = 1'b0;
    forever #10 clk = ~clk;
end

always @(posedge clk) begin
    if (rst)
        Waddr <= 19'd0;
    else if (ready)
        Waddr <= (Waddr + 1) % 19'h4B000;
    else 
        Waddr <= Waddr;
end

initial begin
    rst = 1'b1;
    fifo_full = 1'b0;
    fifo_empty = 1'b1;
    #100;
    rst = 1'b0;
    #100;

    while (ready == 1'b1) begin
        #100;
    end

    #1000;
    fifo_empty = 1'b0;
    fifo_full = 1'b1;
    #1000;
    fifo_empty = 1'b1;
    fifo_full = 1'b0;
    #1000;
    fifo_empty = 1'b0;
    fifo_full = 1'b1;
    #1000;
    fifo_empty = 1'b1;
    fifo_full = 1'b0;
    #1000;

    while (ready == 1'b0) begin
        #100;
    end
    #1000;
    $stop;
end

endmodule
