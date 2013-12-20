// writer_driver module
module write_driver(
    input clk,						//system clock
    input rst,						//system reset
    input dav,						//data available
    input [15:0] data_in,				//data from ps2_mouse
    output reg [1:0] addr,				//address to read write data from
    input tbr,						//transmit buffer ready
    output reg [7:0] data_out,				//data to write 
    output reg write					//write signal
);
	 
	 reg [3:0] state, next_state;			//state variables
	 reg [1:0] status, next_status;			//status from ps2_mouse
    
    	 //state parameters
	 localparam WAIT = 4'h0;
	 localparam WRITE_STATUS_1 = 4'h1;
	 localparam WRITE_STATUS_2 = 4'h2;
	 localparam WRITE_X_1 = 4'h3;
	 localparam WRITE_X_2 = 4'h4;
	 localparam WRITE_Y_1 = 4'h5;
	 localparam WRITE_Y_2 = 4'h6;
	 localparam WAIT_START_1 = 4'h7;
	 localparam WAIT_START_2 = 4'h8;
	 localparam START_BYTE_1 = 4'h9;
	 localparam START_BYTE_2 = 4'ha;
	 
    //sequential logic to update state and status
    always@(posedge clk, posedge rst) begin
		if(rst) begin
		    state <= WAIT;
			 status <= 2'd0;
		end
		else begin
		    state <= next_state;
			 status <= next_status;
		end
    end
    
    //combinational logic
    always@(*) begin
       //defaults
       next_state = state;
       addr = 2'd0;
       next_status = status;
		 data_out = 15'd0;
		 write = 1'b0;
            //state case statement
	    case(state)
	    	//wait for data available
	        WAIT: begin
	           //data available
	           if(dav)
	              //go to next state
	              next_state = START_BYTE_1;
	        end
	        //sending a start byte
		START_BYTE_1: begin
		   //transmit buffer ready
	           if(tbr) begin
	              //assert write signal
		      write = 1'b1;
		      //send first start byte
	              data_out = 8'hBA;
	              //go to next state
	              next_state = START_BYTE_2;
	           end
	        end
	        //send second start byte
		START_BYTE_2: begin
		   //transmit buffer ready
	           if(tbr) begin
	              //assert write signal
		      write = 1'b1;
		      //send second start byte
	              data_out = 8'h11;
	              //go to next state
	              next_state = WRITE_STATUS_1;
	           end
	        end
	        //write first byte of status
	        WRITE_STATUS_1: begin
	           //transmit buffer ready
	           if(tbr) begin
	              //read data from ps2_mouse
	              addr = 2'd0;
	              next_status = data_in[1:0];
	              //assert write signal
		      write = 1'b1;
		      //setup data for serial output
	              data_out = data_in[15:8];
	              //go to next state
	              next_state = WRITE_STATUS_2;
	           end
	        end
	        //write second byte of status
	        WRITE_STATUS_2: begin
	           //transmits buffer ready
	           if(tbr) begin
	              //read data from ps2_mouse
	              addr = 2'd0;
	              //assert write signal
		      write = 1'b1;
		      //setup data for serial output
	              data_out = data_in[7:0];
	              //go to next state
	              next_state = WRITE_X_1;
	           end
	        end
	        //write first byte of x position
	        WRITE_X_1: begin
	           //transmit buffer ready
	           if(tbr) begin
	              //read data from ps2_mouse
	              addr = 2'd1;
	              //assert write signal
		      write = 1'b1;
		      //setup data for serial output
	              data_out = data_in[15:8];
	              //go to next state
	              next_state = WRITE_X_2;
	           end
	        end
	        //write second byte of x position
	        WRITE_X_2: begin
	           //transmit buffer ready
	           if(tbr) begin
	              //read data from ps2_mouse
	              addr = 2'd1;
	              //assert write signal
		      write = 1'b1;
		      //setup data for serial output
	              data_out = data_in[7:0];
	              //go to next state
	              next_state = WRITE_Y_1;
	           end
	        end
	        //write first byte of y position
	        WRITE_Y_1: begin
	           //transmit buffer ready
	           if(tbr) begin
	              //read data from ps2_mouse
	              addr = 2'd2;
	              //assert write signal
		      write = 1'b1;
		      //setup data for serial output
	              data_out = data_in[15:8];
	              //go to next state
	              next_state = WRITE_Y_2;
	           end
	        end
	        //write second byte of y position
	        WRITE_Y_2: begin
	           if(tbr) begin
	              //read data from ps2_mouse
	              addr = 2'd2;
	              //assert write signal
		      write = 1'b1;
		      //setup data for serial output
	              data_out = data_in[7:0];
	              //go to next state
	              next_state = WAIT;
	           end
	        end
	    endcase
    end
    
endmodule
