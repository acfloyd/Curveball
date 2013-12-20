//generators transmit signals at baud rate
module write_baud_generator(
	input rst, clk;				// inputs 
	output reg txEnable;			//transmit enable signal
    reg [15:0] counter;					// counter to decrement
    reg [3:0] txCount;					// count for baud rate signal
	 reg rxEnable;
	 
	 // sequential logic
    always@(posedge clk, posedge rst) begin
		 // reset signals
       if(rst) begin
           counter <= 16'd122;//1301;
           txCount <= 4'd15;
           txEnable <= 1'b0;
           rxEnable <= 1'b0;
       end
		 
       else begin 
			 if(counter == 16'd0) begin
				  // output a baud rate signal every 16 samples
              if(txCount == 4'd0) begin
                 txCount <= 4'd15;
                 txEnable <= 1'b1;
              end
				  
				  // decrement baud rate signal counter
              else begin
                 txCount <= txCount - 4'd1;
                 txEnable <= 1'b0; 
              end
				  
				  // send sampling signal
              rxEnable <= 1'b1;
              counter <= 16'd122;
          end
			 
			 // counter hasn't reached 0
          else if(counter != 16'd0) begin
             rxEnable <= 1'b0;
             txEnable <= 1'b0;
             counter <= counter - 16'd1; 
          end
       end
    end
        
endmodule
