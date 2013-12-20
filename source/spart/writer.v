//writer module
module writer(
    input clk,				//system clock
    input rst,				//system reset
    input write,			//write signal
    output tbr,				//transmit buffer ready
    input [7:0] data_in,		//data to transmit
    output txd				//serial output
    );
    
    //instantiate write_baud_generator                 
    write_baud_generator bg(.clk(clk), 
                            .rst(rst),
                            .txEnable(txEnable));
                      
    //instantiate transmitter           
    transmitter tx(.TxD(txd), 
                   .TBR(tbr), 
                   .trans_buff(data_in), 
                   .clk(clk), 
                   .rst(rst), 
                   .txEnable(txEnable), 
                   .trans_load(write));

endmodule
