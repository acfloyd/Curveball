//reader module
module reader(
    input clk,				//system clock
    input rst,				//system reset
    output rda,				//receive data available
    output [7:0] data_out,		//data received
    input rxd				//input serial data
);

    //instantiate read_baud_generator                     
    read_baud_generator bg(.clk(clk), 
                           .rst(rst), 
                           .rxEnable(rxEnable));
                     
    //instantiating receiver  
    receiver rx(.rec_buff(data_out), 
                .RDA(rda),
                .clk(clk), 
                .rst(rst), 
                .RxD(rxd), 
                .rxEnable(rxEnable));

endmodule

