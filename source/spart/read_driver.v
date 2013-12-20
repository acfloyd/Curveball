//read_driver module
module read_driver(
    input clk,						//system clock
    input rst,						//system reset
    input rda,						//receive data available
    input [7:0] data_in,				//data received 
    input [1:0] addr,					//input address
    output [15:0] data_out				//data output
);
	 
	 localparam MSTATUS = 2'b00;			//mouse status parameter
	 localparam XPOS = 2'b01;			//mouse x position parameter
	 localparam YPOS = 2'b10;			//mouse y position parameter
	 
	 reg[15:0] mouseData[0:2];			//memory mapped registers
    
	 //status, x and y location registers
	 reg [7:0] first_status, second_status, next_first_status, next_second_status;
	 reg [7:0] first_x_loc, second_x_loc, next_first_x_loc, next_second_x_loc;
	 reg [7:0] first_y_loc, second_y_loc, next_first_y_loc, next_second_y_loc;


    	 reg [3:0] state, next_state;			//state and next state		
	 reg next_dav, dav;				//data available
    
	 // state variables
	 localparam WAIT_START_1 = 4'hc;
	 localparam READ_START_1 = 4'hd;
	 localparam WAIT_START_2 = 4'he;
	 localparam READ_START_2 = 4'hf;
    	 localparam WAIT_STATUS_1 = 4'h0;
	 localparam READ_STATUS_1 = 4'h1;
	 localparam WAIT_STATUS_2 = 4'h2;
	 localparam READ_STATUS_2 = 4'h3;
	 localparam WAIT_X_1 = 4'h4;
	 localparam READ_X_1 = 4'h5;
	 localparam WAIT_X_2 = 4'h6;
	 localparam READ_X_2 = 4'h7;
	 localparam WAIT_Y_1 = 4'h8;
	 localparam READ_Y_1 = 4'h9;
	 localparam WAIT_Y_2 = 4'ha;
	 localparam READ_Y_2 = 4'hb;
	 
	 //setup data to output given an input address
	 assign data_out = (addr == 2'b00) ? mouseData[MSTATUS] : 
                (addr == 2'b01) ? mouseData[XPOS] :
                (addr == 2'b10) ? mouseData[YPOS] : 16'd0;
					 
	//update status, x and y location registers
	always @(posedge clk, posedge rst) begin
		if (rst) begin
			mouseData[MSTATUS] <= 16'd0;
			mouseData[XPOS] <= 16'd0;
			mouseData[YPOS] <= 16'd0;
		end
		else if (dav) begin
			mouseData[MSTATUS] <= {first_status, second_status};
			mouseData[XPOS] <= {first_x_loc, second_x_loc};
			mouseData[YPOS] <= {first_y_loc, second_y_loc};
		end
	end
    
    // sequential logic
    always@(posedge clk, posedge rst) begin
       //reset signals
       if(rst) begin
           state <= WAIT_START_1;	
	   first_status <= 8'd0;
	   second_status <= 8'd0;
	   first_x_loc <= 8'd0;
	   second_x_loc <= 8'd0;
	   first_y_loc <= 8'd0;
	   second_y_loc <= 8'd0;
	   dav <= 1'b0;
       end 
       else begin
	   //update state, status, x and y locations, and data available
           state <= next_state;		
	   first_status <= next_first_status;
	   second_status <= next_second_status;
	   first_x_loc <= next_first_x_loc;
	   second_x_loc <= next_second_x_loc;
	   first_y_loc <= next_first_y_loc;
	   second_y_loc <= next_second_y_loc;
	   dav <= next_dav;
       end
    end
    
    //combinational logic
    always@(*) begin
	//defaults
	next_state = state;
	next_first_status = first_status;
	next_second_status = second_status;
	next_first_x_loc = first_x_loc;
	next_second_x_loc = second_x_loc;
	next_first_y_loc = first_y_loc;
	next_second_y_loc = second_y_loc;
	next_dav = 1'b0;
	//state case statement
        case(state)
	   //wait for first start byte
           WAIT_START_1: begin
	      //receive data available
              if(rda) begin
	         //go to read start 1 state
                 next_state = READ_START_1;
              end 
              else begin
		 //stay in state
                 next_state = WAIT_START_1; 
              end
           end
	   //read first start byte
	   READ_START_1: begin
	      //not valid first start byte
	      if(data_in != 8'hBA)
		//go back to wait start 1 state
		next_state = WAIT_START_1;
	      else
		//valid first start byte, go to wait start 2
		next_state = WAIT_START_2;
           end
	   //wait for second start byte
	   WAIT_START_2: begin
              //receive data available
              if(rda) begin
		 //go to read start 2 state
                 next_state = READ_START_2;
              end 
              else begin
		 //stay in state
                 next_state = WAIT_START_2; 
              end
           end
	   //read second start byte
	   READ_START_2: begin
              //not valid second start byte
	      if(data_in != 8'h11)
		 //stay in state
	         next_state = WAIT_START_1;
	      else
                 //valid second start byte, go to wait status 1
		 next_state = WAIT_STATUS_1;
           end
           //wait for first status byte
	   WAIT_STATUS_1: begin
	      //receive data available
              if(rda) begin
                 //go to read status 1 state
                 next_state = READ_STATUS_1;
              end 
              else begin
		 //stay in state
                 next_state = WAIT_STATUS_1; 
              end
           end
           //read first status byte
           READ_STATUS_1: begin
	      //read first status byte and go to wait status 2 state
	      next_first_status = data_in;
	      next_state = WAIT_STATUS_2;
           end
           //wait for second status byte
           WAIT_STATUS_2: begin
	      //receive data available
              if(rda) begin
                 //go to read status 2 state
                 next_state = READ_STATUS_2;
              end 
              else begin
                 //stay in state
                 next_state = WAIT_STATUS_2; 
              end
           end
           //read second status byte
           READ_STATUS_2: begin
              //read second status byte and go to wait x 1 state
	      next_second_status = data_in;
              next_state = WAIT_X_1;
           end
           //wait for first x movement byte
           WAIT_X_1: begin
	      //receive data available
              if(rda) begin
                 //go to read x 1 state
                 next_state = READ_X_1;
              end 
              else begin
                 //stay in state
                 next_state = WAIT_X_1; 
              end
           end
           //read first x movement byte
           READ_X_1: begin
	      //read first x movement byte and go to wait x 2 state
	      next_first_x_loc = data_in;
              next_state = WAIT_X_2;
           end
           //wait for second x movement byte
           WAIT_X_2: begin
	      //receive data available
              if(rda) begin
		 //go to read x 2 state
                 next_state = READ_X_2;
              end 
              else begin
                 //stay in state
                 next_state = WAIT_X_2; 
              end
           end
	   //read second x movement byte
           READ_X_2: begin
	      //read second x movement byte and go to wait y 1 state
	      next_second_x_loc = data_in;
              next_state = WAIT_Y_1;
           end
	   //wait for first y movement byte
           WAIT_Y_1: begin
	      //receive data available
              if(rda) begin
                 //go to read y 1 state
                 next_state = READ_Y_1;
              end 
              else begin
                 //stay in state
                 next_state = WAIT_Y_1; 
              end
           end
	   //read first y movement byte
           READ_Y_1: begin
	      //read first y movement byte and go to wait y 2 state
	      next_first_y_loc = data_in;
              next_state = WAIT_Y_2;
           end
           //wait for second y movement byte
           WAIT_Y_2: begin
	      //receive data available	
              if(rda) begin
	         //go to read y 2 state
                 next_state = READ_Y_2;
              end 
              else begin
                 //stay in state
                 next_state = WAIT_Y_2; 
              end
           end
	   //read second y movement byte
           READ_Y_2: begin
	      //assert data available
	      next_dav = 1'b1;
              //read second y movement byte and go to wait start 1 state
	      next_second_y_loc = data_in;
              next_state = WAIT_START_1;
           end
       endcase
    end
endmodule


